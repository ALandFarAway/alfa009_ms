// Black Rain 2009

#include "z_casino_tutorial_blackjack"
#include "z_casino_tutorial_chinchirorin"
#include "z_casino_tutorial_craps"
#include "z_casino_tutorial_poker_5cdraw"
#include "z_casino_tutorial_poker_7cstud"
#include "z_casino_tutorial_poker_hands"
#include "z_casino_tutorial_poker_txshldm"
#include "z_casino_tutorial_roulette"


const string sTutorialObjTag = "";  // empty string defaults to using PC's area as tutorial data object


// function prototypes
void SetPCTutorialData ( object oPC, string sGameName );
void ClosePCTutorial ( string sHandlerTag, int iPCPos );
string GetPCTutorialGame ( object oHandler, int iPCPos );
int GetPCTutorialState ( object oHandler, int iPCPos );
void UpdatePCTutorialGUI ( object oHandler, int iPCPos, int iDirection = 0 );


// set the PC's game name and state data on tutorial object

void SetPCTutorialData ( object oPC, string sGameName ) {
	int iPCPos;
	object oHandler;
	string sHandlerTag, sPCPos, sVarName;
	
	// get the tutorial handler object
	if ( sTutorialObjTag == "" ) {
		oHandler = GetArea(oPC);	
	} else {
		oHandler = GetObjectByTag(sTutorialObjTag);
	}
	
	// find the first available slot on oHandler
	iPCPos = 1;
	sPCPos = IntToString(iPCPos);
	sVarName = "iCasinoTutorialSlot";
	while ( GetLocalInt ( oHandler, sVarName + sPCPos + "Taken" ) == 1 ) {
		iPCPos = iPCPos + 1;
		sPCPos = IntToString(iPCPos);
	}
	
	// write data
	sVarName = sVarName + sPCPos;
	SetLocalInt ( oHandler, sVarName + "Taken", 1 );
	SetLocalObject ( oHandler, sVarName + "Player",	oPC );
	SetLocalString ( oHandler, sVarName + "GameName", sGameName );
	SetLocalInt ( oHandler, sVarName + "State", 1 );
	
	// write handler tag and player position to player gui
	sHandlerTag = GetTag(oHandler);
	SetGUIObjectText ( oPC, "br_tutorial", "handlertag", -1, sHandlerTag );
	SetGUIObjectText ( oPC, "br_tutorial", "pcpos", -1, sPCPos );
	// set the player's tutorial gui at state 1
	UpdatePCTutorialGUI ( oHandler, iPCPos );	
}


// clear a PC's data off tutorial object

void ClosePCTutorial ( string sHandlerTag, int iPCPos ) {
	object oHandler, oPC;
	string sGameName, sPCPos, sVarName;
	
	// get the tutorial handler object
	oHandler = GetObjectByTag(sHandlerTag);
	
	// remove PC from handler object
	sPCPos = IntToString(iPCPos);
	sVarName = "iCasinoTutorialSlot" + sPCPos;
	oPC = GetLocalObject ( oHandler, sVarName + "Player" );
	SetLocalInt ( oHandler, sVarName + "Taken", 0 );		
	
	// get the current game and close both GUI
	sGameName = GetPCTutorialGame ( oHandler, iPCPos );
	CloseGUIScreen ( oPC, "br_tutorial" );
	// find game specific action		
	if ( sGameName == "br_blackjack" ) {
		Blackjack_CloseTutorial(oPC);
	} else if ( sGameName == "br_chinchirorin" ) {	
		Chinchirorin_CloseTutorial(oPC);	
	} else if ( sGameName == "br_craps" ) {
		Craps_CloseTutorial(oPC);	
	} else if ( sGameName == "br_poker_5cdraw" ) {
		Poker_5cdraw_CloseTutorial(oPC);	
	} else if ( sGameName == "br_poker_7cstud" ) {
		Poker_7cstud_CloseTutorial(oPC);	
	} else if ( sGameName == "br_poker_txshldm" ) {
		Poker_txshldm_CloseTutorial(oPC);		
	} else if ( sGameName == "br_roulette" ) {
		Roulette_CloseTutorial(oPC);		
	} else if ( sGameName == "br_poker_handstutorial" ) {
		Poker_HandsTutorial_CloseTutorial(oPC);	
	}
}


