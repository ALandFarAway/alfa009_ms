#include "acr_quest_i"
#include "acr_notifications_i"
#include "acr_skills_i"
#include "acr_items_i"

//Static Rumor System.  Used to pass on information to PC's through triggers.  Variables are as below.  
//Painfully assembled by Rumple with much help from Foam and Zelknolf.  

//string QuestName = Tag of the Quest
//string WhatTheyLearned = Information to be relayed to PC (in game)
//int NeedTrack = Set to 1 if track skill required (auto pass)
//int NeedGather = Set to 1 if track skill required (must also set DC as below)
//int DCGather = Set DC for skill check
//int NeedListen = Set to 1 if track skill required (must also set DC as below)
//int DCListen = Set DC for skill check
//int NeedSpot = Set to 1 if track skill required (must also set DC as below)
//int DCSpot = Set DC for skill check
//int NeedSearch = Set to 1 if track skill required (must also set DC as below)
//int DCSearch = Set DC for skill check
//int QuestStageToAdvance = Quest state required to trigger trigger
//int JournalUpdated = Set to 1 if Journal is to be updated
//int NewQuestStage = Quest stage this trigger will set quest to

//int ObjectType = for object type (cr =1, pl = 64

//string SpawnWaypointA = waypoint Tag to spawn at
//string SpawnNameA = resref of spawn to be spawned
//and so on

//string DayNightRestrict = "" for anytime, Day for only spawns in day, Night for only Night

int nTimeIsOK(object oPC)
{
	{
	if(GetLocalString(OBJECT_SELF,"DayNightRestrict") == "")
	return TRUE;
	else if(GetLocalString(OBJECT_SELF,"DayNightRestrict") == "Day" && GetIsNight() == FALSE)
	return TRUE;
	else if(GetLocalString(OBJECT_SELF,"DayNightRestrict") == "Night" && GetIsNight() == TRUE)
	return TRUE;
	}
	return FALSE;
}

int WillFireTrigger(object oPC)
{
	object oMember = GetFirstFactionMember(oPC);
	while(GetIsObjectValid(oMember))
	{	
		int nState = ACR_RetrieveQuestState(GetLocalString(OBJECT_SELF,"QuestName"), oMember);
		if(nState == GetLocalInt(OBJECT_SELF,"QuestStageToAdvance") && 
		   GetLocalInt(OBJECT_SELF, IntToString(ACR_GetCharacterID(oMember))) == 0)
			return TRUE;
		oMember = GetNextFactionMember(oPC);			
	}
	return FALSE;
}

