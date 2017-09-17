// 2009 Black Rain Software


// game declarations, make sure these match the same declarations in the game include
const int i7cstudAnte = 100;  // amount of ante each player must contribute to start a hand
const int i7cstudInitialBet = 100;  // the the raise value of the first two rounds in a fixed limit game
const int i7cstudMaxRaises = 3;  // number of raises allowed per round in a fixed limit game
const string s7cstudDefaultGameName = "Seven Card Stud";  // the name of the game


// function prototypes
void Poker_7cstud_CleanUpState ( object oPC );
void Poker_7cstud_CloseTutorial ( object oPC );


// main function
void Poker_7cstud_ChangeState ( object oPC, int iState ) {
	string sDisplayString;
	
	if ( iState == 1 ) {
		sDisplayString = s7cstudDefaultGameName + " is a variant of poker, played with one standard deck of cards and against other players rather than the house dealer.  All players contribute to a shared pot, and the player with the best poker hand each round takes the pot.";
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", TRUE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "notice_pane", TRUE );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2dealerbutton", FALSE );
		SetGUIObjectText ( oPC, "br_poker_7cstud", "banner", -1, s7cstudDefaultGameName );				
		SetGUIObjectText ( oPC, "br_poker_7cstud", "player1name2", -1, GetName(oPC) );
		SetGUIObjectText ( oPC, "br_poker_7cstud", "player2name2", -1, "Player 2" );
		SetGUIObjectText ( oPC, "br_poker_7cstud", "player3name2", -1, "Player 3" );
		SetGUIObjectText ( oPC, "br_poker_7cstud", "player4name2", -1, "Player 4" );						
		SetGUIObjectText ( oPC, "br_poker_7cstud", "player_gold", -1, "0" );
		SetGUIObjectText ( oPC, "br_poker_7cstud", "bet_call", -1, "0" );
		SetGUIObjectText ( oPC, "br_poker_7cstud", "bet_raise", -1, "0" );			
	} else if ( iState == 2 ) {
		sDisplayString = "Play begins with each player contributing an ante of " + IntToString(i7cstudAnte) + " gold to the pot.  Once all players have bought in each player is dealt a hand of three cards, two cards only visible to the player and one up card visible to the entire table.";	
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2dealerbutton", FALSE );			
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card1", "br_card_diam11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card1", FALSE );
		DelayCommand ( 0.5, SetGUITexture ( oPC, "br_poker_7cstud", "player2card1", "br_card_back.tga" ) );
		DelayCommand ( 0.5, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card1", FALSE ) );		
		DelayCommand ( 1.0, SetGUITexture ( oPC, "br_poker_7cstud", "player3card1", "br_card_back.tga" ) );
		DelayCommand ( 1.0, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card1", FALSE ) );
		DelayCommand ( 1.5, SetGUITexture ( oPC, "br_poker_7cstud", "player4card1", "br_card_back.tga" ) );
		DelayCommand ( 1.5, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card1", FALSE ) );				
		DelayCommand ( 2.0, SetGUITexture ( oPC, "br_poker_7cstud", "player1card2", "br_card_diam7.tga" ) );
		DelayCommand ( 2.0, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card2", FALSE ) );
		DelayCommand ( 2.5, SetGUITexture ( oPC, "br_poker_7cstud", "player2card2", "br_card_back.tga" ) );
		DelayCommand ( 2.5, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card2", FALSE ) );		
		DelayCommand ( 3.0, SetGUITexture ( oPC, "br_poker_7cstud", "player3card2", "br_card_back.tga" ) );
		DelayCommand ( 3.0, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card2", FALSE ) );
		DelayCommand ( 3.5, SetGUITexture ( oPC, "br_poker_7cstud", "player4card2", "br_card_back.tga" ) );
		DelayCommand ( 3.5, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card2", FALSE ) );
		DelayCommand ( 4.0, SetGUITexture ( oPC, "br_poker_7cstud", "player1card3", "br_card_diam12.tga" ) );
		DelayCommand ( 4.0, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card3", FALSE ) );
		DelayCommand ( 4.5, SetGUITexture ( oPC, "br_poker_7cstud", "player2card3", "br_card_club7.tga" ) );
		DelayCommand ( 4.5, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card3", FALSE ) );		
		DelayCommand ( 5.0, SetGUITexture ( oPC, "br_poker_7cstud", "player3card3", "br_card_spad1.tga" ) );
		DelayCommand ( 5.0, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card3", FALSE ) );
		DelayCommand ( 5.5, SetGUITexture ( oPC, "br_poker_7cstud", "player4card3", "br_card_hear3.tga" ) );
		DelayCommand ( 5.5, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card3", FALSE ) );		
				
		DelayCommand ( 5.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE ) );	
		DelayCommand ( 5.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE ) );		
		DelayCommand ( 5.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE ) );		
	} else if ( iState == 3 ) {
		sDisplayString = "The first round of betting begins after each player is dealt two face down and one face up cards.  In this instance Player 3, the first player to the left of the dealer position, initiates each betting round this hand.  Betting continues around the table clockwise until all bets are complete.";	
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2dealerbutton", FALSE );			
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card1", "br_card_diam11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card1", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card1", FALSE );				
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card2", "br_card_diam7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card3", "br_card_diam12.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card3", "br_card_club7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card3", "br_card_spad1.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card3", "br_card_hear3.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card3", FALSE );		
		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 4 ) {
		sDisplayString = "In the first round of betting, the first and second betting players are forced to make small and big blind bets, to the value of " + IntToString ( i7cstudInitialBet / 2 ) + " and " + IntToString(i7cstudInitialBet) + " gold respectively.  In this hand Player 3 posts the small blind and Player 4 posts the big blind.  Once the blinds have been posted, all further betting this round and all subsequent rounds this hand occur normally.  After each hand is resolved the dealer position moves one spot clockwise, resulting in new players posting the small and big blinds next hand.";	
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2dealerbutton", FALSE );			
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card1", "br_card_diam11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card1", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card1", FALSE );				
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card2", "br_card_diam7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card3", "br_card_diam12.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card3", "br_card_club7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card3", "br_card_spad1.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card3", "br_card_hear3.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card3", FALSE );		
		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );			
	} else if ( iState == 5 ) {
		sDisplayString = "During a player's betting turn, he or she has three options.  A player can 'Call' when he or she wishes to match the bet of the player who has contributed the most to the pot so far.  A 'Raise' allows a player to put more into the pot than the current highest stake.";	
		sDisplayString = sDisplayString + "  'Fold', the third option, allows the player to give up the current hand.  He or she won't have to contribute any more to the pot in subsequent betting rounds, but all wagered gold including antes and blinds will be lost.  The betting round continues until all players have either matched the highest stake or folded.  A maximum of " + IntToString(i7cstudMaxRaises) + " raises are allowed by all players during a single betting round.";
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2dealerbutton", FALSE );			
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card1", "br_card_diam11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card1", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card1", FALSE );				
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card2", "br_card_diam7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card3", "br_card_diam12.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card3", "br_card_club7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card3", "br_card_spad1.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card3", "br_card_hear3.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card3", FALSE );		
		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 6 ) {
		sDisplayString = "Once the first betting round is complete, a face up card is dealt to each player, followed by the second betting round.  The second betting round proceeds similarly to the first, except no blinds are posted.";	
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2dealerbutton", FALSE );			
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card1", "br_card_diam11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card1", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card1", FALSE );				
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card2", "br_card_diam7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card3", "br_card_diam12.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card3", "br_card_club7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card3", "br_card_spad1.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card3", "br_card_hear3.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card4", "br_card_hear7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card4", FALSE );
		DelayCommand ( 0.5, SetGUITexture ( oPC, "br_poker_7cstud", "player2card4", "br_card_spad5.tga" ) );
		DelayCommand ( 0.5, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card4", FALSE ) );		
		DelayCommand ( 1.0, SetGUITexture ( oPC, "br_poker_7cstud", "player3card4", "br_card_hear10.tga" ) );
		DelayCommand ( 1.0, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card4", FALSE ) );
		DelayCommand ( 1.5, SetGUITexture ( oPC, "br_poker_7cstud", "player4card4", "br_card_spad4.tga" ) );
		DelayCommand ( 1.5, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card4", FALSE ) );	
				
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE ) );	
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE ) );		
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE ) );		
	} else if ( iState == 7 ) {
		sDisplayString = "The second betting round is followed by each playing being dealt a face up card, followed by the third betting round.  In the third and all subsequent betting rounds each hand, the default call and raise values are doubled, raising the stakes for players still in the game at this point.";	
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2dealerbutton", FALSE );			
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card1", "br_card_diam11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card1", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card1", FALSE );				
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card2", "br_card_diam7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card3", "br_card_diam12.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card3", "br_card_club7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card3", "br_card_spad1.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card3", "br_card_hear3.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card4", "br_card_hear7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card4", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card4", "br_card_spad5.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card4", "br_card_hear10.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card4", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card4", "br_card_spad4.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card4", FALSE );	
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card5", "br_card_club9.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card5", FALSE );
		DelayCommand ( 0.5, SetGUITexture ( oPC, "br_poker_7cstud", "player2card5", "br_card_hear2.tga" ) );
		DelayCommand ( 0.5, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card5", FALSE ) );		
		DelayCommand ( 1.0, SetGUITexture ( oPC, "br_poker_7cstud", "player3card5", "br_card_hear5.tga" ) );
		DelayCommand ( 1.0, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card5", FALSE ) );
		DelayCommand ( 1.5, SetGUITexture ( oPC, "br_poker_7cstud", "player4card5", "br_card_club11.tga" ) );
		DelayCommand ( 1.5, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card5", FALSE ) );					

		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE ) );	
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE ) );		
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE ) );				
	} else if ( iState == 8 ) {
		sDisplayString = "One more face up is dealt per player, followed by the fourth betting round.";	
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2dealerbutton", FALSE );			
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card1", "br_card_diam11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card1", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card1", FALSE );				
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card2", "br_card_diam7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card3", "br_card_diam12.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card3", "br_card_club7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card3", "br_card_spad1.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card3", "br_card_hear3.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card3", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card4", "br_card_hear7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card4", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card4", "br_card_spad5.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card4", "br_card_hear10.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card4", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card4", "br_card_spad4.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card4", FALSE );	
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card5", "br_card_club9.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card5", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player2card5", "br_card_hear2.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card5", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card5", "br_card_hear5.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card5", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player4card5", "br_card_club11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card5", FALSE );					
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card6", "br_card_diam3.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card6", FALSE );
		DelayCommand ( 0.5, SetGUITexture ( oPC, "br_poker_7cstud", "player2card6", "br_card_diam8.tga" ) );
		DelayCommand ( 0.5, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2card6", FALSE ) );		
		DelayCommand ( 1.0, SetGUITexture ( oPC, "br_poker_7cstud", "player3card6", "br_card_club2.tga" ) );
		DelayCommand ( 1.0, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card6", FALSE ) );
		DelayCommand ( 1.5, SetGUITexture ( oPC, "br_poker_7cstud", "player4card6", "br_card_spad2.tga" ) );
		DelayCommand ( 1.5, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player4card6", FALSE ) );	
		
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE ) );	
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE ) );		
		DelayCommand ( 1.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE ) );		
	} else if ( iState == 9 ) {
		sDisplayString = "A last card is dealt to each player, face down this time. If there are still players remaining the fifth and last round of betting occurs.  In this instance Player 2 and Player 4 have opted to fold their hands rather than continue on.  Their cards are removed, and only Player 1 and Player 4 will receive additional cards as well as participate in the next betting round.";	
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2dealerbutton", FALSE );			
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card1", "br_card_diam11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card1", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card1", FALSE );				
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card2", "br_card_diam7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card2", "br_card_back.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card3", "br_card_diam12.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card3", "br_card_spad1.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card3", FALSE );	
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card4", "br_card_hear7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card4", "br_card_hear10.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card4", FALSE );	
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card5", "br_card_club9.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card5", FALSE );	
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card5", "br_card_hear5.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card5", FALSE );					
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card6", "br_card_diam3.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card6", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card6", "br_card_club2.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card6", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card7", "br_card_spad13.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card7", FALSE );
		DelayCommand ( 0.5, SetGUITexture ( oPC, "br_poker_7cstud", "player3card7", "br_card_back.tga" ) );
		DelayCommand ( 0.5, SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card7", FALSE ) );
				
		DelayCommand ( 0.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE ) );	
		DelayCommand ( 0.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE ) );		
		DelayCommand ( 0.5, SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE ) );	
	} else if ( iState == 10 ) {
		sDisplayString = "If more than one player remains after the final betting round, the showdown occurs in which all player cards are revealed.  In " + s7cstudDefaultGameName + ", the winner is the player who can make the best five card poker hand out of his or her seven cards, and wins the entire pot.  In the case of a tie, all tied players split the pot equally.  In this hand Player 1 has won with a Seven Pair hand, beating Player 3's Five Pair hand.";	
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2dealerbutton", FALSE );			
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card1", "br_card_diam11.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card1", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card1", "br_card_club4.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card1", FALSE );				
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card2", "br_card_diam7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card2", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card2", "br_card_hear8.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card2", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card3", "br_card_diam12.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card3", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card3", "br_card_spad1.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card3", FALSE );	
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card4", "br_card_hear7.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card4", FALSE );		
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card4", "br_card_hear10.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card4", FALSE );	
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card5", "br_card_club9.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card5", FALSE );	
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card5", "br_card_hear5.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card5", FALSE );					
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card6", "br_card_diam3.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card6", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card6", "br_card_club2.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card6", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player1card7", "br_card_spad13.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player1card7", FALSE );
		SetGUITexture ( oPC, "br_poker_7cstud", "player3card7", "br_card_diam5.tga" );
		SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player3card7", FALSE );
				
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
	} else if ( iState == 11 ) {
		sDisplayString = "There is one more betting option available to players.  If in the course of a hand a player does not have enough gold to cover a 'Call', he or she can opt to 'All In'.  The player will then be able to proceed to the end of the hand without having to contribute any more to the pot during betting round.";
		sDisplayString = sDisplayString + "  'All-in' players can only win from other players an amount equal their contribution to the pot though.  For example, if the pot is at 7000 gold, no players have folded and one player has gone 'All-in' with 1000 gold, that player can only win up to 4000 gold from the pot.  The remainder of the pot goes to the second best hand.";	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 12 ) {
		sDisplayString = "That's all you need to know to start playing " + s7cstudDefaultGameName + ".  Good luck!";	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", TRUE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	}
	
	SetGUIObjectText ( oPC, "br_tutorial", "tutorial_text", -1, sDisplayString );	
}


// clean up table between each state update

void Poker_7cstud_CleanUpState ( object oPC ) {
	int i, j;
	string s, sJ;
	
	SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player2dealerbutton", TRUE );		
	for ( i = 1 ; i <= 4 ; i++ ) {
		s = IntToString(i);
		for ( j = 1 ; j <= 7 ; j++ ) {
			sJ = IntToString(j);
			SetGUIObjectHidden ( oPC, "br_poker_7cstud", "player" + s + "card" + sJ, TRUE );
		}
	}
}


// close gui action

void Poker_7cstud_CloseTutorial ( object oPC ) {
	Poker_7cstud_CleanUpState(oPC);
	SetGUIObjectHidden ( oPC, "br_poker_7cstud", "notice_pane", FALSE );	
	CloseGUIScreen ( oPC, "br_poker_7cstud" );
}