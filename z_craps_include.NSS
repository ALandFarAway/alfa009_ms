// Black Rain 2009
//
// rule and setting definitions for craps
// some settings can be modified in-game by setting appropriate values on object running the game
// ex: to increase max bet set the int iMaxBet on sTag object, it will override the defined setting

#include "y_multiplayer_casino_lib"
#include "z_casino_stats_include"


// default betting variables, these can be changed in-game by overriding on dealer
const int iMaxBet = 1000;  // odds bets are not constrained by iMaxBet
const int iMinBet = 100;
const int iBetIncrement = 100;


// system variables
const int iIdleTimer = 30;  // amount of time to idle before forcing player action
const float fInitialDelay = 0.8;  // delay before rolling dice
const float fFinalDelay = 0.9;  // delay after rolling dice
const int iTotalFrames = 679;  // number of frames from left to right of dice track in gui
const int iStartFrameVariance = 20;  // starting position variance
const int iBaseFrameSkip = 30;  // base frame skip
const int iFrameSkipVariance = 15;  // frame skip variance
const float fBaseDelay = 0.04;  // base delay per iteration
const int iDelayVariance = 4;  // delay variance, each int represents a 0.01 increase in fBaseDelay
const int iBaseBounce = 4;  // base number of animation iterations after bounce
const int iBounceVariance = 6;  // bounce iterations variance
const int iBaseFrameSkipLoss = 10;  // base frame skip loss on bounce
const int iFrameSkipLossVariance = 10;  // variance frame skip loss on bounce
const string sDefaultName = "     -";  // default non-player slot name


// function prototypes
void SetUpNewPlayer ( object oDealer, object oPC );
void UpdateGUIPlayerList ( object oDealer );
void PopulateNewPlayerGUIBetPositions ( object oDealer, object oPC, int iCurrentPlayer );
void UpdateChipImage ( object oDealer, string sBettingPosition );
void PopulateModbetPane ( object oDealer, object oPC, int iPlayerPos, string sBet );
void ClearPlayerBettingPositions ( object oDealer, int iPlayerPos );
void ClearGUIChipGraphics ( object oDealer, object oPC );
void SetupRoll ( object oDealer );
void GenerateResults ( object oDealer );
void RollDie ( object oDealer, string sDieNumber );
void EvaluateResults ( object oDealer );
void EndRound ( object oDealer );
void EndRoundIdleTimer ( object oDealer );


// set a player up on the dealer object
void SetUpNewPlayer ( object oDealer, object oPC ) {
	int i, iMinBetLocal, iNumPlayers;
	string s, sVarName;		
	
	// increment number of players
	iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
	iNumPlayers = iNumPlayers + 1;
	SetLocalInt ( oDealer, "iNumPlayers", iNumPlayers );
	if ( iNumPlayers == 1 ) {
		SetLocalInt ( oDealer, "iRound", 0 );
	}	
	
	// message all current players if more than one player at table
	if ( iNumPlayers > 1 ) {
		MPMessageAllPlayers ( oDealer, "Craps: " + GetName(oPC) + " has joined this table." );
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
			SetGUIObjectText ( oPC, "br_craps", "playerpos", -1, s );
			SetGUIObjectText ( oPC, "br_craps", "dealertag", -1, GetTag(oDealer) );			
			
			// set up GUI visible elements
			SetGUIObjectText ( oPC, "br_craps", "craps_gold", -1, IntToString(GetGold(oPC)) );		
			iMinBetLocal = GetLocalInt ( oDealer, "iMinBet" );
			if ( iMinBetLocal == 0 ) {  // check for iMinBet local override
				iMinBetLocal = iMinBet;
			}
			SetGUIObjectText ( oPC, "br_craps", "craps_bet", -1, IntToString(iMinBetLocal) );
			SetLocalInt ( oDealer, sVarName + "CurrentBet", iMinBetLocal );
			SetLocalInt ( oDealer, sVarName + "CurrentPlacedBet", 0 );
			
			// disable wait notice pane and enable buttons
			SetGUIObjectHidden ( oPC, "br_craps", "notice_pane", TRUE );
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_shoot", FALSE );
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_bettypes", FALSE );
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_quit", FALSE );
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_betplus", FALSE );			
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_betminus", FALSE );
					
			// round display
			if ( GetLocalInt ( oDealer, "iRound" ) == 0 ) {
				SetGUIObjectText ( oPC, "br_craps", "craps_roundbanner1", -1, "Come Out" );
				SetGUIObjectText ( oPC, "br_craps", "craps_roundbanner2", -1, "Round" );			
			} else {
				SetGUIObjectText ( oPC, "br_craps", "craps_roundbanner1", -1, "Point:" );
				SetGUIObjectText ( oPC, "br_craps", "craps_roundbanner2", -1, IntToString(GetLocalInt ( oDealer, "iCurrentPoint" )) );				
			}
			
			PopulateNewPlayerGUIBetPositions ( oDealer, oPC, i );		
			break;
		}
	}
	
	// start idle timer if more than one player in
	if ( iIdleTimer != 0 ) {
		if ( ( iNumPlayers > 1 ) && ( GetLocalInt ( oDealer, "iEndRoundIdleTimerActive" ) == 0 ) ) {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );	
			MPGUIDisplayComponent ( oDealer, "br_craps", "timerpane", 1 );
			EndRoundIdleTimer(oDealer);		
		} else if ( ( iNumPlayers > 1 ) && ( GetLocalInt ( oDealer, "iEndRoundIdleTimerActive" ) != 0 ) ) {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );	
			SetGUIObjectHidden ( oPC, "br_craps", "timerpane", FALSE );		
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
	MPGUIUpdateMultiComponent ( oDealer, "br_craps", "", sComponentString, "" );
}


// populate a newly joined player's GUI with existing bets

void PopulateNewPlayerGUIBetPositions ( object oDealer, object oPC, int iCurrentPlayer ) {
	int i, iPlayerPos;
	string s, sBet, sChipPrefix, sChipResourceName, sPlayerPos, sVarName;
	
	if ( GetLocalInt ( oDealer, "iNumPlayer" ) == 1 ) {
		// first player to join table, skip this routine
		return;
	}
	
	sChipPrefix = "craps_chip_";
	
	// big 6 & 8
	sBet = "big6";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
	
	sBet = "big8";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}		
	
	// line bets
	sBet = "pass";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
		
	sBet = "dontpass";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
			
	sBet = "come";	
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
		
	sBet = "dontcome";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}		
	
	// hard ways
	sBet = "hard4";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
	
	sBet = "hard6";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
		
	sBet = "hard8";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
		
	sBet = "hard10";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
	
	// single roll bets	
	sBet = "hilo";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
	
	sBet = "acedeuce";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
		
	sBet = "snakeeyes";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
		
	sBet = "yo";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
		
	sBet = "boxcars";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
			
	sBet = "anyseven";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
		
	sBet = "anycraps";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
		
	sBet = "cande";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}	
		
	sBet = "field";
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
		SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
		SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
	}			
	
	// number bets, turn off puck
	for ( i = 4 ; i <= 10 ; i++ ) {
		s = IntToString(i);
		
		sBet = "placewin" + s;
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
			SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
		}		
		
		sBet = "placelose" + s;
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
			SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
		}	
				
		sBet = "buy" + s;
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
			SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
		}	
		
		sBet = "lay" + s;
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
			SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
		}		
				
		sBet = "come" + s;
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
			SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
		}	
			
		sBet = "comeodds" + s;
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
			SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
		}	
			
		sBet = "dontcome" + s;
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
			SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
		}	
			
		sBet = "dontcomeodds" + s;
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
			SetGUITexture ( oPC, "br_craps", sVarName, sChipResourceName );
			SetGUIObjectHidden ( oPC, "br_craps", sVarName, FALSE );
		}	
		
		if ( i == 6 ) {
			i++;
		}
	}
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
		MPGUIUpdateTexture ( oDealer, "br_craps", "craps_chip_" + sBettingPosition, sChipResource );
	} else {
		MPGUIDisplayComponent ( oDealer, "br_craps", "craps_chip_" + sBettingPosition );
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
				SetGUIObjectText ( oPC, "br_craps", "modbet_player" + s, -1, sName ); 
				sBetPrefix = s + "-";
				SetGUIObjectText ( oPC, "br_craps", "modbet_player" + s + "bet", -1, IntToString(GetLocalInt ( oDealer, sBetPrefix + sBet )) ); 		
			} else {
				s = IntToString(iCurrentPos);
				SetGUIObjectText ( oPC, "br_craps", "modbet_player" + s, -1, sDefaultName ); 
				SetGUIObjectText ( oPC, "br_craps", "modbet_player" + s + "bet", -1, "-" ); 				
			}
		}
	}
}


// clear all bets for one player

