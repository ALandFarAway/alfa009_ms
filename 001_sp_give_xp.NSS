#include "acr_xp_i" 

void main(int nXpAmount)

{
    // Get the PC
    object oPC = GetPCSpeaker();

    // Give the experience
    ACR_GiveXPToPC(oPC, nXpAmount);
}


