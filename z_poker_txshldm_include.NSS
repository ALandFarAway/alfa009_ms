// Black Rain Software 2009

#include "y_poker_include"


// betting settings, can be overridden in-game
const int iAnte = 100;  // amount of ante each player must contribute to start a hand
const int iInitialBet = 100;  // the the raise value of the first two rounds in a fixed limit game
const int iMaxRaises = 3;  // number of raises allowed per round in a fixed limit game

// system settings
const float fDealDelay = 0.5;  // delay between card deals
const float fPlayDelay = 1.0;  // delay between AI decisions
const int iIdleTimer = 30;  // how many seconds to allow a player to idle before taking measures
const string sDefaultName = "Casino Patron";  // default AI player name
const string sDefaultGameName = "Texas Hold'em";  // the name of the game


// function prototypes

void SetUpNewPlayer ( object oDealer, object oPC );
void UpdateGUIPlayerNames ( object oDealer );
void DealInitialPlayerHands ( object oDealer, int iPhase );
void ManageBettingRound ( object oDealer, int iCurrentPlayer, int iBlindStatus = 0 );
int ResolveAIPlayerBet ( object oDealer, string sPosition );
void EndPhaseEvaluate ( object oDealer );
void DealCommunityCards ( object oDealer, int iPhase, int iCardPhase = 0  );
void EndRoundProcessResults ( object oDealer, int iLastPlayer = 0 );
void EndRoundCleanUp ( object oDealer );
void BetRoundIdleTimer ( object oDealer, int iCurrentPlayer );
void EndRoundIdleTimer ( object oDealer );


// set up a new player's gui and vars

void SetUpNewPlayer ( object oDealer, object oPC ) {
	int i, iNumPlayers;
	string s, sVarName;
	
	// increment number of players
	iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
	iNumPlayers = iNumPlayers + 1;
	SetLocalInt ( oDealer, "iNumPlayers", iNumPlayers );
	
	// message all current players if more than one player at table
	if ( iNumPlayers > 1 ) {
		MPMessageAllPlayers ( oDealer, sDefaultGameName + ": " + GetName(oPC) + " has joined this table." );
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
			SetGUIObjectText ( oPC, "br_poker_txshldm", "playerpos", -1, s );
			SetGUIObjectText ( oPC, "br_poker_txshldm", "dealertag", -1, GetTag(oDealer) );				
						
			// set up GUI visible elements
			SetGUIObjectText ( oPC, "br_poker_txshldm", "player_gold", -1, IntToString(GetGold(oPC)) );		
			
			// set stat vars
			SetLocalInt ( oDealer, "iPlayer" + s + "GoldWon", 0 );
			SetLocalInt ( oDealer, "iPlayer" + s + "GoldLost", 0 );			
			SetPlayerStartTime ( oDealer, i );
			
			// enable buttons
			SetGUIObjectHidden ( oPC, "br_poker_txshldm", "notice_pane", TRUE );
			SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_ready", FALSE );								
			SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_quit", FALSE );			
					
			break;
		}
	}
	
	// start idle timer if more than one player in
	if ( iIdleTimer != 0 ) {
		if ( ( iNumPlayers > 1 ) && ( GetLocalInt ( oDealer, "iEndRoundIdleTimerActive" ) == 0 ) ) {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );	
			MPGUIDisplayComponent ( oDealer, "br_poker_txshldm", "timerpane", 1 );		
			EndRoundIdleTimer(oDealer);		
		} else if ( ( iNumPlayers > 1 ) && ( GetLocalInt ( oDealer, "iEndRoundIdleTimerActive" ) != 0 ) ) {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );	
			SetGUIObjectHidden ( oPC, "br_poker_txshldm", "timerpane", FALSE );		
		}
	}
}


// update all player guis with player names

void UpdateGUIPlayerNames ( object oDealer ) {
	int i;
	object oPlayer;
	string s, sTextField;
	
	if ( iUsePCName == 0 ) {  // only use player character names
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				MPGUIUpdateText ( oDealer, "br_poker_txshldm", "player" + s + "name2", GetName(oPlayer) );
			} else {
				MPGUIUpdateText ( oDealer, "br_poker_txshldm", "player" + s + "name2", sDefaultName );
			}
		}
	} else {  // add PC name to character name
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				sTextField = "player" + s + "name1" + "=" + GetName(oPlayer) + ";player" + s + "name2" + "=- " + GetPCPlayerName(oPlayer);
				MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", sTextField, "" );				
			} else {
				MPGUIUpdateText ( oDealer, "br_poker_txshldm", "player" + s + "name2", sDefaultName );
			}
		}		
	}	
}


// set up the starting hands for all players

void DealInitialPlayerHands ( object oDealer, int iPhase ) {
	int i, iCurrentCard, iCurrentPlayer, iInitialBetLocal, iStartingPlayer;
	object oPC;
	string s, sCard, sComponentString, sCurrentCard, sCurrentPlayer, sVarName;
	
	if ( iPhase == 0 ) {  // gui cleanup
		// either shuffle for first games, or clean up from previous rounds
		if ( GetLocalInt ( oDealer, "iShuffled" ) == 0 ) {
			SetLocalInt ( oDealer, "iShuffled", 1 );
			ShuffleDeck(oDealer);
			
			// initialize next deal phase
			DealInitialPlayerHands ( oDealer, 0 );			
		} else {
			AssignCommand ( oDealer, PlaySound("it_paper") );	
		
			// update pot
			iInitialBetLocal = GetLocalInt ( oDealer, "iInitialBet" );
			if ( iInitialBetLocal == 0 ) {  // check for iInitialBet dealer override
			}
			iInitialBetLocal = iInitialBet;
			iInitialBetLocal = iInitialBetLocal * iNumPlayersAllowed;
			SetLocalInt ( oDealer, "iPotValue", iInitialBetLocal );
					
			for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
				s = IntToString(i);
				SetLocalInt ( oDealer, "iPlayer" + s + "BetValueTotal", iAnte );
			}
			
			// hide message banner
			sComponentString = "msgbanner1=0;msgbanner2=0";			
				
			// hide card displays
			for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
				s = IntToString(i);
				sComponentString = sComponentString + ";player" + s + "card1=0;player" + s + "card2=0;player" + s + "card1bg=0;player" + s + "card2bg=0";
			}
			for ( i = 1 ; i <= 5 ; i++ ) {
				s = IntToString(i);
				sComponentString = sComponentString + ";communitycard" + s + "=0;communitycard" + s + "bg=0";																
			}
			
			// hide player actions
			for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
				s = IntToString(i);
				sComponentString = sComponentString + ";player" + s + "action=0;player" + s + "fold=0"; 
			}
			
			// update gui elements
			MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", "pot=Pot: " + IntToString(iInitialBetLocal), sComponentString );
			
			// initialize next deal phase
			DelayCommand ( fDealDelay, DealInitialPlayerHands ( oDealer, 1 ) );		
		}
	} else {  // deal cards to each player in turn
		AssignCommand ( oDealer, PlaySound("it_paper") );	
	
		// determine current player and card position
		if ( iPhase <= iNumPlayersAllowed ) {
			iCurrentPlayer = iPhase;
			sCurrentPlayer = IntToString(iCurrentPlayer);
			iCurrentCard = 1;
			sCurrentCard = "1";
		} else {
			iCurrentPlayer = iPhase - iNumPlayersAllowed;
			sCurrentPlayer = IntToString(iCurrentPlayer);			
			iCurrentCard = 2;
			sCurrentCard = "2";		
		}		
	
		// move card from stack to player hand
		sCard = GetLocalArrayString ( oDealer, "sCardStack", iPhase );
		SetLocalArrayString ( oDealer, "sPlayer" + sCurrentPlayer + "Stack", iCurrentCard, sCard );
		
		// update player graphics
		sVarName = "player" + sCurrentPlayer + "card" + sCurrentCard;
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				oPC = GetLocalObject ( oDealer, "oPlayer" + s );
				if ( i == iCurrentPlayer ) {  // player can see own card
					SetGUITexture ( oPC, "br_poker_txshldm", sVarName, sCard + ".tga" );
					SetGUIObjectHidden ( oPC, "br_poker_txshldm", sVarName + "opaque", FALSE );					
					SetGUIObjectHidden ( oPC, "br_poker_txshldm", sVarName, FALSE );
				} else {  // players see card back graphic of other players' cards
					SetGUITexture ( oPC, "br_poker_txshldm", sVarName, "br_card_back.tga" );				
					SetGUIObjectHidden ( oPC, "br_poker_txshldm", sVarName, FALSE );				
				}
			}
		}		
	
		if ( iPhase == ( iNumPlayersAllowed * 2 ) ) {
			// initialize first round of betting
			iStartingPlayer = GetLocalInt ( oDealer, "iDealerPos" );
			if ( iStartingPlayer < iNumPlayersAllowed ) {
				iStartingPlayer = iStartingPlayer + 1;
			} else {
				iStartingPlayer = 1;
			}
					
			MPGUIUpdateText ( oDealer, "br_poker_txshldm", "msgbanner1", "Betting Round 1" );
			ManageBettingRound ( oDealer, iStartingPlayer, 1 );	
		} else {
			// initialize next deal phase
			DelayCommand ( fDealDelay, DealInitialPlayerHands ( oDealer, iPhase + 1 ) );			
		}
	}
}


