// Put this script OnClick of a placeable.




//#include "nwnx_objectattributes_include"
#include "acr_vanity_i"


void OnActivate(object oEventItem, object oActTarget, location lActTarget, object oActivator) {
    object oPC = GetItemActivator();
	
    XPObjectAttributesSetSubRace(oActivator, RACIAL_SUBTYPE_HALFORC);
	 // Get the creature who triggered this event.
    

    // Change how the PC looks.
    SetCreatureAppearanceType(oActivator, APPEARANCE_TYPE_HALF_ORC);
	SetCreatureAppearanceType(oActivator, iAppearanceNumber(5));
	// Set the PC's subrace.
    SetSubRace(oActivator, "HALF-ORC");
}



