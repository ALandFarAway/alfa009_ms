// Black Rain 2009

#include "z_casino_rulespane_include"
#include "z_craps_include"


void main() {
	int i;
	object oHandler, oPC;
	string sHandlerTag, sOutput;
	
	// set up rules pane
	oPC = GetLastUsedBy();	
	DisplayGuiScreen ( oPC, "br_casino_rulespane", TRUE, "br_casino_rulespane.xml" );
	SetPCRulesPaneData(oPC);	
	SetGUIObjectText ( oPC, "br_casino_rulespane", "rules_banner", -1, "CRAPS" );
	
	// set up rules
	sOutput = "Craps is a dice-based game which allows players many options in betting.  The game is divided into rounds, with each round consisting of one or more rolls of the dice with a betting phase between each roll.  ";
	sOutput = sOutput + "The first roll of each round is called the Come-Out Roll, and players who wish to participate must bet on the Pass or Don't Pass Lines.  Players may not bet on Come or Don't Come at this time.  ";
	sOutput = sOutput + "After betting is concluded the dice is thrown for the Come-Out Roll.  Pass Line bets win on a roll of 7 or 11, and lose on a roll of 2, 3, or 12.  Don't Pass wins on 2 or 3, lose on 7 or 11, and tie on 12.  ";
	sOutput = sOutput + "These rolls end the round, and the next roll is again a Come-Out Roll.  On any other roll value, a Point is established and the current round continues with more rolls.  Rolls continue until either a 7 is rolled or the point value is rolled again.  ";
	sOutput = sOutput + "Pass Line bets win if the point value is rolled again before 7, while Don't Pass wins in the opposite case.  ";
	sOutput = sOutput + "During subsequent rolls in a round players may bet on Come or Don't Come, and may not bet on Pass or Don't Pass.  These bets resolve the same way as Pass and Don't Pass, and on point-establishing roll values the wager is moved to the appropriate place in the number boxes to denote that number as a point for a specific player.  ";
	sOutput = sOutput + "Those are the basic bets involved in Craps, but there are many other bet types available for either single or multiple rolls.  Check the Craps betting table for further details.  Bets can be placed and modified via left click, and removed via right click.\n\n\n";	
	
	sHandlerTag = GetLocalString ( OBJECT_SELF, "sHandlerTag" );
	if ( sHandlerTag != "" ) {
		// this rules board is tied to a specific handler object
		oHandler = GetObjectByTag(sHandlerTag);

		i = GetLocalInt ( oHandler, "iMinBet" );
		if ( i == 0 ) {
			i = iMinBet;
		}			
		sOutput = sOutput + "- Bets from " + IntToString(i) + " to ";
		i = GetLocalInt ( oHandler, "iMaxBet" );
		if ( i == 0 ) {
			i = iMaxBet;
		}			
		sOutput = sOutput + IntToString(i) + " gold, bet increments of ";
		i = GetLocalInt ( oHandler, "iBetIncrement" );
		if ( i == 0 ) {
			i = iBetIncrement;
		}			
		sOutput = sOutput + IntToString(i) + " gold.\n";						
	} else {
		sOutput = sOutput + "- Bets from " + IntToString(iMinBet) + " to ";
		sOutput = sOutput + IntToString(iMaxBet) + " gold, bet increments of ";
		sOutput = sOutput + IntToString(iBetIncrement) + " gold.\n";			
	}
		
	SetGUIObjectText ( oPC, "br_casino_rulespane", "rules_text", -1, sOutput );
}