// manage betting rounds

void ManageBettingRound ( object oDealer, int iCurrentPlayer, int iBlindStatus = 0 )  {
	int i, iAIDecision, iBet, iBetValueTotal, iCurrentBetValue, iGold, iInitialBetLocal, iMaxRaisesLocal, iNextPlayer, iNumPlayersFolded, iNumRaises, iPlayerBetValue, iPotValue, iPrevPlayer, iRoundPhase;
	object oPC;
	string s, sComponentString, sCurrentPlayer, sNextPlayer, sVarName;

	// update active player bg
	sCurrentPlayer = IntToString(iCurrentPlayer);
	MPGUIDisplayComponent ( oDealer, "br_poker_txshldm", "player" + sCurrentPlayer + "bg", 1 );
	SetLocalInt ( oDealer, "iActivePlayer", iCurrentPlayer );	
	
	// evaluate position
	if ( iBlindStatus == 1 ) {  // small blind
		AssignCommand ( oDealer, PlaySound("it_coins") );	
	
		iInitialBetLocal = GetLocalInt ( oDealer, "iInitialBet" );
		if ( iInitialBetLocal == 0 ) {  // look for iInitialBet dealer override
			iInitialBetLocal = iInitialBet;
		}
		
		// add the small blind to the pot		
		iPlayerBetValue = iInitialBetLocal / 2;
		iPotValue = GetLocalInt ( oDealer, "iPotValue" );
		iPotValue = iPotValue + iPlayerBetValue;
		SetLocalInt ( oDealer, "iPotValue", iPotValue );
		sComponentString = "pot=Pot: " + IntToString(iPotValue) + ";player" + sCurrentPlayer + "action=Small Blind - " + IntToString(iPlayerBetValue) + "g added";
		MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", sComponentString, "" );
		
		// update the player position's bet value
		sVarName = "iPlayer" + sCurrentPlayer + "BetValue";	
		SetLocalInt ( oDealer, sVarName, iPlayerBetValue );
		sVarName = "iPlayer" + sCurrentPlayer + "BetValueTotal";	
		SetLocalInt ( oDealer, sVarName, GetLocalInt ( oDealer, sVarName) + iPlayerBetValue );
						
		// subtract the bet value from human player gold
		if ( GetLocalInt ( oDealer, "i" + sCurrentPlayer + "isPlayer" ) == 1 ) {
			oPC = GetLocalObject ( oDealer, "oPlayer" + sCurrentPlayer );
			iGold = GetGold(oPC);
			iGold = iGold - iPlayerBetValue;
			SetGUIObjectText ( oPC, "br_poker_txshldm", "player_gold", -1, IntToString(iGold) );
			AssignCommand ( oDealer, TakeGoldFromCreature ( iPlayerBetValue, oPC, TRUE, FALSE ) );
			
		}
		
		// set up evaluation of next bet
		if ( iCurrentPlayer < iNumPlayersAllowed ) {
			iCurrentPlayer = iCurrentPlayer + 1;
		} else {
			iCurrentPlayer = 1;
		}
		DelayCommand ( fPlayDelay, MPGUIDisplayComponent ( oDealer, "br_poker_txshldm", "player" + sCurrentPlayer + "bg") );		
		DelayCommand ( fPlayDelay, ManageBettingRound ( oDealer, iCurrentPlayer, 2 ) );
	} else if ( iBlindStatus == 2 ) {  // big blind
		AssignCommand ( oDealer, PlaySound("it_coins") );	
	
		iInitialBetLocal = GetLocalInt ( oDealer, "iInitialBet" );
		if ( iInitialBetLocal == 0 ) {  // look for iInitialBet dealer override
			iInitialBetLocal = iInitialBet;
		}
		
		// add the small blind to the pot		
		iPlayerBetValue = iInitialBetLocal;
		iPotValue = GetLocalInt ( oDealer, "iPotValue" );
		iPotValue = iPotValue + iPlayerBetValue;
		SetLocalInt ( oDealer, "iPotValue", iPotValue );		
		sComponentString = "pot=Pot: " + IntToString(iPotValue) + ";player" + sCurrentPlayer + "action=Big Blind - " + IntToString(iPlayerBetValue) + "g added";
		MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", sComponentString, "" );
		
		// update the player position's bet value
		sVarName = "iPlayer" + sCurrentPlayer + "BetValue";	
		SetLocalInt ( oDealer, sVarName, iPlayerBetValue );
		sVarName = "iPlayer" + sCurrentPlayer + "BetValueTotal";	
		SetLocalInt ( oDealer, sVarName, GetLocalInt ( oDealer, sVarName) + iPlayerBetValue );
						
		// subtract the bet value from human player gold
		if ( GetLocalInt ( oDealer, "i" + sCurrentPlayer + "isPlayer" ) == 1 ) {
			oPC = GetLocalObject ( oDealer, "oPlayer" + sCurrentPlayer );
			iGold = GetGold(oPC);
			iGold = iGold - iPlayerBetValue;
			SetGUIObjectText ( oPC, "br_poker_txshldm", "player_gold", -1, IntToString(iGold) );
			AssignCommand ( oDealer, TakeGoldFromCreature ( iPlayerBetValue, oPC, TRUE, FALSE ) );
			
		}
		
		// set the big blind as the last raising player and update current bet
		SetLocalInt ( oDealer, "iLastRaisingPlayer", iCurrentPlayer );
		SetLocalInt ( oDealer, "iCurrentBetValue", iPlayerBetValue );
		
		// set up evaluation of next bet
		if ( iCurrentPlayer < iNumPlayersAllowed ) {
			iCurrentPlayer = iCurrentPlayer + 1;
		} else {
			iCurrentPlayer = 1;
		}
		DelayCommand ( fPlayDelay, MPGUIDisplayComponent ( oDealer, "br_poker_txshldm", "player" + sCurrentPlayer + "bg") );		
		DelayCommand ( fPlayDelay, ManageBettingRound ( oDealer, iCurrentPlayer ) );		
	} else {
		// determine whether this position is human or AI
		if ( GetLocalInt ( oDealer, "i" + sCurrentPlayer + "isPlayer" ) == 1 ) {
			// human
			oPC = GetLocalObject ( oDealer , "oPlayer" + sCurrentPlayer );
			
			// determine the raise value for the round
			iInitialBetLocal = GetLocalInt ( oDealer, "iInitialBet" );
			if ( iInitialBetLocal == 0 ) {  // look for iInitialBet dealer override
				iInitialBetLocal = iInitialBet;
			}
			if ( GetLocalInt ( oDealer, "iRoundPhase" ) > 1 ) {
				iInitialBetLocal = iInitialBetLocal * 2;  // double bet for turn and river rounds
			}
			
			// update call and raise values and gui
			iCurrentBetValue = GetLocalInt ( oDealer, "iCurrentBetValue" );			
			sVarName = "iPlayer" + sCurrentPlayer + "BetValue";	
			iPlayerBetValue = GetLocalInt ( oDealer, sVarName );
			iBet = iCurrentBetValue - iPlayerBetValue;
			SetGUIObjectText ( oPC, "br_poker_txshldm", "bet_call", -1, IntToString(iBet) );	
			iGold = GetGold(oPC);
			if ( iGold < iBet ) {
				iBet = iBet + iInitialBetLocal;
				SetGUIObjectText ( oPC, "br_poker_txshldm", "bet_raise", -1, IntToString(iBet) );					
				SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_allin", FALSE );			
			} else {
				SetLocalInt ( oDealer, "iCurrentPlayerCallValue", iBet );				
				if ( iBet == 0 ) {
					SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_call", FALSE );				
					SetGUIObjectText ( oPC, "br_poker_txshldm", "button_call", -1, "Check" );					
				} else {				
					SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_call", FALSE );				
					SetGUIObjectText ( oPC, "br_poker_txshldm", "button_call", -1, "Call" );				
					SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_fold", FALSE );				
				}
				iBet = iBet + iInitialBetLocal;
				SetGUIObjectText ( oPC, "br_poker_txshldm", "bet_raise", -1, IntToString(iBet) );				
				iMaxRaisesLocal = GetLocalInt ( oDealer, "iMaxRaises" );
				if ( iMaxRaisesLocal == 0 ) {  // check for dealer iMaxRaises override
					iMaxRaisesLocal = iMaxRaises;
				}								
				if ( ( iGold >= iBet ) && ( GetLocalInt ( oDealer, "iNumRaises" ) < iMaxRaisesLocal ) ) {
					SetLocalInt ( oDealer, "iCurrentPlayerRaiseValue", iBet );
					SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_raise", FALSE );										
				}		
			}
			
			// set up griefing timer
			if ( iIdleTimer != 0 ) {
				SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );
				SetGUIObjectHidden ( oPC, "br_poker_txshldm", "timerpane", FALSE );	
				BetRoundIdleTimer ( oDealer, iCurrentPlayer );					
			}
		} else {
			// AI
			iAIDecision = ResolveAIPlayerBet ( oDealer, sCurrentPlayer );
			if ( iAIDecision == 0 ) {  // fold 
				iNumPlayersFolded = GetLocalInt ( oDealer, "iNumPlayersFolded" );
				iNumPlayersFolded = iNumPlayersFolded + 1;
				SetLocalInt ( oDealer, "iNumPlayersFolded", iNumPlayersFolded );
				SetLocalInt ( oDealer, "iPlayer" + sCurrentPlayer + "Folded", 1 );
				sComponentString = "player" + sCurrentPlayer + "card1=0;player" + sCurrentPlayer + "card2=0;player" + sCurrentPlayer + "fold=1";
				MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", "player" + sCurrentPlayer + "action=Fold", sComponentString );	
			} else if ( iAIDecision == 1 ) {  // call
				iCurrentBetValue = GetLocalInt ( oDealer, "iCurrentBetValue" );
				if ( iCurrentBetValue == 0 ) {
					// AI checks
					MPGUIUpdateText ( oDealer, "br_poker_txshldm", "player" + sCurrentPlayer + "action", "Check" );
				} else {
					AssignCommand ( oDealer, PlaySound("it_coins") );				
				
					// update the pot and AI bet values
					sVarName = "iPlayer" + sCurrentPlayer + "BetValue";
					iPlayerBetValue = GetLocalInt ( oDealer, sVarName );
					iBet = iCurrentBetValue - iPlayerBetValue;
					iPotValue = GetLocalInt ( oDealer, "iPotValue" );
					iPotValue = iPotValue + iBet;
					SetLocalInt ( oDealer, "iPotValue", iPotValue );
					SetLocalInt ( oDealer, sVarName, iCurrentBetValue );
					iBetValueTotal = GetLocalInt ( oDealer, "iPlayer" + sCurrentPlayer + "BetValueTotal" );
					iBetValueTotal = iBetValueTotal + iBet;
					SetLocalInt ( oDealer, "iPlayer" + sCurrentPlayer + "BetValueTotal", iBetValueTotal );
					
					// update gui elements
					sComponentString = "pot=Pot: " + IntToString(iPotValue) + ";player" + sCurrentPlayer + "action=Call - " + IntToString(iBet) + "g added";
					MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", sComponentString, "" );					
				}
			} else {  // raise
				AssignCommand ( oDealer, PlaySound("it_coins") );			
			
				// update the pot with AI contribution
				iCurrentBetValue = GetLocalInt ( oDealer, "iCurrentBetValue" );				
				sVarName = "iPlayer" + sCurrentPlayer + "BetValue";				
				iPlayerBetValue = GetLocalInt ( oDealer, sVarName );
				iBet = ( iCurrentBetValue - iPlayerBetValue ) + iAIDecision;
				iPotValue = GetLocalInt ( oDealer, "iPotValue" );
				iPotValue = iPotValue + iBet;
				SetLocalInt ( oDealer, "iPotValue", iPotValue );
				iBetValueTotal = GetLocalInt ( oDealer, "iPlayer" + sCurrentPlayer + "BetValueTotal" );
				iBetValueTotal = iBetValueTotal + iBet;
				SetLocalInt ( oDealer, "iPlayer" + sCurrentPlayer + "BetValueTotal", iBetValueTotal );				
				
				// update vars
				iCurrentBetValue = iCurrentBetValue + iAIDecision;
				SetLocalInt ( oDealer, "iCurrentBetValue", iCurrentBetValue );
				SetLocalInt ( oDealer, sVarName, iCurrentBetValue );
				SetLocalInt ( oDealer, "iLastRaisingPlayer", iCurrentPlayer );
				iNumRaises = GetLocalInt ( oDealer, "iNumRaises" );
				iNumRaises = iNumRaises + 1;
				SetLocalInt ( oDealer, "iNumRaises", iNumRaises );				
				
				// update gui elements
				sComponentString = "pot=Pot: " + IntToString(iPotValue) + ";player" + sCurrentPlayer + "action=Raise - " + IntToString(iBet) + "g added";
				MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", sComponentString, "" );								
			}
			
			if ( iNumPlayersFolded == ( iNumPlayersAllowed - 1 ) ) {
				// all but one players folded, end the round
				i = 1;
				s = IntToString(i);
				while ( GetLocalInt ( oDealer, "iPlayer" + s + "Folded" ) == 1 ) {
					i = i + 1;
					s = IntToString(i);		
				}	
				MPGUIDisplayComponent ( oDealer, "br_poker_txshldm", "player" + sCurrentPlayer + "bg" );
				EndRoundProcessResults ( oDealer, i );
			} else {
				// set up the next valid player for betting
				iNextPlayer = iCurrentPlayer;
				if ( iNextPlayer < iNumPlayersAllowed ) {
					iNextPlayer = iNextPlayer + 1;
				} else {
					iNextPlayer = 1;
				}
				sNextPlayer = IntToString(iNextPlayer);
				while ( ( GetLocalInt ( oDealer, "iPlayer" + sNextPlayer + "Folded" ) == 1 ) || ( GetLocalInt ( oDealer, "iPlayer" + sNextPlayer + "AllIn" ) == 1 ) ) {
					if ( iNextPlayer < iNumPlayersAllowed ) {
						iNextPlayer = iNextPlayer + 1;
					} else {
						iNextPlayer = 1;
					}
					sNextPlayer = IntToString(iNextPlayer);
				}	
				
				// check to see if the next valid player was the last raising player
				if ( GetLocalInt ( oDealer, "iLastRaisingPlayer" ) == iNextPlayer ) {
					// update vars and evaluate next action
					iRoundPhase = GetLocalInt ( oDealer, "iRoundPhase" );
					iCurrentBetValue = GetLocalInt ( oDealer, "iCurrentBetValue" );
					DelayCommand ( fPlayDelay, MPGUIDisplayComponent ( oDealer, "br_poker_txshldm", "player" + sCurrentPlayer + "bg" ) );
					DelayCommand ( fPlayDelay, EndPhaseEvaluate(oDealer) );
				} else {
					// set up next betting player
					DelayCommand ( fPlayDelay, MPGUIDisplayComponent ( oDealer, "br_poker_txshldm", "player" + sCurrentPlayer + "bg" ) );
					DelayCommand ( fPlayDelay, ManageBettingRound ( oDealer, iNextPlayer ) );			
				}
			}			
		}	
	}
}


