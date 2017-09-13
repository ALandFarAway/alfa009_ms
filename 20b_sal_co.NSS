// 20b_sal_co
//
// Conversation switcher for Sal
	
// EPF 3/21/06
	
//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT4
/*
  Default OnConversation event handler for NPCs.

 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////
// ChazM - 4/21/05 modified so NPC's can stay focused
// ChazM 1/6/06 set local int to notify WalkWayPoints it should kickstart immediately.

#include "nw_i0_generic"
#include "ginc_behavior"

void main()
{

     // See if what we just 'heard' matches any of our
    // predefined patterns
    int nMatch = GetListenPatternNumber();
    object oShouter = GetLastSpeaker();
    int iFocused = GetIsFocused();

    if (nMatch == -1)
    {

            ClearActions(CLEAR_NW_C2_DEFAULT4_29);

			if(GetGlobalInt("00_nAct") == 2)
			{
            	BeginConversation("20_sal");
			}
			else
			{
				BeginConversation();
			}
    
    }   
    // Respond to shouts from friendly non-PCs only
    else if (GetIsObjectValid(oShouter)
               && !GetIsPC(oShouter)
               && GetIsFriend(oShouter)
               && (iFocused <= FOCUSED_STANDARD) )
    {
        object oIntruder = OBJECT_INVALID;
        // Determine the intruder if any
        if(nMatch == 4)
        {
            oIntruder = GetLocalObject(oShouter, "NW_BLOCKER_INTRUDER");
        }
        else if (nMatch == 5)
        {
            oIntruder = GetLastHostileActor(oShouter);
            if(!GetIsObjectValid(oIntruder))
            {
                oIntruder = GetAttemptedAttackTarget();
                if(!GetIsObjectValid(oIntruder))
                {
                    oIntruder = GetAttemptedSpellTarget();
                    if(!GetIsObjectValid(oIntruder))
                    {
                        oIntruder = OBJECT_INVALID;
                    }
                }
            }
        }

        // Actually respond to the shout
        if (iFocused <= FOCUSED_STANDARD)
            RespondToShout(oShouter, nMatch, oIntruder);
    }

    // Send the user-defined event if appropriate
    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DIALOGUE));
    }
}