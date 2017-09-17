// Black Rain 2009


// game declarations, make sure these match the same declarations in the game include
const int iTripleRatio = 3;  
const int iStraightRatio = 2;
const int iChinchirorinTotalFrames = 500;  // number of frames from top of fall to bottom, do not modify unless GUI XML is modified
const int iChinchirorinStartFrameVariance = 20;  // starting position variance
const int iChinchirorinBaseFrameSkip = 40;  // base frameskip
const int iChinchirorinFrameSkipVariance = 20;  // frameskip variance
const float fChinchirorinBaseDelay = 0.04;  // base  delay per iteration
const int iChinchirorinDelayVariance = 4;  // each 1 int represents a 0.01 increase in fChinchirorinBaseDelay
const float fChinchirorinInitialDelay = 0.8;  // delay before rolling dice
const float fChinchirorinFinalDelay = 0.9;  // delay after rolling dice
const int iChinchirorinBaseFrameSkipLoss = 10;  // base frameskip loss on bounce
const int iChinchirorinFrameSkipLossVariance = 10;  // bounce frameskip loss variance


// function prototypes
void Chinchirorin_CleanUpState ( object oPC );
void Chinchirorin_SetupRoll ( object oDealer, int iTutorialState, int iRollNum );
void Chinchirorin_GenerateRollResults ( object oDealer, int iTutorialState, int iRollNum );
void Chinchirorin_RollDie ( object oDealer, string sDieNumber, int iTutorialState, int iRollNum );
void Chinchirorin_BootstrapRoll ( object oDealer, int iTutorialState, int iRollNum );
void Chinchirorin_CleanUpState ( object oPC );
void Chinchirorin_CloseTutorial ( object oPC );


// main function

