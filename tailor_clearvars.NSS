#include "acr_items_i"

void main()
{
	object oPC = GetPCSpeaker();

	DeleteLocalInt(oPC, "ACR_ITEM_INV_SLOT");
	DeleteLocalInt(oPC, "ACR_ITEM_COMMAND");
	DeleteLocalInt(oPC, "ACR_ITEM_PARAM_1");
}