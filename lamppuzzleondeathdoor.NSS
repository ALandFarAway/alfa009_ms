#include "x2_inc_compon"
#include "acr_door_i"

void main()
{
    craft_drop_placeable();
	effect eDoorExplode = EffectNWN2SpecialEffectFile( "fx_wooden_explosion_big");
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eDoorExplode, OBJECT_SELF);
}