// determine an AI player's betting action
// 0 for fold, 1 for call, any other value indicates amount to raise by

int ResolveAIPlayerBet ( object oDealer, string sPosition ) {
	int iInitialBetLocal, iMaxRaisesLocal, iRandom;
	
	iRandom = Random(10);
	if ( iRandom == 0 ) {  // fold
		if ( GetLocalInt ( oDealer, "iCurrentBetValue" ) == 0 ) {
			return 1;  // check instead of fold if there are no bets yet
		} else {
			return 0;
		}
	} else if ( iRandom < 6 ) { // call
		return 1;
	} else {  // raise
		iMaxRaisesLocal = GetLocalInt ( oDealer, "iMaxRaises" );
		if ( iMaxRaisesLocal == 0 ) {  // check for dealer iMaxRaises override
			iMaxRaisesLocal = iMaxRaises;
		}
		if ( GetLocalInt ( oDealer, "iNumRaises" ) < iMaxRaisesLocal ) {
			// determine the raise value for the round
			iInitialBetLocal = GetLocalInt ( oDealer, "iInitialBet" );
			if ( iInitialBetLocal == 0 ) {  // look for iInitialBet dealer override
				iInitialBetLocal = iInitialBet;
			}
			if ( GetLocalInt ( oDealer, "iRoundPhase" ) > 1 ) {
				iInitialBetLocal = iInitialBetLocal * 2;  // double bet for turn and river rounds
			}
			return iInitialBetLocal;
		} else {
			return 1;  // call instead of raiseif max raises reached
		}
	}
}


