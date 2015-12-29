
// Put this OnHeartbeat.
//  Will make NPC sit on the ground crosslegged  sitgrounddown 	
// Will abort (do nothing) if fighting or talking or if no PCs are in the area.


void main()
{
	if (GetLocalInt(GetModule(),"Stop Ambient Life"))
	{
		return;
	}

	int nRandom=Random(1);
	if (nRandom==0)
		PlayCustomAnimation(OBJECT_SELF,"sitgrounddown", -1);
	
}