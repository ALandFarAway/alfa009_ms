// Black Rain 2009
//
// rule and setting definitions for roulette
// some settings can be modified in-game by setting appropriate values on object running the game
// ex: to increase max bet set the int iMaxBet on sTag object, it will override the defined setting

#include "y_multiplayer_casino_lib"
#include "z_casino_stats_include"


// default betting variables, these can be changed in-game by overriding on dealer
const int iMinBet = 100;
const int iBetIncrement = 100;


// system variables
const int iIdleTimer = 30;  // amount of time to idle before forcing player action
const int iMinIterations = 51;  // number of min spin frame iterations, higher value for longer spin
const float fSpinDelay = 0.03;  // time between iterations of spin animaiton
const string sDefaultName = "     -";  // default non-player slot name


// payout rates for various types of wins, don't change unless you know what you're doing
// changing payout rates can result in unbalanced games that reward too much or too little
const int iStraightPayout = 35;  // single number bet
const int iSplitPayout = 17;  // two adjacent numbers, also 0-00
const int iStreetPayout = 11;  // three number column, also 0-1-2 and 00-2-3
const int iCornerPayout = 8;  // four number bet
const int iFivePayout = 6;  // 0-00-1-2-3
const int iSixLinePayout = 5;  // six numbers, two adjacent three number columns
const int iThirdPayout = 2;  // first, second, or third column or dozen
const int iHalfPayout = 1;  // odd and even, red and black, 1-18 and 19-36


// function prototypes
void SetUpNewPlayer ( object oDealer, object oPC ); 
void UpdateGUIPlayerList ( object oDealer );
void PopulateNewPlayerGUIBetPositions ( object oDealer, object oPC, int iCurrentPlayer );
void ClearPlayerBettingPositions ( object oDealer, int iPlayerPos );
void ClearGUIChipGraphics ( object oDealer, object oPC );
void SyncGUIBetPositions ( object oDealer );
void UpdateChipImage ( object oDealer, string sBettingPosition );
void PopulateModbetPane ( object oDealer, object oPC, int iPlayerPos, string sBet );
void GenerateNextSpinResult ( object oDealer );
int GetWheelNumber ( int iWheelPos, int iBallPos );
void SpinWheel ( object oDealer, int iWheelPos, int iBallPos, int iIteration, int iStopWheel = 0 );
string GetBoardNumberColour ( int iNumber, int iCapitalize = 0 );
void EvaluateSpinResult ( object oDealer );
void EndRoundCleanup ( object oDealer );
void EndRoundIdleTimer ( object oDealer );


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
		MPMessageAllPlayers ( oDealer, "Roulette: " + GetName(oPC) + " has joined this table." );
	}
	
	// iterate through player positions to find the first available spot
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		sVarName = "i" + s + "isPlayer";	
		if ( GetLocalInt ( oDealer, sVarName ) == 0 ) {
			// set up dealer vars
			SetLocalInt ( oDealer, sVarName, 1 );
			SetLocalObject ( oDealer, "oPlayer" + s, oPC );
			sVarName = "iPlayer" + s;
			SetLocalInt ( oDealer, sVarName + "GoldWon", 0 );
			SetLocalInt ( oDealer, sVarName + "GoldLost", 0 );			
			SetPlayerStartTime ( oDealer, i );		
			
			// set up GUI hidden fields	
			SetGUIObjectText ( oPC, "br_roulette", "playerpos", -1, s );
			SetGUIObjectText ( oPC, "br_roulette", "dealertag", -1, GetTag(oDealer) );			
			
			// set up GUI visible elements
			SetGUIObjectText ( oPC, "br_roulette", "roulette_gold", -1, IntToString(GetGold(oPC)) );		
			iMinBetLocal = GetLocalInt ( oDealer, "iMinBet" );
			if ( iMinBetLocal == 0 ) {  // check for iMinBet local override
				iMinBetLocal = iMinBet;
			}
			SetGUIObjectText ( oPC, "br_roulette", "roulette_bet", -1, IntToString(iMinBetLocal) );
			SetLocalInt ( oDealer, sVarName + "CurrentBet", iMinBetLocal );
			SetLocalInt ( oDealer, sVarName + "CurrentPlacedBet", 0 );
			
			// disable wait notice pane and enable buttons
			SetGUIObjectHidden ( oPC, "br_roulette", "notice_pane", TRUE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_spin", FALSE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_clearbets", FALSE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_payouts", FALSE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_quit", FALSE );			
		
			PopulateNewPlayerGUIBetPositions ( oDealer, oPC, i );		
			break;
		}
	}
	
	// start idle timer if more than one player in
	if ( iIdleTimer != 0 ) {
		if ( ( iNumPlayers > 1 ) && ( GetLocalInt ( oDealer, "iEndRoundIdleTimerActive" ) == 0 ) ) {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );	
			MPGUIDisplayComponent ( oDealer, "br_roulette", "timerpane", 1 );
			EndRoundIdleTimer(oDealer);		
		} else if ( ( iNumPlayers > 1 ) && ( GetLocalInt ( oDealer, "iEndRoundIdleTimerActive" ) != 0 ) ) {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );	
			SetGUIObjectHidden ( oPC, "br_roulette", "timerpane", FALSE );		
		}
	}
}


// update all players' GUI player list data

void UpdateGUIPlayerList ( object oDealer ) {
	int i;
	object oPlayer;
	string s, sComponentString, sVarName;
	
	// build the display string
	sComponentString = "";
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		sVarName = "player" + s;
		if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
			// human player
			oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );					
			if ( iUsePCName == 1 ) {
				sComponentString = sComponentString + sVarName + "name1=" + GetName(oPlayer) + ";" + sVarName + "bet=" + IntToString(GetLocalInt ( oDealer, "iPlayer" + s + "CurrentPlacedBet" )) + ";";				
				sComponentString = sComponentString + sVarName + "name2=" + GetPCPlayerName(oPlayer) + ";";
			} else {
				sComponentString = sComponentString + sVarName + "name2=" + GetName(oPlayer) + ";" + sVarName + "bet=" + IntToString(GetLocalInt ( oDealer, "iPlayer" + s + "CurrentPlacedBet" )) + ";";				
			}
		} else {
			// empty slot
			sComponentString = sComponentString + sVarName + "name2=" + sDefaultName + ";" + sVarName + "bet=-;";
		}
	}
	
	// trim the last ; and update all player guis
	sComponentString = GetStringLeft ( sComponentString, GetStringLength(sComponentString) - 1 );
	MPGUIUpdateMultiComponent ( oDealer, "br_roulette", "", sComponentString, "" );
}


// populate a newly joined player's GUI with existing bets

