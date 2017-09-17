// Black Rain 2009


// game declarations, make sure these match the same declarations in the game include
const int iHard17 = -1;  // dealer stands on hard 17s only
const int iFiveCardCharlie = -1;  // player wins drawing five cards without busting
const int iDealerWinsTies = -1;  // dealer wins ties
const int iDoubleExposure = -1;  // both dealer cards visible, typically used with 100 iNaturalPayoff and dealer wins ties
const float fNaturalPayoff = 1.5;  // percentage payoff for a natural blackjack


// function prototypes
void Blackjack_CleanUpState ( object oPC );
void Blackjack_CloseTutorial ( object oPC );


// main function

void Blackjack_ChangeState ( object oPC, int iState ) {
	int iTemp;
	string sDisplayString;
	
	if ( iState == 1 ) {
		sDisplayString = "Blackjack is a game of cards, in which the objective is to get a hand as close to 21 as possible without going over.  Each card has a value, with number cards being equal to their numbers.  Face cards, Kings, Queens, and Jacks, are all worth 10 points, while Aces are worth either 1 or 11 points.";			
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", TRUE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
		SetGUIObjectHidden ( oPC, "br_blackjack", "notice_pane", TRUE );
		SetGUIObjectText ( oPC, "br_blackjack", "player1card1_name", -1, GetName(oPC) );
		SetGUIObjectText ( oPC, "br_blackjack", "player2card1_name", -1, "" );
		SetGUIObjectText ( oPC, "br_blackjack", "player3card1_name", -1, "" );
		SetGUIObjectText ( oPC, "br_blackjack", "player4card1_name", -1, "" );
		SetGUIObjectText ( oPC, "br_blackjack", "player_gold", -1, "0" );
		SetGUIObjectText ( oPC, "br_blackjack", "player_stake", -1, "0" );										
	} else if ( iState == 2 ) {
		sDisplayString = "Play begins with each player being dealt a hand, with each hand cosisting of two cards.";
		if ( iDoubleExposure == -1 ) {
			sDisplayString = sDisplayString + "  The dealer's first card is dealt face down.";
			SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_back.tga" );		
			SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );
		} else {
			SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_spad5.tga" );			
			SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );		
		}
		DelayCommand ( 0.5, SetGUITexture ( oPC, "br_blackjack", "dealercard_2", "br_card_spad13.tga" ) );
		DelayCommand ( 0.5, SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_2", FALSE ) );		
		DelayCommand ( 1.0, SetGUITexture ( oPC, "br_blackjack", "player1card1_1", "br_card_club3.tga" ) );
		DelayCommand ( 1.0, SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_1", FALSE ) );		
		DelayCommand ( 1.5, SetGUITexture ( oPC, "br_blackjack", "player1card1_2", "br_card_hear12.tga" ) );
		DelayCommand ( 1.5, SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_2", FALSE ) );			
		
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE ) );
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE ) );			
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE ) );	
	} else if ( iState == 3 ) {
		if ( iDoubleExposure == -1 ) {
			sDisplayString = "In this instance the player's hand totals 13, while the dealer's hand value cannot be determined yet.";		
			SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_back.tga" );		
			SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );		
		} else {
			sDisplayString = "In this instance the player's hand totals 13, while the dealer's hand totals 15.";
			SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_spad5.tga" );			
			SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );			
		}
		SetGUITexture ( oPC, "br_blackjack", "dealercard_2", "br_card_spad13.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_2", FALSE );		
		SetGUITexture ( oPC, "br_blackjack", "player1card1_1", "br_card_club3.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_1", FALSE );		
		SetGUITexture ( oPC, "br_blackjack", "player1card1_2", "br_card_hear12.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_2", FALSE );	
		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );			
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );												
	} else if ( iState == 4 ) {
		sDisplayString = "After the initial deal, the player's turn begins.  The player may request additional cards until he or she is satisfied with the value of the hand.  When that occurs, the dealer's turn begins.";
		if ( iDoubleExposure == -1 ) {		
			SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_back.tga" );		
			SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );		
		} else {
			SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_spad5.tga" );			
			SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );			
		}
		SetGUITexture ( oPC, "br_blackjack", "dealercard_2", "br_card_spad13.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_2", FALSE );		
		SetGUITexture ( oPC, "br_blackjack", "player1card1_1", "br_card_club3.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_1", FALSE );		
		SetGUITexture ( oPC, "br_blackjack", "player1card1_2", "br_card_hear12.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_2", FALSE );
		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );			
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );					
	} else if ( iState == 5 ) {
		sDisplayString = "The 'Hit' option allows the player to receive another card, with its value being added to the player's hand value.  The 'Stand' option indicates that the player wishes to draw no more cards, and begins the dealer's turn.  The player may 'Hit' as many times as desired, until the player chooses to 'Stand' or the value of the hand either exceeds 21.  For this hand, the player chooses to 'Hit' once.";
		if ( iDoubleExposure == -1 ) {		
			SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_back.tga" );		
			SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );		
		} else {
			SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_spad5.tga" );			
			SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );			
		}
		SetGUITexture ( oPC, "br_blackjack", "dealercard_2", "br_card_spad13.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_2", FALSE );		
		SetGUITexture ( oPC, "br_blackjack", "player1card1_1", "br_card_club3.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_1", FALSE );		
		SetGUITexture ( oPC, "br_blackjack", "player1card1_2", "br_card_hear12.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_2", FALSE );
		SetGUITexture ( oPC, "br_blackjack", "player1card1_3", "br_card_hear7.tga" );				
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_3", FALSE );		
		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );			
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );					
	} else if ( iState == 6 ) {
		sDisplayString = "During the dealer's turn, the dealer must 'Hit' if the value of the dealer hand is 16 or below, and must 'Stand' if the value of the dealer hand is 17 or above.";
		if ( iHard17 != 1 ) {
			sDisplayString = sDisplayString + "  The dealer must also 'Hit' in the case of a soft 17, a hand adding up to 17 in which one of the cards is an Ace valued at 11.";
		}
		SetGUITexture ( oPC, "br_blackjack", "player1card1_1", "br_card_club3.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_1", FALSE );		
		SetGUITexture ( oPC, "br_blackjack", "player1card1_2", "br_card_hear12.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_2", FALSE );
		SetGUITexture ( oPC, "br_blackjack", "player1card1_3", "br_card_hear7.tga" );				
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_3", FALSE );		
		SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_spad5.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );			
		SetGUITexture ( oPC, "br_blackjack", "dealercard_2", "br_card_spad13.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_2", FALSE );			
		SetGUITexture ( oPC, "br_blackjack", "dealercard_3", "br_card_spad1.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_3", FALSE );				
		DelayCommand ( 0.5, SetGUITexture ( oPC, "br_blackjack", "dealercard_4", "br_card_club10.tga" ) );		
		DelayCommand ( 0.5, SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_4", FALSE ) );			
		
		DelayCommand ( 0.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE ) );
		DelayCommand ( 0.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE ) );			
		DelayCommand ( 0.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE ) );;	
	} else if ( iState == 7 ) {
		sDisplayString = "The player's hand has a value of 20, while the dealer has gone 'Bust', with a hand value of over 21.  The player wins this round.  Note that the rules forced the dealer to take the fourth card, as the value of the dealer hand was below 17 at three cards.";
		SetGUITexture ( oPC, "br_blackjack", "player1card1_1", "br_card_club3.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_1", FALSE );		
		SetGUITexture ( oPC, "br_blackjack", "player1card1_2", "br_card_hear12.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_2", FALSE );
		SetGUITexture ( oPC, "br_blackjack", "player1card1_3", "br_card_hear7.tga" );				
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_3", FALSE );		
		SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_spad5.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );			
		SetGUITexture ( oPC, "br_blackjack", "dealercard_2", "br_card_spad13.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_2", FALSE );			
		SetGUITexture ( oPC, "br_blackjack", "dealercard_3", "br_card_spad1.tga" );
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_3", FALSE );				
		SetGUITexture ( oPC, "br_blackjack", "dealercard_4", "br_card_club10.tga" );		
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_4", FALSE );
		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );			
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );							
	} else if ( iState == 8 ) {
		sDisplayString = "The dealer would still be required to play the dealer hand to 17 or above, even if the player had gone 'Bust' beforehand.  In the case of a tie in hand value, or if both player and dealer 'Bust', the tie is considered ";
		if ( iDealerWinsTies == -1 ) {
			sDisplayString = sDisplayString + "to be a push, no stake is won or lost on the hand.";		
		} else {
			sDisplayString = sDisplayString + "a win for the dealer.";
		}	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );			
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );			
	} else if ( iState == 9 ) {
		iTemp = FloatToInt(fNaturalPayoff) * 100;
		sDisplayString = "Those are the basic rules for Blackjack, but there are some advanced rules that make the game more enjoyable.  If players score a 'Blackjack' on the initial deal, which consists of an Ace plus any card valued 10, the player automatically wins the round and earns " + IntToString(iTemp) + "% of the original wager";
		if ( iDoubleExposure == -1 ) {
			SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_back.tga" );
			SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );					
		} else {
			SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_spad5.tga" );
			SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );			
		}		
		DelayCommand ( 0.5, SetGUITexture ( oPC, "br_blackjack", "dealercard_2", "br_card_spad13.tga" ) );
		DelayCommand ( 0.5, SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_2", FALSE ) );		
		DelayCommand ( 1.0, SetGUITexture ( oPC, "br_blackjack", "player1card1_1", "br_card_hear1.tga" ) );
		DelayCommand ( 1.0, SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_1", FALSE ) );		
		DelayCommand ( 1.5, SetGUITexture ( oPC, "br_blackjack", "player1card1_2", "br_card_club11.tga" ) );
		DelayCommand ( 1.5, SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_2", FALSE ) );			
		
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE ) );
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE ) );			
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE ) );
	} else if ( iState == 10 ) {
		sDisplayString = "On the player's first turn he or she can choose to 'Double down', doubling the wager while drawing exactly one additional card for the player hand.  After the player draws one additional card the dealer's turn begins.";  	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );			
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 11 ) {
		sDisplayString = "If the player's initial hand consists of two cards with identical values, the player can opt to 'Split' the cards, and play each card as a separate hand.  This requires an additional wager, giving the player the opportunity to win or lose double the initial bet.";
		if ( iDoubleExposure == -1 ) {
			SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_back.tga" );		
			SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );
		} else {
			SetGUITexture ( oPC, "br_blackjack", "dealercard_1", "br_card_spad5.tga" );			
			SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", FALSE );		
		}
		DelayCommand ( 0.5, SetGUITexture ( oPC, "br_blackjack", "dealercard_2", "br_card_spad13.tga" ) );
		DelayCommand ( 0.5, SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_2", FALSE ) );		
		DelayCommand ( 1.0, SetGUITexture ( oPC, "br_blackjack", "player1card1_1", "br_card_hear4.tga" ) );
		DelayCommand ( 1.0, SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_1", FALSE ) );		
		DelayCommand ( 1.5, SetGUITexture ( oPC, "br_blackjack", "player1card1_2", "br_card_club4.tga" ) );
		DelayCommand ( 1.5, SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_2", FALSE ) );					
		DelayCommand ( 2.5, SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_2", TRUE ) );
		DelayCommand ( 2.5, SetGUITexture ( oPC, "br_blackjack", "player1card2_1", "br_card_club4.tga" ) );		
		DelayCommand ( 2.5, SetGUIObjectHidden ( oPC, "br_blackjack", "player1card2_1", FALSE ) );			
		
		DelayCommand ( 2.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE ) );
		DelayCommand ( 2.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE ) );			
		DelayCommand ( 2.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE ) );
	} else if ( iState == 12 ) {
		if ( iFiveCardCharlie == 1 ) {
			sDisplayString = "If players 'Hit' five times without going 'Bust', for a total of seven cards in the player's hand, the player automatically wins.";
			SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
			SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );			
			SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
		} else {
			sDisplayString = "That's the rules of Blackjack.  With the proper strategy, Blackjack can be one of the most fun and rewarding casino games to play.  Give it a try!";
			SetGUIObjectDisabled ( oPC, "br_tutorial", "next", TRUE );
			SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );			
			SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );				
		}	
	} else if ( iState == 13 ) {
		sDisplayString = "That's the rules of Blackjack.  With the proper strategy, Blackjack can be one of the most fun and rewarding casino games to play.  Give it a try!";
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", TRUE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );			
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	}
	
	SetGUIObjectText ( oPC, "br_tutorial", "tutorial_text", -1, sDisplayString );		
}


// clean up board between each state update

void Blackjack_CleanUpState ( object oPC ) {
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_1", TRUE );
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_2", TRUE );	
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card1_3", TRUE );
		SetGUIObjectHidden ( oPC, "br_blackjack", "player1card2_1", TRUE );	
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_1", TRUE );						
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_2", TRUE );			
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_3", TRUE ) ;				
		SetGUIObjectHidden ( oPC, "br_blackjack", "dealercard_4", TRUE );
}


// close gui action

void Blackjack_CloseTutorial ( object oPC ) {
	Blackjack_CleanUpState(oPC);
	SetGUIObjectHidden ( oPC, "br_blackjack", "notice_pane", FALSE );	
	CloseGUIScreen ( oPC, "br_blackjack" );
}