//Put this script OnEnter
//spawns in corpses for  Where are the taxes quest
void main()
{

object oPC = GetEnteringObject();

if (!GetIsPC(oPC)) return;

int nInt;
nInt=GetLocalInt(oPC, "NW_JOURNAL_ENTRYsndn_taxes_westphal");

if (nInt = 4)
   return;

object oTarget;
object oSpawn;
location lTarget;
oTarget = GetWaypointByTag("Where_Tax1");

lTarget = GetLocation(oTarget);

oSpawn = CreateObject(OBJECT_TYPE_PLACEABLE, "abr_pl_mr_corpse14", lTarget);

oTarget = GetWaypointByTag("Where_Tax2");

lTarget = GetLocation(oTarget);

oSpawn = CreateObject(OBJECT_TYPE_PLACEABLE, "abr_pl_mr_corpse20", lTarget);

oTarget = GetWaypointByTag("Where_Tax3");

lTarget = GetLocation(oTarget);

oSpawn = CreateObject(OBJECT_TYPE_PLACEABLE, "abr_pl_mr_corpse30", lTarget);

oTarget = GetWaypointByTag("Where_Tax4");

lTarget = GetLocation(oTarget);

oSpawn = CreateObject(OBJECT_TYPE_PLACEABLE, "abr_afx_bug_swarm", lTarget);

}