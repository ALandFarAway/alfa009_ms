// Black Rain Software 2009

#include "y_multiplayer_casino_lib"
#include "z_casino_stats_include"


// function prototypes

void ShuffleDeck ( object oDealer );
void QuickSortCards ( object oDealer, string sPointerArrayName, string sPlayerCardStackName, int iLeft, int iRight );
void FindBestPlayerHand ( object oDealer, string sPointerArrayName, string sPlayerCardStackName, string sPlayerSuitStackName, int iNumCards, int iPlayerPos );
int ComparePlayerHands ( object oDealer, int iRank, int iPlayer1, int iPlayer2 );
string GetHandTextDescription ( object oDealer, int iRank, int iPlayerPos );
string CardValueToWordDescription ( int iNumber, int iPlural = 0 );


// shuffle algorithm for 52 standard playing cards
// assumes poker uses only one deck
// 1-13 correspond to Spades, Ace is 1
// 14-26 Hearts, 27-39 Clubs, 40-52 Diamonds

void ShuffleDeck ( object oDealer ) {
	int i, j, k;
	string s;
	
	// populate the array with cards in order
	k = 0;
	
	s = "br_card_spad";
	for ( j = 1 ; j <= 13 ; j++ ) {
		k++;		
		SetLocalArrayString ( oDealer, "sCardStack", k, s + IntToString(j) );
	}				
		
	s = "br_card_hear";
	for ( j = 1 ; j <= 13 ; j++ ) {
		k++;		
		SetLocalArrayString ( oDealer, "sCardStack", k, s + IntToString(j) );
	}		
				
	s = "br_card_club";
	for ( j = 1 ; j <= 13 ; j++ ) {
		k++;		
		SetLocalArrayString ( oDealer, "sCardStack", k, s + IntToString(j) );
	}		
			
	s = "br_card_diam";
	for ( j = 1 ; j <= 13 ; j++ ) {
		k++;		
		SetLocalArrayString ( oDealer, "sCardStack", k, s + IntToString(j) );
	}

	// sort the array
	while ( k != 1 ) {
		i = Random(k) + 1;
		s =	GetLocalArrayString ( oDealer, "sCardStack", k );
		SetLocalArrayString ( oDealer, "sCardStack", k, GetLocalArrayString ( oDealer, "sCardStack", i ) );
		SetLocalArrayString ( oDealer, "sCardStack", i, s );
		k--;
	}
		
	// set stack pointer
	SetLocalInt ( oDealer, "iStackPointer", 1 );
																			
}


// quicksort on card hands, replace ace values with 14 to sort them to the right end

void QuickSortCards ( object oDealer, string sPointerArrayName, string sPlayerCardStackName, int iLeft, int iRight ) {
	int iLeftLocal, iPivotCardValue, iPivotPointerValue, iRightLocal, iTempCardValue, iTempPointerValue;

	// terminate if only one element in subarray
	if ( ( iRight - iLeft ) <= 0 ) {
		return;
	}
	
	iLeftLocal = iLeft;
	iRightLocal = iRight;
	
	// choose a pivot value at the start of the array
	iPivotPointerValue = GetLocalArrayInt ( oDealer, sPointerArrayName, iLeft );
	iPivotCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, iPivotPointerValue );
	if ( iPivotCardValue == 1 ) {
		iPivotCardValue = 14;
	}
	
	while ( iLeftLocal < iRightLocal ) {
		iTempPointerValue = GetLocalArrayInt ( oDealer, sPointerArrayName, iLeftLocal );
		iTempCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, iTempPointerValue );
		if ( iTempCardValue == 1 ) {
			iTempCardValue = 14;
		}
		while ( ( iTempCardValue <= iPivotCardValue ) && ( iLeftLocal <= iRight ) && ( iLeftLocal < iRightLocal ) ) {
			iLeftLocal = iLeftLocal + 1;
			iTempPointerValue = GetLocalArrayInt ( oDealer, sPointerArrayName, iLeftLocal );
			iTempCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, iTempPointerValue );			
			if ( iTempCardValue == 1 ) {
				iTempCardValue = 14;
			}		
		}		
		
		iTempPointerValue = GetLocalArrayInt ( oDealer, sPointerArrayName, iRightLocal );
		iTempCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, iTempPointerValue );		
		if ( iTempCardValue == 1 ) {
			iTempCardValue = 14;
		}		
		while ( ( iTempCardValue > iPivotCardValue ) && ( iRightLocal >= iLeft ) && ( iRightLocal >= iLeftLocal ) ) {
			iRightLocal = iRightLocal - 1;
			iTempPointerValue = GetLocalArrayInt ( oDealer, sPointerArrayName, iRightLocal );
			iTempCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, iTempPointerValue );				
			if ( iTempCardValue == 1 ) {
				iTempCardValue = 14;
			}			
		}

		if ( iLeftLocal < iRightLocal ) {
			iTempPointerValue = GetLocalArrayInt ( oDealer, sPointerArrayName, iLeftLocal );
			SetLocalArrayInt ( oDealer, sPointerArrayName, iLeftLocal, GetLocalArrayInt ( oDealer, sPointerArrayName, iRightLocal ) );
			SetLocalArrayInt ( oDealer, sPointerArrayName, iRightLocal, iTempPointerValue );
		}	
	}
	
	// swap pivot with iRightLocal
	iTempPointerValue = GetLocalArrayInt ( oDealer, sPointerArrayName, iRightLocal );
	SetLocalArrayInt ( oDealer, sPointerArrayName, iRightLocal, iPivotPointerValue );
	SetLocalArrayInt ( oDealer, sPointerArrayName, iLeft, iTempPointerValue );
	
	QuickSortCards ( oDealer, sPointerArrayName, sPlayerCardStackName, iLeft, iRightLocal - 1 );
	QuickSortCards ( oDealer, sPointerArrayName, sPlayerCardStackName, iRightLocal + 1, iRight );
}


