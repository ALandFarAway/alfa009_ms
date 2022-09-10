//Wynna March 2009



void main()
{	
	object oOwner = GetModuleItemLostBy();
    object oItem = GetModuleItemLost();
	
	object oShovelPLC = CreateObject(OBJECT_TYPE_PLACEABLE, "abr_plc_shovel_port", GetLocation(oOwner));
    DestroyObject(oItem);
	}