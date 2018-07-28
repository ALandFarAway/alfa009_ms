#include "acr_spawn_i"

void main();
// Created by Arianna for ALFA 7/2018
// Underdark Random Encounters
// Encounter Level 5 - 18

/* 
Day:
6% Beetles high
8% Basilisk
6% Derro Raiders
8% Beholder
10% Drow Slavers
6% Gargoyles
6% Goblin Patrol
10% Halfling Scouts
2% Hellhounds
4% Black Pudding
6% Ogres
6% Dreadwarrior Company
4% Duegar Patrol
14% kobolds elite
4% leucrotta cr9

Night:
2% Beetles high
2% Basilisk
4% Derro Raiders
6% Beholder
4% Gargoyles
4% Ghast Gang
2% Ghast Pack
4% Goblin Patrol
5% Hellhounds
5% Goblin Patrol
4% Hellhounds
6% Black Pudding
6% Ogres
5% Dreadwarrior company
5% Orc Patrol
4% Shadow Gang
4% Vampire Spawn Pack
6% Werewolves
4% Wight Gang
10% Wolf Pack
4% Wraiths
4% Wyvern

*/

void main() {

	int nRoll = d100();
	int i;

	if (GetIsDay()) 
	{ 
		if (nRoll <= 6) ACR_SpawnGroup("beetles_high");
		else if (nRoll <= 14) ACR_SpawnObject("abr_cr_mb_basilisk", OBJECT_TYPE_CREATURE);
		else if (nRoll <= 20) ACR_SpawnGroup("derro_raiders");
		else if (nRoll <= 28) ACR_SpawnObject("010_cr_aber_beholder", OBJECT_TYPE_CREATURE);
		else if (nRoll <= 38) ACR_SpawnGroup("drow_slavers");
		else if (nRoll <= 44) ACR_SpawnGroup("gargoyles");
		else if (nRoll <= 50) ACR_SpawnGroup("ghast_gang");
		else if (nRoll <= 60) ACR_SpawnGroup("goblin_patrol");
		else if (nRoll <= 62) ACR_SpawnGroup("hellhounds");
		else if (nRoll <= 66) ACR_SpawnObject("abr_cr_blackpud0",OBJECT_TYPE_CREATURE);
		else if (nRoll <= 72) ACR_SpawnGroup("ogres");
		else if (nRoll <= 78) ACR_SpawnGroup("dreadwarrior_company");
		else if (nRoll <= 82) ACR_SpawnGroup("duergar_patrol");
		else if (nRoll <= 96) ACR_SpawnGroup("kobolds_elite");
		else ACR_SpawnObject("abr_cr_mb_leucrotta9", OBJECT_TYPE_CREATURE);
	}	
	else	// Is night
	{
		if (nRoll <= 2) ACR_SpawnGroup("fire_beetle_cluster");
		else if (nRoll <= 4) ACR_SpawnObject("009_cr_ab_hookhorror6", OBJECT_TYPE_CREATURE);
		else if (nRoll <= 8) ACR_SpawnGroup("dreadwarrior_company");
		else if (nRoll <= 14) ACR_SpawnObject("009_cr_mhg_minotaur8", OBJECT_TYPE_CREATURE);
		else if (nRoll <= 18) ACR_SpawnGroup("duergar_raiders");
		else if (nRoll <= 22) ACR_SpawnGroup("ghast_gang");
		else if (nRoll <= 24) ACR_SpawnGroup("ghast_pack");
		else if (nRoll <= 28) ACR_SpawnGroup("ghoul_gang");
		else if (nRoll <= 33) ACR_SpawnGroup("derro_raiders");
		else if (nRoll <= 38) ACR_SpawnGroup("goblin_raiders");
		else if (nRoll <= 42) ACR_SpawnGroup("hellhounds");
		else if (nRoll <= 48) ACR_SpawnGroup("deepgnomes");
		else if (nRoll <= 54) ACR_SpawnObject("abr_cr_ab_mindflayer_sorc9", OBJECT_TYPE_CREATURE);
		else if (nRoll <= 59) ACR_SpawnObject("abr_cr_ab_beholder_010", OBJECT_TYPE_CREATURE);
		else if (nRoll <= 64) ACR_SpawnObject("009_cr_ab_intellectdevourer", OBJECT_TYPE_CREATURE);
		else if (nRoll <= 68) ACR_SpawnGroup("shadow_gang");
		else if (nRoll <= 72) ACR_SpawnGroup("drow_slavers");
		else if (nRoll <= 78) ACR_SpawnGroup("werewolves");
		else if (nRoll <= 82) ACR_SpawnGroup("wight_gang");
		else if (nRoll <= 92) ACR_SpawnGroup("myconid_troupe");
		else if (nRoll <= 96) ACR_SpawnGroup("wraiths");
		else ACR_SpawnObject("abr_cr_mb_leucrotta9", OBJECT_TYPE_CREATURE);
	}
}