// find a player's best hand, assumes that iNumCards is 5 or 7, so there cannot be two flushes or two full straights in one hand

void FindBestPlayerHand ( object oDealer, string sPointerArrayName, string sPlayerCardStackName, string sPlayerSuitStackName, int iNumCards, int iPlayerPos ) {
	int i, iCardPointer, iCardValueCurr, iCardValueNext, iCountClubs, iCountDiamonds, iCountHearts, iCountSpades, iHandValue, iMatchStrLen, iNumCardGroups, iNumCardsInSequence, iStraightFound;
	string s, sCardGroupMatchCounts, sCardGroupMatchPointers, sCardPointer, sCardSequenceFlush, sCardSequenceMatch, sCardSequenceStraight, sCardSequenceStraightFlush, sCardSuit, sFlushSuit, sReturnStringFinal, sVarName;
	
	iHandValue = 0;
	
	// evaluate for flush
	iCountClubs = 0;
	iCountDiamonds = 0;
	iCountHearts = 0;
	iCountSpades = 0;			
	for ( iCardPointer = 1 ; iCardPointer <= iNumCards ; iCardPointer++ ) {
		sCardSuit = GetLocalArrayString ( oDealer, sPlayerSuitStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, iCardPointer ) );		
		if ( sCardSuit == "br_card_club" ) {
			iCountClubs = iCountClubs + 1;
		} else if ( sCardSuit == "br_card_diam" ) {
			iCountDiamonds = iCountDiamonds + 1;
		} else if ( sCardSuit == "br_card_hear" ) {
			iCountHearts = iCountHearts + 1;
		} else if ( sCardSuit == "br_card_spad" ) {
			iCountSpades = iCountSpades + 1;
		}
	}
	
	if ( iCountClubs >= 5 ) {
		iHandValue = 5;
		sFlushSuit = "br_card_club";
	} else if ( iCountDiamonds >= 5 ) {
		iHandValue = 5;
		sFlushSuit = "br_card_diam";	
	} else if ( iCountHearts >= 5 ) {
		iHandValue = 5;
		sFlushSuit = "br_card_hear";	
	} else if ( iCountSpades >= 5 ) {
		iHandValue = 5;
		sFlushSuit = "br_card_spad";	
	}
	
	// get the string representing the flush cards, including extras below the top 5
	sCardSequenceFlush = "";
	for ( iCardPointer = 1 ; iCardPointer <= iNumCards ; iCardPointer++ ) {
		sCardSuit = GetLocalArrayString ( oDealer, sPlayerSuitStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, iCardPointer ) );
		if ( sCardSuit == sFlushSuit ) {
			sCardSequenceFlush = sCardSequenceFlush + IntToString(iCardPointer);
		}
	}
	
	// evaluate for straights
	iStraightFound = 0;
	iCardPointer = 0;
	iCardValueNext = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, 1 ) );
	sCardSequenceStraight;
	while ( ( iCardPointer <= ( iNumCards - 4 ) ) && ( iStraightFound == 0 ) ) {
		iCardPointer = iCardPointer + 1;		
		iNumCardsInSequence = 1;
		iCardValueCurr = iCardValueNext;
		iCardValueNext = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, iCardPointer + 1 ) );		
		sCardSequenceStraight = IntToString(iCardPointer);
		while ( ( iCardValueCurr == ( iCardValueNext - 1 ) ) || ( ( iCardValueCurr == 13 ) && ( iCardValueNext == 1 ) ) || ( iCardValueCurr == ( iCardValueNext ) ) ) {
			iCardPointer = iCardPointer + 1;
			if ( iCardValueCurr != iCardValueNext ) {
				iNumCardsInSequence = iNumCardsInSequence + 1;
				iCardValueCurr = iCardValueNext; 
			}
			sCardSequenceStraight = sCardSequenceStraight + IntToString(iCardPointer);			
			iCardValueNext = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, iCardPointer + 1 ) );			
		}
		if ( iNumCardsInSequence >= 5 ) {
			iStraightFound = 1;
		} else if ( ( iNumCardsInSequence == 4 ) && ( iCardValueCurr == 5 ) && ( GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, iNumCards ) ) == 1 ) )  {
			iStraightFound = 1;
			for ( iCardPointer = 7 ; iCardPointer >= 1 ; iCardPointer-- ) {
				if ( GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, iCardPointer ) ) == 1 ) {
					sCardSequenceStraight = IntToString(iCardPointer) + sCardSequenceStraight;
				}
			}
		}
	}
	
	if ( iStraightFound == 1 ) {
		if ( iHandValue == 5 ) {
			// a flush exists, check for the possibility of straight flush
			sCardSequenceStraightFlush = "";
			for ( iCardPointer = 1 ; iCardPointer <= GetStringLength(sCardSequenceStraight) ; iCardPointer++ ) {
				sCardPointer = GetSubString ( sCardSequenceStraight, iCardPointer - 1, 1 );
				if ( FindSubString ( sCardSequenceFlush, sCardPointer ) != -1 ) {
					sCardSequenceStraightFlush = sCardSequenceStraightFlush + sCardPointer;
				}
			}
			if ( GetStringLength(sCardSequenceStraightFlush) >= 5 ) {
				// straight flush found
				s = GetStringRight ( sCardSequenceStraightFlush, 1 );
				i = StringToInt(s);
				if ( GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, i ) ) == 1 ) {
					iHandValue = 9;  // royal flush
				} else {
					iHandValue = 8;
				}
			}
		} else {
			// no flush, straight is current highest hand
			iHandValue = 4;
		}	
	}
	
	// evaluate for pairs and greater identical runs
	iCardPointer = 1;
	iNumCardGroups = 0;
	sCardGroupMatchCounts = "";
	sCardGroupMatchPointers = "";
	iCardValueCurr = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, iCardPointer ) );
	while ( iCardPointer <= ( iNumCards - 1 ) ) {
		iCardPointer = iCardPointer + 1;				
		iCardValueNext = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, iCardPointer ) );			
		if ( iCardValueCurr == iCardValueNext ) {
			iNumCardGroups = iNumCardGroups + 1;
			sCardGroupMatchPointers = sCardGroupMatchPointers + IntToString(iCardPointer - 1);
			iCardPointer = iCardPointer + 1;
			iNumCardsInSequence = 2;
			iCardValueNext = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, iCardPointer ) );					
			while ( iCardValueCurr == iCardValueNext ) {
				iCardPointer = iCardPointer + 1;
				iNumCardsInSequence = iNumCardsInSequence + 1;
				iCardValueNext = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, iCardPointer ) );
			}
			sCardGroupMatchCounts = sCardGroupMatchCounts + IntToString(iNumCardsInSequence);
		} 
		iCardValueCurr = iCardValueNext;
	}
	
	// break down the results to determine exact number and types of matched cards
	iMatchStrLen = GetStringLength(sCardGroupMatchPointers);
	if ( iMatchStrLen == 3 ) {  // possible: full house, two pair
		i = FindSubString ( sCardGroupMatchCounts, "3" );
		if ( i == -1 ) {  // only possible result is two pair
			if ( iHandValue < 2 ) {
				iHandValue = 2;
				s = GetStringRight ( sCardGroupMatchPointers, 1 );
				i = StringToInt(s);
				i = i + 1;
				sReturnStringFinal = s + IntToString(i);
				s = GetSubString ( sCardGroupMatchPointers, 1, 1 );
				i = StringToInt(s);
				i = i + 1;
				sReturnStringFinal = sReturnStringFinal + s + IntToString(i);
				if ( FindSubString ( sReturnStringFinal, "7" ) == -1 ) {
					sReturnStringFinal = sReturnStringFinal + "7";
				} else if ( FindSubString ( sReturnStringFinal, "5" ) == -1 ) {
					sReturnStringFinal = sReturnStringFinal + "5";
				} else {
					sReturnStringFinal = sReturnStringFinal + "3";
				}
				sReturnStringFinal = "2" + sReturnStringFinal;
			}
		} else {  // only possible result is full house
			if ( iHandValue < 6 ) {
				iHandValue = 6;
				if ( i == ( iMatchStrLen - 1 ) ) {  // three card group is highest value
					s = GetSubString ( sCardGroupMatchPointers, 2, 1 );
					i = StringToInt(s);
					i = i + 1;
					sReturnStringFinal = s + IntToString(i);
					i = i + 1;	
					sReturnStringFinal = sReturnStringFinal + IntToString(i);
					s = GetSubString ( sCardGroupMatchPointers, 1, 1 );	
					i = StringToInt(s);
					i = i + 1;	
					sReturnStringFinal = sReturnStringFinal + IntToString(i);											
				} else {
					s = GetSubString ( sCardGroupMatchPointers, i, 1 );
					i = StringToInt(s);
					i = i + 1;
					sReturnStringFinal = s + IntToString(i);
					i = i + 1;	
					sReturnStringFinal = sReturnStringFinal + IntToString(i);
					s = GetSubString ( sCardGroupMatchPointers, 2, 1 );	
					i = StringToInt(s);
					i = i + 1;	
					sReturnStringFinal = sReturnStringFinal + IntToString(i);					
				}
				sReturnStringFinal = "6" + sReturnStringFinal;				
			}
		}
	} else if ( iMatchStrLen == 2 ) {  // possible: four of a kind, full house, two pair
		i = FindSubString ( sCardGroupMatchCounts, "4" );
		if ( i == -1 ) {
			i = FindSubString ( sCardGroupMatchCounts, "3" );
			if ( i == -1 ) {  // only possible hand is a two pair
				if ( iHandValue < 2 ) {
					iHandValue = 2;
					s = GetSubString ( sCardGroupMatchPointers, 1, 1 );
					if ( s == "6" ) {
						i = StringToInt(s);
						i = i + 1;
						sReturnStringFinal = "2" + s + IntToString(i);
						s = GetSubString ( sCardGroupMatchPointers, 0, 1 );
						if ( s == "4" ) {
							i = StringToInt(s);
							i = i + 1;
							sReturnStringFinal = sReturnStringFinal + s + IntToString(i) + "3";
						} else {
							i = StringToInt(s);
							i = i + 1;
							sReturnStringFinal = sReturnStringFinal + s + IntToString(i) + "5";							
						}
					} else {
						i = StringToInt(s);
						i = i + 1;
						sReturnStringFinal = "2" + s + IntToString(i);
						s = GetSubString ( sCardGroupMatchPointers, 0, 1 );
						i = StringToInt(s);
						i = i + 1;
						sReturnStringFinal = sReturnStringFinal + s + IntToString(i) + "7";					
					}
				}
			} else {  // only possible hand is a full house
				if ( iHandValue < 6 ) {
					iHandValue = 6;
					if ( i == 1 ) {  // three card group is highest
						s = GetSubString ( sCardGroupMatchPointers, 1, 1 );
						i = StringToInt(s);
						i = i + 1;
						sReturnStringFinal = "6" + s + IntToString(i) + IntToString(i + 1);
						s = GetSubString ( sCardGroupMatchPointers, 0, 1 );
						i = StringToInt(s);
						i = i + 1;
						sReturnStringFinal = sReturnStringFinal + s + IntToString(i);					
					} else {  // two card group is highest
						s = GetSubString ( sCardGroupMatchPointers, 0, 1 );
						i = StringToInt(s);
						i = i + 1;
						sReturnStringFinal = "6" + s + IntToString(i) + IntToString(i + 1);
						s = GetSubString ( sCardGroupMatchPointers, 1, 1 );
						i = StringToInt(s);
						i = i + 1;
						sReturnStringFinal = sReturnStringFinal + s + IntToString(i);						
					}
				}
			}			
		} else {  // only possible hand is a four of a kind
			if ( iHandValue < 7 ) {	
				iHandValue = 7;				
				s = GetSubString ( sCardGroupMatchPointers, i, 1 );
				i = StringToInt(s);
				if ( i == 4 ) {
					sReturnStringFinal = "776543";
				} else {
					i = i + 1;
					sReturnStringFinal = "7" + s + IntToString(i) + IntToString(i + 1) + IntToString(i + 2) + "7";
				}
			}
		}
	} else if ( iMatchStrLen == 1 ) {  // possible: one pair, three of a kind, four of a kind
		if ( sCardGroupMatchCounts == "4" ) {  // only possible hand is a four of a kind
			if ( iHandValue < 7 ) {
				iHandValue = 7;			
				i = StringToInt(sCardGroupMatchPointers);
				if ( i == 4 ) {
					sReturnStringFinal = "3";						
				} else {
					sReturnStringFinal = "7";
				}
				i = i + 1;
				sReturnStringFinal = "7" + sCardGroupMatchPointers + IntToString(i) + IntToString(i + 1) + IntToString(i + 2) + sReturnStringFinal;		
			}	
		} else if ( sCardGroupMatchCounts == "3" ) {  // only possible hand is a three of a kind
			if ( iHandValue < 3 ) {
				iHandValue = 3;			
				i = StringToInt(sCardGroupMatchPointers);
				if ( i <= 3 ) {
					sReturnStringFinal = "76";				
				} else if ( i == 4 ) {
					sReturnStringFinal = "73";			
				} else {  
					sReturnStringFinal = "43";
				}
				i = i + 1;
				sReturnStringFinal = "3" + sCardGroupMatchPointers + IntToString(i) + IntToString(i + 1) + sReturnStringFinal;		
			}
		} else {  // only possible hand is a one pair
			if ( iHandValue == 0 ) {
				iHandValue = 1;
				i = StringToInt(sCardGroupMatchPointers);
				if ( i <= 3 ) {
					sReturnStringFinal = "765";				
				} else if ( i == 4 ) {
					sReturnStringFinal = "763";				
				} else if ( i == 5 ) {
					sReturnStringFinal = "743";				
				} else {
					sReturnStringFinal = "543";
				}
				i = i + 1;
				sReturnStringFinal = "1" + sCardGroupMatchPointers + IntToString(i) + sReturnStringFinal;
			}
		}
	}

	// process return strings for flushes, straights, and straight flushes
	if ( iHandValue >= 8 ) {  // straight flush
		if ( GetStringLength(sCardSequenceStraightFlush) == 5 ) {
			sReturnStringFinal = IntToString(iHandValue) + sCardSequenceStraightFlush;
		} else {  // eliminate anything lower than the top 5 card values
			sReturnStringFinal = IntToString(iHandValue) + GetStringRight ( sCardSequenceStraightFlush, 5 );
		}
	} else if ( iHandValue == 5 ) {  // flush
		if ( GetStringLength(sCardSequenceFlush) == 5 ) {
			sReturnStringFinal = "5" + sCardSequenceFlush;
		} else {
			sReturnStringFinal = "5" + GetStringRight ( sCardSequenceFlush, 5 );
		}
	} else if ( iHandValue == 4 ) {  // straight
		if ( GetStringLength(sCardSequenceStraight) == 5 ) {
			sReturnStringFinal = "4" + sCardSequenceStraight;
		} else {
			iNumCardsInSequence = 1;
			sReturnStringFinal = GetStringRight ( sCardSequenceStraight, 1 );
			sCardSequenceStraight = GetSubString ( sCardSequenceStraight, 0, GetStringLength(sCardSequenceStraight) - 1 );
			i = StringToInt(sReturnStringFinal);
			iCardValueCurr = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, i ) );
			while ( iNumCardsInSequence < 5 ) {
				s = GetStringRight ( sCardSequenceStraight, 1 );
				sCardSequenceStraight = GetSubString ( sCardSequenceStraight, 0, GetStringLength(sCardSequenceStraight) - 1 );
				i = StringToInt(s);
				iCardValueNext = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPointerArrayName, i ) );			
			
				if ( iCardValueCurr != iCardValueNext ) {
					iCardValueCurr = iCardValueNext;
					sReturnStringFinal = s + sReturnStringFinal;
					iNumCardsInSequence = iNumCardsInSequence + 1;
				}
			}
			sReturnStringFinal = "4" + sReturnStringFinal;
		}
	} else if ( iHandValue == 0 ) {  // garbage hand
		sReturnStringFinal = "034567";
	}
	
	// record player position in hand value arrays
	s = GetStringLeft ( sReturnStringFinal, 1 );
	sVarName = "iRank" + s + "HandPointer";
	i = GetLocalInt ( oDealer, sVarName );
	i = i + 1;
	SetLocalInt ( oDealer, sVarName, i );
	SetLocalArrayInt ( oDealer, "iRank" + s + "HandArray", i, iPlayerPos );
	
	// record player's specific winning hand
	sVarName = "iPlayer" + IntToString(iPlayerPos) + "BestHandSequence";
	for ( iCardPointer = 1 ; iCardPointer <= 5 ; iCardPointer++ ) {
		s = GetSubString ( sReturnStringFinal, iCardPointer, 1 );
		SetLocalArrayInt ( oDealer, sVarName, iCardPointer, StringToInt(s) );
	}
}


