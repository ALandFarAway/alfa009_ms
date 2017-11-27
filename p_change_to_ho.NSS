// Put this script OnClick of a placeable.




#include "nwnx_objectattributes_include"

void main() {
    object oPC = GetItemActivator();
	
    XPObjectAttributesSetSubRace(oPC, RACIAL_SUBTYPE_HALFORC);
	 // Get the creature who triggered this event.
    

    // Only fire once per PC.
    if ( GetLocalInt(oPC, "DO_ONCE__" + GetTag(OBJECT_SELF)) )
        return;
    SetLocalInt(oPC, "DO_ONCE__" + GetTag(OBJECT_SELF), TRUE);

    // Change how the PC looks.
    SetCreatureAppearanceType(oPC, APPEARANCE_TYPE_HALF_ORC);
}