////////////////////////////////////////////////////////////////////////////////
//
//  System Name : ACR Configuration File
//     Filename : acf_trg_onenter.nss
//    $Revision:: 236        $ current version of the file
//        $Date:: 2007-01-21#$ date the file was created or modified
//       Author : Cipher
//
//    Var Prefix:
//  Dependencies:
//
//  Description
//  This script calls the ACR's OnEnter code for triggers, and any
//  custom code a server may need. It is not updated in ACR updates.
//
//  Revision History
//  2007/01/20  Cipher  Inception
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Includes ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
#include "acr_trigger_i"
#include "acr_quest_i"
#include "acr_spawn_i"



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

////////////////////////////////////////////////////////////////////////////////
// Function Definitions ////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void ACR_ApplyNLDDamageToCreature(object oTarget, int nSubdualDamage)
{
    int nNLDTotal = _GetNLDTotal(oTarget);
    int nHPMax = GetMaxHitPoints(oTarget);
    int nCap = nHPMax + 10;
    nNLDTotal = ((nNLDTotal + nSubdualDamage) > nCap) ? nCap :
            nNLDTotal + nSubdualDamage;
    _SetNLDTotal(oTarget, nNLDTotal);
    ACR_ApplyNLDEffects(oTarget, nNLDTotal);
}

void main()
{
    ACR_TriggerOnEnter();

    // Custom code goes here.
	object oPC = OBJECT_SELF;
	int nRepHeat = GetLocalInt(oPC, "nRepHeat");
	float fTimeLoop = 91.0;
			
if((GetLocalInt(oPC, "HeatLoop") == 1) && (nRepHeat < 100)  && (oPC != OBJECT_INVALID)) {
//SendMessageToPC(oPC, "HeatLoop");
	
	if(GetIsPC(oPC))
		{
	
		if(GetSkillRank(SKILL_SURVIVAL, oPC, FALSE)> 0)
			{SetLocalInt(oPC, "Survival", 4);
			 if(nRepHeat == 0) {SendMessageToPC(oPC, "Your ability to survive keeps you from succumbing to the worst of the heat.");
				}
			}
		if((!GetHasSpellEffect(SPELL_ENDURE_ELEMENTS, oPC)) && (!GetHasSpellEffect(SPELL_RESIST_ENERGY, OBJECT_SELF))&& (!GetHasSpellEffect(SPELL_PROTECTION_FROM_ENERGY, OBJECT_SELF))&& (!GetHasSpellEffect(SPELL_ENERGY_IMMUNITY_FIRE, OBJECT_SELF)))
			{int nSurvival = GetLocalInt(oPC, "Survival");
			 int nDC = 15 + nRepHeat - nSurvival;
			 if(nRepHeat > 0) {
			 if(!FortitudeSave(oPC, nDC, SAVING_THROW_TYPE_FIRE, oPC))
				{ACR_ApplyNLDDamageToCreature(oPC, d6());
				 ACR_NLD_ReportTotal(oPC, oPC, 0);
				 SendMessageToPC(oPC, "The burning heat takes its toll!");
				 }
				}
			}
			else if((GetHasSpellEffect(SPELL_ENDURE_ELEMENTS, oPC)) || (GetHasSpellEffect(SPELL_RESIST_ENERGY, OBJECT_SELF))|| (GetHasSpellEffect(SPELL_PROTECTION_FROM_ENERGY, OBJECT_SELF))|| (!GetHasSpellEffect(SPELL_ENERGY_IMMUNITY_FIRE, OBJECT_SELF)))
				{SendMessageToPC(oPC, "You feel your elemental protection spell keeping the worst of the heat at bay.");
				}
					
			SetLocalInt(oPC, "Survival", 0);
			nRepHeat++;
			SetLocalInt(oPC, "nRepHeat", nRepHeat);
			DelayCommand(fTimeLoop, ExecuteScript("tsm_trg_onloop_heat", oPC));
					 
		}
	}
}