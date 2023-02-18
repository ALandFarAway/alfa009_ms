// put in onenter of trigger
//used in alaron r26 stirgewick ruins to activate creature when party gets to close

#include "nw_i0_generic"

void main()
{
    object oPC = GetEnteringObject();

    if (!GetIsPC(oPC) || GetIsDMPossessed(oPC))
        return;

    object oTarget = GetNearestObjectByTag("009_c_con_animated_book_lg");
    ChangeToStandardFaction(oTarget, STANDARD_FACTION_HOSTILE);
    AssignCommand(oTarget, DetermineCombatRound(oPC));
}