int StartingConditional(int inventorySlot)
{
	return GetIsObjectValid(GetItemInSlot(inventorySlot, GetPCSpeaker()));
}