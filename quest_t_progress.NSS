#include "acr_quest_i"
int StartingConditional(string sQuest, int nState)
{
return (ACR_RetrieveQuestState(sQuest, GetPCSpeaker()) == nState) ? TRUE : FALSE;
}