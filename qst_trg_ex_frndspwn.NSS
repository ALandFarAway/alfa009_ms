///010_qst_trg_ex_frndspwn



#include "acr_quest_i"

const string ACR_QUEST_SAVED_OBJECT = "SAVED_OBJECT_";

void main()
{
	int count = 1;
	
	// If we've not spawned anything, abort.
	if(!GetIsObjectValid(GetLocalObject(OBJECT_SELF, ACR_QUEST_SAVED_OBJECT + IntToString(count))))
		return;
	
	string sQuest = GetLocalString(OBJECT_SELF, ACR_QST_NAME);
	int nLowerState = GetLocalInt(OBJECT_SELF, ACR_QST_LOWER_STATE);
	int bDespawn = TRUE;
	object oPC = GetFirstInPersistentObject(OBJECT_SELF, OBJECT_TYPE_CREATURE);
	while(GetIsObjectValid(oPC) && bDespawn)
	{
		if(ACR_RetrieveQuestState(sQuest, oPC) == nLowerState && oPC != GetExitingObject())
				bDespawn = FALSE;
		
		oPC = GetNextInPersistentObject(OBJECT_SELF, OBJECT_TYPE_CREATURE);
	}
	
	if(bDespawn)
	{
		while(GetIsObjectValid(GetLocalObject(OBJECT_SELF, ACR_QUEST_SAVED_OBJECT + IntToString(count))))
		{
			object oDespawn = GetLocalObject(OBJECT_SELF, ACR_QUEST_SAVED_OBJECT + IntToString(count));
			if(GetObjectType(oDespawn) == OBJECT_TYPE_ITEM)
			{
				if(!GetIsObjectValid(GetItemPossessor(oDespawn)))
					DestroyObject(oDespawn, 0.0f);
			}
			else if(GetLocalInt(oDespawn, "NO_DESPAWN") == 0)
			{
				DestroyObject(oDespawn, 0.0f);
			}
			count++;
		}
	}
}