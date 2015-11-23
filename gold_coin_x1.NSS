/*
 *  For download info, please visit:
 *  http://nwvault.ign.com/View.php?view=Other.Detail&id=1502
 */
// Put this script OnUsed.

#include "acr_db_persist_i"

void main()
{
    // Get the creature who triggered this event.
    object oPC = GetLastUsedBy();

    // Only fire once per PC.
    if (ACR_GetPersistentInt(OBJECT_SELF, "DO_ONCE__" + ObjectToString(oPC)) )
        return;
   	ACR_SetPersistentInt(OBJECT_SELF, "DO_ONCE__" + ObjectToString(oPC), TRUE);

    // Give 1 gold to the PC.
    GiveGoldToCreature(oPC, 1);
}