// evaluate the next action at the end of a betting round

void EndPhaseEvaluate ( object oDealer ) {
	int i, iRoundPhase;
	string s;
	
	MPGUIDisplayComponent ( oDealer, "br_poker_txshldm", "msgbanner1", 0 );
	
	// determine game phase
	iRoundPhase = GetLocalInt ( oDealer, "iRoundPhase" );
	iRoundPhase = iRoundPhase + 1;
	SetLocalInt ( oDealer, "iRoundPhase", iRoundPhase );
	if ( iRoundPhase == 4 ) {
		// all betting done
		EndRoundProcessResults ( oDealer );
	} else {
		DealCommunityCards ( oDealer, iRoundPhase );
	}
}


// deal the community cards

void DealCommunityCards ( object oDealer, int iPhase, int iCardPhase = 0 ) {
	int i, iStartingPlayer;
	string s, sCard, sComponentString, sStartingPlayer;
	
	// hide all player position action messages
	sComponentString = "player1action=0";
	for ( i = 2 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		sComponentString = sComponentString + ";player" + s + "action=0";
	}
	MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", "", sComponentString );
	
	AssignCommand ( oDealer, PlaySound("it_paper") );	
			
	if ( iPhase == 1 ) {
		// skip one burn card and get the next card off the stack
		sCard = GetLocalArrayString ( oDealer, "sCardStack", iPhase + iCardPhase + ( iNumPlayersAllowed * 2 ) + 1 );
		
		// write the card to array
		SetLocalArrayString ( oDealer, "sCommunityStack", iPhase + iCardPhase, sCard );
	
		// update player graphics
		MPGUIUpdateTexture ( oDealer, "br_poker_txshldm", "communitycard" + IntToString(iCardPhase + 1), sCard );
		
		if ( iCardPhase != 2 ) {
			DelayCommand ( fDealDelay, DealCommunityCards ( oDealer, iPhase, iCardPhase + 1 ) );	
		} else {
			// initialize next round of betting
			iStartingPlayer = GetLocalInt ( oDealer, "iDealerPos" );
			if ( iStartingPlayer < iNumPlayersAllowed ) {
				iStartingPlayer = iStartingPlayer + 1;
			} else {
				iStartingPlayer = 1;
			}
			sStartingPlayer = IntToString(iStartingPlayer);
			while ( ( GetLocalInt ( oDealer, "iPlayer" + sStartingPlayer + "Folded" ) == 1 ) || ( GetLocalInt ( oDealer, "iPlayer" + sStartingPlayer + "AllIn" ) == 1 ) ) {
				if ( iStartingPlayer < iNumPlayersAllowed ) {
					iStartingPlayer = iStartingPlayer + 1;
				} else {
					iStartingPlayer = 1;
				}
				sStartingPlayer = IntToString(iStartingPlayer);				
			}
			SetLocalInt ( oDealer, "iLastRaisingPlayer", iStartingPlayer );
			SetLocalInt ( oDealer, "iCurrentBetValue", 0 );
			SetLocalInt ( oDealer, "iNumRaises", 0 );
			for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
				s = IntToString(i);
				if ( GetLocalInt ( oDealer, "iPlayer" + s + "AllIn" ) == 0 ) {
					SetLocalInt ( oDealer, "iPlayer" + s + "BetValue", 0 );
				}
			}
			DelayCommand ( fPlayDelay, MPGUIUpdateText ( oDealer, "br_poker_txshldm", "msgbanner1", "Betting Round " + IntToString(iPhase + 1) ) );			
			DelayCommand ( fPlayDelay, ManageBettingRound ( oDealer, iStartingPlayer ) );	
		}
	} else {
		sCard = GetLocalArrayString ( oDealer, "sCardStack", iPhase + 11 );
		
		// write the card to array
		SetLocalArrayString ( oDealer, "sCommunityStack", iPhase + 2, sCard );
	
		// update player graphics
		MPGUIUpdateTexture ( oDealer, "br_poker_txshldm", "communitycard" + IntToString(iPhase + 2), sCard );
		
		// initialize next round of betting
		iStartingPlayer = GetLocalInt ( oDealer, "iDealerPos" );
		if ( iStartingPlayer < iNumPlayersAllowed ) {
			iStartingPlayer = iStartingPlayer + 1;
		} else {
			iStartingPlayer = 1;
		}
		sStartingPlayer = IntToString(iStartingPlayer);
		while ( ( GetLocalInt ( oDealer, "iPlayer" + sStartingPlayer + "Folded" ) == 1 ) || ( GetLocalInt ( oDealer, "iPlayer" + sStartingPlayer + "AllIn" ) == 1 ) ) {
			if ( iStartingPlayer < iNumPlayersAllowed ) {
				iStartingPlayer = iStartingPlayer + 1;
			} else {
				iStartingPlayer = 1;
			}
			sStartingPlayer = IntToString(iStartingPlayer);				
		}		
		SetLocalInt ( oDealer, "iLastRaisingPlayer", iStartingPlayer );
		SetLocalInt ( oDealer, "iCurrentBetValue", 0 );
		SetLocalInt ( oDealer, "iNumRaises", 0 );		
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "iPlayer" + s + "AllIn" ) == 0 ) {
				SetLocalInt ( oDealer, "iPlayer" + s + "BetValue", 0 );
			}
		}
		DelayCommand ( fPlayDelay, MPGUIUpdateText ( oDealer, "br_poker_txshldm", "msgbanner1", "Betting Round " + IntToString(iPhase + 1) ) );			
		DelayCommand ( fPlayDelay, ManageBettingRound ( oDealer, iStartingPlayer ) );		
	}
}


// handle end round payout
// set iWinningPlayer to bypass search for winning hand, when all other positions have folded

