// Black Rain 2008

#include "z_chinchirorin_include"


void main() {
	int iDealerBusy, iMinBetLocal;
	object oHandler, oPC;
	string s;
	
	oPC = GetLastSpeaker();
	iDealerBusy = GetLocalInt ( OBJECT_SELF, "iDealerBusy" );
	
	if ( iDealerBusy == 0 )	{
		SetLocalInt ( OBJECT_SELF, "iDealerBusy", 1 );
		
		// initiate session timer
		SetPlayerStartTime(OBJECT_SELF);
		
		SetLocalObject ( OBJECT_SELF, "oPlayer", oPC);
		
		// set up the GUI
		DisplayGuiScreen ( oPC, "br_chinchirorin", TRUE, "br_chinchirorin.xml" );
		SetGUIObjectText ( oPC, "br_chinchirorin", "dealertag", -1, GetTag(OBJECT_SELF) );
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_start", FALSE );
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_rules", FALSE );			
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_quit", FALSE );
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_plus", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_minus", FALSE );
		SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(GetGold(oPC)) );
		iMinBetLocal = GetLocalInt ( OBJECT_SELF, "iMinBet" );
		if ( iMinBetLocal == 0 ) {
			iMinBetLocal = iMinBet;
		}
		SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_bet", -1, IntToString(iMinBetLocal) );
		SetLocalInt ( OBJECT_SELF, "iCurrentBet", iMinBetLocal );
		SetLocalInt ( OBJECT_SELF, "iPlayerGoldWon", 0 );
		SetLocalInt ( OBJECT_SELF, "iPlayerGoldLost", 0 );		
		
		// start the idle timer
		if ( iIdleTimer != 0 ) {
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "timerpane", FALSE );
			EndRoundIdleTimer ( OBJECT_SELF, iIdleTimer );
		}
	} else {
		if ( GetGender(oPC) == GENDER_FEMALE ) {
			s = "madam";
		} else {
			s = "sir";
		}
		SpeakString ( "I'm sorry " + s + ", this table is currently full." );
	}
}