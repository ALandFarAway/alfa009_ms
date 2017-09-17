// Black Rain Software 2009
//
// rule and setting definitions for Blackjack
// rules can be modified in-game by setting appropriate values on object running the game
// ex: to increase max bet set the int iMaxBet on sTag object, it will override the defined setting

#include "nw_o0_itemmaker"
#include "y_multiplayer_casino_lib"
#include "z_casino_stats_include"


// game rule settings, -1 = disabled, 1 = enabled, can be overridden in-game
const int iHard17 = -1;  // dealer stands on hard 17s only
const int iFiveCardCharlie = -1;  // player wins drawing five cards without busting
const int iDealerWinsTies = -1;  // dealer wins ties
const int iDoubleExposure = -1;  // both dealer cards visible, typically used with 100 iNaturalPayoff and dealer wins ties

// additional settings, can be overridden in-game
const float fNaturalPayoff = 1.5;  // percentage payoff for a natural blackjack
const int iNumDecks = 4;  // number of decks used in the game, at least four recommended for multiplayer games
const int iMaxBet = 5000;  // maximum bet, bet increment will *NOT* check to see if a single increment takes player stake past max bet
const int iMinBet = 100;   // minimum bet, see above
const int iBetIncrement = 100;  // increment of bet change

// system settings
const float fDealDelay = 0.5;  // delay between card deals
const float fPlayDelay = 0.75;  // delay between AI decisions
const int iIdleTimer = 30;  // how many seconds to allow a player to idle before taking measures
const string sDefaultName = "Casino Patron";  // default AI player name


// prototypes

int GetValueOfStack ( object oDealer, string sStackName, int iStackPointer );
void SetUpNewPlayer ( object oDealer, object oPC );
void UpdateGUIPlayerNames ( object oDealer );
void ShuffleDeck ( object oDealer );
void DealInitialHands ( object oDealer, int iPhase );
void ManageHandPosition ( object oDealer, int iPosition );
void PlayAIHand ( object oDealer, int iPosition );
void PlayDealerHand ( object oDealer );
void GenerateRoundResults ( object oDealer );
void InRoundIdleTimer ( object oDealer, int iCurrentPlayer );
void EndRoundIdleTimer ( object oDealer );


// get the total value of a stack, adjust for aces if necessary

int GetValueOfStack ( object oDealer, string sStackName, int iStackPointer ) {
	int i, iCardValue, iNumAces, iResult;
	string sCard;
	
	iNumAces = 0;
	iResult = 0;
	for ( i = 1 ; i <= iStackPointer ; i++ ) {
		sCard = GetLocalArrayString ( oDealer, sStackName, i );
		if ( GetStringLength(sCard) == 14 ) {
			// all 10 and face cards count as 10
			iResult = iResult + 10;
		} else {
			iCardValue = StringToInt ( GetStringRight ( sCard, 1 ) );
			if ( iCardValue == 1 ) {
				iResult = iResult + 11;
				iNumAces = iNumAces + 1;
			} else {
				iResult = iResult + iCardValue;
			}
		}		
	}
	
	while ( ( iResult > 21 ) && ( iNumAces > 0 ) ) {
		iResult = iResult - 10;
		iNumAces = iNumAces - 1;
	}
	
	return iResult;
}


// set a player up on the dealer object

void SetUpNewPlayer ( object oDealer, object oPC ) {
	int i, iMinBetLocal, iNumPlayers;
	string s, sVarName;
	
	// increment number of players
	iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
	iNumPlayers = iNumPlayers + 1;
	SetLocalInt ( oDealer, "iNumPlayers", iNumPlayers );
	
	// message all current players if more than one player at table
	if ( iNumPlayers > 1 ) {
		MPMessageAllPlayers ( oDealer, "Blackjack: " + GetName(oPC) + " has joined this table." );
	}
	
	// iterate through player positions to find the first available spot
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		sVarName = "i" + s + "isPlayer";
		if ( GetLocalInt ( oDealer, sVarName ) == 0 ) {
			// set up dealer vars
			SetLocalInt ( oDealer, sVarName, 1 );
			sVarName = "oPlayer" + s;
			SetLocalObject ( oDealer, sVarName, oPC );
			SetLocalInt ( oDealer, "iPlayer" + s + "GoldWon", 0 );
			SetLocalInt ( oDealer, "iPlayer" + s + "GoldLost", 0 );			
			SetPlayerStartTime ( oDealer, i );
			
			// set up GUI hidden fields	
			SetGUIObjectText ( oPC, "br_blackjack", "playerpos", -1, s );
			SetGUIObjectText ( oPC, "br_blackjack", "dealertag", -1, GetTag(oDealer) );				
						
			// set up GUI visible elements
			SetGUIObjectText ( oPC, "br_blackjack", "player_gold", -1, IntToString(GetGold(oPC)) );		
			iMinBetLocal = GetLocalInt ( oDealer, "iMinBet" );
			if ( iMinBetLocal == 0 ) {  // check for iMinBet local override
				iMinBetLocal = iMinBet;
			}
			SetGUIObjectText ( oPC, "br_blackjack", "player_stake", -1, IntToString(iMinBetLocal) );						
			sVarName = "iPlayer" + s + "Stake";
			SetLocalInt ( oDealer, sVarName, iMinBetLocal );

			// enable buttons
			SetGUIObjectHidden ( oPC, "br_blackjack", "notice_pane", TRUE );
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_ready", FALSE );
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_betplus", FALSE );
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_betminus", FALSE );									
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_quit", FALSE );			
					
			break;
		}
	}
	
	// start idle timer if more than one player in
	if ( iIdleTimer != 0 ) {
		if ( ( iNumPlayers > 1 ) && ( GetLocalInt ( oDealer, "iEndRoundIdleTimerActive" ) == 0 ) ) {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );	
			MPGUIDisplayComponent ( oDealer, "br_blackjack", "timerpane", 1 );
			EndRoundIdleTimer(oDealer);		
		} else if ( ( iNumPlayers > 1 ) && ( GetLocalInt ( oDealer, "iEndRoundIdleTimerActive" ) != 0 ) ) {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );	
			SetGUIObjectHidden ( oPC, "br_blackjack", "timerpane", FALSE );		
		}
	}
}


// update human player names for all players

void UpdateGUIPlayerNames ( object oDealer ) {
	int i;
	object oPlayer;
	string s;
	
	if ( iUsePCName == 0 ) {  // only use player character names
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				MPGUIUpdateText ( oDealer, "br_blackjack", "player" + s + "card1_name", GetName(oPlayer) );
			} else {
				MPGUIUpdateText ( oDealer, "br_blackjack", "player" + s + "card1_name", sDefaultName );
			}
		}
	} else {  // add PC name to character name
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				MPGUIUpdateText ( oDealer, "br_blackjack", "player" + s + "card1_name", GetName(oPlayer) + " - " + GetPCPlayerName(oPlayer) );
			} else {
				MPGUIUpdateText ( oDealer, "br_blackjack", "player" + s + "card1_name", sDefaultName );
			}
		}		
	}	
}


