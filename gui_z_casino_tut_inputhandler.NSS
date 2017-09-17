// Black Rain 2009

#include "z_casino_tutorial_include"


void main ( string sHandlerTag, string sPCPos, string sAction ) {
	object oHandler, oPC;
	string sVarName;
	
	// get the PC object
	oHandler = GetObjectByTag(sHandlerTag);
	sVarName = "iCasinoTutorialSlot" + sPCPos;
	oPC = GetLocalObject ( oHandler, sVarName + "Player" );

	// disable buttons
	SetGUIObjectDisabled ( oPC, "br_tutorial", "next", TRUE );		
	SetGUIObjectDisabled ( oPC, "br_tutorial", "back", TRUE );			
	SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", TRUE );		

	// set up tutorial state action
	if ( sAction == "next" ) {
		UpdatePCTutorialGUI ( oHandler, StringToInt(sPCPos), 1 );
	} else if ( sAction == "back" ) {	
		UpdatePCTutorialGUI ( oHandler, StringToInt(sPCPos), -1 );	
	} else if ( sAction == "quit" ) {
		ClosePCTutorial ( sHandlerTag, StringToInt(sPCPos) );
	}
}