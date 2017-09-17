// Black Rain 2009

#include "nw_o0_itemmaker"
#include "z_casino_stats_include"


// gameplay settings, can be modified in-game by writing a var of the same name on dealer
const int iMaxBet = 500;
const int iMinBet = 100;
const int iBetIncrement = 100;


// payout settings, can be modified in-game the same way
const int iThreeBarsPayoff = 5000;  // bars are equivalent to image 11 on each reel
const int iThreeCherriesPayoff = 1000;  // cherries are equivalent to 1 and 13
const int iThreePlumsPayoff = 200;  // plums are equivalent to 3 and 15
const int iThreeWatermelonsPayoff = 100;  // watermelons are equivalent to 5 and 17
const int iThreeOrangesPayoff = 50;  // oranges are equivalent to 7 and 19
const int iThreeLemonsPayoff = 25;  // lemons are equivalent to 9 and 21
const int iTwoCherriesPayoff = 10;
const int iOneCherryPayoff = 2;


// system settings
const int iReel1Skip = 35;  // reel 1 frameskip per iteration
const int iReel2Skip = 45;  // reel 2 frameskip per iteration
const int iReel3Skip = 55;  // reel 3 frameskip per iteration
const int iMinIterations = 50;  // number of minimum iterations
const int iMaxIterations = 450;  // maximum iterations before forcing a stop
const int iIdleTimer = 30;  // idle time allowed to players being booted off machine


// weighings and payouts, default settings return back 94.5% of player gold
// a full reel is given a weight of 64, divided unevenly between the 22 individual frames
// the higher a frame's weight, the more likely it comes up
const int iWeight1_1 = 3;
const int iWeight1_2 = 2;
const int iWeight1_3 = 3;
const int iWeight1_4 = 2;
const int iWeight1_5 = 3;
const int iWeight1_6 = 2;
const int iWeight1_7 = 4;
const int iWeight1_8 = 2;
const int iWeight1_9 = 4;
const int iWeight1_10 = 5;
const int iWeight1_11 = 4;
const int iWeight1_12 = 5;
const int iWeight1_13 = 2;
const int iWeight1_14 = 2;
const int iWeight1_15 = 3;
const int iWeight1_16 = 2;
const int iWeight1_17 = 3;
const int iWeight1_18 = 2;
const int iWeight1_19 = 3;
const int iWeight1_20 = 2;
const int iWeight1_21 = 4;
const int iWeight1_22 = 2;
const int iWeight2_1 = 2;
const int iWeight2_2 = 3;
const int iWeight2_3 = 2;
const int iWeight2_4 = 3;
const int iWeight2_5 = 3;
const int iWeight2_6 = 3;
const int iWeight2_7 = 3;
const int iWeight2_8 = 3;
const int iWeight2_9 = 3;
const int iWeight2_10 = 5;
const int iWeight2_11 = 3;
const int iWeight2_12 = 5;
const int iWeight2_13 = 2;
const int iWeight2_14 = 3;
const int iWeight2_15 = 2;
const int iWeight2_16 = 3;
const int iWeight2_17 = 2;
const int iWeight2_18 = 3;
const int iWeight2_19 = 2;
const int iWeight2_20 = 3;
const int iWeight2_21 = 3;
const int iWeight2_22 = 3;
const int iWeight3_1 = 1;
const int iWeight3_2 = 3;
const int iWeight3_3 = 2;
const int iWeight3_4 = 3;
const int iWeight3_5 = 2;
const int iWeight3_6 = 3;
const int iWeight3_7 = 3;
const int iWeight3_8 = 3;
const int iWeight3_9 = 3;
const int iWeight3_10 = 8;
const int iWeight3_11 = 1;
const int iWeight3_12 = 7;
const int iWeight3_13 = 1;
const int iWeight3_14 = 3;
const int iWeight3_15 = 1;
const int iWeight3_16 = 3;
const int iWeight3_17 = 2;
const int iWeight3_18 = 3;
const int iWeight3_19 = 3;
const int iWeight3_20 = 3;
const int iWeight3_21 = 3;
const int iWeight3_22 = 3;


