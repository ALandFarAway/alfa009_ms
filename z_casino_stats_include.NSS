 // Black Rain Software 2009

#include "nw_o0_itemmaker"
#include "y_multiplayer_casino_lib"


const int iMaxLeaderboard = 20;  // maximum number of entries allowed on the leaderboard
const int iMinutesPerGameHour = 60;  // minutes per game in this module, should be set to the same as module properties
const string sLeaderBoardObjTag = "";  // empty string defaults to using module as leaderboard data object

// prototypes

int GetCasinoStatsArrayPosition ( object oPC, int iCreateNewEntry = 1 );
void SetCasinoStatsArrayPlayerStat ( object oPC, string sGameName, string sStatName, int iValue );
void SetPlayerStartTime ( object oHandler, int iPlayerPos = 1 );
int GetPlayerTimePlayed ( object oHandler, int iPlayerPos = 1 );
void PopulateListBoxForPC ( object oPC, string sGameName, string sStatName );


// either return the player's leaderboard array position or create a new position for a new player
// iCreateNewEntry = 1 creates a new player entry if none is found

int GetCasinoStatsArrayPosition ( object oPC, int iCreateNewEntry = 1 ) {
	int i, iCasinoStatsArrayPointer, iStatsArrayPos;
	object oHandler;

	// get the leaderboard data handler object
	if ( sLeaderBoardObjTag == "" ) {
		oHandler = GetModule();	
	} else {
		oHandler = GetObjectByTag(sLeaderBoardObjTag);
	}
	
  	// check to see if player name already exists	
	iStatsArrayPos = GetLocalInt ( oPC, "iCasinoStatsArrayPos" );
	if ( iStatsArrayPos == 0 ) {
		// no variable found on the player object, iterate through the existing list
		iCasinoStatsArrayPointer = GetLocalInt ( oHandler, "iCasinoStatsArrayPointer" );
		for ( i = 1 ; i <= iCasinoStatsArrayPointer ; i++ ) {
			if ( ( GetLocalArrayString ( oHandler, "sCasinoStatsName", i ) == GetName(oPC) ) && ( GetLocalArrayString ( oHandler, "sCasinoStatsPCName", iStatsArrayPos ) == GetPCPlayerName(oPC) ) ) {
				iStatsArrayPos = i;
				break;
			}	
		}			
		
		if ( iStatsArrayPos == 0 ) {
			if ( iCreateNewEntry == 1 ) {
				// no matches found in the list, initiate a new entry
				iCasinoStatsArrayPointer = iCasinoStatsArrayPointer + 1;
				SetLocalInt ( oHandler, "iCasinoStatsArrayPointer", iCasinoStatsArrayPointer );
				iStatsArrayPos = iCasinoStatsArrayPointer;
				SetLocalArrayString ( oHandler, "sCasinoStatsName", iCasinoStatsArrayPointer, GetName(oPC) );
				SetLocalArrayString ( oHandler, "sCasinoStatsPCName", iCasinoStatsArrayPointer, GetPCPlayerName(oPC) );			
				SetLocalInt ( oPC, "iCasinoStatsArrayPos", iCasinoStatsArrayPointer );
			}
		}
	} else {  // check to see if player position is correct
		if ( ( GetLocalArrayString ( oHandler, "sCasinoStatsName", iStatsArrayPos ) != GetName(oPC) ) || ( GetLocalArrayString ( oHandler, "sCasinoStatsPCName", iStatsArrayPos ) != GetPCPlayerName(oPC) ) ) {
			// bad match, iterate through the existing list to see if a good match exists
			iCasinoStatsArrayPointer = GetLocalInt ( oHandler, "iCasinoStatsArrayPointer" );
			iStatsArrayPos = 0;
			for ( i = 1 ; i <= iCasinoStatsArrayPointer ; i++ ) {
				if ( ( GetLocalArrayString ( oHandler, "sCasinoStatsName", i ) == GetName(oPC) ) && ( GetLocalArrayString ( oHandler, "sCasinoStatsPCName", iStatsArrayPos ) == GetPCPlayerName(oPC) ) ) {
					iStatsArrayPos = i;
					break;
				}	
			}			
			
			if ( iStatsArrayPos == 0 ) {
				if ( iCreateNewEntry == 1 ) {			
					// no matches found in the list, initiate a new entry
					iCasinoStatsArrayPointer = iCasinoStatsArrayPointer + 1;
					SetLocalInt ( oHandler, "iCasinoStatsArrayPointer", iCasinoStatsArrayPointer );
					iStatsArrayPos = iCasinoStatsArrayPointer;
					SetLocalArrayString ( oHandler, "sCasinoStatsName", iCasinoStatsArrayPointer, GetName(oPC) );
					SetLocalArrayString ( oHandler, "sCasinoStatsPCName", iCasinoStatsArrayPointer, GetPCPlayerName(oPC) );			
					SetLocalInt ( oPC, "iCasinoStatsArrayPos", iCasinoStatsArrayPointer );
				}
			}		
		}
	}
	
	return iStatsArrayPos;
}

