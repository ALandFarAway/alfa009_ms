// Modified from standard template "use_lever"
// Assumes initial state is deactivated.
// If initial state is activated, apply variable set "ActivatedState" to placeable
// Assumes the Tag of the activating lever is "leverXX" and the target door is "gateXX"
void main()
{
// Play the sound effect for the lever.
PlaySound("as_sw_lever1");	
ExecuteScript("x2_plc_used_act", OBJECT_SELF);
int bActivated = GetLocalInt(OBJECT_SELF,"X2_L_PLC_ACTIVATED_STATE");
// Get the right target
object oTarget; //The door to be opened
string sSubstring; //The lever number
sSubstring = GetSubString(GetTag(OBJECT_SELF), 5, 2);
//SpeakString("Using lever number: " + sSubstring); //debug
oTarget = GetNearestObjectByTag("door" + sSubstring);	
//SpeakString("Affecting door with tag: " + GetTag(oTarget)); //debug
// Open or close it depending on the current state.
	if (bActivated == TRUE)
	{
		SetLocked(oTarget, FALSE);
		AssignCommand(oTarget, ActionOpenDoor(oTarget));
//		SpeakString("Door unlocked and opened.");
	}
	else
	{
		AssignCommand(oTarget, ActionCloseDoor(oTarget));
		SetLocked(oTarget, TRUE);
//		SpeakString("Door closed and locked.");
	}
	
}	