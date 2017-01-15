// a waypoint named "RockFallCenter" needed
#include "nw_i0_generic"
void main()
{
object oEpicenter = GetNearestObjectByTag("RockFallCenter", OBJECT_SELF);
object oPC = GetEnteringObject();
int iDelay = GetLocalInt(OBJECT_SELF, "FallDelay");
if( GetIsPC( GetEnteringObject()))   //   <------ is the thing that fires the script a PC
{
if (iDelay!=1)                       // <---- is it primed to go  or has it gone off too recentley?
{
 effect eShake =  EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
location lCenter = GetLocation(oEpicenter);
float fRan1 = IntToFloat (d100(3));
float fRan2 = IntToFloat (d100(3));
float fRan3 = IntToFloat (d100(3));
float fRan4 = IntToFloat (d100(3));
float fRan5 = IntToFloat (d100(3));
float fRan6 = IntToFloat (d100(3));
float fRan7 = IntToFloat (d100(3));
float fRan8 = IntToFloat (d100(3));
float fRan9 = IntToFloat (d100(3));
float fRan10 = IntToFloat (d100(3));
float fRan11 = IntToFloat (d100(3));
float fRan12 = IntToFloat (d100(3));
float fDis1 = IntToFloat (d8(1));
float fDis2 = IntToFloat (d8(1));
float fDis3 = IntToFloat (d8(1));
float fDis4 = IntToFloat (d8(1));
float fDis5 = IntToFloat (d8(1));
float fDis6 = IntToFloat (d8(1));
float fDis7 = IntToFloat (d8(1));
float fDis8 = IntToFloat (d8(1));
float fDis9 = IntToFloat (d8(1));
float fDis10 = IntToFloat (d8(1));
float fDis11 = IntToFloat (d8(1));
float fDis12 = IntToFloat (d8(1));
location lNew1 = GenerateNewLocationFromLocation(lCenter, fDis1, fRan1, fRan12);
location lNew2 = GenerateNewLocationFromLocation(lCenter, fDis2, fRan2, fRan11);
location lNew3 = GenerateNewLocationFromLocation(lCenter, fDis3, fRan3, fRan10);
location lNew4 = GenerateNewLocationFromLocation(lCenter, fDis4, fRan4, fRan9);
location lNew5 = GenerateNewLocationFromLocation(lCenter, fDis5, fRan5, fRan8);
location lNew6 = GenerateNewLocationFromLocation(lCenter, fDis6, fRan6, fRan7);
location lNew7 = GenerateNewLocationFromLocation(lCenter, fDis7, fRan7, fRan6);
location lNew8 = GenerateNewLocationFromLocation(lCenter, fDis8, fRan8, fRan5);
location lNew9 = GenerateNewLocationFromLocation(lCenter, fDis9, fRan9, fRan4);
location lNew10 = GenerateNewLocationFromLocation(lCenter, fDis10, fRan10, fRan3);
location lNew11 = GenerateNewLocationFromLocation(lCenter, fDis11, fRan11, fRan2);
location lNew12 = GenerateNewLocationFromLocation(lCenter, fDis12, fRan12, fRan1);
 SetLocalInt(OBJECT_SELF,"FallDelay",1);
 DelayCommand (600.0f, SetLocalInt(OBJECT_SELF,"FallDelay",2));
 ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eShake, lCenter);
 SendMessageToPC(oPC, "Dear God! It's a cave in!!!");
 
object oTarget;
// oTarget = GetObjectByTag("cave_in_sound");

FloatingTextStringOnCreature("Gods!  Its a cave in!!", oPC);

SoundObjectPlay(oTarget);

SoundObjectSetVolume(oTarget, 100);

PlaySound("RockCrumblesCaveLarge");

//PlaySound("as_na_rockfallg1");

 CreateObject (OBJECT_TYPE_PLACEABLE,"PLC_NT_ROCKS03",lNew1, FALSE);
 CreateObject (OBJECT_TYPE_PLACEABLE,"PLC_NT_ROCKS04",lNew2, FALSE);
 CreateObject (OBJECT_TYPE_PLACEABLE,"PLC_NT_ROCKS05",lNew3, FALSE);
 CreateObject (OBJECT_TYPE_PLACEABLE,"PLC_NT_ROCKS05",lNew4, FALSE);
 CreateObject (OBJECT_TYPE_PLACEABLE,"PLC_NT_ROCKS04",lNew5, FALSE);
 CreateObject (OBJECT_TYPE_PLACEABLE,"PLC_NT_ROCKS03",lNew6, FALSE);
 CreateObject (OBJECT_TYPE_PLACEABLE,"PLC_NT_ROCKS05",lNew7, FALSE);
 CreateObject (OBJECT_TYPE_PLACEABLE,"PLC_NT_ROCKS04",lNew8, FALSE);
 CreateObject (OBJECT_TYPE_PLACEABLE,"PLC_NT_ROCKS03",lNew9, FALSE);
 CreateObject (OBJECT_TYPE_PLACEABLE,"PLC_NT_ROCKS05",lNew10, FALSE);
 CreateObject (OBJECT_TYPE_PLACEABLE,"PLC_NT_ROCKS03",lNew11, FALSE);
 CreateObject (OBJECT_TYPE_PLACEABLE,"PLC_NT_ROCKS03",lNew12, FALSE);
}
}
effect eEffect;
eEffect = EffectDamage(15, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_NORMAL);

ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, oPC);
}