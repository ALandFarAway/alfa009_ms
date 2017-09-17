// Black Rain 2008

#include "z_casino_stats_include"


// bet boundaries and payoff rates, these can be modified in-game
// payoff values are for ratio of payoff
const int iMinBet = 100;
const int iMaxBet = 1000;
const int iBetIncrement = 100;
const int iTripleRatio = 3;  
const int iStraightRatio = 2;


// system vars
const int iTotalFrames = 500;  // number of frames from top of fall to bottom, do not modify unless GUI XML is modified
const int iStartFrameVariance = 20;  // starting position variance
const int iBaseFrameSkip = 40;  // base frameskip
const int iFrameSkipVariance = 20;  // frameskip variance
const float fBaseDelay = 0.04;  // base  delay per iteration
const int iDelayVariance = 4;  // each 1 int represents a 0.01 increase in fBaseDelay
const float fInitialDelay = 0.8;  // delay before rolling dice
const float fFinalDelay = 0.9;  // delay after rolling dice
const int iBaseFrameSkipLoss = 10;  // base frameskip loss on bounce
const int iFrameSkipLossVariance = 10;  // bounce frameskip loss variance
const int iIdleTimer = 30;  // idle time allowed to players before action is forced


// function prototypes

void SetupRoll ( object oDealer );
void GenerateRollResults ( object oDealer );
void RollDie ( object oDealer, string sDieNumber );
void EvaluateRoll ( object oDealer );
void RollIdleTimer ( object oDealer, int iIdleTimerCount );
void EndRoundIdleTimer ( object oDealer, int iIdleTimerCount );


// set up a roll

void SetupRoll ( object oDealer ) {
	float f;
	int i, iRandom;
	object oPC;
	string s, sDie, sVarName;

	oPC = GetLocalObject ( oDealer, "oPlayer" );
	
	// set up each die's initial roll parameters
	for ( i = 1 ; i <= 3 ; i++ ) {
		s = IntToString(i);	
		iRandom = Random(iStartFrameVariance);
		sVarName = "chinchirorin_" + s + "_" + IntToString(iRandom) + "a";
		SetLocalInt ( oDealer, "iDie" + s + "Frame", iRandom );
		iRandom = Random(6) + 1;
		sDie = "br_diewhite" + IntToString(iRandom) + ".tga";
		SetGUITexture ( oPC, "br_chinchirorin", sVarName, sDie );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", sVarName, FALSE );
		SetLocalInt ( oDealer, "iDie" + s + "Curr", iRandom );
		iRandom = Random(iFrameSkipVariance) + iBaseFrameSkip;		
		SetLocalInt ( oDealer, "iDie" + s + "FrameSkip", iRandom );
		SetLocalInt ( oDealer, "iDie" + s + "RollStatus", 0 );
		SetLocalInt ( oDealer, "iDie" + s + "Spin", Random(4) );
		SetLocalInt ( oDealer, "iDie" + s + "Status", 0 );
		f = ( IntToFloat(Random(iDelayVariance)) * 0.01 ) + fBaseDelay;
		SetLocalFloat ( oDealer, "fDie" + s + "Delay", f );
	}
		
	GenerateRollResults(oDealer);
	DelayCommand ( fInitialDelay, RollDie ( oDealer, "1" ) );
	DelayCommand ( fInitialDelay, RollDie ( oDealer, "2" ) );
	DelayCommand ( fInitialDelay, RollDie ( oDealer, "3" ) );
}


// set up the results of a roll

void GenerateRollResults ( object oDealer ) {
	int i;
	string s;
	
	for ( i = 1 ; i <= 3 ; i++ ) {
		s = IntToString(i);
		SetLocalInt ( oDealer, "iDie" + s + "Result", Random(6) + 1 );
	}		
}


// advance sDie to its next roll state, with sDie being "1", "2", or "3"

