// 2009 Black Rain Software

// function prototypes
void Poker_HandsTutorial_txshldm_CleanUpState ( object oPC );
void Poker_HandsTutorial_txshldm_CloseTutorial ( object oPC );


// main function
void Poker_HandsTutorial_ChangeState ( object oPC, int iState ) {
	string sDisplayString;
	
	if ( iState == 1 ) {
		sDisplayString = "In all variants of poker, the winning player is determined by comparing players' five card hands.  Aces are high in poker, meaning that they have a higher card value than Kings.  Suits all have equal value, meaning that an Ace of Spads and an Ace of Hearts are tie cards.";
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", TRUE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );				
	} else if ( iState == 2 ) {
		sDisplayString = "The highest ranked hand in poker is the Royal Flush.  This hand consists of an Ace, King, Queen, Jack, and Ten, all of the same suit.  This hand beats all other poker hands, and tie with other Royal Flushes.";	
		SetGUITexture ( oPC, "br_poker_handstutorial", "card1", "br_card_hear1.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card1", FALSE );
		SetGUITexture ( oPC, "br_poker_handstutorial", "card2", "br_card_hear13.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card3", "br_card_hear12.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card4", "br_card_hear11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card5", "br_card_hear10.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card5", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 3 ) {
		sDisplayString = "The second highest hand is a Straight Flush, consisting of five sequential cards of the same suit.  Note that while Aces are normally high cards, in the case of a 2-3-4-5 hand they can also serve as a low card to complete the straight.  In the case of a tied hand rank the tie is broken by the high card.";	
		SetGUITexture ( oPC, "br_poker_handstutorial", "card1", "br_card_spad1.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card1", FALSE );
		SetGUITexture ( oPC, "br_poker_handstutorial", "card2", "br_card_spad2.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card3", "br_card_spad3.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card4", "br_card_spad4.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card5", "br_card_spad5.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card5", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 4 ) {
		sDisplayString = "The third highest hand is the Four of a Kind, consisting of four identical value cards plus any other card.  Ties are broken by first comparing the value of the quad cards, then the value of the fifth card if necessary.";
		SetGUITexture ( oPC, "br_poker_handstutorial", "card1", "br_card_club6.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card1", FALSE );
		SetGUITexture ( oPC, "br_poker_handstutorial", "card2", "br_card_diam6.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card3", "br_card_spad6.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card4", "br_card_hear6.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card5", "br_card_hear8.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card5", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 5 ) {
		sDisplayString = "The fourth highest ranked hand in poker is the Full House, a hand consisting of a triplet plus a pair.  Ties are broken by first comparing the triplets values, then the pairs'.";
		SetGUITexture ( oPC, "br_poker_handstutorial", "card1", "br_card_spad10.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card1", FALSE );
		SetGUITexture ( oPC, "br_poker_handstutorial", "card2", "br_card_hear10.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card3", "br_card_club10.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card4", "br_card_hear1.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card5", "br_card_diam1.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card5", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 6 ) {
		sDisplayString = "The fifth highest hand in poker is a Flush, which consists of five cards of the same suit of any value.  Ties are broken by first comparing the highest ranked cards, then the next, and so on.";
		SetGUITexture ( oPC, "br_poker_handstutorial", "card1", "br_card_diam3.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card1", FALSE );
		SetGUITexture ( oPC, "br_poker_handstutorial", "card2", "br_card_diam13.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card3", "br_card_diam8.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card4", "br_card_diam6.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card5", "br_card_diam11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card5", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 7 ) {
		sDisplayString = "The sixth highest ranked hand in poker is the Straight, five sequential cards which are not of the same suit.  Ties are broken by high card value.";
		SetGUITexture ( oPC, "br_poker_handstutorial", "card1", "br_card_spad2.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card1", FALSE );
		SetGUITexture ( oPC, "br_poker_handstutorial", "card2", "br_card_club3.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card3", "br_card_hear4.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card4", "br_card_spad5.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card5", "br_card_hear6.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card5", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 8 ) {
		sDisplayString = "The seventh highest ranked hand in poker is the Three of a Kind, with a trio of identical value cards plus any two other cards.  Ties are broken by first comparing the triplet values, and then the other two cards in order.";
		SetGUITexture ( oPC, "br_poker_handstutorial", "card1", "br_card_diam9.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card1", FALSE );
		SetGUITexture ( oPC, "br_poker_handstutorial", "card2", "br_card_spad9.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card3", "br_card_club9.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card4", "br_card_diam11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card5", "br_card_club4.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card5", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 9 ) {
		sDisplayString = "The eigth highest ranked hand in poker is the Two Pair, consisting of two pairs of identical value cards plus any fifth card.  Ties are broken by comparing the high pair, then the low pair, then the lone card.";
		SetGUITexture ( oPC, "br_poker_handstutorial", "card1", "br_card_diam7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card1", FALSE );
		SetGUITexture ( oPC, "br_poker_handstutorial", "card2", "br_card_hear7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card3", "br_card_spad4.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card4", "br_card_hear4.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card5", "br_card_club11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card5", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 10 ) {
		sDisplayString = "The ninth highest ranked hand in poker is the One Pair, consisting of one pair of identical value cards plus any other three cards.  Ties are broken by comparing the pair, and then the other three cards in order.";
		SetGUITexture ( oPC, "br_poker_handstutorial", "card1", "br_card_club5.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card1", FALSE );
		SetGUITexture ( oPC, "br_poker_handstutorial", "card2", "br_card_spad5.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card3", "br_card_diam9.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card4", "br_card_spad6.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card5", "br_card_hear8.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card5", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 11 ) {
		sDisplayString = "The lowest hand in poker is the high card hand.  This hand is a loose collection of cards that doesn't qualify for any higher hands, and ties are broken by comparing card values in order from high to low.";
		SetGUITexture ( oPC, "br_poker_handstutorial", "card1", "br_card_club10.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card1", FALSE );
		SetGUITexture ( oPC, "br_poker_handstutorial", "card2", "br_card_diam8.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card3", "br_card_diam6.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card4", "br_card_diam4.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_handstutorial", "card5", "br_card_spad2.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card5", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", TRUE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	}						
			
	SetGUIObjectText ( oPC, "br_tutorial", "tutorial_text", -1, sDisplayString );	
}


// clean up table between each state update

void Poker_HandsTutorial_CleanUpState ( object oPC ) {
	int i;
	
	for ( i = 1 ; i <= 5 ; i++ ) {
		SetGUIObjectHidden ( oPC, "br_poker_handstutorial", "card" + IntToString(i), TRUE );
	}
}


// close gui action

void Poker_HandsTutorial_CloseTutorial ( object oPC ) {
	Poker_HandsTutorial_CleanUpState(oPC);
	CloseGUIScreen ( oPC, "br_poker_handstutorial" );
}