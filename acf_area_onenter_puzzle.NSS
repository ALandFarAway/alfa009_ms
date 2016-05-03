////////////////////////////////////////////////////////////////////////////////
//
//  System Name : ACR Configuration File
//     Filename : acf_area_onenter.nss
//      Version : 0.1
//         Date : 7/25/06
//       Author : Zelknof
//
//  Local Variable Prefix =
//
//
//  Dependencies external of nwscript:
//
//  Description
//  This script calls the ACR's OnAreaEnter code, and any custom code a server
//  may need. It is not updated in ACR updates.
//
//  Revision History 
//  4/2016 aquired from BG mod to use on MS 
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Includes ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#include "acr_area_i"
#include "acr_hazards_i"
//#include "acr_time_i"

////////////////////////////////////////////////////////////////////////////////
// Constants ///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

string PUZZLE_INIT_VAR = "PUZZLE_INIT_VAR";
string PUZZLE_LOC_X = "PUZZLE_LOC_X";
string PUZZLE_LOC_Y = "PUZZLE_LOC_Y";
string PUZZLE_MAX_X = "PUZZLE_MAX_X";
string PUZZLE_MAX_Y = "PUZZLE_MAX_Y";
string PUZZLE_SAV_TAG = "PUZZLE_SAV_TAG";

string PUZZLE_TAG = "ST_4A_PUZ_";


string SHOOTER_TAG = "ST_4A_SHOT_";
string TARGET_TAG = "ST_4A_TARG_";

////////////////////////////////////////////////////////////////////////////////
// Structures //////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Global Variables ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Function Prototypes /////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

//! The main event handler.
void main();
void _Arrows_1();

////////////////////////////////////////////////////////////////////////////////
// Function Definitions ////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

int IsAreaOccupied(object oEnterer=OBJECT_INVALID)
{
	object oPC = GetFirstPC();
	while(GetIsObjectValid(oPC))
	{
		if(oPC != oEnterer && GetArea(oPC) == GetArea(oEnterer))
		{
			return TRUE;
		}
		oPC = GetNextPC();
	}
	return FALSE;
}

void _SpawnPuzzleTrigger(object visual, string puzzleTag, int X, int Y, int maxX, int maxY)
{
	string trigTag = puzzleTag + IntToString(X) + IntToString(Y);
	ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectAreaOfEffect(81, "light_puzzle1", "****", "****", trigTag)), GetLocation(visual));
	object oAoE = GetObjectByTag(trigTag);
	SetLocalInt(oAoE, PUZZLE_LOC_X, X);
	SetLocalInt(oAoE, PUZZLE_LOC_Y, Y);
	SetLocalInt(oAoE, PUZZLE_MAX_X, maxX);
	SetLocalInt(oAoE, PUZZLE_MAX_Y, maxY);
	SetLocalString(oAoE, PUZZLE_SAV_TAG, puzzleTag);
}

