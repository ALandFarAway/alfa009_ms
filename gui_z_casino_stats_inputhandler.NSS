// Black Rain Software 2009

#include "z_casino_stats_include"

void main ( string sHandlerTag, string sPlayerPos, string sAction, string sGameName, string sStatName ) {
	object oHandler, oPC;
	string sDesc;
	
	oHandler = GetObjectByTag(sHandlerTag);
	oPC = GetLocalObject ( oHandler, "oPlayer" + sPlayerPos );
	
	if ( sAction == "sort" ) {
		// write the current game and stat to player's gui hidden fields
		SetGUIObjectText ( oPC, "br_casino_stats", "lastgame", -1, sGameName );
		SetGUIObjectText ( oPC, "br_casino_stats", "laststat", -1, sStatName );	
		
		// update game name description, this is where game names that aren't the same
		// as their system data names need to be checked
		if ( sGameName == "TexasHoldem" ) {
			sDesc = "Texas Hold'em";
		} else if ( sGameName == "5CardDraw" ) {
			sDesc = "Five Card Draw";
		} else if ( sGameName == "7CardStud" ) {
			sDesc = "Seven Card Stud";
		} else {
			sDesc = sGameName;
		}
		
		// update stat description
		if ( sStatName == "Win" ) {
			sDesc = sDesc + " Winnings";		
		} else if ( sStatName == "Lose" ) {
			sDesc = sDesc + " Losses";		
		} else if ( sStatName == "Time" ) {
			sDesc = sDesc + " Time Played";		
		}
		
		SetGUIObjectText ( oPC, "br_casino_stats", "sortdesc", -1, "Displaying: " + sDesc);		
		
		// update listbox
		PopulateListBoxForPC ( oPC, sGameName, sStatName );		
	} else if ( sAction == "exit" ) {
		// remove player from handler and close gui
		SetLocalInt ( oHandler, sPlayerPos + "isPlayer", 0 );
		CloseGUIScreen ( oPC, "br_casino_stats" );
	}
}