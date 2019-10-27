//this is to allow a PC to use the shout channel for special events  with the megaphone item


const string SHOUT_ITEM_TAG = "i_megaphone"; // if PC has an item with this tag, they can shout
const string SHOUT_LOCAL_INT = "shout_allowed"; // if PC has a local int with value not equal to 0 by this name, they can shout
const int SHOUT_FEAT = -1; // if PC has this feat allow shouting, negative value disables

int CheckPCCanShout(object oPC){
	if (GetIsDM(oPC) || GetIsDMPossessed(oPC) || GetLocalInt(oPC,SHOUT_LOCAL_INT)) return TRUE; // local int check
	if (SHOUT_FEAT>=0)
		if (GetHasFeat(SHOUT_FEAT,oPC)) return TRUE; // feat check
	return GetIsObjectValid(GetItemPossessedBy(oPC,SHOUT_ITEM_TAG)); // widget check
}

int CheckForPCShout(object oSender, int nChannel, string sMessage) {
	if (nChannel != CHAT_MODE_SHOUT) return FALSE;
	if (CheckPCCanShout(oSender))
		SendChatMessage(oSender,OBJECT_INVALID,CHAT_MODE_SHOUT,sMessage);
	return TRUE;
}



// wrote the previous example under the assumption that PCs normally can't shout.
// It will work, but really all you need is to add this call to the chat script:
//if (nChannel == CHAT_MODE_SHOUT && !CheckPCCanShout(oSender)) return FALSE;