// shuffle algorithm for n decks of 52 standard playing cards
// 1-13 correspond to Spades, Ace is 1
// 14-26 Hearts, 27-39 Clubs, 40-52 Diamonds

void ShuffleDeck ( object oDealer ) {
	int i, iNumDecksLocal, j, k;
	string s;
	
	// populate the array with cards in order
	k = 0;
	
	// check for local override on number of decks to use
	iNumDecksLocal = GetLocalInt ( oDealer, "iNumDecks" );
	if ( iNumDecksLocal == 0 ) {
		iNumDecksLocal = iNumDecks;
	}

	for ( i = 1 ; i <= iNumDecksLocal ; i++ ) {
		s = "br_card_spad";
		for ( j = 1 ; j <= 13 ; j++ ) {
			k++;		
			SetLocalArrayString ( oDealer, "sCardStack", k, s + IntToString(j) );
		}				
		
		s = "br_card_hear";
		for ( j = 1 ; j <= 13 ; j++ ) {
			k++;		
			SetLocalArrayString ( oDealer, "sCardStack", k, s + IntToString(j) );
		}		
				
		s = "br_card_club";
		for ( j = 1 ; j <= 13 ; j++ ) {
			k++;		
			SetLocalArrayString ( oDealer, "sCardStack", k, s + IntToString(j) );
		}		
			
		s = "br_card_diam";
		for ( j = 1 ; j <= 13 ; j++ ) {
			k++;		
			SetLocalArrayString ( oDealer, "sCardStack", k, s + IntToString(j) );
		}								
	}

	// sort the array
	while ( k != 1 ) {
		i = Random(k) + 1;
		s =	GetLocalArrayString ( oDealer, "sCardStack", k );
		SetLocalArrayString ( oDealer, "sCardStack", k, GetLocalArrayString ( oDealer, "sCardStack", i ) );
		SetLocalArrayString ( oDealer, "sCardStack", i, s );
		k--;
	}

	// set variables
	SetLocalInt ( oDealer, "iShuffleDeck", 0 );
	SetLocalInt ( oDealer, "iStackPointer", 1 );
}


// deal starting set of cards for all players, start at -1 for cleanup

void DealInitialHands ( object oDealer, int iPhase ) {
	int i, iCardPos, iDoubleExposureLocal, iNumDecksLocal, iPlayerPos, iStackPointer, j;
	string s, sCard, sComponentString, sPlayerPos;
	
	if ( iPhase == -1 ) {  // iPhase 0 is for board cleanup or initialization
		// check to see if the dealer has ever shuffled before
		if ( GetLocalInt ( oDealer, "iStackPointer" ) == 0 ) {
			ShuffleDeck(oDealer);
			DealInitialHands ( oDealer, 0 );		
		} else {	
			// clean up from previous round
			AssignCommand ( oDealer, PlaySound("it_paper") );
				
			sComponentString = "dealer_msg=0";
			for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
				s = IntToString(i);
				sComponentString = sComponentString + ";player" + s + "card1_msg=0;player" + s + "card2_msg=0";
				iStackPointer = GetLocalInt ( oDealer, "iPlayer" + s +"Pointer1" );
				for ( j = 1 ; j <= iStackPointer ; j++ ) {
					sComponentString = sComponentString + ";player" + s + "card1_" + IntToString(j) + "=0";
				}
				iStackPointer = GetLocalInt ( oDealer, "iPlayer" + s +"Pointer2" );
				for ( j = 1 ; j <= iStackPointer ; j++ ) {
					sComponentString = sComponentString + ";player" + s + "card2_" + IntToString(j) + "=0";
				}				
			}
			iStackPointer = GetLocalInt ( oDealer, "iDealerPointer" );
			for ( i = 1 ; i <= iStackPointer ; i++ ) {
				sComponentString = sComponentString + ";dealercard_" + IntToString(i) + "=0";
			}			
				
			MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "", "", sComponentString );	
		
			// check if the deck needs shuffling, do this before the first card is dealt
			if ( GetLocalInt ( oDealer, "iShuffleDeck" ) == 1 ) {  // shuffle the deck and restart the deal
				ShuffleDeck(oDealer);
				MPMessageAllPlayers ( oDealer, "Blackjack: Please wait for the dealer to shuffle." );
				DelayCommand ( 3.0, DealInitialHands ( oDealer, 0 ) );
			} else {  // set up card deals
				DelayCommand ( fDealDelay, DealInitialHands ( oDealer, 0 ) );
			}
		}
	} else if ( iPhase <= 1 ) {  // handle dealer cards
		AssignCommand ( oDealer, PlaySound("it_paper") );
		iCardPos = ( iPhase % 2 ) + 1;
	
		// pop the next card from the stack and update stack pointer
		iStackPointer = GetLocalInt ( oDealer, "iStackPointer" );	
		sCard = GetLocalArrayString ( oDealer, "sCardStack", iStackPointer );
		iNumDecksLocal = GetLocalInt ( oDealer, "iNumDecks" );
		if ( iNumDecksLocal == 0 ) {
			iNumDecksLocal = iNumDecks;
		}
		if ( iStackPointer == ( iNumDecksLocal * 52 ) ) {
			// revert to top of stack if end reached and set shuffle flag
			iStackPointer = 1;
			SetLocalInt ( oDealer, "iShuffleDeck", 1 );				
		} else {
			iStackPointer = iStackPointer + 1;
		}
		SetLocalInt ( oDealer, "iStackPointer", iStackPointer );	
		
		// set the card and update player graphics
		SetLocalArrayString ( oDealer, "sDealerStack", iCardPos, sCard );	
		if ( iCardPos == 1 ) {  // check double exposure rule
			iDoubleExposureLocal = GetLocalInt ( oDealer, "iDoubleExposure" );
			if ( iDoubleExposureLocal == 0 ) {
				iDoubleExposureLocal = iDoubleExposure;
			}
			if ( iDoubleExposureLocal == -1 ) {
				sCard = "br_card_back";			
			}
		}
		MPGUIUpdateTexture ( oDealer, "br_blackjack", "dealercard_" + IntToString(iCardPos), sCard );
		
		// deal next card
		DelayCommand ( fDealDelay, DealInitialHands ( oDealer, iPhase + 1 ) );				
	} else {  // handle all player cards
		AssignCommand ( oDealer, PlaySound("it_paper") );
		iPlayerPos = iPhase / 2;
		sPlayerPos = IntToString(iPlayerPos);
		iCardPos = ( iPhase % 2 ) + 1;
	
		// pop the next card from the stack and update stack pointer
		iStackPointer = GetLocalInt ( oDealer, "iStackPointer" );	
		sCard = GetLocalArrayString ( oDealer, "sCardStack", iStackPointer );
		iNumDecksLocal = GetLocalInt ( oDealer, "iNumDecks" );
		if ( iNumDecksLocal == 0 ) {
			iNumDecksLocal = iNumDecks;
		}
		if ( iStackPointer == ( iNumDecksLocal * 52 ) ) {
			// revert to top of stack if end reached and set shuffle flag
			iStackPointer = 1;
			SetLocalInt ( oDealer, "iShuffleDeck", 1 );				
		} else {
			iStackPointer = iStackPointer + 1;
		}
		SetLocalInt ( oDealer, "iStackPointer", iStackPointer );	
		
		// set the card and update player graphics
		SetLocalArrayString ( oDealer, "sPlayer" + sPlayerPos + "Stack1", iCardPos, sCard );
		MPGUIUpdateTexture ( oDealer, "br_blackjack", "player" + sPlayerPos + "card1_" + IntToString(iCardPos), sCard );
	
		if ( iPhase == ( ( iNumPlayersAllowed * 2 ) + 1 ) ) {
			// initialize stack pointers
			for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
				s = IntToString(i);
				SetLocalInt ( oDealer, "iPlayer" + s + "Pointer1", 2 );
				SetLocalInt ( oDealer, "iPlayer" + s + "Pointer2", 0 );				
			}
			SetLocalInt ( oDealer, "iDealerPointer", 2 );
		
			// initialize position 1 to start the round
			ManageHandPosition ( oDealer, 1 );
		} else {
			// deal next card
			DelayCommand ( fDealDelay, DealInitialHands ( oDealer, iPhase + 1 ) );
		}
	}
}	


