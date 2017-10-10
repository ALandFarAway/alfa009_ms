// Put this script OnOpen.


#include "nw_i0_generic"

#include "acr_door_i"

void main()
{
    object oTarget;
    object oSpawn;

    // Get the creature who triggered this event.
    object oPC = GetLastOpenedBy();
     ACR_DoorOnOpen();
    // Spawn "009_cr_elemental".
    oTarget = GetWaypointByTag("WP_spawnnpchere_sp1");
    oSpawn = CreateObject(OBJECT_TYPE_CREATURE, "009_cr_elemental", GetLocation(oTarget));
    AssignCommand(oSpawn, DetermineCombatRound(oPC));
}