void EndRoundProcessResults ( object oDealer, int iLastPlayer = 0 ) {
	int i, iAllBetsPaid, iAllInValue, iBestHandFound, iBetValue, iComparisonResult, iGold, iGoldWon, iHandPointer, iLastHandRankEvaluated, iNumAllInHands, iNumWinningHands, iPlayer, iPotValue, iPotValueTemp, iTemp, iValue, iWinningPlayer, j;
	object oPC;
	string s, sCard, sComponentDisplayString, sComponentTextString, sComponentTextureString, sJ, sLastHandRankEvaluated, sPointerArrayName, sPlayer, sPlayerCardStackName, sPlayerSuitStackName, sRankString, sVarName, sWinningPlayers;
	
	AssignCommand ( oDealer, PlaySound("it_coins") );	
	SetLocalInt ( oDealer, "iActivePlayer", 0 );
		
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
			oPC = GetLocalObject ( oDealer, "oPlayer" + s );
			sVarName = "player" + s + "card";
			SetGUIObjectHidden ( oPC, "br_poker_txshldm", sVarName + "1opaque", TRUE );
			SetGUIObjectHidden ( oPC, "br_poker_txshldm", sVarName + "2opaque", TRUE );						
		}
	}	
	
	if ( iLastPlayer != 0 ) {
		s = IntToString(iLastPlayer);
		sVarName = "sPlayer" + s + "Stack";	
		sCard = GetLocalArrayString ( oDealer, sVarName, 1 );
		sComponentTextureString = "player" + s +"card1=" + sCard;
		sCard = GetLocalArrayString ( oDealer, sVarName, 2 );
		sComponentTextureString = sComponentTextureString + ";player" + s +"card2=" + sCard;
		sComponentDisplayString = "player" + s +"bg=0";	
				
		if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
			oPC = GetLocalObject ( oDealer, "oPlayer" + s );
			sComponentTextString = "msgbanner1=" + GetName(oPC) + " wins!";
			
			iPotValue = GetLocalInt ( oDealer, "iPotValue" );			
			iGold = GetGold(oPC);	
			iGold = iGold + iPotValue;	
			GiveGoldToCreature ( oPC, iPotValue, FALSE );
			SendMessageToPC ( oPC, sDefaultGameName + ": You have won " + IntToString(iPotValue) + " gold from the pot." );						
			SetGUIObjectText ( oPC, "br_poker_txshldm", "player_gold", -1, IntToString(iGold) );			
		
			// update gold won
			SetLocalInt ( oDealer, "iPlayer" + s + "RoundGoldWon", iPotValue );				
			iPotValue = 0;
		} else {
			sComponentTextString = "msgbanner1=" + sDefaultName + " wins!";			
		}				
	} else {
		// iterate through and evaluate hands individually
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "iPlayer" + s + "Folded" ) == 0 ) {
				sPointerArrayName = "iPlayer" + s + "HandPointerArray";	
				sPlayerCardStackName = "iPlayer" + s + "HandCardStack";
				sPlayerSuitStackName = "sPlayer" + s + "HandSuitStack";
				sVarName = "sCommunityStack";
				for ( j = 1 ; j <= 5 ; j++ ) {
					SetLocalArrayInt ( oDealer, sPointerArrayName, j, j );
					sCard = GetLocalArrayString ( oDealer, sVarName, j );
					if ( GetStringLength(sCard) == 13 ) {
						SetLocalArrayInt ( oDealer, sPlayerCardStackName, j, StringToInt(GetStringRight ( sCard, 1 )) );
					} else {
						SetLocalArrayInt ( oDealer, sPlayerCardStackName, j, StringToInt(GetStringRight ( sCard, 2 )) );				
					}
					SetLocalArrayString ( oDealer, sPlayerSuitStackName, j, GetStringLeft ( sCard, 12 ) );
				}
				
				sVarName = "sPlayer" + s + "Stack";			
				for ( j = 1 ; j <= 2 ; j++ ) {
					SetLocalArrayInt ( oDealer, sPointerArrayName, j + 5, j + 5 );
					sCard = GetLocalArrayString ( oDealer, sVarName, j );
					if ( GetStringLength(sCard) == 13 ) {
						SetLocalArrayInt ( oDealer, sPlayerCardStackName, j + 5, StringToInt(GetStringRight ( sCard, 1 )) );
					} else {
						SetLocalArrayInt ( oDealer, sPlayerCardStackName, j + 5, StringToInt(GetStringRight ( sCard, 2 )) );				
					}
					SetLocalArrayString ( oDealer, sPlayerSuitStackName, j + 5, GetStringLeft ( sCard, 12 ) );
									
					if ( sComponentTextureString == "" ) {
						sComponentTextureString = "player" + s + "card" + IntToString(j) + "=" + sCard;				
					} else {
						sComponentTextureString = sComponentTextureString + ";player" + s + "card" + IntToString(j) + "=" + sCard;
					}			
				}			
			
				QuickSortCards ( oDealer, sPointerArrayName, sPlayerCardStackName, 1, 7 );
				FindBestPlayerHand ( oDealer, sPointerArrayName, sPlayerCardStackName, sPlayerSuitStackName, 7, i );			
			}
		}
		
		iPotValue = GetLocalInt ( oDealer, "iPotValue" );
		iBestHandFound = 0;
		iLastHandRankEvaluated = 9;
		sLastHandRankEvaluated = IntToString(iLastHandRankEvaluated);		
		while ( iPotValue > 0 ) {
			// find the highest rank hand(s)
			iHandPointer = GetLocalInt ( oDealer, "iRank" + sLastHandRankEvaluated + "HandPointer" );
			while ( iHandPointer == 0 ) {
				iLastHandRankEvaluated = iLastHandRankEvaluated - 1;
				sLastHandRankEvaluated = IntToString(iLastHandRankEvaluated);			
				iHandPointer = GetLocalInt ( oDealer, "iRank" + sLastHandRankEvaluated + "HandPointer" );			
			} 
	
			// evaluate the ranks
			if ( iHandPointer == 1 ) {  // only one hand in this rank
				iPlayer = GetLocalArrayInt ( oDealer, "iRank" + sLastHandRankEvaluated + "HandArray", 1 );
				sPlayer = IntToString(iPlayer);
				if ( GetLocalInt ( oDealer, "i" + sPlayer + "isPlayer" ) == 1 ) {
					oPC = GetLocalObject ( oDealer, "oPlayer" + sPlayer );
					iGold = GetGold(oPC);
					if ( GetLocalInt ( oDealer, "iPlayer" + sPlayer + "AllIn" ) == 1 ) {
						iAllInValue = GetLocalInt ( oDealer, "iPlayer" + sPlayer + "BetValueTotal" );
						iPotValueTemp = iAllInValue;
						for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
							sJ = IntToString(j);
							if ( sJ != sPlayer ) {
								iTemp = GetLocalInt ( oDealer, "iPlayer" + sJ + "BetValueTotal" );
								if ( iTemp >= iAllInValue ) {
									iPotValueTemp = iPotValueTemp + iAllInValue;
								} else {
									iPotValueTemp = iPotValueTemp + iTemp;
								}
							}
						}
							
						GiveGoldToCreature ( oPC, iPotValueTemp, FALSE );
						SendMessageToPC ( oPC, sDefaultGameName + ": You have won " + IntToString(iPotValueTemp) + " gold from the pot." );							
						SetLocalInt ( oDealer, "iPlayer" + sPlayer + "RoundGoldWon", iPotValueTemp );												
						iGold = iGold + iPotValueTemp;
						SetGUIObjectText ( oPC, "br_poker_txshldm", "player_gold", -1, IntToString(iGold) );
						iPotValue = iPotValue - iPotValueTemp;						
	
						// decrement rank pointer
						iLastHandRankEvaluated = iLastHandRankEvaluated - 1;
						sLastHandRankEvaluated = IntToString(iLastHandRankEvaluated);			
					} else {													
						GiveGoldToCreature ( oPC, iPotValue, FALSE );
						SendMessageToPC ( oPC, sDefaultGameName + ": You have won " + IntToString(iPotValue) + " gold from the pot." );					
						SetLocalInt ( oDealer, "iPlayer" + sPlayer + "RoundGoldWon", iPotValue );
						iGold = iGold + iPotValue;	
						iPotValue = 0;			
						SetGUIObjectText ( oPC, "br_poker_txshldm", "player_gold", -1, IntToString(iGold) );				
					}
					
					if ( iBestHandFound == 0 ) {
						iBestHandFound = 1;
						sComponentTextString = "msgbanner1=" + GetName(oPC) + " wins!;";	
						sComponentTextString = sComponentTextString + "msgbanner2=" + GetHandTextDescription ( oDealer, iLastHandRankEvaluated, iPlayer );								
						sVarName = "player" + sPlayer + "card";
						for ( i = 1 ; i <= 5 ; i++ ) {
							iTemp = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer + "BestHandSequence", i );
							iTemp = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer + "HandPointerArray", iTemp );
							if ( sComponentDisplayString == "" ) {
								if ( iTemp > 5 ) {
									sComponentDisplayString = sVarName + IntToString ( iTemp - 5 ) + "bg=1";
								} else {
									sComponentDisplayString = "communitycard" + IntToString(iTemp) + "bg=1";							
								}
							} else {
								if ( iTemp > 5 ) {
									sComponentDisplayString = sComponentDisplayString + ";" + sVarName + IntToString ( iTemp - 5 ) + "bg=1";
								} else {
									sComponentDisplayString = sComponentDisplayString + ";communitycard" + IntToString(iTemp) + "bg=1";							
								}									
							}		
						}
					}
				} else {
					iPotValue = 0;
					if ( iBestHandFound == 0 ) {
						iBestHandFound = 1;				
						sComponentTextString = "msgbanner1=" + sDefaultName + " wins!;";
						sComponentTextString = sComponentTextString + "msgbanner2=" + GetHandTextDescription ( oDealer, iLastHandRankEvaluated, iPlayer );				
						sVarName = "player" + sPlayer + "card";
						
						for ( i = 1 ; i <= 5 ; i++ ) {
							iTemp = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer + "BestHandSequence", i );
							iTemp = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer + "HandPointerArray", iTemp );
							if ( sComponentDisplayString == "" ) {
								if ( iTemp > 5 ) {
									sComponentDisplayString = sVarName + IntToString ( iTemp - 5 ) + "bg=1";
								} else {
									sComponentDisplayString = "communitycard" + IntToString(iTemp) + "bg=1";							
								}
							} else {
								if ( iTemp > 5 ) {
									sComponentDisplayString = sComponentDisplayString + ";" + sVarName + IntToString ( iTemp - 5 ) + "bg=1";
								} else {
									sComponentDisplayString = sComponentDisplayString + ";communitycard" + IntToString(iTemp) + "bg=1";							
								}									
							}	
						}		
					}
				}
			} else {  // break ties
				iWinningPlayer = GetLocalArrayInt ( oDealer, "iRank" + sLastHandRankEvaluated + "HandArray", 1 );
				sWinningPlayers = IntToString(iWinningPlayer);
				for ( i = 2 ; i <= iHandPointer ; i++ ) {
					iPlayer = GetLocalArrayInt ( oDealer, "iRank" + sLastHandRankEvaluated + "HandArray", i );
					iComparisonResult = ComparePlayerHands ( oDealer, iLastHandRankEvaluated, iWinningPlayer, iPlayer );
					if ( iComparisonResult == 0 ) {
						sWinningPlayers = sWinningPlayers + IntToString(iPlayer);
					} else if ( iComparisonResult == -1 ) {
						iWinningPlayer = iPlayer;
						sWinningPlayers = IntToString(iWinningPlayer);
					}
				}
					
				iNumWinningHands = GetStringLength(sWinningPlayers);				
				if ( iBestHandFound == 0 ) {
					iBestHandFound = 1;
					if ( iNumWinningHands == 1 ) {
						if ( GetLocalInt ( oDealer, "i" + sWinningPlayers + "isPlayer" ) == 1 ) {
							oPC = GetLocalObject ( oDealer, "oPlayer" + sWinningPlayers );
							sComponentTextString = "msgbanner1=" + GetName(oPC) + " wins!;";						
						} else {
							sComponentTextString = "msgbanner1=" + sDefaultName + " wins!;";						
						}	
					} else {
						sComponentTextString = "msgbanner1=Tie Hands;";					
					}
					sComponentTextString = sComponentTextString + "msgbanner2=" + GetHandTextDescription ( oDealer, iLastHandRankEvaluated, iWinningPlayer );								
					
					for ( i = 1 ; i <= iNumWinningHands ; i++ ) {
						sPlayer = GetSubString ( sWinningPlayers, i - 1, 1 );
						sVarName = "player" + sPlayer + "card";
						for ( j = 1 ; j <= 5 ; j++ ) {
							iTemp = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer + "BestHandSequence", j );
							iTemp = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer + "HandPointerArray", iTemp );												
							if ( sComponentDisplayString == "" ) {
								if ( iTemp > 5 ) {
									sComponentDisplayString = sVarName + IntToString ( iTemp - 5 ) + "bg=1";
								} else {
									sComponentDisplayString = "communitycard" + IntToString(iTemp) + "bg=1";							
								}
							} else {
								if ( iTemp > 5 ) {
									sComponentDisplayString = sComponentDisplayString + ";" + sVarName + IntToString ( iTemp - 5 ) + "bg=1";
								} else {
									sComponentDisplayString = sComponentDisplayString + ";communitycard" + IntToString(iTemp) + "bg=1";							
								}									
							}		
						}
					}				
				}
	
				// check winners for all-in players
				iNumAllInHands = 0;
				for ( i = 1 ; i <= iNumWinningHands ; i++ ) {
					sPlayer = GetSubString ( sWinningPlayers, i - 1, 1 );
					if ( ( GetLocalInt ( oDealer, "i" + sPlayer + "isPlayer" ) == 1 ) && ( GetLocalInt ( oDealer, "iPlayer" + sPlayer + "AllIn" ) == 1 ) ) {
						iNumAllInHands = iNumAllInHands + 1;
					
						iAllInValue = GetLocalInt ( oDealer, "iPlayer" + sPlayer + "BetValueTotal" );
						iPotValueTemp = iAllInValue;
						for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
							sJ = IntToString(j);
							if ( sJ != sPlayer ) {
								iTemp = GetLocalInt ( oDealer, "iPlayer" + sJ + "BetValueTotal" );
								if ( iTemp >= iAllInValue ) {
									iPotValueTemp = iPotValueTemp + iAllInValue;
								} else {
									iPotValueTemp = iPotValueTemp + iTemp;
								}
							}
						}
						iPotValueTemp = iPotValueTemp / iNumWinningHands;
						
						oPC = GetLocalObject ( oDealer, "oPlayer" + sPlayer );
						iGold = GetGold(oPC);						
						GiveGoldToCreature ( oPC, iPotValueTemp, FALSE );
						SendMessageToPC ( oPC, sDefaultGameName + ": You have won " + IntToString(iPotValueTemp) + " gold from the pot." );							
						SetLocalInt ( oDealer, "iPlayer" + sPlayer + "RoundGoldWon", iPotValueTemp );												
						iGold = iGold + iPotValueTemp;
						SetGUIObjectText ( oPC, "br_poker_txshldm", "player_gold", -1, IntToString(iGold) );
						iPotValue = iPotValue - iPotValueTemp;	
					}
				}	

				// check for non all-in winners
				for ( i = 1 ; i <= iNumWinningHands ; i++ ) {
					sPlayer = GetSubString ( sWinningPlayers, i - 1, 1 );
					if ( GetLocalInt ( oDealer, "i" + sPlayer + "isPlayer" ) == 1 ) {
						if ( GetLocalInt ( oDealer, "iPlayer" + sPlayer + "AllIn" ) != 1 ) {
							oPC = GetLocalObject ( oDealer, "oPlayer" + sPlayer );
							iGold = GetGold(oPC);							
							iGoldWon = iPotValue / ( iNumWinningHands - iNumAllInHands );
							GiveGoldToCreature ( oPC, iGoldWon, FALSE );
							SendMessageToPC ( oPC, sDefaultGameName + ": You have won " + IntToString(iGoldWon) + " gold from the pot." );								
							SetLocalInt ( oDealer, "iPlayer" + sPlayer + "RoundGoldWon", iGoldWon );
							iGold = iGold + iGoldWon;		
							SetGUIObjectText ( oPC, "br_poker_txshldm", "player_gold", -1, IntToString(iGold) );								
						
							iAllBetsPaid = 1;							
						}
					} else {
						iAllBetsPaid = 1;						
					}
				}
					
				if ( iAllBetsPaid == 1 ) {
					iPotValue = 0;
				} else {	
					if ( iNumWinningHands == iHandPointer ) {
						// all hands of this rank are tied
						iLastHandRankEvaluated = iLastHandRankEvaluated - 1;
						sLastHandRankEvaluated = IntToString(iLastHandRankEvaluated);	
					} else {
						// there are lower value hands in this rank
						sRankString = "";
						sVarName = "iRank" + sLastHandRankEvaluated + "HandArray";
						for ( i = 1 ; i <= iHandPointer ; i++ ) {
							sRankString = sRankString + IntToString(GetLocalArrayInt ( oDealer, sVarName, i ));
						}
							
						for ( i = 1 ; i <= iNumWinningHands ; i++ ) {
							iTemp = GetStringLength(sRankString);
							s = GetStringLeft ( sWinningPlayers, 1 );
							iComparisonResult = FindSubString ( sRankString, s );
							if ( iComparisonResult == 0 ) {
								sRankString = GetStringRight ( sRankString, iTemp - 1 );
							} else if ( iComparisonResult == iTemp - 1 ) {
								sRankString = GetStringLeft ( sRankString, iTemp - 1 );
							} else {
								sRankString = GetStringLeft ( sRankString, iComparisonResult ) + GetStringRight ( sRankString, iTemp - ( iComparisonResult + 1 ) );
							}
						}
							
						iHandPointer = GetStringLength(sRankString);
						SetLocalInt ( oDealer, "iRank" + sLastHandRankEvaluated + "HandPointer", iHandPointer );
						for ( i = 1 ; i <= iHandPointer ; i++ ) {
							s = GetStringLeft ( sRankString, 1 );	
							SetLocalArrayInt ( oDealer, sVarName, i, StringToInt(s) );
						}
					}
				}
			} 
		}
	}
	
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		sPlayer = IntToString(i);
		if ( ( GetLocalInt ( oDealer, "i" + sPlayer + "isPlayer" ) == 1 ) && ( GetLocalInt ( oDealer, "iPlayer" + sPlayer + "Folded" ) == 0 ) ) {
			iBetValue = GetLocalInt ( oDealer, "iPlayer" + sPlayer + "RoundGoldWon" );
			if ( iBetValue == 0 ) {
				iBetValue = GetLocalInt ( oDealer, "iPlayer" + sPlayer + "BetValueTotal" );
				iBetValue = iBetValue + GetLocalInt ( oDealer, "iPlayer" + sPlayer + "GoldLost" );
				SetLocalInt ( oDealer, "iPlayer" + sPlayer + "GoldLost", iBetValue );
			} else {
				iBetValue = iBetValue - GetLocalInt ( oDealer, "iPlayer" + sPlayer + "BetValueTotal" );
				iBetValue = iBetValue + GetLocalInt ( oDealer, "iPlayer" + sPlayer + "GoldWon" );
				SetLocalInt ( oDealer, "iPlayer" + sPlayer + "GoldWon", iBetValue );			
			}
		}
	}
	
	// set up display
	if ( sComponentDisplayString == "" ) {
		sComponentDisplayString = "player1action=0";
	} else {
		sComponentDisplayString = sComponentDisplayString + ";player1action=0";
	}
	for ( i = 2 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		sComponentDisplayString = sComponentDisplayString + ";player" + s + "action=0";
	}
	MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", sComponentTextureString, sComponentTextString, sComponentDisplayString );

	// set up next round
	EndRoundCleanUp(oDealer);
}


