/*
// Shrieker script
// Name:        fungi_shri_ud.nss
// Created by:  Robert Joanis   aka Doorman1970
// Date:        3-24-04
// Using:       Bioware Aurora Script Editor
// Goes in:     OnUserDefined event of Shrieker placeable
//
// To create a Shrieker encounter you must place a trigger around
// a placeable mushroom to the size that would deliniate the Shriekers
// perception range. Since placeables do not have perception, we are
// using the series of fungi_*_enter/exit/ud/cast to define a perception.
// For the Shrieker we are going to attempt to stun NEAREST creature (PC, familiar, monster)
// for X seconds, give a X% to spawn x creature(s) to attack the PC, and let out
// a sound for 4 seconds, and shout for wandering monsters to attack the PC.
// To apply a VFX to the Shrieker, uncomment lines 85,86 and 96,97.
*/
#include "x0_i0_spawncond"
object oShroom = OBJECT_SELF;
object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
object oSpawn;  // Spawns "c_kobold" (ResRef only) by default. Change at line 110
object oSpawnSite = GetWaypointByTag("ShriekSpawn");
location lCenter = GetLocation(oShroom);
location lTarget;

/* Below are the variables you set on the Shrieker placeable
++++Name:+++++++++++++++Type:+++Value:++Purpose:
++++++++++++++++++++++++++++Default:
//  StunSave            int     X       DC to save against stun effect      18
//  SpawnChance         int     x       % chance the spawn will happen      50  %
//  StunDur             float   X.X     Duration stun effect lasts          12.0 seconds (2rnds)
//  SphereSize          float   X.X     Area of influence diameter          10.0 feet
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  If you can not set variables on the Trigger from the pallete (pre HotU or
//  1.62?) you need to comment out the below box and manually set these numbers.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
//-------------------------Comment below out if needed--------------------------
int nStunSave = GetLocalInt(oShroom, "StunSave");            //Line 80
float fStunDur = GetLocalFloat(oShroom, "StunDur");          //Line 99
int nChance = GetLocalInt(oShroom, "SpawnChance");           //Line 105
float fSphereSize = GetLocalFloat(oShroom, "SphereSize");    //Line 46
//------------Edit variables manually below on line numbers listed--------------

object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fSphereSize, lCenter, TRUE, OBJECT_TYPE_CREATURE);
int nEvent = GetUserDefinedEventNumber();

void main()
{
 switch(nEvent)
 {
  case 747:
  {
   // Check to see if we have Silence cast at Shrieker and exit if so.
   if (GetLocalInt(oShroom, "Silenced")==1) return;
   {
    while (oTarget!=OBJECT_INVALID)
    {
     FloatingTextStringOnCreature("Shrieker making noise", oTarget); // DEBUG
     PlaySound("c_willwisp_atk1");// Combined sounds to bring a little
     PlaySound("as_an_x2cvbat8"); // mystery to the sound.
     DelayCommand(0.50, PlaySound("c_willwisp_atk1"));
     DelayCommand(0.50, PlaySound("as_an_x2cvbat8"));
     DelayCommand(1.0, PlaySound("c_willwisp_atk1"));
     DelayCommand(1.0, PlaySound("as_an_x2cvbat8"));
     DelayCommand(1.50, PlaySound("c_willwisp_atk1"));
     DelayCommand(1.50, PlaySound("as_an_x2cvbat8"));
     DelayCommand(2.0, PlaySound("c_willwisp_atk1"));
     DelayCommand(2.0, PlaySound("as_an_x2cvbat8"));
     DelayCommand(2.50, PlaySound("c_willwisp_atk1"));
     DelayCommand(2.50, PlaySound("as_an_x2cvbat8"));
     DelayCommand(3.0, PlaySound("c_willwisp_atk1"));
     DelayCommand(3.0, PlaySound("as_an_x2cvbat8"));
     DelayCommand(3.50, PlaySound("c_willwisp_atk1"));
     DelayCommand(3.50, PlaySound("as_an_x2cvbat8"));
     DelayCommand(4.0, PlaySound("c_willwisp_atk1"));
     DelayCommand(4.0, PlaySound("as_an_x2cvbat8"));
     if (WillSave(oTarget, nStunSave, SAVING_THROW_TYPE_MIND_SPELLS)>0)
      {
       // Will save passed
       FloatingTextStringOnCreature("The piercing sound of the Shrieker is sure to draw monsters!", oTarget);
       // Apply visual effect to Shrieker
       effect eEffect = EffectVisualEffect(VFX_FNF_HOWL_MIND); // Uncomment these if you want visual effect
       ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, oShroom); // Uncomment these if you want visual effect
       // Call in any wandering creatures to attack the PC's
       ActionSpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_SHOUT);
       ActionSpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_SHOUT);
      }
     else
      {
       // Will save failed.
       FloatingTextStringOnCreature("The piercing sound of the Shrieker overwhelms your senses.", oTarget);
       // Apply visual effect to Shrieker
       effect eEffect = EffectVisualEffect(VFX_FNF_HOWL_MIND); // Uncomment these if you want visual effect
       ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, oShroom); // Uncomment these if you want visual effect
       // Applies stun for x seconds.
       ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectStunned(), oTarget, fStunDur);
       //Call in any wandering creatures to attack the PC's
       ActionSpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_SHOUT);
       ActionSpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_SHOUT);
      }
     if ((d100()>=nChance)|(GetIsFriend(oTarget, oShroom))) return;
      {
       // Spawn creature next to PC on a X% chance
       //FloatingTextStringOnCreature("Spawning Enemy", oPC); //DEBUG
       lTarget = GetLocation(oSpawnSite);
       oSpawn = CreateObject(OBJECT_TYPE_CREATURE, "009_cr_ab_hookhorror6", lTarget);
      }
    oTarget = GetNextObjectInShape(SHAPE_SPHERE, fSphereSize, lCenter, TRUE, OBJECT_TYPE_CREATURE);
    break;
    }
   }
  }
  break;
  case 757:
   {
    // OnExit event would fire here
   }
  break;
  case 767:
   {
    // Added for expandability
   }
  break;
 }
}