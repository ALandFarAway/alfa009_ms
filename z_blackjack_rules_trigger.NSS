// Black Rain 2009

#include "z_casino_rulespane_include"
#include "z_blackjack_include"


void main() {
	float f;
	int i;
	object oHandler, oPC;
	string sHandlerTag, sOutput;
	
	// set up rules pane
	oPC = GetLastUsedBy();	
	DisplayGuiScreen ( oPC, "br_casino_rulespane", TRUE, "br_casino_rulespane.xml" );
	SetPCRulesPaneData(oPC);	
	SetGUIObjectText ( oPC, "br_casino_rulespane", "rules_banner", -1, "BLACKJACK" );
	
	// set up rules
	sOutput = "The goal of Blackjack is to get a hand of cards as close to 21 as possible without going over.  Ace cards can be valued 1 or 11, and face cards are valued at 10.\n\n";
	sOutput = sOutput + "At the beginning of a round both the player and dealer are dealt a hand of two cards.  Players can get an additional card by signaling for 'hit', or end the turn by calling for 'stand'.  ";
	sOutput = sOutput + "On the first act of each hand players can also call for 'double down', taking only one extra card while doubling the wager.  If the player's two card hand are of equal value the player can also call for a 'split', allowing players to place an additional wager of equal value to split the two cards and play two hands.\n\n";
	sOutput = sOutput + "When the player stands or goes over 21 (goes bust) on all hands, then the dealer's turn begins until he stands or busts.  Dealers always hit under 17 and stand 17 and over.  The higher card hand that's not busted is the winner.  Dealer wins if both player and dealer hands bust.\n\n\n";
	sOutput = sOutput + "House Rules:\n\n";
	
	sHandlerTag = GetLocalString ( OBJECT_SELF, "sHandlerTag" );
	if ( sHandlerTag != "" ) {
		// this rules board is tied to a specific handler object
		oHandler = GetObjectByTag(sHandlerTag);
		
		i = GetLocalInt ( oHandler, "iDealerWinsTies" );
		if ( i == 0 ) {
			i = iDealerWinsTies;
		}
		if ( i == 1 ) {
			sOutput = sOutput + "- Ties are won by the dealer.\n";
		}
		
		i = GetLocalInt ( oHandler, "iDoubleExposure" );
		if ( i == 0 ) {
			i = iDoubleExposure;
		}		
		if ( i == 1 ) {
			sOutput = sOutput + "- Dealer's first card dealt face up.\n";		
		}
		
		i = GetLocalInt ( oHandler, "iHard17" );
		if ( i == 0 ) {
			i = iHard17;
		}			
		if ( i == 1 ) {
			sOutput = sOutput + "- Dealer stands on hard 17s only.\n";		
		}
		
		i = GetLocalInt ( oHandler, "iFiveCardCharlie" );
		if ( i == 0 ) {
			i = iFiveCardCharlie;
		}				
		if ( i == 1 ) {
			sOutput = sOutput + "- If player draws five additional cards without busting player wins automatically.\n";		
		}
		
		f = GetLocalFloat ( oHandler, "fNaturalPayoff" );
		if ( f == 0.0 ) {
			f = fNaturalPayoff;
		}
		f = f * 100;
		sOutput = sOutput + "- Natural Blackjacks (player's two dealt cards total 21) pay off at " + IntToString(FloatToInt(f)) + "%\n";
		
		sOutput = sOutput + "-number of decks used: " + IntToString(iNumDecks) + "\n\n";

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
		if ( iDealerWinsTies == 1 ) {
			sOutput = sOutput + "- Ties are won by the dealer.\n";
		}
		
		if ( iDoubleExposure == 1 ) {
			sOutput = sOutput + "- Dealer's first card dealt face up.\n";		
		}
		
		if ( iHard17 == 1 ) {
			sOutput = sOutput + "- Dealer stands on hard 17s only.\n";		
		}
		
		if ( iFiveCardCharlie == 1 ) {
			sOutput = sOutput + "- If player draws five additional cards without busting player wins automatically.\n";		
		}
		
		f = fNaturalPayoff * 100;
		sOutput = sOutput + "- Natural Blackjacks (player's two dealt cards total 21) pay off at " + IntToString(FloatToInt(f)) + "%\n";
		
		sOutput = sOutput + "-number of decks used: " + IntToString(iNumDecks) + "\n\n";
		
		sOutput = sOutput + "- Bets from " + IntToString(iMinBet) + " to ";
		sOutput = sOutput + IntToString(iMaxBet) + " gold, bet increments of ";
		sOutput = sOutput + IntToString(iBetIncrement) + " gold.\n";									
	}
		
	SetGUIObjectText ( oPC, "br_casino_rulespane", "rules_text", -1, sOutput );
}