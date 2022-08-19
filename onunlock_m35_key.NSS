void main()
{
    object oOpener = GetLastUnlocked();
    int iKeyUsed = FALSE;
    if (oOpener != OBJECT_INVALID)
    {
        object oItem = GetFirstItemInInventory(oOpener);
        while (oItem != OBJECT_INVALID)
        {
            if (GetTag(oItem) == "m35_mystery_keep_key")
            {
            // key used, flag it
                iKeyUsed = TRUE;
            }
            oItem = GetNextItemInInventory(oOpener);
        }
        if (iKeyUsed == FALSE)
        {
            // lock picked, open into the hallway beyond
        }
        else
        {
            // key used, do the AT stuff
        }
    }
}