void ClearPlayerBettingPositions ( object oDealer, int iPlayerPos ) {
	int i, j;
	string s, sBet, sBetPrefix, sChipResource, sDisplayString, sHideString, sJ, sPrefix;
	
	sBetPrefix = IntToString(iPlayerPos) + "-";
	sDisplayString = "";
	sHideString = "";
	
	// big 6 & 8
	sBet = "big6";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}	
	
	sBet = "big8";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );		
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
		
	// line bets
	sBet = "pass";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );	
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
			
	sBet = "dontpass";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
				
	sBet = "come";	
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );	
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
			
	sBet = "dontcome";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );		
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
		
	// hard ways
	sBet = "hard4";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
		
	sBet = "hard6";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
			
	sBet = "hard8";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );	
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
			
	sBet = "hard10";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );	
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
		
	// single roll bets	
	sBet = "hilo";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );	
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
		
	sBet = "acedeuce";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
			
	sBet = "snakeeyes";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );	
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
			
	sBet = "yo";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
			
	sBet = "boxcars";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
				
	sBet = "anyseven";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
			
	sBet = "anycraps";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );	
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
			
	sBet = "cande";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
			
	sBet = "field";
	SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );			
	sChipResource = "";
	for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
		sJ = IntToString(j);
		sPrefix = sJ + "-";
		if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
			sChipResource = sChipResource + sJ;
		}
	}
	if ( sChipResource != "" ) {
		sChipResource = "br_chip_" + sChipResource;
		sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
	} else {
		sHideString = sHideString + "craps_chip_" + sBet + "=0;";
	}
		
	// number bets, turn off puck
	for ( i = 4 ; i <= 10 ; i++ ) {
		s = IntToString(i);
		
		sBet = "placewin" + s;
		SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );	
		sChipResource = "";
		for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
			sJ = IntToString(j);
			sPrefix = sJ + "-";
			if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
				sChipResource = sChipResource + sJ;
			}
		}
		if ( sChipResource != "" ) {
			sChipResource = "br_chip_" + sChipResource;
			sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
		} else {
			sHideString = sHideString + "craps_chip_" + sBet + "=0;";
		}		
		
		sBet = "placelose" + s;
		SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );	
		sChipResource = "";
		for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
			sJ = IntToString(j);
			sPrefix = sJ + "-";
			if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
				sChipResource = sChipResource + sJ;
			}
		}
		if ( sChipResource != "" ) {
			sChipResource = "br_chip_" + sChipResource;
			sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
		} else {
			sHideString = sHideString + "craps_chip_" + sBet + "=0;";
		}		
						
		sBet = "buy" + s;
		SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );	
		sChipResource = "";
		for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
			sJ = IntToString(j);
			sPrefix = sJ + "-";
			if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
				sChipResource = sChipResource + sJ;
			}
		}
		if ( sChipResource != "" ) {
			sChipResource = "br_chip_" + sChipResource;
			sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
		} else {
			sHideString = sHideString + "craps_chip_" + sBet + "=0;";
		}		
				
		sBet = "lay" + s;
		SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );		
		sChipResource = "";
		for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
			sJ = IntToString(j);
			sPrefix = sJ + "-";
			if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
				sChipResource = sChipResource + sJ;
			}
		}
		if ( sChipResource != "" ) {
			sChipResource = "br_chip_" + sChipResource;
			sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
		} else {
			sHideString = sHideString + "craps_chip_" + sBet + "=0;";
		}		
						
		sBet = "come" + s;
		SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );	
		sChipResource = "";
		for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
			sJ = IntToString(j);
			sPrefix = sJ + "-";
			if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
				sChipResource = sChipResource + sJ;
			}
		}
		if ( sChipResource != "" ) {
			sChipResource = "br_chip_" + sChipResource;
			sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
		} else {
			sHideString = sHideString + "craps_chip_" + sBet + "=0;";
		}		
					
		sBet = "comeodds" + s;
		SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );	
		sChipResource = "";
		for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
			sJ = IntToString(j);
			sPrefix = sJ + "-";
			if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
				sChipResource = sChipResource + sJ;
			}
		}
		if ( sChipResource != "" ) {
			sChipResource = "br_chip_" + sChipResource;
			sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
		} else {
			sHideString = sHideString + "craps_chip_" + sBet + "=0;";
		}		
					
		sBet = "dontcome" + s;
		SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );	
		sChipResource = "";
		for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
			sJ = IntToString(j);
			sPrefix = sJ + "-";
			if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
				sChipResource = sChipResource + sJ;
			}
		}
		if ( sChipResource != "" ) {
			sChipResource = "br_chip_" + sChipResource;
			sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
		} else {
			sHideString = sHideString + "craps_chip_" + sBet + "=0;";
		}		
					
		sBet = "dontcomeodds" + s;
		SetLocalInt ( oDealer, sBetPrefix + sBet, 0 );
		sChipResource = "";
		for ( j = 1 ; j <= iNumPlayersAllowed ; j++ ) {
			sJ = IntToString(j);
			sPrefix = sJ + "-";
			if ( GetLocalInt ( oDealer, sPrefix + sBet ) != 0 ) {
				sChipResource = sChipResource + sJ;
			}
		}
		if ( sChipResource != "" ) {
			sChipResource = "br_chip_" + sChipResource;
			sDisplayString = sDisplayString + "craps_chip_" + sBet + "=" + sChipResource + ";";
		} else {
			sHideString = sHideString + "craps_chip_" + sBet + "=0;";
		}		
				
		if ( i == 6 ) {
			i++;
		}
	}
	
	if ( sDisplayString != "" ) {
		sDisplayString = GetStringLeft ( sDisplayString, GetStringLength(sDisplayString) - 1 );
	} 	
	if ( sHideString != "" ) {
		sHideString = GetStringLeft ( sHideString, GetStringLength(sHideString) - 1 );
	} 		
	MPGUIUpdateMultiComponent ( oDealer, "br_craps", sDisplayString, "", sHideString );
}


// clear one player's table of chip graphics

void ClearGUIChipGraphics ( object oDealer, object oPC ) {
	int i;
	string s, sBet, sBetPrefix;
	
	sBetPrefix = "craps_chip_";
	
	// big 6 & 8
	sBet = "big6";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );
	
	sBet = "big8";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );		
	
	// line bets
	sBet = "pass";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );	
		
	sBet = "dontpass";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );
			
	sBet = "come";	
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );	
		
	sBet = "dontcome";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );		
	
	// hard ways
	sBet = "hard4";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );
	
	sBet = "hard6";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );
		
	sBet = "hard8";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );	
		
	sBet = "hard10";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );	
	
	// single roll bets	
	sBet = "hilo";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );	
	
	sBet = "acedeuce";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );
		
	sBet = "snakeeyes";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );	
		
	sBet = "yo";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );
		
	sBet = "boxcars";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );
			
	sBet = "anyseven";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );
		
	sBet = "anycraps";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );	
		
	sBet = "cande";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );
		
	sBet = "field";
	SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );			
	
	// number bets, turn off puck
	for ( i = 4 ; i <= 10 ; i++ ) {
		s = IntToString(i);
		
		sBet = "placewin" + s;
		SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );	
		
		sBet = "placelose" + s;
		SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );	
				
		sBet = "buy" + s;
		SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );	
		
		sBet = "lay" + s;
		SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );		
				
		sBet = "come" + s;
		SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );	
			
		sBet = "comeodds" + s;
		SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );	
			
		sBet = "dontcome" + s;
		SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );	
			
		sBet = "dontcomeodds" + s;
		SetGUIObjectHidden ( oPC, "br_craps", sBetPrefix + sBet, TRUE );
		
		if ( i == 6 ) {
			i++;
		}
	}
}


// set up a roll

void SetupRoll ( object oDealer ) {
	float f;
	int i;
	string s, sComponentString, sDie;

	SetLocalInt ( oDealer, "iInPlay", 1 );
	
	// set up die 1
	i = Random(iStartFrameVariance);
	s = "craps_1_" + IntToString(i) + "a";
	SetLocalInt ( oDealer, "iDie1Frame", i );	
	i = Random(6) + 1;
	sDie = "br_diered" + IntToString(i);
	sComponentString = s + "=" + sDie + ";";
	SetLocalInt ( oDealer, "iDie1Curr", i );
	i = Random(iFrameSkipVariance) + iBaseFrameSkip;
	SetLocalInt ( oDealer, "iDie1FrameSkip", i );	
	SetLocalInt ( oDealer, "iDie1RollStatus", 0 );
	SetLocalInt ( oDealer, "iDie1Spin", Random(4) );
	SetLocalInt ( oDealer, "iDie1Status", 0 );
	f = ( IntToFloat(Random(iDelayVariance)) * 0.01 ) + fBaseDelay;
	SetLocalFloat ( oDealer, "iDie1Delay", f );
	i = Random(iBounceVariance) + iBaseBounce;
	SetLocalInt ( oDealer, "iDie1Bounce", i );
	
	// set up die 2		
	i = Random(iStartFrameVariance);
	s = "craps_2_" + IntToString(i) + "a";
	SetLocalInt ( oDealer, "iDie2Frame", i );	
	i = Random(6) + 1;
	sDie = "br_diered" + IntToString(i);
	sComponentString = sComponentString + s + "=" + sDie;		
	SetLocalInt ( oDealer, "iDie2Curr", i );
	i = Random(iFrameSkipVariance) + iBaseFrameSkip;
	SetLocalInt ( oDealer, "iDie2FrameSkip", i );
	SetLocalInt ( oDealer, "iDie2RollStatus", 0 );
	SetLocalInt ( oDealer, "iDie2Spin", Random(4) );
	SetLocalInt ( oDealer, "iDie2Status", 0 );
	f = ( IntToFloat(Random(iDelayVariance)) * 0.01 ) + fBaseDelay;
	SetLocalFloat ( oDealer, "iDie2Delay", f );
	i = Random(iBounceVariance) + iBaseBounce;
	SetLocalInt ( oDealer, "iDie2Bounce", i );
		
	GenerateResults(oDealer);
	MPGUIUpdateMultiComponent ( oDealer, "br_craps", sComponentString, "", "craps_die1=1;craps_die2=1" );	
	DelayCommand ( fInitialDelay, RollDie ( oDealer, "1" ) );
	DelayCommand ( fInitialDelay, RollDie ( oDealer, "2" ) );
}


