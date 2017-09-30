// 'nude_inc'

// Checks if 'oPC' has unequipped a chest-item, and if so equips a nudity-item.
// - called from OnPlayerUnequip (note that the call must be delayed, else the
//   engine thinks an item is still equipped)
// oPC    : the character that unequipped an item
// oChest : the item that was unequipped
void checkNakedStatus(object oPC, object oChest)
{
    if (GetBaseItemType(oChest) == BASE_ITEM_ARMOR) // bypass if not chest-type equipment
    {
        string sResref = "009_it_sp_underwear";                // <- doubles as the tag.

        switch (GetRacialType(oPC))         // define a compatible chest-item .UTI blueprint
        {                                   // based on race (ie, handle racial types here when
            case RACIAL_TYPE_HUMAN:         // suitable blueprints/resources become available)
                sResref = "009_it_sp_underwear";
//              sResref = "nw_cloth024";    // TEST item. Commoner's Tunic.
                break;

            default:
                break;
        }

        if (sResref != "009_it_sp_underwear")                  // bypass if there isn't a blueprint
        {
            object oChestTest = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);

            if (!GetIsObjectValid(oChestTest))      // nothing on chest, equip nudity-item ->
            {
                oChest = GetItemPossessedBy(oPC, sResref);

                if (!GetIsObjectValid(oChest))
                {
                    oChest = CreateItemOnObject(sResref, oPC, 1, sResref, FALSE);
                    if (GetIsObjectValid(oChest))
                    {
                        SetPlotFlag(oChest, TRUE);          // NOTE: These can be deleted if
                        SetItemCursedFlag(oChest, TRUE);    // set on the blueprint instead.
                    }
                }

                if (GetIsObjectValid(oChest)) // NOTE: This check should be deleted if you're sure the resource is available.
                {
                    DelayCommand(0.f, AssignCommand(oPC, ActionEquipItem(oChest, INVENTORY_SLOT_CHEST)));
                }
            }
            else if (GetTag(oChestTest) != sResref) // something is on chest, if it's not a nudity-item ->
            {
                DestroyObject(oChest, 0.f, FALSE);  // then destroy the nudity-item from inventory
            }
        }
    }
}