// manage the flow of a round, either pass to AI or enable human player control

void ManageHandPosition ( object oDealer, int iPosition ) {
	int iCard1StrLen, iCard2StrLen, iDoubleExposureLocal, iStake;
	object oPC;
	string s, sCard1, sCard2, sComponentString, sPrevPlayer, sVarName;
	
	// set active player for idle timer
	SetLocalInt ( oDealer, "iActivePlayer", iPosition );	
	
	if ( iPosition > iNumPlayersAllowed ) {  // dealer position
		// update position background
		sComponentString = "dealer_bg=1;";
		s = IntToString(iNumPlayersAllowed);		
		if ( GetLocalInt ( oDealer, "iPlayer" + s + "Split" ) == 0 ) {
			sComponentString = sComponentString + "player" + s + "card1_bg=0";
		} else {
			sComponentString = sComponentString + "player" + s + "card2_bg=0";			
		}
		MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "", "", sComponentString );
	
		// check to see if dealer first card needs to be flipped
		iDoubleExposureLocal = GetLocalInt ( oDealer, "iDoubleExposure" );
		if ( iDoubleExposureLocal == 0 ) {
			iDoubleExposureLocal = iDoubleExposure;
		}
		if ( iDoubleExposure == -1 ) {
			sCard1 = GetLocalArrayString ( oDealer, "sDealerStack", 1 );
			MPGUIUpdateTexture ( oDealer, "br_blackjack", "dealercard_1", sCard1 );
		}
		
		// resolve the hand
		PlayDealerHand(oDealer);		
	} else {  // human or AI non-dealer positions
		// update position background
		s = IntToString(iPosition);		
			
		if ( iPosition == 1 ) {  // first player
			MPGUIDisplayComponent ( oDealer, "br_blackjack", "player1card1_bg", 1 );				
		} else {
			sPrevPlayer = IntToString(iPosition - 1 );
			sComponentString = "player" + s + "card1_bg=1;";
			if ( GetLocalInt ( oDealer, "iPlayer" + sPrevPlayer + "Split" ) == 0 ) {
				sComponentString = sComponentString + "player" + sPrevPlayer + "card1_bg=0";
			} else {
				sComponentString = sComponentString + "player" + sPrevPlayer + "card2_bg=0";			
			}
			MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "", "", sComponentString );
		}
		
		if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {		
			// human player, enable controls
			oPC = GetLocalObject ( oDealer, "oPlayer" + s );
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_hit", FALSE );
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_stand", FALSE );	
			
			// check whether double and split need to be enabled
			sVarName = "iPlayer" + s + "Stake";
			iStake = GetLocalInt ( oDealer, sVarName );
			if ( GetGold(oPC) >= iStake ) {
				// double is enabled if player has the gold
				SetGUIObjectDisabled ( oPC, "br_blackjack", "button_double", FALSE );
				
				// check for split conditions
				sCard1 = GetLocalArrayString ( oDealer, "sPlayer" + s + "Stack1", 1 );
				sCard2 = GetLocalArrayString ( oDealer, "sPlayer" + s + "Stack1", 2 );
				iCard1StrLen = GetStringLength(sCard1);
				iCard2StrLen = GetStringLength(sCard2);	
				if ( ( iCard1StrLen == 14 ) && ( iCard2StrLen == 14 ) ) {
					// a pair of 10 or face cards, splittable
					SetGUIObjectDisabled ( oPC, "br_blackjack", "button_split", FALSE );
				} else if ( ( iCard1StrLen == 13 ) && ( iCard2StrLen == 13 ) ) {
					if ( GetStringRight ( sCard1, 1 ) == GetStringRight ( sCard2, 1 ) ) {
						// identical value ace to nine cards, splittable
						SetGUIObjectDisabled ( oPC, "br_blackjack", "button_split", FALSE );					
					}
				}						
			}			
			
			// set up griefing timer
			if ( iIdleTimer != 0 ) {
				SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );
				SetGUIObjectHidden ( oPC, "br_blackjack", "timerpane", FALSE );	
				InRoundIdleTimer ( oDealer, iPosition );
			}
		} else {
			// nonhuman player, call AI to play hand
			PlayAIHand ( oDealer, iPosition );
		}
	}
}


// resolve a non-human non-dealer position's hand

