void main()
{
	object PCclick;
	object resval;
	
	PCclick = GetLastUsedBy();
	//Wolfsbane leaves
	resval = CreateItemOnObject("tg_mush2",PCclick);
		
	if (!GetIsObjectValid(resval)) 
		SpeakOneLinerConversation("Fsck, invalid item");

	DestroyObject(OBJECT_SELF);
}