// Suderham OnClientEnter.
// bealzebub 5/4/2012


void main()
{
    object oSpawn;
	object oTarget;
    int nValue;

    object oPC = GetEnteringObject();
	oTarget = GetModule();

    if ( !GetIsPC(oPC)  ||  GetIsDMPossessed(oPC) )
        return;
		
 	if ( GetLocalInt(oPC, "DO_ONCE__" + GetTag(OBJECT_SELF)) )
        return;

    if ( GetLocalInt(oTarget, "corruption_speak") == 7 )
    {
      
        nValue = GetLocalInt(oTarget, "adoril_attack") + 1;
        SetLocalInt(oTarget, "adoril_attack", nValue);
		
		if ( GetLocalInt(oTarget, "adoril_attack") == 4 )
		{
			 oSpawn = CreateObject(OBJECT_TYPE_CREATURE, "s_adoril", GetLocation(oPC));
	         AssignCommand(oSpawn, ActionStartConversation(oPC));
			 SetLocalInt(oPC, "DO_ONCE__" + GetTag(OBJECT_SELF), TRUE);
		}

			
    }
}