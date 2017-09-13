
// OnPerceived
// bealzebub 4/13/2012


#include "nw_i0_generic"
#include "ginc_ai"

void main()
{
    object oTarget;
	object oSelf = OBJECT_SELF;

    if ( !GetLastPerceptionSeen() )
        return;

    object oPC = GetLastPerceived();
	
	if ( GetLocalInt(oSelf, "spoke_jugug") == 1 )
         {
	   ExecuteScript("nw_c2_default2",OBJECT_SELF);
		 return;
		}

    if ( !GetIsPC(oPC)  ||  GetIsDMPossessed(oPC) )
        return;


{
    object oTarget=GetNearestObjectByTag(GetLocalString(OBJECT_SELF, "TargetTag"));
    WrapperActionAttack(oTarget);
    SetCreatureOverrideAIScriptFinished();
    return;
}


}