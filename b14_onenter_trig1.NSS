
// b14_OnEnter_trig1


void main()
{
    object oActor;
    object oTarget;
	object oSelf = OBJECT_SELF;
 
    object oPC = GetEnteringObject();
    oActor = GetObjectByTag("b18_eleena");

    if ( oPC != oActor )
        return;

    oTarget = GetObjectByTag("b14_door2");
    AssignCommand(oTarget, ActionOpenDoor(oTarget));

    SetLockLockable(oTarget);
    SetLockLockDC(oTarget, 20);

    oActor = GetObjectByTag("b18_eleena");
    AssignCommand(oActor, ActionMoveToObject(GetNearestObjectByTag("b14_eleena_wp2")));

	DestroyObject(oSelf);
	
	
	
	}