// compare two player hands, return 1 if first player is higher, -1 if second, and 0 if tied

int ComparePlayerHands ( object oDealer, int iRank, int iPlayer1, int iPlayer2 ) {
	int i, iCardPointer, iPlayer1CardValue, iPlayer2CardValue, iOutput;
	string sPlayer1, sPlayer1CardStackName, sPlayer1PointerArrayName, sPlayer2, sPlayer2CardStackName, sPlayer2PointerArrayName;
	
	iOutput = 0;
	
	switch (iRank) {
	case 0:
		sPlayer1 = IntToString(iPlayer1);
		sPlayer2 = IntToString(iPlayer2);
		sPlayer1PointerArrayName = "iPlayer" + sPlayer1 + "HandPointerArray";	
		sPlayer1CardStackName = "iPlayer" + sPlayer1 + "HandCardStack";	
		sPlayer2PointerArrayName = "iPlayer" + sPlayer2 + "HandPointerArray";	
		sPlayer2CardStackName = "iPlayer" + sPlayer2 + "HandCardStack";				
		i = 0;
		while ( ( iOutput == 0 ) && ( iCardPointer <= 5 ) ) {
			i = i + 1;
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", i );
			iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );			
			if ( iPlayer1CardValue == 1 ) {
				iPlayer1CardValue = 14;
			}			
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", i );
			iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );			
			if ( iPlayer2CardValue == 1 ) {
				iPlayer2CardValue = 14;
			}			
			
			if ( iPlayer1CardValue > iPlayer2CardValue ) {
				iOutput = 1;
			} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
				iOutput = -1;
			}
		}
		break;
	case 1:
		sPlayer1 = IntToString(iPlayer1);
		sPlayer2 = IntToString(iPlayer2);
		sPlayer1PointerArrayName = "iPlayer" + sPlayer1 + "HandPointerArray";	
		sPlayer1CardStackName = "iPlayer" + sPlayer1 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 1 );
		iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
		if ( iPlayer1CardValue == 1 ) {
			iPlayer1CardValue = 14;
		}
		sPlayer2PointerArrayName = "iPlayer" + sPlayer2 + "HandPointerArray";	
		sPlayer2CardStackName = "iPlayer" + sPlayer2 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 1 );
		iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
		if ( iPlayer2CardValue == 1 ) {
			iPlayer2CardValue = 14;
		}
		if ( iPlayer1CardValue > iPlayer2CardValue ) {
			iOutput = 1;
		} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
			iOutput = -1;
		} else {	
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 3 );
			iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
			if ( iPlayer1CardValue == 1 ) {
				iPlayer1CardValue = 14;
			}	
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 3 );
			iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
			if ( iPlayer2CardValue == 1 ) {
				iPlayer2CardValue = 14;
			}
			if ( iPlayer1CardValue > iPlayer2CardValue ) {
				iOutput = 1;
			} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
				iOutput = -1;
			} else {
				iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 4 );
				iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
				if ( iPlayer1CardValue == 1 ) {
					iPlayer1CardValue = 14;
				}	
				iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 4 );
				iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
				if ( iPlayer2CardValue == 1 ) {
					iPlayer2CardValue = 14;
				}
				if ( iPlayer1CardValue > iPlayer2CardValue ) {
					iOutput = 1;
				} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
					iOutput = -1;
				} else {
					iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 5 );
					iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
					if ( iPlayer1CardValue == 1 ) {
						iPlayer1CardValue = 14;
					}	
					iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 5 );
					iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
					if ( iPlayer2CardValue == 1 ) {
						iPlayer2CardValue = 14;
					}
					if ( iPlayer1CardValue > iPlayer2CardValue ) {
						iOutput = 1;
					} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
						iOutput = -1;
					}				
				}			
			}			
		}			
		break;
	case 2:
		sPlayer1 = IntToString(iPlayer1);
		sPlayer2 = IntToString(iPlayer2);
		sPlayer1PointerArrayName = "iPlayer" + sPlayer1 + "HandPointerArray";	
		sPlayer1CardStackName = "iPlayer" + sPlayer1 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 1 );
		iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
		if ( iPlayer1CardValue == 1 ) {
			iPlayer1CardValue = 14;
		}
		sPlayer2PointerArrayName = "iPlayer" + sPlayer2 + "HandPointerArray";	
		sPlayer2CardStackName = "iPlayer" + sPlayer2 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 1 );
		iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
		if ( iPlayer2CardValue == 1 ) {
			iPlayer2CardValue = 14;
		}
		if ( iPlayer1CardValue > iPlayer2CardValue ) {
			iOutput = 1;
		} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
			iOutput = -1;
		} else {	
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 3 );
			iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
			if ( iPlayer1CardValue == 1 ) {
				iPlayer1CardValue = 14;
			}	
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 3 );
			iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
			if ( iPlayer2CardValue == 1 ) {
				iPlayer2CardValue = 14;
			}
			if ( iPlayer1CardValue > iPlayer2CardValue ) {
				iOutput = 1;
			} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
				iOutput = -1;
			} else {
				iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 5 );
				iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
				if ( iPlayer1CardValue == 1 ) {
					iPlayer1CardValue = 14;
				}	
				iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 5 );
				iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
				if ( iPlayer2CardValue == 1 ) {
					iPlayer2CardValue = 14;
				}
				if ( iPlayer1CardValue > iPlayer2CardValue ) {
					iOutput = 1;
				} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
					iOutput = -1;
				}				
			}			
		}			
		break;
	case 3:
		sPlayer1 = IntToString(iPlayer1);
		sPlayer2 = IntToString(iPlayer2);
		sPlayer1PointerArrayName = "iPlayer" + sPlayer1 + "HandPointerArray";	
		sPlayer1CardStackName = "iPlayer" + sPlayer1 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 1 );
		iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
		if ( iPlayer1CardValue == 1 ) {
			iPlayer1CardValue = 14;
		}
		sPlayer2PointerArrayName = "iPlayer" + sPlayer2 + "HandPointerArray";	
		sPlayer2CardStackName = "iPlayer" + sPlayer2 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 1 );
		iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
		if ( iPlayer2CardValue == 1 ) {
			iPlayer2CardValue = 14;
		}
		if ( iPlayer1CardValue > iPlayer2CardValue ) {
			iOutput = 1;
		} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
			iOutput = -1;
		} else {	
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 4 );
			iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
			if ( iPlayer1CardValue == 1 ) {
				iPlayer1CardValue = 14;
			}	
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 4 );
			iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
			if ( iPlayer2CardValue == 1 ) {
				iPlayer2CardValue = 14;
			}
			if ( iPlayer1CardValue > iPlayer2CardValue ) {
				iOutput = 1;
			} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
				iOutput = -1;
			} else {
				iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 5 );
				iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
				if ( iPlayer1CardValue == 1 ) {
					iPlayer1CardValue = 14;
				}	
				iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 5 );
				iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
				if ( iPlayer2CardValue == 1 ) {
					iPlayer2CardValue = 14;
				}
				if ( iPlayer1CardValue > iPlayer2CardValue ) {
					iOutput = 1;
				} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
					iOutput = -1;
				}				
			}			
		}		
		break;
	case 4:
		sPlayer1 = IntToString(iPlayer1);
		sPlayer2 = IntToString(iPlayer2);
		sPlayer1PointerArrayName = "iPlayer" + sPlayer1 + "HandPointerArray";	
		sPlayer1CardStackName = "iPlayer" + sPlayer1 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 3 );
		iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
		if ( iPlayer1CardValue == 1 ) {
			iPlayer1CardValue = 14;
		}
		sPlayer2PointerArrayName = "iPlayer" + sPlayer2 + "HandPointerArray";	
		sPlayer2CardStackName = "iPlayer" + sPlayer2 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 3 );
		iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
		if ( iPlayer2CardValue == 1 ) {
			iPlayer2CardValue = 14;
		}
		if ( iPlayer1CardValue > iPlayer2CardValue ) {
			iOutput = 1;
		} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
			iOutput = -1;
		}	
		break;
	case 5:
		sPlayer1 = IntToString(iPlayer1);
		sPlayer2 = IntToString(iPlayer2);
		sPlayer1PointerArrayName = "iPlayer" + sPlayer1 + "HandPointerArray";	
		sPlayer1CardStackName = "iPlayer" + sPlayer1 + "HandCardStack";	
		sPlayer2PointerArrayName = "iPlayer" + sPlayer2 + "HandPointerArray";	
		sPlayer2CardStackName = "iPlayer" + sPlayer2 + "HandCardStack";				
		i = 0;
		while ( ( iOutput == 0 ) && ( iCardPointer <= 5 ) ) {
			i = i + 1;
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", i );
			iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );			
			if ( iPlayer1CardValue == 1 ) {
				iPlayer1CardValue = 14;
			}			
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", i );
			iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );			
			if ( iPlayer2CardValue == 1 ) {
				iPlayer2CardValue = 14;
			}			
			
			if ( iPlayer1CardValue > iPlayer2CardValue ) {
				iOutput = 1;
			} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
				iOutput = -1;
			}
		}
		break;
	case 6:
		sPlayer1 = IntToString(iPlayer1);
		sPlayer2 = IntToString(iPlayer2);
		sPlayer1PointerArrayName = "iPlayer" + sPlayer1 + "HandPointerArray";	
		sPlayer1CardStackName = "iPlayer" + sPlayer1 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 1 );
		iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
		if ( iPlayer1CardValue == 1 ) {
			iPlayer1CardValue = 14;
		}
		sPlayer2PointerArrayName = "iPlayer" + sPlayer2 + "HandPointerArray";	
		sPlayer2CardStackName = "iPlayer" + sPlayer2 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 1 );
		iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
		if ( iPlayer2CardValue == 1 ) {
			iPlayer2CardValue = 14;
		}
		if ( iPlayer1CardValue > iPlayer2CardValue ) {
			iOutput = 1;
		} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
			iOutput = -1;
		} else {	
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 4 );
			iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
			if ( iPlayer1CardValue == 1 ) {
				iPlayer1CardValue = 14;
			}	
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 4 );
			iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
			if ( iPlayer2CardValue == 1 ) {
				iPlayer2CardValue = 14;
			}
			if ( iPlayer1CardValue > iPlayer2CardValue ) {
				iOutput = 1;
			} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
				iOutput = -1;
			}			
		}		
		break;
	case 7:
		sPlayer1 = IntToString(iPlayer1);
		sPlayer2 = IntToString(iPlayer2);
		sPlayer1PointerArrayName = "iPlayer" + sPlayer1 + "HandPointerArray";	
		sPlayer1CardStackName = "iPlayer" + sPlayer1 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 1 );
		iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
		if ( iPlayer1CardValue == 1 ) {
			iPlayer1CardValue = 14;
		}
		sPlayer2PointerArrayName = "iPlayer" + sPlayer2 + "HandPointerArray";	
		sPlayer2CardStackName = "iPlayer" + sPlayer2 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 1 );
		iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
		if ( iPlayer2CardValue == 1 ) {
			iPlayer2CardValue = 14;
		}
		if ( iPlayer1CardValue > iPlayer2CardValue ) {
			iOutput = 1;
		} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
			iOutput = -1;
		} else {	
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 5 );
			iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
			if ( iPlayer1CardValue == 1 ) {
				iPlayer1CardValue = 14;
			}	
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 5 );
			iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
			if ( iPlayer2CardValue == 1 ) {
				iPlayer2CardValue = 14;
			}
			if ( iPlayer1CardValue > iPlayer2CardValue ) {
				iOutput = 1;
			} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
				iOutput = -1;
			}			
		}	
		break;
	case 8:
		sPlayer1 = IntToString(iPlayer1);
		sPlayer2 = IntToString(iPlayer2);
		sPlayer1PointerArrayName = "iPlayer" + sPlayer1 + "HandPointerArray";	
		sPlayer1CardStackName = "iPlayer" + sPlayer1 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer1 + "BestHandSequence", 3 );
		iPlayer1CardValue = GetLocalArrayInt ( oDealer, sPlayer1CardStackName, GetLocalArrayInt ( oDealer, sPlayer1PointerArrayName, iCardPointer ) );
		if ( iPlayer1CardValue == 1 ) {
			iPlayer1CardValue = 14;
		}
		sPlayer2PointerArrayName = "iPlayer" + sPlayer2 + "HandPointerArray";	
		sPlayer2CardStackName = "iPlayer" + sPlayer2 + "HandCardStack";			
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayer2 + "BestHandSequence", 3 );
		iPlayer2CardValue = GetLocalArrayInt ( oDealer, sPlayer2CardStackName, GetLocalArrayInt ( oDealer, sPlayer2PointerArrayName, iCardPointer ) );		
		if ( iPlayer2CardValue == 1 ) {
			iPlayer2CardValue = 14;
		}
		if ( iPlayer1CardValue > iPlayer2CardValue ) {
			iOutput = 1;
		} else if ( iPlayer1CardValue < iPlayer2CardValue ) {
			iOutput = -1;
		}
		break;
	case 9:
		// no action needed, all royal flushes are ties
		break;
	}
	
	return iOutput;
}


