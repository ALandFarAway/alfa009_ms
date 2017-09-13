// OnUsed script for the placeable emulating item on the ground
//
// If the placeable has inventory and there is item inside then that item is
// given to the player. If there is no items inside then variables of the
// placeable are checked.
//
// Placeable can have following variables:
//
// item_resref: Resref of the item to create
// item_stacksize: Stacksize of items to create
// item_tag: New tag of the item to create
// item_description: Description for the item
// item_first_name: First name of the item
// item_last_name: Last name of the item
//
// If item_resref is not set then placeables tag is used instead (plc_??_
// prefix is removed if it is there). If item cannot be created with that
// resref, then placeables resref is used and it is matched to known resrefs
// and those are mapped to default items.
//
// Kivinen 2007-06-19

#include "c_tk_i_item_placeable"

void main()
{
  object oPC = GetLastUsedBy();
  object oPlc = OBJECT_SELF;

  // SendMessageToPC(oPC, "OnUsed called");
  C_GetItemFromGround(oPC, oPlc);
}