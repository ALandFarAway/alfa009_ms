// OnClosed script for the placeable emulating item on the ground
//
// Note that as the placeable should be destroyed immediately when it is
// opened, this is called directly without the items inside being destroyed
// first. Thats why we do not want to do anything here.
//
// Kivinen 2007-06-19

#include "c_tk_i_item_placeable"

void main()
{
  object oPC = GetLastClosedBy();
  object oPlc = OBJECT_SELF;

  // Nothing to be done here. The items are already moved to the PCs inventory
  // in the OnOpen, and the placeable is destroyed there. Then this is
  // immediately called as the placeable is automatically closed when it is
  // destroyed and the items we have already destroyed from inside in the
  // OnOpen, are still there when this is called. 
}

