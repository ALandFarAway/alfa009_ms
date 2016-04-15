////////////////////////////////////////////////////////////////////////////////
//
//  System Name : ACR Configuration File
//     Filename : acf_area_onenter.nss
//      Version : 0.1
//         Date : 7/25/06
//       Author : Ronan
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
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Includes ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////////
// Function Definitions ////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


void LightsOff(int X, int Y)
{
	object oLight = GetObjectByTag(PUZZLE_TAG + IntToString(X) + IntToString(Y) + "LT");
	if(GetIsObjectValid(oLight)) DestroyObject(oLight);
	DeleteLocalInt(GetArea(OBJECT_SELF), PUZZLE_TAG + IntToString(X) + IntToString(Y));
}

void LightsOn(int X, int Y)
{
	SetLocalInt(GetArea(OBJECT_SELF), PUZZLE_TAG + IntToString(X) + IntToString(Y), 1);
	CreateObject(OBJECT_TYPE_PLACED_EFFECT, "fx_death_god_light_red", GetLocation(GetObjectByTag(PUZZLE_TAG + IntToString(X) + IntToString(Y))), TRUE, PUZZLE_TAG + IntToString(X) + IntToString(Y) + "LT");
}

void Toggle(int X, int Y)
{
	if(GetLocalInt(GetArea(OBJECT_SELF), PUZZLE_TAG + IntToString(X) + IntToString(Y)))
	{
		LightsOff(X, Y);	
	}
	else
	{
		LightsOn(X, Y);
	}
}

int IsPuzzleDone(int maxX, int maxY)
{
	int X = 0;
	while(X <= maxX)
	{
		int Y = 0;
		while(Y <= maxY)
		{
			if(!GetLocalInt(GetArea(OBJECT_SELF), PUZZLE_TAG + IntToString(X) + IntToString(Y)))
				return FALSE;
			Y++;
		}
		X++;
	}
	return TRUE;
}

void main() 
{
	int X = GetLocalInt(OBJECT_SELF, PUZZLE_LOC_X);
	int Y = GetLocalInt(OBJECT_SELF, PUZZLE_LOC_Y);
	int maxX = GetLocalInt(OBJECT_SELF, PUZZLE_MAX_X);
	int maxY = GetLocalInt(OBJECT_SELF, PUZZLE_MAX_Y);
	
	Toggle(X, Y);
	if(X > 0)
	{
		Toggle(X-1, Y);
	}
	if(X < maxX)
	{
		Toggle(X+1, Y);
	}
	if(Y > 0)
	{
		Toggle(X, Y-1);
	}
	if(Y < maxY)
	{
		Toggle(X, Y+1);
	}
	if(IsPuzzleDone(maxX, maxY)) 
	{
		object oDoor = GetObjectByTag("ST_4A_PUZ_DOOR");
		SetLocked(oDoor, FALSE);
		AssignCommand(oDoor, ActionOpenDoor(oDoor));
	}
}