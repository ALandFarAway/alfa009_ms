// Black Rain Software 2009

#include "z_poker_txshldm_include"


void main ( string sDealerTag, string sPlayerPos, string sAction, string sCardNum = "" ) {
	int i, iAnteLocal, iBetValue, iBetValueTotal, iGold, iInitialBetLocal, iNextPlayer, iNumPlayers, iNumPlayersFolded, iNumRaises, iNumReadyPlayers, iPotValue, iRoundPhase;
	object oDealer, oPC;
	string s, sComponentString, sCurrentPlayer, sVarName;
	
	oDealer = GetObjectByTag(sDealerTag);
	oPC = GetLocalObject ( oDealer, "oPlayer" + sPlayerPos );
	
	if ( sAction == "ready" ) {
		// check if player has enough gold to cover ante and initial bet
		iAnteLocal = GetLocalInt ( oDealer, "iAnte" );
		if ( iAnteLocal == 0 ) {  // check for dealer iAnte override
			iAnteLocal = iAnte;
		}
		iInitialBetLocal = GetLocalInt ( oDealer, "iInitialBet" );
		if ( iInitialBetLocal == 0 ) {  // check for dealer iInitialBet override
			iInitialBetLocal = iInitialBet;
		}		
		iGold = GetGold(oPC);		
		if ( iGold < ( iAnteLocal + iInitialBetLocal ) ) {
			SendMessageToPC ( oPC, sDefaultGameName + ": You do not have enough gold to play the next hand." );
			return;	
		} else {
			iGold = iGold - iAnteLocal;
			AssignCommand ( oDealer, TakeGoldFromCreature ( iAnteLocal, oPC, TRUE, FALSE ) );
			SetGUIObjectText ( oPC, "br_poker_txshldm", "player_gold", -1, IntToString(iGold) );
			AssignCommand ( oDealer, PlaySound("it_coins") );							
		}
	
		// disable buttons and set up player data
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_ready", TRUE );
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_quit", TRUE );				
		iNumReadyPlayers = GetLocalInt ( oDealer, "iNumReadyPlayers" );
		iNumReadyPlayers = iNumReadyPlayers + 1;
		SetLocalInt ( oDealer, "iNumReadyPlayers", iNumReadyPlayers );
		SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "isReady", 1 );		
		
		iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
		if ( iNumPlayers == 1 ) {
			// single human player, start the game immediately
			SetLocalInt ( oDealer, "iInPlay", 1 );
			DealInitialPlayerHands ( oDealer, 0 );
		} else if ( iNumPlayers == iNumReadyPlayers ) {
			// all players ready
			SetLocalInt ( oDealer, "iInPlay", 1 );
			DealInitialPlayerHands ( oDealer, 0 );		
		}
	} else if ( sAction == "call" ) {	
		// remove gold from player and add to pot
		iBetValue = GetLocalInt ( oDealer, "iCurrentPlayerCallValue" );
		iGold = GetGold(oPC);
		AssignCommand ( oDealer, TakeGoldFromCreature ( iBetValue, oPC, TRUE, FALSE ) );
		iBetValueTotal = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "BetValueTotal" );
		iBetValueTotal = iBetValueTotal + iBetValue;
		SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "BetValueTotal", iBetValueTotal );
		iGold = iGold - iBetValue;
		SetGUIObjectText ( oPC, "br_poker_txshldm", "player_gold", -1, IntToString(iGold) );
		iPotValue = GetLocalInt ( oDealer, "iPotValue" );
		iPotValue = iPotValue + iBetValue;
		SetLocalInt ( oDealer, "iPotValue", iPotValue );
		if ( iBetValue == 0 ) {
			sComponentString = "pot=Pot: " + IntToString(iPotValue) + ";player" + sPlayerPos + "action=Check";
		} else {		
			sComponentString = "pot=Pot: " + IntToString(iPotValue) + ";player" + sPlayerPos + "action=Call - " + IntToString(iBetValue) + "g added";
		}
		MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", sComponentString, "player" + sPlayerPos + "bg=0" );
		
		// update vars
		sVarName = "iPlayer" + sPlayerPos + "BetValue";
		SetLocalInt ( oDealer, sVarName, GetLocalInt ( oDealer, "iCurrentBetValue" ) );
				
		// disable buttons
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_call", TRUE );
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_raise", TRUE );
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_fold", TRUE );
				
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
			SetLocalInt ( oDealer, "iActivePlayer", 0 );
			iRoundPhase = GetLocalInt ( oDealer, "iRoundPhase" );
			iBetValue = GetLocalInt ( oDealer, "iCurrentBetValue" );
			DelayCommand ( fPlayDelay, EndPhaseEvaluate(oDealer) );	
		} else {
			// set up next betting player
			ManageBettingRound ( oDealer, iNextPlayer );			
		}
	} else if ( sAction == "raise" ) {
		AssignCommand ( oDealer, PlaySound("it_coins") );
			
		// remove gold from player and add to pot
		iBetValue = GetLocalInt ( oDealer, "iCurrentPlayerRaiseValue" );
		iGold = GetGold(oPC);
		AssignCommand ( oDealer, TakeGoldFromCreature ( iBetValue, oPC, TRUE, FALSE ) );
		iBetValueTotal = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "BetValueTotal" );
		iBetValueTotal = iBetValueTotal + iBetValue;
		SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "BetValueTotal", iBetValueTotal );
		iGold = iGold - iBetValue;
		SetGUIObjectText ( oPC, "br_poker_txshldm", "player_gold", -1, IntToString(iGold) );
		iPotValue = GetLocalInt ( oDealer, "iPotValue" );
		iPotValue = iPotValue + iBetValue;
		SetLocalInt ( oDealer, "iPotValue", iPotValue );
		sComponentString = "pot=Pot: " + IntToString(iPotValue) + ";player" + sPlayerPos + "action=Raise - " + IntToString(iBetValue) + "g added";
		MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", sComponentString, "player" + sPlayerPos + "bg=0" );
			
		// update vars
		sVarName = "iPlayer" + sPlayerPos + "BetValue";
		iBetValue = GetLocalInt ( oDealer, sVarName ) + iBetValue;			
		SetLocalInt ( oDealer, sVarName, iBetValue );
		SetLocalInt ( oDealer, "iCurrentBetValue", iBetValue );
		SetLocalInt ( oDealer, "iLastRaisingPlayer", StringToInt(sPlayerPos) );
		iNumRaises = GetLocalInt ( oDealer, "iNumRaises" );
		iNumRaises = iNumRaises + 1;
		SetLocalInt ( oDealer, "iNumRaises", iNumRaises );
		
		// disable buttons
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_call", TRUE );
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_raise", TRUE );
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_fold", TRUE );
				
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
			SetLocalInt ( oDealer, "iActivePlayer", 0 );			
			iRoundPhase = GetLocalInt ( oDealer, "iRoundPhase" );
			iBetValue = GetLocalInt ( oDealer, "iCurrentBetValue" );
			DelayCommand ( fPlayDelay, EndPhaseEvaluate(oDealer) );		
		} else {
			// set up next betting player
			ManageBettingRound ( oDealer, iNextPlayer );			
		}
	} else if ( sAction == "allin" ) {
		SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "AllIn", 1 );	

		// take the player's gold
		iGold = GetGold(oPC);
		AssignCommand ( oDealer, TakeGoldFromCreature ( iGold, oPC, TRUE, FALSE ) );
		iBetValueTotal = GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "BetValueTotal" );
		iBetValueTotal = iBetValueTotal + iGold;
		SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "BetValueTotal", iBetValueTotal );
		iPotValue = GetLocalInt ( oDealer, "iPotValue" );
		iPotValue = iPotValue + iGold;
		SetLocalInt ( oDealer, "iPotValue", iPotValue );
		sComponentString = "pot=Pot: " + IntToString(iPotValue) + ";player" + sPlayerPos + "action=All In - " + IntToString(iGold) + "g added";
		MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", sComponentString, "player" + sPlayerPos + "bg=0" );
		
		// disable buttons and update gold display
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_allin", TRUE );
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_fold", TRUE );		
		SetGUIObjectText ( oPC, "br_poker_txshldm", "player_gold", -1 , "0" );
		
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
			SetLocalInt ( oDealer, "iActivePlayer", 0 );			
			iRoundPhase = GetLocalInt ( oDealer, "iRoundPhase" );
			iBetValue = GetLocalInt ( oDealer, "iCurrentBetValue" );
			DelayCommand ( fPlayDelay, EndPhaseEvaluate(oDealer) );		
		} else {
			// set up next betting player
			ManageBettingRound ( oDealer, iNextPlayer );			
		}		
	} else if ( sAction == "fold" ) {
		SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "Folded", 1 );
		sComponentString = "player" + sPlayerPos + "card1=0;player" + sPlayerPos + "card2=0;player" + sPlayerPos + "bg=0;player" + sPlayerPos + "fold=1";
		MPGUIUpdateMultiComponent ( oDealer, "br_poker_txshldm", "", "player" + sPlayerPos + "action=Fold", sComponentString );				
		SetGUIObjectText ( oPC, "br_poker_txshldm", "bet_call", -1, "0" );
		SetGUIObjectText ( oPC, "br_poker_txshldm", "bet_raise", -1, "0" );	
		
		// disable buttons
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_call", TRUE );
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_raise", TRUE );
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_allin", TRUE );
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_fold", TRUE );				
					
		// hide card opacity and enable fold banner
		sVarName = "player" + sPlayerPos + "card";
		SetGUIObjectHidden ( oPC, "br_poker_txshldm", sVarName + "1opaque", TRUE );
		SetGUIObjectHidden ( oPC, "br_poker_txshldm", sVarName + "2opaque", TRUE );
		SetGUIObjectHidden ( oPC, "br_poker_txshldm", "player" + sPlayerPos + "fold", FALSE );
						
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
				SetLocalInt ( oDealer, "iActivePlayer", 0 );				
				DelayCommand ( fPlayDelay, EndPhaseEvaluate(oDealer) );			
			} else {
				// set up next betting player
				ManageBettingRound ( oDealer, iNextPlayer );			
			}	
		}		
	} else if ( sAction == "quit" ) {
		// hide timer pane
		SetGUIObjectHidden ( oPC, "br_poker_txshldm", "timerpane", TRUE );	
	
		// clear player positions
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);		
			SetGUIObjectHidden ( oPC, "br_poker_txshldm", "player" + s + "bg", TRUE );
			SetGUIObjectHidden ( oPC, "br_poker_txshldm", "player" + s + "card1", TRUE );
			SetGUIObjectHidden ( oPC, "br_poker_txshldm", "player" + s + "card1bg", TRUE );
			SetGUIObjectHidden ( oPC, "br_poker_txshldm", "player" + s + "card2", TRUE );												
			SetGUIObjectHidden ( oPC, "br_poker_txshldm", "player" + s + "card2bg", TRUE );		
			SetGUIObjectHidden ( oPC, "br_poker_txshldm", "player" + s + "action", TRUE );
			SetGUIObjectHidden ( oPC, "br_poker_txshldm", "player" + s + "fold", TRUE );
		}

		for ( i = 1 ; i <= 5 ; i++ ) {
			s = IntToString(i);
			SetGUIObjectHidden ( oPC, "br_poker_txshldm", "communitycard" + s, TRUE );
			SetGUIObjectHidden ( oPC, "br_poker_txshldm", "communitycard" + s + "bg", TRUE );					
		}		
				
		// disable message banner and pot
		SetGUIObjectHidden ( oPC, "br_poker_txshldm", "msgbanner1", TRUE );
		SetGUIObjectHidden ( oPC, "br_poker_txshldm", "msgbanner2", TRUE );		
		SetGUIObjectHidden ( oPC, "br_poker_txshldm", "pot", TRUE );					
		
		// disable buttons and reinstate wait message
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_ready", TRUE );
		SetGUIObjectDisabled ( oPC, "br_poker_txshldm", "button_quit", TRUE );	
		SetGUIObjectHidden ( oPC, "br_poker_txshldm", "notice_pane", FALSE );				
		
		// set local gui names
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			SetGUIObjectText ( oPC, "br_poker_txshldm", "player" + s + "name1", -1, "" );
			SetGUIObjectText ( oPC, "br_poker_txshldm", "player" + s + "name2", -1, "" );			
		}
		
		// close gui	
		CloseGUIScreen ( oPC, "br_poker_txshldm" );		
		
		// clear player data from dealer
		SetLocalInt ( oDealer, "i" + sPlayerPos + "isPlayer", 0 );
		SetCasinoStatsArrayPlayerStat ( oPC, "TexasHoldem", "Win", GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "GoldWon" ) );
		SetCasinoStatsArrayPlayerStat ( oPC, "TexasHoldem", "Lose", GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "GoldLost" ) );		
		SetCasinoStatsArrayPlayerStat ( oPC, "TexasHoldem", "Time", GetPlayerTimePlayed ( oDealer, StringToInt(sPlayerPos) ) );
		iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
		iNumPlayers = iNumPlayers - 1;
		SetLocalInt ( oDealer, "iNumPlayers", iNumPlayers );
		
		// reset dealerpos if there are no players in game
		if ( iNumPlayers == 0 ) {
			SetLocalInt ( oDealer, "iDealerPos", 0 );		
		}
		
		// notify other players of quittage, update position name
		MPMessageAllPlayers ( oDealer, sDefaultGameName + ": " + GetName(oPC) + " has left the table." );
		MPGUIUpdateMultiComponent ( oDealer, "br_poker_", "", "player" + sPlayerPos + "name1= ;player" + sPlayerPos + "name2=" + sDefaultName, "" );
		
		// check to see if this player has been holding up the game from starting
		iNumReadyPlayers = GetLocalInt ( oDealer, "iNumReadyPlayers" );
		if ( ( iNumPlayers == iNumReadyPlayers ) && ( iNumPlayers != 0 ) ) {
			SetLocalInt ( oDealer, "iInPlay", 1 );
			DealInitialPlayerHands ( oDealer, 1 );			
		}		
	}
}