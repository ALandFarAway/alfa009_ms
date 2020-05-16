/*
  nDB_Local = 1 = DB 2 = Local
  Alucelestria
  this code is in a beta state and should not be shared.
*/


int StartingConditional(int nDB_Local, string sVariable, int nValue,  string sObject="", string sTable="", string sDB="")
{
    object oObject;
    int nDBInt;

    // Use the PC table by default if nothing is set
    if (sTable == "") {
         sTable = "PC";
    }
    // Use the PC DB by default if nothing is set
    if (sDB == "") {
         sDB = "PC";
    }
    // Object to check is PC
    if (sObject == "self") {
        oObject = GetPCSpeaker();
    }
    // Object to check is self (one who is conversing w/ PC)
    else if (sObject == "OBJECT_SELF") {
        oObject = OBJECT_SELF;
    }
    // Object to check is Area
    else if (sObject == "area") {
        oObject = GetArea(GetPCSpeaker());
    }

    // See if we check campaign DB
    if (nDB_Local == 1) {
        nDBInt = GetCampaignInt(sDB, sVariable, oObject);
    }
    // See if instead we check local variable
    else if (nDB_Local == 2) {
        nDBInt = GetLocalInt(oObject, sVariable);
    }

    // Return TRUE if whatever the value in the DB is matches our value
    if (nDBInt == nValue) {
        return TRUE;
    }
    // If it doesn't just return FALSE
    return FALSE;
}
