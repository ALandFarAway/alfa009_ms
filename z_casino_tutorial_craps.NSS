// Black Rain 2009


// game declarations, make sure these match the same declarations in the game include
const float fInitialDelay = 0.8;  // delay before rolling dice
const float fFinalDelay = 0.9;  // delay after rolling dice
const int iTotalFrames = 679;  // number of frames from left to right of dice track in gui
const int iStartFrameVariance = 20;  // starting position variance
const int iBaseFrameSkip = 30;  // base frame skip
const int iFrameSkipVariance = 15;  // frame skip variance
const float fBaseDelay = 0.04;  // base delay per iteration
const int iDelayVariance = 4;  // delay variance, each int represents a 0.01 increase in fBaseDelay
const int iBaseBounce = 4;  // base number of animation iterations after bounce
const int iBounceVariance = 6;  // bounce iterations variance
const int iBaseFrameSkipLoss = 10;  // base frame skip loss on bounce
const int iFrameSkipLossVariance = 10;  // variance frame skip loss on bounce


// function prototypes
void Craps_ChangeState ( object oPC, int iState );
void Craps_SetupRoll ( object oDealer, int iTutorialState );
void Craps_GenerateRollResults ( object oDealer, int iTutorialState );
void Craps_RollDie ( object oDealer, string sDieNumber, int iTutorialState );
void Craps_BootstrapRoll ( object oDealer, int iTutorialState );
void Craps_CleanUpState ( object oPC );
void Craps_CloseTutorial ( object oPC );

// main function

