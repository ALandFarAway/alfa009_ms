const int maxDifficulty = 30; // how many levels do you want to have?
const int startDC = 10; // the starting DC
const int dcIncrease = 1; // how much does the dc increase with each level?

void PlayCustomAnimationWrapper(object oTarget, string sAnim, int bLoop)   
{
    PlayCustomAnimation(oTarget,sAnim,bLoop);
}
void main(){

    object oPC = GetLastUsedBy();
    int iDifficulty = GetLocalInt(oPC, "DIFF");

    if(iDifficulty == maxDifficulty) // if the PC is already at the max difficulty, go back to level 1
        iDifficulty = 1;
    else // else increase difficulty by 1 (if it is 0, which means no variable set yet, it goes to 1
        iDifficulty++;
        
    SetLocalInt(oPC, "DIFF", iDifficulty); // you set the variable for next time
    
    int iDC = startDC + dcIncrease * (iDifficulty -1); // the -1 is because we do not want an increase at first level
    
    int nSave = FortitudeSave(oPC, iDC, SAVING_THROW_TYPE_POISON);

    if(nSave >= SAVING_THROW_CHECK_SUCCEEDED) // the >= also covers the immune case
    {
        PlayCustomAnimationWrapper(oPC,"drunk", TRUE);//do your stuff
    }

    
    else if (nSave == SAVING_THROW_CHECK_FAILED)
    {
      PlayCustomAnimationWrapper(oPC,"collapsedB", TRUE); //do your other stuff
    }    
}