// clean vars and buttons for next round

void EndRoundCleanUp ( object oDealer ) {
	int i, iDealerPos, iNumPlayers, iWaitList;
	object oPC;
	string s, sComponentString;
	
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		
	}	
	
	ShuffleDeck(oDealer);
	
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
			// enable buttons for human players
			oPC = GetLocalObject ( oDealer, "oPlayer" + s );
			SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_ready", FALSE );
			SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_quit", FALSE );			
		}
		
		SetLocalInt ( oDealer, "iPlayer" + s + "Folded", 0 );
		SetLocalInt ( oDealer, "iPlayer" + s + "AllIn", 0 );
		SetLocalInt ( oDealer, "iPlayer" + s + "BetValue", 0 );
		SetLocalInt ( oDealer, "iPlayer" + s + "BetValueTotal", 0 );
		SetLocalInt ( oDealer, "iPlayer" + s + "isReady", 0 );
	}
	
	for ( i = 0 ; i<= 9 ; i++ ) {
		s = IntToString(i);	
		SetLocalInt ( oDealer, "iRank" + s + "HandPointer", 0 );
	}

	SetLocalInt ( oDealer, "iCurrentBetValue", 0 );
	SetLocalInt ( oDealer, "iNumPlayersFolded", 0 );
	SetLocalInt ( oDealer, "iRoundPhase", 0 );	
	SetLocalInt ( oDealer, "iNumRaises", 0 );	
	SetLocalInt ( oDealer, "iNumReadyPlayers", 0 );		
		
	// move dealer button to next player
	iDealerPos = GetLocalInt ( oDealer, "iDealerPos" );
	sComponentString = "player" + IntToString(iDealerPos) + "dealerbutton=0;";
	if ( iDealerPos < iNumPlayersAllowed ) {
		iDealerPos = iDealerPos + 1;
	} else {
		iDealerPos = 1;
	}
	SetLocalInt ( oDealer, "iDealerPos", iDealerPos );
	sComponentString = sComponentString + "player" + IntToString(iDealerPos) + "dealerbutton=1";
	MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", "", sComponentString );
	
	SetLocalInt ( oDealer, "iInPlay", 0 );
	
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
	
	// set idle timer
	if ( ( iIdleTimer != 0 ) && ( GetLocalInt ( oDealer, "iNumPlayers" ) > 1 ) ) {
		if ( GetLocalInt ( oDealer, "iEndRoundIdleTimerActive" ) == 0 ) {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );	
			MPGUIDisplayComponent ( oDealer, "br_poker_txshldm", "timerpane", 1 );		
			EndRoundIdleTimer(oDealer);
		} else {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );			
		}
	}
}


