// Black Rain Software 2009


#include "z_casino_stats_include"


void main() {
	int i;
	object oPC;
	string sPlayerPos;
	
	oPC = GetLastUsedBy();
	
	// write the PC object to the first open slot
	i = 1;
	sPlayerPos = IntToString(i);
	while ( GetLocalInt ( OBJECT_SELF, sPlayerPos + "isPlayer" ) == 1 ) {
		i = i + 1;
		sPlayerPos = IntToString(i);
	}
	SetLocalInt ( OBJECT_SELF, sPlayerPos + "isPlayer", 1 );
	SetLocalObject ( OBJECT_SELF, "oPlayer" + sPlayerPos, oPC );
	
	// initialize board	
	DisplayGuiScreen ( oPC, "br_casino_stats", TRUE, "br_casino_stats.xml" );	
	SetGUIObjectText ( oPC, "br_casino_stats", "playerpos", -1, sPlayerPos );
	SetGUIObjectText ( oPC, "br_casino_stats", "handlertag", -1, GetTag(OBJECT_SELF) );
	SetGUIObjectText ( oPC, "br_casino_stats", "lastgame", -1, "Total" );
	SetGUIObjectText ( oPC, "br_casino_stats", "laststat", -1, "Win" );
	SetGUIObjectText ( oPC, "br_casino_stats", "sortdesc", -1, "Displaying: Total Winnings" );			
	
	// populate the listbox
	PopulateListBoxForPC ( oPC, "Total", "Win" );
}