// gui specific settings, change if gui size changes
const int iImageHeight = 3036;  // height of a full reel
const int iPictureHeight = 138;  // height of an individal frame in the reel
const int iLastFrame = 3313;  // numbering of the last frame in window


// function prototypes

int GetWeightWrapper ( int iReel, int iImage );
void GenerateSpinResults ( object oDealer );
void CalculateSpinEnd ( object oDealer, int iReelNum, int iResult );
void SpinReel ( object oDealer, object oPC, int iIterations, int iSpinState );
void EvaluateResults ( object oDealer, object oPC );
int GetTiltStop ( int iReel, int iPos );
void EndRoundIdleTimer ( object oDealer, int iIdleTimerCount );


// wrapper function to return a reel image's weighing
// so that results generation can be structured as a loop

int GetWeightWrapper ( int iReel, int iImage ) {
	int iReturn;
	
	if ( iReel == 1 ) {  // first reel
		switch (iImage) {			
		case 1:
			iReturn = iWeight1_1;
			break;
		case 2:
			iReturn = iWeight1_2;
			break;		
		case 3:
			iReturn = iWeight1_3;
			break;		
		case 4:
			iReturn = iWeight1_4;
			break;		
		case 5:
			iReturn = iWeight1_5;
			break;		
		case 6:
			iReturn = iWeight1_6;
			break;		
		case 7:
			iReturn = iWeight1_7;
			break;		
		case 8:
			iReturn = iWeight1_18;
			break;
		case 9:
			iReturn = iWeight1_9;
			break;		
		case 10:
			iReturn = iWeight1_10;
			break;		
		case 11:
			iReturn = iWeight1_11;
			break;		
		case 12:
			iReturn = iWeight1_12;
			break;		
		case 13:
			iReturn = iWeight1_13;
			break;		
		case 14:
			iReturn = iWeight1_14;
			break;		
		case 15:
			iReturn = iWeight1_15;
			break;
		case 16:
			iReturn = iWeight1_16;
			break;		
		case 17:
			iReturn = iWeight1_17;
			break;		
		case 18:
			iReturn = iWeight1_18;
			break;		
		case 19:
			iReturn = iWeight1_19;
			break;		
		case 20:
			iReturn = iWeight1_20;
			break;		
		case 21:
			iReturn = iWeight1_21;
			break;		
		case 22:
			iReturn = iWeight1_22;
			break;	
		default:
			break;										
		}
	} else if ( iReel == 2 ) {  // second reel
		switch (iImage) {			
		case 1:
			iReturn = iWeight2_1;
			break;
		case 2:
			iReturn = iWeight2_2;
			break;		
		case 3:
			iReturn = iWeight2_3;
			break;		
		case 4:
			iReturn = iWeight2_4;
			break;		
		case 5:
			iReturn = iWeight2_5;
			break;		
		case 6:
			iReturn = iWeight2_6;
			break;		
		case 7:
			iReturn = iWeight2_7;
			break;		
		case 8:
			iReturn = iWeight2_18;
			break;
		case 9:
			iReturn = iWeight2_9;
			break;		
		case 10:
			iReturn = iWeight2_10;
			break;		
		case 11:
			iReturn = iWeight2_11;
			break;		
		case 12:
			iReturn = iWeight2_12;
			break;		
		case 13:
			iReturn = iWeight2_13;
			break;		
		case 14:
			iReturn = iWeight2_14;
			break;		
		case 15:
			iReturn = iWeight2_15;
			break;
		case 16:
			iReturn = iWeight2_16;
			break;		
		case 17:
			iReturn = iWeight2_17;
			break;		
		case 18:
			iReturn = iWeight2_18;
			break;		
		case 19:
			iReturn = iWeight2_19;
			break;		
		case 20:
			iReturn = iWeight2_20;
			break;		
		case 21:
			iReturn = iWeight2_21;
			break;		
		case 22:
			iReturn = iWeight2_22;
			break;	
		default:
			break;										
		}	
	} else if ( iReel == 3 ) {
		switch (iImage) {			
		case 1:
			iReturn = iWeight3_1;
			break;
		case 2:
			iReturn = iWeight3_2;
			break;		
		case 3:
			iReturn = iWeight3_3;
			break;		
		case 4:
			iReturn = iWeight3_4;
			break;		
		case 5:
			iReturn = iWeight3_5;
			break;		
		case 6:
			iReturn = iWeight3_6;
			break;		
		case 7:
			iReturn = iWeight3_7;
			break;		
		case 8:
			iReturn = iWeight3_18;
			break;
		case 9:
			iReturn = iWeight3_9;
			break;		
		case 10:
			iReturn = iWeight3_10;
			break;		
		case 11:
			iReturn = iWeight3_11;
			break;		
		case 12:
			iReturn = iWeight3_12;
			break;		
		case 13:
			iReturn = iWeight3_13;
			break;		
		case 14:
			iReturn = iWeight3_14;
			break;		
		case 15:
			iReturn = iWeight3_15;
			break;
		case 16:
			iReturn = iWeight3_16;
			break;		
		case 17:
			iReturn = iWeight3_17;
			break;		
		case 18:
			iReturn = iWeight3_18;
			break;		
		case 19:
			iReturn = iWeight3_19;
			break;		
		case 20:
			iReturn = iWeight3_20;
			break;		
		case 21:
			iReturn = iWeight3_21;
			break;		
		case 22:
			iReturn = iWeight3_22;
			break;	
		default:
			break;										
		}	
	}
	
	return iReturn;
}


