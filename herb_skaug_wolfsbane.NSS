void main()
{
	object PCclick;
	object resval;
	
	PCclick = GetLastUsedBy();
	//Wolfsbane leaves
	resval = CreateItemOnObject("tg_herb2",PCclick);
		
	if (!GetIsObjectValid(resval)) 
		SpeakOneLinerConversation("Fsck, invalid item");

	DestroyObject(OBJECT_SELF);
}