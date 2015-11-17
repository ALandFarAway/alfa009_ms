#include "acr_db_persist_i"
#include "acr_quest_i"

//// Put this script OnEnter of your trigger

void main()
{
    object oTarget;

    // Get the creature who triggered this event.
    object oPC = GetEnteringObject();

    // Only fire for (real) PCs.
    if ( !GetIsPC(oPC)  ||  GetIsDMPossessed(oPC) )
        return;

    // Abort if the PC is not at least at stage 23 of journal quest "gc_orphans_missing".
    if ( GetLocalInt(oPC, "NW_JOURNAL_ENTRYgc_orphans_missing") < 23 )
    {
        SendMessageToPC(oPC, "*the tracks lead up to the door of the cottage*");
        return;
    }

    // Unlock "dr_n35_shore_cottage_enter".
    oTarget = GetObjectByTag("dr_n35_shore_cottage_enter");
    SetLocked(oTarget, FALSE);

	if (GetLocalInt(oPC,"NW_JOURNAL_ENTRgc_rowlina_orphans") <5)
  // lock "dr_n35_shore_cottage_enter".
    oTarget = GetObjectByTag("dr_n35_shore_cottage_enter");
    SetLocked(oTarget, TRUE);
}