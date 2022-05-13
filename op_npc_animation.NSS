// Created by Saaz for ALFA 
// MAY 2022
// Put this OnPerception of NPC.
// place      sAnimation = "animation namefrom 2da" in the variables
// WP needs to be positioned exactly at area where NPC is to be 
// sitgroundidle = sits cross legged on the ground
// proneB = laying down(sleep)
// sitfidget = sit on chair moving a little
// sitidle = sit on chair no movement
// kneelidle = down on one knee
// shoveling/raking = use with the fx for proper postured tool
// forge01 = hammering at an anvil 
// kemo_kneel_1i = kneeling on both knees, hands on knees
// kemo_sit_5i = sitting ground knees up hands around them -M
// kemo_sit_8i = sitting ground knees up hands around them -F
// kemo_stand_5i = for tied spread eagle upright 
// kemo_sit_7i - on ground side leg out - F
// Will abort (do nothing) if fighting or talking or if no PCs are in the area.

#include "acr_spawn_i"

const string ANIMATION_VAR_NAME = "sAnimation";
const string ANIMATION_DEFAULT = "sitgroundidle";
void main()
{
object oPC = GetLastPerceived();

if (!GetIsPC(oPC)) return;

if (!GetLastPerceptionSeen()) return;
object oTarget;
oTarget = OBJECT_SELF;
    if (GetLocalInt(GetModule(),"Stop Ambient Life"))
    {
        return;
    }

string sAnimation = GetLocalString(OBJECT_SELF,ANIMATION_VAR_NAME);
if (sAnimation == "") sAnimation = ANIMATION_DEFAULT;

    PlayCustomAnimation(OBJECT_SELF, sAnimation, 1);
        SetOrientOnDialog(OBJECT_SELF,FALSE);//keeps NPC from turning when talked too
        SetBumpState(OBJECT_SELF,BUMPSTATE_UNBUMPABLE); //keeps NPC from being bumped and standing    
} 