void PlayAIHand ( object oDealer, int iPosition ) {
	int iFiveCardCharlieLocal, iHandValue, iNumDecksLocal, iPlayerPointer, iStackPointer;
	string s, sCard, sPointerName, sStackName;

	// evaluate current hand to see whether a hit is desirable
	s = IntToString(iPosition);
	sPointerName = "iPlayer" + s + "Pointer1";
	iPlayerPointer = GetLocalInt ( oDealer, sPointerName );
	sStackName = "sPlayer" + s + "Stack1";
	iHandValue = GetValueOfStack ( oDealer, sStackName, iPlayerPointer );
	
	// get Five Card Charlie rule status
	iFiveCardCharlieLocal = GetLocalInt ( oDealer, "iFiveCardCharlie" );
	if ( iFiveCardCharlieLocal == 0 ) {
		iFiveCardCharlieLocal = iFiveCardCharlie;
	}	
	
	if ( iHandValue > 21 ) {  // bust
		// update GUI
		MPGUIUpdateText ( oDealer, "br_blackjack", "player" + s + "card1_msg", "BUST" );		
		
		// hand finished, kick back to hand manager	
		DelayCommand ( fPlayDelay, ManageHandPosition ( oDealer, iPosition + 1 ) );	
	} else if ( ( iPlayerPointer == 5 ) && ( iHandValue <= 21 ) && ( iFiveCardCharlieLocal == 1 ) ) {	// Five Card Charlie
		// update GUI
		MPGUIUpdateText ( oDealer, "br_blackjack", "player" + s + "card1_msg", "FIVE CARD CHARLIE" );					
		
		// hand finished, kick back to hand manager	
		DelayCommand ( fPlayDelay, ManageHandPosition ( oDealer, iPosition + 1 ) );
	} else if ( ( iHandValue >= 20 ) && ( iHandValue <= 21 ) ) {  // 100% stand
		// update GUI
		MPGUIUpdateText ( oDealer, "br_blackjack", "player" + s + "card1_msg", "STAND" );		
		
		// hand finished, kick back to hand manager	
		DelayCommand ( fPlayDelay, ManageHandPosition ( oDealer, iPosition + 1 ) );			
	} else if ( ( iHandValue >= 18 ) && ( iHandValue <= 19 ) ) {
		// 10% hit
		if ( Random(10) == 0 ) {  // hit
			// draw another card and update graphics
			iStackPointer = GetLocalInt ( oDealer, "iStackPointer" );
			iPlayerPointer = iPlayerPointer + 1;
			sCard = GetLocalArrayString ( oDealer, "sCardStack", iStackPointer );
			SetLocalArrayString ( oDealer, sStackName, iPlayerPointer, sCard );
			SetLocalInt ( oDealer, sPointerName, iPlayerPointer );
			MPGUIUpdateTexture ( oDealer, "br_blackjack", "player" + s + "card1_" + IntToString(iPlayerPointer), sCard );
			
			// update stack pointer
			iNumDecksLocal = GetLocalInt ( oDealer, "iNumDecks" );
			if ( iNumDecksLocal == 0 ) {
				iNumDecksLocal = iNumDecks;
			}			
			if ( iStackPointer == ( iNumDecksLocal * 52 ) ) {
				// revert to top of stack if end reached and set shuffle flag
				iStackPointer = 1;
				SetLocalInt ( oDealer, "iShuffleDeck", 1 );				
			} else {
				iStackPointer = iStackPointer + 1;
			}
			SetLocalInt ( oDealer, "iStackPointer", iStackPointer );			
			
			DelayCommand ( fPlayDelay, PlayAIHand ( oDealer, iPosition ) );			
		} else {  // stand
			// update GUI
			MPGUIUpdateText ( oDealer, "br_blackjack", "player" + s + "card1_msg", "STAND" );	
			
			// hand finished, kick back to hand manager	
			DelayCommand ( fPlayDelay, ManageHandPosition ( oDealer, iPosition + 1 ) );		
		}	
	} else if ( ( iHandValue >= 16 ) && ( iHandValue <= 17 ) ) {
		// 30% hit
		if ( Random(10) <= 2 ) {  // hit
			// draw another card and update graphics
			iStackPointer = GetLocalInt ( oDealer, "iStackPointer" );
			iPlayerPointer = iPlayerPointer + 1;
			sCard = GetLocalArrayString ( oDealer, "sCardStack", iStackPointer );
			SetLocalArrayString ( oDealer, sStackName, iPlayerPointer, sCard );
			SetLocalInt ( oDealer, sPointerName, iPlayerPointer );
			MPGUIUpdateTexture ( oDealer, "br_blackjack", "player" + s + "card1_" + IntToString(iPlayerPointer), sCard );
			
			// update stack pointer
			iNumDecksLocal = GetLocalInt ( oDealer, "iNumDecks" );
			if ( iNumDecksLocal == 0 ) {
				iNumDecksLocal = iNumDecks;
			}			
			if ( iStackPointer == ( iNumDecksLocal * 52 ) ) {
				// revert to top of stack if end reached and set shuffle flag
				iStackPointer = 1;
				SetLocalInt ( oDealer, "iShuffleDeck", 1 );				
			} else {
				iStackPointer = iStackPointer + 1;
			}
			SetLocalInt ( oDealer, "iStackPointer", iStackPointer );			
			
			DelayCommand ( fPlayDelay, PlayAIHand ( oDealer, iPosition ) );			
		} else {  // stand
			// update GUI
			MPGUIUpdateText ( oDealer, "br_blackjack", "player" + s + "card1_msg", "STAND" );
				
			// hand finished, kick back to hand manager	
			DelayCommand ( fPlayDelay, ManageHandPosition ( oDealer, iPosition + 1 ) );			
		}			
	} else if ( ( iHandValue >= 14 ) && ( iHandValue <= 15 ) ) {
		// 70% hit
		if ( Random(10) <= 6 ) {  // hit
			// draw another card and update graphics
			iStackPointer = GetLocalInt ( oDealer, "iStackPointer" );
			iPlayerPointer = iPlayerPointer + 1;
			sCard = GetLocalArrayString ( oDealer, "sCardStack", iStackPointer );
			SetLocalArrayString ( oDealer, sStackName, iPlayerPointer, sCard );
			SetLocalInt ( oDealer, sPointerName, iPlayerPointer );
			MPGUIUpdateTexture ( oDealer, "br_blackjack", "player" + s + "card1_" + IntToString(iPlayerPointer), sCard );
			
			// update stack pointer
			iNumDecksLocal = GetLocalInt ( oDealer, "iNumDecks" );
			if ( iNumDecksLocal == 0 ) {
				iNumDecksLocal = iNumDecks;
			}			
			if ( iStackPointer == ( iNumDecksLocal * 52 ) ) {
				// revert to top of stack if end reached and set shuffle flag
				iStackPointer = 1;
				SetLocalInt ( oDealer, "iShuffleDeck", 1 );				
			} else {
				iStackPointer = iStackPointer + 1;
			}
			SetLocalInt ( oDealer, "iStackPointer", iStackPointer );			
			
			DelayCommand ( fPlayDelay, PlayAIHand ( oDealer, iPosition ) );			
		} else {  // stand
			// update GUI
			MPGUIUpdateText ( oDealer, "br_blackjack", "player" + s + "card1_msg", "STAND" );		
			
			// hand finished, kick back to hand manager	
			DelayCommand ( fPlayDelay, ManageHandPosition ( oDealer, iPosition + 1 ) );			
		}			
	} else {
		// 100% hit, draw another card and update graphics
		iStackPointer = GetLocalInt ( oDealer, "iStackPointer" );
		iPlayerPointer = iPlayerPointer + 1;
		sCard = GetLocalArrayString ( oDealer, "sCardStack", iStackPointer );
		SetLocalArrayString ( oDealer, sStackName, iPlayerPointer, sCard );
		SetLocalInt ( oDealer, sPointerName, iPlayerPointer );
		MPGUIUpdateTexture ( oDealer, "br_blackjack", "player" + s + "card1_" + IntToString(iPlayerPointer), sCard );
			
		// update stack pointer
		iNumDecksLocal = GetLocalInt ( oDealer, "iNumDecks" );
		if ( iNumDecksLocal == 0 ) {
			iNumDecksLocal = iNumDecks;
		}			
		if ( iStackPointer == ( iNumDecksLocal * 52 ) ) {
			// revert to top of stack if end reached and set shuffle flag
			iStackPointer = 1;
			SetLocalInt ( oDealer, "iShuffleDeck", 1 );				
		} else {
			iStackPointer = iStackPointer + 1;
		}
		SetLocalInt ( oDealer, "iStackPointer", iStackPointer );			
			
		DelayCommand ( fPlayDelay, PlayAIHand ( oDealer, iPosition ) );	
	}
}


