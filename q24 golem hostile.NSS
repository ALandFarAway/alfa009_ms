// ga_bb_go_hostile

// By Brendan Bellina, Feb 2009

/*

	Based on x0_c2_go_hostile, which makes a creature hostile and killable

	Useful for hostiles that you want to have temporarily friendly --

	put them in a non-hostile faction, then use this to make them attack.

	Also unsets the plot flag and immortal flag.

	

	Parameters:

		string sTargetTag: tag of the creature to go hostile

			Defaults to OWNER

		string sShout: string to shout out

			If not passed as parm can be set by local variable AttackShout on the owner

			Defaults to none

/



#include "ginc_param_const"

#include "nw_i0_generic"

	

void main(string sTargetTag = "009_cr_q24_golem", string sShout = "Death awaits")

{

	object oPC =(GetPCSpeaker()==OBJECT_INVALID?OBJECT_SELF:GetPCSpeaker());

    object oTarget = GetTarget(sTargetTag, TARGET_OWNER);

	if (sShout == "") { sShout = GetLocalString(oTarget, "AttackShout"); }

	if (sShout != "") { AssignCommand(oTarget, ActionSpeakString(sShout)); }

	SetImmortal(oTarget, FALSE);

	SetPlotFlag(oTarget, FALSE);

	ChangeToStandardFaction(oTarget, STANDARD_FACTION_HOSTILE);

	AdjustReputation(oPC, oTarget, -100);

	DelayCommand(0.5, DetermineCombatRound(oPC));

	DelayCommand(0.7, AssignCommand(oTarget, ActionSpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK)));

}


*/
	#include "x0_i0_partywide"
#include "nw_i0_generic"


void main()
{
    object oTarget;

    // Get the creature who triggered this event.
    object oPC = GetEnteringObject();

    // Only fire for (real) PCs.
    if ( !GetIsPC(oPC)  ||  GetIsDMPossessed(oPC) )
        return;

    // Attack the PC.
	ChangeToStandardFaction(oTarget, STANDARD_FACTION_HOSTILE);

	AdjustReputation(oPC, oTarget, -100);
    //AdjustReputation(oPC, GetNearestObjectByTag("009_cr_q24_golem"), -100);
    SetIsTemporaryEnemy(oPC, GetNearestObjectByTag("009_cr_q24_golem"));
    AssignCommand(GetNearestObjectByTag("009_cr_q24_golem"), DetermineCombatRound(oPC));

    // Make "009_cr_q24_golem" dislike the PC's party more.
    oTarget = GetObjectByTag("009_cr_q24_golem");
    AdjustReputationWithFaction(oPC, oTarget, -100);
}
