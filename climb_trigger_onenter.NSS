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

void main()
{
    ACR_TriggerOnEnter();

    // Custom code goes here.
	
	
	if(GetTag(OBJECT_SELF) == "climb_trigger")
	{SendMessageToPC(GetEnteringObject(), "rough handholds offer treacherous purchase.");
		if(ReflexSave(GetEnteringObject(), 15, SAVING_THROW_TYPE_NONE, GetAreaOfEffectCreator()) > 0)
			{SendMessageToPC(GetEnteringObject(), "You climb safely.");
			}
		else{SendMessageToPC(GetEnteringObject(), "You slip, injuring yourself!");
			effect eSlip = EffectDamage(d4(1), DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL, FALSE);
			ApplyEffectToObject(DURATION_TYPE_INSTANT, eSlip, GetEnteringObject());
			}
	}
	}