// anti-grief/logout measures

void BetRoundIdleTimer ( object oDealer, int iCurrentPlayer ) {
	int i, iBetValue, iHalfIdleTimer, iNextPlayer, iNumPlayersFolded, iPlayerPointer, iRoundPhase, iSplit, iTimer;
	object oPC;
	string s, sComponentString, sCurrentPlayer, sPlayerPos;	
	
	if ( GetLocalInt ( oDealer, "iInPlay" ) == 0 ) {
		sPlayerPos = IntToString(iCurrentPlayer);
		oPC = GetLocalObject ( oDealer, "oPlayer" + sPlayerPos );
		SetGUIObjectHidden ( oPC, "br_poker_txshldm", "timerpane", TRUE );		
		return;
	}	
	
	// if the player has finished the round then terminate 
	if ( GetLocalInt ( oDealer, "iActivePlayer" ) != iCurrentPlayer ) {	
		sPlayerPos = IntToString(iCurrentPlayer);
		oPC = GetLocalObject ( oDealer, "oPlayer" + sPlayerPos );
		SetGUIObjectHidden ( oPC, "br_poker_txshldm", "timerpane", TRUE );	
		return;
	}
	
	// check timer to see if it's counted down to 0
	iTimer = GetLocalInt ( oDealer, "iIdleTimer" );
			
	if ( iTimer == -1 ) {
		// force player action
		sPlayerPos = IntToString(iCurrentPlayer);				
		oPC = GetLocalObject ( oDealer, "oPlayer" + sPlayerPos );
		SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Folded", 1 );
		sComponentString = "player" + sPlayerPos + "card1=0;player" + sPlayerPos + "card2=0";
		MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", "player" + sPlayerPos + "action=Fold", sComponentString );				
		SetGUIObjectText ( oPC, "br_poker_txshldm", "bet_call", -1, "0" );
		SetGUIObjectText ( oPC, "br_poker_txshldm", "bet_raise", -1, "0" );		
				
		// hide timer pane and player background, display fold message
		SetGUIObjectHidden ( oPC, "br_poker_txshldm", "timerpane", TRUE );
		MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", "player" + sPlayerPos + "action=Fold", "player" + sPlayerPos + "bg=0" );	
		
		// disable buttons
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_call", TRUE );
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_raise", TRUE );
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_allin", TRUE );
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_fold", TRUE );		
		
		// update fold status
		iNumPlayersFolded = GetLocalInt ( oDealer, "iNumPlayersFolded" );
		iNumPlayersFolded = iNumPlayersFolded + 1;
		SetLocalInt ( oDealer, "iNumPlayersFolded", iNumPlayersFolded );
		
		// update gold lost
		iBetValue = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "BetValueTotal" );
		iBetValue = iBetValue + GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "GoldLost" );
		SetLocalInt ( oDealer, "iPlayer" + s + "GoldLost", iBetValue );
		
		if ( iNumPlayersFolded == ( iNumPlayersAllowed - 1 ) ) {
			// all but one players folded, end the round
			i = 1;
			s = IntToString(i);
			while ( GetLocalInt ( oDealer, "iPlayer" + s + "Folded" ) == 1 ) {
				i = i + 1;
				s = IntToString(i);		
			}	
			EndRoundProcessResults ( oDealer, i );					
		} else {
			// set up the next valid player for betting
			iNextPlayer = StringToInt(sPlayerPos);
			if ( iNextPlayer < iNumPlayersAllowed ) {
				iNextPlayer = iNextPlayer + 1;
			} else {
				iNextPlayer = 1;
			}		
			sCurrentPlayer = IntToString(iNextPlayer);
			while ( ( GetLocalInt ( oDealer, "iPlayer" + sCurrentPlayer + "Folded" ) == 1 ) || ( GetLocalInt ( oDealer, "iPlayer" + sCurrentPlayer + "AllIn" ) == 1 ) ) {
				if ( iNextPlayer < iNumPlayersAllowed ) {
					iNextPlayer = iNextPlayer + 1;
				} else {
					iNextPlayer = 1;
				}
				sCurrentPlayer = IntToString(iNextPlayer);
			}	
				
			// check to see if the next valid player was the last raising player
			if ( GetLocalInt ( oDealer, "iLastRaisingPlayer" ) == iNextPlayer ) {				
				// update vars and evaluate next action
				DelayCommand ( fPlayDelay, EndPhaseEvaluate(oDealer) );			
			} else {
				// set up next betting player
				ManageBettingRound ( oDealer, iNextPlayer );			
			}	
		}			
								
		SendMessageToPC ( oPC, sDefaultGameName + ":You have been passed by the dealer for inactivity." );							
	} else {
		sPlayerPos = IntToString(iCurrentPlayer);
		oPC = GetLocalObject ( oDealer, "oPlayer" + sPlayerPos );
		SetGUIObjectText ( oPC, "br_poker_txshldm", "timerfield", -1, IntToString(iTimer) );
		
		// not counted down yet, iterate
		SetLocalInt ( oDealer, "iIdleTimer", iTimer - 1 );
		DelayCommand ( 1.0, BetRoundIdleTimer ( oDealer, iCurrentPlayer ) );
	}
}


