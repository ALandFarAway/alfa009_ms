
// Put this OnHeartbeat.
//  Will make NPC sit on the ground crosslegged  sitgrounddown sitgroundidle	
// Will abort (do nothing) if fighting or talking or if no PCs are in the area.


void main()
{
	if (GetLocalInt(GetModule(),"Stop Ambient Life"))
	{
		return;
	}

	int nRandom=Random(1);
	if (nRandom==1)

	PlayCustomAnimation(OBJECT_SELF,"sitgroundidle", 1);
	//	AssignCommand(oNPC, ActionPlayAnimation(sitgroundidle));
	
}