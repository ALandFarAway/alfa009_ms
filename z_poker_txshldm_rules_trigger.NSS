// Black Rain 2009

#include "z_casino_rulespane_include"
#include "z_poker_txshldm_include"


void main() {
	int i;
	object oHandler, oPC;
	string sHandlerTag, sOutput;
	
	// set up rules pane
	oPC = GetLastUsedBy();	
	DisplayGuiScreen ( oPC, "br_casino_rulespane", TRUE, "br_casino_rulespane.xml" );
	SetPCRulesPaneData(oPC);	
	SetGUIObjectText ( oPC, "br_casino_rulespane", "rules_banner", -1, sDefaultGameName );
	
	// set up rules
	sOutput = sDefaultGameName + " is a poker card game variant, with players betting against each other rather than the dealer.  Players are dealt two cards faced down, followed by a round of fixed-limit betting.  Three community cards are then dealt face up, followed by another round of betting.  ";
	sOutput = sOutput + "After that two community cards are dealt face up, one at a time, with a round of betting after each deal.  The goal is to get the best possible Poker hand using any combination of a player's hole cards and the community cards.  ";
	sOutput = sOutput + "During their betting turn players may Call to match other players' bets, Raise to increase the stakes in the pot, or Fold their hand to retire from the round.  Players who do not have enough gold to Call can opt to go All-In, putting all their gold into the pot.  ";
	sOutput = sOutput + "All-In players can continue to the end of the round without contributing any more to the pot, but are eligible to win only as much as their stake from other players.  If an All-In player wins, the remainder of the pot goes to the second highest hand value.\n\n\n";
		
	sHandlerTag = GetLocalString ( OBJECT_SELF, "sHandlerTag" );
	if ( sHandlerTag != "" ) {
		// this rules board is tied to a specific handler object
		oHandler = GetObjectByTag(sHandlerTag);	
		
		i = GetLocalInt ( oHandler, "iAnte" );
		if ( i == 0 ) {
			i = iAnte;
		}
		sOutput = sOutput + "- Each player contributes an ante of " + IntToString(i) + " to the pot before a round.\n";
		i = GetLocalInt ( oHandler, "iInitialBet" );
		if ( i == 0 ) {
			i = iInitialBet;
		}		
		sOutput = sOutput + "- Raising is done in fixed increments of " + IntToString(i) + ", with the value doubled in the final two betting rounds.\n";
		i = GetLocalInt ( oHandler, "iMaxRaises" );
		if ( i == 0 ) {
			i = iMaxRaises;
		}		
		sOutput = sOutput + "- All players may cumulatively raise a maximum of " + IntToString(i) + " times per betting round.\n";								
	} else {	
		sOutput = sOutput + "- Each player contributes an ante of " + IntToString(iAnte) + " to the pot before a round.\n";
		sOutput = sOutput + "- Raising is done in fixed increments of " + IntToString(iInitialBet) + ", with the value doubled in the final two betting rounds.\n";
		sOutput = sOutput + "- All players may cumulatively raise a maximum of " + IntToString(iMaxRaises) + " times per betting round.\n";		
	}
		
	SetGUIObjectText ( oPC, "br_casino_rulespane", "rules_text", -1, sOutput );
}