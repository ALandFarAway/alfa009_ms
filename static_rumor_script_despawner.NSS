#include "acr_quest_i"

void main()
{
	// If the quest isn't spawned, we don't care. Skip it all.
	if(!GetIsObjectValid(GetLocalObject(OBJECT_SELF, "010_intro_102_A")))
		return;

	// Otherwise, see if there's anyone left in the trigger
	// who is on the quest.
	int bDespawn = TRUE;
	object oPC = GetFirstInPersistentObject();
	while(GetIsObjectValid(oPC) && bDespawn)
	{
		if(GetIsPC(oPC))
		{
			int nQuest = ACR_RetrieveQuestState("010_intro", oPC);
			if(nQuest == 102 || nQuest == 202 || nQuest == 302 ||  nQuest == 402 || nQuest == 502)
			{
				bDespawn = FALSE;
			}
		}
		oPC = GetNextInPersistentObject();
	}

	// If no one in the area is on the quest, we despawn.
	if(bDespawn)
	{
		DestroyObject(GetLocalObject(OBJECT_SELF, "010_intro_102_A"));
		DestroyObject(GetLocalObject(OBJECT_SELF, "010_intro_102_B"));
		DestroyObject(GetLocalObject(OBJECT_SELF, "010_intro_102_C"));
		DestroyObject(GetLocalObject(OBJECT_SELF, "010_intro_102_D"));
	}
}