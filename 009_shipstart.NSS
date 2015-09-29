#include "acr_area_instance_i"

void _FuckTheCompiler(int a, string b, location c, int d, string e)
{
	CreateObject(a,b,c,d,e);
}

void _AddDock(object oArea)
{
	object oPlac = GetFirstObjectInArea(oArea);
	while(GetIsObjectValid(oPlac))
	{
		if(GetTag(oPlac) == "PLANK_POSITION")     DelayCommand(1.0f, _FuckTheCompiler(OBJECT_TYPE_PLACEABLE, "plc_hss_plank_str", GetLocation(oPlac), TRUE, "TEMP"));
		else if(GetTag(oPlac) == "DOCK_POSITION") DelayCommand(1.0f, _FuckTheCompiler(OBJECT_TYPE_PLACEABLE, "plc_bc_dockg8", GetLocation(oPlac), TRUE, "TEMP"));
		oPlac = GetNextObjectInArea(oArea);
	}
}

void _RemoveDock(object oArea)
{
	object oPlac = GetFirstObjectInArea(oArea);
	while(GetIsObjectValid(oPlac))
	{
		if(GetTag(oPlac) == "TEMP") DestroyObject(oPlac, 0.0f);
		oPlac = GetNextObjectInArea(oArea);
	}
}

void GarbageCollection(object oShip, object oStartWP, object oEndWP)
{
	int notEmpty = 0;
	object oPC = GetFirstObjectInArea(oShip);
	while(GetIsObjectValid(oPC))
	{
		if(GetIsPC(oPC))
		{
			SendMessageToPC(oPC, "The ship remains at the dock, and the sailors stop by on occasion, letting you know that it's time to get out.");
			notEmpty++;
		}
		oPC = GetNextObjectInArea(oShip);
	}
	if(notEmpty) 
	{
		DelayCommand(60.0f, GarbageCollection(oShip, oStartWP, oEndWP));
		return;
	}
	int count = 0;
	object oArea = GetLocalObject(OBJECT_SELF, ObjectToString(oStartWP) + "_" + ObjectToString(oEndWP) + "_" + IntToString(count));
	while(GetIsObjectValid(oArea))
	{
		if(oArea == oShip)
		{
			DeleteLocalObject(OBJECT_SELF, ObjectToString(oStartWP) + "_" + ObjectToString(oEndWP) + "_" + IntToString(count));
		}
		count++;
		oArea = GetLocalObject(OBJECT_SELF, ObjectToString(oStartWP) + "_" + ObjectToString(oEndWP) + "_" + IntToString(count));
	}
	ACR_ReleaseAreaInstance(oShip);
}

void StartShipTrip(object oShip)
{
	object oPC = GetFirstObjectInArea(oShip);
	while(GetIsObjectValid(oPC))
	{
		if(GetIsPC(oPC)) SendMessageToPC(oPC, "The ship pulls away from the dock, and you are now underway.");
		oPC = GetNextObjectInArea(oShip);
	}
	DeleteLocalObject(oShip, "EXIT_WP");
	_RemoveDock(oShip);
}

void EndShipTrip(object oShip, object oStart, object oDest)
{
	object oPC = GetFirstObjectInArea(oShip);
	while(GetIsObjectValid(oPC))
	{
		if(GetIsPC(oPC)) SendMessageToPC(oPC, "The ship sails comfortably to the new dock, and you may now leave the ship.");
		oPC = GetNextObjectInArea(oShip);
	}
	SetLocalObject(oShip, "EXIT_WP", oDest);
	DelayCommand(60.0f, GarbageCollection(oShip, oStart, oDest));
	_AddDock(oShip);
}

object GetShipTemplate(object oPC)
{
	if(GetIsObjectValid(GetLocalObject(GetModule(), "SHIP_TEMPLATE"))) return GetLocalObject(GetModule(), "SHIP_TEMPLATE");
	
	object oShipWP = GetWaypointByTag("WP_SHIP_ENTER");
	object oTemplateArea = GetArea(oShipWP);
	if(GetIsObjectValid(oTemplateArea))
	{
		return oTemplateArea;
	}
	else
	{
		SendMessageToPC(oPC, "Error: Could not find the ship's template area.");
		return OBJECT_INVALID;
	}
}
object GetShip(object oStartWP, object oEndWP, object oPC)
{
	int count = 0;
	object oArea = GetLocalObject(OBJECT_SELF, ObjectToString(oStartWP) + "_" + ObjectToString(oEndWP) + "_" + IntToString(count));
	while(GetIsObjectValid(oArea))
	{
		if(GetLocalObject(oArea, "EXIT_WP") == oStartWP)
		{
			return oArea;
		}
		count++;
		oArea = GetLocalObject(OBJECT_SELF, ObjectToString(oStartWP) + "_" + ObjectToString(oEndWP) + "_" + IntToString(count));
	}
	oArea = GetShipTemplate(oPC);
	if(!GetIsObjectValid(oArea)) return OBJECT_INVALID;
	oArea = ACR_CreateAreaInstance(oArea);
	SetLocalObject(OBJECT_SELF, ObjectToString(oStartWP) + "_" + ObjectToString(oEndWP) + "_" + IntToString(count), oArea);
	SetLocalObject(oArea, "EXIT_WP", oStartWP);
	_AddDock(oArea);
	DelayCommand(1.0f * 25.0f, StartShipTrip(oArea));
	DelayCommand(7.0f * 10.0f, EndShipTrip(oArea, oStartWP, oEndWP));
	return oArea;
}

object GetShipWaypoint(object oShip, object oPC)
{
	object oWP = GetFirstObjectInArea(oShip);
	while(GetIsObjectValid(oWP))
	{
		if(GetTag(oWP) == "WP_SHIP_ENTER") return oWP;
		oWP = GetNextObjectInArea(oShip);
	}
	SendMessageToPC(oPC, "Error: could not find ship's entry waypoint");
	return OBJECT_INVALID;
}

void ManageShip(string startWP, string endWP, object oPC)
{
	object oStartWP = GetWaypointByTag(startWP);
	object oEndWP = GetWaypointByTag(endWP);
	object oShip = GetShip(oStartWP, oEndWP, oPC);
	if(!GetIsObjectValid(oShip)) return;
	object oWP = GetShipWaypoint(oShip, oPC);
	if(!GetIsObjectValid(oWP)) return;
	AssignCommand(oPC, JumpToObject(oWP));
}

void main(string startWP, string endWP)
{
	object oPC = GetPCSpeaker();
	SendMessageToPC(oPC, "You're shown to the ship, and make ready to depart.");
	AssignCommand(GetModule(), ManageShip(startWP, endWP, oPC));}