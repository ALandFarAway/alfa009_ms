#include "009_arena_i"
#include "acr_creature_i"

void ForceSparring(object oNPC)
{
	if(GetIsPC(oNPC)) return;
	DeleteLocalString(oNPC, "ACR_CREATURE_BEHAVIOR");
	if(!_GetNLDMode(oNPC))
	{
		ACR_ToggleNLDMode(oNPC);
	}
}

void main() 
{
	if(CheckAllReady())
	{
		int nRedCount = 0;
		object oRed = GetLocalObject(GetArea(OBJECT_SELF), "RED"+IntToString(nRedCount));
		while(GetIsObjectValid(oRed))
		{
			ForceSparring(oRed);
			nRedCount++;
			oRed = GetLocalObject(GetArea(OBJECT_SELF), "RED"+IntToString(nRedCount));
		}
		int nBlueCount = 0;
		object oBlue = GetLocalObject(GetArea(OBJECT_SELF), "BLUE"+IntToString(nBlueCount));
		while(GetIsObjectValid(oBlue))
		{
			ForceSparring(oBlue);
			nBlueCount++;
			oBlue = GetLocalObject(GetArea(OBJECT_SELF), "BLUE"+IntToString(nBlueCount));
		}
		
		object oBluePig = GetObjectByTag("PIG_FACTION_BLUE");
		object oRedPig = GetObjectByTag("PIG_FACTION_RED");
		
		nRedCount = 0;
		oRed = GetLocalObject(GetArea(OBJECT_SELF), "RED"+IntToString(nRedCount));
		while(GetIsObjectValid(oRed))
		{
			if(GetIsPC(oRed))
			{
				AdjustReputation(oRed, oBluePig, -100);
			}
			else
			{
				ChangeFaction(oRed, oRedPig);
			}
			nRedCount++;
			oRed = GetLocalObject(GetArea(OBJECT_SELF), "RED"+IntToString(nRedCount));
		}
		nBlueCount = 0;
		oBlue = GetLocalObject(GetArea(OBJECT_SELF), "BLUE"+IntToString(nBlueCount));
		while(GetIsObjectValid(oBlue))
		{
			if(GetIsPC(oBlue))
			{
				AdjustReputation(oBlue, oRedPig, -100);
			}
			else
			{
				ChangeFaction(oBlue, oBluePig);
			}
			nBlueCount++;
			oBlue = GetLocalObject(GetArea(OBJECT_SELF), "BLUE"+IntToString(nBlueCount));
		}
		NotifyPlayer(OBJECT_SELF, NOTIFY_TYPE_TIP, "Match can be stopped", "The match has begun! Is it time to stop?", NOTIFY_WINDOW_MESSAGE_BOX, "gui_arena_stop", "gui_arena_cancel", "Stop!", "Not yet!");
	}
	else
	{
		SendMessageToPC(OBJECT_SELF, "Teams are not ready. Step off of and into the MC's position to prompt again.");
	}
}