

// OnFailToOpen.


void main()
{
    object oActor;
    object oPC = GetClickingObject();

      oActor = GetNearestObjectByTag("b06_moneychanger", oPC);
    AssignCommand(oActor, ActionStartConversation(oPC, "b06_door", FALSE, FALSE));
}
