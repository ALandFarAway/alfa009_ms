// Put this script OnClick of a placeable.




#include "nwnx_objectattributes_include"

void main() {
    object oPC = GetItemActivator();
    XPObjectAttributesSetSubRace(oPC, RACIAL_SUBTYPE_HALFORC);

}