// generate spin results

void GenerateSpinResults ( object oDealer ) {
	int i, iCount, iResult, iWeight;
		
	for ( i = 1 ; i <= 3 ; i++ ) {
		iResult = Random(64) + 1;	
		iCount = 0;
		while ( iResult > 0 ) {
			iWeight = GetWeightWrapper ( i, iCount + 1 );
			iResult = iResult - iWeight;
		
			iCount++;
		}	
		SetLocalArrayInt ( oDealer, "iResults", i, iCount );
		CalculateSpinEnd ( oDealer, i, iCount );			
	}
}


// calculate spin endpoints by reel

void CalculateSpinEnd ( object oDealer, int iReelNum, int iResult ) {
	if ( iResult != 22 ) {
		// convert from picture number to frame position
		iResult = iResult * iPictureHeight + ( iPictureHeight / 2 );
		SetLocalArrayInt ( oDealer, "iStopTarget", iReelNum, iResult );
	} else {
		SetLocalArrayInt ( oDealer, "iStopTarget", iReelNum, iPictureHeight / 2 );
	}
}


// spin a reel

void SpinReel ( object oDealer, object oPC, int iIterations, int iSpinState ) {
	int iMinIterationsLocal, iReelPos, iStopTarget, iWindowSize;	
	string s;
	
	iWindowSize = iPictureHeight * 2; 
	iMinIterationsLocal = GetLocalInt ( oDealer, "iMinIterations" );
	
	// handle window 1
	if ( iSpinState == 0 ) {
		// disable old frames
		iReelPos = GetLocalInt ( oDealer, "iReel1Pos" );	
		s = "slotwindow1_" + IntToString(iReelPos);
		SetGUIObjectHidden ( oPC, "br_slots", s, TRUE );
		if ( iReelPos < iWindowSize ) {
			s = "slotwindow1_" + IntToString ( iReelPos + iImageHeight );
			SetGUIObjectHidden ( oPC, "br_slots", s, TRUE );	
		}
		
		// determine frame skip 
			iStopTarget = GetLocalArrayInt ( oDealer, "iStopTarget", 1 );				
		iReelPos = iReelPos + iReel1Skip;
		if ( iIterations >= iMaxIterations ) {
			iReelPos = iStopTarget;
			iSpinState = 1;
			SetLocalInt ( oDealer, "iSpinState", 1 );			
			AssignCommand ( oPC, PlaySound("it_eq_shieldmed03") );
		} else if ( ( iReelPos >= iStopTarget ) && ( iReelPos - iStopTarget <= iReel1Skip ) && ( iIterations >= iMinIterationsLocal ) ) {			
			iReelPos = iStopTarget;
			iSpinState = 1;
			SetLocalInt ( oDealer, "iSpinState", 1 );			
			AssignCommand ( oPC, PlaySound("it_eq_shieldmed03") );		
		}	
		// show new frames		
		if ( iReelPos < iWindowSize ) {  // two strips are necessary
			s = "slotwindow1_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );
			s = "slotwindow1_" + IntToString ( iReelPos + iImageHeight );
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );		
		} else if ( iReelPos > iImageHeight + 1 ) {  // transition from one to two strips
			s = "slotwindow1_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );
			iReelPos = iReelPos - iImageHeight;
			s = "slotwindow1_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );				
		} else {  // one strip is necessary
			s = "slotwindow1_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );	
		}
		SetLocalInt ( oDealer, "iReel1Pos", iReelPos );
	}
	
	// handle window 2
	if ( iSpinState <= 1 ) {
		// disable old frames
		iReelPos = GetLocalInt ( oDealer, "iReel2Pos" );	
		s = "slotwindow2_" + IntToString(iReelPos);
		SetGUIObjectHidden ( oPC, "br_slots", s, TRUE );
		if ( iReelPos < iWindowSize ) {
			s = "slotwindow2_" + IntToString ( iReelPos + iImageHeight );
			SetGUIObjectHidden ( oPC, "br_slots", s, TRUE );	
		}
		
		// determine frame skip 
		iReelPos = iReelPos + iReel2Skip;
		iStopTarget = GetLocalArrayInt ( oDealer, "iStopTarget", 2 );		
		if ( iIterations >= iMaxIterations ) {	
			iReelPos = iStopTarget;
			iSpinState = 2;
			SetLocalInt ( oDealer, "iSpinState", 2 );
			AssignCommand ( oPC, PlaySound("it_eq_shieldmed03") );
		} else if ( ( iReelPos >= iStopTarget ) && ( iReelPos - iStopTarget <= iReel2Skip ) && ( iIterations >= iMinIterationsLocal ) && ( iSpinState == 1 ) ) {			
			iReelPos = iStopTarget;
			iSpinState = 2;
			SetLocalInt ( oDealer, "iSpinState", 2 );			
			AssignCommand ( oPC, PlaySound("it_eq_shieldmed03") );		
		}	
		// show new frames		
		if ( iReelPos < iWindowSize ) {  // two strips are necessary
			s = "slotwindow2_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );
			s = "slotwindow2_" + IntToString ( iReelPos + iImageHeight );
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );		
		} else if ( iReelPos > iImageHeight + 1 ) {  // transition from one to two strips
			s = "slotwindow2_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );
			iReelPos = iReelPos - iImageHeight;
			s = "slotwindow2_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );				
		} else {  // one strip is necessary
			s = "slotwindow2_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );	
		}
		SetLocalInt ( oDealer, "iReel2Pos", iReelPos );
	}
	
	// handle window 3
	if ( iSpinState <= 2 ) {
		// disable old frames
		iReelPos = GetLocalInt ( oDealer, "iReel3Pos" );	
		s = "slotwindow3_" + IntToString(iReelPos);
		SetGUIObjectHidden ( oPC, "br_slots", s, TRUE );
		if ( iReelPos < iWindowSize ) {
			s = "slotwindow3_" + IntToString ( iReelPos + iImageHeight );
			SetGUIObjectHidden ( oPC, "br_slots", s, TRUE );	
		}
		
		// determine frame skip 
		iReelPos = iReelPos + iReel2Skip;
		iStopTarget = GetLocalArrayInt ( oDealer, "iStopTarget", 3 );		
		if ( iIterations >= iMaxIterations ) {	
			iReelPos = iStopTarget;
			iSpinState = 3;
			SetLocalInt ( oDealer, "iSpinState", 3 );			
			AssignCommand ( oPC, PlaySound("it_eq_shieldmed03") );
		} else if ( ( iReelPos >= iStopTarget ) && ( iReelPos - iStopTarget <= iReel3Skip ) && ( iIterations >= iMinIterationsLocal ) && ( iSpinState == 2 ) ) {			
			iReelPos = iStopTarget;
			iSpinState = 3;
			SetLocalInt ( oDealer, "iSpinState", 3 );			
			AssignCommand ( oPC, PlaySound("it_eq_shieldmed03") );		
		}	
		// show new frames		
		if ( iReelPos < iWindowSize ) {  // two strips are necessary
			s = "slotwindow3_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );
			s = "slotwindow3_" + IntToString ( iReelPos + iImageHeight );
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );		
		} else if ( iReelPos > iImageHeight + 1 ) {  // transition from one to two strips
			s = "slotwindow3_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );
			iReelPos = iReelPos - iImageHeight;
			s = "slotwindow3_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );				
		} else {  // one strip is necessary
			s = "slotwindow3_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, FALSE );	
		}
		SetLocalInt ( oDealer, "iReel3Pos", iReelPos );
	}	
	
	if ( iSpinState == 3 ) {
		EvaluateResults ( oDealer, oPC );
	} else {;
		DelayCommand ( 0.01, SpinReel ( oDealer, oPC, iIterations + 1, iSpinState ) );
	}		
}


