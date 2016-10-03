#include "acr_quest_i"

void main(string sQuest, int nState, int bAllPartyMembers=TRUE, int bAllPlayers=FALSE, int bAllowOverrideHigher=FALSE, int nXP=0)
{
// add the quest to the player and his party
ACR_AddPersistentJournalQuestEntry(sQuest, nState, GetPCSpeaker(), bAllPartyMembers, bAllPlayers, bAllowOverrideHigher, nXP);
}