void RollDie ( object oDealer, string sDieNumber ) {
	float fDieDelay;
	int i, iDieCurr, iDieFrame, iDieFrameSkip, iDieNext, iDieRollStatus, iDieSpin, iDieStatus;
	object oPC;
	string s, sDie;
	
	// basic setup
	oPC = GetLocalObject ( oDealer, "oPlayer" );	

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
			if ( iDieFrame > iTotalFrames - iDieFrameSkip ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 1 );
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "FrameSkip", iDieFrameSkip - ( iBaseFrameSkipLoss + Random(iFrameSkipLossVariance) ) );				
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
			if ( iDieFrame > iTotalFrames - iDieFrameSkip ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 1 );
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "FrameSkip", iDieFrameSkip - ( iBaseFrameSkipLoss + Random(iFrameSkipLossVariance) ) );
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
			if ( iDieFrame < ( ( iTotalFrames / 3 )* 2 ) ) {
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
			if ( iDieFrame < ( ( iTotalFrames / 3 )* 2 ) ) {
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "RollStatus", 2 );
			}	
			
			// randomize die spin per roll
			SetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin", Random(4) );											
		}	
	} else if ( iDieRollStatus == 2 ) {  // final drop
		if ( iDieFrame > iTotalFrames - iDieFrameSkip + 1 ) {  // last frame
			if ( iDieStatus == 0 ) {  // currently a full die
				// disable current frame
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, TRUE );
			
				// get current die face
				iDieCurr = GetLocalInt ( oDealer, "iDie" + sDieNumber + "Curr" );				
				
				// turn on new frame
				iDieFrame = iTotalFrames;
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
				iDieFrame = iTotalFrames;
				sDie = "br_diewhite" + IntToString(iDieCurr) + ".tga";
				s = "chinchirorin_" + sDieNumber + "_" + IntToString(iDieFrame) + "a";
				SetGUITexture ( oPC, "br_chinchirorin", s, sDie );				
				SetGUIObjectHidden ( oPC, "br_chinchirorin", s, FALSE );	
				
				// randomize die spin per roll
				SetLocalInt ( oDealer, "iDie" + sDieNumber + "Spin", Random(4) );													
			}
			iDieRollStatus = 3;
		} else if ( iDieFrame > iTotalFrames - ( iDieFrameSkip * 3 ) ) {  // 2nd or 3rd to last frame
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
		DelayCommand ( fDieDelay, RollDie ( oDealer, sDieNumber ) );
	} else {
		if ( sDieNumber == "1" ) {
			if ( ( GetLocalInt ( oDealer, "iDie2RollStatus" ) == 3 ) && ( GetLocalInt ( oDealer, "iDie3RollStatus" ) == 3 ) ) {
				// all dice finished
				DelayCommand ( fFinalDelay, EvaluateRoll(oDealer) );
			} else {
				SetLocalInt ( oDealer, "iDie1RollStatus", iDieRollStatus );
			}		
		} else if ( sDieNumber == "2" ) {
			if ( ( GetLocalInt ( oDealer, "iDie1RollStatus" ) == 3 ) && ( GetLocalInt ( oDealer, "iDie3RollStatus" ) == 3 ) ) {
				// all dice finished
				DelayCommand ( fFinalDelay, EvaluateRoll(oDealer) );
			} else {
				SetLocalInt ( oDealer, "iDie2RollStatus", iDieRollStatus );
			}				
		} else {
			if ( ( GetLocalInt ( oDealer, "iDie1RollStatus" ) == 3 ) && ( GetLocalInt ( oDealer, "iDie2RollStatus" ) == 3 ) ) {
				// all dice finished
				DelayCommand ( fFinalDelay, EvaluateRoll(oDealer) );
			} else {
				SetLocalInt ( oDealer, "iDie3RollStatus", iDieRollStatus );
			}				
		}
	}
}


// evaluate a roll for results

