// 'lever_to_door'
//
// OnUsed script placed on a lever unlocks/opens & closes/locks door.
// - set 'sDoorTag' on lever as a variable on the lever with the name of the door tag

#include "acr_placeable_i"

void main()
{
    ACR_PlaceableOnUsed();
    object oLever = OBJECT_SELF;

    string sDoorTag = GetLocalString(oLever, "sDoorTag");
    object oDoor = GetObjectByTag(sDoorTag);

    if (!GetIsOpen(OBJECT_SELF))
    {
        PlayAnimation(ANIMATION_PLACEABLE_OPEN);

        SetLocked(oDoor, FALSE);
        ActionOpenDoor(oDoor);
    }
    else
    {
        PlayAnimation(ANIMATION_PLACEABLE_CLOSE);

        SetLocked(oDoor, TRUE);
        ActionCloseDoor(oDoor);
    }
}