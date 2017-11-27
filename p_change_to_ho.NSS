// Put this script OnClick of a placeable.




#include "nwnx_objectattributes_include"

void main()
{
    // Get the creature who triggered this event.
    object oPC = GetLastUsedBy();

    // Change how the PC looks.
	XPObjectAttributesSetRace(oPC, RACIAL_TYPE_HALFORC);
    XPObjectAttributesSetSubRace(oPC, RACIAL_SUBTYPE_HALFORC);
	
	//SetCreatureAppearanceType(oPC, APPEARANCE_TYPE_HALF_ORC);
	SetCreatureAppearanceType(oPC,5); // appearance.2da-line
    // Set the PC's subrace.
    //SetSubRace(oPC, "HALF-ORC");
}/*



