// nDB_Local 1 = DB 2 = Local 3 = Both
// sObject self or area
//  Alucelestria
//  this code is in a beta state and should not be shared.

void main(int nDB_Local, string sVariable, int nValue, string sObject, string sTable, string sDB)
{
     object oObject;

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

    // Set campaign DB with value
    if (nDB_Local == 1 || nDB_Local == 3) {
        SetCampaignInt(sDB, sVariable, nValue, oObject);
    }
    // Set local variable with value
    if (nDB_Local == 2 || nDB_Local == 3) {
        SetLocalInt(oObject, sVariable, nValue);
    }
}
