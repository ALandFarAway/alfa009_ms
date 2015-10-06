//
//  Turn Lights On Off
//  puk_lights
//  By:Puket
//  01/13/07
//  give me credit
//
//
//	2/28/07 modified by Lochlainn
//	Turns on and off the streetlamp in the erf
//	It does this by removing and replacing the "on" and "off" mdb's
//
//  Place this on the OnUsed Event of a Torch/Candle/Streetlamp etc. for Light and FX
//
////////////////////////////////////////////////////////////////////////////




int iLightEffect;
object oNearest;
object oCaller=GetLastUsedBy();
object oSelf = OBJECT_SELF;
int iNumberOfFlames;
location lMyLoc;

void main()
{

	iLightEffect=VFX_DUR_LIGHT_ORANGE_20;
		
	//if not currently on
    if (GetLocalInt(OBJECT_SELF,"NW_L_AMION") == 0)
    {
		SendMessageToPC(oCaller,"You light the flame.");

		//remove the "off" placeable and put in the "on" one
		lMyLoc=GetLocation(oSelf);
		object oNewLamp=CreateObject(OBJECT_TYPE_PLACEABLE,"useable_lamp_post_on",lMyLoc);
		DestroyObject(oSelf);
		oSelf=oNewLamp;
				
	    //turn on light from the placeable and play animation if any
		PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
      	DelayCommand(0.4,SetPlaceableIllumination(oSelf, TRUE));
      	SetLocalInt(oSelf ,"NW_L_AMION",1);
      	DelayCommand(0.5,RecomputeStaticLighting(GetArea(oSelf)));
			
		//apply lighting
		effect eLight=EffectVisualEffect(iLightEffect);
      	ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLight, oSelf);
	  	

    }
    else
    {
		SendMessageToPC(oCaller,"You extinguish the flame.");
		//turn off lights

		//remove the "on" placeable and put in the "off" one
		lMyLoc=GetLocation(oSelf);
		object oNewLamp=CreateObject(OBJECT_TYPE_PLACEABLE,"useable_lamp_post_off",lMyLoc);
		DestroyObject(oSelf);
		oSelf=oNewLamp;

		
	  	PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE);
		
		//deactivate light
      	DelayCommand(0.2,SetPlaceableIllumination(oSelf, FALSE));
		
		//set local variable to off
      	SetLocalInt(oSelf ,"NW_L_AMION",0);

		DelayCommand(0.3,RecomputeStaticLighting(GetArea(oSelf)));
	  	effect eEffect = GetFirstEffect(oSelf);
		while (GetIsEffectValid(eEffect) == TRUE)
			{
   	     	if (GetEffectType(eEffect) == EFFECT_TYPE_VISUALEFFECT) RemoveEffect(oSelf, eEffect);
        	eEffect = GetNextEffect(oSelf);
			}
	}
}
		
				