void InitializePuzzle()
{
	if(!GetLocalInt(OBJECT_SELF, PUZZLE_INIT_VAR))
	{
		object puz00 = GetObjectByTag("ST_4A_PUZ_NW");
		_SpawnPuzzleTrigger(puz00, PUZZLE_TAG, 0, 0, 2, 2);
		object puz01 = GetObjectByTag("ST_4A_PUZ_N");
		_SpawnPuzzleTrigger(puz01, PUZZLE_TAG, 0, 1, 2, 2);
		object puz02 = GetObjectByTag("ST_4A_PUZ_NE");
		_SpawnPuzzleTrigger(puz02, PUZZLE_TAG, 0, 2, 2, 2);
		object puz10 = GetObjectByTag("ST_4A_PUZ_W");
		_SpawnPuzzleTrigger(puz10, PUZZLE_TAG, 1, 0, 2, 2);
		object puz11 = GetObjectByTag("ST_4A_PUZ_M");
		_SpawnPuzzleTrigger(puz11, PUZZLE_TAG, 1, 1, 2, 2);
		object puz12 = GetObjectByTag("ST_4A_PUZ_E");
		_SpawnPuzzleTrigger(puz12, PUZZLE_TAG, 1, 2, 2, 2);
		object puz20 = GetObjectByTag("ST_4A_PUZ_SW");
		_SpawnPuzzleTrigger(puz20, PUZZLE_TAG, 2, 0, 2, 2);
		object puz21 = GetObjectByTag("ST_4A_PUZ_S");
		_SpawnPuzzleTrigger(puz21, PUZZLE_TAG, 2, 1, 2, 2);
		object puz22 = GetObjectByTag("ST_4A_PUZ_SE");
		_SpawnPuzzleTrigger(puz22, PUZZLE_TAG, 2, 2, 2, 2);
		SetLocalInt(OBJECT_SELF, PUZZLE_INIT_VAR, 1);
	}
	else
	{
		object oLight = GetObjectByTag(PUZZLE_TAG + "00LT");
		if(GetIsObjectValid(oLight)) DestroyObject(oLight);
		oLight = GetObjectByTag(PUZZLE_TAG + "01LT");
		if(GetIsObjectValid(oLight)) DestroyObject(oLight);
		oLight = GetObjectByTag(PUZZLE_TAG + "02LT");
		if(GetIsObjectValid(oLight)) DestroyObject(oLight);
		oLight = GetObjectByTag(PUZZLE_TAG + "10LT");
		if(GetIsObjectValid(oLight)) DestroyObject(oLight);
		oLight = GetObjectByTag(PUZZLE_TAG + "11LT");
		if(GetIsObjectValid(oLight)) DestroyObject(oLight);
		oLight = GetObjectByTag(PUZZLE_TAG + "12LT");
		if(GetIsObjectValid(oLight)) DestroyObject(oLight);
		oLight = GetObjectByTag(PUZZLE_TAG + "20LT");
		if(GetIsObjectValid(oLight)) DestroyObject(oLight);
		oLight = GetObjectByTag(PUZZLE_TAG + "21LT");
		if(GetIsObjectValid(oLight)) DestroyObject(oLight);
		oLight = GetObjectByTag(PUZZLE_TAG + "22LT");
		if(GetIsObjectValid(oLight)) DestroyObject(oLight);
		
		DeleteLocalInt(OBJECT_SELF, PUZZLE_TAG + "00");
		DeleteLocalInt(OBJECT_SELF, PUZZLE_TAG + "01");
		DeleteLocalInt(OBJECT_SELF, PUZZLE_TAG + "02");
		DeleteLocalInt(OBJECT_SELF, PUZZLE_TAG + "10");
		DeleteLocalInt(OBJECT_SELF, PUZZLE_TAG + "11");
		DeleteLocalInt(OBJECT_SELF, PUZZLE_TAG + "12");
		DeleteLocalInt(OBJECT_SELF, PUZZLE_TAG + "20");
		DeleteLocalInt(OBJECT_SELF, PUZZLE_TAG + "21");
		DeleteLocalInt(OBJECT_SELF, PUZZLE_TAG + "22");
		
		object oDoor = GetObjectByTag("ST_4A_PUZ_DOOR");
		AssignCommand(oDoor, ActionCloseDoor(oDoor));
		SetLocked(oDoor, TRUE);
	}
}

object GetCreatureArrowTarget(object oTarget)
{
	object oArea = GetArea(oTarget);
	object oRetVal = OBJECT_INVALID;
	float fCurrentRetY = 0.0f;
	object oChecking = GetFirstObjectInArea();
	while(GetIsObjectValid(oChecking))
	{
		if(GetObjectType(oChecking) == OBJECT_TYPE_CREATURE)
		{
			vector vChkPos = GetPosition(oChecking);
			vector vTargPos = GetPosition(oTarget);
			if(fabs(vChkPos.x - vTargPos.x) < 9.25f)
		//	if(fabs(vChkPos.x - vTargPos.x) < 1.25f)
			{
				if(vChkPos.y >  3.50f && vChkPos.y >121.5f && vChkPos.y > fCurrentRetY)
			//	if(vChkPos.y > 12.0f && vChkPos.y <61.5f && vChkPos.y > fCurrentRetY)
				{
					oRetVal = oChecking;
				}
			}
		}
		oChecking = GetNextObjectInArea();
	}
	return oRetVal;
}