// resolve the dealer's hand

void PlayDealerHand ( object oDealer ) {
	int i, iCardValue, iDealerPointer, iHandValue, iHandValueUnmodded, iHard17Local, iNumAces, iNumDecksLocal, iStackPointer;
	string sCard;

	// evaluate current hand
	iDealerPointer = GetLocalInt ( oDealer, "iDealerPointer" );
	iHandValue = GetValueOfStack ( oDealer, "sDealerStack", iDealerPointer );
	
	if ( iHandValue > 21 ) {  // bust
		// update player graphics
		MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "", "dealer_msg=BUST", "dealer_bg=0" );
		
		// record final hand value and move to resolution
		SetLocalInt ( oDealer, "iDealerFinalHand", iHandValue );
		DelayCommand ( fPlayDelay, GenerateRoundResults(oDealer) );
	} else if ( ( iHandValue > 17 ) && ( iHandValue <= 21 ) ) {  // mandatory stand
		// update player graphics
		MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "", "dealer_msg=STAND", "dealer_bg=0" );	
		
		// record final hand value and move to resolution
		SetLocalInt ( oDealer, "iDealerFinalHand", iHandValue );
		DelayCommand ( fPlayDelay, GenerateRoundResults(oDealer) );
	} else if ( iHandValue == 17 ) {  // check hard 17
		// check for dealer override
		iHard17Local = GetLocalInt ( oDealer, "iHard17" );
		if ( iHard17Local == 0 ) {
			iHard17Local = iHard17;
		}
		
		if ( iHard17Local == 1 ) {  // dealer stands on hard 17s only
			// get the unmodified ( all aces at 11 ) value of the dealer hand and count aces
			iHandValueUnmodded = 0;
			iNumAces = 0;
			iDealerPointer = GetLocalInt ( oDealer, "iDealerPointer" );
			for ( i = 1 ; i <= iDealerPointer ; i++ ) {
				sCard = GetLocalArrayString ( oDealer, "sDealerStack", i );
				if ( GetStringLength(sCard) == 14 ) {  // face card
					iHandValueUnmodded = iHandValueUnmodded + 10;
				} else {
					iCardValue = StringToInt(GetStringRight ( sCard, 1 ));
					if ( iCardValue == 1 ) {  // ace
						iHandValueUnmodded = iHandValueUnmodded + 11;		
						iNumAces = iNumAces + 1;				
					} else {  // non face non ace card
						iHandValueUnmodded = iHandValueUnmodded + iCardValue;
					}
				}
			}
			
			// check whether dealer's hand is hard or soft 17
			while ( ( iHandValueUnmodded > 17 ) && ( iNumAces != 0 ) ) {
				iHandValueUnmodded = iHandValueUnmodded - 10;
				iNumAces = iNumAces -1;
			}
			
			if ( iNumAces == 0 ) {  // hard 17, stand
				// update player graphics
				MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "", "dealer_msg=STAND", "dealer_bg=0" );				
				
				// record final hand value and move to resolution
				SetLocalInt ( oDealer, "iDealerFinalHand", iHandValue );
				DelayCommand ( fPlayDelay, GenerateRoundResults(oDealer) );				
			} else {  // soft 17, hit
				// get the next card on stack and move to dealer stack, update dealer pointer
				iStackPointer = GetLocalInt ( oDealer, "iStackPointer" );
				sCard = GetLocalArrayString ( oDealer, "sCardStack", iStackPointer );
				iDealerPointer = iDealerPointer + 1;
				SetLocalArrayString ( oDealer, "sDealerStack", iDealerPointer, sCard );
				SetLocalInt ( oDealer, "iDealerPointer", iDealerPointer );
		
				// update stack pointer
				iNumDecksLocal = GetLocalInt ( oDealer, "iNumDecks" );
				if ( iNumDecksLocal == 0 ) {
					iNumDecksLocal = iNumDecks;
				}
				if ( iStackPointer == ( iNumDecksLocal * 52 ) ) {
					// revert to top of stack if end reached and set shuffle flag
					iStackPointer = 1;
					SetLocalInt ( oDealer, "iShuffleDeck", 1 );				
				} else {
					iStackPointer = iStackPointer + 1;
				}
				SetLocalInt ( oDealer, "iStackPointer", iStackPointer );
				
				// update player graphics
				MPGUIUpdateTexture ( oDealer, "br_blackjack", "dealercard_" + IntToString(iDealerPointer), sCard );	
				
				// set up next dealer play
				DelayCommand ( fPlayDelay, PlayDealerHand(oDealer) );			
			}
		} else {  // dealer stands on all 17s
			// update player graphics
			MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "", "dealer_msg=STAND", "dealer_bg=0" );		
			
			// record final hand value and move to resolution
			SetLocalInt ( oDealer, "iDealerFinalHand", iHandValue );
			DelayCommand ( fPlayDelay, GenerateRoundResults(oDealer) );		
		}
	} else {  // mandatory hit
		// get the next card on stack and move to dealer stack, update dealer pointer
		iStackPointer = GetLocalInt ( oDealer, "iStackPointer" );
		sCard = GetLocalArrayString ( oDealer, "sCardStack", iStackPointer );
		iDealerPointer = iDealerPointer + 1;
		SetLocalArrayString ( oDealer, "sDealerStack", iDealerPointer, sCard );
		SetLocalInt ( oDealer, "iDealerPointer", iDealerPointer );

		// update stack pointer
		iNumDecksLocal = GetLocalInt ( oDealer, "iNumDecks" );
		if ( iNumDecksLocal == 0 ) {
			iNumDecksLocal = iNumDecks;
		}
		if ( iStackPointer == ( iNumDecksLocal * 52 ) ) {
			// revert to top of stack if end reached and set shuffle flag
			iStackPointer = 1;
			SetLocalInt ( oDealer, "iShuffleDeck", 1 );				
		} else {
			iStackPointer = iStackPointer + 1;
		}
		SetLocalInt ( oDealer, "iStackPointer", iStackPointer );
		
		// update player graphics
		MPGUIUpdateTexture ( oDealer, "br_blackjack", "dealercard_" + IntToString(iDealerPointer), sCard );	
		
		// set up next dealer play
		DelayCommand ( fPlayDelay, PlayDealerHand(oDealer) );						
	}
}


// generate round results and compensate players