void EvaluateRoll ( object oDealer ) {
	int i, iBet, iRatio, iRound, iResult1, iResult2, iResult3, iScore;
	object oPC;
	string s, sTotalFrames;
	
	oPC = GetLocalObject(oDealer, "oPlayer");
	iRound = GetLocalInt ( oDealer, "iRound" );;
	iResult1 = GetLocalInt ( oDealer, "iDie1Result" );
	iResult2 = GetLocalInt ( oDealer, "iDie2Result" );
	iResult3 = GetLocalInt ( oDealer, "iDie3Result" );
	iScore = 0;
	
	if ( ( iResult1 == iResult2 ) && ( iResult1 == iResult3 ) ) {	// check triples
		if ( iResult1 == 1 ) {  // losing triple
			if ( iRound <= 3 ) {  // bank turn				
				s = "Triple 1 storm, bank loses triple!";				
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);				
				iRatio = GetLocalInt ( oDealer, "iTripleRatio" );
				if ( iRatio == 0 ) {
					iRatio = iTripleRatio;
				}
				iBet = iBet * iRatio;
				GiveGoldToCreature ( oPC, iBet, TRUE );
				i = i + iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );				
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );	
				i = GetLocalInt ( oDealer, "iPlayerGoldWon" );
				SetLocalInt ( oDealer, "iPlayerGoldWon", i + iBet );			
			} else {  // player turn			
				s = "Triple 1 storm, player loses triple!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);		
				iRatio = GetLocalInt ( oDealer, "iTripleRatio" );
				if ( iRatio == 0 ) {
					iRatio = iTripleRatio;
				}	
				iBet = iBet * iRatio;			
				AssignCommand ( oDealer, TakeGoldFromCreature ( iBet, oPC, TRUE, TRUE ) );							
				i = i - iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );								
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldLost" );
				SetLocalInt ( oDealer, "iPlayerGoldLost", i + iBet );										
			}
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_frame", FALSE );			
			SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_notice", -1, s );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", FALSE );
		} else {  // winning triple, expected result 2-6
			if ( iRound <= 3 ) {  // bank turn
				s = "Triple " + IntToString(iResult1) + " storm, bank takes triple!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);		
				iRatio = GetLocalInt ( oDealer, "iTripleRatio" );
				if ( iRatio == 0 ) {
					iRatio = iTripleRatio;
				}				
				iBet = iBet * iRatio;
				AssignCommand ( oDealer, TakeGoldFromCreature ( iBet, oPC, TRUE, TRUE ) );							
				i = i - iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldLost" );
				SetLocalInt ( oDealer, "iPlayerGoldLost", i + iBet );				
			} else {  // player turn
				s = "Triple " + IntToString(iResult1) + " storm, player wins triple!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);				
				iRatio = GetLocalInt ( oDealer, "iTripleRatio" );
				if ( iRatio == 0 ) {
					iRatio = iTripleRatio;
				}							
				iBet = iBet * iRatio;	
				GiveGoldToCreature ( oPC, iBet, TRUE );
				i = i + iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );							
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldWon" );
				SetLocalInt ( oDealer, "iPlayerGoldWon", i + iBet );								
			}
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_frame", FALSE );			
			SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_notice", -1, s );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", FALSE );		
		}
		iRound = 8;
	} else if ( iResult1 == iResult2 ) {  // check for score
		if ( iRound <= 3 ) {  // set bank score
			s = "Bank's score is " + IntToString(iResult3);
			iScore = iResult3;
			SetLocalInt ( oDealer, "iScore", iResult3 );
			iRound = 3;
		} else {  // compare bank score to player score
			iScore = GetLocalInt ( oDealer, "iScore" );
			if ( iResult3 > iScore ) {  // player has higher score
				s = "Player scores " + IntToString(iResult3) + ", Bank scores " + IntToString(iScore) + ", player wins!";
				i = GetGold(oPC);				
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );								
				GiveGoldToCreature ( oPC, iBet, TRUE );			
				i = i + iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );					
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );	
				i = GetLocalInt ( oDealer, "iPlayerGoldWon" );
				SetLocalInt ( oDealer, "iPlayerGoldWon", i + iBet );							
			} else if ( iResult3 < iScore ) {  // player has lower score
				s = "Player scores " + IntToString(iResult3) + ", Bank scores " + IntToString(iScore) + ", bank wins!";
				i = GetGold(oPC);				
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );						
				AssignCommand ( oDealer, TakeGoldFromCreature ( iBet, oPC, TRUE, TRUE ) );							
				i = i - iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );											
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldLost" );
				SetLocalInt ( oDealer, "iPlayerGoldLost", i + iBet );							
			} else {  // tie
				s = "Player ties bank, wash!";			
			}
			iRound = 8;
		}
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_frame", FALSE );		
		SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_notice", -1, s );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", FALSE );		
	} else if ( iResult2 == iResult3 ) {
		if ( iRound <= 3 ) {  // set bank score
			s = "Bank's score is " + IntToString(iResult1);
			iScore = iResult1;			
			SetLocalInt ( oDealer, "iScore", iResult1 );
			iRound = 3;
		} else {  // compare bank score to player score
			iScore = GetLocalInt ( oDealer, "iScore" );
			if ( iResult1 > iScore ) {  // player has higher score
				s = "Player scores " + IntToString(iResult1) + ", Bank scores " + IntToString(iScore) + ", player wins!";
				i = GetGold(oPC);				
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );								
				GiveGoldToCreature ( oPC, iBet, TRUE );			
				i = i + iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );					
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );	
				i = GetLocalInt ( oDealer, "iPlayerGoldWon" );
				SetLocalInt ( oDealer, "iPlayerGoldWon", i + iBet );							
			} else if ( iResult1 < iScore ) {  // player has lower score
				s = "Player scores " + IntToString(iResult1) + ", Bank scores " + IntToString(iScore) + ", bank wins!";
				i = GetGold(oPC);				
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );						
				AssignCommand ( oDealer, TakeGoldFromCreature ( iBet, oPC, TRUE, TRUE ) );							
				i = i - iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );											
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldLost" );
				SetLocalInt ( oDealer, "iPlayerGoldLost", i + iBet );							
			} else {  // tie
				s = "Player ties bank, wash!";			
			}
			iRound = 8;
		}
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_frame", FALSE );			
		SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_notice", -1, s );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", FALSE );	
	} else if ( iResult1 == iResult3 ) {
		if ( iRound <= 3 ) {  // set bank score
			s = "Bank's score is " + IntToString(iResult2);
			iScore = iResult2;			
			SetLocalInt ( oDealer, "iScore", iResult2 );
			iRound = 3;
		} else {  // compare bank score to player score
			iScore = GetLocalInt ( oDealer, "iScore" );
			if ( iResult2 > iScore ) {  // player has higher score
				s = "Player scores " + IntToString(iResult2) + ", Bank scores " + IntToString(iScore) + ", player wins!";
				i = GetGold(oPC);				
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );								
				GiveGoldToCreature ( oPC, iBet, TRUE );			
				i = i + iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );					
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );	
				i = GetLocalInt ( oDealer, "iPlayerGoldWon" );
				SetLocalInt ( oDealer, "iPlayerGoldWon", i + iBet );							
			} else if ( iResult3 < iScore ) {  // player has lower score
				s = "Player scores " + IntToString(iResult2) + ", Bank scores " + IntToString(iScore) + ", bank wins!";
				i = GetGold(oPC);				
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );						
				AssignCommand ( oDealer, TakeGoldFromCreature ( iBet, oPC, TRUE, TRUE ) );							
				i = i - iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );											
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldLost" );
				SetLocalInt ( oDealer, "iPlayerGoldLost", i + iBet );							
			} else {  // tie
				s = "Player ties bank, wash!";			
			}
			iRound = 8;
		}
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_frame", FALSE );			
		SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_notice", -1, s );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", FALSE );
	} else if ( iResult1 == 1 ) {  // check low straights
		if ( ( iResult2 == 2 ) && ( iResult3 == 3 ) || ( iResult2 == 3 ) && ( iResult3 == 2 ) ) {
			if ( iRound <= 3 ) {  // bank rolls low straight
				s = "1-2-3 low straight, bank loses double!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);				
				iRatio = GetLocalInt ( oDealer, "iStraightRatio" );
				if ( iRatio == 0 ) {
					iRatio = iStraightRatio;
				}
				iBet = iBet * iRatio;
				GiveGoldToCreature ( oPC, iBet, TRUE );
				i = i + iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );			
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldWon" );
				SetLocalInt ( oDealer, "iPlayerGoldWon", i + iBet );								
			} else {  // player rolls low straight
				s = "1-2-3 low straight, player loses double!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);		
				iRatio = GetLocalInt ( oDealer, "iStraightRatio" );
				if ( iRatio == 0 ) {
					iRatio = iStraightRatio;
				}				
				iBet = iBet * iRatio;
				AssignCommand ( oDealer, TakeGoldFromCreature ( iBet, oPC, TRUE, TRUE ) );	
				i = i - iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );	
				i = GetLocalInt ( oDealer, "iPlayerGoldLost" );
				SetLocalInt ( oDealer, "iPlayerGoldLost", i + iBet );							
			}
			iRound = 8;		
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_frame", FALSE );				
			SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_notice", -1, s );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", FALSE );		
		}
	} else if ( iResult1 == 2 ) {
		if ( ( iResult2 == 1 ) && ( iResult3 == 3 ) || ( iResult2 == 3 ) && ( iResult3 == 1 ) ) {
			if ( iRound <= 3 ) {  // bank rolls low straight
				s = "1-2-3 low straight, bank loses double!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);				
				iRatio = GetLocalInt ( oDealer, "iStraightRatio" );
				if ( iRatio == 0 ) {
					iRatio = iStraightRatio;
				}
				iBet = iBet * iRatio;
				GiveGoldToCreature ( oPC, iBet, TRUE );
				i = i + iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );			
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldWon" );
				SetLocalInt ( oDealer, "iPlayerGoldWon", i + iBet );								
			} else {  // player rolls low straight
				s = "1-2-3 low straight, player loses double!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);		
				iRatio = GetLocalInt ( oDealer, "iStraightRatio" );
				if ( iRatio == 0 ) {
					iRatio = iStraightRatio;
				}				
				iBet = iBet * iRatio;
				AssignCommand ( oDealer, TakeGoldFromCreature ( iBet, oPC, TRUE, TRUE ) );	
				i = i - iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );	
				i = GetLocalInt ( oDealer, "iPlayerGoldLost" );
				SetLocalInt ( oDealer, "iPlayerGoldLost", i + iBet );							
			}
			iRound = 8;		
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_frame", FALSE );				
			SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_notice", -1, s );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", FALSE );	
		}	
	} else if ( iResult1 == 3 ) {
		if ( ( iResult2 == 1 ) && ( iResult3 == 2 ) || ( iResult2 == 2 ) && ( iResult3 == 1 ) ) {
			if ( iRound <= 3 ) {  // bank rolls low straight
				s = "1-2-3 low straight, bank loses double!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);				
				iRatio = GetLocalInt ( oDealer, "iStraightRatio" );
				if ( iRatio == 0 ) {
					iRatio = iStraightRatio;
				}
				iBet = iBet * iRatio;
				GiveGoldToCreature ( oPC, iBet, TRUE );
				i = i + iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );			
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldWon" );
				SetLocalInt ( oDealer, "iPlayerGoldWon", i + iBet );								
			} else {  // player rolls low straight
				s = "1-2-3 low straight, player loses double!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);		
				iRatio = GetLocalInt ( oDealer, "iStraightRatio" );
				if ( iRatio == 0 ) {
					iRatio = iStraightRatio;
				}				
				iBet = iBet * iRatio;
				AssignCommand ( oDealer, TakeGoldFromCreature ( iBet, oPC, TRUE, TRUE ) );	
				i = i - iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );	
				i = GetLocalInt ( oDealer, "iPlayerGoldLost" );
				SetLocalInt ( oDealer, "iPlayerGoldLost", i + iBet );							
			}
			iRound = 8;	
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_frame", FALSE );					
			SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_notice", -1, s );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", FALSE );	
		}	
	} else if ( iResult1 == 4 ) {  // check high straights
		if ( ( iResult2 == 5 ) && ( iResult3 == 6 ) || ( iResult2 == 6 ) && ( iResult3 == 5 ) ) {
			if ( iRound <= 3 ) {  // bank rolls high straight
				s = "4-5-6 high straight, bank takes double!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);		
				iRatio = GetLocalInt ( oDealer, "iStraightRatio" );
				if ( iRatio == 0 ) {
					iRatio = iStraightRatio;
				}
				iBet = iBet * iRatio;
				AssignCommand ( oDealer, TakeGoldFromCreature ( iBet, oPC, TRUE, TRUE ) );							
				i = i - iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldLost" );
				SetLocalInt ( oDealer, "iPlayerGoldLost", i + iBet );								
			} else {  // player rolls high straight
				s = "4-5-6 high straight, player wins double!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);
				iRatio = GetLocalInt ( oDealer, "iStraightRatio" );
				if ( iRatio == 0 ) {
					iRatio = iStraightRatio;
				}
				iBet = iBet * iRatio;
				GiveGoldToCreature ( oPC, iBet, TRUE );
				i = i + iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldWon" );
				SetLocalInt ( oDealer, "iPlayerGoldWon", i + iBet );									
			}
			iRound = 8;	
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_frame", FALSE );					
			SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_notice", -1, s );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", FALSE );	
		}	
	} else if ( iResult1 == 5 ) {
		if ( ( iResult2 == 4 ) && ( iResult3 == 6 ) || ( iResult2 == 6 ) && ( iResult3 == 4 ) ) {
			if ( iRound <= 3 ) {  // bank rolls high straight
				s = "4-5-6 high straight, bank takes double!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);		
				iRatio = GetLocalInt ( oDealer, "iStraightRatio" );
				if ( iRatio == 0 ) {
					iRatio = iStraightRatio;
				}
				iBet = iBet * iRatio;
				AssignCommand ( oDealer, TakeGoldFromCreature ( iBet, oPC, TRUE, TRUE ) );							
				i = i - iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldLost" );
				SetLocalInt ( oDealer, "iPlayerGoldLost", i + iBet );								
			} else {  // player rolls high straight
				s = "4-5-6 high straight, player wins double!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);
				iRatio = GetLocalInt ( oDealer, "iStraightRatio" );
				if ( iRatio == 0 ) {
					iRatio = iStraightRatio;
				}
				iBet = iBet * iRatio;
				GiveGoldToCreature ( oPC, iBet, TRUE );
				i = i + iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldWon" );
				SetLocalInt ( oDealer, "iPlayerGoldWon", i + iBet );									
			}
			iRound = 8;	
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_frame", FALSE );					
			SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_notice", -1, s );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", FALSE );	
		}	
	} else  {  // expected value is 6
		if ( ( iResult2 == 4 ) && ( iResult3 == 5 ) || ( iResult2 == 5 ) && ( iResult3 == 4 ) ) {
			if ( iRound <= 3 ) {  // bank rolls high straight
				s = "4-5-6 high straight, bank takes double!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);		
				iRatio = GetLocalInt ( oDealer, "iStraightRatio" );
				if ( iRatio == 0 ) {
					iRatio = iStraightRatio;
				}
				iBet = iBet * iRatio;
				AssignCommand ( oDealer, TakeGoldFromCreature ( iBet, oPC, TRUE, TRUE ) );							
				i = i - iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldLost" );
				SetLocalInt ( oDealer, "iPlayerGoldLost", i + iBet );								
			} else {  // player rolls high straight
				s = "4-5-6 high straight, player wins double!";
				iBet = GetLocalInt ( oDealer, "iCurrentBet" );
				i = GetGold(oPC);
				iRatio = GetLocalInt ( oDealer, "iStraightRatio" );
				if ( iRatio == 0 ) {
					iRatio = iStraightRatio;
				}
				iBet = iBet * iRatio;
				GiveGoldToCreature ( oPC, iBet, TRUE );
				i = i + iBet;
				SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );
				AssignCommand ( oPC, PlaySound ( "it_coins" ) );
				i = GetLocalInt ( oDealer, "iPlayerGoldWon" );
				SetLocalInt ( oDealer, "iPlayerGoldWon", i + iBet );									
			}
			iRound = 8;	
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_frame", FALSE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_frame", FALSE );					
			SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_notice", -1, s );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", FALSE );	
		}		
	}

	iRound = iRound + 1;	
	if ( iRound < 7 ) {	// roll another round
		SetLocalInt ( oDealer, "iRound", iRound );
		if ( iRound < 4 ){  // prep another bank roll
			sTotalFrames = IntToString(iTotalFrames);	
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_" + sTotalFrames + "a", TRUE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_" + sTotalFrames + "a", TRUE );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_" + sTotalFrames + "a", TRUE );
		
			SetupRoll(oDealer);
		} else {
			// set up notice text
			if ( iRound == 4 ) {
				s = "Bank's score is " + IntToString(iScore) + ", player's first roll"; 
			} else if ( iRound == 5 ) {
				s = "Player's second roll";
			} else {
				s = "Player's third roll";			
			}
			SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_notice", -1, s );
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", FALSE );			
			
			// enable roll button
			SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_roll", FALSE );
			
			// start the idle timer
			if ( iIdleTimer != 0 ) {
				SetLocalInt ( oDealer, "iInRoll", 0 );
				SetGUIObjectHidden ( oPC, "br_chinchirorin", "timerpane", FALSE );
				RollIdleTimer ( oDealer, iIdleTimer );
			}							
		}
	} else if ( iRound == 7 ) {  // player didn't manage a score
		if ( GetLocalInt ( oDealer, "iScore" ) > 0 ) {  // dealer wins
			s = "Player scores low, bank wins!";
			i = GetGold(oPC);			
			iBet = GetLocalInt ( oDealer, "iCurrentBet" );						
			AssignCommand ( oDealer, TakeGoldFromCreature ( iBet, oPC, TRUE, TRUE ) );			
			i = i - iBet;
			SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_gold", -1, IntToString(i) );	
			AssignCommand ( oPC, PlaySound ( "it_coins" ) );
			i = GetLocalInt ( oDealer, "iPlayerGoldLost" );
			SetLocalInt ( oDealer, "iPlayerGoldLost", i + iBet );					
		} else {
			s = "Player ties bank, wash!";			
		}
		SetGUIObjectText ( oPC, "br_chinchirorin", "chinchirorin_notice", -1, s );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", FALSE );	
		
		// enable buttons
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_start", FALSE );
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_rules", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_quit", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_plus", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_minus", FALSE );
		
		// unlock round
		SetLocalInt ( oDealer, "iInPlay", 0 );	
		
		// start the idle timer
		if ( iIdleTimer != 0 ) {
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "timerpane", FALSE );
			EndRoundIdleTimer ( oDealer, iIdleTimer );
		}								
	} else {  // roll finished, end round
		// enable buttons
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_start", FALSE );
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_rules", FALSE );			
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_quit", FALSE );
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_plus", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_minus", FALSE );
		
		// unlock round
		SetLocalInt ( oDealer, "iInPlay", 0 );	
		
		// start the idle timer
		if ( iIdleTimer != 0 ) {
			SetGUIObjectHidden ( oPC, "br_chinchirorin", "timerpane", FALSE );
			EndRoundIdleTimer ( oDealer, iIdleTimer );
		}						
	}
}


