// Black Rain 2008

#include "nw_o0_itemmaker"
#include "z_slots_include"


void main() {
	int i, iMinBetLocal, iOccupied, iReelPos;
	object oPC;
	string s, sInt;
	
	oPC = GetLastUsedBy();
	iOccupied = GetLocalInt ( OBJECT_SELF, "iOccupied" );
	
	if ( iOccupied == 0 ) {
		SetLocalInt ( OBJECT_SELF, "iOccupied", 1 );
		
		// initiate session timer
		SetPlayerStartTime(OBJECT_SELF);
		
		SetLocalObject ( OBJECT_SELF, "oPlayer", oPC);
		
		// set up the GUI
		DisplayGuiScreen ( oPC, "br_slots", TRUE, "br_slots.xml" );
		SetGUIObjectText ( oPC, "br_slots", "dealertag", -1, GetTag(OBJECT_SELF) );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_spin", FALSE );			
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_payouts", FALSE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_quit", FALSE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betplus", FALSE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betminus", FALSE );				
		iMinBetLocal = GetLocalInt ( OBJECT_SELF, "iMinBet" );
		if ( iMinBetLocal == 0 ) {
			iMinBetLocal = iMinBet;
		}
		SetLocalInt ( OBJECT_SELF, "iCurrentBet", iMinBetLocal );
		SetGUIObjectText ( oPC, "br_slots", "slots_text_gold", -1, IntToString(GetGold(oPC)) );
		SetGUIObjectText ( oPC, "br_slots", "slots_text_bet", -1, IntToString(iMinBetLocal) );		
		SetLocalInt ( OBJECT_SELF, "iPlayerGoldWon", 0 );
		SetLocalInt ( OBJECT_SELF, "iPlayerGoldLost", 0 );		
		
		// generate starting states for each reel and display them on GUI
		for ( i = 1 ; i <=3 ; i++ ) {
			sInt = IntToString(i);
			iReelPos = GetLocalInt ( OBJECT_SELF, "reel" + sInt + "Pos" );
			iReelPos = ( ( Random(22) + 1 ) * iPictureHeight ) + ( iPictureHeight / 2 );		
			s = "slotwindow" + sInt + "_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );		
			if ( iReelPos > iImageHeight + 1 ) {
				iReelPos = iReelPos - iImageHeight;
				s = "slotwindow" + sInt + "_" + IntToString(iReelPos);
				SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );							
			} else if ( iReelPos < iLastFrame - iImageHeight ) {
				s = "slotwindow" + sInt + "_" + IntToString ( iReelPos + iImageHeight );
				SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );				
			}
			SetLocalInt ( OBJECT_SELF, "iReel" + sInt + "Pos", iReelPos );
		}		
		
		// start the idle timer
		if ( iIdleTimer != 0 ) {
			SetGUIObjectHidden ( oPC, "br_slots", "timerpane", FALSE );
			EndRoundIdleTimer ( OBJECT_SELF, iIdleTimer );
		}		
	} else {
		SendMessageToPC ( oPC, "This slot machine is currently in use." );
	}	
}