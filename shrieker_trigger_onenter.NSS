/*
// Shrieker script
// Name:        fungi_shri_enter.nss
// Created by:  Robert Joanis   aka Doorman1970
// Date:        3-22-04
// Using:       Bioware Aurora Script Editor
// Goes in:     OnEnter event of the Shrieker trigger
//
// To create a Shrieker encounter you must place a trigger around
// a placeable mushroom to the size that would deliniate the Shriekers
// perception range. Since placeables do not have perception, we are
// using the series of fungi_*_enter/ exit/ ud/ cast to define a perception.
//
// For the Shrieker we are going to attempt to stun the PC for x seconds, give a
// % to spawn x creature(s) to attack the PC, and let out a sound for 4 seconds
//  will shout for wandering monsters to attack the PC.
*/

object oCreature = GetEnteringObject();
object oShroom = GetNearestObjectByTag("Fungi_Shriek");
int nSkill = GetSkillRank(SKILL_MOVE_SILENTLY, oCreature);

/* Below are the variables you set on the trigger around the Shrieker placeable
++++Name:+++++++++++++++Type:+++Value:++Purpose:
++++++++++++++++++++++++++++Default:
//  SneakCheck          int     X       "Listen" skill of Shrieker          30
//  ShroomDist          float   X.X     Keep from calling close Shriekers   10.0 ft
//  SilenceDuration     float   X.X     Time Shrieker is silenced           60.0 seconds (1trn)
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  If you can not set variables on the Trigger from the pallete (pre HotU or
//  1.62?) you need to comment out the below box and manually set these numbers.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
//-------------------------Comment below out if needed--------------------------
int nSneakCheck = GetLocalInt(OBJECT_SELF, "SneakCheck");       // Line 47
float fShroomDist = GetLocalFloat(OBJECT_SELF, "ShroomDist");   // Line 51
float fSilDur = GetLocalFloat(OBJECT_SELF, "SilenceDuration");  // Line 43
//------------Edit variables manually below on line numbers listed--------------
void main()
{
 if (GetLocalInt(oShroom, "Silenced")==1)
  {
   // Delete Silenced variable to prepare Shrieker to fire on next enter.
   DelayCommand(fSilDur, DeleteLocalInt(oShroom, "Silenced"));
  }
     // Check if entering is sneaking and apply a check at DC=nSneakCheck
 if ((GetStealthMode(oCreature)==STEALTH_MODE_ACTIVATED)&&(d20() + nSkill >= nSneakCheck)) return;
 if (GetIsFriend(oCreature, oShroom)==TRUE || // Don't want it popping for wandering monsters.
    //GetHasSpellEffect(SPELL_INVISIBILITY, oCreature) || // Shriekers can't see, so it doesn't matter.
    GetHasSpellEffect(SPELL_SILENCE, oCreature) || // Shriekers use sound to detect.
    GetDistanceBetween(oCreature, oShroom) >= fShroomDist) return; // Don't want it to call the Shrieker down the road.
     {
      // All checks above failed so continue
      // Send a user defined Enter event numbered 747 to the Shrieker placeable
      SignalEvent(oShroom, EventUserDefined(747));
      //FloatingTextStringOnCreature("Sent event to Shroom", oCreature); // DEBUG
     }
}
