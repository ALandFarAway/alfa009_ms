// Black Rain 2009

#include "z_casino_rulespane_include"
#include "z_chinchirorin_include"


void main() {
	int i;
	object oHandler, oPC;
	string sHandlerTag, sOutput;
	
	// set up rules pane
	oPC = GetLastUsedBy();	
	DisplayGuiScreen ( oPC, "br_casino_rulespane", TRUE, "br_casino_rulespane.xml" );
	SetPCRulesPaneData(oPC);	
	SetGUIObjectText ( oPC, "br_casino_rulespane", "rules_banner", -1, "CHINCHIRORIN" );
	
	// set up rules
	sOutput = "Chinchirorin is a simple but exotic game of dice, originally hailing from distant lands.  Players roll three dice against the banker, with the objective of achieving the highest score.  ";
	sOutput = sOutput + "The banker rolls first, and may take three rolls to establish a score, after which the player gets three rolls.  Scoring is achieved by rolling two identical numbers on the three dice, with the third differing number being the score.  ";
	sOutput = sOutput + "If the banker or player is unable to make a score after three rolls, their turn ends and they're considered to have a score of 0.  If the player and banker tie, the round is a wash and no gold is won or lost.\n\n";
	sOutput = sOutput + "Storm:\nThe following dice combinations are known as storms, and immediately end\ the game in a win or a loss.\n\n";
	
	sHandlerTag = GetLocalString ( OBJECT_SELF, "sHandlerTag" );
	if ( sHandlerTag != "" ) {
		// this rules board is tied to a specific handler object
		oHandler = GetObjectByTag(sHandlerTag);

		i = GetLocalInt ( oHandler, "iTripleRatio" );
		if ( i == 0 ) {
			i = iTripleRatio;
		}
		sOutput = sOutput + "Triple 1: Roller loses and pays " + IntToString(i) + "X  the initial wager\n";
		sOutput = sOutput + "Any other triple: Roller wins and receives " + IntToString(i) + "X the initial wager\n";								
		
		i = GetLocalInt ( oHandler, "iStraightRatio" );
		if ( i == 0 ) {
			i = iStraightRatio;
		}	
		sOutput = sOutput + "1-2-3 Low Straight: Roller loses and pays " + IntToString(i) + "X the initial wager\n";
		sOutput = sOutput + "4-5-6 High Straight: Roller wins and receives " + IntToString(i) + "X the initial wager\n\n\n";	
	
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
		sOutput = sOutput + "Triple 1: Roller loses and pays " + IntToString(iTripleRatio) + "X  the initial wager\n";
		sOutput = sOutput + "Any other triple: Roller wins and receives " + IntToString(iTripleRatio) + "X the initial wager\n";								
	
		sOutput = sOutput + "1-2-3 Low Straight: Roller loses and pays " + IntToString(iStraightRatio) + "X the initial wager\n";
		sOutput = sOutput + "4-5-6 High Straight: Roller wins and receives " + IntToString(iStraightRatio) + "X the initial wager\n\n\n";	
	
		sOutput = sOutput + "- Bets from " + IntToString(iMinBet) + " to ";
		sOutput = sOutput + IntToString(iMaxBet) + " gold, bet increments of ";
		sOutput = sOutput + IntToString(iBetIncrement) + " gold.\n";			
	}
		
	SetGUIObjectText ( oPC, "br_casino_rulespane", "rules_text", -1, sOutput );
}