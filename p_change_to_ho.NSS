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
   // SetFirstName(oPC,"Tobias");
	SetBaseAbilityScore (oPC,ABILITY_STRENGTH,10);
	SetBaseAbilityScore (oPC,ABILITY_DEXTERITY, 18);
	SetBaseAbilityScore (oPC,ABILITY_CONSTITUTION,14);
	SetBaseAbilityScore (oPC,ABILITY_INTELLIGENCE,21);
	SetBaseAbilityScore (oPC,ABILITY_WISDOM, 8);
	SetBaseAbilityScore (oPC,ABILITY_CHARISMA,10);
	
    FeatRemove (oPC,FEAT_QUICK_TO_MASTER);
	FeatRemove (oPC,1773);//FEAT_HUMAN_SKILLED
	FeatAdd (oPC,FEAT_DARKVISION,1,1,1);
}

