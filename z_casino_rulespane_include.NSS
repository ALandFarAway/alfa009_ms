// Black Rain 2009

const string sRulesPaneObjTag = "";  // empty string defaults to using PC's area as data object


// function prototypes
void SetPCRulesPaneData ( object oPC );
void CloseRulesPane ( string sHandlerTag, int iPCPos );


// set the PC's game name and state data on RulesPane object

void SetPCRulesPaneData ( object oPC ) {
	int iPCPos;
	object oHandler;
	string sHandlerTag, sPCPos, sVarName;
	
	// get the RulesPane handler object
	if ( sRulesPaneObjTag == "" ) {
		oHandler = GetArea(oPC);	
	} else {
		oHandler = GetObjectByTag(sRulesPaneObjTag);
	}
	
	// find the first available slot on oHandler
	iPCPos = 1;
	sPCPos = IntToString(iPCPos);
	sVarName = "iCasinoRulesPaneSlot";
	while ( GetLocalInt ( oHandler, sVarName + sPCPos + "Taken" ) == 1 ) {
		iPCPos = iPCPos + 1;
		sPCPos = IntToString(iPCPos);
	}
	
	// write data
	sVarName = sVarName + sPCPos;
	SetLocalInt ( oHandler, sVarName + "Taken", 1 );
	SetLocalObject ( oHandler, sVarName + "Player",	oPC );
	
	// write handler tag and player position to player gui
	sHandlerTag = GetTag(oHandler);
	SetGUIObjectText ( oPC, "br_casino_rulespane", "handlertag", -1, sHandlerTag );
	SetGUIObjectText ( oPC, "br_casino_rulespane", "pcpos", -1, sPCPos );
}


// clear a PC's data off RulesPane object

void ClosePCRulesPane ( string sHandlerTag, string sPCPos ) {
	object oHandler, oPC;
	string sGameName, sVarName;
	
	// get the RulesPane handler object
	oHandler = GetObjectByTag(sHandlerTag);
	
	// remove PC from handler object
	sVarName = "iCasinoRulesPaneSlot" + sPCPos;
	oPC = GetLocalObject ( oHandler, sVarName + "Player" );
	SetLocalInt ( oHandler, sVarName + "Taken", 0 );		
	
	// close rules pane
	CloseGUIScreen ( oPC, "br_casino_rulespane" );
}