void PopulateNewPlayerGUIBetPositions ( object oDealer, object oPC, int iCurrentPlayer ) {
	int i, iPlayerPos;
	string sBet, sChipPrefix, sChipResourceName, sPlayerPos, sVarName;
	
	if ( GetLocalInt ( oDealer, "iNumPlayer" ) == 1 ) {
		// first player to join table, skip this routine
		return;
	}
	
	sChipPrefix = "roulette_chip_";
	
	// straight bets
	for ( i = 1 ; i <= 38 ; i++ ) {
		sBet = IntToString(i);
		sChipResourceName = "";
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			if ( iPlayerPos != iCurrentPlayer ) {
				sPlayerPos = IntToString(iPlayerPos);
				if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
					sChipResourceName = sChipResourceName + sPlayerPos;
				}
			}
		}
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
			sVarName = sChipPrefix + sBet;
			SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
		}		
	}
	
	// split bets
	sBet = "38_37";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}		
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}
	
	for ( i = 1 ; i <= 34 ; i = i + 3 ) {  // split bets from first column
		sBet = IntToString(i) + "_" + IntToString ( i + 1 );
		sChipResourceName = "";		
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			if ( iPlayerPos != iCurrentPlayer ) {
				sPlayerPos = IntToString(iPlayerPos);
				if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
					sChipResourceName = sChipResourceName + sPlayerPos;
				}
			}
		}	
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
			sVarName = sChipPrefix + sBet;
			SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
		}
		
		if ( i != 34 ) {
			sBet = IntToString(i) + "_" + IntToString ( i + 3 );
			sChipResourceName = "";		
			// check each player position on this bet position, excluding the joining player
			for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
				if ( iPlayerPos != iCurrentPlayer ) {
					sPlayerPos = IntToString(iPlayerPos);
					if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
						sChipResourceName = sChipResourceName + sPlayerPos;
					}
				}
			}	
			if ( sChipResourceName != "" ) {  // bets exist on this position
				sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
				sVarName = sChipPrefix + sBet;
				SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
				SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
			}							
		}
	}
	
	for ( i = 2 ; i <= 35 ; i = i + 3 ) {  // split bets from second column
		sBet = IntToString(i) + "_" + IntToString ( i + 1 );
		sChipResourceName = "";		
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			if ( iPlayerPos != iCurrentPlayer ) {
				sPlayerPos = IntToString(iPlayerPos);
				if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
					sChipResourceName = sChipResourceName + sPlayerPos;
				}
			}
		}	
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
			sVarName = sChipPrefix + sBet;
			SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
		}	
				
		if ( i != 34 ) {
			sBet = IntToString(i) + "_" + IntToString ( i + 3 );
			sChipResourceName = "";		
			// check each player position on this bet position, excluding the joining player
			for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
				if ( iPlayerPos != iCurrentPlayer ) {
					sPlayerPos = IntToString(iPlayerPos);
					if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
						sChipResourceName = sChipResourceName + sPlayerPos;
					}
				}
			}	
			if ( sChipResourceName != "" ) {  // bets exist on this position
				sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
				sVarName = sChipPrefix + sBet;
				SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
				SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
			}							
		}		
	}	
	
	for ( i = 3 ; i <= 33 ; i = i + 3 ) {  // split bets from third column
		sBet = IntToString(i) + "_" + IntToString ( i + 3 );
		sChipResourceName = "";		
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			if ( iPlayerPos != iCurrentPlayer ) {
				sPlayerPos = IntToString(iPlayerPos);
				if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
					sChipResourceName = sChipResourceName + sPlayerPos;
				}
			}
		}	
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
			sVarName = sChipPrefix + sBet;
			SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
		}
	}	
	
	// street bets
	sBet = "38_1_2";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}
	
	sBet = "37_2_3";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}
	
	for ( i = 1 ; i <= 34 ; i = i + 3 ) {
		sBet = IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 2 );		
		sChipResourceName = "";		
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			if ( iPlayerPos != iCurrentPlayer ) {
				sPlayerPos = IntToString(iPlayerPos);
				if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
					sChipResourceName = sChipResourceName + sPlayerPos;
				}
			}
		}	
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
			sVarName = sChipPrefix + sBet;
			SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
		}	
	}	
	
	// corner bets
	for ( i = 1 ; i <= 31 ; i = i + 3 ) {
		sBet = IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 );		
		sChipResourceName = "";		
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			if ( iPlayerPos != iCurrentPlayer ) {
				sPlayerPos = IntToString(iPlayerPos);
				if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
					sChipResourceName = sChipResourceName + sPlayerPos;
				}
			}
		}	
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
			sVarName = sChipPrefix + sBet;
			SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
		}		
	}
	
	for ( i = 2 ; i <= 32 ; i = i + 3 ) {
		sBet = IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 );		
		sChipResourceName = "";		
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			if ( iPlayerPos != iCurrentPlayer ) {
				sPlayerPos = IntToString(iPlayerPos);
				if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
					sChipResourceName = sChipResourceName + sPlayerPos;
				}
			}
		}	
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
			sVarName = sChipPrefix + sBet;
			SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
		}
	}
	
	// five number bet
	sBet = "38_37_1_2_3";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}	
			
	// six line bets
	for ( i = 1 ; i <= 31 ; i = i + 3 ) {
		sBet = IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 2 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 ) + "_" + IntToString ( i + 5 );
		sChipResourceName = "";		
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			if ( iPlayerPos != iCurrentPlayer ) {
				sPlayerPos = IntToString(iPlayerPos);
				if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
					sChipResourceName = sChipResourceName + sPlayerPos;
				}
			}
		}	
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
			sVarName = sChipPrefix + sBet;
			SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
		}		
	}
	
	// third board bets
	sBet = "Column1";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}
	
	sBet = "Column2";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}
	
	sBet = "Column3";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}
		
	sBet = "1_12";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}
	
	sBet = "13_24";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}
	
	sBet = "25_36";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}	
	
	// half board bets
	sBet = "1_18";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}	
	
	sBet = "19_36";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}
	
	sBet = "odds";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}
	
	sBet = "evens";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}	
	
	sBet = "red";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}	
	
	sBet = "black";
	sChipResourceName = "";		
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		if ( iPlayerPos != iCurrentPlayer ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
	}	
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName + ".tga";
		sVarName = sChipPrefix + sBet;
		SetGUITexture ( oPC, "br_roulette", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
	}
}


// clear one player's bet data off dealer object

void ClearPlayerBettingPositions ( object oDealer, int iPlayerPos ) {
	int i;
	string sBet, sBetPrefix;	
	
	sBetPrefix = IntToString(iPlayerPos) + "-";	
	
	// straight bets
	for ( i = 1 ; i <= 38 ; i++ ) {
		sBet = sBetPrefix + IntToString(i);
		SetLocalInt ( oDealer, sBet, 0 );	
	}	
	
	// split bets
	sBet = sBetPrefix + "38_37";
	SetLocalInt ( oDealer, sBet, 0 );
	
	for ( i = 1 ; i <= 34 ; i = i + 3 ) {  // split bets from first column
		sBet = sBetPrefix + IntToString(i) + "_" + IntToString ( i + 1 );
		SetLocalInt ( oDealer, sBet, 0 );	
		
		if ( i != 34 ) {
			sBet = sBetPrefix + IntToString(i) + "_" + IntToString ( i + 3 );
			SetLocalInt ( oDealer, sBet, 0 );		
		}		
	}
	
	for ( i = 2 ; i <= 35 ; i = i + 3 ) {  // split bets from second column
		sBet = sBetPrefix + IntToString(i) + "_" + IntToString ( i + 1 );
		SetLocalInt ( oDealer, sBet, 0 );
		
		if ( i != 35 ) {
			sBet = sBetPrefix + IntToString(i) + "_" + IntToString ( i + 3 );
			SetLocalInt ( oDealer, sBet, 0 );		
		}		
	}	
	
	for ( i = 3 ; i <= 33 ; i = i + 3 ) {  // split bets from third column
		sBet = sBetPrefix + IntToString(i) + "_" + IntToString ( i + 3 );
		SetLocalInt ( oDealer, sBet, 0 );	
	}	
	
	// street bets
	sBet = sBetPrefix + "38_1_2";
	SetLocalInt ( oDealer, sBet, 0 );
	
	sBet = sBetPrefix + "37_2_3";
	SetLocalInt ( oDealer, sBet, 0 );	
	
	for ( i = 1 ; i <= 34 ; i = i + 3 ) {
		sBet = sBetPrefix + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 2 );
		SetLocalInt ( oDealer, sBet, 0 );			
	}	
	
	// corner bets
	for ( i = 1 ; i <= 31 ; i = i + 3 ) {
		sBet = sBetPrefix + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 );
		SetLocalInt ( oDealer, sBet, 0 );	
	}
	
	for ( i = 2 ; i <= 32 ; i = i + 3 ) {
		sBet = sBetPrefix + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 );
		SetLocalInt ( oDealer, sBet, 0 );	
	}
	
	// five number bet
	sBet = sBetPrefix + "38_37_1_2_3";
	SetLocalInt ( oDealer, sBet, 0 );
			
	// six line bets
	for ( i = 1 ; i <= 31 ; i = i + 3 ) {
		sBet = sBetPrefix + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 2 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 ) + "_" + IntToString ( i + 5 );
		SetLocalInt ( oDealer, sBet, 0 );		
	}		
	
	// third board bets
	sBet = sBetPrefix + "Column1";
	SetLocalInt ( oDealer, sBet, 0 );
	
	sBet = sBetPrefix + "Column2";
	SetLocalInt ( oDealer, sBet, 0 );
	
	sBet = sBetPrefix + "Column3";
	SetLocalInt ( oDealer, sBet, 0 );
	
	sBet = sBetPrefix + "1_12";
	SetLocalInt ( oDealer, sBet, 0 );
	
	sBet = sBetPrefix + "13_24";
	SetLocalInt ( oDealer, sBet, 0 );
	
	sBet = sBetPrefix + "25_36";
	SetLocalInt ( oDealer, sBet, 0 );
	
	// half board bets
	sBet = sBetPrefix + "1_18";
	SetLocalInt ( oDealer, sBet, 0 );
	
	sBet = sBetPrefix + "19_36";
	SetLocalInt ( oDealer, sBet, 0 );
	
	sBet = sBetPrefix + "odds";
	SetLocalInt ( oDealer, sBet, 0 );
	
	sBet = sBetPrefix + "evens";
	SetLocalInt ( oDealer, sBet, 0 );
	
	sBet = sBetPrefix + "red";
	SetLocalInt ( oDealer, sBet, 0 );
	
	sBet = sBetPrefix + "black";
	SetLocalInt ( oDealer, sBet, 0 );
	
	MPGUIUpdateText ( oDealer, "br_roulette", "player" + IntToString(iPlayerPos) + "bet", "0" );						
}


