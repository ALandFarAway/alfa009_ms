
/*
// Shrieker script
// Name:        fungi_shri_oca.nss
// Created by:  Robert Joanis   aka Doorman1970
// Date:        3-19-04
// Using:       Bioware Aurora Script Editor
// Goes in:     OnSpellCastAt event of the Shrieker Placeable
//
// To create a Shrieker encounter you must place a trigger around
// a placeable mushroom to the size that would deliniate the Shriekers
// perception range. Since placeables do not have perception, we are
// using the series of fungi_shri_enter/exit/ud/cast to define a perception.
//
*/

object oPC = GetLastSpellCaster();
void main()
{
 if(!GetLastSpell()==SPELL_SILENCE) return;
  {
   SetLocalInt(OBJECT_SELF, "Silenced", 1);
   FloatingTextStringOnCreature("The mushroom appears to quiver with restrained effort.", oPC);
  }
}