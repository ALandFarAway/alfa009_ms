/*   Script generated by
Lilac Soul's NWN Script Generator, v. 2.3

For download info, please visit:
http://nwvault.ign.com/View.php?view=Other.Detail&id=4683&id=625    */

#include "acr_trigger_i"
#include "acr_skills_i"
#include "acr_hazards_i"
#include "acr_movement_i"


//Put this script OnEnter
void main()
{
ACR_TriggerOnEnter();

    EnterWater(OBJECT_SELF, GetEnteringObject());
	
object oPC = GetEnteringObject();

if (!GetIsPC(oPC)) return;

object oTarget;
oTarget = oPC;

effect eEffect;
eEffect = EffectMovementSpeedDecrease(85);

eEffect = SupernaturalEffect(eEffect);

ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oTarget);

FloatingTextStringOnCreature("You must work very hard to move through the goo ", oPC);

}