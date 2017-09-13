//Bealzebub 5/2/2010

//put onheartbeat or onperception

#include "ginc_misc"
#include "ginc_math"
#include "ginc_wp"

	void PlayCustomLoopingAnimation(object oObject, string sAnimationName)
	{
	PlayCustomAnimation(oObject, sAnimationName, 1);
	}

	void PlayCustomOneShotAnimation(object oObject, string sAnimationName)
	{
	PlayCustomAnimation(oObject, sAnimationName, 0);
	}


void main()
{


	
if (GetTag(OBJECT_SELF) == "drunk_npc")
	{
		int iAnim;
	int iRandom = d6(1);
	switch(iRandom)
	{
		case 1:
			iAnim = ANIMATION_FIREFORGET_CHUCKLE;
			break;
		case 2:
			iAnim = ANIMATION_FIREFORGET_DRINK;
			break;
		case 3:
			iAnim = ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD;
			break;
		case 4:
			iAnim = ANIMATION_LOOPING_PAUSE_DRUNK;
			break;
		case 5:
			iAnim = ANIMATION_LOOPING_PAUSE_TIRED;
			break;
		case 6:
			iAnim = ANIMATION_LOOPING_TALK_LAUGHING;
			break;
	}
	PlayAnimation(iAnim);
	return;
	}
	
if (GetTag(OBJECT_SELF) == "gutar_npc")
	{
	object oNpc = OBJECT_SELF;
	PlayCustomAnimation(oNpc, "playguitar", 1, 1.0);
	SetOrientOnDialog(oNpc, FALSE);	
	return;
	}
	
if (GetTag(OBJECT_SELF) == "prone_npc")
	{
	object oNpc = OBJECT_SELF;
	PlayCustomAnimation(oNpc, "proneB", 1, 1.0);
	SetOrientOnDialog(oNpc, FALSE);	
	return;
	}

if (GetTag(OBJECT_SELF) == "sitidle_npc")
	{
	object oNpc = OBJECT_SELF;
	PlayCustomAnimation(oNpc, "sitidle", 1, 1.0);
	SetOrientOnDialog(oNpc, FALSE);	
	return;
	}

	if (GetTag(OBJECT_SELF) == "wander_npc")
	{
	ActionRandomWalk();
	return;
	}
	

if (GetTag(OBJECT_SELF) == "sitdrink_npc1")
	{
	{
	if (GetAILevel(OBJECT_SELF) == AI_LEVEL_VERY_LOW)
	{
	return;
	}
	object oActor = OBJECT_SELF;	
	if (GetLocalInt(oActor, "SetDefaultAnimation") == 0)
	{
		AssignCommand(oActor, PlayCustomLoopingAnimation(oActor, "sitidle"));
		SetLocalInt(oActor, "SetDefaultAnimation", 1);
		
	}	
	int nRandom = RandomIntBetween(1, 9);
	switch(nRandom)
	{
		case 1:
			PlayCustomLoopingAnimation(oActor, "sitdrink");
			break;
		case 2:
			PlayCustomLoopingAnimation(oActor, "sittalk01");
			break;
		case 3:
			PlayCustomLoopingAnimation(oActor, "sittalk02");
			break;
		case 4:
			PlayCustomLoopingAnimation(oActor, "sitfidget");
			break;
		case 5:
			PlayCustomLoopingAnimation(oActor, "sitdrinkidle");
			break;
		case 6:
		case 7:
		case 8:
	}
	}
	return;
	}
	
if (GetTag(OBJECT_SELF) == "sitdrink_npc2")
	{
	{
	if (GetAILevel(OBJECT_SELF) == AI_LEVEL_VERY_LOW)
	{
	return;
	}
	object oActor = OBJECT_SELF;	
	if (GetLocalInt(oActor, "SetDefaultAnimation") == 0)
	{
		AssignCommand(oActor, PlayCustomLoopingAnimation(oActor, "sitidle"));
		SetLocalInt(oActor, "SetDefaultAnimation", 1);
		ActionMoveToObject(GetNearestObjectByTag("sitter_wp2"));
	}	
	int nRandom = RandomIntBetween(1, 9);
	switch(nRandom)
	{
		case 1:
			PlayCustomLoopingAnimation(oActor, "sitdrink");
			break;
		case 2:
			PlayCustomLoopingAnimation(oActor, "sittalk01");
			break;
		case 3:
			PlayCustomLoopingAnimation(oActor, "sittalk02");
			break;
		case 4:
			PlayCustomLoopingAnimation(oActor, "sitfidget");
			break;
		case 5:
			PlayCustomLoopingAnimation(oActor, "sitdrinkidle");
			break;
		case 6:
		case 7:
		case 8:
	}
	}
	return;
	}
	
if (GetTag(OBJECT_SELF) == "cook01_npc")
	{
	object oNpc = OBJECT_SELF;
	PlayCustomAnimation(oNpc, "cooking01", 1, 1.0);
	SetOrientOnDialog(oNpc, FALSE);	
	ActionMoveToObject(GetNearestObjectByTag("cook_wp1"));
	return;
	}
	
if (GetTag(OBJECT_SELF) == "sitgroundidle_npc")
	{
	object oNpc = OBJECT_SELF;
	PlayCustomAnimation(oNpc, "sitgroundidle", 1, 1.0);
	SetOrientOnDialog(oNpc, FALSE);	
	return;
	}
	
if (GetTag(OBJECT_SELF) == "forge01_npc")
	{
	object oNpc = OBJECT_SELF;
	PlayCustomAnimation(oNpc, "forge01", 1, 1.0);
	SetOrientOnDialog(oNpc, FALSE);	
	return;
	}
	
if (GetTag(OBJECT_SELF) == "dance01_npc")
	{
	object oNpc = OBJECT_SELF;
	PlayCustomAnimation(oNpc, "dance01", 1, 1.0);
	SetOrientOnDialog(oNpc, FALSE);	
	return;
	}
	
if (GetTag(OBJECT_SELF) == "dance02_npc")
	{
	object oNpc = OBJECT_SELF;
	PlayCustomAnimation(oNpc, "dance02", 1, 1.0);
	SetOrientOnDialog(oNpc, FALSE);	
	return;
	}
	
if (GetTag(OBJECT_SELF) == "chuckle_npc")
	{
	object oNpc = OBJECT_SELF;
	PlayCustomAnimation(oNpc, "CHUCKLE", 1, 1.0);
	SetOrientOnDialog(oNpc, FALSE);	
	return;
	}
	


}