void _ShootArrows(int Row, int NumArrows)
{
	object oTarget = GetObjectByTag(TARGET_TAG + IntToString(Row));
	
	object oCreature = GetCreatureArrowTarget(oTarget);
	if(GetIsObjectValid(oCreature))
	{
		float fDelay = 0.0f;
		int deflectArrows = 0;
		while(NumArrows > 0)
		{
			int Roll = d20();
			if(deflectArrows == 0 && GetHasFeat(FEAT_DEFLECT_ARROWS, oCreature, TRUE) && ReflexSave(oCreature, 15))
			{
				float extraDelay = GetProjectileTravelTime(GetLocation(OBJECT_SELF), GetLocation(oCreature), PROJECTILE_PATH_TYPE_BALLISTIC_LAUNCHED);
				DelayCommand(fDelay, SpawnItemProjectile(OBJECT_SELF, oCreature, GetLocation(OBJECT_SELF), GetLocation(oCreature), BASE_ITEM_LIGHTCROSSBOW, PROJECTILE_PATH_TYPE_BALLISTIC_LAUNCHED, OVERRIDE_ATTACK_RESULT_PARRIED, DAMAGE_TYPE_PIERCING));
				DelayCommand(fDelay + extraDelay, SendMessageToPC(oCreature, " ** Deflect Arrows Deflected an Arrow ** "));
				deflectArrows = 1;
			}
			else if(Roll == 20 || Roll + 8 >= GetAC(oCreature))
			{
				float extraDelay = GetProjectileTravelTime(GetLocation(OBJECT_SELF), GetLocation(oCreature), PROJECTILE_PATH_TYPE_BALLISTIC_LAUNCHED);
				DelayCommand(fDelay, SpawnItemProjectile(OBJECT_SELF, oCreature, GetLocation(OBJECT_SELF), GetLocation(oCreature), BASE_ITEM_LIGHTCROSSBOW, PROJECTILE_PATH_TYPE_BALLISTIC_LAUNCHED, OVERRIDE_ATTACK_RESULT_HIT_SUCCESSFUL, DAMAGE_TYPE_PIERCING));
				DelayCommand(fDelay + extraDelay, SendMessageToPC(oCreature, "You are struck by an arrow!"));
				DelayCommand(fDelay + extraDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d8(1), DAMAGE_TYPE_PIERCING), oCreature));
			}
			else
			{
				float extraDelay = GetProjectileTravelTime(GetLocation(OBJECT_SELF), GetLocation(oCreature), PROJECTILE_PATH_TYPE_BALLISTIC_LAUNCHED);
				DelayCommand(fDelay, SpawnItemProjectile(OBJECT_SELF, oCreature, GetLocation(OBJECT_SELF), GetLocation(oCreature), BASE_ITEM_LIGHTCROSSBOW, PROJECTILE_PATH_TYPE_BALLISTIC_LAUNCHED, OVERRIDE_ATTACK_RESULT_MISS, DAMAGE_TYPE_PIERCING));
				DelayCommand(fDelay + extraDelay, SendMessageToPC(oCreature, "An arrow whizzes past you!"));
			}
			fDelay += 0.5f;
			NumArrows--;
		}
	}
	else
	{
		float fDelay = 0.0f;
		while(NumArrows > 0)
		{
			DelayCommand(fDelay, SpawnItemProjectile(OBJECT_SELF, oTarget, GetLocation(OBJECT_SELF), GetLocation(oTarget), BASE_ITEM_LIGHTCROSSBOW, PROJECTILE_PATH_TYPE_BALLISTIC_LAUNCHED, OVERRIDE_ATTACK_RESULT_HIT_SUCCESSFUL, DAMAGE_TYPE_PIERCING));
			fDelay += 0.5f;
			NumArrows--;
		}
	}
}

void _Arrows_8()
{
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "0"), _ShootArrows(0, 2));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "1"), _ShootArrows(1, 2));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "2"), _ShootArrows(2, 2));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "3"), _ShootArrows(3, 2));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "4"), _ShootArrows(4, 2));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "5"), _ShootArrows(5, 2));
	DelayCommand(4.0f, _Arrows_1());
}

void _Arrows_7()
{
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "2"), _ShootArrows(2, 5));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "3"), _ShootArrows(3, 5));
	DelayCommand(4.0f, _Arrows_8());
}

void _Arrows_6()
{
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "4"), _ShootArrows(4, 5));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "5"), _ShootArrows(5, 5));
	DelayCommand(4.0f, _Arrows_7());
}

void _Arrows_5()
{
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "0"), _ShootArrows(0, 5));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "1"), _ShootArrows(1, 5));
	DelayCommand(4.0f, _Arrows_6());
}

void _Arrows_4()
{
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "1"), _ShootArrows(1, 5));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "3"), _ShootArrows(3, 5));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "5"), _ShootArrows(5, 5));
	DelayCommand(4.0f, _Arrows_5());
}

void _Arrows_3()
{
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "0"), _ShootArrows(0, 5));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "2"), _ShootArrows(2, 5));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "4"), _ShootArrows(4, 5));	
	DelayCommand(4.0f, _Arrows_4());
}

void _Arrows_2()
{
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "1"), _ShootArrows(1, 5));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "3"), _ShootArrows(3, 5));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "5"), _ShootArrows(5, 5));
	DelayCommand(4.0f, _Arrows_3());
}

void _Arrows_1()
{
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "0"), _ShootArrows(0, 5));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "2"), _ShootArrows(2, 5));
	AssignCommand(GetObjectByTag(SHOOTER_TAG + "4"), _ShootArrows(4, 5));
	DelayCommand(4.0f, _Arrows_2());
}

void RunArrows()
{
	DelayCommand(4.0f, _Arrows_1());
}

void main() 
{
    ACR_AreaOnEnter();
	ACR_HazardousAreaOnEnter();
    // Custom code goes below this line.
	
	if(!GetLocalInt(OBJECT_SELF, "ARROWS_STARTED"))
	{
		RunArrows();
		SetLocalInt(OBJECT_SELF, "ARROWS_STARTED", 1);
	}
	if(!IsAreaOccupied(GetEnteringObject()))
	{
		InitializePuzzle();
	}
}