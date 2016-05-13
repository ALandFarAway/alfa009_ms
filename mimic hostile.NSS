#include "nw_i0_generic"

void main()
{
    object oPC = GetEnteringObject();

    if (!GetIsPC(oPC) || GetIsDMPossessed(oPC))
        return;

    object oTarget = GetNearestObjectByTag("abr_cr_ab_mimic_01");
    ChangeToStandardFaction(oTarget, STANDARD_FACTION_HOSTILE);
    AssignCommand(oTarget, DetermineCombatRound(oPC));
}