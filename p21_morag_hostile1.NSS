// put in onenter of trigger

#include "nw_i0_generic"

void main()
{
    object oPC = GetEnteringObject();

    if (!GetIsPC(oPC) || GetIsDMPossessed(oPC))
        return;

    object oTarget1 = GetNearestObjectByTag("Morag_1");
	ChangeToStandardFaction(oTarget1, STANDARD_FACTION_HOSTILE);
	 AssignCommand(oTarget1, DetermineCombatRound(oPC));
	 object oTarget2 = GetNearestObjectByTag("Morag_2");
	 ChangeToStandardFaction(oTarget2, STANDARD_FACTION_HOSTILE);
	  AssignCommand(oTarget2, DetermineCombatRound(oPC));
	 object oTarget3 = GetNearestObjectByTag("Morag_3");
	 ChangeToStandardFaction(oTarget3, STANDARD_FACTION_HOSTILE);
	  AssignCommand(oTarget3, DetermineCombatRound(oPC));
	 object oTarget4 = GetNearestObjectByTag("Morag_4");
    ChangeToStandardFaction(oTarget4, STANDARD_FACTION_HOSTILE);
    AssignCommand(oTarget4, DetermineCombatRound(oPC));
}