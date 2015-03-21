/*this script is used in conjunction with passing out
 inn keys use in the conditional slot*/



int StartingConditional(string checker)
{

	object otarget = GetObjectByTag("innkey_holder");

	if (GetIsObjectValid(GetItemPossessedBy(otarget,checker)))
		return TRUE;
	return FALSE;
}