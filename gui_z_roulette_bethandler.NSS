// Black Rain 2008

#include "z_roulette_include"

void main ( string sDealer, string sPlayerPos, string sType, string sBet, string sBetType="" ) {
	int i, iBetValue, iBetIncrementLocal, iCurrentBet, iCurrentPlacedBet, iGold, iLength, iMinBetLocal;
	object oPC, oDealer;
	string s, sBetPrefix, sBetTypeLocal, sVarName;
	
	oDealer = GetObjectByTag(sDealer);
	oPC = GetLocalObject ( oDealer, "oPlayer" + sPlayerPos );
	
	if ( GetLocalInt ( oDealer, "iInPlay" ) == 1 || GetLocalInt ( oDealer, "i" + sPlayerPos + "isReady" ) == 1 ) {
		return;
	}

	// evaluate the bet
	sVarName = "iPlayer" + sPlayerPos;
	iCurrentBet = GetLocalInt ( oDealer, sVarName + "CurrentBet" );	
	if ( sType == "place" ) {  // place a bet
		sBetPrefix = sPlayerPos + "-";
		iBetValue = GetLocalInt ( oDealer, sBetPrefix + sBet );
		if ( iBetValue == 0 ) {  // place new bet
			iGold = GetGold(oPC);
			if ( iCurrentBet <= iGold ) {  // enough gold to place the bet
				// play chip sound
				AssignCommand ( oDealer, PlaySound("it_pickup") );				

				// remove gold and set bet vars
				AssignCommand ( oDealer, TakeGoldFromCreature ( iCurrentBet, oPC, TRUE, FALSE ) );
				iGold = iGold - iCurrentBet;
				SetGUIObjectText ( oPC, "br_roulette", "roulette_gold", -1, IntToString(iGold) );
				iCurrentPlacedBet = GetLocalInt ( oDealer, sVarName + "CurrentPlacedBet" ) + iCurrentBet;
				SetLocalInt ( oDealer, sVarName + "CurrentPlacedBet", iCurrentPlacedBet );
				SetLocalInt ( oDealer, sBetPrefix + sBet, iCurrentBet );

				// update gui
				UpdateChipImage ( oDealer, sBet );
				MPGUIUpdateText ( oDealer, "br_roulette", "player" + sPlayerPos + "bet", IntToString(iCurrentPlacedBet) );				
			} else {
				SendMessageToPC ( oPC, "Roulette: You don't have enough gold to cover that bet." );
			}
		} else {  // bet already exists, modify
			if ( sBetType == "0" ) {
				sBetTypeLocal = "Straight bet ";
			} else if ( sBetType == "1" ) {
				sBetTypeLocal = "Column bet ";
			} else if ( sBetType == "2" ) {
				sBetTypeLocal = "Dozen bet ";
			} else if ( sBetType == "3" ) {
				sBetTypeLocal = "Half board bet ";
			} else if ( sBetType == "4" ) {
				sBetTypeLocal = "Street bet ";
			} else if ( sBetType == "5" ) {
				sBetTypeLocal = "Corner bet ";
			} else if ( sBetType == "6" ) {
				sBetTypeLocal = "Five number bet ";
			} else if ( sBetType == "7" ) {
				sBetTypeLocal = "Six line bet ";
			} else if ( sBetType == "8" ) {
				sBetTypeLocal = "Split bet ";
			} else if ( sBetType == "9" ) {
				sBetTypeLocal = "Trio bet ";
			}
			
			if ( sBetType == "1" ) {
				if ( sBet == "Column1" ) {
					sBetTypeLocal = sBetTypeLocal + "Column 1";
				} else if ( sBet == "Column2" ) {
					sBetTypeLocal = sBetTypeLocal + "Column 2";				
				} else if ( sBet == "Column3" ) {
					sBetTypeLocal = sBetTypeLocal + "Column 3";				
				}
			} else if ( sBetType == "6" ) {
				sBetTypeLocal = sBetTypeLocal + "0-00-1-2-3";			
			} else if ( sBetType == "9" ) {
				if ( sBet == "38_1_2" ) {
					sBetTypeLocal = sBetTypeLocal + "0-1-2";
				} else if ( sBet == "37_2_3" ) {
					sBetTypeLocal = sBetTypeLocal + "00-2-3";
				}		
			} else {
				iLength = GetStringLength(sBet);
				for ( i = 0 ; i <= iLength ; i++ ) {
					s = GetSubString ( sBet, i, 1 );
					if ( s == "_" ) {
						s = "-";
					}
					sBetTypeLocal = sBetTypeLocal + s;
				}
			}
			
			// set up modbet pane
			sBetPrefix = sPlayerPos + "-";
			sVarName = "iPlayer" + sPlayerPos;			
			SetGUIObjectText ( oPC, "br_roulette", "roulette_modbet_betname", -1, sBetTypeLocal );
			iBetValue = GetLocalInt ( oDealer, sBetPrefix + sBet );
			SetLocalInt ( oDealer, sVarName + "LastModifiedBetValue", iBetValue );
			SetGUIObjectText ( oPC, "br_roulette", "roulette_modbet_bet", -1, IntToString(iBetValue) );
			SetLocalString ( oDealer, sVarName + "LastModifiedBet", sBetPrefix + sBet );			
			SetGUIObjectHidden ( oPC, "br_roulette", "roulette_modbet_pane", FALSE );
			PopulateModbetPane ( oDealer, oPC, StringToInt(sPlayerPos), sBet );			
		}
	} else if ( sType == "clear" ) {  //clear the bet
		// play gold sound	
		AssignCommand ( oDealer, PlaySound("it_gold") );
			
		// return gold and set bet vars	
		sBetPrefix = sPlayerPos + "-";
		iGold = GetGold(oPC);
		iBetValue = GetLocalInt ( oDealer, sBetPrefix + sBet );
		SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );
		GiveGoldToCreature ( oPC, iBetValue, FALSE );
		iGold = iGold + iBetValue;
		SetGUIObjectText ( oPC, "br_roulette", "roulette_gold", -1, IntToString(iGold) );
		
		// recalculate current placed bet
		iCurrentPlacedBet = GetLocalInt ( oDealer, sVarName + "CurrentPlacedBet" ) - iBetValue;
		SetLocalInt ( oDealer, sVarName + "CurrentPlacedBet", iCurrentPlacedBet );
		
		// update gui
		UpdateChipImage ( oDealer, sBet );
		MPGUIUpdateText ( oDealer, "br_roulette", "player" + sPlayerPos + "bet", IntToString(iCurrentPlacedBet) );			
	} else if ( sType == "plus" ) {
		// repeatcallback delay	
		sVarName = "iPlayer" + sPlayerPos;
		if ( GetLocalInt ( oDealer, sVarName + "BetIncrementLock" ) == 1 ) {
			return;
		}
		SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 1 );
		DelayCommand ( 0.02, SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 0 ) );
			
		// determine current bet
		iCurrentBet = GetLocalInt ( oDealer, sVarName + "LastModifiedBetValue" );
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
			SetLocalInt ( oDealer, sVarName + "LastModifiedBetValue", iCurrentBet );
			SetGUIObjectText ( oPC, "br_roulette", "roulette_modbet_bet", -1, IntToString(iCurrentBet));
		}		
	} else if ( sType == "minus" ) {
		// repeatcallback delay	
		sVarName = "iPlayer" + sPlayerPos;
		if ( GetLocalInt ( oDealer, sVarName + "BetIncrementLock" ) == 1 ) {
			return;
		}
		SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 1 );
		DelayCommand ( 0.02, SetLocalInt ( oDealer, sVarName + "BetIncrementLock", 0 ) );
			
		// determine current bet
		iCurrentBet = GetLocalInt ( oDealer, sVarName + "LastModifiedBetValue" );
		iBetIncrementLocal = GetLocalInt ( oDealer, "iBetIncrementLocal" );
		if ( iBetIncrementLocal == 0 ) {
			iBetIncrementLocal = iBetIncrement;
		}
		iMinBetLocal = GetLocalInt ( oDealer, "iMinBet" );
		if ( iMinBetLocal == 0 ) {
			iMinBetLocal = iMinBet;
		}
		if ( iCurrentBet > iMinBetLocal ) {  // room available to decrease bet
			if ( iCurrentBet - iBetIncrementLocal < iMinBetLocal ) {  // another increment takes bet below min
				iCurrentBet = iMinBetLocal;
			} else {
				iCurrentBet = iCurrentBet - iBetIncrementLocal;
			} 
			// set new value and update GUI
			SetLocalInt ( oDealer, sVarName + "LastModifiedBetValue", iCurrentBet );
			SetGUIObjectText ( oPC, "br_roulette", "roulette_modbet_bet", -1, IntToString(iCurrentBet) );		
		}	
	} else if ( sType == "apply" ) {
		sVarName = "iPlayer" + sPlayerPos;	
		iBetValue = GetLocalInt ( oDealer, sVarName + "LastModifiedBetValue" );
		s = GetLocalString ( oDealer, sVarName + "LastModifiedBet" );
		iGold = ( iBetValue - GetLocalInt ( oDealer, s ) );
		if ( iGold > 0 ) {  // increase bet
			i = GetGold(oPC);
			SetLocalInt ( oDealer, s, iBetValue );
			iBetValue = GetLocalInt ( oDealer, sVarName + "CurrentPlacedBet" ) + iGold;
			SetLocalInt ( oDealer, sVarName + "CurrentPlacedBet", iBetValue );
			SetGUIObjectText ( oPC, "br_roulette", "roulette_placedbet", -1, IntToString(iBetValue) );			
			AssignCommand ( oPC, TakeGoldFromCreature ( iGold, oPC, TRUE, FALSE ) );
			SetGUIObjectText ( oPC, "br_roulette", "roulette_gold", -1, IntToString ( i - iGold ) );		
		} else if ( iGold < 0 ) {  // decrease bet
			iGold = iGold * -1;
			i = GetGold(oPC);
			SetLocalInt ( oDealer, s, iBetValue );
			iBetValue = GetLocalInt ( oDealer, sVarName + "CurrentPlacedBet" ) - iGold;
			SetLocalInt ( oDealer, sVarName + "CurrentPlacedBet", iBetValue );
			SetGUIObjectText ( oPC, "br_roulette", "roulette_placedbet", -1, IntToString(iBetValue) );			
			GiveGoldToCreature ( oPC, iGold, FALSE );			
			SetGUIObjectText ( oPC, "br_roulette", "roulette_gold", -1, IntToString ( i + iGold ) );		
		}
		SetGUIObjectHidden ( oPC, "br_roulette", "roulette_modbet_pane", TRUE );	
		
		// update gui
		MPGUIUpdateText ( oDealer, "br_roulette", "player" + sPlayerPos + "bet", IntToString(iBetValue) );		
	} else if ( sType == "exit" ) {
		SetGUIObjectHidden ( oPC, "br_roulette", "roulette_modbet_pane", TRUE );	
	}
}