// by 4760 
// for door in m35 Mystery Keep
// if picklock opens into cooridor if use key jumps party to other doorway

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
			ActionOpenDoor(OBJECT_SELF);
        }
        else
        {
            // key used, do the AT stuff
		location lWhereTo = GetLocation(GetObjectByTag("wp_dr_m35_hall_at_door2"));
               object oParty = GetFirstFactionMember(GetFirstPC(), FALSE);
               object oWP = GetObjectByTag("wp_dr_m35_hall_at_door2");
        while (GetIsObjectValid(oParty))
        {
            AssignCommand(oParty, ClearAllActions(TRUE));
            AssignCommand(oParty, JumpToObject(oWP));
           oParty = GetNextFactionMember(GetNextPC(), FALSE);
        }
       }
    }
}