// clear the board of chip graphics for one player, does not check for bet values

void ClearGUIChipGraphics ( object oDealer, object oPC ) {
	int i;
	string sChip, sChipPrefix;	
	
	sChipPrefix = "roulette_chip_";	
	
	// straight bets
	for ( i = 1 ; i <= 38 ; i++ ) {
		sChip = sChipPrefix + IntToString(i);
		SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );
	}	
	
	// split bets
	sChip = sChipPrefix + "38_37";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );
	
	for ( i = 1 ; i <= 34 ; i = i + 3 ) {  // split bets from first column
		sChip = sChipPrefix + IntToString(i) + "_" + IntToString ( i + 1 );
		SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );
		
		if ( i != 34 ) {
			sChip = sChipPrefix + IntToString(i) + "_" + IntToString ( i + 3 );
			SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );		
		}		
	}
	for ( i = 2 ; i <= 35 ; i = i + 3 ) {  // split bets from second column
		sChip = sChipPrefix + IntToString(i) + "_" + IntToString ( i + 1 );
		SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );
		
		if ( i != 35 ) {
			sChip = sChipPrefix + IntToString(i) + "_" + IntToString ( i + 3 );
			SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );			
		}		
	}	
	
	for ( i = 3 ; i <= 33 ; i = i + 3 ) {  // split bets from third column
		sChip = sChipPrefix + IntToString(i) + "_" + IntToString ( i + 3 );
		SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );		
	}	
	
	// street bets
	sChip = sChipPrefix + "38_1_2";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );	
	
	sChip = sChipPrefix + "37_2_3";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );		
	
	for ( i = 1 ; i <= 34 ; i = i + 3 ) {
		sChip = sChipPrefix + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 2 );
		SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );			
	}	
	
	// corner bets
	for ( i = 1 ; i <= 31 ; i = i + 3 ) {
		sChip = sChipPrefix + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 );
		SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );		
	}
	
	for ( i = 2 ; i <= 32 ; i = i + 3 ) {
		sChip = sChipPrefix + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 );
		SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );		
	}
	
	// five number bet
	sChip = sChipPrefix + "38_37_1_2_3";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );	
			
	// six line bets
	for ( i = 1 ; i <= 31 ; i = i + 3 ) {
		sChip = sChipPrefix + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 2 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 ) + "_" + IntToString ( i + 5 );
		SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );			
	}		
	
	// third board bets
	sChip = sChipPrefix + "Column1";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );	
	
	sChip = sChipPrefix + "Column2";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );	;
	
	sChip = sChipPrefix + "Column3";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );	
	
	sChip = sChipPrefix + "1_12";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );	
	
	sChip = sChipPrefix + "13_24";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );	
	
	sChip = sChipPrefix + "25_36";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );	
	
	// half board bets
	sChip = sChipPrefix + "1_18";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );	
	
	sChip = sChipPrefix + "19_36";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );	
	
	sChip = sChipPrefix + "odds";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );	
	
	sChip = sChipPrefix + "evens";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );	
	
	sChip = sChipPrefix + "red";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );	
	
	sChip = sChipPrefix + "black";
	SetGUIObjectHidden ( oPC, "br_roulette", sChip, TRUE );		
}


// sync all players' GUI after one player clears bets
// only use if there's more than one player at the table

void SyncGUIBetPositions ( object oDealer ) {
	int i, iPlayerPos;
	string sBet, sChipPrefix, sChipResourceName, sComponentString, sHideString, sPlayerPos;
	
	sChipPrefix = "roulette_chip_";
	sComponentString = "";
	sHideString = "";
	
	// straight bets
	for ( i = 1 ; i <= 38 ; i++ ) {
		sBet = IntToString(i);
		sChipResourceName = "";
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName;
			sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
		} else {
			sHideString = sHideString + sChipPrefix + sBet + "=0;";			
		}	
	}
	
	// split bets
	sBet = "38_37";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}			
	
	for ( i = 1 ; i <= 34 ; i = i + 3 ) {  // split bets from first column
		sBet = IntToString(i) + "_" + IntToString ( i + 1 );
		sChipResourceName = "";
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName;
			sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
		} else {
			sHideString = sHideString + sChipPrefix + sBet + "=0;";			
		}			
		
		if ( i != 34 ) {
			sBet = IntToString(i) + "_" + IntToString ( i + 3 );
			sChipResourceName = "";
			// check each player position on this bet position, excluding the joining player
			for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
				sPlayerPos = IntToString(iPlayerPos);
				if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
					sChipResourceName = sChipResourceName + sPlayerPos;
				}
			}
			if ( sChipResourceName != "" ) {  // bets exist on this position
				sChipResourceName = "br_chip_" + sChipResourceName;
				sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
			} else {
				sHideString = sHideString + sChipPrefix + sBet + "=0;";			
			}										
		}
	}
	
	for ( i = 2 ; i <= 35 ; i = i + 3 ) {  // split bets from second column
		sBet = IntToString(i) + "_" + IntToString ( i + 1 );
		sChipResourceName = "";
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName;
			sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
		} else {
			sHideString = sHideString + sChipPrefix + sBet + "=0;";			
		}			
				
		if ( i != 34 ) {
			sBet = IntToString(i) + "_" + IntToString ( i + 3 );
			sChipResourceName = "";
			// check each player position on this bet position, excluding the joining player
			for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
				sPlayerPos = IntToString(iPlayerPos);
				if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
					sChipResourceName = sChipResourceName + sPlayerPos;
				}
			}
			if ( sChipResourceName != "" ) {  // bets exist on this position
				sChipResourceName = "br_chip_" + sChipResourceName;
				sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
			} else {
				sHideString = sHideString + sChipPrefix + sBet + "=0;";			
			}										
		}		
	}	
	
	for ( i = 3 ; i <= 33 ; i = i + 3 ) {  // split bets from third column
		sBet = IntToString(i) + "_" + IntToString ( i + 3 );
		sChipResourceName = "";
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName;
			sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
		} else {
			sHideString = sHideString + sChipPrefix + sBet + "=0;";			
		}		
	}	
	
	// street bets
	sBet = "38_1_2";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}				
	
	sBet = "37_2_3";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}		
	
	for ( i = 1 ; i <= 34 ; i = i + 3 ) {
		sBet = IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 2 );		
		sChipResourceName = "";
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName;
			sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
		} else {
			sHideString = sHideString + sChipPrefix + sBet + "=0;";			
		}		
	}	
	
	// corner bets
	for ( i = 1 ; i <= 31 ; i = i + 3 ) {
		sBet = IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 );		
		sChipResourceName = "";
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName;
			sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
		} else {
			sHideString = sHideString + sChipPrefix + sBet + "=0;";			
		}			
	}
	
	for ( i = 2 ; i <= 32 ; i = i + 3 ) {
		sBet = IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 );		
		sChipResourceName = "";
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName;
			sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
		} else {
			sHideString = sHideString + sChipPrefix + sBet + "=0;";			
		}			
	}
	
	// five number bet
	sBet = "38_37_1_2_3";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}			
			
	// six line bets
	for ( i = 1 ; i <= 31 ; i = i + 3 ) {
		sBet = IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 2 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 ) + "_" + IntToString ( i + 5 );
		sChipResourceName = "";
		// check each player position on this bet position, excluding the joining player
		for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
			sPlayerPos = IntToString(iPlayerPos);
			if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
				sChipResourceName = sChipResourceName + sPlayerPos;
			}
		}
		if ( sChipResourceName != "" ) {  // bets exist on this position
			sChipResourceName = "br_chip_" + sChipResourceName;
			sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
		} else {
			sHideString = sHideString + sChipPrefix + sBet + "=0;";			
		}				
	}
	
	// third board bets
	sBet = "Column1";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}		
	
	sBet = "Column2";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}	
	
	sBet = "Column3";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}		
		
	sBet = "1_12";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}			
	
	sBet = "13_24";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}			
	
	sBet = "25_36";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}			
	
	// half board bets
	sBet = "1_18";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}			
	
	sBet = "19_36";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}		
	
	sBet = "odds";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}		
	
	sBet = "evens";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}			
	
	sBet = "red";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}			
	
	sBet = "black";
	sChipResourceName = "";
	// check each player position on this bet position, excluding the joining player
	for ( iPlayerPos = 1 ; iPlayerPos <= iNumPlayersAllowed ; iPlayerPos++ ) {
		sPlayerPos = IntToString(iPlayerPos);
		if ( GetLocalInt ( oDealer, sPlayerPos + "-" + sBet ) != 0 ) {
			sChipResourceName = sChipResourceName + sPlayerPos;
		}
	}
	if ( sChipResourceName != "" ) {  // bets exist on this position
		sChipResourceName = "br_chip_" + sChipResourceName;
		sComponentString = sComponentString + sChipPrefix + sBet + "=" + sChipResourceName + ";";
	} else {
		sHideString = sHideString + sChipPrefix + sBet + "=0;";			
	}		
	
	// trim the last ; and update all player guis
	if ( sComponentString != "" ) {
		sComponentString = GetStringLeft ( sComponentString, GetStringLength(sComponentString) - 1 );
	}
	if ( sHideString != "" ) {
		sHideString = GetStringLeft ( sHideString, GetStringLength(sHideString) - 1 );	
	}
	MPGUIUpdateMultiComponent ( oDealer, "br_roulette", sComponentString, "", sHideString );				
}


