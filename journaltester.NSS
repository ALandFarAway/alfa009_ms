//Wynna April 2015


#include "acr_trigger_i"
#include "acr_spawn_i"
#include "acr_tools_i"
#include "acr_quest_i"

void main()
{	
	ACR_TriggerOnEnter();
	object oPC = GetEnteringObject();
     	
	if(ACR_RetrieveQuestState("009_gc_finlay_msg", GetEnteringObject()) == 0)
		{ACR_AddPersistentJournalQuestEntry("009_gc_finlay_msg", 1, GetEnteringObject(), FALSE, FALSE, FALSE, FALSE);}

	if(ACR_RetrieveQuestState("009_gc_finlay_msg", GetEnteringObject()) == 1)
		{ACR_AddPersistentJournalQuestEntry("009_gc_finlay_msg", 2, GetEnteringObject(), FALSE, FALSE, FALSE, FALSE);}

	if(ACR_RetrieveQuestState("009_gc_finlay_msg", GetEnteringObject()) == 2)
		{ACR_AddPersistentJournalQuestEntry("009_gc_finlay_msg", 3, GetEnteringObject(), FALSE, FALSE, FALSE, FALSE);}

	if(ACR_RetrieveQuestState("009_gc_finlay_msg", GetEnteringObject()) == 3)
		{ACR_AddPersistentJournalQuestEntry("009_gc_finlay_msg", 0, GetEnteringObject(), FALSE, FALSE, FALSE, FALSE);}
	
}