void main()
{
	object PCclick;
	object resval;
	
	PCclick = GetLastUsedBy();
	//Mushrooms
	resval = CreateItemOnObject("tg_mushrooms",PCclick);
		
	if (!GetIsObjectValid(resval)) 
		SpeakOneLinerConversation("Fsck, invalid item");

	DestroyObject(OBJECT_SELF);
}