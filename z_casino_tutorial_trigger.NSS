// Black Rain 2009

#include "z_casino_tutorial_include"


void main ( string sGameName ) {
	int iPCPos;
	object oPC;
	
	oPC = GetLastSpeaker();	
	DisplayGuiScreen ( oPC, sGameName, TRUE, sGameName + ".xml" );		
	DisplayGuiScreen ( oPC, "br_tutorial", TRUE, "br_tutorial.xml" );
	SetPCTutorialData ( oPC, sGameName );
}