// get the PC's current tutorial game

string GetPCTutorialGame ( object oHandler, int iPCPos ) {
	string sPCPos, sResult, sVarName;
	
	sPCPos = IntToString(iPCPos);
	sVarName = "iCasinoTutorialSlot" + sPCPos;
	sResult = GetLocalString ( oHandler, sVarName + "GameName" );	
	
	return sResult;	
}


// get the PC's current tutorial state

int GetPCTutorialState ( object oHandler, int iPCPos ) {
	int iResult;
	string sPCPos, sVarName;
	
	sPCPos = IntToString(iPCPos);
	sVarName = "iCasinoTutorialSlot" + sPCPos;
	iResult = GetLocalInt ( oHandler, sVarName + "State" );
	
	return iResult;	
}


// update the PC's tutorial gui, iDirection 1 for next page, iDirection -1 for previous page, 0 is set up the first page

void UpdatePCTutorialGUI ( object oHandler, int iPCPos, int iDirection = 0 ) {
	int iState;
	object oPC;
	string sGameName, sPCPos, sVarName;
		
	// get PC data	
	sPCPos = IntToString(iPCPos);
	sVarName = "iCasinoTutorialSlot" + sPCPos;	
	oPC = GetLocalObject ( oHandler, sVarName + "Player" );
	sGameName = GetPCTutorialGame ( oHandler, iPCPos );	
	
	if ( iDirection == 0 ) {
		// find game specific action		
		if ( sGameName == "br_blackjack" ) {
			Blackjack_ChangeState ( oPC, 1 );
		} else if ( sGameName == "br_chinchirorin" ) {
			Chinchirorin_ChangeState ( oPC, 1 );			
		} else if ( sGameName == "br_craps" ) {
			Craps_ChangeState ( oPC, 1 );		
		} else if ( sGameName == "br_poker_5cdraw" ) {
			Poker_5cdraw_ChangeState ( oPC, 1 );		
		} else if ( sGameName == "br_poker_7cstud" ) {
			Poker_7cstud_ChangeState ( oPC, 1 );		
		} else if ( sGameName == "br_poker_txshldm" ) {
			Poker_txshldm_ChangeState ( oPC, 1 );		
		} else if ( sGameName == "br_roulette" ) {
			Roulette_ChangeState ( oPC, 1 );		
		} else if ( sGameName == "br_poker_handstutorial" ) {
			Poker_HandsTutorial_ChangeState ( oPC, 1 );		
		}
	} else {
		// find the current tutorial state
		iState = GetPCTutorialState ( oHandler, iPCPos );
		if ( iDirection == 1 ) {
			iState = iState + 1;
		} else {
			iState = iState -1;
		}
		SetLocalInt ( oHandler, sVarName + "State", iState );
				
		// find game specific action	
		if ( sGameName == "br_blackjack" ) {
			Blackjack_CleanUpState(oPC);
			Blackjack_ChangeState ( oPC, iState );			
		} else if ( sGameName == "br_chinchirorin" ) {
			Chinchirorin_CleanUpState(oPC);
			Chinchirorin_ChangeState ( oPC, iState );			
		} else if ( sGameName == "br_craps" ) {
			Craps_CleanUpState(oPC);
			Craps_ChangeState ( oPC, iState );		
		} else if ( sGameName == "br_poker_5cdraw" ) {
			Poker_5cdraw_CleanUpState(oPC);
			Poker_5cdraw_ChangeState ( oPC, iState );		
		} else if ( sGameName == "br_poker_7cstud" ) {
			Poker_7cstud_CleanUpState(oPC);
			Poker_7cstud_ChangeState ( oPC, iState );		
		} else if ( sGameName == "br_poker_txshldm" ) {
			Poker_txshldm_CleanUpState(oPC);
			Poker_txshldm_ChangeState ( oPC, iState );		
		} else if ( sGameName == "br_roulette" ) {
			Roulette_CleanUpState(oPC);
			Roulette_ChangeState ( oPC, iState );		
		} else if ( sGameName == "br_poker_handstutorial" ) {
			Poker_HandsTutorial_CleanUpState(oPC);
			Poker_HandsTutorial_ChangeState ( oPC, iState );			
		}	
	}	
}