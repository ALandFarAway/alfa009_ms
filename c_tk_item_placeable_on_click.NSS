// OnLeftClick script for the placeable emulating item on the ground
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
// Kivinen 2008-01-10

#include "c_tk_i_item_placeable"

void C_CheckDistanceAndPickup(object oPC, object oPlc, int nLoop = 0)
{
  float fLimit;

  fLimit = 0.5 * IntToFloat(nLoop) + 0.5;
  if (GetDistanceBetween(oPlc, oPC) < fLimit) {
    // SendMessageToPC(oPC, "OnLeftClicked called");
    C_GetItemFromGround(oPC, oPlc);
  } else {
    if (nLoop >= 5) {
      // Could not reach the location, stop trying. 
      return;
    }
    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, ActionMoveToObject(oPlc, TRUE, 0.0));
    AssignCommand(oPC,
		  ActionDoCommand(C_CheckDistanceAndPickup(oPC, oPlc,
							   ++nLoop)));
  }
}

void main()
{
  object oPC = GetPlaceableLastClickedBy();
  object oPlc = OBJECT_SELF;
  C_CheckDistanceAndPickup(oPC, oPlc);
}