void Craps_ChangeState ( object oPC, int iState ) {	
	int iDieFrame;
	string s, sDisplayString;	

	if ( iState == 1 ) {
		sDisplayString = "Craps is a dice-based game where players bet on the outcome of dice rolls.  The game offers a large variety of bets, suited for many different betting strategies.  Bets are placed by clicking the appropriate spots on the table.  Existing bets can be modified by left clicking or removed by right clicking.";
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", TRUE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
		SetGUIObjectHidden ( oPC, "br_craps", "notice_pane", TRUE );
		SetGUIObjectText ( oPC, "br_craps", "player1name2", -1, GetName(oPC) );
		SetGUIObjectText ( oPC, "br_craps", "roulette_gold", -1, "0" );
		SetGUIObjectText ( oPC, "br_craps", "roulette_bet", -1, "0" );		
	} else if ( iState == 2 ) {
		sDisplayString = "Play starts with players betting on either the Pass or Don't Pass Lines.  Note that a player can only bet on one or the other, not both, and must bet on either before the game can proceed.";
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
	} else if ( iState == 3 ) {
		sDisplayString = "In this case the player has bet on the Pass Line, which wins if the roll is 7 or 11, and loses on rolls of 2, 3, or 12.  The player could have bet instead on Don't Pass, which wins on 2 and 3, loses on 7 and 11, and ties on 12.";
		SetGUITexture(oPC, "br_craps", "craps_chip_pass", "br_chip_1.tga");		
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_pass", FALSE );
		SetGUIObjectHidden ( oPC, "br_craps", "craps_puck_off", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );			
	} else if ( iState == 4 ) {
		sDisplayString = "Craps play is divided into rounds, with the first dice roll of each round known as the 'Come Out Roll'  If the 'Come Out Roll' is 2, 3, 7, 11, or 12, the player has won or lost and the round ends.  On other results, the round continues with subsequent rolls.";
		SetGUITexture(oPC, "br_craps", "craps_chip_pass", "br_chip_1.tga");		
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_pass", FALSE );
		SetGUIObjectHidden ( oPC, "br_craps", "craps_puck_off", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "previous", TRUE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", TRUE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", TRUE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", TRUE );				
		Craps_SetupRoll ( oPC, iState );
	} else if ( iState == 5 ) {
		sDisplayString = "The player rolled a 'Hard Six', the name indicating that the six was rolled with two equal die values.  This roll establishes the 'Point' as six, indicated by the white puck above the box.  The round continues with further rolls until the player rolls either seven or the 'Point' value, in this case six.";
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_pass", FALSE );
		SetGUIObjectHidden ( oPC, "br_craps", "craps_puck_off", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "previous", TRUE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
		
		iDieFrame = GetLocalInt ( oPC, "iDie1Frame" );
		s = "craps_1_" + IntToString(iDieFrame) + "a";
		SetGUITexture ( oPC, "br_crasps", s, "br_diered3.tga" );
		SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );		
		iDieFrame = GetLocalInt ( oPC, "iDie2Frame" );
		s = "craps_2_" + IntToString(iDieFrame) + "a";
		SetGUITexture ( oPC, "br_crasps", s, "br_diered3.tga" );
		SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );		
	} else if ( iState == 6 ) {
		sDisplayString = "After the 'Come Out Roll', the winning and losing conditions for Pass Line and Don't Pass bets also change.  The player wins a Pass Line bet if the 'Point' value is rolled again before a seven, and loses if the opposite happens.  The reverse is true for a Don't Pass bet, rolling a seven before the 'Point' value wins.  When either a seven or the 'Point' value is rolled, the round is over and the next roll will be a 'Come Out Roll' again.";			
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_pass", FALSE );
		SetGUIObjectHidden ( oPC, "br_craps", "craps_puck_off", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );				
	} else if ( iState == 7 ) {		
		sDisplayString = "After the 'Come out Roll' the player can also place an odds bet, which is an extra wager with the same win and lose conditions as the original Pass Line or Don't Pass bets.  Odds bets can be made at up to five times the value of the original bet, and are placed next to the chips indicating the original bet.";
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_pass", FALSE );
		SetGUIObjectHidden ( oPC, "br_craps", "craps_puck_off", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 8 ) {	
		sDisplayString = "The Pass Line, Don't Pass, and odds are the basic bets for Craps, but there are other bets available for more advanced players.  These bets are divided into three types: line bets which are similar to Pass and Don't Pass, single roll bets on the next roll, and multi roll bets which may take multiple rolls to determine the outcome.";
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_pass", FALSE );	
		SetGUIObjectHidden ( oPC, "br_craps", "craps_puck_off", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );			
	} else if ( iState == 9 ) {	
		sDisplayString = "These are the line bets.  Come and Don't Come are functionally similar to Pass and Don't Pass respectively in terms of win and lose conditions, except they cannot be placed on the 'Come Out Roll'.  If the next roll does not resolve the Come or Don't Come bet, the bet is moved within the number box of the roll to denote a 'Come Point'.";	
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_pass", FALSE );	
		SetGUIObjectHidden ( oPC, "br_craps", "craps_puck_off", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_dontpass", "br_chip_1.tga" );
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_dontpass", FALSE );	
		SetGUITexture(oPC, "br_craps", "craps_chip_come", "br_chip_1.tga" );
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_come", FALSE );	
		SetGUITexture(oPC, "br_craps", "craps_chip_dontcome", "br_chip_1.tga" );		
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_dontcome", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 10 ) {	
		sDisplayString = "In this instance the player has placed a Come bet.";	
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_come", FALSE );		
		SetGUIObjectHidden ( oPC, "br_craps", "craps_puck_off", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
		Craps_SetupRoll ( oPC, iState );
	} else if ( iState == 11 ) {	
		sDisplayString = "The next roll is an eight, establishing it as the 'Come Point'.  The bet is moved to the appropriate place within the number eight box.  To place an odds bet put the chips beside the Come bet within the number eight box.";
		SetGUITexture(oPC, "br_craps", "craps_chip_come8", "br_chip_1.tga" );				
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_come8", FALSE );	
		DelayCommand ( 1.0, SetGUITexture(oPC, "br_craps", "craps_chip_comeodds8", "br_chip_1.tga" ) );			
		DelayCommand ( 1.0, SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_comeodds8", FALSE ) );		
		DelayCommand ( 1.0, SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE ) );
		DelayCommand ( 1.0, SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE ) );
		DelayCommand ( 1.0, SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE ) );		
	} else if ( iState == 12 ) {	
		sDisplayString = "These are the single roll bets, which may cover individual numbers, pairs of numbers as with The Hi-Lo bet between 2 and 12, any Craps, or the Field bet which covers many numbers.  Payouts differ for each bet depending on the odds of that bet coming true.  The Field bet pays 2 to 1 on rolls of 2 and 12, and 1 to 1 on all other values.";	
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_hilo", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_hilo", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_acedeuce", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_acedeuce", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_snakeeyes", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_snakeeyes", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_yo", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_yo", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_boxcars", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_boxcars", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_anyseven", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_anyseven", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_anycraps", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_anycraps", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_cande", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_cande", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_field", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_field", "br_chip_1.tga");		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
	} else if ( iState == 13 ) {
		sDisplayString = "These are the multi roll 'Hard Way' bets.  The name refers to the value being rolled with two equal dice.  For example. dice results of 4 and 4 are a 'Hard Way' 8, while 3 and 5 would be 'Easy Way'.  These bets win if the number is rolled the 'Hard Way' before the player rolls either 7 or the number the 'Easy Way'.";
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_hard4", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_hard4", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_hard6", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_hard6", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_hard8", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_hard8", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_hard10", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_hard10", "br_chip_1.tga");		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );			
	} else if ( iState == 14 ) {		
		sDisplayString = "These are the multi roll Place Win and Place Lose bets, as well as the Big 6 and Big 8 bets.  Place Win bets are placed at the bottom of the main number box, while Place Lose bets are placed in the narrow strip above the number.  Place Win and Big 6 & 8 bets win if the number is rolled before the player rolls a 7, while Place Lose wins if 7 is rolled before the number.";
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placewin4", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_placewin4", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placelose4", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_placelose4", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placewin5", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_placewin5", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placelose5", FALSE );	
		SetGUITexture(oPC, "br_craps", "craps_chip_placelose5", "br_chip_1.tga");		
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placewin6", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_placewin6", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placelose6", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_placelose6", "br_chip_1.tga");			
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placewin8", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_placewin8", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placelose8", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_placelose8", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placewin9", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_placewin9", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placelose9", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_placelose9", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placewin10", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_placewin10", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placelose10", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_placelose10", "br_chip_1.tga");										
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_big6", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_big6", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_big8", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_big8", "br_chip_1.tga");		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );			
	} else if ( iState == 15 ) {	
		sDisplayString = "These are the multi roll Buy and Lay bets.  Buy bets are placed on the right side of the main number box, while Lay bets are placed in the upper box on the right side.Buy bets are similar to Place Win, paying out if the number is rolled before a 7.  Lay bets are similar to Place Lose, paying out if 7 is rolled before the number.  They offer a different payout rate however.";
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_buy4", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_buy4", "br_chip_1.tga");	
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_lay4", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_lay4", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_buy5", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_buy5", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_lay5", FALSE );		
		SetGUITexture(oPC, "br_craps", "craps_chip_lay5", "br_chip_1.tga");	
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_buy6", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_buy6", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_lay6", FALSE );		
		SetGUITexture(oPC, "br_craps", "craps_chip_lay6", "br_chip_1.tga");	
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_buy8", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_buy8", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_lay8", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_lay8", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_buy9", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_buy9", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_lay9", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_lay9", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_buy10", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_buy10", "br_chip_1.tga");
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_lay10", FALSE );
		SetGUITexture(oPC, "br_craps", "craps_chip_lay10", "br_chip_1.tga");		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );			
	} else if ( iState == 16 ) {		
		sDisplayString = "Those are all the bets available in Craps.  The game may seem daunting at first, but by sticking with the basic Pass & Don't Pass bets and expanding into the more advanced bets slowly you'll get the hang of it in no time.";			
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", TRUE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );											
	} else if ( iState == 100 ) {
		sDisplayString = "Craps play is divided into rounds, with the first dice roll of each round known as the 'Come Out Roll'  If the 'Come Out Roll' is 2, 3, 7, 11, or 12, the player has won or lost and the round ends.  On other results, the round continues with subsequent rolls.";		
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_pass", FALSE );
		SetGUIObjectHidden ( oPC, "br_craps", "craps_puck_off", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
	} else if ( iState == 101 ) {
		sDisplayString = "In this instance the player has placed a Come bet.";	
		SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_come", FALSE );		
		SetGUIObjectHidden ( oPC, "br_craps", "craps_puck_off", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
	}
	
	SetGUIObjectText ( oPC, "br_tutorial", "tutorial_text", -1, sDisplayString );	
}


// set up a roll

void Craps_SetupRoll ( object oDealer, int iTutorialState ) {
	float f;
	int i;
	string s, sComponentString, sDie;
	
	SetGUIObjectHidden ( oDealer, "br_craps", "craps_die1", FALSE );
	SetGUIObjectHidden ( oDealer, "br_craps", "craps_die2", FALSE );	
		
	// set up die 1
	i = Random(iStartFrameVariance);
	s = "craps_1_" + IntToString(i) + "a";
	SetLocalInt ( oDealer, "iDie1Frame", i );	
	i = Random(6) + 1;
	sDie = "br_diered" + IntToString(i);
	SetGUITexture ( oDealer, "br_craps", s, sDie + ".tga" );
	SetGUIObjectHidden ( oDealer, "br_craps", s, FALSE );	
	SetLocalInt ( oDealer, "iDie1Curr", i );
	i = Random(iFrameSkipVariance) + iBaseFrameSkip;
	SetLocalInt ( oDealer, "iDie1FrameSkip", i );	
	SetLocalInt ( oDealer, "iDie1RollStatus", 0 );
	SetLocalInt ( oDealer, "iDie1Spin", Random(4) );
	SetLocalInt ( oDealer, "iDie1Status", 0 );
	f = ( IntToFloat(Random(iDelayVariance)) * 0.01 ) + fBaseDelay;
	SetLocalFloat ( oDealer, "iDie1Delay", f );
	i = Random(iBounceVariance) + iBaseBounce;
	SetLocalInt ( oDealer, "iDie1Bounce", i );
	
	// set up die 2		
	i = Random(iStartFrameVariance);
	s = "craps_2_" + IntToString(i) + "a";
	SetLocalInt ( oDealer, "iDie2Frame", i );	
	i = Random(6) + 1;
	sDie = "br_diered" + IntToString(i);
	SetGUITexture ( oDealer, "br_craps", s, sDie + ".tga" );
	SetGUIObjectHidden ( oDealer, "br_craps", s, FALSE );	
	SetLocalInt ( oDealer, "iDie2Curr", i );
	i = Random(iFrameSkipVariance) + iBaseFrameSkip;
	SetLocalInt ( oDealer, "iDie2FrameSkip", i );
	SetLocalInt ( oDealer, "iDie2RollStatus", 0 );
	SetLocalInt ( oDealer, "iDie2Spin", Random(4) );
	SetLocalInt ( oDealer, "iDie2Status", 0 );
	f = ( IntToFloat(Random(iDelayVariance)) * 0.01 ) + fBaseDelay;
	SetLocalFloat ( oDealer, "iDie2Delay", f );
	i = Random(iBounceVariance) + iBaseBounce;
	SetLocalInt ( oDealer, "iDie2Bounce", i );
		
	Craps_GenerateRollResults ( oDealer, iTutorialState );
	DelayCommand ( fInitialDelay, Craps_RollDie ( oDealer, "1", iTutorialState ) );
	DelayCommand ( fInitialDelay, Craps_RollDie ( oDealer, "2", iTutorialState ) );
}


// set up the results of a roll

void Craps_GenerateRollResults ( object oDealer, int iTutorialState ) {
	if ( iTutorialState == 4 ) {
		SetLocalInt ( oDealer, "iResult1", 3 );
		SetLocalInt ( oDealer, "iResult2", 3 );											
	} else if ( iTutorialState == 10 ) {
		SetLocalInt ( oDealer, "iResult1", 4 );
		SetLocalInt ( oDealer, "iResult2", 4 );	
	}	
}


// roll die animation

void Craps_RollDie ( object oDealer, string sDieNumber, int iTutorialState ) {
	float fDieDelay;
	int iDiceStopped, iDieBounce, iDieCurr, iDieFrame, iDieFrameSkip, iDieNext, iDieResult, iDieRollStatus, iDieSpin, iDieStatus;
	object oPC;
	string s, sDie;

	iDiceStopped = 0;	
	oPC = oDealer;
	
	// initiate variables
	iDieFrame = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame" );
	iDieFrameSkip = GetLocalInt ( oDealer, "iDie" + sDieNumber + "FrameSkip" );
	iDieRollStatus = GetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus" );
	iDieStatus = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Status" );
	
	// evaluate die status
	if ( iDieRollStatus == 0 ) {  // first drop
		if ( iDieStatus == 0 ) {  // currently a full die
			// turn off current frame
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUIObjectHidden ( oPC, "br_craps", s, TRUE );	
			
			iDieFrame = iDieFrame + iDieFrameSkip;
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr" );			
			// determine next die face
			iDieNext = Random(5) + 1;
			if ( iDieNext >= iDieCurr ) {
				iDieNext = iDieNext + 1;
			}
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Next", iDieNext );	
			iDieSpin = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin" );	
			// turn on new frames
			if ( iDieSpin == 0 ) {  // left spin
				sDie = "br_diered" + IntToString(iDieCurr) + "l";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";	
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );								
				sDie = "br_diered" + IntToString(iDieNext) + "r";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );											
			} else if ( iDieSpin == 1 ) {  // right spin
				sDie = "br_diered" + IntToString(iDieCurr) + "r";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );					
				sDie = "br_diered" + IntToString(iDieNext) + "l";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );				
			} else if ( iDieSpin == 2 ) {  // top spin
				sDie = "br_diered" + IntToString(iDieCurr) + "t";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );					
				sDie = "br_diered" + IntToString(iDieNext) + "b";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );					
			} else {  // bottom spin, expected value 3
				sDie = "br_diered" + IntToString(iDieCurr) + "b";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );				
				sDie = "br_diered" + IntToString(iDieNext) + "t";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );					
			}
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 1 );
			if ( iDieFrame > iTotalFrames - iDieFrameSkip ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 1 );
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "FrameSkip", iDieFrameSkip - ( iBaseFrameSkipLoss + Random(iFrameSkipLossVariance) ) );				
				AssignCommand ( oDealer, PlaySound ( "cb_ht_whipston" ) );				
			}
		} else {  // currently two half images, expected value 1
			// turn off current frames	
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUIObjectHidden ( oPC, "br_craps", s, TRUE );
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
			SetGUIObjectHidden ( oPC, "br_craps", s, TRUE );
			
			iDieFrame = iDieFrame + iDieFrameSkip;
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
			
			// get new current die face
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Next" );
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr", iDieCurr );			
		
			// turn on new frame
			sDie = "br_diered" + IntToString(iDieCurr);
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
			SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 0 );	
			if ( iDieFrame > iTotalFrames - iDieFrameSkip ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 1 );
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "FrameSkip", iDieFrameSkip - ( iBaseFrameSkipLoss + Random(iFrameSkipLossVariance) ) );
				AssignCommand ( oDealer, PlaySound ( "cb_ht_whipston" ) );				
			}			
			
			// randomize die spin per roll
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin", Random(4) );							
		}		
	} else if ( iDieRollStatus == 1 ) {  // bounce
		if ( iDieStatus == 0 ) {  // currently a full die
			// turn off current frame
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUIObjectHidden ( oPC, "br_craps", s, TRUE );		
			
			iDieFrame = iDieFrame - iDieFrameSkip;
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr" );			
			// determine next die face
			iDieNext = Random(5) + 1;
			if ( iDieNext >= iDieCurr ) {
				iDieNext = iDieNext + 1;
			}
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Next", iDieNext );	
			iDieSpin = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin" );	
			// turn on new frames
			if ( iDieSpin == 0 ) {  // left spin
				sDie = "br_diered" + IntToString(iDieCurr) + "l";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );							
				sDie = "br_diered" + IntToString(iDieNext) + "r";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );									
			} else if ( iDieSpin == 1 ) {  // right spin
				sDie = "br_diered" + IntToString(iDieCurr) + "r";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );				
				sDie = "br_diered" + IntToString(iDieNext) + "l";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );				
			} else if ( iDieSpin == 2 ) {  // top spin
				sDie = "br_diered" + IntToString(iDieCurr) + "t";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );				
				sDie = "br_diered" + IntToString(iDieNext) + "b";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );			
			} else {  // bottom spin, expected value 3
				sDie = "br_diered" + IntToString(iDieCurr) + "b";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );				
				sDie = "br_diered" + IntToString(iDieNext) + "t";
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
				SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );		
			}
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 1 );
			iDieBounce = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce" );
			if ( iDieBounce <= 0 ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 2 );
			} else {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce", iDieBounce - 1 );
			}
		} else {  // currently two half images, expected value 1
			// turn off current frames	
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUIObjectHidden ( oPC, "br_craps", s, TRUE );		
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
			SetGUIObjectHidden ( oPC, "br_craps", s, TRUE );	
			
			iDieFrame = iDieFrame - iDieFrameSkip;
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
			// get new current die face
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Next" );
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr", iDieCurr );			
		
			// turn on new frame
			sDie = "br_diered" + IntToString(iDieCurr);
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
			SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 0 );
			iDieBounce = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce" );
			if ( iDieBounce <= 0 ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 2 );
			} else {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce", iDieBounce - 1 );
			}
			
			// randomize die spin per roll
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin", Random(4) );											
		}		
	} else if ( iDieRollStatus == 2 ) {  // initiate final frames
		if ( iDieStatus == 0 ) {  // currently a full die
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr" );
			iDieResult = GetLocalInt ( oDealer, "iResult" + sDieNumber );
			if ( iDieCurr == iDieResult ) {  // already on result face
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 3 );
			} else {  // set up the final frame
				// turn off current frame
				s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUIObjectHidden ( oPC, "br_craps", s, TRUE );			
				
				iDieFrame = iDieFrame - iDieFrameSkip;
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );			
			
				// determine next die face
				iDieNext = iDieResult;
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Next", iDieNext );	
				iDieSpin = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin" );	
				// turn on new frames
				if ( iDieSpin == 0 ) {  // left spin
					sDie = "br_diered" + IntToString(iDieCurr) + "l";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
					SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );				
					sDie = "br_diered" + IntToString(iDieNext) + "r";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
					SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );											
				} else if ( iDieSpin == 1 ) {  // right spin
					sDie = "br_diered" + IntToString(iDieCurr) + "r";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
					SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );								
					sDie = "br_diered" + IntToString(iDieNext) + "l";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
					SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );							
				} else if ( iDieSpin == 2 ) {  // top spin
					sDie = "br_diered" + IntToString(iDieCurr) + "t";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
					SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );								
					sDie = "br_diered" + IntToString(iDieNext) + "b";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
					SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );							
				} else {  // bottom spin, expected value 3
					sDie = "br_diered" + IntToString(iDieCurr) + "b";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
					SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );								
					sDie = "br_diered" + IntToString(iDieNext) + "t";
					s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
					SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );						
				}
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 1 );
				iDieBounce = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce" );
				if ( iDieBounce <= 0 ) {
					SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 2 );
				} else {
					SetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce", iDieBounce - 1 );
				}
			}
		} else {  // currently two half images, expected value 1
			// turn off current frames	
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUIObjectHidden ( oPC, "br_craps", s, TRUE );
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
			SetGUIObjectHidden ( oPC, "br_craps", s, TRUE );
			
			iDieFrame = iDieFrame - iDieFrameSkip;
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
			
			// get new current die face
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Next" );
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr", iDieCurr );			
		
			// turn on new frame
			sDie = "br_diered" + IntToString(iDieCurr);
			s = "craps_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUITexture ( oPC, "br_craps", s, sDie + ".tga" );
			SetGUIObjectHidden ( oPC, "br_craps", s, FALSE );		
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 0 );
			iDieBounce = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce" );
			if ( iDieBounce <= 0 ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 2 );
			} else {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Bounce", iDieBounce - 1 );
			}
			
			// randomize die spin per roll
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin", Random(4) );											
		}		
	}
	
	fDieDelay = GetLocalFloat ( oDealer, "iDie" + sDieNumber + "Delay" );
	if ( iDieRollStatus != 3 ) {
		DelayCommand ( fDieDelay, Craps_RollDie ( oDealer, sDieNumber, iTutorialState ) );
	} else {
		if ( sDieNumber == "1" ) {
			if ( GetLocalInt ( oDealer, "iDie2RollStatus" ) == 4 ) {
				// all dice finished		
				DelayCommand ( fFinalDelay, Craps_BootstrapRoll ( oDealer, iTutorialState ) );
			} else {
				SetLocalInt ( oDealer, "iDie1RollStatus", 4 );
			}
		} else {
			if ( GetLocalInt ( oDealer, "iDie1RollStatus" ) == 4 ) {
				// all dice finished		
				DelayCommand ( fFinalDelay, Craps_BootstrapRoll ( oDealer, iTutorialState ) );
			} else {
				SetLocalInt ( oDealer, "iDie2RollStatus", 4 );
			}		
		}
	}		
}


