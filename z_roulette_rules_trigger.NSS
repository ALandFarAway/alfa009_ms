// Black Rain 2009

#include "z_casino_rulespane_include"
#include "z_roulette_include"


void main() {
	int i;
	object oHandler, oPC;
	string sHandlerTag, sOutput;
	
	// set up rules pane
	oPC = GetLastUsedBy();	
	DisplayGuiScreen ( oPC, "br_casino_rulespane", TRUE, "br_casino_rulespane.xml" );
	SetPCRulesPaneData(oPC);	
	SetGUIObjectText ( oPC, "br_casino_rulespane", "rules_banner", -1, "ROULETTE" );
	
	// set up rules
	sOutput = "Roulette is a game in which players bet on the outcome of a spinning wheel.  The wheel is composed of 38 slots, numbers 1-36 in black or red, with 0 and 00 which are neither black nor red.  ";
	sOutput = sOutput + "Before each spin players may put down any number of bets.  Single number bets are placed in the middle of their number boxes.  Two-number split bets are placed on the dividing line between the boxes.  Three number street bets are placed in the empty box above each three number line, or in the intersections of the 0-1-2 and 00-2-3 boxes.  Four number corner bets are placed on the corner between four numbers.  ";
	sOutput = sOutput + "The unique five number bet, covering 0-00-1-2-3, is placed on the intersection of the 0-00-2 boxes.  Six number or double line bets, representing bets on two adjacent three number line bets, are placed on the line between the line bet boxes.  Players may also bet on one-third or one-half of the board at a time by placing their chips in the indicated boxes.  ";	
	sOutput = sOutput + "Bets can be placed and modified via left click, and removed via right click.\n\n\n";
	
	sHandlerTag = GetLocalString ( OBJECT_SELF, "sHandlerTag" );
	if ( sHandlerTag != "" ) {
		// this rules board is tied to a specific handler object
		oHandler = GetObjectByTag(sHandlerTag);	
		
		i = GetLocalInt ( oHandler, "iMinBet" );
		if ( i == 0 ) {
			i = iMinBet;
		}
		sOutput = sOutput + "- The minimum bet is " + IntToString(i) + ", there is no maximum bet limit";
		i = GetLocalInt ( oHandler, "iBetIncrement" );
		if ( i == 0 ) {
			i = iBetIncrement;
		}		
		sOutput = sOutput + "- Bets are increased in increments of " + IntToString(i);						
	} else {
		sOutput = sOutput + "- The minimum bet is " + IntToString(iMinBet) + ", there is no maximum bet limit";
		sOutput = sOutput + "- Bets are increased in increments of " + IntToString(iBetIncrement);
	}
		
	SetGUIObjectText ( oPC, "br_casino_rulespane", "rules_text", -1, sOutput );
}