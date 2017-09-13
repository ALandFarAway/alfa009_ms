
// Put this script OnEnter.


void main()
{
    object oActor = GetObjectByTag("b14_panther");
    object oPC = GetEnteringObject();
	object oSelf = OBJECT_SELF;
   
	
  if ( oPC != oActor )
        return;

    AssignCommand(oActor, ClearAllActions());
    AssignCommand(oActor, ActionMoveToObject(GetNearestObjectByTag("b14_panther_wp1")));
}