// generate the next roll results

void GenerateResults ( object oDealer ) {
	int iResult;
	
	iResult = Random(6) + 1;
	SetLocalInt ( oDealer, "iResult1", iResult );
	
	iResult = Random(6) + 1;
	SetLocalInt ( oDealer, "iResult2", iResult );
}


// roll die animation

void RollDie ( object oDealer, string sDieNumber ) {
	float fDieDelay;
	int iDiceStopped, iDieBounce, iDieCurr, iDieFrame, iDieFrameSkip, iDieNext, iDieResult, iDieRollStatus, iDieSpin, iDieStatus;
	string s, sDie, sDisplayString, sTextureString;

	iDiceStopped = 0;	
	
	// initiate variables
	iDieFrame = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame" );
	iDieFrameSkip = GetLocalInt ( oDealer, "iDie" + sDieNumber + "FrameSkip" );
	iDieRollStatus = GetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus" );
	iDieStatus = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Status" );
	
	// evaluate die status
	if ( iDieRollStatus == 0 ) {  // first drop
		if ( iDieStatus == 0 ) {  // currently a full die
			// turn off current frame
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			sDisplayString = s + "=0";		
			
			iDieFrame = iDieFrame + iDieFrameSkip;
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr" );			
			// determine next die face
			iDieNext = Random(5) + 1;
			if ( iDieNext >= iDieCurr ) {
				iDieNext = iDieNext + 1;
			}
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Next", iDieNext );	
			iDieSpin = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin" );	
			// turn on new frames
			if ( iDieSpin == 0 ) {  // left spin
				sDie = "br_diered" + IntToString(iDieCurr) + "l";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				sTextureString = s + "=" + sDie + ";";				
				sDie = "br_diered" + IntToString(iDieNext) + "r";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				sTextureString = sTextureString + s + "=" + sDie;											
			} else if ( iDieSpin == 1 ) {  // right spin
				sDie = "br_diered" + IntToString(iDieCurr) + "r";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				sTextureString = s + "=" + sDie + ";";				
				sDie = "br_diered" + IntToString(iDieNext) + "l";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				sTextureString = sTextureString + s + "=" + sDie;			
			} else if ( iDieSpin == 2 ) {  // top spin
				sDie = "br_diered" + IntToString(iDieCurr) + "t";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				sTextureString = s + "=" + sDie + ";";					
				sDie = "br_diered" + IntToString(iDieNext) + "b";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				sTextureString = sTextureString + s + "=" + sDie;				
			} else {  // bottom spin, expected value 3
				sDie = "br_diered" + IntToString(iDieCurr) + "b";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				sTextureString = s + "=" + sDie + ";";				
				sDie = "br_diered" + IntToString(iDieNext) + "t";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				sTextureString = sTextureString + s + "=" + sDie;				
			}
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 1 );
			if ( iDieFrame > iTotalFrames - iDieFrameSkip ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 1 );
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "FrameSkip", iDieFrameSkip - ( iBaseFrameSkipLoss + Random(iFrameSkipLossVariance) ) );				
				AssignCommand ( oDealer, PlaySound ( "cb_ht_whipston" ) );				
			}
		} else {  // currently two half images, expected value 1
			// turn off current frames	
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			sDisplayString = s + "=0;";
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
			sDisplayString = sDisplayString + s + "=0";
			
			iDieFrame = iDieFrame + iDieFrameSkip;
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
			
			// get new current die face
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Next" );
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr", iDieCurr );			
		
			// turn on new frame
			sDie = "br_diered" + IntToString(iDieCurr);
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			sTextureString = s + "=" + sDie;	
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 0 );	
			if ( iDieFrame > iTotalFrames - iDieFrameSkip ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 1 );
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "FrameSkip", iDieFrameSkip - ( iBaseFrameSkipLoss + Random(iFrameSkipLossVariance) ) );
				AssignCommand ( oDealer, PlaySound ( "cb_ht_whipston" ) );				
			}			
			
			// randomize die spin per roll
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin", Random(4) );							
		}	
		
		MPGUIUpdateMultiComponent ( oDealer, "br_craps", sTextureString, "", sDisplayString );		
	} else if ( iDieRollStatus == 1 ) {  // bounce
		if ( iDieStatus == 0 ) {  // currently a full die
			// turn off current frame
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			sDisplayString = s + "=0";		
			
			iDieFrame = iDieFrame - iDieFrameSkip;
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr" );			
			// determine next die face
			iDieNext = Random(5) + 1;
			if ( iDieNext >= iDieCurr ) {
				iDieNext = iDieNext + 1;
			}
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Next", iDieNext );	
			iDieSpin = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin" );	
			// turn on new frames
			if ( iDieSpin == 0 ) {  // left spin
				sDie = "br_diered" + IntToString(iDieCurr) + "l";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				sTextureString = s + "=" + sDie + ";";								
				sDie = "br_diered" + IntToString(iDieNext) + "r";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				sTextureString = sTextureString + s + "=" + sDie;									
			} else if ( iDieSpin == 1 ) {  // right spin
				sDie = "br_diered" + IntToString(iDieCurr) + "r";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				sTextureString = s + "=" + sDie + ";";					
				sDie = "br_diered" + IntToString(iDieNext) + "l";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				sTextureString = sTextureString + s + "=" + sDie;				
			} else if ( iDieSpin == 2 ) {  // top spin
				sDie = "br_diered" + IntToString(iDieCurr) + "t";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				sTextureString = s + "=" + sDie + ";";					
				sDie = "br_diered" + IntToString(iDieNext) + "b";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				sTextureString = sTextureString + s + "=" + sDie;			
			} else {  // bottom spin, expected value 3
				sDie = "br_diered" + IntToString(iDieCurr) + "b";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				sTextureString = s + "=" + sDie + ";";					
				sDie = "br_diered" + IntToString(iDieNext) + "t";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				sTextureString = sTextureString + s + "=" + sDie;			
			}
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 1 );
			iDieBounce = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce" );
			if ( iDieBounce <= 0 ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 2 );
			} else {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce", iDieBounce - 1 );
			}
		} else {  // currently two half images, expected value 1
			// turn off current frames	
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			sDisplayString = s + "=0;";		
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
			sDisplayString = sDisplayString + s + "=0";		
			
			iDieFrame = iDieFrame - iDieFrameSkip;
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
			// get new current die face
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Next" );
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr", iDieCurr );			
		
			// turn on new frame
			sDie = "br_diered" + IntToString(iDieCurr);
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			sTextureString = s + "=" + sDie;
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 0 );
			iDieBounce = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce" );
			if ( iDieBounce <= 0 ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 2 );
			} else {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce", iDieBounce - 1 );
			}
			
			// randomize die spin per roll
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin", Random(4) );											
		}	
		
		MPGUIUpdateMultiComponent ( oDealer, "br_craps", sTextureString, "", sDisplayString );			
	} else if ( iDieRollStatus == 2 ) {  // initiate final frames
		if ( iDieStatus == 0 ) {  // currently a full die
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr" );
			iDieResult = GetLocalInt ( oDealer, "iResult" + sDieNumber );
			if ( iDieCurr == iDieResult ) {  // already on result face
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 3 );
			} else {  // set up the final frame
				// turn off current frame
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				sDisplayString = s + "=0";			
				
				iDieFrame = iDieFrame - iDieFrameSkip;
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );			
			
				// determine next die face
				iDieNext = iDieResult;
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Next", iDieNext );	
				iDieSpin = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin" );	
				// turn on new frames
				if ( iDieSpin == 0 ) {  // left spin
					sDie = "br_diered" + IntToString(iDieCurr) + "l";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					sTextureString = s + "=" + sDie + ";";				
					sDie = "br_diered" + IntToString(iDieNext) + "r";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					sTextureString = sTextureString + s + "=" + sDie;								
				} else if ( iDieSpin == 1 ) {  // right spin
					sDie = "br_diered" + IntToString(iDieCurr) + "r";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					sTextureString = s + "=" + sDie + ";";						
					sDie = "br_diered" + IntToString(iDieNext) + "l";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					sTextureString = sTextureString + s + "=" + sDie;			
				} else if ( iDieSpin == 2 ) {  // top spin
					sDie = "br_diered" + IntToString(iDieCurr) + "t";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					sTextureString = s + "=" + sDie + ";";						
					sDie = "br_diered" + IntToString(iDieNext) + "b";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					sTextureString = sTextureString + s + "=" + sDie;			
				} else {  // bottom spin, expected value 3
					sDie = "br_diered" + IntToString(iDieCurr) + "b";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					sTextureString = s + "=" + sDie + ";";						
					sDie = "br_diered" + IntToString(iDieNext) + "t";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					sTextureString = sTextureString + s + "=" + sDie;			
				}
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 1 );
				iDieBounce = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce" );
				if ( iDieBounce <= 0 ) {
					SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 2 );
				} else {
					SetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce", iDieBounce - 1 );
				}
			}
		} else {  // currently two half images, expected value 1
			// turn off current frames	
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			sDisplayString = s + "=0;";
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
			sDisplayString = sDisplayString + s + "=0";
			
			iDieFrame = iDieFrame - iDieFrameSkip;
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
			
			// get new current die face
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Next" );
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr", iDieCurr );			
		
			// turn on new frame
			sDie = "br_diered" + IntToString(iDieCurr);
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			sTextureString = s + "=" + sDie;			
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 0 );
			iDieBounce = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce" );
			if ( iDieBounce <= 0 ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 2 );
			} else {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce", iDieBounce - 1 );
			}
			
			// randomize die spin per roll
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin", Random(4) );											
		}	
		
		MPGUIUpdateMultiComponent ( oDealer, "br_craps", sTextureString, "", sDisplayString );			
	}
	
	fDieDelay = GetLocalFloat ( oDealer, "iDie" + sDieNumber + "Delay" );
	if ( iDieRollStatus != 3 ) {
		DelayCommand ( fDieDelay, RollDie ( oDealer, sDieNumber ) );
	} else {
		if ( sDieNumber == "1" ) {
			if ( GetLocalInt ( oDealer, "iDie2RollStatus" ) == 4 ) {
				// all dice finished		
				DelayCommand ( fFinalDelay, EvaluateResults(oDealer) );
			} else {
				SetLocalInt ( oDealer, "iDie1RollStatus", 4 );
			}
		} else {
			if ( GetLocalInt ( oDealer, "iDie1RollStatus" ) == 4 ) {
				// all dice finished		
				DelayCommand ( fFinalDelay, EvaluateResults(oDealer) );
			} else {
				SetLocalInt ( oDealer, "iDie2RollStatus", 4 );
			}		
		}
	}		
}