// set the player's current stat from the leaderboard arrays
// sGameName is game name (first leter capitalized)
// sStatName is Win, Lose, and Time
// individual game stats and total stats are updated with each call

void SetCasinoStatsArrayPlayerStat ( object oPC, string sGameName, string sStatName, int iValue ) {
	int i, iCasinoStatsRankingPointer, iPlayerPos, iPosFound, iResult, iTemp;
	object oHandler;
	string sCurrentFavGame, sVarName, sVarNameRanking;
	
	// get the leaderboard data handler object
	if ( sLeaderBoardObjTag == "" ) {
		oHandler = GetModule();	
	} else {
		oHandler = GetObjectByTag(sLeaderBoardObjTag);
	}
	iPlayerPos = GetCasinoStatsArrayPosition(oPC);	
	
	// update the game-specific stat
	sVarName = "i" + sGameName + sStatName;
	iResult = GetLocalArrayInt ( oHandler, sVarName, iPlayerPos );	
	iResult = iResult + iValue;
	SetLocalArrayInt ( oHandler, sVarName, iPlayerPos, iResult );
	
	// update the player's favourite game if necessary
	if ( sStatName == "Time" ) {
		sCurrentFavGame = GetLocalArrayString ( oHandler, "sFavGame", iPlayerPos );
		if ( sCurrentFavGame == "" ) {  // first game played, update current game as favourite
			SetLocalArrayString ( oHandler, "sFavGame", iPlayerPos, sGameName );
		} else {
			if ( iResult > GetLocalArrayInt ( oHandler, "i" + sCurrentFavGame + "Time", iPlayerPos ) ) {
				SetLocalArrayString ( oHandler, "sFavGame", iPlayerPos, sGameName );			
			}
		}
	}	
	
	// check status of leaderboard rankings
	sVarNameRanking = sVarName + "RankPtr";	
	iCasinoStatsRankingPointer = GetLocalInt ( oHandler, sVarNameRanking );
	if ( iCasinoStatsRankingPointer == 0 ) {  // put this stat on the leaderboard with no comparisons
		iCasinoStatsRankingPointer = iCasinoStatsRankingPointer + 1;
		SetLocalInt ( oHandler, sVarNameRanking, iCasinoStatsRankingPointer );		
		SetLocalArrayInt ( oHandler, sVarNameRanking, iCasinoStatsRankingPointer, iPlayerPos );
	} else {  // determine if player already exists in the leaderboard
		i = iCasinoStatsRankingPointer;
		iPosFound = 0;
		while ( ( i >= 1 ) && ( iPosFound == 0 ) ) {
			if ( GetLocalArrayInt ( oHandler, sVarNameRanking, i ) == iPlayerPos ) {
				iPosFound = 1;
			} else {
				i = i - 1;
			}
		}
		
		if ( iPosFound == 0 ) {  // player not in leaderboard
			// initialize the player as one entry beyond current last position
			iCasinoStatsRankingPointer = iCasinoStatsRankingPointer + 1;
			if ( iCasinoStatsRankingPointer <= iMaxLeaderboard ) {
				SetLocalInt ( oHandler, sVarNameRanking, iCasinoStatsRankingPointer );			
				SetLocalArrayInt ( oHandler, sVarNameRanking, iCasinoStatsRankingPointer, iPlayerPos );
			}
			i = iCasinoStatsRankingPointer;
		}
		
		iTemp = GetLocalArrayInt ( oHandler, sVarNameRanking, i - 1 );
		while ( ( i > 1 ) && ( iResult > GetLocalArrayInt ( oHandler, sVarName, iTemp ) ) ) {
			SetLocalArrayInt ( oHandler, sVarNameRanking, i - 1, iPlayerPos );
			// current record needs to be moved up one place
			if ( i <= iMaxLeaderboard ) {  // displaced player needs to be moved down one rank
				SetLocalArrayInt ( oHandler, sVarNameRanking, i, iTemp );
			}
				
			i = i - 1;
			iTemp = GetLocalArrayInt ( oHandler, sVarNameRanking, i - 1 );
		}		
	}
		
	// update total game stats
	sVarName = "iTotal" + sStatName;
	iResult = GetLocalArrayInt ( oHandler, sVarName, iPlayerPos );	
	iResult = iResult + iValue;
	SetLocalArrayInt ( oHandler, sVarName, iPlayerPos, iResult );
	
	// check status of leaderboard rankings
	sVarNameRanking = sVarName + "RankPtr";	
	iCasinoStatsRankingPointer = GetLocalInt ( oHandler, sVarNameRanking );
	if ( iCasinoStatsRankingPointer == 0 ) {  // put this stat on the leaderboard with no comparisons
		iCasinoStatsRankingPointer = iCasinoStatsRankingPointer + 1;
		SetLocalInt ( oHandler, sVarNameRanking, iCasinoStatsRankingPointer );		
		SetLocalArrayInt ( oHandler, sVarNameRanking, iCasinoStatsRankingPointer, iPlayerPos );
	} else {  // determine if player already exists in the leaderboard
		i = iCasinoStatsRankingPointer;
		iPosFound = 0;
		while ( ( i >= 1 ) && ( iPosFound == 0 ) ) {
			if ( GetLocalArrayInt ( oHandler, sVarNameRanking, i ) == iPlayerPos ) {
				iPosFound = 1;
			} else {
				i = i - 1;
			}
		}
		
		if ( iPosFound == 0 ) {  // player not in leaderboard
			// initialize the player as one entry beyond current last position
			iCasinoStatsRankingPointer = iCasinoStatsRankingPointer + 1;
			if ( iCasinoStatsRankingPointer <= iMaxLeaderboard ) {
				SetLocalInt ( oHandler, sVarNameRanking, iCasinoStatsRankingPointer );			
				SetLocalArrayInt ( oHandler, sVarNameRanking, iCasinoStatsRankingPointer, iPlayerPos );
			}		
			i = iCasinoStatsRankingPointer;
		}
		
		iTemp = GetLocalArrayInt ( oHandler, sVarNameRanking, i - 1 );
		while ( ( i > 1 ) && ( iResult > GetLocalArrayInt ( oHandler, sVarName, iTemp ) ) ) {
			SetLocalArrayInt ( oHandler, sVarNameRanking, i - 1, iPlayerPos );
			// current record needs to be moved up one place
			if ( i <= iMaxLeaderboard ) {  // displaced player needs to be moved down one rank
				SetLocalArrayInt ( oHandler, sVarNameRanking, i, iTemp );
			}
				
			i = i - 1;
			iTemp = GetLocalArrayInt ( oHandler, sVarNameRanking, i - 1 );
		}		
	}
}


