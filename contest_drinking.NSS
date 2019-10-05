// by sve on NWN2 creator's channel


#include "ginc_param_const"

const int maxDifficulty = 30; 
const int startDC = 10;
const int dcIncrease = 1;

void SendTextToAllInArea(object oPC, string sMessage)
{
    object oArea = GetArea(oPC);
    object oPlayer = GetFirstPC(FALSE);
    while(GetIsObjectValid(oPlayer))
    {
        if(GetArea(oPlayer) == oArea && GetDistanceBetween(oPC,oPlayer) <= 20.0) 
            SendMessageToPC(oPlayer,sMessage);
        oPlayer = GetNextPC(FALSE);
    }
}

void main(){

    object oPC = GetLastUsedBy();
    int iDifficulty = GetLocalInt(oPC, "DRINKING");

    if(iDifficulty == maxDifficulty) // if the PC is already at the max difficulty, go back to level 1
        iDifficulty = 1;
    else // else increase difficulty by 1 (if it is 0, which means no variable set yet, it goes to 1
        iDifficulty++;
        
    SetLocalInt(oPC, "DRINKING", iDifficulty); // you set the variable for next time
    
    int iDC = startDC + dcIncrease * (iDifficulty -1); // the -1 is because we do not want an increase at first level
    
    int iRoll = d20(); // first we roll a dice
    int iFort = GetFortitudeSavingThrow(oPC); // the issue here is that if we do it manually we don't get any bonuses against poison, if present

    if(iRoll + iFort >= iDC) // the >= also covers the immune case
    {
	
	 AssignCommand(oPC,ActionPlayAnimation(ANIMATION_FIREFORGET_DRINK));
     AssignCommand(oPC,ActionPlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK));
	 
        SendTextToAllInArea(oPC, GetName(oPC) + " - Fortitude Save: " + IntToString(iRoll) + " + " + IntToString(iFort) + " against DC: " + IntToString(iDC) + ". SUCCESS!");
       
    }

    
    else
	
	
    {
	//	AssignCommand(oPC,ActionPlayAnimation(ANIMATION_FIREFORGET_DRINK)); 
     
	//	AssignCommand(oPC,ActionPlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK));
        
		
		SendTextToAllInArea(oPC,  GetName(oPC) + " - Fortitude Save: " + IntToString(iRoll) + " + " + IntToString(iFort) + " against DC: " + IntToString(iDC) + ". FAILURE!");
      
		PlayCustomAnimation(oPC, "collapseB", 1, 30.0);
		 
	
	   //	AssignCommand(oPC,ActionPlayAnimation(ANIMATION_FIREFORGET_DRINK)); 
     
		//AssignCommand(oPC,ActionPlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK));
		 
		AssignCommand(oPC,ActionPlayAnimation(ANIMATION_LOOPING_DEAD_FRONT)); 
	    //	PlayCustomAnimation(oPC, "proneB", 1, 10.0);
			
			
    }    
}
