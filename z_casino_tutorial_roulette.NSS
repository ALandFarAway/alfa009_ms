// Black Rain 2009


// game declarations, make sure these match the same declarations in the game include
const int iStraightPayout = 35;  // single number bet
const int iSplitPayout = 17;  // two adjacent numbers, also 0-00
const int iStreetPayout = 11;  // three number column, also 0-1-2 and 00-2-3
const int iCornerPayout = 8;  // four number bet
const int iFivePayout = 6;  // 0-00-1-2-3
const int iSixLinePayout = 5;  // six numbers, two adjacent three number columns
const int iThirdPayout = 2;  // first, second, or third column or dozen
const int iHalfPayout = 1;  // odd and even, red and black, 1-18 and 19-36


// function prototypes
void Roulette_CleanUpState ( object oPC );
void Roulette_CloseTutorial ( object oPC );


// main function

void Roulette_ChangeState ( object oPC, int iState ) {
	int i;
	string sChipTag, sDisplayString, sVarName;
	
	if ( iState == 1 ) {
		sDisplayString = "Roulette is a betting game in which players can place one more more bets on the table covering a variety of possible outcomes, with the result being determined by the spin of a wheel.  To place a bet, left click on any of the betting positions.  Placed bets can be modified by left clicking them, or removed by right clicking them.";
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", TRUE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
		SetGUIObjectHidden ( oPC, "br_roulette", "notice_pane", TRUE );
		SetGUIObjectText ( oPC, "br_roulette", "player1name2", -1, GetName(oPC) );
		SetGUIObjectText ( oPC, "br_roulette", "roulette_gold", -1, "0" );
		SetGUIObjectText ( oPC, "br_roulette", "roulette_bet", -1, "0" );
	} else if ( iState == 2 ) {
		sDisplayString = "The wheel is divided into 38 spaces, numbered 1 to 36 plus 0 and 00.  There are eighteen black and eighteen red squares, plus 0 and 00 which are neither color.";
		SetGUIObjectHidden ( oPC, "br_roulette", "roulette_wheel_center", FALSE );
		SetGUIObjectHidden ( oPC, "br_roulette", "roulette_wheel_frame", FALSE );	
		SetGUIObjectHidden ( oPC, "br_roulette", "roulette_wheel_1", FALSE );
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
	} else if ( iState == 3 ) {
		sDisplayString = "These are the 38 individual number bets, known as straight bets.  These bets win if the number matches the spin result, and pay at a rate of " + IntToString(iStraightPayout) + " to 1.  To place a straight bet put a chip in the center of any number box.";	
		sChipTag = "roulette_chip_";
		for ( i = 1 ; i <= 38 ; i++ ) {
			sVarName = sChipTag + IntToString(i);
			SetGUITexture ( oPC, "br_roulette", sVarName, "br_chip_1.tga" );
			SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
		}
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
	} else if ( iState == 4 ) {
		sDisplayString = "These are two-number bets, known as split bets.  These bets win if either number matches the spin result, and pay at a rate of " + IntToString(iSplitPayout) + " to 1.  To place a split bet place a chip on the line dividing any two number boxes.";
		sChipTag = "roulette_chip_";
		for ( i = 1 ; i <= 36 ; i++ ) {
			if ( ( i % 3 ) != 0 ) {
				sVarName = sChipTag + IntToString(i) + "_" + IntToString ( i + 1 );
				SetGUITexture ( oPC, "br_roulette", sVarName, "br_chip_1.tga" );			
				SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
			}
		}	
				
		for ( i = 1 ; i <= 33 ; i++ ) {
				sVarName = sChipTag + IntToString(i) + "_" + IntToString ( i + 3 );
				SetGUITexture ( oPC, "br_roulette", sVarName, "br_chip_1.tga" );			
				SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
		}		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );	
	} else if ( iState == 5 ) {
		sDisplayString = "These are three-number bets, known as street bets.  These bets win if any of the three numbers match the spin result, and pay at a rate of " + IntToString(iStreetPayout) + " to 1.  To place a street bet place a chip in the box above each three-number row.  You can also place a three-number bet for 0-1-2 or 00-2-3 by placing a chip on the intersection of their boundaries.";
		sChipTag = "roulette_chip_";
		for ( i = 1 ; i <= 34 ; i = i + 3 ) {
			sVarName = sChipTag + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 2 );
			SetGUITexture ( oPC, "br_roulette", sVarName, "br_chip_1.tga" );		
			SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );
		}	
			SetGUITexture ( oPC, "br_roulette", sChipTag + "38_1_2", "br_chip_1.tga" );		
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "38_1_2", FALSE );
			SetGUITexture ( oPC, "br_roulette", sChipTag + "37_2_3", "br_chip_1.tga" );			
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "37_2_3", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 6 ) {
		sDisplayString = "These are four-number bets, known as corner bets.  These bets win if any of the four numbers match the spin result, and pay at a rate of " + IntToString(iCornerPayout) + " to 1.  To place a corner bet place a chip in the corner touching all four numbers.";
		sChipTag = "roulette_chip_";				
		for ( i = 1 ; i <= 34 ; i++ ) {
			if ( ( i % 3 ) != 0 ) {	
				sVarName = sChipTag + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 );
				SetGUITexture ( oPC, "br_roulette", sVarName, "br_chip_1.tga" );					
				SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );				
			}
		}	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 7 ) {
		sDisplayString = "This is a five-number bet, covering the numbers 0-00-1-2-3.  This bet pays out at a rate of " + IntToString(iFivePayout) + " to 1, and is placed at the intersection of the borders of 0, 00, and 2.";
		sChipTag = "roulette_chip_";
		SetGUITexture ( oPC, "br_roulette", sChipTag + "38_37_1_2_3", "br_chip_1.tga" );		
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "38_37_1_2_3", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 8 ) {
		sDisplayString = "These are a six-number bets, known as six-line bets.  These bets are essentially a pair of street bets and win if any of the six numbers match the spin result, and pay at a rate of " + IntToString(iSixLinePayout) + " to 1.  To place a six-line bet place a chip on the border between two adjacent street bet boxes.";
		sChipTag = "roulette_chip_";
		for ( i = 1 ; i <= 31 ; i = i + 3 ) {
			sVarName = sChipTag + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 2 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 ) + "_" + IntToString ( i + 5 );
			SetGUITexture ( oPC, "br_roulette", sVarName, "br_chip_1.tga" );		
			SetGUIObjectHidden ( oPC, "br_roulette", sVarName, FALSE );				
		}
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );			
	} else if ( iState == 9 ) {
		sDisplayString = "These are third-board bets, which cover 12 numbers at a time.  These bets pay at a rate of " + IntToString(iThirdPayout) + " to 1, and can be placed for first, second, or third columns or dozen numbers.  The position of the betting box reflects the numbers they represent.  Note none of these bets cover 0 and 00.";
		sChipTag = "roulette_chip_";							
		SetGUITexture ( oPC, "br_roulette", sChipTag + "1_12", "br_chip_1.tga" );					
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "1_12", FALSE );
		SetGUITexture ( oPC, "br_roulette", sChipTag + "13_24", "br_chip_1.tga" );			
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "13_24", FALSE );
		SetGUITexture ( oPC, "br_roulette", sChipTag + "25_36", "br_chip_1.tga" );			
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "25_36", FALSE );
		SetGUITexture ( oPC, "br_roulette", sChipTag + "Column1", "br_chip_1.tga" );			
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "Column1", FALSE );
		SetGUITexture ( oPC, "br_roulette", sChipTag + "Column2", "br_chip_1.tga" );			
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "Column2", FALSE );
		SetGUITexture ( oPC, "br_roulette", sChipTag + "Column3", "br_chip_1.tga" );			
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "Column3", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 10 ) {
		sDisplayString = "These are half-board bets, which cover 18 numbers at a time.  These bets pay at a rate of " + IntToString(iHalfPayout) + " to 1, and can be placed for the lower or upper half of the numbers, red or black, and odd or even.  Note none of these bets cover 0 and 00.";
		sChipTag = "roulette_chip_";	
		SetGUITexture ( oPC, "br_roulette", sChipTag + "1_18", "br_chip_1.tga" );					
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "1_18", FALSE );
		SetGUITexture ( oPC, "br_roulette", sChipTag + "19_36", "br_chip_1.tga" );			
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "19_36", FALSE );
		SetGUITexture ( oPC, "br_roulette", sChipTag + "evens", "br_chip_1.tga" );		
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "evens", FALSE );
		SetGUITexture ( oPC, "br_roulette", sChipTag + "odds", "br_chip_1.tga" );		
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "odds", FALSE );
		SetGUITexture ( oPC, "br_roulette", sChipTag + "black", "br_chip_1.tga" );		
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "black", FALSE );
		SetGUITexture ( oPC, "br_roulette", sChipTag + "red", "br_chip_1.tga" );		
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "red", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", FALSE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	} else if ( iState == 11 ) {
		sDisplayString = "That's the basics of playing roulette.  We encourage you to develop your own betting strategy in order to maximize your returns.";	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "next", TRUE );	
		SetGUIObjectDisabled ( oPC, "br_tutorial", "back", FALSE );		
		SetGUIObjectDisabled ( oPC, "br_tutorial", "quit", FALSE );		
	}	
	
	SetGUIObjectText ( oPC, "br_tutorial", "tutorial_text", -1, sDisplayString );
}