void GenerateRoundResults ( object oDealer ) {
	int i, iDealerHandValue, iDealerPointer, iGold, iPlayerDoubled, iPlayerGold, iPlayerHand1Value, iPlayerHand2Value, iPlayerPointer, iPlayerSplit, iStake, iWaitList;
	object oPC;
	string s, sMsg, sVarNameLost, sVarNameWon;
	
	// play coins sound
	AssignCommand ( oDealer, PlaySound("it_coins") );
	SetLocalInt ( oDealer, "iActivePlayer", 0 );
		
	// get dealer hand value
	iDealerHandValue = GetLocalInt ( oDealer, "iDealerFinalHand" );
	
	// find human players
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
			// set up initial payoff
			iGold = 0;	
		
			// human player found, get player object, hand value, stake, double and split status, player gold
			oPC = GetLocalObject ( oDealer, "oPlayer" + s );
			iPlayerHand1Value = GetLocalInt ( oDealer, "iPlayer" + s + "FinalHand1" );
			iStake = GetLocalInt ( oDealer, "iPlayer" + s + "Stake" );
			iPlayerDoubled = GetLocalInt ( oDealer, "iPlayer" + s +"Doubled" );
			iPlayerSplit = GetLocalInt ( oDealer, "iPlayer" + s +"Split" );			
			iPlayerGold = GetGold(oPC);
			sVarNameWon = "iPlayer" + s + "GoldWon";
			sVarNameLost = "iPlayer" + s + "GoldLost";
						
			// evaluate hand against dealer
			if ( iPlayerHand1Value > 21 ) {  // player busts
				if ( iDealerHandValue > 21 ) {  // tie hand if dealer busts
					sMsg = "Blackjack: You and the dealer both bust, push.";
					if ( iPlayerDoubled == 1 ) {
						iGold = iStake * 2;
					} else {
						iGold = iStake;
					} 
				} else {  // player loses
					if ( iPlayerDoubled == 1 ) {
						SetLocalInt ( oDealer, sVarNameLost, GetLocalInt ( oDealer, sVarNameLost ) + ( iStake * 2 ) );
					} else {
						SetLocalInt ( oDealer, sVarNameLost, GetLocalInt ( oDealer, sVarNameLost ) + iStake );
					} 				
					sMsg = "Blackjack: " + IntToString(iPlayerHand1Value) + " bust, you lose.";
				}
			} else if ( iPlayerHand1Value == 21 ) {  // evaluate for natural blackjack
				iPlayerPointer = GetLocalInt ( oDealer, "iPlayer" + s + "Pointer1" );
				if ( iPlayerPointer == 2 ) {  // natural blackjack
					if ( iDealerHandValue == 21 ) {  // check to see if dealer blackjacked
						iDealerPointer = GetLocalInt ( oDealer, "iDealerPointer" );
						if ( iDealerPointer == 2 ) {  // dealer natural, push
							sMsg = "Blackjack: You and the dealer both draw natural blackjacks, push.";
							iGold = iStake;					
						} else {  // dealer not natural, loses
							sMsg = "Blackjack: You draw a natural blackjack, you win.";
							iGold = FloatToInt ( IntToFloat(iStake) * ( fNaturalPayoff + 1.0 ) );
							SetLocalInt ( oDealer, sVarNameWon, GetLocalInt ( oDealer, sVarNameWon ) + FloatToInt ( IntToFloat(iStake) * fNaturalPayoff ) );							
						}				
					} else {  // dealer loses
						sMsg = "Blackjack: You draw a natural blackjack, you win.";
						iGold = FloatToInt ( IntToFloat(iStake) * ( fNaturalPayoff + 1.0 ) );
						SetLocalInt ( oDealer, sVarNameWon, GetLocalInt ( oDealer, sVarNameWon ) + FloatToInt ( IntToFloat(iStake) * fNaturalPayoff ) );												
					}
				} else {  // not natural
					if ( iDealerPointer == 21 ) {  // push
						sMsg = "Blackjack: Your 21 ties the dealer's 21, push.";
						if ( iPlayerDoubled == 1 ) {
							iGold = iStake * 2;
						} else {
							iGold = iStake;
						} 					
					} else {  // dealer loses
						sMsg = "Blackjack: Your 21 beats the dealer's " + IntToString(iDealerHandValue) + ", you win.";
						if ( iPlayerDoubled == 1 ) {
							iGold = iStake * 4;
							SetLocalInt ( oDealer, sVarNameWon, GetLocalInt ( oDealer, sVarNameWon ) + ( iStake * 2 ) );							
						} else {
							iGold = iStake * 2;
							SetLocalInt ( oDealer, sVarNameWon, GetLocalInt ( oDealer, sVarNameWon ) + iStake );						
						} 										
					}
				}
			} else if ( iPlayerHand1Value > iDealerHandValue ) {  // player hand value is higher, player wins
				// generate the appropriate message
				if ( iDealerHandValue > 21 ) {
					sMsg = "Blackjack: Dealer busts, you win.";				
				} else {
					sMsg = "Blackjack: Your " + IntToString(iPlayerHand1Value) + " beats the dealer's " + IntToString(iDealerHandValue) + ", you win.";
				}
				
				// generate the appropriate payoff
				if ( iPlayerDoubled == 1 ) {
					iGold = iStake * 4;
					SetLocalInt ( oDealer, sVarNameWon, GetLocalInt ( oDealer, sVarNameWon ) + ( iStake * 2 ) );												
				} else {
					iGold = iStake * 2;
					SetLocalInt ( oDealer, sVarNameWon, GetLocalInt ( oDealer, sVarNameWon ) + iStake );							
				} 					
			} else if ( iPlayerHand1Value == iDealerHandValue ) {  // player hand value is equal
				// generate the message
				sMsg = "Blackjack: Tied hands, push.";
				
				// generate the appropriate payoff
				if ( iPlayerDoubled == 1 ) {
					iGold = iStake * 2;
				} else {
					iGold = iStake;
				} 							
			} else {  // player hand value is lower
				if ( iDealerHandValue > 21 ) {  // dealer busts, player wins
					sMsg = "Blackjack: Dealer busts, you win.";	
					
					// generate the appropriate payoff
					if ( iPlayerDoubled == 1 ) {
						iGold = iStake * 4;
						SetLocalInt ( oDealer, sVarNameWon, GetLocalInt ( oDealer, sVarNameWon ) + ( iStake * 2 ) );
					} else {
						iGold = iStake * 2;
						SetLocalInt ( oDealer, sVarNameWon, GetLocalInt ( oDealer, sVarNameWon ) + iStake );
					} 									
				} else {  // player loses
					sMsg = "Blackjack: Your " + IntToString(iPlayerHand1Value) + " loses to the dealer's " + IntToString(iDealerHandValue) + ", you lose.";	
					if ( iPlayerDoubled == 1 ) {
						SetLocalInt ( oDealer, sVarNameLost, GetLocalInt ( oDealer, sVarNameLost ) + ( iStake * 2 ) );
					} else {
						SetLocalInt ( oDealer, sVarNameLost, GetLocalInt ( oDealer, sVarNameLost ) + iStake );
					} 				
				}
			}
			
			// message and pay player
			SendMessageToPC ( oPC, sMsg );
			if ( iGold != 0 ) {
				iPlayerGold = iPlayerGold + iGold;
				GiveGoldToCreature ( oPC, iGold, TRUE );
			}
		
			if ( iPlayerSplit == 2 ) {  // 2nd hand needs to be evaluated
				// reset payoff, get player 2nd hand
				iGold = 0;
				iPlayerHand2Value = GetLocalInt ( oDealer, "iPlayer" + s + "FinalHand2" );
							
				// evaluate 2nd hand against dealer
				if ( iPlayerHand2Value > 21 ) {  // player busts
					if ( iDealerHandValue > 21 ) {  // tie hand if dealer busts
						sMsg = "Blackjack: Second hand busted, push.";
						iGold = iStake;
					} else {  // player loses
						sMsg = "Blackjack: Second hand " + IntToString(iPlayerHand2Value) + " bust, you lose.";
						SetLocalInt ( oDealer, sVarNameLost, GetLocalInt ( oDealer, sVarNameLost ) + iStake );					
					}
				} else if ( iPlayerHand2Value == 21 ) {  // evaluate for natural blackjack
					iPlayerPointer = GetLocalInt ( oDealer, "iPlayer" + s + "Pointer2" );
					if ( iPlayerPointer == 2 ) {  // natural blackjack
						if ( iDealerHandValue == 21 ) {  // check to see if dealer blackjacked
							if ( iDealerPointer == 2 ) {  // dealer natural, push
								sMsg = "Blackjack: Second hand natural blackjack ties dealer's natural, push.";
								iGold = iStake;					
							} else {  // dealer not natural, loses
								sMsg = "Blackjack: Second hand natural blackjack, you win.";
								iGold = FloatToInt ( IntToFloat(iStake) * ( fNaturalPayoff + 1.0 ) );
								SetLocalInt ( oDealer, sVarNameWon, GetLocalInt ( oDealer, sVarNameWon ) + FloatToInt ( IntToFloat(iStake) * fNaturalPayoff ) );
							}				
						} else {  // dealer loses
							sMsg = "Blackjack: Second hand natural blackjack, you win.";
							iGold = FloatToInt ( IntToFloat(iStake) * ( fNaturalPayoff + 1.0 ) );
							SetLocalInt ( oDealer, sVarNameWon, GetLocalInt ( oDealer, sVarNameWon ) + FloatToInt ( IntToFloat(iStake) * fNaturalPayoff ) );					
						}
					} else {  // not natural
						if ( iDealerPointer == 21 ) {  // push
							sMsg = "Blackjack: Second hand 21 ties the dealer's 21, push.";
							iGold = iStake;					
						} else {  // dealer loses
							sMsg = "Blackjack: Second hand 21 beats the dealer's " + IntToString(iDealerHandValue) + ", you win.";
							iGold = iStake * 2;
							SetLocalInt ( oDealer, sVarNameWon, GetLocalInt ( oDealer, sVarNameWon ) + iStake );							
						}
					}
				} else if ( iPlayerHand2Value > iDealerHandValue ) {  // player hand value is higher, player wins
					// generate the appropriate message
					if ( iDealerHandValue > 21 ) {
						sMsg = "Blackjack: Second hand beats dealer bust, you win.";				
					} else {
						sMsg = "Blackjack: Second hand " + IntToString(iPlayerHand2Value) + " beats the dealer's " + IntToString(iDealerHandValue) + ", you win.";
					}
					iGold = iStake * 2;
					SetLocalInt ( oDealer, sVarNameWon, GetLocalInt ( oDealer, sVarNameWon ) + iStake );
				} else if ( iPlayerHand2Value == iDealerHandValue ) {  // player hand value is equal
					// generate the message
					sMsg = "Blackjack: Second hand tied with dealer, push.";
					iGold = iStake;						
				} else {  // player hand value is lower
					if ( iDealerHandValue > 21 ) {  // dealer busts, player wins
						sMsg = "Blackjack: Second hand beats dealer bust, you win.";	
						iGold = iStake * 2;	
						SetLocalInt ( oDealer, sVarNameWon, GetLocalInt ( oDealer, sVarNameWon ) + iStake );								
					} else {  // player loses
						sMsg = "Blackjack: Second hand " + IntToString(iPlayerHand2Value) + " loses to the dealer's " + IntToString(iDealerHandValue) + ", you lose.";				
						SetLocalInt ( oDealer, sVarNameLost, GetLocalInt ( oDealer, sVarNameLost ) + iStake );
					}
				}
				
				// message and pay player
				SendMessageToPC ( oPC, sMsg );
				if ( iGold != 0 ) {
					iPlayerGold = iPlayerGold + iGold;				
					GiveGoldToCreature ( oPC, iGold, TRUE );
					
				}
			}
		}
		
		// update player gold display
		SetGUIObjectText ( oPC, "br_blackjack", "player_gold", -1, IntToString(iPlayerGold) );
		// clean up player variables
		SetLocalInt ( oDealer, "iPlayer" + s + "Doubled", 0 );
		SetLocalInt ( oDealer, "iPlayer" + s + "Split", 0 );
	}
	
	// add any waitlisted players to game
	iWaitList = GetLocalInt ( oDealer, "iWaitList" );
	if ( iWaitList != 0 ) {
		for ( i = 1 ; i <= iWaitList ; i++ ) {
			s = IntToString(i);
			oPC = GetLocalObject ( oDealer, "oWaitList" + s );
			SetUpNewPlayer ( oDealer, oPC );
		}
		UpdateGUIPlayerNames(oDealer);
		SetLocalInt ( oDealer, "iWaitList", 0 );		
	}
	
	// unlock game and enable buttons for next round
	SetLocalInt ( oDealer, "iNumReadyPlayers", 0 );	
	SetLocalInt ( oDealer, "iInPlay", 0 );	
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
			oPC = GetLocalObject ( oDealer, "oPlayer" + s );
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_ready", FALSE );
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_quit", FALSE );
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_betplus", FALSE );
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_betminus", FALSE );						
			SetLocalInt ( oDealer, "i" + s + "isReady", 0 );						
		}
	}
	
	// set idle timer
	if ( ( iIdleTimer != 0 ) && ( GetLocalInt ( oDealer, "iNumPlayers" ) > 1 ) ) {
		if ( GetLocalInt ( oDealer, "iEndRoundIdleTimerActive" ) == 0 ) {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );	
			MPGUIDisplayComponent ( oDealer, "br_blackjack", "timerpane", 1 );		
			EndRoundIdleTimer(oDealer);
		} else {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );			
		}
	}
}


