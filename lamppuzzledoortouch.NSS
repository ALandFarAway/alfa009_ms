
#include "acr_door_i"


void main()
{
	object oSelf = OBJECT_SELF;
	object oPC = GetLastUsedBy();
	int GetPCHealth = GetCurrentHitPoints(oPC);
	int GetDeductedHealth = GetPCHealth/20;
	
	if(GetLocalInt(oSelf, "TorchDoorTrapped") != 1)
	{
		//Set off trap
		SetLocalInt(oSelf, "TorchDoorTrapped", 1);
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetDeductedHealth, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_NORMAL, TRUE), oPC, 0.0f);
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectKnockdown(), oPC, 3.0f);
		
		//Set to Blood To Water Spell Visual Effect from visualeffects.2da
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(1021), oPC);
		
			string sLamp1 = "puzzlelamp1";
			object oLamp1 = GetObjectByTag(sLamp1);	
			string sLamp2 = "puzzlelamp2";
			object oLamp2 = GetObjectByTag(sLamp2);
			string sLamp3 = "puzzlelamp3";
			object oLamp3 = GetObjectByTag(sLamp3);
			string sLamp4 = "puzzlelamp4";
			object oLamp4 = GetObjectByTag(sLamp4);
			string sLamp5 = "puzzlelamp5";
			object oLamp5 = GetObjectByTag(sLamp5);
			string sLamp6 = "puzzlelamp6";
			object oLamp6 = GetObjectByTag(sLamp6);	
			
					SetUseableFlag(oLamp1, 0);
					SetUseableFlag(oLamp2, 0);
					SetUseableFlag(oLamp3, 0);
					SetUseableFlag(oLamp4, 0);
					SetUseableFlag(oLamp5, 0);
					SetUseableFlag(oLamp6, 0);
	}
	else
	{
		//Trap Already Set Off
	}
}