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

CreateItemOnObject("plc_vv_chainring", oPC);

object oTarget;
oTarget = OBJECT_SELF;

DestroyObject(oTarget, 0.0);

}