// check all player betting positions at sBettingPosition to find the right chip image

void UpdateChipImage ( object oDealer, string sBettingPosition ) {
	int i;
	string s, sBetPrefix, sChipResource;
	
	sChipResource = "";
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		sBetPrefix = s + "-";
		if ( GetLocalInt ( oDealer, sBetPrefix + sBettingPosition ) != 0 ) {
			sChipResource = sChipResource + s;
		}
	}
	
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		MPGUIUpdateTexture ( oDealer, "br_roulette", "roulette_chip_" + sBettingPosition, sChipResource );
	} else {
		MPGUIDisplayComponent ( oDealer, "br_roulette", "roulette_chip_" + sBettingPosition );
	}
}


// populate oPC's modbet pane for sBet

void PopulateModbetPane ( object oDealer, object oPC, int iPlayerPos, string sBet ) {
	int i, iCurrentPos;
	object oPlayer;
	string s, sBetPrefix, sName;
	
	iCurrentPos = 0;
	for ( i = 1 ; i <= iNumPlayersAllowed; i++ ) {
		if ( i != iPlayerPos ) {  // only evaluate other positions
			iCurrentPos = iCurrentPos + 1;
			
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				if ( iUsePCName == 1 ) {
					sName = GetName(oPlayer) + " - " + GetPCPlayerName(oPlayer);
				} else {
					sName = GetName(oPlayer);
				}
				s = IntToString(iCurrentPos);
				SetGUIObjectText ( oPC, "br_roulette", "modbet_player" + s, -1, sName ); 
				sBetPrefix = s + "-";
				SetGUIObjectText ( oPC, "br_roulette", "modbet_player" + s + "bet", -1, IntToString(GetLocalInt ( oDealer, sBetPrefix + sBet )) ); 		
			} else {
				s = IntToString(iCurrentPos);
				SetGUIObjectText ( oPC, "br_roulette", "modbet_player" + s, -1, sDefaultName ); 
				SetGUIObjectText ( oPC, "br_roulette", "modbet_player" + s + "bet", -1, "-" ); 				
			}
		}
	}
}


// generate and store the next spin's winning value

void GenerateNextSpinResult ( object oDealer ) {
	int iSpinResult;
	
	iSpinResult = Random(38) + 1;  // 37 stands for 00 and 38 for 0
	SetLocalInt ( oDealer, "iSpinResult", iSpinResult );	
}


// helper function for SpinWheel

int GetWheelNumber ( int iWheelPos, int iBallPos ) {
	int i, iResult;

	i = iWheelPos + iBallPos - 1;
	while ( i > 38 ) {
		i = i - 38;
	}
	
	if ( i == 1 ) {
		iResult = 27;
	} else if ( i == 2 ) {
	 	iResult = 10;
	} else if ( i == 3 ) {
	 	iResult = 25;
	} else if ( i == 4 ) {
	 	iResult = 29;
	} else if ( i == 5 ) {
	 	iResult = 12;
	} else if ( i == 6 ) {
	 	iResult = 8;
	} else if ( i == 7 ) {
	 	iResult = 19;
	} else if ( i == 8 ) {
	 	iResult = 31;
	} else if ( i == 9 ) {
	 	iResult = 18;
	} else if ( i == 10 ) {
	 	iResult = 6;
	} else if ( i == 11 ) {
	 	iResult = 21;
	} else if ( i == 12 ) {
	 	iResult = 33;
	} else if ( i == 13 ) {
	 	iResult = 16;
	} else if ( i == 14 ) {
	 	iResult = 4;
	} else if ( i == 15 ) {
	 	iResult = 23;
	} else if ( i == 16 ) {
	 	iResult = 35;
	} else if ( i == 17 ) {
	 	iResult = 14;
	} else if ( i == 18 ) {
	 	iResult = 2;
	} else if ( i == 19 ) {
	 	iResult = 38;  // 0
	} else if ( i == 20 ) {
	 	iResult = 28;
	} else if ( i == 21 ) {
	 	iResult = 9;
	} else if ( i == 22 ) {
	 	iResult = 26;
	} else if ( i == 23 ) {
	 	iResult = 30;
	} else if ( i == 24 ) {
	 	iResult = 11;
	} else if ( i == 25 ) {
	 	iResult = 7;
	} else if ( i == 26 ) {
	 	iResult = 20;
	} else if ( i == 27 ) {
	 	iResult = 32;
	} else if ( i == 28 ) {
	 	iResult = 17;
	} else if ( i == 29 ) {
	 	iResult = 5;
	} else if ( i == 30 ) {
	 	iResult = 22;
	} else if ( i == 31 ) {
	 	iResult = 34;
	} else if ( i == 32 ) {
	 	iResult = 15;
	} else if ( i == 33 ) {
	 	iResult = 3;
	} else if ( i == 34 ) {
	 	iResult = 24;
	} else if ( i == 35 ) {
	 	iResult = 36;
	} else if ( i == 36 ) {
	 	iResult = 13;
	} else if ( i == 37 ) {
	 	iResult = 1;
	} else if ( i == 38 ) {
	 	iResult = 37;  // 00
	}

	return iResult;
}


// animate the wheel for players

