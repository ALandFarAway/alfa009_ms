/* *  For download info, please visit:
 *  http://nwvault.ign.com/View.php?view=Other.Detail&id=1502
 */
// Put this script OnEnter.


#include "ginc_param_const"
#include "nw_i0_generic"
#include "acr_creature_i"
#include "acr_trigger_i"


void main()
{
    // Get the creature who triggered this event.
    object oPC = GetEnteringObject();

    // Only fire for (real) PCs.
    if ( !GetIsPC(oPC)  ||  GetIsDMPossessed(oPC) )
        return;

    // Only fire once.
    if ( GetLocalInt(GetModule(), "DO_ONCE__" + GetTag(OBJECT_SELF)) )
        return;
    SetLocalInt(GetModule(), "DO_ONCE__" + GetTag(OBJECT_SELF), TRUE);

    // Attack the PC.
    SetIsTemporaryEnemy(oPC, GetNearestObjectByTag("009_cr_con_bladegolem"));
    SetIsTemporaryEnemy(oPC, GetNearestObjectByTag("009_cr_con_bladegolem", OBJECT_SELF, 2));
    SetIsTemporaryEnemy(oPC, GetNearestObjectByTag("009_cr_con_bladegolem", OBJECT_SELF, 3));
    AssignCommand(GetNearestObjectByTag("009_cr_con_bladegolem"), DetermineCombatRound(oPC));
    AssignCommand(GetNearestObjectByTag("009_cr_con_bladegolem", OBJECT_SELF, 2), DetermineCombatRound(oPC));
    AssignCommand(GetNearestObjectByTag("009_cr_con_bladegolem", OBJECT_SELF, 3), DetermineCombatRound(oPC));
}
