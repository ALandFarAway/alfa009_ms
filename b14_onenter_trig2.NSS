
// b14_OnEnter_trig2


#include "x0_i0_partywide"


void main()
{
    object oActor;
    object oPC = GetEnteringObject();

    if ( !GetIsPC(oPC)  ||  GetIsDMPossessed(oPC) )
        return;

    if ( !GetIsItemPossessedByParty(oPC, "bub_blackopal") )
        return;

    oActor = GetNearestObjectByTag("b18_eleena", oPC);
    AssignCommand(oActor, ActionStartConversation(oPC, "b18_eleena"));
}