// return a text description of the hand

string GetHandTextDescription ( object oDealer, int iRank, int iPlayerPos ) {
	int iCardPointer, iCardValue;
	string sOutput, sPlayerCardStackName, sPlayerPointerArrayName, sPlayerPos;

	switch (iRank) {
	case 0:
		sPlayerPos = IntToString(iPlayerPos);
		sPlayerPointerArrayName = "iPlayer" + sPlayerPos + "HandPointerArray";	
		sPlayerCardStackName = "iPlayer" + sPlayerPos + "HandCardStack";		
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayerPos + "BestHandSequence", 5 );
		iCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPlayerPointerArrayName, iCardPointer ) );
		sOutput = CardValueToWordDescription(iCardValue) + " High";
		break;
	case 1:
		sPlayerPos = IntToString(iPlayerPos);
		sPlayerPointerArrayName = "iPlayer" + sPlayerPos + "HandPointerArray";	
		sPlayerCardStackName = "iPlayer" + sPlayerPos + "HandCardStack";		
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayerPos + "BestHandSequence", 1 );
		iCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPlayerPointerArrayName, iCardPointer ) );
		sOutput = CardValueToWordDescription(iCardValue) + " Pair";
		break;
	case 2:
		sPlayerPos = IntToString(iPlayerPos);
		sPlayerPointerArrayName = "iPlayer" + sPlayerPos + "HandPointerArray";	
		sPlayerCardStackName = "iPlayer" + sPlayerPos + "HandCardStack";		
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayerPos + "BestHandSequence", 1 );
		iCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPlayerPointerArrayName, iCardPointer ) );
		sOutput = CardValueToWordDescription ( iCardValue, 1 ) + " and ";
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayerPos + "BestHandSequence", 3 );
		iCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPlayerPointerArrayName, iCardPointer ) );
		sOutput = sOutput + CardValueToWordDescription ( iCardValue, 1 );		
		break;
	case 3:
		sPlayerPos = IntToString(iPlayerPos);
		sPlayerPointerArrayName = "iPlayer" + sPlayerPos + "HandPointerArray";	
		sPlayerCardStackName = "iPlayer" + sPlayerPos + "HandCardStack";		
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayerPos + "BestHandSequence", 1 );
		iCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPlayerPointerArrayName, iCardPointer ) );
		sOutput = CardValueToWordDescription(iCardValue) + " Trips";
		break;
	case 4:
		sPlayerPos = IntToString(iPlayerPos);
		sPlayerPointerArrayName = "iPlayer" + sPlayerPos + "HandPointerArray";	
		sPlayerCardStackName = "iPlayer" + sPlayerPos + "HandCardStack";		
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayerPos + "BestHandSequence", 5 );
		iCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPlayerPointerArrayName, iCardPointer ) );
		if ( iCardValue == 1 ) {
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayerPos + "BestHandSequence", 4 );
			iCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPlayerPointerArrayName, iCardPointer ) );			
			if ( iCardValue != 5 ) {
				iCardValue = 1;
			}
		}
		sOutput = CardValueToWordDescription(iCardValue) + " high Straight";
		break;
	case 5:
		sPlayerPos = IntToString(iPlayerPos);
		sPlayerPointerArrayName = "iPlayer" + sPlayerPos + "HandPointerArray";	
		sPlayerCardStackName = "iPlayer" + sPlayerPos + "HandCardStack";		
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayerPos + "BestHandSequence", 5 );
		iCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPlayerPointerArrayName, iCardPointer ) );
		sOutput = CardValueToWordDescription(iCardValue) + " high Flush";
		break;
	case 6:
		sPlayerPos = IntToString(iPlayerPos);
		sPlayerPointerArrayName = "iPlayer" + sPlayerPos + "HandPointerArray";	
		sPlayerCardStackName = "iPlayer" + sPlayerPos + "HandCardStack";		
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayerPos + "BestHandSequence", 1 );
		iCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPlayerPointerArrayName, iCardPointer ) );
		sOutput = CardValueToWordDescription ( iCardValue, 1 ) + " over ";
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayerPos + "BestHandSequence", 4 );
		iCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPlayerPointerArrayName, iCardPointer ) );
		sOutput = sOutput + CardValueToWordDescription ( iCardValue, 1 );		
		break;
	case 7:
		sPlayerPos = IntToString(iPlayerPos);
		sPlayerPointerArrayName = "iPlayer" + sPlayerPos + "HandPointerArray";	
		sPlayerCardStackName = "iPlayer" + sPlayerPos + "HandCardStack";		
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayerPos + "BestHandSequence", 1 );
		iCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPlayerPointerArrayName, iCardPointer ) );
		sOutput = "Quad " + CardValueToWordDescription ( iCardValue, 1 );
		break;
	case 8:
		sPlayerPos = IntToString(iPlayerPos);
		sPlayerPointerArrayName = "iPlayer" + sPlayerPos + "HandPointerArray";	
		sPlayerCardStackName = "iPlayer" + sPlayerPos + "HandCardStack";		
		iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayerPos + "BestHandSequence", 5 );
		iCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPlayerPointerArrayName, iCardPointer ) );
		if ( iCardValue == 1 ) {
			iCardPointer = GetLocalArrayInt ( oDealer, "iPlayer" + sPlayerPos + "BestHandSequence", 4 );
			iCardValue = GetLocalArrayInt ( oDealer, sPlayerCardStackName, GetLocalArrayInt ( oDealer, sPlayerPointerArrayName, iCardPointer ) );			
			if ( iCardValue != 5 ) {
				iCardValue = 1;
			}
		}		
		sOutput = CardValueToWordDescription(iCardValue) + " high Straight Flush";
		break;
	case 9:
		sOutput = "Royal Flush";
		break;		
	}
	
	return sOutput;
}


