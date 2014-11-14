void main()
{
    object oPC      = GetItemActivator();
    object oItem    = GetItemActivated();
	object oLocArea = GetArea(GetWaypointByTag("ROBYN_SEA"));
 	if(GetArea(oPC) == oLocArea)
	{
		SetLocalInt(GetModule(), "ROBYN_STATE", 1);
		object oArea = GetArea(oPC);
		object oTargetArea = GetArea(GetWaypointByTag("ROBYN_BAT"));
		object oCreature = GetFirstObjectInArea(oArea);
		while(GetIsObjectValid(oCreature))
		{
			if(GetObjectType(oCreature) == OBJECT_TYPE_CREATURE)
			{
				location lTarget = Location(oTargetArea, GetPosition(oCreature), GetFacing(oCreature));
				AssignCommand(oCreature, JumpToLocation(lTarget));
			}
			oCreature = GetNextObjectInArea(oArea);
		}
		location lTarget = Location(oTargetArea, GetPosition(oPC), GetFacing(oPC));
		AssignCommand(oPC, JumpToLocation(lTarget));
	}
}