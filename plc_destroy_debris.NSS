// Put this script OnClick of a placeable.


void main()
{
    effect eVFX;
    object oSelf = OBJECT_SELF;

    // Get the creature who triggered this event.
    object oPC = GetPlaceableLastClickedBy();

    // Destroy an object (not fully effective until this script ends).

    eVFX = EffectVisualEffect(VFX_COM_CHUNK_STONE_SMALL);
    DelayCommand(10.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFX, oSelf));
    DelayCommand(10.0, DestroyObject(oSelf, 3.0));

    // Have us say something.
    SpeakString("*you spend a few minutes and manage to clear away some of the rubble*");
}
