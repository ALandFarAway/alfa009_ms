// THIS SCRIPT IS NOT A PART OF ACR

#include "acr_xp_i"
#include "acr_time_i"


void main(string sQuest, int nGold, int bPartyWide, int nXP, float fCR)
{
	object oPC = GetPCSpeaker();
	
	GiveGoldToCreature(oPC, nGold);
	if(!bPartyWide)
	{
		ACR_AwardStaticQuestXP(oPC, sQuest, nXP, fCR); 
		return;
	}
	else
	{
		object oAlly = GetFirstFactionMember(oPC);
		while(GetIsObjectValid(oAlly))
		{
			ACR_AwardStaticQuestXP(oAlly, sQuest, nXP, fCR);
			oAlly = GetNextFactionMember(oPC);
		}
	}
}