// evaluate a roll's result

void EvaluateResults ( object oDealer ) {
	int i, j, iBet, iBetDifferential, iCurrentPlacedBet, iCurrentPlacedBetOld, iDieFrame, iGold, iResult1, iResult2, iResultTotal, iRound;
	object oPC;
	string s, sDisplayString, sPlayerPos, sResult, sVarName;
		
	// hide the dice
	iDieFrame = GetLocalInt ( oDealer, "iDie1Frame" );	
	s = "craps_1_" + IntToString(iDieFrame) + "a";
	sDisplayString = s + "=0";
	iDieFrame = GetLocalInt ( oDealer, "iDie2Frame" );	
	s = "craps_2_" + IntToString(iDieFrame) + "a";
	sDisplayString = sDisplayString + ";" + s + "=0;craps_die1=0;craps_die2=0";
				
	// check the roll value
	iResult1 = GetLocalInt ( oDealer, "iResult1" );	
	iResult2 = GetLocalInt ( oDealer, "iResult2" );	
	iResultTotal = iResult1 + iResult2;
	iRound = GetLocalInt ( oDealer, "iRound" );	
	
	//for each player, run this
	for ( j = 1 ; j <= 4 ; j++ ) {
		sPlayerPos = IntToString(j);
		if ( GetLocalInt ( oDealer, "i" + sPlayerPos +"isPlayer" ) == 1 ) {
			oPC = GetLocalObject ( oDealer, "oPlayer" + sPlayerPos ); 
			sVarName = "iPlayer" + sPlayerPos;
			iCurrentPlacedBet = GetLocalInt ( oDealer, sVarName + "CurrentPlacedBet" );
			iCurrentPlacedBetOld = iCurrentPlacedBet;
			iGold = 0;
			iBetDifferential = 0;
			
			if ( iResultTotal == 2 ) {
				sResult = "Snake Eyes, the roll is 2";
			
				// check single roll bets	
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "snakeeyes" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;
					iGold = iGold + ( iBet * 3 );
				}
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "hilo" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 16 );
				}		
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "anycraps" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 8 );
				}
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "cande" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 4 );
				}			
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "field" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 3 );
				}
				
				// check pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "pass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // 2 loses on come-out roll
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "pass", 0 );
						sDisplayString = sDisplayString + ";craps_chip_pass=0";						
					}
				}	
				
				// check don't pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // 2 wins on come-out roll
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontpass=0";
					}			
				}	
				
				// check come bet
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come" );
				if ( iBet != 0 ) {
					iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
					SetLocalInt ( oDealer, sPlayerPos + "-" + "come", 0 );
					sDisplayString = sDisplayString + ";craps_chip_come=0";			
				}
				
				// check don't come bet
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 2 );
					iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
					SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome", 0 );
					sDisplayString = sDisplayString + ";craps_chip_dontcome=0";
				}		
				
				// reset round
				if ( iRound == 0 ) {
					iRound = -1;
				}
			} else if ( iResultTotal == 3 ) {
				sResult = "Ace Deuce, the roll is 3";	
			
				// check single roll bets	
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "acedeuce" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 16 );
				}
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "anycraps" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 8 );
				}	
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "cande" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 4 );
				}			
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "field" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 2 );
				}	
				
				// check pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "pass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // 3 loses on come-out roll
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "pass", 0 );
						sDisplayString = sDisplayString + ";craps_chip_pass=0";
					}
				}		
				
				// check don't pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // 3 wins on come-out roll
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontpass=0";
					}
				}
				
				// check come bet
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come" );
				if ( iBet != 0 ) {
					iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
					SetLocalInt ( oDealer, sPlayerPos + "-" + "come", 0 );
					sDisplayString = sDisplayString + ";craps_chip_come=0";			
				}
				
				// check don't come bet
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 2 );
					iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
					SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome", 0 );
					sDisplayString = sDisplayString + ";craps_chip_dontcome=0";			
				}			
				
				// reset round
				if ( iRound == 0 ) {
					iRound = -1;
				}												
			} else if ( iResultTotal == 4 ) {
				if ( iResult1 == iResult2 ) {
					sResult = "Hard Four, the roll is 4";
				} else {
					sResult = "Easy Four, the roll is 4";		
				}
			
				// check single roll bets	
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "field" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 2 );
				}		
				
				if ( iRound != 0 ) {
					// check hard way
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "hard4" );
					if ( iBet != 0 ) {
						if ( iResult1 == iResult2 ) {
							iBetDifferential = iBetDifferential + iBet;								
							iGold = iGold + ( iBet * 8 );
						}
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "hard4", 0 );
						sDisplayString = sDisplayString + ";craps_chip_hard4=0";							
					}
					
					// check place win and buy
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placewin4" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = FloatToInt ( IntToFloat(iGold) + ( IntToFloat(iBet) * 2.8 ) );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "placewin4", 0 );
						sDisplayString = sDisplayString + ";craps_chip_placewin4=0";
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "buy4" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;						
						iGold = iGold + FloatToInt ( ( ( IntToFloat(iBet) * 3.0 ) * 0.95 ) );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "buy4", 0 );
						sDisplayString = sDisplayString + ";craps_chip_buy4=0";						
					}
					
					// check come and don't come 4
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come4" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "come4", 0 );
						sDisplayString = sDisplayString + ";craps_chip_come4=0";
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds4" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;						
							iGold = iGold + ( iBet * 3 );					
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds4", 0 );
							sDisplayString = sDisplayString + ";craps_chip_comeodds4=0";				
						}
					}
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome4" );
					if ( iBet != 0 ) {
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome4", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontcome4=0";
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds4" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds4", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontcomeodds4=0";				
						}
					}			
				}
				
				// check pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "pass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // establish the point
						SetLocalInt ( oDealer, "iCurrentPoint", iResultTotal );
						s = "craps_puck_on" + IntToString(iResultTotal);						
						sDisplayString = sDisplayString + ";craps_puck_off=0;" + s + "=1";								
					} else if ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) {  // pass line win
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "pass", 0 );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_chip_pass=0;craps_puck_off=1;" + s + "=0";
						
						// check odds
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "passodds" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;						
							iGold = iGold + ( iBet * 3 );
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "passodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_passodds=0";
						}				
					}
				}	
				
				// check don't pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // establish the point
						SetLocalInt ( oDealer, "iCurrentPoint", iResultTotal );
						s = "craps_puck_on" + IntToString(iResultTotal);	
						sDisplayString = sDisplayString + ";craps_puck_off=0;" + s + "=1";													
					} else if ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) {  // pass line win
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass", 0 );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_chip_dontpass=0;craps_puck_off=1;" + s + "=0";
												
						// check odds
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontpassodds=0";							
						}				
					}
				}				
				
				// clear place lose and lay bets
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placelose4" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "placelose4", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "lay4" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "lay4", 0 );
				sDisplayString = sDisplayString + ";craps_chip_placelose4=0;craps_chip_lay4=0";				
				
				// reset round
				if ( ( iRound != 0 ) && ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) ) {
					iRound = -1;
				}
			} else if ( iResultTotal == 5 ) {
				sResult = "Five, the roll is 5";
			
				if ( iRound != 0 ) {
					// check place win and buy
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placewin5" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = FloatToInt ( IntToFloat(iGold) + ( IntToFloat(iBet) * 2.4 ) );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "placewin5", 0 );
						sDisplayString = sDisplayString + ";craps_chip_placewin5=0";													
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "buy5" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( ( IntToFloat(iBet) * 2.5 ) * 0.95 ) );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "buy5", 0 );
						MPGUIDisplayComponent ( oDealer,"br_craps", "craps_chip_buy5", FALSE );
						sDisplayString = sDisplayString + ";craps_chip_buy5=0";													
					}
					
					// check come and don't come 5
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come5" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;				
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "come5", 0 );
						sDisplayString = sDisplayString + ";craps_chip_come5=0";						
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds5" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;					
							iGold = iGold + FloatToInt ( IntToFloat(iBet) * 2.5 );					
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds5", 0 );
							sDisplayString = sDisplayString + ";craps_chip_comeodds5=0";											
						}
					}
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome5" );
					if ( iBet != 0 ) {
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome5", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontcome5=0";
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds5" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds5", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontcomeodds5=0";				
						}
					}			
				}
				
				// check pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "pass" );				
				if ( iBet != 0 ) {			
					if ( iRound == 0 ) {  // establish the point
						SetLocalInt ( oDealer, "iCurrentPoint", iResultTotal );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_puck_off=0;" + s + "=" + "1";			
					} else if ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) {  // pass line win
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "pass", 0 );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_chip_pass=0;craps_puck_off=1;" + s + "=" + "0";	
														
						// check odds
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "passodds" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;				
							iGold = iGold + FloatToInt ( IntToFloat(iBet) * 2.5 );
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "passodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_passodds=0";							
						}									
					}
				}
				
				// check don't pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // establish the point
						SetLocalInt ( oDealer, "iCurrentPoint", iResultTotal );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_puck_off=0;" + s + "=" + "1;";														
					} else if ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) {  // pass line win
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass", 0 );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_chip_dontpass=0;craps_puck_off=1;" + s + "=" + "0";						
						
						// check odds
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontpassodds=0";
						}				
					}
				}						
				
				// clear place lose and lay bets
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placelose5" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "placelose5", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "lay5" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "lay5", 0 );
				sDisplayString = sDisplayString + ";craps_chip_placelose5=0;craps_chip_lay5=0";	
									
				// reset round
				if ( ( iRound != 0 ) && ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) ) {
					iRound = -1;
				}											
			} else if ( iResultTotal == 6 ) {
				if ( iResult1 == iResult2 ) {
					sResult = "Hard Six, the roll is 6";
				} else {
					sResult = "Easy Six, the roll is 6";		
				}	
			
				if ( iRound != 0 ) {	
					// check hard way
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "hard6" );
					if ( iBet != 0 ) {
						if ( iResult1 == iResult2 ) {
							iBetDifferential = iBetDifferential + iBet;					
							iGold = iGold + ( iBet * 10 );
						}
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "hard6", 0 );
						sDisplayString = sDisplayString + ";craps_chip_hard6=0";						
					}				
					
					// check Big 6
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "big6" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "big6", 0 );
						sDisplayString = sDisplayString + ";craps_chip_big6=0";												
					}					
					
					// check place win and buy
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placewin6" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( IntToFloat(iBet) / 6.0 ) * 7.0 ) + iBet;
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "placewin6", 0 );
						sDisplayString = sDisplayString + ";craps_chip_placewin6=0";														
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "buy6" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( ( IntToFloat(iBet) * 2.2 ) * 0.95 ) );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "buy6", 0 );
						sDisplayString = sDisplayString + ";craps_chip_buy6=0";						
					}
					
					// check come and don't come 6
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come6" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "come6", 0 );
						sDisplayString = sDisplayString + ";craps_chip_come6=0";
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds6" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;					
							iGold = iGold + FloatToInt ( IntToFloat(iBet) * 2.2 );					
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds6", 0 );
							sDisplayString = sDisplayString + ";craps_chip_comeodds6=0";				
						}
					}
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome6" );
					if ( iBet != 0 ) {
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome6", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontcome6=0";
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds6" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds6", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontcomeodds6=0";				
						}
					}			
				}
				
				// check pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "pass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // establish the point
						SetLocalInt ( oDealer, "iCurrentPoint", iResultTotal );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_puck_off=0;" + s + "=1";				
					} else if ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) {  // pass line win
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "pass", 0 );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_chip_pass=0;craps_puck_off=1;" + s + "=0";
														
						// check odds
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "passodds" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;						
							iGold = iGold + FloatToInt ( IntToFloat(iBet) * 2.2 );
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "passodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_passodds=0";
						}									
					}
				}		
				
				// check don't pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // establish the point
						SetLocalInt ( oDealer, "iCurrentPoint", iResultTotal );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_puck_off=0;" + s + "=1";									
					} else if ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) {  // pass line win
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass", 0 );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_chip_dontpass=0;craps_puck_off=1;" + s + "=0";
						
						// check odds
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontpassodds=0";	
						}				
					}
				}	
								
				// clear place lose and lay bets
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placelose6" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "placelose6", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "lay6" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "lay6", 0 );
				sDisplayString = sDisplayString + ";craps_chip_placelose6=0;craps_chip_lay6=0";	
			
				// reset round
				if ( ( iRound != 0 ) && ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) ) {
					iRound = -1;
				}																	
			} else if ( iResultTotal == 7 ) {
				if ( iRound == 0 ) {
					sResult = "Natural Seven, the roll is 7";
				} else {
					sResult = "Seven Out, the roll is 7";	
				}	
			
				if ( iRound != 0 ) {	
					// check place lose and lay bets
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placelose4" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;			
						iGold = iGold + FloatToInt ( ( IntToFloat(iBet) / 11.0 ) * 5.0 ) + iBet;
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "placelose4", 0 );
						sDisplayString = sDisplayString + ";craps_chip_placelose4=0";								
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "lay4" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( ( IntToFloat(iBet) * 1.5 ) * 0.95 ) );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "lay4", 0 );
						sDisplayString = sDisplayString + ";craps_chip_lay4=0";						
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placelose5" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( IntToFloat(iBet) * 1.625 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "placelose5", 0 );
						sDisplayString = sDisplayString + ";craps_chip_placelose5=0";						
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "lay5" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( ( ( IntToFloat(iBet) / 3.0 ) * 2.0 ) + IntToFloat(iBet) ) * 0.95 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "lay5", 0 );
						sDisplayString = sDisplayString + ";craps_chip_lay5=0";							
					}		
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placelose6" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( IntToFloat(iBet) * 1.8 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "placelose6", 0 );
						sDisplayString = sDisplayString + ";craps_chip_placelose6=0";							
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "lay6" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( ( ( IntToFloat(iBet) / 6.0 ) * 5.0 ) + IntToFloat(iBet) ) * 0.95 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "lay6", 0 );
						sDisplayString = sDisplayString + ";craps_chip_lay6=0";								
					}		
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placelose8" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( IntToFloat(iBet) * 1.8 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "placelose8", 0 );
						sDisplayString = sDisplayString + ";craps_chip_placelose8=0";							
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "lay8" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( ( ( IntToFloat(iBet) / 6.0 ) * 5.0 ) + IntToFloat(iBet) ) * 0.95 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "lay8", 0 );
						sDisplayString = sDisplayString + ";craps_chip_lay8=0";							
					}
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placelose9" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( IntToFloat(iBet) * 1.625 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "placelose9", 0 );
						sDisplayString = sDisplayString + ";craps_chip_placelose9=0";							
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "lay9" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( ( ( IntToFloat(iBet) / 3.0 ) * 2.0 ) + IntToFloat(iBet) ) * 0.95 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "lay9", 0 );
						sDisplayString = sDisplayString + ";craps_chip_lay9=0";						
					}		
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placelose10" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( IntToFloat(iBet) / 11.0 ) * 5.0 ) + iBet;
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "placelose10", 0 );
						sDisplayString = sDisplayString + ";craps_chip_placelose10=0";						
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "lay10" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( ( IntToFloat(iBet) * 1.5 ) * 0.95 ) );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "lay10", 0 );
						sDisplayString = sDisplayString + ";craps_chip_lay10=0";								
					}		
					
					// check come numbers
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come4" );
					if ( iBet != 0 ) {
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "come4", 0 );
						sDisplayString = sDisplayString + ";craps_chip_come4=0";
												
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds4" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds4", 0 );
							sDisplayString = sDisplayString + ";craps_chip_comeodds4=0";					
						}			
					}
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come5" );
					if ( iBet != 0 ) {
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "come5", 0 );
						sDisplayString = sDisplayString + ";craps_chip_come5=0";
						
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds5" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds5", 0 );
							sDisplayString = sDisplayString + ";craps_chip_comeodds5=0";					
						}			
					}			
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come6" );
					if ( iBet != 0 ) {
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "come6", 0 );
						sDisplayString = sDisplayString + ";craps_chip_come6=0";
						
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds6" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds6", 0 );
							sDisplayString = sDisplayString + ";craps_chip_comeodds6=0";					
						}			
					}
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come8" );
					if ( iBet != 0 ) {
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "come8", 0 );
						sDisplayString = sDisplayString + ";craps_chip_come8=0";
						
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds8" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds8", 0 );
							sDisplayString = sDisplayString + ";craps_chip_comeodds8=0";					
						}			
					}			
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come9" );
					if ( iBet != 0 ) {
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "come9", 0 );
						sDisplayString = sDisplayString + ";craps_chip_come9=0";
						
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds9" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds9", 0 );
							sDisplayString = sDisplayString + ";craps_chip_comeodds9=0";					
						}			
					}			
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come10" );
					if ( iBet != 0 ) {
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "come10", 0 );
						sDisplayString = sDisplayString + ";craps_chip_come10=0";
						
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds10" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds10", 0 );
							sDisplayString = sDisplayString + ";craps_chip_comeodds10=0";					
						}			
					}			
					
					// check don't come numbers
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome4" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome4", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontcome4=0";
						
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds4" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;					
							iGold = iGold + FloatToInt ( IntToFloat(iBet) * 1.5 );
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds4", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontcomeodds4=0";					
						}			
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome5" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome5", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontcome5=0";
						
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds5" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;						
							iGold = iGold + FloatToInt ( ( IntToFloat(iBet) / 3.0 ) * 2.0 ) + iBet;	
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds5", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontcomeodds5=0";					
						}			
					}				
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome6" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;				
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome6", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontcome6=0";
						
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds6" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;					
							iGold = iGold + FloatToInt ( ( IntToFloat(iBet) / 6.0 ) * 5.0 ) + iBet;	
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds6", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontcomeodds6=0";					
						}			
					}			
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome8" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;				
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome8", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontcome8=0";
						
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds8" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;			
							iGold = iGold + FloatToInt ( ( IntToFloat(iBet) / 6.0 ) * 5.0 ) + iBet;	
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds8", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontcomeodds8=0";					
						}			
					}						
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome9" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome9", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontcome9=0";
						
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds9" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;						
							iGold = iGold + FloatToInt ( ( IntToFloat(iBet) / 3.0 ) * 2.0 ) + iBet;	
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds9", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontcomeodds9=0";					
						}			
					}				
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome10" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome10", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontcome10=0";
						
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds10" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;						
							iGold = iGold + FloatToInt ( IntToFloat(iBet) * 1.5 );
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds10", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontcomeodds10=0";					
						}			
					}								
				}	
				
				// check pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "pass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // 7 wins on come-out roll
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "pass", 0 );
						sDisplayString = sDisplayString + ";craps_chip_pass=0";	
					} else {  // 7 loses all subsequent rolls
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;
						SetLocalInt ( oDealer, sPlayerPos + "-" + "pass", 0 );
						sDisplayString = sDisplayString + ";craps_chip_pass=0";	
						
						// check odds bets	
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "passodds" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;
							SetLocalInt ( oDealer, sPlayerPos + "-" + "passodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_passodds=0";					
						}						
					}
				}
				
				// check don't pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // 7 loses on come-out roll
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontpass=0";	
					} else {  // 7 wins on other rolls
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontpass=0";
						
						// check odds bets	
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds" );
						if ( iBet != 0 ) {
							i = GetLocalInt ( oDealer, "iCurrentPoint" );
							if ( ( i == 4 ) || ( i == 10 ) ) {
								iBetDifferential = iBetDifferential + iBet;					
								iGold = iGold + FloatToInt ( IntToFloat(iBet) * 1.5 );
							} else if ( ( i == 5 ) || ( i == 9 ) ) {
								iBetDifferential = iBetDifferential + iBet;				
								iGold = iGold + FloatToInt ( ( IntToFloat(iBet) / 3.0 ) * 2.0 ) + iBet;					
							} else if ( ( i == 6 ) || ( i == 8 ) ) {
								iBetDifferential = iBetDifferential + iBet;						
								iGold = iGold + FloatToInt ( ( IntToFloat(iBet) / 6.0 ) * 5.0 ) + iBet;						
							}
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontpassodds=0";					
						}							
					}
				}	
				
				// check come bet
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 2 );		
					iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
					SetLocalInt ( oDealer, sPlayerPos + "-" + "come", 0 );	
					sDisplayString = sDisplayString + ";craps_chip_come=0";			
				}
				
				// check don't come bet
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome" );
				if ( iBet != 0 ) {
					iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
					SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome", 0 );
					sDisplayString = sDisplayString + ";craps_chip_dontcome=0";			
				}
					
				// clear all hard ways
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "hard4" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "hard4", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "hard6" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "hard6", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "hard8" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "hard8", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "hard10" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "hard10", 0 );
				sDisplayString = sDisplayString + ";craps_chip_hard4=0;craps_chip_hard6=0;craps_chip_hard8=0;craps_chip_hard10=0";	
				
				// clear Big 6 & 8 bets
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "big6" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "big6", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "big8" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "big8", 0 );	
				sDisplayString = sDisplayString + ";craps_chip_big6=0;craps_chip_big8=0";						
				
				// clear all place win bets
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placewin4" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "placewin4", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placewin5" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "placewin5", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placewin6" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "placewin6", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placewin8" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "placewin8", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placewin9" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "placewin9", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placewin10" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "placewin10", 0 );
				sDisplayString = sDisplayString + ";craps_chip_placewin4=0;craps_chip_placewin5=0;craps_chip_placewin6=0;craps_chip_placewin8=0;craps_chip_placewin9=0;craps_chip_placewin10=0";					
				
				// clear all buy bets
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "buy4" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "buy4", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "buy5" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "buy5", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "buy6" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "buy6", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "buy8" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "buy8", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "buy9" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "buy9", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "buy10" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "buy10", 0 );	
				sDisplayString = sDisplayString + ";craps_chip_buy4=0;craps_chip_buy5=0;craps_chip_buy6=0;craps_chip_buy8=0;craps_chip_buy9=0;craps_chip_buy10=0";
								
				// reset round
				iRound = -1;
				s = "craps_puck_on" + IntToString ( GetLocalInt ( oDealer, "iCurrentPoint" ) );
				sDisplayString = sDisplayString + ";craps_puck_off=1;" + s + "=0";			
			} else if ( iResultTotal == 8 ) {
				if ( iResult1 == iResult2 ) {
					sResult = "Hard Eight, the roll is 8";
				} else {
					sResult = "Easy Eight, the roll is 8";		
				}	
			
				if ( iRound != 0 ) {	
					// check hard way
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "hard8" );
					if ( iBet != 0 ) {
						if ( iResult1 == iResult2 ) {		
							iBetDifferential = iBetDifferential + iBet;						
							iGold = iGold + ( iBet * 10 );
						}
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "hard8", 0 );
						sDisplayString = sDisplayString + ";craps_chip_hard8=0";												
					}	
					
					// check Big 8
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "big8" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "big8", 0 );
						sDisplayString = sDisplayString + ";craps_chip_big8=0";											
					}	
					
					// check place win and buy
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placewin8" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( IntToFloat(iBet) / 6.0 ) * 7.0 ) + iBet;
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "placewin8", 0 );
						sDisplayString = sDisplayString + ";craps_chip_placewin8=0";													
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "buy8" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( ( IntToFloat(iBet) * 2.2 ) * 0.95 ) );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "buy8", 0 );
						sDisplayString = sDisplayString + ";craps_chip_buy8=0";													
					}
					
					// check come and don't come 8
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come8" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "come8", 0 );
						sDisplayString = sDisplayString + ";craps_chip_come8=0";						
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds8" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;					
							iGold = iGold + FloatToInt ( IntToFloat(iBet) * 2.2 );					
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds8", 0 );
							sDisplayString = sDisplayString + ";craps_chip_comeodds8=0";				
						}
					}
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome8" );
					if ( iBet != 0 ) {
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome8", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontcome8=0";
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds8" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds8", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontcomeodds8=0";				
						}
					}					
				}
				
				// check pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "pass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // establish the point
						SetLocalInt ( oDealer, "iCurrentPoint", iResultTotal );
						s = "craps_puck_on" + IntToString(iResultTotal);	
						sDisplayString = sDisplayString + ";craps_puck_off=0;" + s + "=1";								
					} else if ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) {  // pass line win
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "pass", 0 );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_chip_pass=0;craps_puck_off=1;" + s + "=0";						
														
						// check odds
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "passodds" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;						
							iGold = iGold + FloatToInt ( IntToFloat(iBet) * 2.2 );
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "passodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_passodds=0";							
						}				
					}
				}
				
				// check don't pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // establish the point
						SetLocalInt ( oDealer, "iCurrentPoint", iResultTotal );
						s = "craps_puck_on" + IntToString(iResultTotal);	
						sDisplayString = sDisplayString + ";craps_puck_off=0;" + s + "=1";													
					} else if ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) {  // pass line win
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass", 0 );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_chip_dontpass=0;craps_puck_off=1;" + s + "=0";						
						
						// check odds
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontpassodds=0";	
						}				
					}
				}			
						
				// clear place lose and lay bets
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placelose8" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "placelose8", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" +  "lay8" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "lay8", 0 );
				sDisplayString = sDisplayString + ";craps_chip_placelose8=0;craps_chip_lay8=0";					
				
				// reset round
				if ( ( iRound != 0 ) && ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) ) {
					iRound = -1;
				}														
			} else if ( iResultTotal == 9 ) {
				sResult = "Nine, the roll is 9";
			
				// check single roll bets	
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "field" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 2 );
				}	
				
				if ( iRound != 0 ) {		
					// check place win and buy
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placewin9" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;				
						iGold = FloatToInt ( IntToFloat(iGold) + ( IntToFloat(iBet) * 2.4 ) );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "placewin9", 0 );
						sDisplayString = sDisplayString + ";craps_chip_placewin9=0";									
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "buy9" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( ( IntToFloat(iBet) * 2.5 ) * 0.95 ) );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "buy9", 0 );
						sDisplayString = sDisplayString + ";craps_chip_buy9=0";						
					}
					
					// check come and don't come 9
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come9" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "come9", 0 );
						sDisplayString = sDisplayString + ";craps_chip_come9=0";
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds9" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;					
							iGold = iGold + FloatToInt ( IntToFloat(iBet) * 2.5 );					
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds9", 0 );
							sDisplayString = sDisplayString + ";craps_chip_comeodds9=0";				
						}
					}
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome9" );
					if ( iBet != 0 ) {
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome9", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontcome9=0";
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds9" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds9", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontcomeodds9=0";				
						}
					}				
				}
				
				// check pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "pass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // establish the point
						SetLocalInt ( oDealer, "iCurrentPoint", iResultTotal );
						s = "craps_puck_on" + IntToString(iResultTotal);	
						sDisplayString = sDisplayString + ";craps_puck_off=0;" + s + "=1";									
					} else if ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) {  // pass line win
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "pass", 0 );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_chip_pass=0;craps_puck_off=1;" + s + "=0";							
														
						// check odds
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "passodds" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;					
							iGold = iGold + FloatToInt ( IntToFloat(iBet) * 2.5 );
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "passodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_passodds=0";								
						}				
					}
				}					
				
				// check don't pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // establish the point
						SetLocalInt ( oDealer, "iCurrentPoint", iResultTotal );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_puck_off=0;" + s + "=1";								
					} else if ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) {  // pass line win
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass", 0 );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_chip_dontpass=0;craps_puck_off=1;" + s + "=0";
						
						// check odds
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontpassodds=0";	
						}				
					}
				}	
						
				// clear place lose and lay bets
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placelose9" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "placelose9", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "lay9" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "lay9", 0 );
				sDisplayString = sDisplayString + ";craps_chip_placelose9=0;craps_chip_lay9=0";	
				
				// reset round
				if ( ( iRound != 0 ) && ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) ) {
					iRound = -1;
				}										
			} else if ( iResultTotal == 10 ) {
				if ( iResult1 == iResult2 ) {
					sResult = "Hard Ten, the roll is 10";
				} else {
					sResult = "Easy Ten, the roll is 10";	
				}		
			
				// check single roll bets	
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "field" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 2 );
				}		
				
				if ( iRound != 0 ) {		
					// check hard way
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "hard10" );
					if ( iBet != 0 ) {
						if ( iResult1 == iResult2 ) {
							iBetDifferential = iBetDifferential + iBet;						
							iGold = iGold + ( iBet * 8 );
						}
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "hard10", 0 );
						sDisplayString = sDisplayString + ";craps_chip_hard10=0";							
					}	
					
					// check place win and buy
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placewin10" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = FloatToInt ( IntToFloat(iGold) + ( IntToFloat(iBet) * 2.8 ) );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "placewin10", 0 );
						sDisplayString = sDisplayString + ";craps_chip_placewin10=0";							
					}	
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "buy10" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + FloatToInt ( ( ( IntToFloat(iBet) * 3.0 ) * 0.95 ) );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "buy10", 0 );
						sDisplayString = sDisplayString + ";craps_chip_buy10=0";							
					}
					
					// check come and don't come 10
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come10" );
					if ( iBet != 0 ) {
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "come10", 0 );
						sDisplayString = sDisplayString + ";craps_chip_come10=0";
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds10" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;					
							iGold = iGold + ( iBet * 3 );					
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "comeodds10", 0 );
							sDisplayString = sDisplayString + ";craps_chip_comeodds10=0";				
						}
					}
					iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome10" );
					if ( iBet != 0 ) {
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome10", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontcome10=0";
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds10" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcomeodds10", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontcomeodds10=0";				
						}
					}			
				}
				
				// check pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "pass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // establish the point
						SetLocalInt ( oDealer, "iCurrentPoint", iResultTotal );
						s = "craps_puck_on" + IntToString(iResultTotal);	
						sDisplayString = sDisplayString + ";craps_puck_off=0;" + s + "=1";									
					} else if ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) {  // pass line win
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "pass", 0 );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_chip_pass=0;craps_puck_off=1;" + s + "=0";
														
						// check odds
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "passodds" );
						if ( iBet != 0 ) {
							iBetDifferential = iBetDifferential + iBet;						
							iGold = iGold + ( iBet * 3 );
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "passodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_passodds=0";
						}				
					}
				}				
				
				// check don't pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // establish the point
						SetLocalInt ( oDealer, "iCurrentPoint", iResultTotal );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_puck_off=0;" + s + "=1";							
					} else if ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) {  // pass line win
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass", 0 );
						s = "craps_puck_on" + IntToString(iResultTotal);
						sDisplayString = sDisplayString + ";craps_chip_dontpass=0;craps_puck_off=1;" + s + "=0";
						
						// check odds
						iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds" );
						if ( iBet != 0 ) {
							iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
							SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpassodds", 0 );
							sDisplayString = sDisplayString + ";craps_chip_dontpassodds=0";
						}				
					}
				}			
				
				// clear place lose and lay bets
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "placelose10" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "placelose10", 0 );
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "lay10" );
				iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
				SetLocalInt ( oDealer, sPlayerPos + "-" + "lay10", 0 );
				sDisplayString = sDisplayString + ";craps_chip_placelose10=0;craps_chip_lay10=0";	
		
				// reset round
				if ( ( iRound != 0 ) && ( GetLocalInt ( oDealer, "iCurrentPoint" ) == iResultTotal ) ) {
					iRound = -1;
				}																	
			} else if ( iResultTotal == 11 ) {
				sResult = "Yo-leven, the roll is 11";	
			
				// check single roll bets
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "yo" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 16 );
				}				
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "cande" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 8 );
				}				
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "field" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 2 );
				}				
				
				// check pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "pass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // 11 wins on come-out roll
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + ( iBet * 2 );
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "pass", 0 );
						sDisplayString = sDisplayString + ";craps_chip_pass=0";	
					}
				}	
				
				// check don't pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // 11 loses on come-out roll
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontpass=0";	
					}
				}	
				
				// check come bet
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 2 );		
					iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
					SetLocalInt ( oDealer, sPlayerPos + "-" + "come", 0 );
					sDisplayString = sDisplayString + ";craps_chip_come=0";			
				}
				
				// check don't come bet
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome" );
				if ( iBet != 0 ) {
					iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
					SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome", 0 );
					sDisplayString = sDisplayString + ";craps_chip_dontcome=0";			
				}					
				
				// reset round
				if ( iRound == 0 ) {
					iRound = -1;
				}			
			} else if ( iResultTotal == 12 ) {
				sResult = "Boxcars, the roll is 12";		
			
				// check single roll bets	
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "boxcars" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 3 );
				}
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "hilo" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + ( iBet * 16 );
				}		
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "anycraps" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;	
					iGold = iGold + ( iBet * 8 );
				}
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "field" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;			
					iGold = iGold + ( iBet * 3 );
				}
				
				// check pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "pass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // 2 loses on come-out roll
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "pass", 0 );
						sDisplayString = sDisplayString + ";craps_chip_pass=0";	
					}
				}
				
				// check don't pass line
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass" );
				if ( iBet != 0 ) {
					if ( iRound == 0 ) {  // 12 ties on come-out roll
						iBetDifferential = iBetDifferential + iBet;					
						iGold = iGold + iBet;
						iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
						SetLocalInt ( oDealer, sPlayerPos + "-" + "dontpass", 0 );
						sDisplayString = sDisplayString + ";craps_chip_dontpass=0";		
					}
				}
				
				// check come bet
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come" );
				if ( iBet != 0 ) {
					iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
					SetLocalInt ( oDealer, sPlayerPos + "-" + "come", 0 );
					sDisplayString = sDisplayString + ";craps_chip_come=0";			
				}
				
				// check don't come bet
				iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome" );
				if ( iBet != 0 ) {
					iBetDifferential = iBetDifferential + iBet;				
					iGold = iGold + iBet;
					iCurrentPlacedBet = iCurrentPlacedBet - iBet;		
					SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome", 0 );
					sDisplayString = sDisplayString + ";craps_chip_dontcome=0";			
				}					
				
				// reset round
				if ( iRound == 0 ) {
					iRound = -1;
				}												
			}		
		
			// move the come and don't come bets
			iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "come" );
				
			if ( iBet != 0 ) {
				SetLocalInt ( oDealer, sPlayerPos + "-" + "come", 0 );
				sDisplayString = sDisplayString + ";craps_chip_come=0";	
				s = "come" + IntToString(iResultTotal);
				SetLocalInt ( oDealer, sPlayerPos + "-" + s, iBet );
				UpdateChipImage ( oDealer, s );		
			}
			iBet = GetLocalInt ( oDealer, sPlayerPos + "-" +  "dontcome" );
			
			if ( iBet != 0 ) {
				SetLocalInt ( oDealer, sPlayerPos + "-" + "dontcome", 0 );
				sDisplayString = sDisplayString + ";craps_chip_dontcome=0";	
				s = "dontcome" + IntToString(iResultTotal);
				SetLocalInt ( oDealer, sPlayerPos + "-" + s, iBet );
				UpdateChipImage ( oDealer, s );			
			}	
			
			// clear single roll bets
			iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "snakeeyes" );
			iCurrentPlacedBet = iCurrentPlacedBet - iBet;
			SetLocalInt ( oDealer, sPlayerPos + "-" + "snakeeyes", 0 );
			iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "acedeuce" );
			iCurrentPlacedBet = iCurrentPlacedBet - iBet;	
			SetLocalInt ( oDealer, sPlayerPos + "-" + "acedeuce", 0 );
			iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "yo" );
			iCurrentPlacedBet = iCurrentPlacedBet - iBet;	
			SetLocalInt ( oDealer, sPlayerPos + "-" + "yo", 0 );
			iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "boxcars" );
			iCurrentPlacedBet = iCurrentPlacedBet - iBet;	
			SetLocalInt ( oDealer, sPlayerPos + "-" + "boxcars", 0 );
			iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "hilo" );
			iCurrentPlacedBet = iCurrentPlacedBet - iBet;	
			SetLocalInt ( oDealer, sPlayerPos + "-" + "hilo", 0 );
			iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "anyseven" );
			iCurrentPlacedBet = iCurrentPlacedBet - iBet;	
			SetLocalInt ( oDealer, sPlayerPos + "-" + "anyseven", 0 );
			iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "anycraps" );
			iCurrentPlacedBet = iCurrentPlacedBet - iBet;	
			SetLocalInt ( oDealer, sPlayerPos + "-" + "anycraps", 0 );
			iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "cande" );
			iCurrentPlacedBet = iCurrentPlacedBet - iBet;	
			SetLocalInt ( oDealer, sPlayerPos + "-" + "cande", 0 );
			iBet = GetLocalInt ( oDealer, sPlayerPos + "-" + "field" );
			iCurrentPlacedBet = iCurrentPlacedBet - iBet;	
			SetLocalInt ( oDealer, sPlayerPos + "-" + "field", 0 );
			sDisplayString = sDisplayString + ";craps_chip_snakeeyes=0;craps_chip_acedeuce=0;craps_chip_yo=0;craps_chip_boxcars=0;craps_chip_hilo=0;craps_chip_anyseven=0;craps_chip_anycraps=0;craps_chip_cande=0;craps_chip_field=0";				
			
			// resolve gold balance
			if ( iGold > 0 ) {  // player won
				i = GetGold(oPC);			
				GiveGoldToCreature ( oPC, iGold, TRUE );
				SetGUIObjectText ( oPC, "br_craps", "craps_gold", -1, IntToString ( i + iGold ) );
				SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "GoldWon", GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "GoldWon" ) + ( iGold - iBetDifferential ) );
			}
			
			// calculate amount lost
			SetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "GoldLost", GetLocalInt ( oDealer, "iPlayer" + sPlayerPos + "GoldLost" ) + ( iCurrentPlacedBetOld - iCurrentPlacedBet - iBetDifferential ) );
			
			SetLocalInt ( oDealer, sVarName + "CurrentPlacedBet", iCurrentPlacedBet );		
			sDisplayString = sDisplayString + ";craps_message_pane=1";
			MPGUIUpdateMultiComponent ( oDealer, "br_craps", "", "craps_message=" + sResult + ";player" + sPlayerPos + "bet=" + IntToString(iCurrentPlacedBet), sDisplayString );
			DelayCommand ( 1.5, MPGUIDisplayComponent ( oDealer, "br_craps", "craps_message_pane" ) );
		}			
	}
	
	SetLocalInt ( oDealer, "iRound", iRound + 1 );
	SetLocalInt ( oDealer, "iInPlay", 0 );	
	SetLocalInt ( oDealer, "iNumReadyPlayers", 0 );
	EndRound(oDealer);
}


