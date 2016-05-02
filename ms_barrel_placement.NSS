const int DEBUG = FALSE;

void main ()
{
	object oItem = OBJECT_SELF;
	
	location lTarget = GetLocation(oItem);
	
	int iBarrelDice = GetLocalInt(oItem, "BLAST_DICE");
	int iBarrelRadius = GetLocalInt(oItem, "BLAST_RADIUS");
	
	if (iBarrelDice == 0) iBarrelDice = 1;
	if (iBarrelRadius == 0) iBarrelRadius = 1;
	
	// Determine size of placed barrel
	string sBarrelResRef = "ms_barrel_blast_medium";
	if (iBarrelRadius + iBarrelDice > 11) sBarrelResRef = "ms_barrel_blast_large";
	if (iBarrelRadius + iBarrelDice < 5) sBarrelResRef = "ms_flask_blast_small";

	// DEBUG
	if (DEBUG) 
	{
		SendMessageToPC(GetFirstPC(), "BLAST_DICE: " + IntToString(iBarrelDice));
		SendMessageToPC(GetFirstPC(), "BLAST_RADIUS: " + IntToString(iBarrelRadius));
	}
	
	object oBarrel = CreateObject(OBJECT_TYPE_PLACEABLE, sBarrelResRef, lTarget);
	
	SetLocalInt(oBarrel, "BARREL_BLAST_RADIUS", iBarrelRadius);
	SetLocalInt(oBarrel, "BARREL_BLAST_DICE", iBarrelDice);
	
	DestroyObject(oItem);	
}