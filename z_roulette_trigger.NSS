// Black Rain 2009

#include "z_roulette_include"


void main() {
	int i, iNumPlayers, iWaitList;
	object oHandler, oPC;
	string s;
	
	oPC = GetLastSpeaker();
	
	iNumPlayers = GetLocalInt ( OBJECT_SELF, "iNumPlayers" );
	iWaitList = GetLocalInt ( OBJECT_SELF, "iWaitList" );	
	if ( iNumPlayers + iWaitList == iNumPlayersAllowed ) {
		if ( GetGender(oPC) == GENDER_FEMALE ) {
			s = "madam";
		} else {
			s = "sir";
		}
		SpeakString ( "I'm sorry " + s + ", this table is currently full." );
	} else {
		// initialize board			
		DisplayGuiScreen ( oPC, "br_roulette", FALSE, "br_roulette.xml" );
		
		// determine if the player needs to wait for the next hand
		if ( GetLocalInt ( OBJECT_SELF, "iInPlay" ) == 1 ) {
			// player needs to wait for end of spin
			iWaitList = iWaitList + 1;
			SetLocalInt ( OBJECT_SELF, "iWaitList", iWaitList );
			s = "oWaitList" + IntToString(iWaitList);
			SetLocalObject ( OBJECT_SELF, s, oPC );
		} else {
			// player can start immediately, set up player and update player names
			SetUpNewPlayer ( OBJECT_SELF, oPC );
			UpdateGUIPlayerList(OBJECT_SELF);		
		}
	}
}