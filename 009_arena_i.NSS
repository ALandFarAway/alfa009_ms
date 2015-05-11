#include "acr_nonlethal_i"
#include "acr_creature_i"
#include "acr_notifications_i"

void _resetRep(object oPC);
void _heartBeat(object oPC, int startingHitPoints);

void ScrubTeams();
void Push(string array, object creature);
void Remove(string array, object creature);
void StopFight(object oStopped);

int GetIsInAoE(object oCreature, object oAoE);
int CheckTeams();
int CheckAllReady();

void StopFight(object oStopped)
{
	AssignCommand(oStopped, ClearAllActions());
	_resetRep(oStopped);
	if(!GetIsPC(oStopped)) ChangeToStandardFaction(oStopped, STANDARD_FACTION_DEFENDER);
}

void _resetRep(object oPC)
{
	object oContents = GetFirstObjectInArea(GetArea(OBJECT_SELF));
	while(GetIsObjectValid(oContents))
	{
		if(GetObjectType(oContents) == OBJECT_TYPE_CREATURE)
		{
			ClearPersonalReputation(oPC, oContents);
			ClearPersonalReputation(oContents, oPC);
		}
		oContents = GetNextObjectInArea(GetArea(OBJECT_SELF));
	}
	object oBluePig = GetObjectByTag("PIG_FACTION_BLUE");
	object oRedPig = GetObjectByTag("PIG_FACTION_RED");
	AdjustReputation(oPC, oBluePig, 50-GetReputation(oPC, oBluePig));
	AdjustReputation(oPC, oRedPig, 50-GetReputation(oPC, oRedPig));
	
	SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 50, oPC);
	SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 50, oPC);
	SetStandardFactionReputation(STANDARD_FACTION_HOSTILE, 50, oPC);
	SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 50, oPC);
}

void _heartBeat(object oPC, int startingHitPoints)
{
	int bContinue = 0;
	object oContents = GetFirstInPersistentObject();
	while(GetIsObjectValid(oContents))
	{
		if(oContents == oPC) bContinue = 1;
		oContents = GetNextInPersistentObject();
	}
	if(!bContinue) 
	{
		StopFight(oPC);
		Remove(GetLocalString(oPC, "ARENA_TEAM"), oPC);
		DeleteLocalString(oPC, "ARENA_TEAM");
		return;
	}
	
	int hp = GetCurrentHitPoints(oPC);
	if(startingHitPoints > hp)
	{
		int heal = startingHitPoints - hp;
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(heal), oPC);
		ACR_ApplyNonlethalDamageToCreature(oPC, heal);
	}
	DelayCommand(6.0f, _heartBeat(oPC, startingHitPoints));
}

void Push(string array, object creature)
{
	int count = 0;
	object oFound = GetLocalObject(GetArea(OBJECT_SELF), array + IntToString(count));
	while(GetIsObjectValid(oFound))
	{
		count++;
		oFound = GetLocalObject(GetArea(OBJECT_SELF), array + IntToString(count));
	}
	
	SetLocalObject(GetArea(OBJECT_SELF), array + IntToString(count), creature);
}

void Remove(string array, object creature)
{
	int count = 0;
	object oFound = GetLocalObject(GetArea(OBJECT_SELF), array + IntToString(count));
	while(GetIsObjectValid(oFound))
	{
		if(oFound == creature)
		{
			SetLocalObject(GetArea(OBJECT_SELF), array + IntToString(count), OBJECT_INVALID);
			ScrubTeams();
			return;
		}
		count++;
		oFound = GetLocalObject(GetArea(OBJECT_SELF), array + IntToString(count));
	}
}

int GetIsInAoE(object oCreature, object oAoE)
{
	object oContents = GetFirstInPersistentObject(oAoE);
	while(GetIsObjectValid(oContents))
	{
		if(oContents == oCreature) return TRUE;
		oContents = GetNextInPersistentObject(oAoE);
	}
	return FALSE;
}

void ScrubTeams()
{
	int readCount = 0;
	int redCount = 0;
	int blueCount = 0;
	
	object oArena = GetLocalObject(OBJECT_SELF, "CENTER");
	if(!GetIsObjectValid(oArena))
	{
		SendMessageToPC(GetLocalObject(GetArea(OBJECT_SELF), "MC"), "Error: Arena AoEs have not saved the arena boundaries.");
		return;
	}
	while(readCount < 31)
	{
		object oRed = GetLocalObject(GetArea(OBJECT_SELF), "RED"+IntToString(readCount));
    object oBlue = GetLocalObject(GetArea(OBJECT_SELF), "BLUE"+IntToString(readCount));
		if(!GetIsObjectValid(oRed))
		{
			readCount++;
		}
		else if(!GetIsInAoE(oRed, oArena))
		{
			readCount++;
		}
		else
		{
			SetLocalObject(GetArea(OBJECT_SELF), "RED"+IntToString(redCount), oRed);
			redCount++;
			readCount++;
		}
		
		if(GetIsObjectValid(oBlue) && GetIsInAoE(oBlue, oArena))
		{
			SetLocalObject(GetArea(OBJECT_SELF), "BLUE"+IntToString(blueCount), oBlue);
			blueCount++;
		}
	}
	SetLocalObject(GetArea(OBJECT_SELF), "BLUE"+IntToString(blueCount), OBJECT_INVALID);
	SetLocalObject(GetArea(OBJECT_SELF), "RED"+IntToString(redCount), OBJECT_INVALID);
}

int CheckTeams()
{
	ScrubTeams();
	if(!GetIsObjectValid(GetLocalObject(GetArea(OBJECT_SELF), "RED0"))) return FALSE;
	if(!GetIsObjectValid(GetLocalObject(GetArea(OBJECT_SELF), "BLUE0"))) return FALSE;
	return TRUE;
}

int CheckAllReady()
{
	if(CheckTeams() && GetIsObjectValid(GetLocalObject(GetArea(OBJECT_SELF), "MC")))
		return TRUE;
	return FALSE;
}
