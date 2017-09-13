
// b06_OnDamaged

#include "nw_i0_generic"


void main()
{
    object oPC = GetLastHostileActor();

    AdjustReputation(oPC, OBJECT_SELF, -100);
    SetIsTemporaryEnemy(oPC);
    DetermineCombatRound(oPC);

    AdjustAlignment(oPC, ALIGNMENT_CHAOTIC, 5);
}