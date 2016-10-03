// gb_heartbeat_sp

//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/11/2002
//:://////////////////////////////////////////////////
//:: Updated 2003-08-20 Georg Zoeller: Added check for variables to active spawn in conditions without changing the spawnscript


#include "x0_i0_anims"


void main()
{


    SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);

    WalkWayPoints();



}