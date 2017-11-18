//item activation script to apply a permanent see invisibility to player






#include "acr_spells_i"


void OnActivate(object oEventItem, object oActTarget, location lActTarget, object oActivator)
{
    effect eEffect;
    object oPC = oActivator;

    // This item must target a PC.
    if ( !GetIsPC(OBJECT_SELF) )
    {
        SendMessageToPC(oActivator, "Improper use of this item!");
        return;
    }

    // Apply an effect.
    eEffect = EffectSeeInvisible();
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oActivator);
	
	

    // Remove all effects of a specified type.
    RemoveSpecificEffect(EFFECT_TYPE_SEEINVISIBLE, oActTarget);

    // Destroy objects (not fully effective until this script ends).
    DestroyObject(oEventItem);
    DestroyObject(GetObjectByTag("009_perm_seeinvis"));
}