// anti-grief/logout measures

void InRoundIdleTimer ( object oDealer, int iCurrentPlayer ) {
	int iHalfIdleTimer, iPlayerPointer, iSplit, iTimer;
	object oPC;
	string sComponentString, sPlayerPos;
	
	sPlayerPos = IntToString(iCurrentPlayer);
	oPC = GetLocalObject ( oDealer, "oPlayer" + sPlayerPos );
			
	// if the player has finished the round then terminate 
	if ( GetLocalInt ( oDealer, "iActivePlayer" ) != iCurrentPlayer ) {
		SetGUIObjectHidden ( oPC, "br_blackjack", "timerpane", TRUE );
		return;
	}
	
	// check timer to see if it's counted down to 0
	iTimer = GetLocalInt ( oDealer, "iIdleTimer" );
			
	if ( iTimer == 0 ) {
		// hide timer pane
		SetGUIObjectHidden ( oPC, "br_blackjack", "timerpane", TRUE );
				
		// disable player buttons
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_hit", TRUE );
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_stand", TRUE );				
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_double", TRUE );
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_split", TRUE );		
					
		// update player graphics for idle player hand(s), calculate final hand values
		iSplit = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Split" );
		if ( iSplit == 0 ) {  // terminate hand 1
			MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "", "player" + sPlayerPos + "card1_msg=STAND", "player" + sPlayerPos + "card1_bg=0" );
		
			iPlayerPointer = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Pointer1" );
			SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "FinalHand1", GetValueOfStack ( oDealer, "sPlayer" + sPlayerPos + "Stack1", iPlayerPointer ) );				
		} else if ( iSplit== 1 ) {  // terminate hand 1 and 2
			MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "", "player" + sPlayerPos + "card1_msg=STAND;player" + sPlayerPos + "card2_msg=STAND", "player" + sPlayerPos + "card1_bg=0;player" + sPlayerPos +"card2_bg=0" );
		
			iPlayerPointer = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Pointer1" );
			SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "FinalHand1", GetValueOfStack ( oDealer, "sPlayer" + sPlayerPos + "Stack1", iPlayerPointer ) );			
			iPlayerPointer = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Pointer2" );
			SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "FinalHand2", GetValueOfStack ( oDealer, "sPlayer" + sPlayerPos + "Stack2", iPlayerPointer ) );	
		} else {  // terminate hand 2
			MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "", "player" + sPlayerPos + "card2_msg=STAND", "player" + sPlayerPos + "card2_bg=0" );
		
			iPlayerPointer = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Pointer2" );
			SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "FinalHand2", GetValueOfStack ( oDealer, "sPlayer" + sPlayerPos + "Stack2", iPlayerPointer ) );				
		}
					
		// pass turn to next player
		ManageHandPosition ( oDealer, iCurrentPlayer + 1 );					
		SendMessageToPC ( oPC, "Blackjack: You have been passed by the dealer for inactivity." );							
	} else {
		SetGUIObjectText ( oPC, "br_blackjack", "timerfield", -1, IntToString(iTimer) );
		
		// not counted down yet, iterate
		SetLocalInt ( oDealer, "iIdleTimer", iTimer - 1 );
		DelayCommand ( 1.0, InRoundIdleTimer ( oDealer, iCurrentPlayer ) );
	}	
}