void Chinchirorin_ChangeState ( object oPC, int iState ) {
	string sDie, sDisplayString;
		
	if ( iState == 1 ) {
		sDisplayString = "Chinchirorin is a simple game played with only three dice.  The dealer throws the dice up to three times, followed by the player throwing the dice up to three times.  The object of the game is to acquire a higher score than the dealer.";
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", TRUE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
		SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, "0" );
		SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_bet", -1, "0" );						
	} else if ( iState == 2 ) {
		sDisplayString = "After wagers are placed, the game starts with the dealer rolling the dice.  A score is established when two dice have identical values, the value of the third die then becomes the roller's score.  For example, a dice result of 2-2-6 would grant the dealer a score of 6.";	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", TRUE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", TRUE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", TRUE );
		Chinchirorin_SetupRoll ( oPC, iState, 1 );
	} else if ( iState == 3 ) {
		sDisplayString = "The dealer's third roll, 4-4-6, establishes the dealer's score as 6.";		
		sDie = "chinchirorin_1_" + IntToString(iChinchirorinTotalFrames) + "a";
		SetGUITexture ( oPC, "br_chinchirorin", sDie, "br_diewhite4.tga" );				
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sDie, FALSE );	
		sDie = "chinchirorin_2_" + IntToString(iChinchirorinTotalFrames) + "a";
		SetGUITexture ( oPC, "br_chinchirorin", sDie, "br_diewhite4.tga" );				
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sDie, FALSE );		
		sDie = "chinchirorin_3_" + IntToString(iChinchirorinTotalFrames) + "a";
		SetGUITexture ( oPC, "br_chinchirorin", sDie, "br_diewhite6.tga" );				
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sDie, FALSE );			
		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
	} else if ( iState == 4 ) {
		sDisplayString = "After the dealer establishes a score, the player then rolls the dice to establish a score.  The dealer and player each have three chances to establish a score.  If no score is established within three rolls, a score of 0 is granted.";		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", TRUE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", TRUE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", TRUE );
		Chinchirorin_SetupRoll ( oPC, iState, 1 );		
	} else if ( iState == 5 ) {
		sDisplayString = "The player's second roll, 6-6-1, establishes the player's score as 1.  The dealer wins this round.  If the player opts to play another round, the next round begins with the dealer once again rolling for score.";	
		sDie = "chinchirorin_1_" + IntToString(iChinchirorinTotalFrames) + "a";
		SetGUITexture ( oPC, "br_chinchirorin", sDie, "br_diewhite6.tga" );				
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sDie, FALSE );	
		sDie = "chinchirorin_2_" + IntToString(iChinchirorinTotalFrames) + "a";
		SetGUITexture ( oPC, "br_chinchirorin", sDie, "br_diewhite6.tga" );				
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sDie, FALSE );		
		sDie = "chinchirorin_3_" + IntToString(iChinchirorinTotalFrames) + "a";
		SetGUITexture ( oPC, "br_chinchirorin", sDie, "br_diewhite1.tga" );				
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sDie, FALSE );			
		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
	} else if ( iState == 6 ) {
		sDisplayString = "Some dice results result in an immediate win or loss, regardless of who the current roller is.  These rolls are called storms, and there are two types of them: triples and straights.";				
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
	} else if ( iState == 7 ) {
		sDisplayString = "A triple occurs when all three dice come up identical values.  A triple 1 roll is an immediate loss for the roller, while any other triple roll is an immediate win.  If the dealer rolls a triple, the round is over without the player rolling the dice.";
		sDie = "chinchirorin_1_" + IntToString(iChinchirorinTotalFrames) + "a";
		SetGUITexture ( oPC, "br_chinchirorin", sDie, "br_diewhite6.tga" );				
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sDie, FALSE );	
		sDie = "chinchirorin_2_" + IntToString(iChinchirorinTotalFrames) + "a";
		SetGUITexture ( oPC, "br_chinchirorin", sDie, "br_diewhite6.tga" );				
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sDie, FALSE );		
		sDie = "chinchirorin_3_" + IntToString(iChinchirorinTotalFrames) + "a";
		SetGUITexture ( oPC, "br_chinchirorin", sDie, "br_diewhite6.tga" );				
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sDie, FALSE );	
		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
	} else if ( iState == 8 ) {
		sDisplayString = "A straight occurs when the dice come up 1-2-3 or 4-5-6.  A low straight is an immediate loser for the roller, while a high straight is an immediate winner.  Similar to triples, if the dealer rolls a straight the round is over without the player rolling.";
		sDie = "chinchirorin_1_" + IntToString(iChinchirorinTotalFrames) + "a";
		SetGUITexture ( oPC, "br_chinchirorin", sDie, "br_diewhite4.tga" );				
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sDie, FALSE );	
		sDie = "chinchirorin_2_" + IntToString(iChinchirorinTotalFrames) + "a";
		SetGUITexture ( oPC, "br_chinchirorin", sDie, "br_diewhite5.tga" );				
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sDie, FALSE );		
		sDie = "chinchirorin_3_" + IntToString(iChinchirorinTotalFrames) + "a";
		SetGUITexture ( oPC, "br_chinchirorin", sDie, "br_diewhite6.tga" );				
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sDie, FALSE );	
		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
	} else if ( iState == 9 ) {
		sDisplayString = "Storms also pay out more than regular wins.  A triple will win or lose the player " + IntToString(iTripleRatio) + "X the original bet, depending on who rolled the triple and what type was rolled.  Similarly, straights will win or lose the player " + IntToString(iStraightRatio) + "X the original bet.";			
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 10 ) {
		sDisplayString = "That's all you need to know to enjoy a few rounds of chinchirorin.  Good luck!";
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", TRUE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 100 ) {
		sDisplayString = "After wagers are placed, the game starts with the dealer rolling the dice.  A score is established when two dice have identical values, the value of the third die then becomes the roller's score.  For example, a dice result of 2-2-6 would grant the dealer a score of 6.";		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 101 ) {
		sDisplayString = "After the dealer establishes a score, the player then rolls the dice to establish a score.  The dealer and player each have three chances to establish a score.  If no score is established within three rolls, a score of 0 is granted.";	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	}
	
	SetGUIObjectText ( oPC, "br_tutorial", "tutorial_text", -1, sDisplayString );	
}


