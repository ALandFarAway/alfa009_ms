// Put this script OnUsed.

#include  "acr_quest_i"
void main()
{
    object oSelf = OBJECT_SELF;

    // Get the creature who triggered this event.
    object oPC = GetLastUsedBy();

	 // Give "009_injured_mark" to the PC.
    CreateItemOnObject("009_injured_mark", oPC);

	  // Destroy objects (not fully effective until this script ends).
    DestroyObject(oSelf);
    DestroyObject(GetObjectByTag("009_quest_orphan_mark"));

     // Update the party's journals.
    

     ACR_AddPersistentJournalQuestEntry("gc_orphans_missing", 28, oPC,1);
}