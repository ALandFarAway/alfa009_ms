// Black Rain Software 2009

#include "z_blackjack_include"


void main ( string sAction, string sPlayerPos, string sDealerTag ) {
	int i, iBetBoundary, iBetIncrementLocal, iGold, iHandValue, iNumDecksLocal, iNumPlayers, iNumReadyPlayers, iPlayerPointer, iSplit, iStackPointer, iStake, j;
	object oDealer, oPC;
	string s, sCard, sJ, sVarName;

	oDealer = GetObjectByTag(sDealerTag);
	sVarName = "oPlayer" + sPlayerPos;
	oPC = GetLocalObject ( oDealer, sVarName );
	SetLocalInt ( oDealer, "iLastActingPlayer", StringToInt(sPlayerPos) );
	
	// reset idle timer if a button is pressed while a hand is currently being played
	if ( ( iIdleTimer != 0 ) && ( GetLocalInt ( oDealer, "iInPlay" ) == 1 ) ) {
		SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );
	}
	
	if ( sAction == "plus" ) {
		// repeatcallback delay	
		sVarName = "iPlayer" + sPlayerPos;
		if ( GetLocalInt ( oDealer, sVarName + "BetIncrementLock" ) == 1 ) {
			return;
		}
		SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 1 );
		DelayCommand ( 0.02, SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 0 ) );	
	
		// check and increment stake
		sVarName = "iPlayer" + sPlayerPos + "Stake";
		iStake = GetLocalInt ( oDealer, sVarName );
		iBetBoundary = GetLocalInt ( oDealer, "iMaxBet" );
		if ( iBetBoundary == 0 ) {  // check for iMaxBet local override
			iBetBoundary = iMaxBet;
		}		
		iBetIncrementLocal = GetLocalInt ( oDealer, "iBetIncrement" );
		if ( iBetIncrementLocal == 0 ) {  // check for iBetIncrement local override
			iBetIncrementLocal = iBetIncrement;
		}
		if ( iStake < iBetBoundary ) {
			iStake = iStake + iBetIncrementLocal;
			SetLocalInt ( oDealer, sVarName, iStake );
			SetGUIObjectText ( oPC, "br_blackjack", "player_stake", -1, IntToString(iStake) );				
		}	
	} else if ( sAction == "minus" ) {  // decrement stake
		// repeatcallback delay	
		sVarName = "iPlayer" + sPlayerPos;
		if ( GetLocalInt ( oDealer, sVarName + "BetIncrementLock" ) == 1 ) {
			return;
		}
		SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 1 );
		DelayCommand ( 0.02, SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 0 ) );
	
		// check and decrement stake	
		sVarName = "iPlayer" + sPlayerPos + "Stake";
		iStake = GetLocalInt ( oDealer, sVarName );
		iBetBoundary = GetLocalInt ( oDealer, "iMinBet" );
		if ( iBetBoundary == 0 ) {  // check for iMinBet local override
			iBetBoundary = iMinBet;
		}		
		iBetIncrementLocal = GetLocalInt ( oDealer, "iBetIncrement" );
		if ( iBetIncrementLocal == 0 ) {  // check for iBetIncrement local override
			iBetIncrementLocal = iBetIncrement;
		}		
		if ( iStake > iBetBoundary ) {
			iStake = iStake - iBetIncrementLocal;
			SetLocalInt ( oDealer, sVarName, iStake );
			SetGUIObjectText ( oPC, "br_blackjack", "player_stake", -1, IntToString(iStake) );				
		}	
	} else if ( sAction == "ready" ) {
		// check if player has enough gold to cover stake
		sVarName = "iPlayer" + sPlayerPos + "Stake";	
		iStake = GetLocalInt ( oDealer, sVarName );
		iGold = GetGold(oPC);
		if ( iGold < iStake ) {
			SendMessageToPC ( oPC, "Blackjack: You do not have enough gold to place that stake." );
			return;
		} else {
			iGold = iGold - iStake;
			AssignCommand ( oDealer, TakeGoldFromCreature ( iStake, oPC, TRUE, FALSE ) );
			SetGUIObjectText ( oPC, "br_blackjack", "player_gold", -1, IntToString(iGold) );
			AssignCommand ( oDealer, PlaySound("it_coins") );							
		}
	
		// disable buttons and set up player data
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_ready", TRUE );
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_quit", TRUE );		
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_betplus", TRUE );
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_betminus", TRUE );				
		iNumReadyPlayers = GetLocalInt ( oDealer, "iNumReadyPlayers" );
		iNumReadyPlayers = iNumReadyPlayers + 1;
		SetLocalInt ( oDealer, "iNumReadyPlayers", iNumReadyPlayers );
		SetLocalInt ( oDealer, "i" + sPlayerPos + "isReady", 1 );
		
		iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
		if ( iNumPlayers == 1 ) {
			// single human player, start the game immediately
			SetLocalInt ( oDealer, "iInPlay", 1 );
			DealInitialHands ( oDealer, -1 );
		} else if ( iNumPlayers == iNumReadyPlayers ) {
			// all players ready
			SetLocalInt ( oDealer, "iInPlay", 1 );
			DealInitialHands ( oDealer, -1 );		
		}
	} else if ( sAction == "hit" ) {
		// disable invalid buttons			
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_double", TRUE );
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_split", TRUE );		
	
		// get split status
		iSplit = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Split" );
		
		if ( iSplit == 2 ) {  // hit on second split stack
			// move a card from stack to player, update player pointer
			iStackPointer = GetLocalInt ( oDealer, "iStackPointer" );
			sVarName = "iPlayer" + sPlayerPos + "Pointer2";
			iPlayerPointer = GetLocalInt ( oDealer, sVarName );
			iPlayerPointer = iPlayerPointer + 1;
			sCard = GetLocalArrayString ( oDealer, "sCardStack", iStackPointer );
			SetLocalArrayString ( oDealer, "sPlayer" + sPlayerPos + "Stack2", iPlayerPointer, sCard );
			SetLocalInt ( oDealer, sVarName, iPlayerPointer );
			
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
				
			// check for bust
			iHandValue = GetValueOfStack ( oDealer, "sPlayer" + sPlayerPos + "Stack2", iPlayerPointer );			
			if ( iHandValue > 21 ) {  // bust
				// update all player graphics
				MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "player" + sPlayerPos + "card2_" + IntToString(iPlayerPointer) + "=" + sCard, "player" + sPlayerPos + "card2_msg=BUST", "" );		
				
				// disable invalid buttons
				SetGUIObjectDisabled ( oPC, "br_blackjack", "button_hit", TRUE );
				SetGUIObjectDisabled ( oPC, "br_blackjack", "button_stand", TRUE );
					
				// save final hand and set up next hand position
				SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "FinalHand2", iHandValue );
				DelayCommand ( fPlayDelay, ManageHandPosition ( oDealer, StringToInt(sPlayerPos) + 1 ) );			
			} else {
				// update player card graphics
				MPGUIUpdateTexture ( oDealer, "br_blackjack", "player" + sPlayerPos + "card2_" + IntToString(iPlayerPointer), sCard );			
			}
		} else {  // hit on first split or unsplit stack
			// move a card from stack to player, update player pointer
			iStackPointer = GetLocalInt ( oDealer, "iStackPointer" );
			sVarName = "iPlayer" + sPlayerPos + "Pointer1";
			iPlayerPointer = GetLocalInt ( oDealer, sVarName );
			iPlayerPointer = iPlayerPointer + 1;
			sCard = GetLocalArrayString ( oDealer, "sCardStack", iStackPointer );
			SetLocalArrayString ( oDealer, "sPlayer" + sPlayerPos + "Stack1", iPlayerPointer, sCard );
			SetLocalInt ( oDealer, sVarName, iPlayerPointer );
			
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
			
			// check for bust
			iHandValue = GetValueOfStack ( oDealer, "sPlayer" + sPlayerPos + "Stack1", iPlayerPointer );
			if ( iHandValue > 21 ) {  // bust	
				// check whether this is a single stack or first split stack
				if ( iSplit == 0 ) {  // single stack
					// update all player gui
					MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "player" + sPlayerPos + "card1_" + IntToString(iPlayerPointer) + "=" + sCard, "player" + sPlayerPos + "card1_msg=BUST", "" );
					
					// disable invalid buttons
					SetGUIObjectDisabled ( oPC, "br_blackjack", "button_hit", TRUE );
					SetGUIObjectDisabled ( oPC, "br_blackjack", "button_stand", TRUE );
					
					// save final hand and set up next hand position
					SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "FinalHand1", iHandValue );
					DelayCommand ( fPlayDelay, ManageHandPosition ( oDealer, StringToInt(sPlayerPos) + 1 ) );					
				} else {  // first split stack
					// update all player gui
					MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "player" + sPlayerPos + "card1_" + IntToString(iPlayerPointer) + "=" + sCard, "player" + sPlayerPos + "card1_msg=BUST", "player" + sPlayerPos + "card1_bg=0;player" + sPlayerPos + "card2_bg=1" );
									
					// save final hand and set up player second stack
					SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "FinalHand1", iHandValue );				
					SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Split", 2 );					
				}
			} else {
				// update player card graphics
				MPGUIUpdateTexture ( oDealer, "br_blackjack", "player" + sPlayerPos + "card1_" + IntToString(iPlayerPointer), sCard );		
			}			
		}
	} else if ( sAction == "stand" ) {
		// get split status
		sVarName = "iPlayer" + sPlayerPos + "Split";
		iSplit = GetLocalInt ( oDealer, sVarName );
		
		// check split status
		if ( iSplit == 0 ) {  // no split
			// disable invalid buttons
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_hit", TRUE );
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_stand", TRUE );				
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_double", TRUE );
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_split", TRUE );				
			
			// update all player graphics
			MPGUIUpdateText ( oDealer, "br_blackjack", "player" + sPlayerPos + "card1_msg", "STAND" );			
			
			// save final hand and set up next hand position
			iPlayerPointer = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Pointer1" );
			SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "FinalHand1", GetValueOfStack ( oDealer, "sPlayer" + sPlayerPos + "Stack1", iPlayerPointer ) );
			DelayCommand ( fPlayDelay, ManageHandPosition ( oDealer, StringToInt(sPlayerPos) + 1 ) );		
		} else if ( iSplit == 1 ) {  // first split stack
			// update all player graphics
			MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "", "player" + sPlayerPos + "card1_msg=STAND", "player" + sPlayerPos + "card1_bg=0;player" + sPlayerPos + "card2_bg=1" );			
			
			// save final hand and update split flag
			iPlayerPointer = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Pointer1" );
			SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "FinalHand1", GetValueOfStack ( oDealer, "sPlayer" + sPlayerPos + "Stack1", iPlayerPointer ) );	
			SetLocalInt ( oDealer, sVarName, 2 );					
		} else {  // second split stack
			// disable invalid buttons
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_hit", TRUE );
			SetGUIObjectDisabled ( oPC, "br_blackjack", "button_stand", TRUE );	
			
			// update all player graphics
			MPGUIUpdateText ( oDealer, "br_blackjack", "player" + sPlayerPos + "card2_msg", "STAND" );		
			
			// save final hand and set up next hand position
			iPlayerPointer = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Pointer2" );
			SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "FinalHand2", GetValueOfStack ( oDealer, "sPlayer" + sPlayerPos + "Stack2", iPlayerPointer ) );			
			DelayCommand ( fPlayDelay, ManageHandPosition ( oDealer, StringToInt(sPlayerPos) + 1 ) );				
		}
	} else if ( sAction == "double" ) {	
		// take gold from player
		iStake = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Stake" );
		iGold = GetGold(oPC);
		iGold = iGold - iStake;
		AssignCommand ( oDealer, TakeGoldFromCreature ( iStake, oPC, TRUE, FALSE ) );
		SetGUIObjectText ( oPC, "br_blackjack", "player_gold", -1, IntToString(iGold) );
		AssignCommand ( oDealer, PlaySound("it_coins") );
		
		// disable invalid buttons
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_hit", TRUE );
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_stand", TRUE );				
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_double", TRUE );
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_split", TRUE );	
		
		// move a card from stack to player, update player pointer
		iStackPointer = GetLocalInt ( oDealer, "iStackPointer" );
		sCard = GetLocalArrayString ( oDealer, "sCardStack", iStackPointer );
		SetLocalArrayString ( oDealer, "sPlayer" + sPlayerPos + "Stack1", 3, sCard );
		SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Pointer1", 3 );
			
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
		
		// check for bust and update player graphics
		iHandValue = GetValueOfStack ( oDealer, "sPlayer" + sPlayerPos + "Stack1", 3 );
		if ( iHandValue > 21 ) {  // bust
			MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "player" + sPlayerPos + "card1_3=" + sCard, "player" + sPlayerPos + "card1_msg=BUST", "" );			
		} else { // stand 
			MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "player" + sPlayerPos + "card1_3=" + sCard, "player" + sPlayerPos + "card1_msg=STAND", "" );	
		}
		
		// set double flag, save final hand, and set up next hand position
		SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Doubled", 1 );
		SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "FinalHand1", GetValueOfStack ( oDealer, "sPlayer" + sPlayerPos + "Stack1", 3 ) );
		DelayCommand ( fPlayDelay, ManageHandPosition ( oDealer, StringToInt(sPlayerPos) + 1 ) );			
	} else if ( sAction == "split" ) {
		// take gold from player
		iStake = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Stake" );
		iGold = GetGold(oPC);
		iGold = iGold - iStake;
		AssignCommand ( oDealer, TakeGoldFromCreature ( iStake, oPC, TRUE, FALSE ) );
		SetGUIObjectText ( oPC, "br_blackjack", "player_gold", -1, IntToString(iGold) );
		AssignCommand ( oDealer, PlaySound("it_coins") );	
	
		// disable invalid buttons
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_double", TRUE );
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_split", TRUE );				

		// move card from player stack 1 to 2, update player graphics
		sCard = GetLocalArrayString ( oDealer, "sPlayer" + sPlayerPos + "Stack1", 2 );
		SetLocalArrayString ( oDealer, "sPlayer" + sPlayerPos + "Stack2", 1, sCard );
		MPGUIUpdateMultiComponent ( oDealer, "br_blackjack", "player" + sPlayerPos + "card2_1=" + sCard, "", "player" + sPlayerPos + "card1_2=0" );
		
		// update pointer and flag values		
		SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Pointer1", 1 );
		SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Pointer2", 1 );
		SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Split", 1 );				
	} else if ( sAction == "quit" ) {
		// hide timer pane
		SetGUIObjectHidden ( oPC, "br_blackjack", "timerpane", TRUE );		
		
		// clear card stacks
		for ( i = 1 ; i <= 22 ; i++ ) {
			s = IntToString(i);		
			SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_" + s, TRUE );
			for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
				sJ = IntToString(j);
				SetGUIObjectHidden ( oPC, "br_blackjack", "player" + sJ + "card1_" + s, TRUE );
				SetGUIObjectHidden ( oPC, "br_blackjack", "player" + sJ + "card2_" + s, TRUE );
			}												
		}
		
		// clear message boxes
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealer_msg", TRUE );	
		for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
			sJ = IntToString(j);			
			SetGUIObjectHidden ( oPC, "br_blackjack", "player" + sJ + "card1_msg", TRUE );	
			SetGUIObjectHidden ( oPC, "br_blackjack", "player" + sJ + "card2_msg", TRUE );
		}		
				
		// disable buttons and reinstate wait message
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_ready", TRUE );
		SetGUIObjectDisabled ( oPC, "br_blackjack", "button_quit", TRUE );	
		SetGUIObjectHidden ( oPC, "br_blackjack", "notice_pane", FALSE );				
		
		// close gui	
		CloseGUIScreen ( oPC, "br_blackjack" );		
		
		// clear player data from dealer
		SetLocalInt ( oDealer, "i" + sPlayerPos + "isPlayer", 0 );
		SetCasinoStatsArrayPlayerStat ( oPC, "Blackjack", "Win", GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "GoldWon" ) );
		SetCasinoStatsArrayPlayerStat ( oPC, "Blackjack", "Lose", GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "GoldLost" ) );		
		SetCasinoStatsArrayPlayerStat ( oPC, "Blackjack", "Time", GetPlayerTimePlayed ( oDealer, StringToInt(sPlayerPos) ) );
		iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
		iNumPlayers = iNumPlayers - 1;
		SetLocalInt ( oDealer, "iNumPlayers", iNumPlayers );
		
		// notify other players of quittage, update position name
		MPMessageAllPlayers ( oDealer, "Blackjack: " + GetName(oPC) + " has left the table." );
		MPGUIUpdateText ( oDealer, "br_blackjack", "player" + sPlayerPos + "card1_name", sDefaultName );
		
		// check to see if this player has been holding up the game from starting
		iNumReadyPlayers = GetLocalInt ( oDealer, "iNumReadyPlayers" );
		if ( ( iNumPlayers == iNumReadyPlayers ) && ( iNumPlayers != 0 ) ) {
			SetLocalInt ( oDealer, "iInPlay", 1 );
			DealInitialHands ( oDealer, -1 );			
		}		
	}		
}