// set up a roll

void Chinchirorin_SetupRoll ( object oDealer, int iTutorialState, int iRollNum ) {
	float f;
	int i, iRandom;
	object oPC;
	string s, sDie, sVarName;

	oPC = oDealer;
	Chinchirorin_CleanUpState(oPC);
		
	// set up each die's initial roll parameters
	for ( i = 1 ; i <= 3 ; i++ ) {
		s = IntToString(i);	
		iRandom = Random(iChinchirorinStartFrameVariance);
		sVarName = "chinchirorin_" + s + "_" + IntToString(iRandom) + "a";
		SetLocalInt ( oDealer, "iDie" + s + "Frame", iRandom );
		iRandom = Random(6) + 1;
		sDie = "br_diewhite" + IntToString(iRandom) + ".tga";
		SetGUITexture ( oPC, "br_chinchirorin", sVarName, sDie );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sVarName, FALSE );
		SetLocalInt ( oDealer, "iDie" + s + "Curr", iRandom );
		iRandom = Random(iChinchirorinFrameSkipVariance) + iChinchirorinBaseFrameSkip;		
		SetLocalInt ( oDealer, "iDie" + s + "FrameSkip", iRandom );
		SetLocalInt ( oDealer, "iDie" + s + "RollStatus", 0 );
		SetLocalInt ( oDealer, "iDie" + s + "Spin", Random(4) );
		SetLocalInt ( oDealer, "iDie" + s + "Status", 0 );
		f = ( IntToFloat(Random(iChinchirorinDelayVariance)) * 0.01 ) + fChinchirorinBaseDelay;
		SetLocalFloat ( oDealer, "fDie" + s + "Delay", f );
	}
		
	Chinchirorin_GenerateRollResults ( oDealer, iTutorialState, iRollNum );
	DelayCommand ( fChinchirorinInitialDelay, Chinchirorin_RollDie ( oDealer, "1", iTutorialState, iRollNum ) );
	DelayCommand ( fChinchirorinInitialDelay, Chinchirorin_RollDie ( oDealer, "2", iTutorialState, iRollNum ) );
	DelayCommand ( fChinchirorinInitialDelay, Chinchirorin_RollDie ( oDealer, "3", iTutorialState, iRollNum ) );
}


// set up the results of a roll

void Chinchirorin_GenerateRollResults ( object oDealer, int iTutorialState, int iRollNum ) {
	if ( iTutorialState == 2 ) {
		if ( iRollNum == 1 ) {
			SetLocalInt ( oDealer, "iDie1Result", 4 );
			SetLocalInt ( oDealer, "iDie2Result", 1 );	
			SetLocalInt ( oDealer, "iDie3Result", 3 );											
		} else if ( iRollNum == 2 ) {
			SetLocalInt ( oDealer, "iDie1Result", 6 );
			SetLocalInt ( oDealer, "iDie2Result", 2 );	
			SetLocalInt ( oDealer, "iDie3Result", 4 );			
		} else if ( iRollNum == 3 ) {
			SetLocalInt ( oDealer, "iDie1Result", 4 );
			SetLocalInt ( oDealer, "iDie2Result", 4 );	
			SetLocalInt ( oDealer, "iDie3Result", 6 );			
		}
	} else if ( iTutorialState == 4 ) {
		if ( iRollNum == 1 ) {
			SetLocalInt ( oDealer, "iDie1Result", 2 );
			SetLocalInt ( oDealer, "iDie2Result", 5 );	
			SetLocalInt ( oDealer, "iDie3Result", 3 );			
		} else if ( iRollNum == 2 ) {
			SetLocalInt ( oDealer, "iDie1Result", 6 );
			SetLocalInt ( oDealer, "iDie2Result", 6 );	
			SetLocalInt ( oDealer, "iDie3Result", 1 );	
		}
	}		
}


// advance sDie to its next roll state, with sDie being "1", "2", or "3"

