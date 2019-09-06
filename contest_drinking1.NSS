//by andgalf on NWN2 creators channel
/*include "ginc_param_const"
#include "ginc_var_ops"

void PlayCustomAnimationWrapper(object oTarget, string sAnim, int bLoop)   
{
    PlayCustomAnimation(oTarget,sAnim,bLoop);
}

void main()
{

    object oPC=GetLastUsedBy(); 
    int nOldValue = GetLocalInt(oPC, "intoxicated");
    int nDC;
    
    nDC = 10; //just a number, don't know what the DC should be
    
    if(nOldValue == 1)
    {    
    nDC = nDC+1;    //again, don't know how much to increase the difficulty, just a number
    }
    
    else if(nOldValue == 2)
    {
    nDC = nDC+1; //again, don't know how much to increase the difficulty, just a number
    }
    
    else if(nOldValue >= 3)
    {
    nDC = nDC+1; //again, don't know how much to increase the difficulty, just a number
    }
    
    int nSave = FortitudeSave(oPC, nDC, SAVING_THROW_TYPE_POISON);

    if(nSave >= 1)
    {
    
    PlayCustomAnimationWrapper(oPC,"drink", TRUE);
	  PlayCustomAnimationWrapper(oPC,"drunk", TRUE);
      PlayCustomAnimationWrapper(oPC,"collapseB", TRUE);
    
    }

    
    else if (nSave == 0)
    {
    PlayCustomAnimationWrapper(oPC,"drunk", TRUE);
    int nNewValue = CalcNewIntValue(nOldValue, "+");
    SetLocalInt(oPC, "intoxicated", nNewValue);
    
    }


}*/



#include "ginc_param_const"
#include "ginc_var_ops"

void PlayCustomAnimationWrapper(object oTarget, string sAnim, int bLoop) 
{
    PlayCustomAnimation(oTarget,sAnim,bLoop);
}

void main()
{

    object oPC = GetClickingObject();
    int nOldValue = GetLocalInt(oPC, "intoxicated");
    int nDC;
    
    if (!GetLocalInt(oPC,"intoxicated"))
    {
    nDC = 10; //just a number, don't know what the DC should be
    }
    
    if(nOldValue >= 1)
    {    
    nDC = nDC+1;    
    }
    
    
    int nSave = FortitudeSave(oPC, nDC, SAVING_THROW_TYPE_POISON);

    if(nSave >= 1)
    {
    PlayCustomAnimationWrapper(oPC,"drink", TRUE);
	  PlayCustomAnimationWrapper(oPC,"drunk", TRUE);
    int nNewValue = CalcNewIntValue(nOldValue, "+");
    SetLocalInt(oPC, "intoxicated", nNewValue);
    
    }

    
    else if (nSave == 0)
    {

    PlayCustomAnimationWrapper(oPC,"drink", TRUE);
	  PlayCustomAnimationWrapper(oPC,"drunk", TRUE);
      PlayCustomAnimationWrapper(oPC,"collapseB", TRUE);
    
    }
 
}