// 	Script Name:	drl_placeable_grabber
/*
	Description: 	Replaces placeable placed on with *nQuantity* of item 
					*sItemTemplate*.  If applicable, leaves  *sNewPlace* behind.
					
					Variables go on the object.
					int nQuantity = number of items to give (1 if blank)
					string sItemTemplate = template of item PC gets
					string sNewPlace = object that replaces the placeable
					Goes in "on used" script.
*/
// 	Programmer: Darin LaSota on may 14th, 2012

void main()
{
	// get appropriate variables in order
	object oPC = GetLastUsedBy();
	location lLocation = GetLocation(OBJECT_SELF);
	string sItemTemplate = GetLocalString(OBJECT_SELF, "sItemTemplate");
	int nQuantity = GetLocalInt(OBJECT_SELF, "nQuantity");
	string sNewPlace = GetLocalString(OBJECT_SELF, "sNewPlace");
	
	// return 1 item if quantity left blank, else specified quantity
	if (nQuantity == 0)
		{
			CreateItemOnObject(sItemTemplate, oPC, 1, sItemTemplate, TRUE);
		}
	else
		{	
			CreateItemOnObject(sItemTemplate, oPC, nQuantity, sItemTemplate, TRUE);
		} 
	// get rid of it...
	DestroyObject(OBJECT_SELF, 0.3);
	
	// if sNewPlace exists, spawn it in the same location
	if (GetStringLength(sNewPlace)>=1)
		{
		CreateObject(OBJECT_TYPE_PLACEABLE, sNewPlace, lLocation, FALSE, sNewPlace);
		}
	
}