void EndRoundIdleTimer ( object oDealer ) {
	int i, iHalfIdleTimer, iNumPlayers, iTimer, j, k;
	object oPlayer;
	string s, sInt, sK;
	
	// terminate if a round has started
	if ( GetLocalInt ( oDealer, "iInPlay" ) == 1 ) {
		SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 0 );	
		MPGUIDisplayComponent ( oDealer, "br_blackjack", "timerpane" );			
		return;
	}
	
	iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
	if ( iNumPlayers == 1 ) {
		SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 0 );	
		MPGUIDisplayComponent ( oDealer, "br_blackjack", "timerpane" );			
		return;		
	}
	
	SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 1 );
	
	// check timer to see if it's counted down to 0
	iTimer = GetLocalInt ( oDealer, "iIdleTimer" );	
			
	if ( iTimer == 0 ) {
		// boot all outstanding players	
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) && ( GetLocalInt ( oDealer, "i" + s + "isReady" ) == 0 ) ) {
				// player is human and not readied up yet
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				
				// hide timer pane
				SetGUIObjectHidden ( oPlayer, "br_blackjack", "timerpane", TRUE );	
							
				// clear card stacks
				for ( j = 1 ; j <= 22 ; j++ ) {
					sInt = IntToString(j);	
					SetGUIObjectHidden ( oPlayer, "br_blackjack", "dealercard_" + sInt, TRUE );
					for ( k = 1 ; k <= iNumPlayersAllowed ; k++ ) {
						sK = IntToString(k);
						SetGUIObjectHidden ( oPlayer, "br_blackjack", "player" + sK + "card1_" + sInt, TRUE );
						SetGUIObjectHidden ( oPlayer, "br_blackjack", "player" + sK + "card2_" + sInt, TRUE );	
					}											
				}
				
				// clear message boxes
				SetGUIObjectHidden ( oPlayer, "br_blackjack", "dealer_msg", TRUE );	
				for ( k = 1 ; k <= iNumPlayersAllowed ; k++ ) {
					sK = IntToString(k);
					SetGUIObjectHidden ( oPlayer, "br_blackjack", "player" + sK + "card1_msg", TRUE );
					SetGUIObjectHidden ( oPlayer, "br_blackjack", "player" + sK + "card2_msg", TRUE );	
				}				
				
				// disable buttons and reinstate wait message
				SetGUIObjectDisabled ( oPlayer, "br_blackjack", "button_ready", TRUE );
				SetGUIObjectDisabled ( oPlayer, "br_blackjack", "button_quit", TRUE );	
				SetGUIObjectHidden ( oPlayer, "br_blackjack", "notice_pane", FALSE );				
				
				// close gui	
				CloseGUIScreen ( oPlayer, "br_blackjack" );		
					
				// clear player data from dealer
				SetLocalInt ( oDealer, "i" + s + "isPlayer", 0 );
				SetCasinoStatsArrayPlayerStat ( oPlayer, "Blackjack", "Win", GetLocalInt ( oDealer, "iPlayer" + IntToString(i) + "GoldWon" ) );
				SetCasinoStatsArrayPlayerStat ( oPlayer, "Blackjack", "Lose", GetLocalInt ( oDealer, "iPlayer" + IntToString(i) + "GoldLost" ) );
				SetCasinoStatsArrayPlayerStat ( oPlayer, "Blackjack", "Time", GetPlayerTimePlayed ( oDealer, i ) );
				iNumPlayers = iNumPlayers - 1;
				MPGUIUpdateText ( oDealer, "br_blackjack", "player" + s + "card1_name", sDefaultName );		
				
				SendMessageToPC ( oPlayer, "Blackjack: You have beeen removed from the table for inactivity." );
			}
		}	
		SetLocalInt ( oDealer, "iNumPlayers", iNumPlayers );
		MPMessageAllPlayers ( oDealer, "Blackjack: The table has been cleared of idle players." );		
		MPGUIDisplayComponent ( oDealer, "br_blackjack", "timerpane" );		
		SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 0 );		
		
		// start game
		SetLocalInt ( oDealer, "iInPlay", 1 );
		DealInitialHands ( oDealer, -1 );							
	} else {
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				// player is human and not readied up yet
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				SetGUIObjectText ( oPlayer, "br_blackjack", "timerfield", -1, IntToString(iTimer) );
			}
		}
		
		// not counted down yet, iterate
		SetLocalInt ( oDealer, "iIdleTimer", iTimer - 1 );
		DelayCommand ( 1.0, EndRoundIdleTimer(oDealer) );		
	}
}