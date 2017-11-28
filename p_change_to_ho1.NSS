// Put this script OnClick of a placeable.

//#include "nwnx_objectattributes_include"
#include "acr_vanity_i"

void main()
{
    // Get the creature who triggered this event.
    object oPC = GetLastUsedBy();

    // Change how the PC looks.
	XPObjectAttributesSetRace(oPC, RACIAL_TYPE_HALFORC);
    XPObjectAttributesSetSubRace(oPC, RACIAL_SUBTYPE_HALFORC);
	
	//SetCreatureAppearanceType(oPC, APPEARANCE_TYPE_HALF_ORC);
	SetCreatureAppearanceType(oPC,5); // appearance.2da-line
	FeatRemove (oPC,FEAT_QUICK_TO_MASTER);
	FeatAdd (oPC,FEAT_DARKVISION,1,1,1);
  
}