// end round cleanup

void EndRound ( object oDealer ) {
	int i, iRound, iWaitList;
	object oPC;
	string s, sCurrentPoint, sHideString, sTextString;
	
	sHideString = "";
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
			oPC = GetLocalObject ( oDealer, "oPlayer" + s );
			
			SetLocalInt ( oDealer, "i" + s + "isReady", 0 );
			
			// enable buttons
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_shoot", FALSE );
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_bettypes", FALSE );
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_quit", FALSE );
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_betplus", FALSE );
			SetGUIObjectDisabled ( oPC, "br_craps", "craps_button_betminus", FALSE );
			
			sHideString = sHideString + "player" + s + "bg=0;";							
		}	
	}
	
	// update gui
	sHideString = GetStringLeft ( sHideString, GetStringLength(sHideString) - 1 );	
	iRound = GetLocalInt ( oDealer, "iRound" );
	sCurrentPoint = IntToString(GetLocalInt ( oDealer, "iCurrentPoint" ));	
	if ( iRound == 0 ) {
		sTextString = "craps_roundbanner1=Come Out;craps_roundbanner2=Round";			
	} else if ( iRound == 1 ) {
		sTextString = "craps_roundbanner1=Point:;craps_roundbanner2=" + sCurrentPoint;			
	}	
	MPGUIUpdateMultiComponent ( oDealer, "br_craps", "", sTextString, sHideString );
	
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
			MPGUIDisplayComponent ( oDealer, "br_craps", "timerpane", 1 );		
			EndRoundIdleTimer(oDealer);
		} else {
			SetLocalInt ( oDealer, "iIdleTimer", iIdleTimer );			
		}
	}
}


