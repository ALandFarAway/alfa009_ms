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

#include "acr_area_i"
//#include "acr_time_i"

////////////////////////////////////////////////////////////////////////////////
// Constants ///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////////
// Function Definitions ////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void main() 
{
    ACR_AreaOnEnter();
	
//	SendMessageToAllDMs(GetName(GetEnteringObject())+" is entering area "+GetName(OBJECT_SELF)+" at time "+IntToString(GetTimeSecond()));
    // Custom code goes below this line.
	if(!GetLocalInt(OBJECT_SELF, "INITIALIZED"))
	{
		object oContents = GetFirstObjectInArea(OBJECT_SELF);
		object oCenter = OBJECT_INVALID;
		object oRedCorner = OBJECT_INVALID;
		object oBlueCorner = OBJECT_INVALID;
		object oMC = OBJECT_INVALID;
		while(GetIsObjectValid(oContents))
		{
			if(GetTag(oContents) == "ARENA_CENTER")
			{
				oCenter = oContents;
			}
			else if(GetTag(oContents) == "ARENA_BLUE")
			{
				oBlueCorner = oContents;
			}
			else if(GetTag(oContents) == "ARENA_RED")
			{
				oRedCorner = oContents;
			}
			else if(GetTag(oContents) == "ARENA_MC")
			{
				oMC = oContents;
			}
			oContents = GetNextObjectInArea(OBJECT_SELF);
		}
		if(GetIsObjectValid(oCenter) &&
		   GetIsObjectValid(oBlueCorner) &&
		   GetIsObjectValid(oRedCorner) &&
		   GetIsObjectValid(oMC))
		{
			vector vCenter = GetPosition(oCenter);
			vector vBlue = GetPosition(oBlueCorner);
			float fDist = fabs(vCenter.x - vBlue.x) + fabs(vCenter.y - vBlue.y);
			fDist = fDist/1.65;
			int AoEType = 81 + FloatToInt(fDist);
			if(AoEType > 120) AoEType = 120;
			if(AoEType < 81) AoEType = 81;
			ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectAreaOfEffect(AoEType, "009_aoe_arenaenter", "****", "****", "ARENA_CENTER_AOE")), GetLocation(oCenter));
			ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectAreaOfEffect(81, "009_aoe_arenaenter", "****", "****", "ARENA_RED_AOE")), GetLocation(oRedCorner));
			ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectAreaOfEffect(81, "009_aoe_arenaenter", "****", "****", "ARENA_BLUE_AOE")), GetLocation(oBlueCorner));
			ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectAreaOfEffect(81, "009_aoe_arenaenter", "****", "****", "ARENA_MC_AOE")), GetLocation(oMC));
			
			object oCenterAoE = OBJECT_INVALID;
			object oBlueAoE = OBJECT_INVALID;
			object oRedAoE = OBJECT_INVALID;
			object oMCAoE = OBJECT_INVALID;
			oContents = GetFirstObjectInArea(OBJECT_SELF);
			while(GetIsObjectValid(oContents))
			{
				if(GetTag(oContents) == "ARENA_CENTER_AOE")
				{
					oCenterAoE = oContents;
				}
				else if(GetTag(oContents) == "ARENA_RED_AOE")
				{
					oBlueAoE = oContents;
				}
				else if(GetTag(oContents) == "ARENA_BLUE_AOE")
				{
					oRedAoE = oContents;
				}
				else if(GetTag(oContents) == "ARENA_MC_AOE")
				{
					oMCAoE = oContents;
				}
				oContents = GetNextObjectInArea(OBJECT_SELF);
			}
			SetLocalObject(oCenterAoE, "RED", oRedAoE);
			SetLocalObject(oCenterAoE, "BLUE", oBlueAoE);
			SetLocalObject(oBlueAoE, "CENTER", oCenterAoE);
			SetLocalObject(oBlueAoE, "RED", oRedAoE);
			SetLocalObject(oRedAoE, "BLUE", oBlueAoE);
			SetLocalObject(oRedAoE, "CENTER", oCenterAoE);
			SetLocalObject(oMCAoE, "RED", oRedAoE);
			SetLocalObject(oMCAoE, "BLUE", oBlueAoE);
			SetLocalObject(oMCAoE, "CENTER", oCenterAoE);
		}
		SetLocalInt(OBJECT_SELF, "INITIALIZED", 1);
	}
}