void Chinchirorin_RollDie ( object oDealer, string sDieNumber, int iTutorialState, int iRollNum ) {
	float fDieDelay;
	int i, iDieCurr, iDieFrame, iDieFrameSkip, iDieNext, iDieRollStatus, iDieSpin, iDieStatus;
	object oPC;
	string s, sDie;
	
	// basic setup
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
			s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );			
			
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
				sDie = "br_diewhite" + IntToString(iDieCurr) + "l.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
				sDie = "br_diewhite" + IntToString(iDieNext) + "r.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );								
			} else if ( iDieSpin == 1 ) {  // right spin
				sDie = "br_diewhite" + IntToString(iDieCurr) + "r.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
				sDie = "br_diewhite" + IntToString(iDieNext) + "l.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );			
			} else if ( iDieSpin == 2 ) {  // top spin
				sDie = "br_diewhite" + IntToString(iDieCurr) + "t.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
				sDie = "br_diewhite" + IntToString(iDieNext) + "b.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );			
			} else {  // bottom spin, expected value 3
				sDie = "br_diewhite" + IntToString(iDieCurr) + "b.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
				sDie = "br_diewhite" + IntToString(iDieNext) + "t.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );			
			}
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 1 );
			if ( iDieFrame > iChinchirorinTotalFrames - iDieFrameSkip ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 1 );
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "FrameSkip", iDieFrameSkip - ( iChinchirorinBaseFrameSkipLoss + Random(iChinchirorinFrameSkipLossVariance) ) );				
				AssignCommand ( oPC, PlaySound ( "cb_ht_whipston" ) );				
			}
		} else {  // currently two half images, expected value 1
			// turn off current frames	
			s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );	
			s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
			SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );
			
			iDieFrame = iDieFrame + iDieFrameSkip;
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
			
			// get new current die face
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Next" );
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr", iDieCurr );			
		
			// turn on new frame
			sDie = "br_diewhite" + IntToString(iDieCurr) + ".tga";
			s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
			SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 0 );	
			if ( iDieFrame > iChinchirorinTotalFrames - iDieFrameSkip ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 1 );
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "FrameSkip", iDieFrameSkip - ( iChinchirorinBaseFrameSkipLoss + Random(iChinchirorinFrameSkipLossVariance) ) );
				AssignCommand ( oPC, PlaySound ( "cb_ht_whipston" ) );				
			}			
			
			// randomize die spin per roll
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin", Random(4) );							
		}	
	} else if ( iDieRollStatus == 1 ) {  // bounce
		if ( iDieStatus == 0 ) {  // currently a full die
			// turn off current frame
			s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );			
			
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
				sDie = "br_diewhite" + IntToString(iDieCurr) + "l.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
				sDie = "br_diewhite" + IntToString(iDieNext) + "r.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );								
			} else if ( iDieSpin == 1 ) {  // right spin
				sDie = "br_diewhite" + IntToString(iDieCurr) + "r.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
				sDie = "br_diewhite" + IntToString(iDieNext) + "l.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );			
			} else if ( iDieSpin == 2 ) {  // top spin
				sDie = "br_diewhite" + IntToString(iDieCurr) + "t.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
				sDie = "br_diewhite" + IntToString(iDieNext) + "b.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );			
			} else {  // bottom spin, expected value 3
				sDie = "br_diewhite" + IntToString(iDieCurr) + "b.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
				sDie = "br_diewhite" + IntToString(iDieNext) + "t.tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );			
			}
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 1 );
			if ( iDieFrame < ( ( iChinchirorinTotalFrames / 3 )* 2 ) ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 2 );				
			}
		} else {  // currently two half images, expected value 1
			// turn off current frames	
			s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );	
			s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
			SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );
			
			iDieFrame = iDieFrame - iDieFrameSkip;
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
			
			// get new current die face
			iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Next" );
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr", iDieCurr );			
		
			// turn on new frame
			sDie = "br_diewhite" + IntToString(iDieCurr) + ".tga";
			s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
			SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
			SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 0 );	
			if ( iDieFrame < ( ( iChinchirorinTotalFrames / 3 )* 2 ) ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 2 );
			}	
			
			// randomize die spin per roll
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin", Random(4) );											
		}	
	} else if ( iDieRollStatus == 2 ) {  // final drop
		if ( iDieFrame > iChinchirorinTotalFrames - iDieFrameSkip + 1 ) {  // last frame
			if ( iDieStatus == 0 ) {  // currently a full die
				// disable current frame
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );
			
				// get current die face
				iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr" );				
				
				// turn on new frame
				iDieFrame = iChinchirorinTotalFrames;
				sDie = "br_diewhite" + IntToString(iDieCurr) + ".tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );								
			} else {  // two half images, expected value 1
				// disable current frames
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );	
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );
				
				// get new current die face
				iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Next" );				
				
				// turn on new frame
				iDieFrame = iChinchirorinTotalFrames;
				sDie = "br_diewhite" + IntToString(iDieCurr) + ".tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );	
				
				// randomize die spin per roll
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin", Random(4) );													
			}
			iDieRollStatus = 3;
		} else if ( iDieFrame > iChinchirorinTotalFrames - ( iDieFrameSkip * 3 ) ) {  // 2nd or 3rd to last frame
			if ( iDieStatus == 0 ) {  // currently a full die
				// turn off current frame
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );			
				
				iDieFrame = iDieFrame + iDieFrameSkip;
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
					
				iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr" );			
				// determine next die face
				iDieNext = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Result" );
				
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Next", iDieNext );	
				iDieSpin = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin" );	
				// turn on new frames
				if ( iDieSpin == 0 ) {  // left spin
					sDie = "br_diewhite" + IntToString(iDieCurr) + "l.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
					sDie = "br_diewhite" + IntToString(iDieNext) + "r.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );								
				} else if ( iDieSpin == 1 ) {  // right spin
					sDie = "br_diewhite" + IntToString(iDieCurr) + "r.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
					sDie = "br_diewhite" + IntToString(iDieNext) + "l.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );			
				} else if ( iDieSpin == 2 ) {  // top spin
					sDie = "br_diewhite" + IntToString(iDieCurr) + "t.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
					sDie = "br_diewhite" + IntToString(iDieNext) + "b.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );			
				} else {  // bottom spin, expected value 3
					sDie = "br_diewhite" + IntToString(iDieCurr) + "b.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
					sDie = "br_diewhite" + IntToString(iDieNext) + "t.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );			
				}
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 1 );	
			} else {  // currently two half images, expected value 1
				// turn off current frames	
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );	
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );
				
				iDieFrame = iDieFrame + iDieFrameSkip;
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
				
				// get new current die face
				iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Next" );
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr", iDieCurr );			
			
				// turn on new frame
				sDie = "br_diewhite" + IntToString(iDieCurr) + ".tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 0 );	
				
				// randomize die spin per roll
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin", Random(4) );							
			}
		} else {
			if ( iDieStatus == 0 ) {  // currently a full die
				// turn off current frame
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );			
				
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
					sDie = "br_diewhite" + IntToString(iDieCurr) + "l.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
					sDie = "br_diewhite" + IntToString(iDieNext) + "r.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );								
				} else if ( iDieSpin == 1 ) {  // right spin
					sDie = "br_diewhite" + IntToString(iDieCurr) + "r.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
					sDie = "br_diewhite" + IntToString(iDieNext) + "l.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );			
				} else if ( iDieSpin == 2 ) {  // top spin
					sDie = "br_diewhite" + IntToString(iDieCurr) + "t.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
					sDie = "br_diewhite" + IntToString(iDieNext) + "b.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );			
				} else {  // bottom spin, expected value 3
					sDie = "br_diewhite" + IntToString(iDieCurr) + "b.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );				
					sDie = "br_diewhite" + IntToString(iDieNext) + "t.tga";
					s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
					SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
					SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );			
				}
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 1 );
			} else {  // currently two half images, expected value 1
				// turn off current frames	
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );	
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "b";
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );
				
				iDieFrame = iDieFrame + iDieFrameSkip;
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Frame", iDieFrame );
				
				// get new current die face
				iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Next" );
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr", iDieCurr );			
			
				// turn on new frame
				sDie = "br_diewhite" + IntToString(iDieCurr) + ".tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Status", 0 );
				
				// randomize die spin per roll
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin", Random(4) );											
			}			
		}
	}
	
	if ( iDieRollStatus != 3 ) {
		fDieDelay = GetLocalFloat ( oDealer, "fDie" + sDieNumber + "Delay" );	
		DelayCommand ( fDieDelay, Chinchirorin_RollDie ( oDealer, sDieNumber, iTutorialState, iRollNum ) );
	} else {
		if ( sDieNumber == "1" ) {
			if ( ( GetLocalInt ( oDealer, "iDie2RollStatus" ) == 3 ) && ( GetLocalInt ( oDealer, "iDie3RollStatus" ) == 3 ) ) {
				// all dice finished
				DelayCommand ( fChinchirorinFinalDelay, Chinchirorin_BootstrapRoll ( oDealer, iTutorialState, iRollNum ) );
			} else {
				SetLocalInt ( oDealer, "iDie1RollStatus", iDieRollStatus );
			}		
		} else if ( sDieNumber == "2" ) {
			if ( ( GetLocalInt ( oDealer, "iDie1RollStatus" ) == 3 ) && ( GetLocalInt ( oDealer, "iDie3RollStatus" ) == 3 ) ) {
				// all dice finished
				DelayCommand ( fChinchirorinFinalDelay, Chinchirorin_BootstrapRoll ( oDealer, iTutorialState, iRollNum ) );
			} else {
				SetLocalInt ( oDealer, "iDie2RollStatus", iDieRollStatus );
			}				
		} else {
			if ( ( GetLocalInt ( oDealer, "iDie1RollStatus" ) == 3 ) && ( GetLocalInt ( oDealer, "iDie2RollStatus" ) == 3 ) ) {
				// all dice finished
				DelayCommand ( fChinchirorinFinalDelay, Chinchirorin_BootstrapRoll ( oDealer, iTutorialState, iRollNum ) );
			} else {
				SetLocalInt ( oDealer, "iDie3RollStatus", iDieRollStatus );
			}				
		}
	}
}


