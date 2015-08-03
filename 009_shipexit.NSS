void main()
{
	object oArea = GetArea(OBJECT_SELF);
	object oExitWP = GetLocalObject(oArea, "EXIT_WP");
	if(oExitWP == OBJECT_INVALID) 
	{
		SendMessageToPC(GetClickingObject(), "You've already pushed away from shore, and now there's a dangerous swim in the ocean between you and land.");
		return;
	}
	else 
	{
		AssignCommand(GetClickingObject(), JumpToObject(oExitWP));
	}
}