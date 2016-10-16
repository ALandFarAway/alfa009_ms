#include "acr_quest_i"

int QuestIsDone()
{
	if(GetTag(GetArea(OBJECT_SELF)) == GetLocalString(OBJECT_SELF, "ESCORT_TARGET"))
	{
		return TRUE;
	}
	return FALSE;
}

void AdvanceQuest(object oPC)
{
	ACR_AddPersistentJournalQuestEntry(GetLocalString(OBJECT_SELF, "ESCORT_QUEST"), GetLocalInt(OBJECT_SELF, "ESCORT_QUEST_UPPER_STATE"), oPC);
	DestroyObject(OBJECT_SELF, 0.0f);
}

void Follow(object oPC)
{
	if(QuestIsDone()) 
	{
		AdvanceQuest(oPC);
		return;
	}
	if(GetArea(oPC) == GetArea(OBJECT_SELF))
	{
		ActionMoveToObject(oPC, FALSE, 1.0f);
	}
	else
	{
		ClearAllActions(TRUE);
		JumpToObject(oPC);
	}
	DelayCommand(6.0f, Follow(oPC));
}
void main()
{
	Follow(GetPCSpeaker());	
	SetLocalInt(OBJECT_SELF, "NO_DESPAWN", 1);
}