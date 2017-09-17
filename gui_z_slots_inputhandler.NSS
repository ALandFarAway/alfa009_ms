// Black Rain 2008

#include "nw_o0_itemmaker"
#include "z_slots_include"
#include "z_casino_stats_include"

void main ( string sChange, string dealerTag ) {
	int i, iBetIncrementLocal, iGold, iMaxBetLocal, iMinBetLocal, iReelPos, iSpinIterationsLocal;
	object oDealer, oPC;
	string s, sInt, handlerTag;
	
	oDealer = GetObjectByTag(dealerTag);
	oPC = GetLocalObject ( oDealer, "oPlayer" );
	
	if ( sChange == "spin" ) {
		i = GetLocalInt ( oDealer, "iCurrentBet" );
		if ( GetGold(oPC) >= i ) {  // player has enough gold to cover the bet		
			// hide any old notice messages
			SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", TRUE );
			
			// disable all buttons and enable tilt
			SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_spin", TRUE );		
			SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_tilt", FALSE );	
			SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_payouts", TRUE );
			SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_quit", TRUE );
			SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betplus", TRUE );
			SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betminus", TRUE );
			
			iGold = GetGold(oPC);
			AssignCommand ( oPC, TakeGoldFromCreature ( i, oPC, TRUE, FALSE ) );
			AssignCommand ( oPC, PlaySound("it_eq_fullchain03") );
			iGold = iGold - i;
			SetGUIObjectText ( oPC, "br_slots", "slots_text_gold", -1, IntToString(iGold) );
			DelayCommand ( IntToFloat(i) / 100.0, AssignCommand ( oPC, PlaySound("it_eq_fullchain03") ) );			
		
			// est vars
			SetLocalInt ( oDealer, "iMinIterations", iMinIterations );
			SetLocalInt ( oDealer, "iInPlay", 1 );			
			
			GenerateSpinResults(oDealer);	
			SpinReel ( oDealer, oPC, 0, 0 );
		} else {  // player lacks gold to cover the bet
			SetGUIObjectText ( oPC, "br_slots", "slots_notice", -1, "You don't have enough gold" );
			SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", FALSE );				
		}
	} else if ( sChange == "tilt" ) {
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_tilt", TRUE );		
		TiltSlotMachine(oDealer);
	} else if ( sChange == "payouts" ) {
		// hide any old notice messages
		SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", TRUE );
	
		// disable all buttons
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_spin", TRUE );		
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_tilt", TRUE );	
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_payouts", TRUE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_quit", TRUE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betplus", TRUE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betminus", TRUE );						
			
		// update the pane	
		i = GetLocalInt ( oDealer, "iThreeBarsPayoff" );
		if ( i == 0 ) {
			i = iThreeBarsPayoff;
		}
		if ( i < 99999 ) {
			s = " " + IntToString(i) + " to 1";
		} else if ( i < 9999 ) {
			s = "  " + IntToString(i) + " to 1";
		} else if ( i < 999 ) {
			s = "   " + IntToString(i) + " to 1";		
		} else if ( i < 99 ) {
			s = "    " + IntToString(i) + " to 1";		
		} else if ( i < 9 ) {
			s = "     " + IntToString(i) + " to 1";		
		} else {
			s = "      " + IntToString(i) + " to 1";		
		}
		SetGUIObjectText ( oPC, "br_slots", "slots_payout_3bars", -1, s );

		i = GetLocalInt ( oDealer, "iThreeCherriesPayoff" );
		if ( i == 0 ) {
			i = iThreeCherriesPayoff;
		}
		if ( i < 99999 ) {
			s = " " + IntToString(i) + " to 1";
		} else if ( i < 9999 ) {
			s = "  " + IntToString(i) + " to 1";
		} else if ( i < 999 ) {
			s = "   " + IntToString(i) + " to 1";		
		} else if ( i < 99 ) {
			s = "    " + IntToString(i) + " to 1";		
		} else if ( i < 9 ) {
			s = "     " + IntToString(i) + " to 1";		
		} else {
			s = "      " + IntToString(i) + " to 1";		
		}
		SetGUIObjectText ( oPC, "br_slots", "slots_payout_3cherries", -1, s );		
		
		i = GetLocalInt ( oDealer, "iThreePlumsPayoff" );
		if ( i == 0 ) {
			i = iThreePlumsPayoff;
		}
		if ( i < 99999 ) {
			s = " " + IntToString(i) + " to 1";
		} else if ( i < 9999 ) {
			s = "  " + IntToString(i) + " to 1";
		} else if ( i < 999 ) {
			s = "   " + IntToString(i) + " to 1";		
		} else if ( i < 99 ) {
			s = "    " + IntToString(i) + " to 1";		
		} else if ( i < 9 ) {
			s = "     " + IntToString(i) + " to 1";		
		} else {
			s = "      " + IntToString(i) + " to 1";		
		}
		SetGUIObjectText ( oPC, "br_slots", "slots_payout_3plums", -1, s );				
		
		i = GetLocalInt ( oDealer, "iThreeWatermelonsPayoff" );
		if ( i == 0 ) {
			i = iThreeWatermelonsPayoff;
		}
		if ( i < 99999 ) {
			s = " " + IntToString(i) + " to 1";
		} else if ( i < 9999 ) {
			s = "  " + IntToString(i) + " to 1";
		} else if ( i < 999 ) {
			s = "   " + IntToString(i) + " to 1";		
		} else if ( i < 99 ) {
			s = "    " + IntToString(i) + " to 1";		
		} else if ( i < 9 ) {
			s = "     " + IntToString(i) + " to 1";		
		} else {
			s = "      " + IntToString(i) + " to 1";		
		}
		SetGUIObjectText ( oPC, "br_slots", "slots_payout_3watermelons", -1, s );
		
		i = GetLocalInt ( oDealer, "iThreeOrangesPayoff" );
		if ( i == 0 ) {
			i = iThreeOrangesPayoff;
		}
		if ( i < 99999 ) {
			s = " " + IntToString(i) + " to 1";
		} else if ( i < 9999 ) {
			s = "  " + IntToString(i) + " to 1";
		} else if ( i < 999 ) {
			s = "   " + IntToString(i) + " to 1";		
		} else if ( i < 99 ) {
			s = "    " + IntToString(i) + " to 1";		
		} else if ( i < 9 ) {
			s = "     " + IntToString(i) + " to 1";		
		} else {
			s = "      " + IntToString(i) + " to 1";		
		}
		SetGUIObjectText ( oPC, "br_slots", "slots_payout_3oranges", -1, s );		
		
		i = GetLocalInt ( oDealer, "iThreeLemonsPayoff" );
		if ( i == 0 ) {
			i = iThreeLemonsPayoff;
		}
		if ( i < 99999 ) {
			s = " " + IntToString(i) + " to 1";
		} else if ( i < 9999 ) {
			s = "  " + IntToString(i) + " to 1";
		} else if ( i < 999 ) {
			s = "   " + IntToString(i) + " to 1";		
		} else if ( i < 99 ) {
			s = "    " + IntToString(i) + " to 1";		
		} else if ( i < 9 ) {
			s = "     " + IntToString(i) + " to 1";		
		} else {
			s = "      " + IntToString(i) + " to 1";		
		}
		SetGUIObjectText ( oPC, "br_slots", "slots_payout_3lemons", -1, s );	
		
		i = GetLocalInt ( oDealer, "iTwoCherriesPayoff" );
		if ( i == 0 ) {
			i = iTwoCherriesPayoff;
		}
		if ( i < 99999 ) {
			s = " " + IntToString(i) + " to 1";
		} else if ( i < 9999 ) {
			s = "  " + IntToString(i) + " to 1";
		} else if ( i < 999 ) {
			s = "   " + IntToString(i) + " to 1";		
		} else if ( i < 99 ) {
			s = "    " + IntToString(i) + " to 1";		
		} else if ( i < 9 ) {
			s = "     " + IntToString(i) + " to 1";		
		} else {
			s = "      " + IntToString(i) + " to 1";		
		}
		SetGUIObjectText ( oPC, "br_slots", "slots_payout_2cherries", -1, s );
		
		i = GetLocalInt ( oDealer, "iOneCherryPayoff" );
		if ( i == 0 ) {
			i = iOneCherryPayoff;
		}
		if ( i < 99999 ) {
			s = " " + IntToString(i) + " to 1";
		} else if ( i < 9999 ) {
			s = "  " + IntToString(i) + " to 1";
		} else if ( i < 999 ) {
			s = "   " + IntToString(i) + " to 1";		
		} else if ( i < 99 ) {
			s = "    " + IntToString(i) + " to 1";		
		} else if ( i < 9 ) {
			s = "     " + IntToString(i) + " to 1";		
		} else {
			s = "      " + IntToString(i) + " to 1";		
		}
		SetGUIObjectText ( oPC, "br_slots", "slots_payout_1cherry", -1, s );				
				
		// show the payouts pane
		SetGUIObjectHidden ( oPC, "br_slots", "slots_payouts_pane", FALSE );				
	} else if ( sChange == "quit" ) {		
		for ( i = 1 ; i <= 3 ; i++ ) {
			sInt = IntToString(i);
			
			// disable old frames
			iReelPos = GetLocalInt ( oDealer, "iReel" + sInt + "Pos" );	
			s = "slotwindow" + sInt + "_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, TRUE );
			if ( iReelPos < ( iLastFrame - iImageHeight ) ) {
				s = "slotwindow" + sInt + "_" + IntToString ( iReelPos + iImageHeight );
				SetGUIObjectHidden ( oPC, "br_slots", s, TRUE );	
			}
		}	
		// hide any old notice messages
		SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", TRUE );	
			
		// disable all buttons
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_spin", TRUE );		
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_payouts", TRUE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_quit", TRUE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betplus", TRUE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betminus", TRUE );		
		
		// release dealer and hide timer pane
		SetLocalInt ( oDealer, "iOccupied", 0 );
		SetGUIObjectHidden ( oPC, "br_slots", "timerpane", TRUE );
		
		// set stats
		SetCasinoStatsArrayPlayerStat ( oPC, "Slots", "Win", GetLocalInt ( oDealer, "iPlayerGoldWon" ) );
		SetCasinoStatsArrayPlayerStat ( oPC, "Slots", "Lose", GetLocalInt ( oDealer, "iPlayerGoldLost" ) );		
		SetCasinoStatsArrayPlayerStat ( oPC, "Slots", "Time", GetPlayerTimePlayed (oDealer) );
	
		CloseGUIScreen ( oPC, "br_slots" );	
	} else if ( sChange == "plus" ) {
		// hide any old notice messages
		SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", TRUE );
		
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
		i = GetLocalInt ( oDealer, "iCurrentBet" );			
		if ( i < iMaxBetLocal ) {
			i = i + iBetIncrementLocal;
			SetLocalInt ( oDealer, "iCurrentBet", i );
			SetGUIObjectText ( oPC, "br_slots", "slots_text_bet", -1, IntToString(i) );
		}
	} else if ( sChange == "minus" ) {
		// hide any old notice messages
		SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", TRUE );
		
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
		i = GetLocalInt ( oDealer, "iCurrentBet" );
		if ( i > iMinBetLocal ) {
			i = i - iBetIncrementLocal;
			SetLocalInt ( oDealer, "iCurrentBet", i );
			SetGUIObjectText ( oPC, "br_slots", "slots_text_bet", -1, IntToString(i) );
		}					
	} else if ( sChange == "payoff_pane_close" ) {
		// enable all buttons
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_spin", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_payouts", FALSE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_quit", FALSE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betplus", FALSE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betminus", FALSE );						
				
		// hide the payouts pane
		SetGUIObjectHidden ( oPC, "br_slots", "slots_payouts_pane", TRUE );		
	}
}