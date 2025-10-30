//Put this script OnEnter
//spawns in corpses for  Where are the taxes quest
#include "acr_db_persist_i"
#include "acr_quest_i"


void main()
{
object oTarget1;
object oTarget2;
object oTarget3;
object oTarget4;

object oSpawn1;
object oSpawn2;
object oSpawn3;
object oSpawn4;

location lTarget1;
location lTarget2;
location lTarget3;
location lTarget4;

object oPC = GetEnteringObject();

 // Only fire for (real) PCs.
    if ( !GetIsPC(oPC)  ||  GetIsDMPossessed(oPC) )
        return;
		
		
//int nInt;
//nInt=GetLocalInt(oPC, "NW_JOURNAL_ENTRYsndn_taxes_westphal");

//if (nInt = 4)
//   return;

// If the PC is  at stage 4 of journal quest "sndn_taxes_westphal".
    if ( GetLocalInt(oPC, "NW_JOURNAL_ENTRYsndn_taxes_westphal") == 4 )



oTarget1 = GetWaypointByTag("Where_Tax1");

lTarget1 = GetLocation(oTarget1);

oSpawn1 = CreateObject(OBJECT_TYPE_PLACEABLE, "abr_pl_mr_corpse140", lTarget1);

oTarget2 = GetWaypointByTag("Where_Tax2");

lTarget2 = GetLocation(oTarget2);

oSpawn2 = CreateObject(OBJECT_TYPE_PLACEABLE, "abr_pl_mr_corpse200", lTarget2);

oTarget3 = GetWaypointByTag("Where_Tax3");

lTarget3 = GetLocation(oTarget3);

oSpawn3 = CreateObject(OBJECT_TYPE_PLACEABLE, "abr_pl_mr_corpse300", lTarget3);

oTarget4 = GetWaypointByTag("Where_Tax4");

lTarget4 = GetLocation(oTarget4);

oSpawn4 = CreateObject(OBJECT_TYPE_PLACEABLE, "abr_afx_bug_swarm", lTarget4);

}