// set the game start timer for a player
// for single player games only oHandler is necessary as a parameter

void SetPlayerStartTime ( object oHandler, int iPlayerPos = 1 ) {
	string sVarName;

	sVarName = "z_casino_stats_iPlayer" + IntToString(iPlayerPos) + "Timer";
	SetLocalInt ( oHandler, sVarName + "Year", GetCalendarYear() );
	SetLocalInt ( oHandler, sVarName + "Month", GetCalendarMonth() );
	SetLocalInt ( oHandler, sVarName + "Day", GetCalendarDay() );
	SetLocalInt ( oHandler, sVarName + "Hour", GetTimeHour() );
	SetLocalInt ( oHandler, sVarName + "Minute", GetTimeMinute() );	
}


// get the number of minutes played comparing current time against time set at game start
// for single player games only oHandler is necessary as a parameter

int GetPlayerTimePlayed ( object oHandler, int iPlayerPos = 1 ) {
	int iCurrentValue, iStoredValue, iResult;
	string sVarName;

	iResult = 0;
	sVarName = "z_casino_stats_iPlayer" + IntToString(iPlayerPos) + "Timer";
	
	iCurrentValue = GetCalendarYear();
	iStoredValue = GetLocalInt ( oHandler, sVarName + "Year" );
	iResult = ( iCurrentValue - iStoredValue ) * 8064 * iMinutesPerGameHour;
	
	iCurrentValue = GetCalendarMonth();
	iStoredValue = GetLocalInt ( oHandler, sVarName + "Month" );
	if ( iCurrentValue > iStoredValue ) {
		iResult = iResult + ( ( iCurrentValue - iStoredValue ) * 672 * iMinutesPerGameHour );
	} else if ( iCurrentValue < iStoredValue ) {
		iResult = iResult - ( ( iStoredValue - iCurrentValue ) * 672 * iMinutesPerGameHour );	
	}
	
	iCurrentValue = GetCalendarDay();
	iStoredValue = GetLocalInt ( oHandler, sVarName + "Day" );
	if ( iCurrentValue > iStoredValue ) {
		iResult = iResult + ( ( iCurrentValue - iStoredValue ) * 24 * iMinutesPerGameHour );
	} else if ( iCurrentValue < iStoredValue ) {
		iResult = iResult - ( ( iStoredValue - iCurrentValue ) * 24 * iMinutesPerGameHour );	
	}
	
	iCurrentValue = GetTimeHour();
	iStoredValue = GetLocalInt ( oHandler, sVarName + "Hour" );
	if ( iCurrentValue > iStoredValue ) {
		iResult = iResult + ( ( iCurrentValue - iStoredValue ) * iMinutesPerGameHour );
	} else if ( iCurrentValue < iStoredValue ) {
		iResult = iResult - ( ( iStoredValue - iCurrentValue ) * iMinutesPerGameHour );	
	}		
	
	iCurrentValue = GetTimeMinute();
	iStoredValue = GetLocalInt ( oHandler, sVarName + "Minute" );
	if ( iCurrentValue > iStoredValue ) {
		iResult = iResult + ( iCurrentValue - iStoredValue );
	} else if ( iCurrentValue < iStoredValue ) {
		iResult = iResult - ( iStoredValue - iCurrentValue );	
	}		
	
	return iResult;
}


