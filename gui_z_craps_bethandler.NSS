// Black Rain 2008

#include "z_craps_include"

void main ( string sDealer, string sPlayerPos, string sType, string sBet ) {
	int i, iBetValue, iBetIncrementLocal, iCurrentBet, iCurrentPlacedBet, iGold, iMaxBetLocal, iMinBetLocal, iRound, iStatus;
	object oDealer, oPC;
	string s, sBetTypeLocal, sVarName;

	oDealer = GetObjectByTag(sDealer);	
	oPC =  GetLocalObject ( oDealer, "oPlayer" + sPlayerPos );
	
	if ( (GetLocalInt ( oDealer, "iInPlay" ) == 1 ) || ( GetLocalInt( oDealer, "i" + sPlayerPos + "isReady" ) == 1 ) ) {
		return;
	}
	
	iRound = GetLocalInt ( oDealer, "iRound" );	
	if ( ( iRound == 1 ) && ( sBet == "pass" ) && ( GetLocalInt ( oDealer, sPlayerPos+"-"+"pass" ) != 0 ) ) {
		sBet = "passodds";
	} else 	if ( ( iRound == 1 ) && ( sBet == "dontpass" ) && ( GetLocalInt ( oDealer,  sPlayerPos+"-"+"dontpass" ) != 0 ) ) {
		sBet = "dontpassodds";
	}
		
	iStatus = 0;
	if ( sType == "place" ) {  // place a bet
		if ( iRound == 0 ) {  // come out roll
			if ( ( sBet == "come" ) || ( sBet == "dontcome" ) ) {
				iStatus = 1;
				SendMessageToPC ( oPC, "You cannot place a Come/Don't Come bet on the come-out roll" );
			} else if ( ( sBet == "pass" ) && ( GetLocalInt ( oDealer,  sPlayerPos + "-" + "dontpass" ) != 0 ) ) {
				iStatus = 1;
				SendMessageToPC ( oPC, "You cannot bet on the Pass Line and Don't Pass simultaneously." );						
			} else if ( ( sBet == "dontpass" ) && ( GetLocalInt ( oDealer,  sPlayerPos+"-"+"pass" ) != 0 ) ) {
				iStatus = 1;
				SendMessageToPC ( oPC, "You cannot bet on the Pass Line and Don't Pass simultaneously." );				
			}
		} else {  // subsequent rolls
			if ( ( sBet == "pass" ) || ( sBet == "dontpass" ) ) {
				iStatus = 1;
				SendMessageToPC ( oPC, "You can only place a Pass/Don't Pass bet on the come-out roll" );						
			} else if ( ( sBet == "come" ) && ( GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome" ) != 0 ) ) {
				iStatus = 1;
				SendMessageToPC ( oPC, "You cannot bet on Come and Don't Come simultaneously." );								
			} else if ( ( sBet == "dontcome" ) && ( GetLocalInt ( oDealer,  sPlayerPos + "-" + "come" ) != 0 ) ) {
				iStatus = 1;
				SendMessageToPC ( oPC, "You cannot bet on Come and Don't Come simultaneously." );										
			} else if ( ( sBet == "placewin4" ) || ( sBet == "placelose4" ) || ( sBet == "buy4" ) || ( sBet == "lay4" ) ) {
				if ( GetLocalInt ( oDealer, "currentPoint" ) == 4 ) {
					iStatus = 1;
					SendMessageToPC ( oPC, "You cannot place this bet on the current point" );				
				}	
			} else if ( ( sBet == "placewin5" ) || ( sBet == "placelose5" ) || ( sBet == "buy5" ) || ( sBet == "lay5" ) ) {
				if ( GetLocalInt ( oDealer, "currentPoint" ) == 5 ) {
					iStatus = 1;
					SendMessageToPC ( oPC, "You cannot place this bet on the current point" );			
				}	
			} else if ( ( sBet == "placewin6" ) || ( sBet == "placelose6" ) || ( sBet == "buy6" ) || ( sBet == "lay6" ) ) {
				if ( GetLocalInt ( oDealer, "currentPoint" ) == 6 ) {
					iStatus = 1;
					SendMessageToPC ( oPC, "You cannot place this bet on the current point" );			
				}	
			} else if ( ( sBet == "placewin8" ) || ( sBet == "placelose8" ) || ( sBet == "buy8" ) || ( sBet == "lay8" ) ) {
				if ( GetLocalInt ( oDealer, "currentPoint" ) == 8 ) {
					iStatus = 1;
					SendMessageToPC ( oPC, "You cannot place this bet on the current point" );			
				}	
			} else if ( ( sBet == "placewin9" ) || ( sBet == "placelose9" ) || ( sBet == "buy9" ) || ( sBet == "lay9" ) ) {
				if ( GetLocalInt ( oDealer, "currentPoint" ) == 9 ) {
					iStatus = 1;
					SendMessageToPC ( oPC, "You cannot place this bet on the current point" );			
				}	
			} else if ( ( sBet == "placewin10" ) || ( sBet == "placelose10" ) || ( sBet == "buy10" ) || ( sBet == "lay10" ) ) {
				if ( GetLocalInt ( oDealer, "currentPoint" ) == 10 ) {
					iStatus = 1;
					SendMessageToPC ( oPC, "You cannot place this bet on the current point" );				
				}	
			}				
		}
	
		if ( iStatus == 0 ) {
			sVarName = "iPlayer" + sPlayerPos;
			iCurrentBet = GetLocalInt ( oDealer, sVarName + "CurrentBet" );			
			iBetValue = GetLocalInt ( oDealer, sPlayerPos + "-" + sBet );
			if ( iBetValue == 0 ) {  // place new bet
				iGold = GetGold(oPC);
				if ( iCurrentBet <= iGold ) {  // enough gold to place the bet
					if ( sBet == "comeodds4" ) {
						if ( GetLocalInt ( oDealer,  sPlayerPos + "-" + "come4" ) == 0 ) {
							iStatus = 1;
							SendMessageToPC ( oPC, "You cannot place a Come/Don'tCome Odds bet without a base bet." );
						}
					} else if ( sBet == "comeodds5" ) {
						if ( GetLocalInt ( oDealer,  sPlayerPos + "-" + "come5" ) == 0 ) {
							iStatus = 1;
							SendMessageToPC ( oPC, "You cannot place a Come/Don'tCome Odds bet without a base bet." );
						}
					} else if ( sBet == "comeodds6" ) {
						if ( GetLocalInt ( oDealer, sPlayerPos + "-" + "come6" ) == 0 ) {
							iStatus = 1;
							SendMessageToPC ( oPC, "You cannot place a Come/Don'tCome Odds bet without a base bet." );	
						}
					} else if ( sBet == "comeodds8" ) {
						if ( GetLocalInt ( oDealer,  sPlayerPos + "-" + "come8" ) == 0 ) {
							iStatus = 1;
							SendMessageToPC ( oPC, "You cannot place a Come/Don'tCome Odds bet without a base bet." );	
						}
					} else if ( sBet == "comeodds9" ) {
						if ( GetLocalInt ( oDealer,  sPlayerPos + "-" + "come9" ) == 0 ) {
							iStatus = 1;
							SendMessageToPC ( oPC, "You cannot place a Come/Don'tCome Odds bet without a base bet." );
						}
					} else if ( sBet == "comeodds10" ) {
						if ( GetLocalInt ( oDealer,  sPlayerPos + "-" + "come10" ) == 0 ) {
							iStatus = 1;
							SendMessageToPC ( oPC, "You cannot place a Come/Don'tCome Odds bet without a base bet." );	
						}
					} else if ( sBet == "dontcomeodds4" ) {
						if ( GetLocalInt ( oDealer,  sPlayerPos + "-" + "dontcome4" ) == 0 ) {
							iStatus = 1;
							SendMessageToPC ( oPC, "You cannot place a Come/Don'tCome Odds bet without a base bet." );
						}
					} else if ( sBet == "dontcomeodds5" ) {
						if ( GetLocalInt ( oDealer,  sPlayerPos + "-" + "dontcome5" ) == 0 ) {
							iStatus = 1;
							SendMessageToPC ( oPC, "You cannot place a Come/Don'tCome Odds bet without a base bet." );	
						}
					} else if ( sBet == "dontcomeodds6" ) {
						if ( GetLocalInt ( oDealer,  sPlayerPos + "-" + "dontcome6" ) == 0 ) {
							iStatus = 1;
							SendMessageToPC ( oPC, "You cannot place a Come/Don'tCome Odds bet without a base bet." );	
						}
					} else if ( sBet == "dontcomeodds8" ) {
						if ( GetLocalInt ( oDealer,  sPlayerPos + "-" + "dontcome8" ) == 0 ) {
							iStatus = 1;
							SendMessageToPC ( oPC, "You cannot place a Come/Don'tCome Odds bet without a base bet." );	
						}
					} else if ( sBet == "dontcomeodds9" ) {
						if ( GetLocalInt ( oDealer,  sPlayerPos + "-" + "dontcome9" ) == 0 ) {
							iStatus = 1;
							SendMessageToPC ( oPC, "You cannot place a Come/Don'tCome Odds bet without a base bet." );
						}
					} else if ( sBet == "dontcomeodds10" ) {
						if ( GetLocalInt ( oDealer,  sPlayerPos + "-" + "dontcome10" ) == 0 ) {
							iStatus = 1;
							SendMessageToPC ( oPC, "You cannot place a Come/Don'tCome Odds bet without a base bet." );
						}
					}
				
					if ( iStatus == 0 ) {
						// handle gold and bet vars
						AssignCommand ( oDealer, PlaySound("it_pickup") );					
						AssignCommand ( oDealer, TakeGoldFromCreature ( iCurrentBet, oPC, TRUE, FALSE ) );
						iGold = iGold - iCurrentBet;
						SetGUIObjectText ( oPC, "br_craps", "craps_gold", -1, IntToString(iGold) );
						iCurrentPlacedBet = GetLocalInt ( oDealer, sVarName + "CurrentPlacedBet" ) + iCurrentBet;
						SetLocalInt ( oDealer, sVarName + "CurrentPlacedBet", iCurrentPlacedBet );
						MPGUIUpdateText ( oDealer, "br_craps", "player" + sPlayerPos + "bet", IntToString(iCurrentPlacedBet) );	
						SetLocalInt ( oDealer, sPlayerPos + "-" + sBet, iCurrentBet );
				
						// update gui
						UpdateChipImage ( oDealer, sBet );
					}										
				} else {
					SendMessageToPC ( oPC, "You do not have enough gold to place the bet." );
				}
			} else {  // bet already exists, modify			
				// check max and min bets
				iMaxBetLocal = GetLocalInt ( oDealer, "iMaxBet" );
				if ( iMaxBetLocal == 0 ) {
					iMaxBetLocal = iMaxBet;
				}
				
				if ( sBet == "big6" ) {
					sBetTypeLocal = "Big 6";			
				} else if ( sBet == "big8" ) {
					sBetTypeLocal = "Big 8";
				} else if ( sBet == "pass" ) {
					sBetTypeLocal = "Pass Line";
				} else if ( sBet == "dontpass" ) {
					sBetTypeLocal == "Don't Pass";
				} else if ( sBet == "passodds" ) {
					sBetTypeLocal = "Pass Line Odds";
					iMaxBetLocal = GetLocalInt ( oDealer,  sPlayerPos + "-" + "pass" ) * 5;			
				} else if ( sBet == "dontpassodds" ) {
					sBetTypeLocal = "Don't Pass Odds";
					iMaxBetLocal = GetLocalInt ( oDealer,  sPlayerPos + "-" + "dontpass" ) * 5;								
				} else if ( sBet == "come" ) {
					sBetTypeLocal = "Come Bet";										
				} else if ( sBet == "dontcome" ) {
					sBetTypeLocal = "Don't Come";									
				} else if ( sBet == "hilo" ) {
					sBetTypeLocal = "Hi-Lo Bet";				
				} else if ( sBet == "hard4" ) {
					sBetTypeLocal = "Hard 4 Bet";				
				} else if ( sBet == "hard6" ) {
					sBetTypeLocal = "Hard 6 Bet";						
				} else if ( sBet == "hard10" ) {
					sBetTypeLocal = "Hard 10 Bet";						
				} else if ( sBet == "hard8" ) {
					sBetTypeLocal = "Hard 8 Bet";						
				} else if ( sBet == "acedeuce" ) {
					sBetTypeLocal = "Ace Deuce Bet";						
				} else if ( sBet == "snakeeyes" ) {
					sBetTypeLocal = "Snake Eyes Bet";						
				} else if ( sBet == "yo" ) {
					sBetTypeLocal = "Yo Bet";						
				} else if ( sBet == "boxcars" ) {
					sBetTypeLocal = "Boxcars Bet";						
				} else if ( sBet == "anyseven" ) {
					sBetTypeLocal = "Any Seven Bet";						
				} else if ( sBet == "anycraps" ) {
					sBetTypeLocal = "Any Craps Bet";						
				} else if ( sBet == "cande" ) {
					sBetTypeLocal = "C & E Bet";		
				} else if ( sBet == "field" ) {
					sBetTypeLocal = "Field Bet";		
				} else if ( sBet == "dontcomeodds4" ) {
					sBetTypeLocal = "Don't Come Odds 4";
					iMaxBetLocal = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome4" ) * 5;						
				} else if ( sBet == "lay4" ) {
					sBetTypeLocal = "Lay 4";				
				} else if ( sBet == "placelose4" ) {
					sBetTypeLocal = "Place Lose 4";				
				} else if ( sBet == "comeodds4" ) {
					sBetTypeLocal = "Come Odds 4";
					iMaxBetLocal = GetLocalInt ( oDealer,  sPlayerPos + "-" + "come4" ) * 5;										
				} else if ( sBet == "buy4" ) {
					sBetTypeLocal = "Buy 4";				
				} else if ( sBet == "placewin4" ) {
					sBetTypeLocal = "Place Win 4";				
				} else if ( sBet == "dontcomeodds5" ) {
					sBetTypeLocal = "Don't Come Odds 5";
					iMaxBetLocal = GetLocalInt ( oDealer,  sPlayerPos + "-" + "dontcome5" ) * 5;						
				} else if ( sBet == "lay5" ) {
					sBetTypeLocal = "Lay 5";				
				} else if ( sBet == "placelose5" ) {
					sBetTypeLocal = "Place Lose 5";				
				} else if ( sBet == "comeodds5" ) {
					sBetTypeLocal = "Come Odds 5";
					iMaxBetLocal = GetLocalInt ( oDealer,  sPlayerPos + "-" + "come5" ) * 5;										
				} else if ( sBet == "buy5" ) {
					sBetTypeLocal = "Buy 5";				
				} else if ( sBet == "placewin5" ) {
					sBetTypeLocal = "Place Win 5";						
				} else if ( sBet == "dontcomeodds6" ) {
					sBetTypeLocal = "Don't Come Odds 6";
					iMaxBetLocal = GetLocalInt ( oDealer,  sPlayerPos + "-" + "dontcome6" ) * 5;						
				} else if ( sBet == "lay6" ) {
					sBetTypeLocal = "Lay 6";				
				} else if ( sBet == "placelose6" ) {
					sBetTypeLocal = "Place Lose 6";				
				} else if ( sBet == "comeodds6" ) {
					sBetTypeLocal = "Come Odds 6";
					iMaxBetLocal = GetLocalInt ( oDealer,  sPlayerPos + "-" + "come6" ) * 5;										
				} else if ( sBet == "buy6" ) {
					sBetTypeLocal = "Buy 6";				
				} else if ( sBet == "placewin6" ) {
					sBetTypeLocal = "Place Win 6";							
				} else if ( sBet == "dontcomeodds8" ) {
					sBetTypeLocal = "Don't Come Odds 8";
					iMaxBetLocal = GetLocalInt ( oDealer,  sPlayerPos + "-" + "dontcome8" ) * 5;						
				} else if ( sBet == "lay8" ) {
					sBetTypeLocal = "Lay 8";				
				} else if ( sBet == "placelose8" ) {
					sBetTypeLocal = "Place Lose 8";				
				} else if ( sBet == "comeodds8" ) {
					sBetTypeLocal = "Come Odds 8";
					iMaxBetLocal = GetLocalInt ( oDealer, sPlayerPos + "-" + "come8" ) * 5;										
				} else if ( sBet == "buy8" ) {
					sBetTypeLocal = "Buy 8";				
				} else if ( sBet == "placewin8" ) {
					sBetTypeLocal = "Place Win 8";
				} else if ( sBet == "dontcomeodds9" ) {
					sBetTypeLocal = "Don't Come Odds 9";
					iMaxBetLocal = GetLocalInt ( oDealer,  sPlayerPos + "-" + "dontcome9" ) * 5;						
				} else if ( sBet == "lay9" ) {
					sBetTypeLocal = "Lay 9";				
				} else if ( sBet == "placelose9" ) {
					sBetTypeLocal = "Place Lose 9";				
				} else if ( sBet == "comeodds9" ) {
					sBetTypeLocal = "Come Odds 9";
					iMaxBetLocal = GetLocalInt ( oDealer,  sPlayerPos + "-" + "come9" ) * 5;										
				} else if ( sBet == "buy9" ) {
					sBetTypeLocal = "Buy 9";				
				} else if ( sBet == "placewin9" ) {
					sBetTypeLocal = "Place Win 9";				
				} else if ( sBet == "dontcomeodds10" ) {
					sBetTypeLocal = "Don't Come Odds 10";
					iMaxBetLocal = GetLocalInt ( oDealer,  sPlayerPos + "-" + "dontcome10" ) * 5;						
				} else if ( sBet == "lay10" ) {
					sBetTypeLocal = "Lay 10";				
				} else if ( sBet == "placelose10" ) {
					sBetTypeLocal = "Place Lose 10";				
				} else if ( sBet == "comeodds10" ) {
					sBetTypeLocal = "Come Odds 10";
					iMaxBetLocal = GetLocalInt ( oDealer,  sPlayerPos + "-" + "come10" ) * 5;										
				} else if ( sBet == "buy10" ) {
					sBetTypeLocal = "Buy 10";				
				} else if ( sBet == "placewin10" ) {
					sBetTypeLocal = "Place Win 10";				
				}
				
				SetLocalInt ( oDealer, sVarName + "LastModifiedBetMax", iMaxBetLocal );
				SetGUIObjectText ( oPC, "br_craps", "craps_modbet_betname", -1, sBetTypeLocal );
				SetLocalInt ( oDealer, sVarName + "LastModifiedBetValue", iBetValue );
				SetGUIObjectText ( oPC, "br_craps", "craps_modbet_bet", -1, IntToString(iBetValue) );
				SetLocalString ( oDealer, sVarName + "LastModifiedBet", sPlayerPos + "-" + sBet );			
				SetGUIObjectHidden ( oPC, "br_craps", "craps_modbet_pane", FALSE );
				PopulateModbetPane ( oDealer, oPC, StringToInt(sPlayerPos), sBet );				
			}
		}
	} else if ( sType == "clear" ) {  //clear the bet
		iStatus = 0;
		if ( ( ( sBet == "pass" ) || ( sBet == "dontpass" ) ) && iRound != 0 ) {
			iStatus = 1;
		}
		
		if ( iStatus == 0 ){
			iBetValue = GetLocalInt ( oDealer, sPlayerPos + "-" + sBet );
			if ( iBetValue != 0 ) {
				sVarName = "iPlayer" + sPlayerPos;
				AssignCommand ( oDealer, PlaySound("it_pickup") );			
				iGold = GetGold(oPC);
				GiveGoldToCreature ( oPC, iBetValue, FALSE );
				iGold = iGold + iBetValue;
				SetGUIObjectText ( oPC, "br_craps", "craps_gold", -1, IntToString(iGold) );								
				SetLocalInt ( oDealer, sPlayerPos + "-" + sBet, 0 );
				iCurrentPlacedBet = GetLocalInt ( oDealer, sVarName + "CurrentPlacedBet" ) - iBetValue;			
				SetLocalInt ( oDealer, sVarName + "CurrentPlacedBet", iCurrentPlacedBet );
				MPGUIUpdateText ( oDealer, "br_craps", "player" + sPlayerPos + "bet", IntToString(iCurrentPlacedBet) );	
				UpdateChipImage ( oDealer, sBet );	
			}
		}	
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
		iMaxBetLocal = GetLocalInt ( oDealer, sVarName + "LastModifiedBetMax" );
		if ( iCurrentBet < iMaxBetLocal ) {  // room available to increase bet
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

			SetGUIObjectText ( oPC, "br_craps", "craps_modbet_bet", -1, IntToString(iCurrentBet));
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
			SetGUIObjectText ( oPC, "br_craps", "craps_modbet_bet", -1, IntToString(iCurrentBet) );		
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
			SetGUIObjectText ( oPC, "br_craps", "craps_placedbet", -1, IntToString(iBetValue) );			
			AssignCommand ( oPC, TakeGoldFromCreature ( iGold, oPC, TRUE, FALSE ) );
			SetGUIObjectText ( oPC, "br_craps", "craps_gold", -1, IntToString ( i - iGold ) );	
			MPGUIUpdateText ( oDealer, "br_craps", "player" + sPlayerPos + "bet", IntToString(iBetValue) );	
		} else if ( iGold < 0 ) {  // decrease bet
			iGold = iGold * -1;
			i = GetGold(oPC);
			SetLocalInt ( oDealer, s, iBetValue );
			iBetValue = GetLocalInt ( oDealer, sVarName + "CurrentPlacedBet" ) - iGold;
			SetLocalInt ( oDealer, sVarName + "CurrentPlacedBet", iBetValue );
			SetGUIObjectText ( oPC, "br_craps", "craps_placedbet", -1, IntToString(iBetValue) );			
			GiveGoldToCreature ( oPC, iGold, FALSE );			
			SetGUIObjectText ( oPC, "br_craps", "craps_gold", -1, IntToString ( i + iGold ) );		
			MPGUIUpdateText ( oDealer, "br_craps", "player" + sPlayerPos + "bet", IntToString(iBetValue) );	
		}
		
		SetGUIObjectHidden ( oPC, "br_craps", "craps_modbet_pane", TRUE );				
	} else if ( sType == "exit" ) {
		SetGUIObjectHidden ( oPC, "br_craps", "craps_modbet_pane", TRUE );	
	}
}