// idle timer for player rolls

void RollIdleTimer ( object oDealer, int iIdleTimerCount ) {
	object oPC;
	string sTotalFrames;
	
	oPC = GetLocalObject ( oDealer, "oPlayer" );
	
	// kill timer if player rolled
	if ( GetLocalInt ( oDealer, "iInRoll" ) == 1 ) {
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "timerpane", TRUE );
		return;
	}	
	
	if ( iIdleTimerCount == 0 ) {  // timer's done, force a roll
		// clear old messages and rolls
		sTotalFrames = IntToString(iTotalFrames);		
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", TRUE );		
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_" + sTotalFrames + "a", TRUE );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_" + sTotalFrames + "a", TRUE );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_" + sTotalFrames + "a", TRUE );	
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_frame", TRUE );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_frame", TRUE );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_frame", TRUE );		
				
		// disable roll button
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_roll", TRUE );
				
		SetupRoll(oDealer);	
		SendMessageToPC ( oPC, "Chinchirorin: The dealer has rolled the dice for you due to inactivity." );			
	} else {
		// update timer graphic
		SetGUIObjectText ( oPC, "br_chinchirorin", "timerfield", -1, IntToString(iIdleTimerCount) );		

		// set up next iteration
		DelayCommand ( 1.0, RollIdleTimer ( oDealer, iIdleTimerCount - 1 ) );
	}
}


