/*
 *  For download info, please visit:
 *  http://nwvault.ign.com/View.php?view=Other.Detail&id=1502
 */
// Put this script OnUsed.

#include "acr_db_persist_i"

void main()
{
    object oSelf = OBJECT_SELF;

    // Get the creature who triggered this event.
    object oPC = GetPlaceableLastClickedBy();

    // Give 1 gold to the PC.
    GiveGoldToCreature(oPC, 1);

    // Destroy an object (not fully effective until this script ends).
    DestroyObject(oSelf);
}