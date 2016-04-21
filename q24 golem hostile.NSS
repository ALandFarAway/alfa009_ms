#include "ginc_param_const"
#include "nw_i0_generic"
#include "acr_creature_i"
#include "acr_trigger_i"

void main()

{
//ACR_TriggerOnEnter();
	object oTarget = GetObjectByTag("009_cr_q24_golem");
	
	//Make golem attack
	ChangeToStandardFaction(oTarget, STANDARD_FACTION_HOSTILE);
	}