// idle timer between rounds

void EndRoundIdleTimer ( object oDealer, int iIdleTimerCount ) {
	object oPC;
	string sTotalFrames;
	
	oPC = GetLocalObject ( oDealer, "oPlayer" );
	
	// kill timer if player readied up or quit
	if ( GetLocalInt ( oDealer, "iInPlay" ) == 1 ) {
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "timerpane", TRUE );
		return;
	} else if ( GetLocalInt ( oDealer, "iDealerBusy" ) == 0 ) {
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "timerpane", TRUE );
		return;	
	}
	
	if ( iIdleTimerCount == 0 ) {  // timer's done, eject player
		// clear old messages and rolls
		sTotalFrames = IntToString(iTotalFrames);
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_notice", TRUE );		
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_" + sTotalFrames + "a", TRUE );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_" + sTotalFrames + "a", TRUE );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_" + sTotalFrames + "a", TRUE );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_1_frame", TRUE );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_2_frame", TRUE );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "chinchirorin_3_frame", TRUE );
		SetGUIObjectHidden ( oPC, "br_chinchirorin", "timerpane", TRUE );
				
		// disable buttons
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_start", TRUE );
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_rules", TRUE );			
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_quit", TRUE );
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_plus", TRUE );		
		SetGUIObjectDisabled ( oPC, "br_chinchirorin", "chinchirorin_minus", TRUE );
		
		// set player stats
		SetCasinoStatsArrayPlayerStat ( oPC, "Chinchirorin", "Win", GetLocalInt ( oDealer, "iPlayerGoldWon" ) );
		SetCasinoStatsArrayPlayerStat ( oPC, "Chinchirorin", "Lose", GetLocalInt ( oDealer, "iPlayerGoldLost" ) );
		SetCasinoStatsArrayPlayerStat ( oPC, "Chinchirorin", "Time", GetPlayerTimePlayed ( oDealer, 1 ) );
		
		//Release dealer
		SetLocalInt ( oDealer, "iDealerBusy", 0 );
		
		CloseGUIScreen ( oPC, "br_chinchirorin" );		
		SendMessageToPC ( oPC, "Chinchirorin: The dealer has removed you from the table for inactivity." );			
	} else {
		// update timer graphic
		SetGUIObjectText ( oPC, "br_chinchirorin", "timerfield", -1, IntToString(iIdleTimerCount) );		

		// set up next iteration
		DelayCommand ( 1.0, EndRoundIdleTimer ( oDealer, iIdleTimerCount - 1 ) );
	}
}