void EvaluateResults ( object oDealer, object oPC ) {
	int iCherry, iCurrentBet, iGold, iPayoff, iReel1, iReel2, iReel3, iResult, iWinnings;

	iResult = 0;
	iReel1 = GetLocalArrayInt ( oDealer, "iResults", 1 );
	iReel2 = GetLocalArrayInt ( oDealer, "iResults", 2 );
	iReel3 = GetLocalArrayInt ( oDealer, "iResults", 3 );	
	
	// check for wins that don't include cherries
	// check starting with reel3 because has the lowest chance of paying off anything
	if ( iReel3 == 11 ) {  // bar
		if ( ( iReel1 == 11 ) && ( iReel2 == 11 ) ) {
			iResult = 1;   // jackpot
		}
	} else if ( ( iReel3 == 3 )  || ( iReel3 == 15 ) ) {  // plums
		if ( ( ( iReel1 == 3 ) || ( iReel1 == 15 ) ) && ( ( iReel2 == 3 ) || ( iReel2 == 15 ) ) ) {
			iResult = 3;  // three plums
		}
	} else if ( ( iReel3 == 5 )  || ( iReel3 == 17 ) ) {  // watermelons
		if ( ( ( iReel1 == 5 ) || ( iReel1 == 17 ) ) && ( ( iReel2 == 5 ) || ( iReel2 == 17 ) ) ) {
			iResult = 4;  // three watermelons
		}	
	} else if ( ( iReel3 == 7 )  || ( iReel3 == 19 ) ) {  // oranges
		if ( ( ( iReel1 == 7 ) || ( iReel1 == 19 ) ) && ( ( iReel2 == 7 ) || ( iReel2 == 19 ) ) ) {
			iResult = 5;  // three oranges
		}
	} else if ( ( iReel3 == 9 )  || ( iReel3 == 21 ) ) {  // lemons
		if ( ( ( iReel1 == 9 ) || ( iReel1 == 21 ) ) && ( ( iReel2 == 9 ) || ( iReel2 == 21 ) ) ) {
			iResult = 6;  // three lemons
		}
	}
	
	// check for cherry results
	if ( iResult != 1 ) {  // three bar jackpot trumps all, no need to check cherries
		iCherry = 0;
		if ( ( iReel1 == 1 ) || ( iReel1 == 13 ) ) {
			iCherry++;
		}
		if ( ( iReel2 == 1 ) || ( iReel2 == 13 ) ) {
			iCherry++;
		}
		if ( ( iReel3 == 1 ) || ( iReel3 == 13 ) ) {
			iCherry++;
		}
		
		if ( iCherry == 3 ) {
			iResult = 2;  // three cherries
		} else if ( iResult == 0 ) {  // any three pic win overrides one or two cherries
			if ( iCherry == 2 ) {
				iResult = 7;  // two cherries
			} else if ( iCherry == 1 ) {
				iResult = 8;  // one cherry
			}
		}
	}
	
	// give gold and update message
	iCurrentBet = GetLocalInt ( oDealer, "iCurrentBet" );	
	iWinnings = 0;
	if ( iResult == 1 ) {
		SetGUIObjectText ( oPC, "br_slots", "slots_notice", -1, "JACKPOT!" );
		SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", FALSE );
		// check for local override on jackpot payoff
		iPayoff = GetLocalInt ( oDealer, "iThreeBarsPayoff" );
		if ( iPayoff == 0 ) {
			iPayoff = iThreeBarsPayoff;
		}
		iGold = GetGold(oPC);
		AssignCommand ( oPC, PlaySound("it_chains_drop1") );
		iWinnings = iCurrentBet * iPayoff;			
		GiveGoldToCreature ( oPC, iWinnings, TRUE );
		SetGUIObjectText ( oPC, "br_slots", "slots_text_gold", -1, IntToString(iGold + iWinnings) );		
	} else if ( iResult == 2 ) {
		SetGUIObjectText ( oPC, "br_slots", "slots_notice", -1, "Three Anomen!" );
		SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", FALSE );
		// check for local override on three cherries payoff
		iPayoff = GetLocalInt ( oDealer, "iThreeCherriesPayoff" );
		if ( iPayoff == 0 ) {
			iPayoff = iThreeCherriesPayoff;
		}
		iGold = GetGold(oPC);
		AssignCommand ( oPC, PlaySound("it_chains_drop1") );
		iWinnings = iCurrentBet * iPayoff;			
		GiveGoldToCreature ( oPC, iWinnings, TRUE );
		SetGUIObjectText ( oPC, "br_slots", "slots_text_gold", -1, IntToString(iGold + iWinnings) );
	} else if ( iResult == 3 ) {
		SetGUIObjectText ( oPC, "br_slots", "slots_notice", -1, "Three Viconia!" );
		SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", FALSE );
		// check for local override on three plums payoff
		iPayoff = GetLocalInt ( oDealer, "iThreePlumsPayoff" );
		if ( iPayoff == 0 ) {
			iPayoff = iThreePlumsPayoff;
		}
		iGold = GetGold(oPC);
		AssignCommand ( oPC, PlaySound("it_chains_drop1") );
		iWinnings = iCurrentBet * iPayoff;			
		GiveGoldToCreature ( oPC, iWinnings, TRUE );
		SetGUIObjectText ( oPC, "br_slots", "slots_text_gold", -1, IntToString(iGold + iWinnings) );	
	} else if ( iResult == 4 ) {
		SetGUIObjectText ( oPC, "br_slots", "slots_notice", -1, "Three Jaheira!" );
		SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", FALSE );
		// check for local override on three watermelons payoff
		iPayoff = GetLocalInt ( oDealer, "iThreeWatermelonsPayoff" );
		if ( iPayoff == 0 ) {
			iPayoff = iThreeWatermelonsPayoff;
		}
		iGold = GetGold(oPC);
		AssignCommand ( oPC, PlaySound("it_chains_drop1") );
		iWinnings = iCurrentBet * iPayoff;			
		GiveGoldToCreature ( oPC, iWinnings, TRUE );
		SetGUIObjectText ( oPC, "br_slots", "slots_text_gold", -1, IntToString(iGold + iWinnings) );
	} else if ( iResult == 5 ) {
		SetGUIObjectText ( oPC, "br_slots", "slots_notice", -1, "Three Aerie!" );
		SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", FALSE );
		// check for local override on three oranges payoff
		iPayoff = GetLocalInt ( oDealer, "iThreeOrangesPayoff" );
		if ( iPayoff == 0 ) {
			iPayoff = iThreeOrangesPayoff;
		}
		iGold = GetGold(oPC);
		AssignCommand ( oPC, PlaySound("it_chains_drop1") );
		iWinnings = iCurrentBet * iPayoff;			
		GiveGoldToCreature ( oPC, iWinnings, TRUE );
		SetGUIObjectText ( oPC, "br_slots", "slots_text_gold", -1, IntToString(iGold + iWinnings) );
	} else if ( iResult == 6 ) {
		SetGUIObjectText ( oPC, "br_slots", "slots_notice", -1, "Three Minsc!" );
		SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", FALSE );
		// check for local override on three lemons payoff
		iPayoff = GetLocalInt ( oDealer, "iThreeLemonsPayoff" );
		if ( iPayoff == 0 ) {
			iPayoff = iThreeLemonsPayoff;
		}
		iGold = GetGold(oPC);
		AssignCommand ( oPC, PlaySound("it_chains_drop1") );
		iWinnings = iCurrentBet * iPayoff;			
		GiveGoldToCreature ( oPC, iWinnings, TRUE );
		SetGUIObjectText ( oPC, "br_slots", "slots_text_gold", -1, IntToString(iGold + iWinnings) );
	} else if ( iResult == 7 ) {
		SetGUIObjectText ( oPC, "br_slots", "slots_notice", -1, "Two Anomen!" );
		SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", FALSE );
		// check for local override on two cherries payoff
		iPayoff = GetLocalInt ( oDealer, "iTwoCherriesPayoff" );
		if ( iPayoff == 0 ) {
			iPayoff = iTwoCherriesPayoff;
		}
		iGold = GetGold(oPC);
		AssignCommand ( oPC, PlaySound("it_chains_drop1") );
		iWinnings = iCurrentBet * iPayoff;			
		GiveGoldToCreature ( oPC, iWinnings, TRUE );
		SetGUIObjectText ( oPC, "br_slots", "slots_text_gold", -1, IntToString(iGold + iWinnings) );
	} else if ( iResult == 8 ) {
		SetGUIObjectText ( oPC, "br_slots", "slots_notice", -1, "One Anomen!" );
		SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", FALSE );
		// check for local override on one cherry payoff
		iPayoff = GetLocalInt ( oDealer, "iOneCherryPayoff" );
		if ( iPayoff == 0 ) {
			iPayoff = iOneCherryPayoff;
		}	
		iGold = GetGold(oPC);
		AssignCommand ( oPC, PlaySound("it_chains_drop1") );
		iWinnings = iCurrentBet * iPayoff;			
		GiveGoldToCreature ( oPC, iWinnings, TRUE );
		SetGUIObjectText ( oPC, "br_slots", "slots_text_gold", -1, IntToString(iGold + iWinnings) );
	}
	
	// update stats
	if ( iWinnings == 0 ) {
		iGold = GetLocalInt ( oDealer, "iPlayerGoldLost" );
		SetLocalInt ( oDealer, "iPlayerGoldLost", iGold + iCurrentBet );
	} else {
		iGold = GetLocalInt ( oDealer, "iPlayerGoldWon" );
		iWinnings = iWinnings - iCurrentBet;
		SetLocalInt ( oDealer, "iPlayerGoldWon", iGold + iWinnings );			
	}
	
	SetLocalInt ( oDealer, "iSpinState", 0 );
		
	// enable all buttons
	SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_spin", FALSE );		
	SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_tilt", TRUE );	
	SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_payouts", FALSE );
	SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_quit", FALSE );
	SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betplus", FALSE );
	SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betminus", FALSE );
	
	// start the idle timer
	SetLocalInt ( oDealer, "iInPlay", 0 );
	if ( iIdleTimer != 0 ) {
		SetGUIObjectHidden ( oPC, "br_slots", "timerpane", FALSE );
		EndRoundIdleTimer ( oDealer, iIdleTimer );
	}	
}