// determine next course of action after a single roll

void Chinchirorin_BootstrapRoll ( object oDealer, int iTutorialState, int iRollNum ) {
	if ( iTutorialState == 2 ) {
		if ( iRollNum == 1 ) {
			Chinchirorin_SetupRoll ( oDealer, iTutorialState, 2 );		
		} else if ( iRollNum == 2 ) {
			Chinchirorin_SetupRoll ( oDealer, iTutorialState, 3 );			
		} else if ( iRollNum == 3 ) {
			Chinchirorin_ChangeState ( oDealer, 100 );	
		}
	} else if ( iTutorialState == 4 ) {
		if ( iRollNum == 1 ) {
			Chinchirorin_SetupRoll ( oDealer, iTutorialState, 2 );		
		} else if ( iRollNum == 2 ) {
			Chinchirorin_ChangeState ( oDealer, 101 );			
		}	
	}
}


// clean up board between each state update

void Chinchirorin_CleanUpState ( object oPC ) {
	string s, sTotalFrames;
	
	sTotalFrames = IntToString(iChinchirorinTotalFrames);
	s = "chinchirorin_1_" + sTotalFrames + "a";
	SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );		
	s = "chinchirorin_2_" + sTotalFrames + "a";
	SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );
	s = "chinchirorin_3_" + sTotalFrames + "a";
	SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );	
}


// close gui action

void Chinchirorin_CloseTutorial ( object oPC ) {
	Chinchirorin_CleanUpState(oPC);
	CloseGUIScreen ( oPC, "br_chinchirorin" );
}