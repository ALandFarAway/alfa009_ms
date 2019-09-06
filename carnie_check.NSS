// This carries out a standard rigged carnival game. They more-or-less vend common
// items, though wealth plays slightly into one's odds of winning.

#include "acr_wealth_i"

int StartingConditional(int risk)
{
	object oPC = GetPCSpeaker();
	if(GetGold(oPC) < 1)
	{
		SendMessageToPC(oPC, "You don't have enough money for that.");
		return FALSE;
	}
	TakeGoldFromCreature(1, oPC, TRUE, TRUE);
	
	int chance = 50;
	int prize = 2;
	switch(risk)
	{
		case 1:
			chance = 50;
			prize = 2;
			break;
		case 2:
			chance = 25;
			prize = 4;
			break;
		case 3:
			chance = 10;
			prize = 10;
			break;
		case 4:
			chance = 1;
			prize = 100;
			break;
	}
	
	float fMult = ACR_CalculateMultiplier(oPC);
	int nLevel = GetTotalLevels(oPC, FALSE);
	if(nLevel <= 8) fMult /= 1.25f;
	else if(nLevel <= 12) fMult /= 2.5f;
	else if(nLevel <= 16) fMult /= 5.0f;
	else fMult /= 10.0f;
	chance = FloatToInt(IntToFloat(chance) * fMult);
	
	if(d100(1) <= chance)
	{
	//common prizes
		string prizeResRef = "";
		if(prize == 2)
		{
			switch(d8(1))
			{
				case 1:
					prizeResRef = "03_it_hlm_l_gr160";
					break;
				case 2:
					prizeResRef = "009_it_hex_ramhorn1";
					break;
				case 3:
					prizeResRef = "abr_it_hex_mask_ornate";
					break;
				case 4:
				    	prizeResRef = "009_it_p_tophill_lilystarwine";
					break;
				case 5:
					prizeResRef = "abr_it_msc_earring4_2";
					break;
				case 6:
					prizeResRef = "abr_it_msc_earring5_2";
					break;
				case 7:
					prizeResRef = "cs_it_firewine";
					break;
				case 8:
					prizeResRef = "tg_handaxe2";
					break;
			}
		}
		//average prizes
		else if(prize == 4)
		{
			switch(d4(1))
			{
				case 1:
					prizeResRef = "nw_it_book032";
					break;
				case 2:
					prizeResRef = "nw_it_book013";
					break;
				case 3:
					prizeResRef = "nw_it_book027";
					break;
				case 4:
					prizeResRef = "abr_it_msc_drum";
					break;
			}
		}
		//valuable prizes
		else if(prize == 10)
		{
			switch(d6(1))
			{
				case 1:
					prizeResRef = "abr_it_gem_quartz";
					break;
				case 2:
					prizeResRef = "abr_it_gem_074";
					break;
				case 3:
					prizeResRef = "abr_it_gem_064";
					break;
				case 4:
					prizeResRef = "abr_it_msc_lute";
					break;
				case 5:
					prizeResRef = "abr_it_msc_bagpipes";
					break;
				case 6:
					prizeResRef = "abr_it_msc_flute";
					break;
					
			}
		}
		//impossible prizes
		else if(prize == 100)
		{
			switch(d8(1))
			{
				case 1:
					prizeResRef = "abr_it_msc_lute_mw";
					break;
				case 2:
					prizeResRef = "abr_it_msc_flute_mw";
					break;
				case 3:
					prizeResRef = "abr_it_msc_drum_mw";
					break;
				case 4:
					prizeResRef = "abr_it_msc_bagpipes_mw";
					break;
				case 5:
					prizeResRef = "abr_it_gem_001";
					break;
				case 6:
					prizeResRef = "abr_it_gem_034";
					break;
				case 7:
					prizeResRef = "abr_it_gem_076";
					break;
				case 8:
					prizeResRef = "abr_it_gem_015";
					break;
			}
		}
		CreateItemOnObject(prizeResRef, oPC, 1, "", TRUE);
		return TRUE;
	}
	return FALSE;
}