// determine next course of action after a single roll

void Craps_BootstrapRoll ( object oDealer, int iTutorialState ) {
	if ( iTutorialState == 4 ) {
		Craps_ChangeState ( oDealer, 100 );
	} else if ( iTutorialState == 10 ) {
		Craps_ChangeState ( oDealer, 101 );		
	}
}


// clean up board between each state update

void Craps_CleanUpState ( object oPC ) {
	int i, iDieFrame;
	string s;
		
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_hilo", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_acedeuce", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_snakeeyes", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_yo", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_boxcars", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_anyseven", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_anycraps", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_cande", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_field", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_hard4", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_hard6", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_hard8", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_hard10", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placewin4", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placelose4", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placewin5", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placelose5", TRUE );	
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placewin6", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placelose6", TRUE );			
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placewin8", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placelose8", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placewin9", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placelose9", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placewin10", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_placelose10", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_buy4", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_lay4", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_buy5", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_lay5", TRUE );			
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_buy6", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_lay6", TRUE );			
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_buy8", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_lay8", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_buy9", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_lay9", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_buy10", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_lay10", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_pass", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_dontpass", TRUE );	
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_come8", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_comeodds8", TRUE );	
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_come", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_dontcome", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_big6", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_chip_big8", TRUE );	
	
	iDieFrame = GetLocalInt ( oPC, "iDie1Frame" );
	s = "craps_1_" + IntToString(iDieFrame) + "a";
	SetGUIObjectHidden ( oPC, "br_craps", s, TRUE );		
	iDieFrame = GetLocalInt ( oPC, "iDie2Frame" );
	s = "craps_2_" + IntToString(iDieFrame) + "a";
	SetGUIObjectHidden ( oPC, "br_craps", s, TRUE );
}


// close gui action

void Craps_CloseTutorial ( object oPC ) {
	Craps_CleanUpState(oPC);
	SetGUIObjectHidden ( oPC, "br_craps", "craps_die1", TRUE );
	SetGUIObjectHidden ( oPC, "br_craps", "craps_die2", TRUE );		
	SetGUIObjectHidden ( oPC, "br_craps", "notice_pane", FALSE );	
	CloseGUIScreen ( oPC, "br_craps" );
}