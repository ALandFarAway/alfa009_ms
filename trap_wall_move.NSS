//Put this script OnEnter
void main()
{
 
object oPC = GetEnteringObject();
 
if (!GetIsPC(oPC)) return;
 
object oTarget;
oTarget = GetObjectByTag("skpt_drowlair_walltrap");
//string oTrap = GetLocalString((OBJECT_SELF),"oTrap");
 
// Assumes initial state is deactivated.
// If initial state is activated, apply variable set "ActivatedState" to placeable
    ExecuteScript("x2_plc_used_act", oTarget);
int bActivated = GetLocalInt(oTarget,"X2_L_PLC_ACTIVATED_STATE");
 
{
ActionPlayAnimation(ANIMATION_PLACEABLE_OPEN,0.5,0.0);
oTarget = GetObjectByTag("skpt_drowlair_walltrap");
DelayCommand(5.0,ActionPlayAnimation(ANIMATION_PLACEABLE_CLOSE));
// MAKE A ACTIVATE SCRAPE SOUND 
AssignCommand(GetEnteringObject(), PlaySound("as_sw_stonelk1", TRUE));
}
 
 
} 