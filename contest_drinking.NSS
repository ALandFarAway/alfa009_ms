const int maxDifficulty = 25; // how many levels do you want to have?
const int startDC = 10; // the starting DC
const int dcIncrease = 1; // how much does the dc increase with each level?

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
        PlayCustomAnimation(OBJECT_SELF,"drunk", 1);//do your stuff
    }

    
    else if (nSave == SAVING_THROW_CHECK_FAILED)
    {
      PlayCustomAnimation(OBJECT_SELF,"collapseB", 3); //do your other stuff
    }    
}