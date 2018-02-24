
// Put this script OnEnter.

#include "acr_trigger_i"

void main()
{
ACR_TriggerOnEnter();   

    object oTarget;
    object oSpawn;

    // Get the creature who triggered this event.
    object oPC = GetEnteringObject();

    // Only fire for (real) PCs.
    if ( !GetIsPC(oPC)  ||  GetIsDMPossessed(oPC) )
        return;

    // Abort if a skill check (spot) is failed.
    if ( d20() + GetSkillRank(SKILL_SPOT, oPC) < 24 )
        return;

    // Spawn "secret cave door".
    oTarget = GetWaypointByTag("WP_UD_e_secretcave_enter");
    oSpawn = CreateObject(OBJECT_TYPE_DOOR, "secret_ud_e_cave_enter", GetLocation(oTarget));
}
