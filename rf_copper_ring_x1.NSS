/*
 *  For download info, please visit:
 *  http://nwvault.ign.com/View.php?view=Other.Detail&id=1502
 */
// Put this script OnUsed.

#include "acr_db_persist_i"

void main()
{

object oPC = GetLastUsedBy();

if (!GetIsPC(oPC)) return;

CreateItemOnObject("000_it_copperring", oPC);

object oTarget;
oTarget = OBJECT_SELF;

DestroyObject(oTarget, 0.0);

}