void SpinWheel ( object oDealer, int iWheelPos, int iBallPos, int iIteration, int iStopWheel = 0 ) {
	int i, iSpinResult;
	string sComponentString, sVarName;
	
	MPGUIDisplayComponent ( oDealer, "br_roulette", "roulette_wheel_pane", 1 );
	if ( iStopWheel == 1 ) {  // number found, spin the wheel off a few more times
		// hide the currently displayed wheel and ball
		sVarName = "roulette_wheel_" + IntToString(iWheelPos);
		sComponentString = sVarName + "=0;";
		sVarName = "roulette_ball_" + IntToString(iBallPos);
		sComponentString = sComponentString + sVarName + "=0;";		
	
		// move wheel and ball to next position
		if ( iWheelPos == 38 ) {
			iWheelPos = 1;
		} else {
			iWheelPos = iWheelPos + 1;
		}
		if ( iBallPos == 1 ) {
			iBallPos = 38;
		} else {
			iBallPos = iBallPos - 1;
		}
		sVarName = "roulette_wheel_" + IntToString(iWheelPos);
		sComponentString = sComponentString + sVarName + "=1;";
		sVarName = "roulette_ball_" + IntToString(iBallPos);
		sComponentString = sComponentString +  sVarName + "=1";				
		MPGUIUpdateMultiComponent ( oDealer, "br_roulette", "", "", sComponentString );	

		if ( iIteration == 0 ) {
			DelayCommand ( fSpinDelay * 5, SpinWheel ( oDealer, iWheelPos, iBallPos, iIteration, 2 ) );		
		} else {
			DelayCommand ( fSpinDelay * 5, SpinWheel ( oDealer, iWheelPos, iBallPos, iIteration - 1, 1 ) );		
		}		
	} else if ( iStopWheel == 2 ) {  // number found, end wheel spin
		sComponentString = "roulette_wheel_pane=0;roulette_wheel_frame=0;roulette_wheel_center=0;";
		sComponentString = sComponentString + "roulette_wheel_" + IntToString(iWheelPos) + "=0;";
		sComponentString = sComponentString + "roulette_ball_" + IntToString(iBallPos) + "=0;";		
		DelayCommand ( 2.5, MPGUIUpdateMultiComponent ( oDealer, "br_roulette", "", "", sComponentString ) );
		DelayCommand ( 2.5, EvaluateSpinResult(oDealer) );
	} else if ( iIteration == 0 ) {  // first iteration, set up board
		sComponentString = "roulette_wheel_frame=1;roulette_wheel_center=1;";
		sComponentString = sComponentString + "roulette_wheel_" + IntToString(iWheelPos) + "=1;";
		sComponentString = sComponentString + "roulette_ball_" + IntToString(iBallPos) + "=1;";		
		MPGUIUpdateMultiComponent ( oDealer, "br_roulette", "", "", sComponentString );
		
		// set up next spin frame
		DelayCommand ( fSpinDelay, SpinWheel ( oDealer, iWheelPos, iBallPos, 1 ) );		
	} else if ( iIteration <= iMinIterations / 3 ) {  // fastest spin rate
		// hide the currently displayed wheel and ball
		sVarName = "roulette_wheel_" + IntToString(iWheelPos);
		sComponentString = sVarName + "=0;";
		sVarName = "roulette_ball_" + IntToString(iBallPos);
		sComponentString = sComponentString + sVarName + "=0;";		
	
		// move wheel and ball to next position
		if ( iWheelPos == 38 ) {
			iWheelPos = 1;
		} else {
			iWheelPos = iWheelPos + 1;
		}
		if ( iBallPos == 38 ) {
			iBallPos = 1;
		} else {
			iBallPos = iBallPos + 1;
		}
		sVarName = "roulette_wheel_" + IntToString(iWheelPos);
		sComponentString = sComponentString + sVarName + "=1;";
		sVarName = "roulette_ball_" + IntToString(iBallPos);
		sComponentString = sComponentString + sVarName + "=1";				
		MPGUIUpdateMultiComponent ( oDealer, "br_roulette", "", "", sComponentString );	

		DelayCommand ( fSpinDelay, SpinWheel ( oDealer, iWheelPos, iBallPos, iIteration + 1 ) );				
	} else if ( iIteration < ( ( iMinIterations / 3 ) * 2 ) ) {  // first slower spin rate
		// hide the currently displayed wheel and ball
		sVarName = "roulette_wheel_" + IntToString(iWheelPos);
		sComponentString = sVarName + "=0;";
		sVarName = "roulette_ball_" + IntToString(iBallPos);
		sComponentString = sComponentString + sVarName + "=0;";		
	
		// move wheel and ball to next position
		if ( iWheelPos == 38 ) {
			iWheelPos = 1;
		} else {
			iWheelPos = iWheelPos + 1;
		}
		i = Random(3) - 1;  // give the ball some bounce
		iBallPos = iBallPos + i;
		if ( iBallPos > 38 ) {
			iBallPos = iBallPos - 38;
		} else if ( iBallPos < 1 ) {
			iBallPos = iBallPos + 38;
		} 
		sVarName = "roulette_wheel_" + IntToString(iWheelPos);
		sComponentString = sComponentString + sVarName + "=1;";
		sVarName = "roulette_ball_" + IntToString(iBallPos);
		sComponentString = sComponentString + sVarName + "=1";				
		MPGUIUpdateMultiComponent ( oDealer, "br_roulette", "", "", sComponentString );	

		DelayCommand ( fSpinDelay * 2, SpinWheel ( oDealer, iWheelPos, iBallPos, iIteration + 1 ) );
	} else if ( iIteration <= iMinIterations ) {  // second slower spin rate
		// hide the currently displayed wheel and ball
		sVarName = "roulette_wheel_" + IntToString(iWheelPos);
		sComponentString = sVarName + "=0;";
		sVarName = "roulette_ball_" + IntToString(iBallPos);
		sComponentString = sComponentString + sVarName + "=0;";		
	
		// move wheel and ball to next position
		if ( iWheelPos == 38 ) {
			iWheelPos = 1;
		} else {
			iWheelPos = iWheelPos + 1;
		}
		i = Random(3) - 1;  // give the ball some bounce
		iBallPos = iBallPos + i;
		if ( iBallPos > 38 ) {
			iBallPos = iBallPos - 38;
		} else if ( iBallPos < 1 ) {
			iBallPos = iBallPos + 38;
		} 
		sVarName = "roulette_wheel_" + IntToString(iWheelPos);
		sComponentString = sComponentString + sVarName + "=1;";
		sVarName = "roulette_ball_" + IntToString(iBallPos);
		sComponentString = sComponentString + sVarName + "=1";				
		MPGUIUpdateMultiComponent ( oDealer, "br_roulette", "", "", sComponentString );	

		DelayCommand ( fSpinDelay * 3, SpinWheel ( oDealer, iWheelPos, iBallPos, iIteration + 1 ) );	
	} else if ( iIteration > iMinIterations ) {  // find the number
		// hide the currently displayed wheel and ball
		sVarName = "roulette_wheel_" + IntToString(iWheelPos);
		sComponentString = sVarName + "=0;";
		sVarName = "roulette_ball_" + IntToString(iBallPos);
		sComponentString = sComponentString + sVarName + "=0;";		
	
		// move wheel and ball to next position
		if ( iWheelPos == 38 ) {
			iWheelPos = 1;
		} else {
			iWheelPos = iWheelPos + 1;
		}
		
		// increment to next ball frame and check to see if the result slot has been reached
		iSpinResult = GetLocalInt ( oDealer, "iSpinResult" );
		if ( GetWheelNumber ( iWheelPos, iBallPos ) == iSpinResult ) {
			DelayCommand ( fSpinDelay * 4, SpinWheel ( oDealer, iWheelPos, iBallPos, Random(5) + 4, 1 ) );							
		} else if ( GetWheelNumber ( iWheelPos, iBallPos + 1 ) == iSpinResult ) {
			if ( iBallPos == 38 ) {
				iBallPos = 1;
			} else {
				iBallPos = iBallPos + 1;
			}		
			DelayCommand ( fSpinDelay * 4, SpinWheel ( oDealer, iWheelPos, iBallPos, Random(5) + 4, 1 ) );	
		} else if ( GetWheelNumber ( iWheelPos, iBallPos + 2 ) == iSpinResult ) {
			iBallPos = iBallPos + 2;
			if ( iBallPos > 38 ) {
				iBallPos = iBallPos - 38;
			}
			DelayCommand ( fSpinDelay * 4, SpinWheel ( oDealer, iWheelPos, iBallPos, Random(5) + 4, 1 ) );							
		} else {
			// result not reached yet
			if ( iBallPos == 38 ) {
				iBallPos = 1;
			} else {
				iBallPos = iBallPos + 1;
			}
		`	DelayCommand ( fSpinDelay * 4, SpinWheel ( oDealer, iWheelPos, iBallPos, iIteration ) );			
		}
		sVarName = "roulette_wheel_" + IntToString(iWheelPos);
		sComponentString = sComponentString + sVarName + "=1;";
		sVarName = "roulette_ball_" + IntToString(iBallPos);
		sComponentString = sComponentString + sVarName + "=1";				
		MPGUIUpdateMultiComponent ( oDealer, "br_roulette", "", "", sComponentString );		
	}
}


// helper function for EvaluateSpinResult

// returns the colour of a number in a string, "red" or "black"
// 00 and 0 should be passed in as inumber 37 and 38, and return empty strings

string GetBoardNumberColour ( int iNumber, int iCapitalize = 0 ) {
	string sResult;

	if ( iCapitalize == 0 ) {
		switch ( iNumber ) {
			case 1:
				sResult = "red";
				break;
			case 2:
				sResult = "black";		
				break;
			case 3:
				sResult = "red";		
				break;
			case 4:
				sResult = "black";		
				break;
			case 5:
				sResult = "red";
				break;
			case 6:
				sResult = "black";		
				break;
			case 7:
				sResult = "red";		
				break;
			case 8:
				sResult = "black";		
				break;					
			case 9:
				sResult = "red";		
				break;				
			case 10:
				sResult = "black";		
				break;				
			case 11:
				sResult = "black";
				break;
			case 12:
				sResult = "red";		
				break;
			case 13:
				sResult = "black";		
				break;
			case 14:
				sResult = "red";		
				break;
			case 15:
				sResult = "black";
				break;
			case 16:
				sResult = "red";		
				break;
			case 17:
				sResult = "black";		
				break;
			case 18:
				sResult = "red";		
				break;					
			case 19:
				sResult = "red";		
				break;		
			case 20:
				sResult = "black";		
				break;					
			case 21:
				sResult = "red";
				break;
			case 22:
				sResult = "black";		
				break;
			case 23:
				sResult = "red";		
				break;
			case 24:
				sResult = "black";		
				break;
			case 25:
				sResult = "red";
				break;
			case 26:
				sResult = "black";		
				break;
			case 27:
				sResult = "red";		
				break;
			case 28:
				sResult = "black";		
				break;					
			case 29:
				sResult = "black";		
				break;				
			case 30:
				sResult = "red";		
				break;
			case 31:
				sResult = "black";
				break;
			case 32:
				sResult = "red";		
				break;
			case 33:
				sResult = "black";		
				break;
			case 34:
				sResult = "red";		
				break;
			case 35:
				sResult = "black";
				break;
			case 36:
				sResult = "red";		
				break;											
		}
	} else {
		switch ( iNumber ) {
			case 1:
				sResult = "Red";
				break;
			case 2:
				sResult = "Black";		
				break;
			case 3:
				sResult = "Red";		
				break;
			case 4:
				sResult = "Black";		
				break;
			case 5:
				sResult = "Red";
				break;
			case 6:
				sResult = "Black";		
				break;
			case 7:
				sResult = "Red";		
				break;
			case 8:
				sResult = "Black";		
				break;					
			case 9:
				sResult = "Red";		
				break;				
			case 10:
				sResult = "Black";		
				break;				
			case 11:
				sResult = "Black";
				break;
			case 12:
				sResult = "Red";		
				break;
			case 13:
				sResult = "Black";		
				break;
			case 14:
				sResult = "Red";		
				break;
			case 15:
				sResult = "Black";
				break;
			case 16:
				sResult = "Red";		
				break;
			case 17:
				sResult = "Black";		
				break;
			case 18:
				sResult = "Red";		
				break;					
			case 19:
				sResult = "Red";		
				break;		
			case 20:
				sResult = "Black";		
				break;					
			case 21:
				sResult = "Red";
				break;
			case 22:
				sResult = "Black";		
				break;
			case 23:
				sResult = "Red";		
				break;
			case 24:
				sResult = "Black";		
				break;
			case 25:
				sResult = "Red";
				break;
			case 26:
				sResult = "Black";		
				break;
			case 27:
				sResult = "Red";		
				break;
			case 28:
				sResult = "Black";		
				break;					
			case 29:
				sResult = "Black";		
				break;				
			case 30:
				sResult = "Red";		
				break;
			case 31:
				sResult = "Black";
				break;
			case 32:
				sResult = "Red";		
				break;
			case 33:
				sResult = "Black";		
				break;
			case 34:
				sResult = "Red";		
				break;
			case 35:
				sResult = "Black";
				break;
			case 36:
				sResult = "Red";		
				break;											
		}	
	}
	
	return sResult;
}


// process the winning value against player bets

void EvaluateSpinResult ( object oDealer ) {
	int i, iGold, iGoldPos, iGoldTotal, iPayoutLocal, iPlayerBet, iRoundGoldLostModifier, iRoundGoldWon, iSpinResult, iOffsetVal;
	object oPC;
	string s, sBet, sComponentString, sBetPrefix, sSpinMsg, sVarName;
	
	// play coins sound
	AssignCommand ( oDealer, PlaySound("it_chains_drop1") );
		
	// get the winning result and create a winning message
	iSpinResult = GetLocalInt ( oDealer, "iSpinResult" );
	if ( iSpinResult == 37 ) {
		sSpinMsg = "00! The spin is double zero!";
	} else if ( iSpinResult == 38 ) {
		sSpinMsg = "0! The spin is zero!";
	} else {
		sSpinMsg = IntToString(iSpinResult);
		sSpinMsg =  GetBoardNumberColour ( iSpinResult, 1 ) + " " + sSpinMsg + "! The spin is " + GetBoardNumberColour(iSpinResult) + " " + sSpinMsg + "!";			
	} 	
	
	// check each player position for a human player
	sComponentString = "";	
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) { 
			// human player found, set up player object and starting payout
			oPC = GetLocalObject ( oDealer, "oPlayer" + s );	
			
			// disable ready background
			sComponentString = sComponentString + "player" + s +"bg=0;";
			
			// send winning message to player
			SendMessageToPC ( oPC, "Roulette: " + sSpinMsg );
			
			sBetPrefix = s + "-";
			iGoldTotal = 0;
			iRoundGoldLostModifier = 0;
			iRoundGoldWon = 0;
						
			// check straight bets
			iPayoutLocal = GetLocalInt ( oDealer, "iStraightPayout" );
			if ( iPayoutLocal == 0 ) {  // check for bet return override
				iPayoutLocal = iStraightPayout;
			}
			
			sBet = sBetPrefix + IntToString(iSpinResult);			
			iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
			iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
			iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
			iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
			iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
			iGoldTotal = iGoldTotal + iGoldPos;			
			
			// check split bet
			iPayoutLocal = GetLocalInt ( oDealer, "iSplitPayout" );			
			if ( iPayoutLocal == 0 ) {  // check for bet return override
				iPayoutLocal = iSplitPayout;
			}
			
			if ( ( iSpinResult == 37 ) || ( iSpinResult == 38 ) ) {  // 0, 00 split
				sBet = sBetPrefix + "38_37";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;
			} else {
				iOffsetVal = iSpinResult - 3;  // vertical split, iSpinResult on bottom
				sBet = sBetPrefix + IntToString(iOffsetVal) + "_" + IntToString(iSpinResult);
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;	
				
				iOffsetVal = iSpinResult + 3;  // vertical split, iSpinResult on top
				sBet = sBetPrefix + IntToString(iSpinResult) + "_" + IntToString(iOffsetVal);
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;	
				
				iOffsetVal = iSpinResult - 1;  // horizontal split, iSpinResult on left
				sBet = sBetPrefix + IntToString(iOffsetVal) + "_" + IntToString(iSpinResult);
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;	
				
				iOffsetVal = iSpinResult + 1;  // horizontal split, iSpinResult on right
				sBet = sBetPrefix + IntToString(iSpinResult) + "_" + IntToString(iOffsetVal);
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;	
			}			
			
			// check street bet
			iPayoutLocal = GetLocalInt ( oDealer, "iStreetPayout" );
			if ( iPayoutLocal == 0 ) {
				iPayoutLocal = iStreetPayout;
			}				
			
			if ( iSpinResult == 38 ) {  // 0-1-2 bet
				sBet = sBetPrefix + "38_1_2";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;	
			} else if ( iSpinResult == 37 ) {  // 00-2-3 bet
				sBet = sBetPrefix + "37_2_3";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;			
			} else {
				iOffsetVal = iSpinResult;
				while ( ( iOffsetVal % 3 ) != 1 ) {  // find the starting number of the street
					iOffsetVal--;
				}
				sBet = sBetPrefix + IntToString(iOffsetVal) + "_" + IntToString ( iOffsetVal + 1 ) + "_" + IntToString ( iOffsetVal + 2 );
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;				
			}
			
			// check corner bet
			iPayoutLocal = GetLocalInt ( oDealer, "iCornerPayout" );
			if ( iPayoutLocal == 0 ) {
				iPayoutLocal = iCornerPayout;
			}
						
			iOffsetVal = iSpinResult - 4;  // check the top left square corner bet
			sBet = sBetPrefix + IntToString(iOffsetVal ) + "_" + IntToString ( iOffsetVal  + 1 ) + "_" + IntToString ( iOffsetVal  +3 ) + "_"+ IntToString ( iOffsetVal  + 4 );
			iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
			iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
			iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
			iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
			iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
			iGoldTotal = iGoldTotal + iGoldPos;		
				
			iOffsetVal = iSpinResult - 3;  // check the top right square corner bet
			sBet = sBetPrefix + IntToString(iOffsetVal ) + "_" + IntToString ( iOffsetVal  + 1 ) + "_" + IntToString ( iOffsetVal  +3 ) + "_"+ IntToString ( iOffsetVal  + 4 );
			iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
			iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
			iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
			iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
			iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
			iGoldTotal = iGoldTotal + iGoldPos;		
			
			iOffsetVal = iSpinResult - 1;  // check the bottom left square corner bet
			sBet = sBetPrefix + IntToString(iOffsetVal ) + "_" + IntToString ( iOffsetVal  + 1 ) + "_" + IntToString ( iOffsetVal  +3 ) + "_"+ IntToString ( iOffsetVal  + 4 );
			iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
			iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
			iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
			iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
			iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
			iGoldTotal = iGoldTotal + iGoldPos;	
			
			iOffsetVal = iSpinResult;  // check the bottom right square corner bet
			sBet = sBetPrefix + IntToString(iOffsetVal ) + "_" + IntToString ( iOffsetVal  + 1 ) + "_" + IntToString ( iOffsetVal  +3 ) + "_"+ IntToString ( iOffsetVal  + 4 );
			iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
			iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
			iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
			iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
			iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
			iGoldTotal = iGoldTotal + iGoldPos;	
	
			// check five number bet
			if ( ( iSpinResult == 1 ) || ( iSpinResult == 2 ) || ( iSpinResult == 3 ) || ( iSpinResult == 37 ) || ( iSpinResult == 38 ) ) {
				iPayoutLocal = GetLocalInt ( oDealer, "iFivePayout" );
				if ( iPayoutLocal == 0 ) {
					iPayoutLocal = iFivePayout;
				}				
			
				sBet = sBetPrefix + "38_37_1_2_3";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;	
			}			
	
			// check six line bet
			iPayoutLocal = GetLocalInt ( oDealer, "iSixLinePayout" );
			if ( iPayoutLocal == 0 ) {
				iPayoutLocal = iSixLinePayout;
			}			
			
			iOffsetVal = iSpinResult;  // check block where iSpinResult is in the top row
			while ( ( iOffsetVal % 3 ) != 1 ) {
				iOffsetVal--;
			}
			sBet = sBetPrefix + IntToString(iOffsetVal) + "_" + IntToString ( iOffsetVal + 1 ) + "_" + IntToString ( iOffsetVal + 2 ) + "_" + IntToString ( iOffsetVal + 3 ) + "_" + IntToString ( iOffsetVal + 4 ) + "_" + IntToString ( iOffsetVal + 5 );
			iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
			iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
			iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
			iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
			iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
			iGoldTotal = iGoldTotal + iGoldPos;	
			
			iOffsetVal = iOffsetVal - 3;  // check block where iSpinResult is in the bottom row
			sBet = sBetPrefix + IntToString(iOffsetVal) + "_" + IntToString ( iOffsetVal + 1 ) + "_" + IntToString ( iOffsetVal + 2 ) + "_" + IntToString ( iOffsetVal + 3 ) + "_" + IntToString ( iOffsetVal + 4 ) + "_" + IntToString ( iOffsetVal + 5 );
			iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
			iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
			iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
			iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
			iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
			iGoldTotal = iGoldTotal + iGoldPos;					
	
			// check third board bets
			iPayoutLocal = GetLocalInt ( oDealer, "iThirdPayout" );
			if ( iPayoutLocal == 0 ) {
				iPayoutLocal = iThirdPayout;
			}		
				
			// check dozens bets
			if ( iSpinResult <= 12 ) {
				sBet = sBetPrefix + "1_12";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;						
			} else if ( iSpinResult <= 24 ) {
				sBet = sBetPrefix + "13_24";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;		
			} else {
				sBet = sBetPrefix + "25_36";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;			
			}
			
			// check columns bets
			iOffsetVal = iSpinResult % 3;
			if ( iOffsetVal == 1 ) {  // first column
				sBet = sBetPrefix + "Column1";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;	
			} else if ( iOffsetVal == 2 ) {  // second column
				sBet = sBetPrefix + "Column2";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;		
			} else {
				sBet = sBetPrefix + "Column3";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;		
			}
			
			// check half bets
			iPayoutLocal = GetLocalInt ( oDealer, "iHalfPayout" );
			if ( iPayoutLocal == 0 ) {
				iPayoutLocal = iHalfPayout;
			}			
			
			// check first or second half
			if ( iSpinResult <= 18 ) {
				sBet = sBetPrefix + "1_18";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;		
			} else {
				sBet = sBetPrefix + "19_36";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;			
			}
			
			// check odds or evens
			if ( iSpinResult %2 == 1 ) {  // odds
				sBet = sBetPrefix + "odds";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;			
			} else {  // evens
				sBet = sBetPrefix + "evens";
				iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position
				iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
				iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
				iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
				iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
				iGoldTotal = iGoldTotal + iGoldPos;		
			}
			
			// check red or black
			sBet = sBetPrefix + GetBoardNumberColour(iSpinResult);
			iPlayerBet = GetLocalInt ( oDealer, sBet );  // get the player's bet value on this position	
			iRoundGoldLostModifier = iRoundGoldLostModifier + iPlayerBet;  // deduct this amount from a player's losses this round
			iGoldPos = iPlayerBet * iPayoutLocal;  // determine the winnings of this position
			iRoundGoldWon = iRoundGoldWon + iGoldPos;  // add the winnings to the player gold won tally
			iGoldPos = iGoldPos + iPlayerBet;  // add the original position stake to the amount of gold given to player
			iGoldTotal = iGoldTotal + iGoldPos;	
				
			// check if the player won anything
			iPlayerBet = GetLocalInt ( oDealer, "iPlayer" + s +"CurrentPlacedBet" );
			if ( iGoldTotal > 0 ) {
				// update player gold
				iGold = GetGold(oPC);
				GiveGoldToCreature ( oPC, iGoldTotal, TRUE );
				iGold = iGold + iGoldTotal;
				SetGUIObjectText ( oPC, "br_roulette", "roulette_gold", -1, IntToString(iGold) );				
				
				// subtract winning bet stakes from total gold lost
				iPlayerBet = iPlayerBet - iRoundGoldLostModifier;
				
				// update gold won stat
				sVarName = "iPlayer" + s + "GoldWon";
				SetLocalInt ( oDealer, sVarName, GetLocalInt ( oDealer, sVarName ) + iRoundGoldWon );
			}
			
			// update gold lost stat
			if ( iPlayerBet != 0 ) {
				sVarName = "iPlayer" + s + "GoldLost";
				SetLocalInt ( oDealer, sVarName, GetLocalInt ( oDealer, sVarName ) + iPlayerBet );			
			}		
		}			
	}
	
	// trim the last ; and update all player guis
	sComponentString = GetStringLeft ( sComponentString, GetStringLength(sComponentString) - 1 );
	MPGUIUpdateMultiComponent ( oDealer, "br_roulette", "", "", sComponentString );	

	// prep next round
	EndRoundCleanup(oDealer);	
}


// prepare the game for the next round of betting

void EndRoundCleanup ( object oDealer ) {
	int i, iWaitList, j;
	object oPC;
	string s, sComponentString;
	
	SetLocalInt ( oDealer, "iInPlay", 0 );
	SetLocalInt ( oDealer, "iNumReadyPlayers", 0 );
	
	sComponentString = "";
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
			oPC = GetLocalObject ( oDealer, "oPlayer" + s );
			
			// set state vars
			SetLocalInt ( oDealer, "i" + s + "isReady", 0 );			
			SetLocalInt ( oDealer, "iPlayer" + s + "CurrentPlacedBet", 0 );
			
			// clear the player's betting positions and chip graphics
			ClearPlayerBettingPositions ( oDealer, i );
			ClearGUIChipGraphics ( oDealer, oPC );
			
			// enable player buttons
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_spin", FALSE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_clearbets", FALSE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_payouts", FALSE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_quit", FALSE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_betplus", FALSE );
			SetGUIObjectDisabled ( oPC, "br_roulette", "roulette_button_betminus", FALSE );			
		
			// zero player placed gold display
			sComponentString = sComponentString + "player" + s + "bet=0;";
		}
	}
	
	// trim the last ; and update all player guis
	sComponentString = GetStringLeft ( sComponentString, GetStringLength(sComponentString) - 1 );
	MPGUIUpdateMultiComponent ( oDealer, "br_roulette", "", sComponentString, "" );	
	
	// add any waitlisted players to game
	iWaitList = GetLocalInt ( oDealer, "iWaitList" );
	if ( iWaitList != 0 ) {
		for ( i = 1 ; i <= iWaitList ; i++ ) {
			s = IntToString(i);
			oPC = GetLocalObject ( oDealer, "oWaitList" + s );
			SetUpNewPlayer ( oDealer, oPC );
		}
		UpdateGUIPlayerList(oDealer);
		SetLocalInt ( oDealer, "iWaitList", 0 );		
	}	
	
	// set idle timer
	if ( ( iIdleTimer != 0 ) && ( GetLocalInt ( oDealer, "iNumPlayers" ) > 1 ) ) {
		if ( GetLocalInt ( oDealer, "iEndRoundIdleTimerActive" ) == 0 ) {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );	
			MPGUIDisplayComponent ( oDealer, "br_roulette", "timerpane", 1 );		
			EndRoundIdleTimer(oDealer);
		} else {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );			
		}
	}
}


// player idle timer

void EndRoundIdleTimer ( object oDealer ) {
	int i, iBallPos, iCurrentBet, iGold, iHalfIdleTimer, iNumPlayers, iTimer, iWheelPos, j, k;
	object oPlayer;
	string s, sComponentString, sInt, sK, sVarName;
	
	// terminate if a round has started
	if ( GetLocalInt ( oDealer, "iInPlay" ) == 1 ) {
		SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 0 );	
		MPGUIDisplayComponent ( oDealer, "br_roulette", "timerpane" );			
		return;
	}
	
	iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
	if ( iNumPlayers == 1 ) {
		SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 0 );	
		MPGUIDisplayComponent ( oDealer, "br_roulette", "timerpane" );			
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
				SetGUIObjectHidden ( oPlayer, "br_roulette", "timerpane", TRUE );	
							
				// clear the table if any bets exist
				sVarName = "iPlayer" + s + "CurrentPlacedBet";
				iCurrentBet = GetLocalInt ( oDealer, sVarName );
				if ( iCurrentBet != 0 ) {
					AssignCommand ( oDealer, PlaySound("it_pickup") );
					ClearPlayerBettingPositions ( oDealer, StringToInt(s) );
					iGold = GetGold(oPlayer);
					GiveGoldToCreature ( oPlayer, iCurrentBet, FALSE );
					iGold = iGold + iCurrentBet;
					SetGUIObjectText ( oPlayer, "br_roulette", "roulette_placedbet", -1, "0" );				
				}
				SetGUIObjectText ( oPlayer, "br_roulette", "roulette_gold", -1, "0" );				
				
				// reset table graphics
				SyncGUIBetPositions(oDealer);	
				
				for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
					sVarName = "player" + IntToString(i);
					SetGUIObjectText ( oPlayer, "br_roulette", sVarName, -1, "" );
					SetGUIObjectText ( oPlayer, "br_roulette", sVarName + "bet", -1, "" );
					SetGUIObjectHidden ( oPlayer, "br_roulette", sVarName +"bg", TRUE );
				}				
				
				// disable all buttons
				SetGUIObjectDisabled ( oPlayer, "br_roulette", "roulette_button_spin", TRUE);
				SetGUIObjectDisabled ( oPlayer, "br_roulette", "roulette_button_clearbets", TRUE);
				SetGUIObjectDisabled ( oPlayer, "br_roulette", "roulette_button_payouts", TRUE);
				SetGUIObjectDisabled ( oPlayer, "br_roulette", "roulette_button_quit", TRUE);
				SetGUIObjectDisabled ( oPlayer, "br_roulette", "roulette_button_betplus", TRUE);
				SetGUIObjectDisabled ( oPlayer, "br_roulette", "roulette_button_betminus", TRUE);					
				SetGUIObjectText ( oPlayer, "br_roulette", "notice_pane_text", -1, "Please wait for the betting round to begin" );
				SetGUIObjectHidden ( oPlayer, "br_roulette", "notice_pane_frame", FALSE );				
				SetGUIObjectHidden ( oPlayer, "br_roulette", "notice_pane", FALSE );				
				
				// close gui
				CloseGUIScreen ( oPlayer, "br_roulette" );	
					
				// clear player data from dealer
				SetLocalInt ( oDealer, "i" + s + "isPlayer", 0 );
				SetCasinoStatsArrayPlayerStat ( oPlayer, "Roulette", "Win", GetLocalInt ( oDealer, "iPlayer" + s + "GoldWon" ) );
				SetCasinoStatsArrayPlayerStat ( oPlayer, "Roulette", "Lose", GetLocalInt ( oDealer, "iPlayer" + s + "GoldLost" ) );		
				SetCasinoStatsArrayPlayerStat ( oPlayer, "Roulette", "Time", GetPlayerTimePlayed ( oDealer, StringToInt(s) ) );
				iNumPlayers = iNumPlayers - 1;					
				sComponentString = "player" + s + "name1=;player" + s + "name2=" + sDefaultName + ";player" + s + "bet=-";
				MPGUIUpdateMultiComponent ( oDealer, "br_roulette", "", sComponentString, "" );
				
				SendMessageToPC ( oPlayer, "Roulette: You have been removed from the table for inactivity." );				
			}
		}	
		SetLocalInt ( oDealer, "iNumPlayers", iNumPlayers );
		MPMessageAllPlayers ( oDealer, "Roulette: The table has been cleared of idle players." );		
		MPGUIDisplayComponent ( oDealer, "br_roulette", "timerpane" );		
		SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 0 );		
		
		// start game
		AssignCommand ( oDealer, PlaySound("as_cv_crank1") );				
		SetLocalInt ( oDealer, "iInPlay", 1 );	
				
		// generate results and start spin animation
		GenerateNextSpinResult(oDealer);
		iWheelPos = Random(38) + 1;
		iBallPos = Random(38) + 1;
		SpinWheel ( oDealer, iWheelPos, iBallPos, 0 );							
	} else {
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				// player is human and not readied up yet
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				SetGUIObjectText ( oPlayer, "br_roulette", "timerfield", -1, IntToString(iTimer) );
			}
		}
		
		// not counted down yet, iterate
		SetLocalInt ( oDealer, "iIdleTimer", iTimer - 1 );
		DelayCommand ( 1.0, EndRoundIdleTimer(oDealer) );		
	}	
}