void main()
{	
	object oPC = GetEnteringObject();
	
	// No one needs this quest to be advanced. Best return now.
	if(!WillFireTrigger(oPC))
		return;
	if(!nTimeIsOK(oPC)) 
		return;
			
	// Make checks to see if rumor was learnt.
	int nAdvance = FALSE;		
	if(GetLocalInt(OBJECT_SELF,"NeedTrack") && GetHasFeat(FEAT_TRACK, oPC))
		nAdvance = TRUE;
	else if(GetLocalInt(OBJECT_SELF,"NeedGather") && GetIsSkillSuccessful(oPC, SKILL_GATHER_INFORMATION, GetLocalInt(OBJECT_SELF,"DCGather"), FALSE))
		nAdvance = TRUE;	
	else if(GetLocalInt(OBJECT_SELF,"NeedListen") && GetIsSkillSuccessful(oPC, SKILL_LISTEN, GetLocalInt(OBJECT_SELF,"DCListen"), FALSE))
		nAdvance = TRUE;
	else if(GetLocalInt(OBJECT_SELF,"NeedSpot") && GetIsSkillSuccessful(oPC, SKILL_SPOT, GetLocalInt(OBJECT_SELF,"DCSpot"), FALSE))
		nAdvance = TRUE;	
	else if(GetLocalInt(OBJECT_SELF,"NeedSearch") && GetIsSkillSuccessful(oPC, SKILL_SEARCH, GetLocalInt(OBJECT_SELF,"DCSearch"), FALSE))
		nAdvance = TRUE;
	
	if(nAdvance == TRUE){
		
		//checks if placables are required then spawns in
		
		if(GetLocalString(OBJECT_SELF,"SpawnNameA") != "") { 
		
		object oWaypointA = GetWaypointByTag(GetLocalString(OBJECT_SELF,"SpawnWaypointA"));
		object oTransporterA = CreateObject(GetLocalInt(OBJECT_SELF,"ObjectType"), GetLocalString(OBJECT_SELF,"SpawnNameA"), GetLocation(oWaypointA));
		SetLocalObject(OBJECT_SELF, GetLocalString(OBJECT_SELF,"SpawnWaypointA"), oTransporterA);
		if (GetLocalInt(OBJECT_SELF,"ObjectType") == 64){ 
		ACR_GenerateLoot(oTransporterA, GetLocalInt(oTransporterA, "TotalLootValue"), GetLocalInt(oTransporterA, "MaxItemValue"));
		
		}
		}
		
		if(GetLocalString(OBJECT_SELF,"SpawnNameB") != "") { 
		
		object oWaypointB = GetWaypointByTag(GetLocalString(OBJECT_SELF,"SpawnWaypointB"));
		object oTransporterB = CreateObject(GetLocalInt(OBJECT_SELF,"ObjectType"), GetLocalString(OBJECT_SELF,"SpawnNameB"), GetLocation(oWaypointB));
		SetLocalObject(OBJECT_SELF, GetLocalString(OBJECT_SELF,"SpawnWaypointB"), oTransporterB);
		if (GetLocalInt(OBJECT_SELF,"ObjectType") == 64){ 
		ACR_GenerateLoot(oTransporterB, GetLocalInt(oTransporterB, "TotalLootValue"), GetLocalInt(oTransporterB, "MaxItemValue"));
		
		}
		}
		
		if(GetLocalString(OBJECT_SELF,"SpawnNameC") != "") { 
		
		object oWaypointC = GetWaypointByTag(GetLocalString(OBJECT_SELF,"SpawnWaypointC"));
		object oTransporterC = CreateObject(GetLocalInt(OBJECT_SELF,"ObjectType"), GetLocalString(OBJECT_SELF,"SpawnNameC"), GetLocation(oWaypointC));
		SetLocalObject(OBJECT_SELF, GetLocalString(OBJECT_SELF,"SpawnWaypointC"), oTransporterC);
		if (GetLocalInt(OBJECT_SELF,"ObjectType") == 64){ 
		ACR_GenerateLoot(oTransporterC, GetLocalInt(oTransporterC, "TotalLootValue"), GetLocalInt(oTransporterC, "MaxItemValue"));
		
		}
		}
		
		if(GetLocalString(OBJECT_SELF,"SpawnNameD") != "") { 
		
		object oWaypointD = GetWaypointByTag(GetLocalString(OBJECT_SELF,"SpawnWaypointD"));
		object oTransporterD = CreateObject(GetLocalInt(OBJECT_SELF,"ObjectType"), GetLocalString(OBJECT_SELF,"SpawnNameD"), GetLocation(oWaypointD));
		SetLocalObject(OBJECT_SELF, GetLocalString(OBJECT_SELF,"SpawnWaypointD"), oTransporterD);
		if (GetLocalInt(OBJECT_SELF,"ObjectType") == 64){ 
		ACR_GenerateLoot(oTransporterD, GetLocalInt(oTransporterD, "TotalLootValue"), GetLocalInt(oTransporterD, "MaxItemValue"));
		
		}
		}
		
		if(GetLocalString(OBJECT_SELF,"SpawnNameE") != "") { 
		
		object oWaypointE = GetWaypointByTag(GetLocalString(OBJECT_SELF,"SpawnWaypointE"));
		object oTransporterE = CreateObject(GetLocalInt(OBJECT_SELF,"ObjectType"), GetLocalString(OBJECT_SELF,"SpawnNameE"), GetLocation(oWaypointE));
		SetLocalObject(OBJECT_SELF, GetLocalString(OBJECT_SELF,"SpawnWaypointE"), oTransporterE);
		if (GetLocalInt(OBJECT_SELF,"ObjectType") == 64){ 
		ACR_GenerateLoot(oTransporterE, GetLocalInt(oTransporterE, "TotalLootValue"), GetLocalInt(oTransporterE, "MaxItemValue"));
		
		}
		}
		
		// Loop through party members; assume that these people
		// would tell their friends.
		
		object oAdvancing = GetFirstFactionMember(oPC);
		while(GetIsObjectValid(oAdvancing))
		{
			int nState = ACR_RetrieveQuestState(GetLocalString(OBJECT_SELF,"QuestName"), oAdvancing);
			
			// Make sure that the PC has the quest, but check here so they can
			// get help from people who don't have the quest.
			// Also make sure that the PC hasn't advanced from this trigger already
			// and is in the same area s the one who scouted.
			if(nState < 10 &&
			   GetLocalInt(OBJECT_SELF, IntToString(ACR_GetCharacterID(oAdvancing))) == 0 &&
			   GetArea(oAdvancing) == GetArea(oPC))
			{
				nState = GetLocalInt(OBJECT_SELF,"NewQuestStage");

				SetLocalInt(OBJECT_SELF, IntToString(ACR_GetCharacterID(oAdvancing)), 1);					
				NotifyPlayer(oAdvancing, NOTIFY_TYPE_INFO,"Your learn something.", GetLocalString(OBJECT_SELF,"WhatTheyLearned"), NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
			
				if(GetLocalInt(OBJECT_SELF,"JournalUpdated") == 1)
			{			
			    	ACR_AddPersistentJournalQuestEntry(GetLocalString(OBJECT_SELF,"QuestName"), nState, oPC, FALSE, FALSE, FALSE, 0);
			}			
			}}
			oAdvancing = GetNextFactionMember(oPC);
		}
		
	SetLocalInt(OBJECT_SELF, IntToString(ACR_GetCharacterID(oPC)), 1);
	return;
}