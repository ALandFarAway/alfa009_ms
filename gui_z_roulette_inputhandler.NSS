// Black Rain 2008

#include "z_roulette_include"

void main ( string sInput, string sDealer, string sPlayerPos ) {
	int i, iBallPos, iBetIncrementLocal, iCurrentBet, iGold, iMinBetLocal, iMinIterationsLocal, iNumPlayers, iNumReadyPlayers, iWheelPos;
	object oPC, oDealer;
	string s, sComponentString, sVarName;
	
	oDealer = GetObjectByTag(sDealer);
	if ( GetLocalInt ( oDealer, "iInPlay" ) == 1 ) {
		return;
	}
	
	oPC = GetLocalObject ( oDealer, "oPlayer" + sPlayerPos );
	
	if ( sInput == "spin" ) {  // spin the wheel
		if ( GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "CurrentPlacedBet" ) != 0 ) {
			// update gui player background and buttons
			MPGUIDisplayComponent ( oDealer, "br_roulette", "player" + sPlayerPos + "bg", 1 );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_spin", TRUE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_clearbets", TRUE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_payouts", TRUE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_quit", TRUE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_betplus", TRUE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_betminus", TRUE );								
		
			// update player ready status
			SetLocalInt ( oDealer, "i" + sPlayerPos + "isReady", 1 );
			iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
			iNumReadyPlayers = GetLocalInt ( oDealer, "iNumReadyPlayers" );
			iNumReadyPlayers = iNumReadyPlayers + 1;
			SetLocalInt ( oDealer, "iNumReadyPlayers", iNumReadyPlayers );
			
			if ( iNumPlayers == 1 ) {  // only one player, start the spin
				// play spin sound and lock gui during spin
				AssignCommand ( oDealer, PlaySound("as_cv_crank1") );				
				SetLocalInt ( oDealer, "iInPlay", 1);	
				
				// generate results and start spin animation
				GenerateNextSpinResult(oDealer);
				iWheelPos = Random(38) + 1;
				iBallPos = Random(38) + 1;
				SpinWheel ( oDealer, iWheelPos, iBallPos, 0 );
			} else if ( iNumPlayers == iNumReadyPlayers ) {  // all players readied, start the spin
				// play spin sound and lock gui during spin
				AssignCommand ( oDealer, PlaySound("as_cv_crank1") );				
				SetLocalInt ( oDealer, "iInPlay", 1);	
				
				// generate results and start spin animation
				GenerateNextSpinResult(oDealer);
				iWheelPos = Random(38) + 1;
				iBallPos = Random(38) + 1;
				SpinWheel ( oDealer, iWheelPos, iBallPos, 0 );		
			}
		} else {
			SendMessageToPC ( oPC, "Roulette: You do not have any bets placed on the table." );
		}
	} else if ( sInput == "clearBets" ) {
		// clear table bets
		AssignCommand ( oDealer, PlaySound("it_pickup") );			
		iGold = GetGold(oPC);
		sVarName = "iPlayer" + sPlayerPos + "CurrentPlacedBet";
		iCurrentBet = GetLocalInt ( oDealer, sVarName );
		SetLocalInt ( oDealer, sVarName, 0 );
		GiveGoldToCreature ( oPC, iCurrentBet, FALSE );
		iGold = iGold + iCurrentBet;
		SetGUIObjectText ( oPC, "br_roulette", "roulette_gold", -1, IntToString(iGold) );		
		SetGUIObjectText ( oPC, "br_roulette", "roulette_placedbet", -1, "0" );
		
		// clear dealer bet data and update chip graphics
		ClearPlayerBettingPositions ( oDealer, StringToInt(sPlayerPos) );
		if ( GetLocalInt ( oDealer, "iNumPlayers" ) == 1 ) {  
			// only one player at table, clear all chip graphics
			ClearGUIChipGraphics ( oDealer, oPC );
		} else {  
			// the potential for other bets exists, do a full sync
			SyncGUIBetPositions(oDealer);		
		}
	} else if ( sInput == "betsPane" ) {
		// set the bet pane details
		i = GetLocalInt ( oDealer, "iStraightPayout" );
		if ( i == 0 ) {
			i = iStraightPayout;
		}
		if ( i < 10 ) {
			s = " " + IntToString(i) + " to 1";
		} else {
			s = IntToString(i) + " to 1";
		}
		SetGUIObjectText ( oPC, "br_roulette", "roulette_straight_odds", -1, s );

		i = GetLocalInt ( oDealer, "iSplitPayout" );
		if ( i == 0 ) {
			i = iSplitPayout;
		}
		if ( i < 10 ) {
			s = " " + IntToString(i) + " to 1";
		} else {
			s = IntToString(i) + " to 1";
		}
		SetGUIObjectText ( oPC, "br_roulette", "roulette_split_odds", -1, s );	
		
		i = GetLocalInt ( oDealer, "iStreetPayout" );
		if ( i == 0 ) {
			i = iStreetPayout;
		}
		if ( i < 10 ) {
			s = " " + IntToString(i) + " to 1";
		} else {
			s = IntToString(i) + " to 1";
		}
		SetGUIObjectText ( oPC, "br_roulette", "roulette_street_odds", -1, s );				
		SetGUIObjectText ( oPC, "br_roulette", "roulette_trio_odds", -1, s );
		
		i = GetLocalInt ( oDealer, "iCornerPayout" );
		if ( i == 0 ) {
			i = iCornerPayout;
		}
		if ( i < 10 ) {
			s = " " + IntToString(i) + " to 1";
		} else {
			s = IntToString(i) + " to 1";
		}
		SetGUIObjectText ( oPC, "br_roulette", "roulette_corner_odds", -1, s );
		
		i = GetLocalInt ( oDealer, "iFivePayout" );
		if ( i == 0 ) {
			i = iFivePayout;
		}
		if ( i < 10 ) {
			s = " " + IntToString(i) + " to 1";
		} else {
			s = IntToString(i) + " to 1";
		}
		SetGUIObjectText ( oPC, "br_roulette", "roulette_five_odds", -1, s );		
	
		i = GetLocalInt ( oDealer, "iSixLinePayout" );
		if ( i == 0 ) {
			i = iSixLinePayout;
		}
		if ( i < 10 ) {
			s = " " + IntToString(i) + " to 1";
		} else {
			s = IntToString(i) + " to 1";
		}
		SetGUIObjectText ( oPC, "br_roulette", "roulette_sixline_odds", -1, s );		
			
		i = GetLocalInt ( oDealer, "iThirdPayout" );
		if ( i == 0 ) {
			i = iThirdPayout;
		}
		if ( i < 10 ) {
			s = " " + IntToString(i) + " to 1";
		} else {
			s = IntToString(i) + " to 1";
		}
		SetGUIObjectText ( oPC, "br_roulette", "roulette_column_odds", -1, s );		
		SetGUIObjectText ( oPC, "br_roulette", "roulette_dozen_odds", -1, s );
		
		i = GetLocalInt ( oDealer, "iHalfPayout" );
		if ( i == 0 ) {
			i = iHalfPayout;
		}
		if ( i < 10 ) {
			s = " " + IntToString(i) + " to 1";
		} else {
			s = IntToString(i) + " to 1";
		}
		SetGUIObjectText ( oPC, "br_roulette", "roulette_half_odds", -1, s );
							
		// show the pane
		SetGUIObjectHidden ( oPC, "br_roulette", "roulette_payout_pane", FALSE );
	} else if ( sInput == "plus" ) {
		// repeatcallback delay	
		sVarName = "iPlayer" + sPlayerPos;
		if ( GetLocalInt ( oDealer, sVarName + "BetIncrementLock" ) == 1 ) {
			return;
		}
		SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 1 );
		DelayCommand ( 0.02, SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 0 ) );
			
		// determine current bet
		iCurrentBet = GetLocalInt ( oDealer, sVarName + "CurrentBet" );
		iGold = GetGold(oPC);
		if ( iCurrentBet < iGold ) {  // room available to increase bet
			iBetIncrementLocal = GetLocalInt ( oDealer, "iBetIncrement" );
			if ( iBetIncrementLocal == 0 ) {
				iBetIncrementLocal = iBetIncrement;
			}			
			if ( iCurrentBet + iBetIncrement > iGold ) {  // another increment takes bet above available cash
				iCurrentBet = iGold;
			} else {
				iCurrentBet = iCurrentBet + iBetIncrementLocal;
			}
			// set new value and update GUI
			SetLocalInt ( oDealer, sVarName + "CurrentBet", iCurrentBet );
			SetGUIObjectText ( oPC, "br_roulette", "roulette_bet", -1, IntToString(iCurrentBet));
		}
	} else if ( sInput == "minus" ) {
		// repeatcallback delay	
		sVarName = "iPlayer" + sPlayerPos;
		if ( GetLocalInt ( oDealer, sVarName + "BetIncrementLock" ) == 1 ) {
			return;
		}
		SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 1 );
		DelayCommand ( 0.02, SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 0 ) );
			
		// determine current bet
		iCurrentBet = GetLocalInt ( oDealer, sVarName + "CurrentBet" );
		iMinBetLocal = GetLocalInt ( oDealer, "iMinBet" );
		if ( iMinBetLocal == 0 ) {
			iMinBetLocal = iMinBet;
		}
		iBetIncrementLocal = GetLocalInt ( oDealer, "iBetIncrementLocal" );
		if ( iBetIncrementLocal == 0 ) {
			iBetIncrementLocal = iBetIncrement;
		}
		if ( iCurrentBet > iMinBetLocal ) {  // room available to decrease bet
			if ( iCurrentBet - iBetIncrementLocal < iMinBetLocal ) {  // another increment takes bet below min
				iCurrentBet = iMinBetLocal;
			} else {
				iCurrentBet = iCurrentBet - iBetIncrementLocal;
			} 
			// set new value and update GUI
			SetLocalInt ( oDealer, sVarName + "CurrentBet", iCurrentBet );
			SetGUIObjectText ( oPC, "br_roulette", "roulette_bet", -1, IntToString(iCurrentBet));		
		}
	} else if ( sInput == "quit" ) {
		// hide timer pane
		SetGUIObjectHidden ( oPC, "br_roulette", "timerpane", TRUE );	
		
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
		SetGUIObjectText ( oPC, "br_roulette", "roulette_gold", -1, "0" );	
			
		// reset table graphics
		if ( GetLocalInt ( oDealer, "iNumPlayers" ) == 1 ) {  
			// only one player at table, clear all chip graphics
			ClearGUIChipGraphics ( oDealer, oPC );
		} else {  
			// the potential for other bets exists, do a full sync
			SyncGUIBetPositions(oDealer);		
		}		
		
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			sVarName = "player" + IntToString(i);
			SetGUIObjectText ( oPC, "br_roulette", sVarName + "name1", -1, "" );
			SetGUIObjectText ( oPC, "br_roulette", sVarName + "name2", -1, "" );			
			SetGUIObjectText ( oPC, "br_roulette", sVarName + "bet", -1, "" );
			SetGUIObjectHidden ( oPC, "br_roulette", sVarName +"bg", TRUE );
		}		
		
		// disable all buttons
		SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_spin", TRUE);
		SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_clearbets", TRUE);
		SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_payouts", TRUE);
		SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_quit", TRUE);
		SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_betplus", TRUE);
		SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_betminus", TRUE);	
		SetGUIObjectText ( oPC, "br_roulette", "notice_pane_text", -1, "Please wait for the betting round to begin" );		
		SetGUIObjectHidden ( oPC, "br_roulette", "notice_pane_frame", FALSE );		
		SetGUIObjectHidden ( oPC, "br_roulette", "notice_pane", FALSE );						
		
		// close gui
		CloseGUIScreen ( oPC, "br_roulette" );	
			
		// clear player data from dealer
		SetLocalInt ( oDealer, "i" + sPlayerPos + "isPlayer", 0 );
		SetCasinoStatsArrayPlayerStat ( oPC, "Roulette", "Win", GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "GoldWon" ) );
		SetCasinoStatsArrayPlayerStat ( oPC, "Roulette", "Lose", GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "GoldLost" ) );		
		SetCasinoStatsArrayPlayerStat ( oPC, "Roulette", "Time", GetPlayerTimePlayed ( oDealer, StringToInt(sPlayerPos) ) );
		iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
		iNumPlayers = iNumPlayers - 1;
		SetLocalInt ( oDealer, "iNumPlayers", iNumPlayers );	
		
		// notify other players of quittage, update position name
		MPMessageAllPlayers ( oDealer, "Roulette: " + GetName(oPC) + " has left the table." );
		sComponentString = "player" + sPlayerPos + "name1=;player" + sPlayerPos + "name2=" + sDefaultName + ";player" + sPlayerPos + "bet=-";
		MPGUIUpdateMultiComponent ( oDealer, "br_roulette", "", sComponentString, "" );
		
		// check to see if this player has been holding up the game from starting
		iNumReadyPlayers = GetLocalInt ( oDealer, "iNumReadyPlayers" );
		if ( ( iNumPlayers == iNumReadyPlayers ) && ( iNumPlayers != 0 ) ) {
			// play spin sound and lock gui during spin
			AssignCommand ( oDealer, PlaySound("as_cv_crank1") );				
			SetLocalInt ( oDealer, "iInPlay", 1 );	
				
			// generate results and start spin animation
			GenerateNextSpinResult(oDealer);
			iWheelPos = Random(38) + 1;
			iBallPos = Random(38) + 1;
			SpinWheel ( oDealer, iWheelPos, iBallPos, 0 );		
		}	
	} else if ( sInput == "payoff_pane_close" ) {
		SetGUIObjectHidden ( oPC, "br_roulette", "roulette_payout_pane", TRUE );
	}
}