// prevent players from idling between rounds

void EndRoundIdleTimer ( object oDealer ) {
	int i, iHalfIdleTimer, iNumPlayers, iTimer, j;
	object oPlayer;
	string s, sInt;
	
	// terminate if a round has started
	if ( GetLocalInt ( oDealer, "iInPlay" ) == 1 ) {
		SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 0 );
		MPGUIDisplayComponent ( oDealer, "br_poker_txshldm", "timerpane" );								
		return;
	}
	
	iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
	if ( iNumPlayers == 1 ) {
		SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 0 );	
		MPGUIDisplayComponent ( oDealer, "br_poker_txshldm", "timerpane" );			
		return;		
	}	
	
	SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 1 );
	
	// check timer to see if it's counted down to 0
	iTimer = GetLocalInt ( oDealer, "iIdleTimer" );	
			
	if ( iTimer == -1 ) {
		// boot all outstanding players
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) && ( GetLocalInt ( oDealer, "iPlayer" + s + "isReady" ) == 0 ) ) {
				// player is human and not readied up yet
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				
				// hide timer pane
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "timerpane", TRUE );
								
				// clear card stacks
				for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
					sInt = IntToString(j);	
					SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "player" + sInt + "dealerbutton", TRUE );									
					SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "player" + sInt + "bg", TRUE );
					SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "player" + sInt + "card1", TRUE );
					SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "player" + sInt + "card1bg", TRUE );
					SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "player" + sInt + "card2", TRUE );												
					SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "player" + sInt + "card2bg", TRUE );
					SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "player" + sInt + "action", TRUE );												
					SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "player" + sInt + "fold", TRUE );
				}
				
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "communitycard1", TRUE );												
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "communitycard1bg", TRUE );			
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "communitycard2", TRUE );												
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "communitycard2bg", TRUE );
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "communitycard3", TRUE );												
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "communitycard3bg", TRUE );					
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "communitycard4", TRUE );												
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "communitycard4bg", TRUE );
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "communitycard5", TRUE );												
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "communitycard5bg", TRUE );
				
				// disable message banner and pot
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "msgbanner1", TRUE );
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "msgbanner2", TRUE );		
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "pot", TRUE );							
				
				// disable buttons and reinstate wait message
				SetGUIObjectDisabled ( oPlayer, "br_poker_txshldm", "button_ready", TRUE );
				SetGUIObjectDisabled ( oPlayer, "br_poker_txshldm", "button_quit", TRUE );	
				SetGUIObjectHidden ( oPlayer, "br_poker_txshldm", "notice_pane", FALSE );				
		
				// set local gui names
				for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
					sInt = IntToString(j);
					SetGUIObjectText ( oPlayer, "br_poker_txshldm", "player" + sInt + "name1", -1, "" );
					SetGUIObjectText ( oPlayer, "br_poker_txshldm", "player" + sInt + "name2", -1, "" );			
				}						
						
				// close gui	
				CloseGUIScreen ( oPlayer, "br_poker_txshldm" );		
					
				// clear player data from dealer
				SetLocalInt ( oDealer, "i" + s + "isPlayer", 0 );
				SetCasinoStatsArrayPlayerStat ( oPlayer, "TexasHoldem", "Win", GetLocalInt ( oDealer, "iPlayer" + IntToString(i) + "GoldWon" ) );
				SetCasinoStatsArrayPlayerStat ( oPlayer, "TexasHoldem", "Lose", GetLocalInt ( oDealer, "iPlayer" + IntToString(i) + "GoldLost" ) );
				SetCasinoStatsArrayPlayerStat ( oPlayer, "TexasHoldem", "Time", GetPlayerTimePlayed ( oDealer, i ) );
				iNumPlayers = iNumPlayers - 1;
				MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", "player" + s + "name1= ;player" + s + "name2=" + sDefaultName, "" );			
				
				SendMessageToPC ( oPlayer, sDefaultGameName + ": You have been removed from the table for inactivity." );
			}
		}	
		SetLocalInt ( oDealer, "iNumPlayers", iNumPlayers );
		MPMessageAllPlayers ( oDealer, sDefaultGameName + ": The table has been cleared of idle players." );		
		MPGUIDisplayComponent ( oDealer, "br_poker_txshldm", "timerpane" );		
		SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 0 );		
		
		// start game
		SetLocalInt ( oDealer, "iInPlay", 1 );
		DealInitialPlayerHands ( oDealer, 0 );							
	} else {
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				// player is human and not readied up yet
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				SetGUIObjectText ( oPlayer, "br_poker_txshldm", "timerfield", -1, IntToString(iTimer) );
			}
		}
		
		// not counted down yet, iterate
		SetLocalInt ( oDealer, "iIdleTimer", iTimer - 1 );
		DelayCommand ( 1.0, EndRoundIdleTimer(oDealer) );		
	}
}