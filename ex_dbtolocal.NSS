void main(string sDatabase="", string sVariable, string sObject = "")
{
	object oObject;

    // Use the the object who is conversing by default if nothing is set
    if (sObject == "") {
         sObject = "self";
    }
    // Use the the PC database by default if nothing is set
    if (sDatabase == "") {
        sDatabase = "PC";
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
    // Check campaign DB and set local int to that value
    int nDBInt = GetCampaignInt(sDatabase, sVariable, oObject);
	SetLocalInt(oObject, sVariable, nDBInt);
}
