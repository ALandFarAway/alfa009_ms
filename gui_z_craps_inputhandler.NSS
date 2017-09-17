// Black Rain 2008

#include "z_craps_include"

void main ( string sDealer, string sPlayerPos, string sInput ) {
	int i, iBetIncrementLocal, iCurrentBet, iGold, iMaxBetLocal, iMinBetLocal, iNumPlayers, iNumReadyPlayers;
	object oDealer, oPC;
	string s, sComponentString, sVarName;
	
	oDealer = GetObjectByTag(sDealer);
	oPC = GetLocalObject ( oDealer, "oPlayer" + sPlayerPos );
	
	if ( GetLocalInt ( oDealer, "iInPlay" ) == 1 ) {
		return;
	}	
	
	if ( sInput == "shoot" ) {
		if ( ( GetLocalInt ( oDealer, "iRound" ) == 0 ) && ( GetLocalInt ( oDealer, sPlayerPos + "-" + "pass" ) == 0 ) && ( GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass" ) == 0 ) )  {
			SendMessageToPC ( oPC, "You must have a bet on Pass/Don't Pass before the round can proceed." );	
		} else if ( ( GetLocalInt ( oDealer, "iRound" ) != 0 ) && ( GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "CurrentPlacedBet" ) == 0 ) ) {
			SendMessageToPC ( oPC, "You must have some gold on the table to take part in the round." );			
		} else {
			// disable buttons
			MPGUIDisplayComponent ( oDealer, "br_craps", "player" + sPlayerPos + "bg", 1 );			
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_shoot", TRUE );
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_bettypes", TRUE );
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_quit", TRUE );
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_betplus", TRUE );
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_betminus", TRUE );	
		
			// set player vars
			SetLocalInt ( oDealer, "i" + sPlayerPos + "isReady", 1 );
			iNumReadyPlayers = GetLocalInt ( oDealer, "iNumReadyPlayers" );
			iNumReadyPlayers = iNumReadyPlayers + 1;
			SetLocalInt ( oDealer, "iNumReadyPlayers", iNumReadyPlayers );
			
			// check if all players are ready
			iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
			if ( iNumPlayers == 1 ) {
				if ( GetLocalInt ( oDealer, "iRound" ) == 0 ) {
					SetLocalInt ( oDealer, "iCurrentPoint", 0 );			
					MPGUIUpdateMultiComponent ( oDealer, "br_craps", "", "craps_message=Come-Out Roll", "craps_message_pane=1" );
					DelayCommand ( 1.5, MPGUIDisplayComponent ( oDealer, "br_craps", "craps_message_pane" ) );				
				}	
				
				SetupRoll(oDealer);							
			} else if ( iNumPlayers == iNumReadyPlayers ) {
				if ( GetLocalInt ( oDealer, "iRound" ) == 0 ) {
					SetLocalInt ( oDealer, "iCurrentPoint", 0 );			
					MPGUIUpdateMultiComponent ( oDealer, "br_craps", "", "craps_message=Come-Out Roll", "craps_message_pane=1" );
					DelayCommand ( 1.5, MPGUIDisplayComponent ( oDealer, "br_craps", "craps_message_pane" ) );	
				}			
				
				SetupRoll(oDealer);
			}
		}
	} else if ( sInput == "bettypes" ) {
		// show the pane
		SetGUIObjectHidden ( oPC, "br_craps", "craps_bets_pane", FALSE );	
	} else if ( sInput == "quit" ) {
		// hide timer pane
		SetGUIObjectHidden ( oPC, "br_craps", "timerpane", TRUE );	
	
		// clear player data from dealer
		SetLocalInt ( oDealer, "i" + sPlayerPos + "isPlayer", 0 );
		SetCasinoStatsArrayPlayerStat ( oPC, "Craps", "Win", GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "GoldWon" ) );
		SetCasinoStatsArrayPlayerStat ( oPC, "Craps", "Lose", GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "GoldLost" ) );		
		SetCasinoStatsArrayPlayerStat ( oPC, "Craps", "Time", GetPlayerTimePlayed ( oDealer, StringToInt(sPlayerPos) ) );
		iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
		iNumPlayers = iNumPlayers - 1;
		SetLocalInt ( oDealer, "iNumPlayers", iNumPlayers );		
		
		// clear the table if any bets exist
		sVarName = "iPlayer" + sPlayerPos + "CurrentPlacedBet";
		iCurrentBet = GetLocalInt ( oDealer, sVarName );
		if ( iCurrentBet != 0 ) {
			AssignCommand ( oDealer, PlaySound("it_pickup") );
			ClearPlayerBettingPositions ( oDealer, StringToInt(sPlayerPos) );
			iGold = GetGold(oPC);
			GiveGoldToCreature ( oPC, iCurrentBet, FALSE );
			iGold = iGold + iCurrentBet;				
		}
		SetGUIObjectText ( oPC, "br_craps", "craps_gold", -1, "0" );
		
		// clear table graphics
		ClearGUIChipGraphics ( oDealer, oPC );
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			sVarName = "player" + IntToString(i);
			SetGUIObjectText ( oPC, "br_craps", sVarName + "name1", -1, "" );
			SetGUIObjectText ( oPC, "br_craps", sVarName + "name2", -1, "" );
			SetGUIObjectText ( oPC, "br_craps", sVarName + "bet", -1, "" );
			SetGUIObjectHidden ( oPC, "br_craps", sVarName +"bg", TRUE );
		}		
		
		for ( i = 4 ; i <= 10 ; i++ ) {
			sVarName = IntToString(i);
			SetGUIObjectHidden ( oPC, "br_craps", "craps_puck_on" + sVarName, TRUE );
			if ( i == 6 ) {
				i = i + 1;
			}
		}
		SetGUIObjectHidden ( oPC, "br_craps", "craps_puck_off", FALSE );	
		SetGUIObjectHidden ( oPC, "br_craps", "craps_message_pane", TRUE );				
		
		// disable buttons
		SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_shoot", TRUE );
		SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_bettypes", TRUE );
		SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_quit", TRUE );
		SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_betplus", TRUE );
		SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_betminus", TRUE );	
		SetGUIObjectHidden ( oPC, "br_craps", "notice_pane", FALSE );		
		
		// close gui
		CloseGUIScreen ( oPC, "br_craps" );		
		
		// notify other players of quittage, update position name
		MPMessageAllPlayers ( oDealer, "Craps: " + GetName(oPC) + " has left the table." );
		sComponentString = "player" + sPlayerPos + "name1=;player" + sPlayerPos + "name2=" + sDefaultName + ";player" + sPlayerPos + "bet=-";
		MPGUIUpdateMultiComponent ( oDealer, "br_craps", "", sComponentString, "" );		
		
		// check to see if this player has been holding up the game from starting
		iNumReadyPlayers = GetLocalInt ( oDealer, "iNumReadyPlayers" );
		if ( ( iNumPlayers == iNumReadyPlayers ) && ( iNumPlayers != 0 ) ) {
			if ( GetLocalInt ( oDealer, "iRound" ) == 0 ) {
				SetLocalInt ( oDealer, "iCurrentPoint", 0 );			
				MPGUIUpdateMultiComponent ( oDealer, "br_craps", "", "craps_message=Come-Out Roll", "craps_message_pane=1" );
				DelayCommand ( 3.0, MPGUIDisplayComponent ( oDealer, "br_craps", "craps_message_pane" ) );				
			}	
				
			SetupRoll(oDealer);			
		}		
	} else if ( sInput == "plus" ) {
		// repeatcallback delay	
		sVarName = "iPlayer" + sPlayerPos;
		if ( GetLocalInt ( oDealer, sVarName + "BetIncrementLock" ) == 1 ) {
			return;
		}
		SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 1 );
		DelayCommand ( 0.02, SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 0 ) );	
	
		// check for local override on max bet and increment
		iMaxBetLocal = GetLocalInt ( oDealer, "iMaxBet" );
		if ( iMaxBetLocal == 0 ) {
			iMaxBetLocal = iMaxBet;
		}
		iBetIncrementLocal = GetLocalInt ( oDealer, "iBetIncrement" );
		if ( iBetIncrementLocal == 0 ) {
			iBetIncrementLocal = iBetIncrement;
		}
				
		// check and increase bet if applicable			
		i = GetLocalInt ( oDealer, sVarName + "CurrentBet" );			
		if ( i < iMaxBetLocal ) {
			i = i + iBetIncrementLocal;
			SetLocalInt ( oDealer, sVarName + "CurrentBet", i );
			SetGUIObjectText ( oPC, "br_craps", "craps_bet", -1, IntToString(i) );
		}			
	} else if ( sInput == "minus" ) {
		// repeatcallback delay	
		sVarName = "iPlayer" + sPlayerPos;
		if ( GetLocalInt ( oDealer, sVarName + "BetIncrementLock" ) == 1 ) {
			return;
		}
		SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 1 );
		DelayCommand ( 0.02, SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 0 ) );

		// check for local override on min bet and increment
		iMinBetLocal = GetLocalInt ( oDealer, "iMinBet" );
		if ( iMinBetLocal == 0 ) {
			iMinBetLocal = iMinBet;
		}
		iBetIncrementLocal = GetLocalInt ( oDealer, "iBetIncrement" );
		if ( iBetIncrementLocal == 0 ) {
			iBetIncrementLocal = iBetIncrement;
		}		
		
		// check and decrease bet if applicable		
		i = GetLocalInt ( oDealer, sVarName + "CurrentBet" );
		if ( i > iMinBetLocal ) {
			i = i - iBetIncrementLocal;
			SetLocalInt ( oDealer, sVarName + "CurrentBet", i );
			SetGUIObjectText ( oPC, "br_craps", "craps_bet", -1, IntToString(i) );
		}	
	} else if ( sInput == "close" ) {
		// hide the pane
		SetGUIObjectHidden ( oPC, "br_craps", "craps_bets_pane", TRUE );	
	}
}