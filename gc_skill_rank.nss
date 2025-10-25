//USE THIS ONE FOR ALFA 
// gc_skill_rank(int nSkill, int nRank)
/*
	Determine if PC Speaker has sufficient rank in a particular skill.

	Parameters:
		int nSkill 	= skill int to check
		int nRank	= minimum rank to return TRUE

	Remarks:
		skill ints
	-	0	APPRAISE							31  GATHER INFORMATION
	-	1	BLUFF                        		32  HANDLE ANIMAL
	-	2	CONCENTRATION						33  JUMP
	-	3	CRAFT ALCHEMY 						34  KNOWLEDGE ARCANA 
	-	4	CRAFT ARMOR 						35  KNOWLEDGE HISTORY
	-	5	CRAFT WEAPON						36  KNOWLEDGE NATURE
	-	6	DIPLOMACY							37  KNOWLEDGE RELIGION
	-	7	DISABLE DEVICE						38  KNOWLEDGE THE PLANES
	--	8	CLIMB								39  PERFORM ACTING
	-	9	HEAL								40  PERFORM DANCE
	-	10	HIDE								41  PERFORM ORATORY
	-	11	INTIMIDATE							42  PERFORM STRINGED INSTRUMENTS
	-	12	LISTEN								43  PERFORM SING
	-	13	BALANCE								44  PERFORM PERCUSSION
	-	14	MOVE SILENTLY					
	-	15	OPEN LOCK							45  PERFORM WIND INSTRUMENTS
	-	16	PARRY								46  PERFORM COMEDY
		17	PERFORM KEYBOARD					47  PROFESSION
	-	18	RIDE								48  SENSE MOTIVE 
	-	19	SEARCH								49  SPEAK LANGUAGE
	-	20	DECIPHER SCRIPT						50  SWIM
	-	21	SLEIGHT OF HAND						51  USE ROPE
	-	22	SPELLCRAFT							52  KNOWLEDGE GEOGRAPHY
	-	23	SPOT								53  KNOWLEDGE NOBILITY
	-	24	SURVIVAL							54  KNOWLEDGE ENGINEERING
	-	25	DIGUISE								55  KNOWLEDGE LOCAL
	-	26	TUMBLE								
	-	27	USE MAGIC DEVICE
	    28  KNOWLEDGE DUNGEONEERING
		29  ESCAPE ARTIST
		30  FORGERY
*/	
// BMA-OEI 9/02/05
// UPDATED FOR ALFA SKILLS  ARRI 10/21/2025

#include "ginc_param_const"
#include "acr_skills_i"

int StartingConditional(int nSkill, int nRank)
{
	object oPC = GetPCSpeaker();
	int nSkillVal = GetSkillConstant(nSkill);
	
	if (GetSkillRank(nSkillVal, oPC) >= nRank)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}