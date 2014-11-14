void main()
{
    object oPC      = GetItemActivator();
    object oItem    = GetItemActivated();
	object oLocArea = GetArea(GetWaypointByTag("ROBYN_BAT"));
 	if(GetArea(oPC) == oLocArea)
	{
		SetLocalInt(GetModule(), "ROBYN_STATE", 2);
		object oArea = GetArea(oPC);
		object oTargetArea = GetArea(GetWaypointByTag("ROBYN_BRD"));
		object oCreature = GetFirstObjectInArea(oArea);
		while(GetIsObjectValid(oCreature))
		{
			if(GetObjectType(oCreature) == OBJECT_TYPE_CREATURE)
			{
				vector vSource = GetPosition(oCreature);
				float fTargX = vSource.x;
				float fTargY = vSource.y;
				float fTargZ = vSource.z;
				if(fTargX > 110.0f &&
				   fTargZ > 1.0f)
				{
					fTargX -= 10.0f;
					fTargY -= 4.0f;
				}
				vector vTarget = Vector(fTargX, fTargY, fTargZ);
				location lTarget = Location(oTargetArea, vTarget, GetFacing(oCreature));
				AssignCommand(oCreature, JumpToLocation(lTarget));
			}
			oCreature = GetNextObjectInArea(oArea);
		}
		vector vSource = GetPosition(oPC);
		float fTargX = vSource.x;
		float fTargY = vSource.y;
		float fTargZ = vSource.z;
		if(fTargX > 110.0f &&
		   fTargZ > 1.0f)
		{
			fTargX -= 10.0f;
			fTargY -= 4.0f;
		}
		vector vTarget = Vector(fTargX, fTargY, fTargZ);
		location lTarget = Location(oTargetArea, vTarget, GetFacing(oPC));
		AssignCommand(oPC, JumpToLocation(lTarget));
	}
}