// update the player's GUI listbox display

void PopulateListBoxForPC ( object oPC, string sGameName, string sStatName ) {
	int i, iCasinoStatsRankingPointer, iHoursPlayed, iMinutesPlayed, iPlayerInLeaderboard, iPlayerPos, iPointerRef;
	object oHandler;
	string s, sOutput, sTexture, sVarName, sVarNameRankPtr;
	
	// get the leaderboard data handler object
	if ( sLeaderBoardObjTag == "" ) {
		oHandler = GetModule();	
	} else {
		oHandler = GetObjectByTag(sLeaderBoardObjTag);
	}
	
	// find the player's array position
	iPlayerPos = GetCasinoStatsArrayPosition ( oPC, 0 );
	
	// clear the current listbox contents
	ClearListBox ( oPC, "br_casino_stats", "stats_listbox" );
	
	// find the number of leaderboard entries
	sVarName = "i" + sGameName;
	sVarNameRankPtr = sVarName + sStatName + "RankPtr";
	iCasinoStatsRankingPointer = GetLocalInt ( oHandler, sVarNameRankPtr );
	
	// iterate through the leaderboard for this particular game and stat combination
	iPlayerInLeaderboard = 0;	
	for ( i = 1 ; i <= iCasinoStatsRankingPointer ; i++ ) {
		// create the appropriate listbox entry and populate it
		s = IntToString(i);
		iPointerRef = GetLocalArrayInt ( oHandler, sVarNameRankPtr, i );
		if ( iPointerRef == iPlayerPos ) {
			iPlayerInLeaderboard = 1;
			sTexture = "listbox_bg=br_box_ltblue.tga";
		} else {
			sTexture = "listbox_bg=br_box_black.tga";
		}
		
		sOutput = "listbox_text_rank=" + s + ";";
		if ( iUsePCName == 1 ) {
			sOutput = sOutput + "listbox_text_name=" + GetLocalArrayString ( oHandler, "sCasinoStatsName", iPointerRef ) + " - " + GetLocalArrayString ( oHandler, "sCasinoStatsPCName", iPointerRef ) + ";";
		} else {
			sOutput = sOutput + "listbox_text_name=" + GetLocalArrayString ( oHandler, "sCasinoStatsName", iPointerRef ) + ";";		
		}
		
		sOutput = sOutput + "listbox_text_won=" + IntToString(GetLocalArrayInt ( oHandler, sVarName + "Win", iPointerRef )) + ";";		
		sOutput = sOutput + "listbox_text_lost=" + IntToString(GetLocalArrayInt ( oHandler, sVarName + "Lose", iPointerRef )) + ";";
		iHoursPlayed = 0;
		iMinutesPlayed = GetLocalArrayInt ( oHandler, sVarName + "Time", iPointerRef );
		while ( iMinutesPlayed >= 60 ) {
			iHoursPlayed = iHoursPlayed + 1;
			iMinutesPlayed = iMinutesPlayed - 60;
		}
		if ( iHoursPlayed > 0 ) {
			sOutput = sOutput + "listbox_text_time=" + IntToString(iHoursPlayed) + "h " + IntToString(iMinutesPlayed) + "m;";
		} else {
			sOutput = sOutput + "listbox_text_time=" + IntToString(iMinutesPlayed) + "m;";
		}
		sOutput = sOutput + "listbox_text_favgame=" + GetLocalArrayString ( oHandler, "sFavGame", iPointerRef );		
		AddListBoxRow ( oPC, "br_casino_stats", "stats_listbox", "row" + s, sOutput, sTexture, "", "" );
	}
	
	// if the player wasn't part of the leaderboard create a new entry at bottom for player
	if ( ( iPlayerInLeaderboard == 0 ) && ( iPlayerPos != 0 ) ) {
		sOutput = "listbox_text_rank=-;";
		if ( iUsePCName == 1 ) {
			sOutput = sOutput + "listbox_text_name=" + GetName(oPC) + " - " + GetPCPlayerName(oPC) + ";";
		} else {
			sOutput = sOutput + "listbox_text_name=" + GetName(oPC) + ";";		
		}
		
		sOutput = sOutput + "listbox_text_won=" + IntToString(GetLocalArrayInt ( oHandler, sVarName + "Win", iPlayerPos )) + ";";		
		sOutput = sOutput + "listbox_text_lost=" + IntToString(GetLocalArrayInt ( oHandler, sVarName + "Lose", iPlayerPos )) + ";";				
		iHoursPlayed = 0;
		iMinutesPlayed = GetLocalArrayInt ( oHandler, sVarName + "Time", iPointerRef );
		while ( iMinutesPlayed >= 60 ) {
			iHoursPlayed = iHoursPlayed + 1;
			iMinutesPlayed = iMinutesPlayed - 60;
		}
		if ( iHoursPlayed > 0 ) {
			sOutput = sOutput + "listbox_text_time=" + IntToString(iHoursPlayed) + "h " + IntToString(iMinutesPlayed) + "m;";
		} else {
			sOutput = sOutput + "listbox_text_time=" + IntToString(iMinutesPlayed) + "m;";
		}
		sOutput = sOutput + "listbox_text_favgame=" + GetLocalArrayString ( oHandler, "sFavGame", iPlayerPos );		
		AddListBoxRow ( oPC, "br_casino_stats", "stats_listbox", "row" + s, sOutput, "listbox_bg=br_box_ltblue.tga", "", "" );	
	}
}