// support function for tilt

int GetTiltStop ( int iReel, int iPos ) {
	int iResult, iFrame;
	
	iFrame = iPictureHeight / 2;
	if ( iPos < iFrame ) {
		iResult = 22;
	} else {
		iResult = 0;
		while (  iPos >= iFrame ) {
			iFrame = iFrame + iPictureHeight;
			iResult = iResult + 1;
		}
	}
	
	iResult = iResult + ( iReel - 1 );
	if ( iResult > 22 ) {
		iResult = iResult - 22;
	}
	return iResult;
}


void TiltSlotMachine ( object oDealer ) {
	int i, iCount, iPos, iSpinState;
		
	iSpinState = GetLocalInt ( oDealer, "iSpinState" );
	
	// disable the minimum iterations count
	SetLocalInt ( oDealer, "iMinIterations", 0 );
		
	if ( iSpinState == 0 ) {
		// find the next image for reel 1
		iPos = GetLocalInt ( oDealer, "iReel1Pos" );		
		iCount = GetTiltStop ( 1, iPos );
		SetLocalArrayInt ( oDealer, "iResults", 1, iCount );
		CalculateSpinEnd ( oDealer, 1, iCount );		
	}
	
	if ( iSpinState <= 1 ) {
		// find image for reel 2
		iPos = GetLocalInt ( oDealer, "iReel2Pos" );		
		iCount = GetTiltStop ( 2, iPos );
		SetLocalArrayInt ( oDealer, "iResults", 2, iCount );
		CalculateSpinEnd ( oDealer, 2, iCount );		
	}

	if ( iSpinState <= 2 ) {		
		// find image for reel 3
		iPos = GetLocalInt ( oDealer, "iReel3Pos" );		
		iCount = GetTiltStop ( 3, iPos );
		SetLocalArrayInt ( oDealer, "iResults", 3, iCount );
		CalculateSpinEnd ( oDealer, 3, iCount );		
	}
}