// idle timer

void EndRoundIdleTimer ( object oDealer ) {
	int i, iBallPos, iCurrentBet, iGold, iHalfIdleTimer, iNumPlayers, iTimer, iWheelPos, j, k;
	object oPlayer;
	string s, sComponentString, sInt, sK, sVarName;
	
	// terminate if a round has started
	if ( GetLocalInt ( oDealer, "iInPlay" ) == 1 ) {
		SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 0 );	
		MPGUIDisplayComponent ( oDealer, "br_craps", "timerpane" );			
		return;
	}
	
	iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
	if ( iNumPlayers == 1 ) {
		SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 0 );	
		MPGUIDisplayComponent ( oDealer, "br_craps", "timerpane" );			
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
				SetGUIObjectHidden ( oPlayer, "br_craps", "timerpane", TRUE );	
				
				// clear the table if any bets exist
				sVarName = "iPlayer" + s + "CurrentPlacedBet";
				iCurrentBet = GetLocalInt ( oDealer, sVarName );
				if ( iCurrentBet != 0 ) {
					AssignCommand ( oDealer, PlaySound("it_pickup") );
					ClearPlayerBettingPositions ( oDealer, StringToInt(s) );
					iGold = GetGold(oPlayer);
					GiveGoldToCreature ( oPlayer, iCurrentBet, FALSE );
					iGold = iGold + iCurrentBet;				
				}
				SetGUIObjectText ( oPlayer, "br_craps", "craps_gold", -1, "0" );
				
				// reset table graphics for player's GUI
				ClearGUIChipGraphics ( oDealer, oPlayer );
				for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
					sVarName = "player" + IntToString(i);
					SetGUIObjectText ( oPlayer, "br_craps", sVarName + "name1", -1, "" );
					SetGUIObjectText ( oPlayer, "br_craps", sVarName + "name2", -1, "" );
					SetGUIObjectText ( oPlayer, "br_craps", sVarName + "bet", -1, "" );
					SetGUIObjectHidden ( oPlayer, "br_craps", sVarName +"bg", TRUE );
				}		
				
				for ( i = 4 ; i <= 10 ; i++ ) {
					sVarName = IntToString(i);
					SetGUIObjectHidden ( oPlayer, "br_craps", "craps_puck_on" + sVarName, TRUE );
					if ( i == 6 ) {
						i = i + 1;
					}
				}
				SetGUIObjectHidden ( oPlayer, "br_craps", "craps_puck_off", FALSE );	
				SetGUIObjectHidden ( oPlayer, "br_craps", "craps_message_pane", TRUE );					
				
				// disable buttons
				SetGUIObjectDisabled ( oPlayer, "br_craps", "craps_button_shoot", TRUE );
				SetGUIObjectDisabled ( oPlayer, "br_craps", "craps_button_bettypes", TRUE );
				SetGUIObjectDisabled ( oPlayer, "br_craps", "craps_button_quit", TRUE );
				SetGUIObjectDisabled ( oPlayer, "br_craps", "craps_button_betplus", TRUE );
				SetGUIObjectDisabled ( oPlayer, "br_craps", "craps_button_betminus", TRUE );	
				SetGUIObjectHidden ( oPlayer, "br_craps", "notice_pane", FALSE );
						
				// close gui
				CloseGUIScreen ( oPlayer, "br_craps" );	
				
				// clear player data from dealer
				SetLocalInt ( oDealer, "i" + s + "isPlayer", 0 );
				SetCasinoStatsArrayPlayerStat ( oPlayer, "Craps", "Win", GetLocalInt ( oDealer, "iPlayer" + s + "GoldWon" ) );
				SetCasinoStatsArrayPlayerStat ( oPlayer, "Craps", "Lose", GetLocalInt ( oDealer, "iPlayer" + s + "GoldLost" ) );		
				SetCasinoStatsArrayPlayerStat ( oPlayer, "Craps", "Time", GetPlayerTimePlayed ( oDealer, StringToInt(s) ) );
				iNumPlayers = GetLocalInt ( oDealer, "iNumPlayers" );
				iNumPlayers = iNumPlayers - 1;
				SetLocalInt ( oDealer, "iNumPlayers", iNumPlayers );					
				
				sComponentString = "player" + s + "name1=;player" + s + "name2=" + sDefaultName + ";player" + s + "bet=-";
				MPGUIUpdateMultiComponent ( oDealer, "br_craps", "", sComponentString, "" );				
				
				SendMessageToPC ( oPlayer, "Craps: You have been removed from the table for inactivity." );				
			}
		}	
		SetLocalInt ( oDealer, "iNumPlayers", iNumPlayers );
		MPMessageAllPlayers ( oDealer, "Craps: The table has been cleared of idle players." );		
		MPGUIDisplayComponent ( oDealer, "br_craps", "timerpane" );		
		SetLocalInt ( oDealer, "iEndRoundIdleTimerActive", 0 );		
		
		// start game
		if ( GetLocalInt ( oDealer, "iRound" ) == 0 ) {
			SetLocalInt ( oDealer, "iCurrentPoint", 0 );			
			MPGUIUpdateMultiComponent ( oDealer, "br_craps", "", "craps_message=Come-Out Roll", "craps_message_pane=1" );
			DelayCommand ( 1.5, MPGUIDisplayComponent ( oDealer, "br_craps", "craps_message_pane" ) );	
		}			
				
		SetupRoll(oDealer);						
	} else {
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				// player is human and not readied up yet
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				SetGUIObjectText ( oPlayer, "br_craps", "timerfield", -1, IntToString(iTimer) );
			}
		}
		
		// not counted down yet, iterate
		SetLocalInt ( oDealer, "iIdleTimer", iTimer - 1 );
		DelayCommand ( 1.0, EndRoundIdleTimer(oDealer) );		
	}	
}