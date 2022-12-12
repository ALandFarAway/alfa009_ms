

//Put this script OnUsed

void main()
{

object oPC = GetLastUsedBy();

if (!GetIsPC(oPC)) return;
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

object oTarget;
oTarget = GetObjectByTag("m35_forcefield_tower1");

DestroyObject(oTarget, 0.0);

oTarget = GetObjectByTag("m35_forcefield_tower2");

DestroyObject(oTarget, 0.0);

oTarget = GetObjectByTag("m35_forcefield_tower3");

DestroyObject(oTarget, 0.0);

}