// clean up board between each state update

void Roulette_CleanUpState ( object oPC ) {
	string s, sChipTag;
	int i;
	
	SetGUIObjectHidden ( oPC, "br_roulette", "roulette_wheel_center", TRUE );
	SetGUIObjectHidden ( oPC, "br_roulette", "roulette_wheel_frame", TRUE );	
	SetGUIObjectHidden ( oPC, "br_roulette", "roulette_wheel_1", TRUE );
	
	sChipTag = "roulette_chip_";
		
	for ( i = 1 ; i <= 38 ; i++ ) {
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + IntToString(i), TRUE );
	}
	
	
	for ( i = 1 ; i <= 36 ; i++ ){
		if ( ( i % 3 ) != 0 ) {
			SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + IntToString(i) + "_" + IntToString ( i + 1 ), TRUE );
		}
	}	
				
	for ( i = 1 ; i <= 33 ; i++ ) {
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + IntToString(i) + "_" + IntToString ( i + 3 ), TRUE );
	}
	
	for ( i = 1 ; i <= 34 ; i = i + 3 ) {
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 2 ), TRUE );
	}	
		
	for ( i = 1 ; i <= 34 ; i++ ) {
		if ( ( i % 3 ) != 0 ) {			
			SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 ), TRUE );				
		}
	}	
	
	for ( i = 1 ; i <= 31 ; i = i + 3 ) {
		SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + IntToString(i) + "_" + IntToString ( i + 1 ) + "_" + IntToString ( i + 2 ) + "_" + IntToString ( i + 3 ) + "_" + IntToString ( i + 4 ) + "_" + IntToString ( i + 5 ), TRUE );				
	}
	
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "1_18", TRUE );	
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "19_36", TRUE );
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "evens", TRUE );
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "odds", TRUE );
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "black", TRUE );
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "red", TRUE );	
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "1_12", TRUE );	
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "13_24", TRUE );
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "25_36", TRUE );
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "Column1", TRUE );
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "Column2", TRUE );
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "Column3", TRUE );
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "38_37_1_2_3", TRUE );
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "38_1_2", TRUE );	
	SetGUIObjectHidden ( oPC, "br_roulette", sChipTag + "37_2_3", TRUE );	
}


// close gui action

void Roulette_CloseTutorial ( object oPC ) {
	Roulette_CleanUpState(oPC);
	SetGUIObjectHidden ( oPC, "br_roulette", "notice_pane", FALSE );	
	CloseGUIScreen ( oPC, "br_roulette" );
}