// render a number into a word, iPlural to 1 for plural word

string CardValueToWordDescription ( int iNumber, int iPlural = 0 ) {
	string sOutput;
	
	switch (iNumber) {
	case 1:
		if ( iPlural == 0 ) {
			sOutput = "Ace";
		} else {
			sOutput = "Aces";		
		}	
		break;
	case 2:
		if ( iPlural == 0 ) {
			sOutput = "Two";
		} else {
			sOutput = "Twos";		
		}
		break;
	case 3:
		if ( iPlural == 0 ) {
			sOutput = "Three";
		} else {
			sOutput = "Threes";		
		}
		break;
	case 4:
		if ( iPlural == 0 ) {
			sOutput = "Four";
		} else {
			sOutput = "Fours";		
		}
		break;		
	case 5:
		if ( iPlural == 0 ) {
			sOutput = "Five";
		} else {
			sOutput = "Fives";		
		}
		break;
	case 6:
		if ( iPlural == 0 ) {
			sOutput = "Six";
		} else {
			sOutput = "Sixes";		
		}
		break;
	case 7:
		if ( iPlural == 0 ) {
			sOutput = "Seven";
		} else {
			sOutput = "Sevens";		
		}
		break;
	case 8:
		if ( iPlural == 0 ) {
			sOutput = "Eight";
		} else {
			sOutput = "Eights";		
		}
		break;
	case 9:
		if ( iPlural == 0 ) {
			sOutput = "Nine";
		} else {
			sOutput = "Nines";		
		}
		break;
	case 10:
		if ( iPlural == 0 ) {
			sOutput = "Ten";
		} else {
			sOutput = "Tens";		
		}
		break;
	case 11:
		if ( iPlural == 0 ) {
			sOutput = "Jack";
		} else {
			sOutput = "Jacks";		
		}	
		break;
	case 12:
		if ( iPlural == 0 ) {
			sOutput = "Queen";
		} else {
			sOutput = "Queens";		
		}	
		break;	
	case 13:
		if ( iPlural == 0 ) {
			sOutput = "King";
		} else {
			sOutput = "Kings";		
		}	
		break;													
	}
	
	return sOutput;
}