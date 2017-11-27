// Put this script OnClick of a placeable.

#include "nwnx_objectattributes_include"


void main()
{
    // Get the creature who triggered this event.
    object oPC = GetLastUsedBy();

    // Change how the PC looks.
    SetCreatureAppearanceType(oPC, APPEARANCE_TYPE_HALF_ORC);
    XPObjectAttributesSetSubRace(oPC, RACIAL_SUBTYPE_HALFORC);
    // Set the PC's subrace.
    SetSubRace(oPC, "HALF-ORC");
}/*

void main() {
    object oPC = GetItemActivator();
    XPObjectAttributesSetSubRace(oPC, RACIAL_SUBTYPE_HALFORC);
	 // Change how the PC looks.
    SetCreatureAppearanceType(oPC, APPEARANCE_TYPE_HALF_ORC);
}/*