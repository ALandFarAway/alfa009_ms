#include "acr_items_i"

int StartingConditional(int inventorySlot, int command, int param1, int param2, int val)
{
	object oPC = GetPCSpeaker();
	object oItem = GetItemInSlot(inventorySlot, oPC);
	if(!GetIsObjectValid(oItem)) return FALSE;
	
	ClearScriptParams();
	AddScriptParameterObject(oItem);
	AddScriptParameterInt(command);
	AddScriptParameterInt(param1);
	AddScriptParameterInt(param2);
	return (ExecuteScriptEnhanced("ACR_Items", oPC, TRUE) == val);
}