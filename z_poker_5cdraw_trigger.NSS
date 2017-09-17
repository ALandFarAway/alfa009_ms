// Black Rain Software 2009

#include "z_poker_5cdraw_include"


void main() {
	int i, iNumPlayers, iWaitList;
	object oPC;
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
		DisplayGuiScreen ( oPC, "br_poker_5cdraw", TRUE, "br_poker_5cdraw.xml" );
		SetGUIObjectText ( oPC, "br_poker_5cdraw", "banner", -1, sDefaultGameName );
		
		// determine if the player needs to wait for the next hand
		if ( GetLocalInt ( OBJECT_SELF, "iInPlay" ) == 1 ) {
			// player needs to wait for end of hand
			iWaitList = iWaitList + 1;
			SetLocalInt ( OBJECT_SELF, "iWaitList", iWaitList );
			s = "oWaitList" + IntToString(iWaitList);
			SetLocalObject ( OBJECT_SELF, s, oPC );
		} else {
			// player can start immediately, set up player and update player names
			SetUpNewPlayer ( OBJECT_SELF, oPC );
			UpdateGUIPlayerNames(OBJECT_SELF);
		}
	}
	
	// set a position as dealer if none has been set
	if ( GetLocalInt ( OBJECT_SELF, "iDealerPos" ) == 0 ) {
		SetLocalInt ( OBJECT_SELF, "iDealerPos", 1 );
		MPGUIDisplayComponent ( OBJECT_SELF, "br_poker_5cdraw", "player1dealerbutton", 1 );
	}
}