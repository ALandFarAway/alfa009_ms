#include "acr_quest_i"


void main(string sQuest, int nGold, int bPartyWide=FALSE)
{
object oPC = GetPCSpeaker();
object oItem = GetLocalObject(oPC, sQuest);

// reward the player
GiveGoldToCreature(oPC, nGold);

// remove the quest item if one exists
if (GetIsObjectValid(oItem)) { DestroyObject(oItem); }

// update the quest to its final (completed) state
ACR_AddPersistentJournalQuestEntry(sQuest, ACR_RetrieveQuestState(sQuest, oPC) + 1, oPC, bPartyWide, FALSE, FALSE);
}