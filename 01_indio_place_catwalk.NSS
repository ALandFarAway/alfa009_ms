
void main()
{
    object oPC = GetLastUsedBy();
	string sDestTag; //The lever number
	sDestTag = GetSubString(GetTag(OBJECT_SELF), 4, 2);
   // string sDestTag = GetLocalString(OBJECT_SELF, sDestination);
   // object oDestination = GetNearestObjectByTag(sDestTag);
	object oTarget;
	oTarget = GetNearestObjectByTag("door" + sDestTag);
	
	if(GetIsObjectValid(oTarget))
    AssignCommand(oPC, JumpToObject(oTarget));
    else
        SendMessageToPC(oPC, "DEBUG: Destination object tag missing or invalid");
}
/*
void main(string sDestination)
{

object oPC = GetLastUsedBy();
string sDestTag = GetLocalString(OBJECT_SELF, sDestination);
if (!GetIsPC(oPC)) return;

object oTarget;
location lTarget;
oTarget = GetWaypointByTag(sDestTag);

lTarget = GetLocation(oTarget);

//only do the jump if the location is valid.
//though not flawless, we just check if it is in a valid area.
//the script will stop if the location isn't valid - meaning that
//nothing put after the teleport will fire either.
//the current location won't be stored, either

if (GetAreaFromLocation(lTarget)==OBJECT_INVALID) return;

AssignCommand(oPC, ClearAllActions());

AssignCommand(oPC, ActionJumpToLocation(lTarget));

}
*/