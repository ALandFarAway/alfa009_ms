#include "acr_vanity_i"

const string TINTER_VERSION = "v1.0";

void main()
{
	object oPC = GetItemActivator();
	object oTarget = GetItemActivatedTarget();
	object oItem = GetItemActivated();
	
	if (!GetIsObjectValid(oTarget)) {
		oTarget = oPC;
	}
	
	float tint0r = GetLocalInt(oItem, "tint0r") / 255.0f;
	float tint0g = GetLocalInt(oItem, "tint0g") / 255.0f;
	float tint0b = GetLocalInt(oItem, "tint0b") / 255.0f;
	
	float tint1r = GetLocalInt(oItem, "tint1r") / 255.0f;
	float tint1g = GetLocalInt(oItem, "tint1g") / 255.0f;
	float tint1b = GetLocalInt(oItem, "tint1b") / 255.0f;
	
	float tint2r = GetLocalInt(oItem, "tint2r") / 255.0f;
	float tint2g = GetLocalInt(oItem, "tint2g") / 255.0f;
	float tint2b = GetLocalInt(oItem, "tint2b") / 255.0f;

	SendMessageToPC(oPC, "Script version: 1");
	SendMessageToPC(oPC, "Tinting: " + GetName(oTarget) + " (" + TINTER_VERSION + ")");
	SendMessageToPC(oPC,"0: ("+FloatToString(tint0r)+","+FloatToString(tint0g)+","+FloatToString(tint0b)+")");
	SendMessageToPC(oPC,"1: ("+FloatToString(tint1r)+","+FloatToString(tint1g)+","+FloatToString(tint1b)+")");
	SendMessageToPC(oPC,"2: ("+FloatToString(tint2r)+","+FloatToString(tint2g)+","+FloatToString(tint2b)+")");
	
	SendMessageToPC(oTarget, "Being tinted by: " + GetName(oPC) + " (" + TINTER_VERSION + ")");
	SendMessageToPC(oTarget,"0: ("+FloatToString(tint0r)+","+FloatToString(tint0g)+","+FloatToString(tint0b)+")");
	SendMessageToPC(oTarget,"1: ("+FloatToString(tint1r)+","+FloatToString(tint1g)+","+FloatToString(tint1b)+")");
	SendMessageToPC(oTarget,"2: ("+FloatToString(tint2r)+","+FloatToString(tint2g)+","+FloatToString(tint2b)+")");

	XPObjectAttributesSetHeadTint(oTarget,
		CreateXPObjectAttributes_TintSet(
			CreateXPObjectAttributes_Color(tint0r, tint0g, tint0b, 1.0f),
			CreateXPObjectAttributes_Color(tint1r, tint1g, tint1b, 1.0f),
			CreateXPObjectAttributes_Color(tint2r, tint2g, tint2b, 1.0f)));
	ResetModel(oTarget);
}