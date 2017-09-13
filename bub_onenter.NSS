
// bub_OnEnter
// A3 combined onenter scripts

void main()
{

object oPC = GetEnteringObject();
object oSelf = OBJECT_SELF;
object oActor;

 if ( !GetIsPC(oPC)  ||  GetIsDMPossessed(oPC) )
        return;


if (GetTag(OBJECT_SELF) == "c_a1_slide_trigger")
	{

	FloatingTextStringOnCreature("*The floor gives way beneath you*", oPC);

	object oTarget;
	location lTarget;
	oTarget = GetWaypointByTag("c_a2_wp1");
	
	lTarget = GetLocation(oTarget);
	
	if (GetAreaFromLocation(lTarget)==OBJECT_INVALID) return;
	
	oTarget=GetFirstFactionMember(oPC, FALSE);
	
	while (GetIsObjectValid(oTarget))
	   {
	   AssignCommand(oTarget, ClearAllActions());
	
	   DelayCommand(2.0,AssignCommand(oTarget, ActionJumpToLocation(lTarget)));

	effect eEffect;
	eEffect = EffectSlow();
	
	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oTarget, 45.0f);

	   	   oTarget=GetNextFactionMember(oPC, FALSE);
	   }
	
	effect eEffect;
	eEffect = EffectDamage(7, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL);
	
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, oPC);

	return;
	}
	
if (GetTag(OBJECT_SELF) == "c_a9_exittrigger")
	{
	
    oActor = GetNearestObjectByTag("c_a9_speaker2", oPC);
    AssignCommand(oActor, ActionStartConversation(oPC, "c_a9_exitcave"));

	return;
	}
	
	
if (GetTag(OBJECT_SELF) == "comp_con1")
	{
	int DoOnce = GetLocalInt(OBJECT_SELF, GetTag(OBJECT_SELF));

	if (DoOnce==TRUE) return;

	SetLocalInt(OBJECT_SELF, GetTag(OBJECT_SELF), TRUE);

	ActionStartConversation(oPC, "comp_con1");
	
	return;
	}
	

	
if (GetTag(OBJECT_SELF) == "t12_trigger1")
	{
	int DoOnce = GetLocalInt(OBJECT_SELF, GetTag(OBJECT_SELF));
	
	if (DoOnce==TRUE) return;
	
	SetLocalInt(OBJECT_SELF, GetTag(OBJECT_SELF), TRUE);
	
	if (GetIsSkillSuccessful(oPC, SKILL_LISTEN, 10))
   	{
   	AssignCommand(GetObjectByTag("t12_ipoint1"), ActionSpeakString("*Gutteral commands and pitiful cries can be heard from within.*"));
	}
	return;
   	}

if (GetTag(OBJECT_SELF) == "b14_eleena_trig1")
	{
	  if ( GetLocalInt(oPC, "guild_quest") != 1 )
        return;


    oActor = GetNearestObjectByTag("b18_eleena", oPC);
    AssignCommand(oActor, ActionStartConversation(oPC, "b18_eleena"));

    DestroyObject(oSelf);
	return;
}

	
		


 
	  
}