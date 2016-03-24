#include "hench_i0_ai"
#include "ginc_behavior"
//#include "acr_creature_i"
#include "x0_i0_assoc"
#include "x0_i0_enemy"


int GetIsBroken(object oTesting, object oPerceived)
	{
	  if (!GetIsPC(oPerceived))
	  {
	  return 0;
	  }
	
		// Morale check code Teric neDhalir 0707
		// Morale check dice roll 2D10
		int iRoll = d10(2);
		// Morale rating (set on creature as variable int SJC_MORALERATING.
		// A variable of 0 means the creature will always avoid PCs
		int iRating = GetLocalInt(oTesting,"SJC_MORALERATING");
		
		if  (iRating == 0)
			{return 1;}
		
		else
		{// Check for amount of damage sustained and set die modifier accordingly
		int iDamageModifier;
		int iDamage = GetPercentageHPLoss(oTesting);
			if 
			(iDamage <= 50)
			{iDamageModifier = -4;}
			else if
			(iDamage <= 75)
			{iDamageModifier = -2;}
			else
			{iDamageModifier = 0;}
		// Check for alignment and set die modifier accordingly
		int iAlignmentModifier;
		int iAlignment = GetLawChaosValue(oTesting);
			if 
			(iAlignment <= 33)
			{iAlignmentModifier = -1;}
			else if
			(iAlignment >= 66)
			{iAlignmentModifier = 1;}
			else
			{iAlignmentModifier = 0;}
		// Check for ratio of enemies to allies
		int iOutnumberModifier;
		// Reduced range to creature perception distance
		struct sSituation sitCurr = CountEnemiesAndAllies(35.0f,oTesting);
		int nNumEnemies = sitCurr.ENEMY_NUM;
		int nNumAllies = sitCurr.ALLY_NUM;
		
		// AcadiusLost - escape the DIVIDE BY ZERO case.
		// Teric: Commented this out, because creatures that are never hostile dealt with
		// in the SJC_MORALERATING == 0 case above
		//    if (nNumEnemies == 0) { return;}
			
			if
			(nNumEnemies / (nNumAllies + 1) == 1)
			{iOutnumberModifier = 0;}
			else if
			((nNumAllies + 1) > nNumEnemies)
			{iOutnumberModifier = (nNumAllies + 1) / nNumEnemies;}
			else
			{iOutnumberModifier = -(nNumEnemies / (nNumAllies + 1));}
		// Check for CR of testing creature
		int iCRModifier;
			if
			(GetChallengeRating(oTesting) > 7.5)
			{iCRModifier = 3;}
			else if
			(GetChallengeRating(oTesting) > 4.5)
			{iCRModifier = 2;}
			else if
			(GetChallengeRating(oTesting) > 2.0)
			{iCRModifier = 1;}
			else if
			((GetChallengeRating(oTesting) < 0.5) & (GetChallengeRating(OBJECT_SELF) > 0.25))
			{iCRModifier = -1;}
			else if
			(GetChallengeRating(oTesting) < 0.25)
			{iCRModifier = -2;}
			else 
			{iCRModifier = 0;}
		// Give bonus if perceived creature is injured Teric 031209
			int iWoundedModifier;
			if (GetPercentageHPLoss(oPerceived) < 25)
			{iWoundedModifier = 3;}
			else if (GetPercentageHPLoss(oPerceived) < 100)
			{iWoundedModifier = 1;}
			else
			{iWoundedModifier = 0;}
		// Work out die roll needed to pass morale test
		int iFinalScore;
		//object oTarget = GetNearestSeenEnemy(OBJECT_SELF,1);
		iFinalScore = iRating + iDamageModifier + iAlignmentModifier + iOutnumberModifier + iCRModifier + iWoundedModifier;
		
		// Debugging message
		string sRoll = IntToString(iRoll);
		string sRating = IntToString(iRating);
		string sDamage = IntToString(iDamageModifier);
		string sAlignment = IntToString(iAlignmentModifier);
		string sOutnumber = IntToString(iOutnumberModifier);
		string sCR = IntToString(iCRModifier);
		string sWounded = IntToString(iWoundedModifier);
		string sFinalScore = IntToString(iFinalScore);
		//SendMessageToPC( GetFirstPC(), (sRoll + "Rating " + sRating + "Damage " +  sDamage + "Alignment " +  sAlignment + "Outnumber " +  sOutnumber + "CR " +  sCR + " Wounded" + sWounded + "FinalSScore " +  sFinalScore) );	
		if (iRoll > iFinalScore)
			{return 1;}
		else
			{return 0;}

		// 		End morale test
		}
	}
	
void main()
{
object oExit = GetNearestObjectByTag("morale_baleout");
object oEnemy = GetLastPerceived();
if (!GetIsEnemy(oEnemy)) return;

if 	(GetLocalInt(OBJECT_SELF, "SJC_BROKEN") == 1)
		{
		//SendMessageToPC(GetFirstPC(), "broken");
		ClearAllActions(TRUE);
		ActionMoveToObject(oExit, TRUE, 0.0f);
		;
		} 
	
else if (GetIsBroken(OBJECT_SELF, oEnemy) && GetLastPerceptionSeen() == TRUE)
		{//SendMessageToPC(GetFirstPC(), "failed test");
		ClearAllActions(TRUE);
		ActionMoveToObject(oExit, TRUE, 0.0f);
		SetLocalInt(OBJECT_SELF, "SJC_BROKEN", 1);
		}
		
else
		{
		//SendMessageToPC(GetFirstPC(), "Doing default");
		ExecuteScript("nw_c2_default2", OBJECT_SELF);
		}	



}