// idle timer between rounds

void EndRoundIdleTimer ( object oDealer, int iIdleTimerCount ) {
	int i, iReelPos;
	object oPC;
	string s, sInt, sTotalFrames;
	
	oPC = GetLocalObject ( oDealer, "oPlayer" );
	
	// kill timer if player readied up or quit
	if ( GetLocalInt ( oDealer, "iInPlay" ) == 1 ) {
		SetGUIObjectHidden ( oPC, "br_slots", "timerpane", TRUE );
		return;
	} else if ( GetLocalInt ( oDealer, "iOccupied" ) == 0 ) {
		SetGUIObjectHidden ( oPC, "br_slots", "timerpane", TRUE );
		return;	
	}
	
	if ( iIdleTimerCount == 0 ) {  // timer's done, eject player
		for ( i = 1 ; i <= 3 ; i++ ) {
			sInt = IntToString(i);
			
			// disable old frames
			iReelPos = GetLocalInt ( oDealer, "iReel" + sInt + "Pos" );	
			s = "slotwindow" + sInt + "_" + IntToString(iReelPos);
			SetGUIObjectHidden ( oPC, "br_slots", s, TRUE );
			if ( iReelPos < ( iLastFrame - iImageHeight ) ) {
				s = "slotwindow" + sInt + "_" + IntToString ( iReelPos + iImageHeight );
				SetGUIObjectHidden ( oPC, "br_slots", s, TRUE );	
			}
		}	
		// hide any old notice messages
		SetGUIObjectHidden ( oPC, "br_slots", "slots_notice", TRUE );	
			
		// disable all buttons
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_spin", TRUE );		
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_payouts", TRUE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_quit", TRUE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betplus", TRUE );
		SetGUIObjectDisabled ( oPC, "br_slots", "slots_button_betminus", TRUE );		
		
		SetLocalInt ( oDealer, "iOccupied", 0 );
		
		// set stats
		SetCasinoStatsArrayPlayerStat ( oPC, "Slots", "Win", GetLocalInt ( oDealer, "iPlayerGoldWon" ) );
		SetCasinoStatsArrayPlayerStat ( oPC, "Slots", "Lose", GetLocalInt ( oDealer, "iPlayerGoldLost" ) );		
		SetCasinoStatsArrayPlayerStat ( oPC, "Slots", "Time", GetPlayerTimePlayed (oDealer) );
		
		CloseGUIScreen ( oPC, "br_slots" );
		SendMessageToPC ( oPC, "Slots: You have been idled off this machine." );	
	} else {
		// update timer graphic
		SetGUIObjectText ( oPC, "br_slots", "timerfield", -1, IntToString(iIdleTimerCount) );		

		// set up next iteration
		DelayCommand ( 1.0, EndRoundIdleTimer ( oDealer, iIdleTimerCount - 1 ) );
	}
}