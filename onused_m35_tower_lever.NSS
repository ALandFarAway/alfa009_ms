

//Put this script OnUsed
void main()
{

object oPC = GetLastUsedBy();

{
    // * note that nActive == 1 does  not necessarily mean the placeable is active
    // * that depends on the initial state of the object
    int nActive = GetLocalInt (OBJECT_SELF,"X2_L_PLC_ACTIVATED_STATE");
    // * Play Appropriate Animation
    if (!nActive)
    {
      ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
    }
    else
    {
      ActionPlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE);
    }
    // * Store New State
    SetLocalInt(OBJECT_SELF,"X2_L_PLC_ACTIVATED_STATE",!nActive);
}

if (!GetIsPC(oPC)) return;

object oTarget;
oTarget = GetObjectByTag("fx_gem_energy_blue");

DestroyObject(oTarget, 0.0);

}


