// ga_destroy_item
// FoamBats4All 2014-04-30

#include "nw_i0_plot"
#include "acr_xp_i"

// Rewards XP for each item of tag sItem, returns nGold times the count of items found.
int ConsumeReward( object oTarget, string sItem, int nGold, float fXP, float fCR ) {
	// Number of items consumed.
	int nCount = 0;

	// Destroy all items.
	object oItem = GetFirstItemInInventory( oTarget );
	while ( GetIsObjectValid( oItem ) == TRUE ) {
		if ( GetTag( oItem ) == sItem ) {
			nCount += GetItemStackSize( oItem );
			DestroyObject( oItem, 0.0f );
		}
		oItem = GetNextItemInInventory( oTarget );
	}

	// Abort if no items are found.
	if ( nCount == 0 ) {
		return 0;
	}

	// Award XP.
	ACR_AwardStaticQuestXP( oTarget, "Collected: Herbs" + sItem, FloatToInt( fXP * nCount ), fCR ); 

	// Pass back GP to be awarded at the end.
	return nGold * nCount;
}


void main( string sItemTag ) {
	// Get the player speaking.
	object oPC = GetPCSpeaker();

	// Total GP rewarded.
	int nGP = 0;

	
	
	// Fire Fern Frond: 10gp, 5xp, CR 5
	nGP += ConsumeReward( oPC, "firefernfrond", 10, 5.0f, 5.0f );
	
	// Magpie Mushroom: 2gp, 1xp, CR 1
	nGP += ConsumeReward( oPC, "magmush", 2, 1.0f, 1.0f );
	
		// Cassil: 30gp, 15xp, CR 8
	nGP += ConsumeReward( oPC, "it_cassil", 30, 15.0f, 8.0f );
	
	// Garnishcap: 1gp, 0.5xp, CR 1
	nGP += ConsumeReward( oPC, "it_garnishcap", 1, 0.5f, 1.0f );
	
	// Garclive: 4gp, 2xp, CR 2
	nGP += ConsumeReward( oPC, "it_garclive", 30, 15.0f, 2.0f );
	
	// Elderberry: 4gp, 2xp, CR 2
	nGP += ConsumeReward( oPC, "it_elderberry", 30, 15.0f, 2.0f );
	
	// Hensbane: 35gp, 17.5xp, CR 8
	nGP += ConsumeReward( oPC, "it_henbane", 35, 17.5f, 8.0f );
	
	// Skullcap: 32gp, 16xp, CR 10
	nGP += ConsumeReward( oPC, "it_skullcap", 32, 16.0f, 10.0f );
	
	// Gloomshroom: 10gp, 8xp, CR 5
	nGP += ConsumeReward( oPC, "it_gloomshroom", 10, 8.0f, 5.0f );

	// Nararoot: 10gp, 5xp, CR 5
	nGP += ConsumeReward( oPC, "it_nararoot", 10, 5.0f, 5.0f );
	
	// Wormwood: 1gp, 0.5xp, CR 1
	nGP += ConsumeReward( oPC, "009_field_herb1", 1, 0.5f, 1.0f );

	// Woodland mushrooms: 1gp, 0.5xp, CR 1
	nGP += ConsumeReward( oPC, "009_woodland_mushrooms", 1, 1.0f, 1.0f );
	
	// Wolfsbane: 2gp, 1xp, CR 1
	nGP += ConsumeReward( oPC, "tg_herb2", 1, 1.0f, 1.0f );
	
	//Mushrooms: 1gp, 1xp, CR .5	
	nGP += ConsumeReward( oPC, "tg_mushrooms", 1, 1.0f, 1.0f );
	
	//Agrimont: 5gp, 3xp, CR 5	
	nGP += ConsumeReward( oPC, "009_it_herb_agrimont", 5, 3.0f, 5.0f );
	

	// Reward GP.
	GiveGoldToCreature( oPC, nGP );
}