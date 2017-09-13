
// bub_id_OnClientEnter
// start conversation, spawn slavemerchant
// bealzebub 1/1/2012


void TalkOnEnter()
{

object oPC = GetEnteringObject();

if (!GetIsPC(oPC)) return;

object oArea = GetArea(GetFirstPC());
string sConv = GetLocalString(oArea, "Conversation");
string sTalker = GetLocalString(oArea, "Talker");
int iDone = GetLocalInt(oArea, "TalkDone");


if (GetGlobalInt("oric_talk")== 1)
	{
	
	object oTarget;
	object oSpawn;
	location loc1;
	location loc2;
	location loc3;
	location loc4;
	location loc5;
	
	oTarget = GetWaypointByTag("id_guard_spawn1");
	loc1 = GetLocation(oTarget);
	oTarget = GetWaypointByTag("id_guard_spawn2");
	loc2 = GetLocation(oTarget);
	oTarget = GetWaypointByTag("id_guard_spawn3");
	loc3 = GetLocation(oTarget);
	oTarget = GetWaypointByTag("id_slave_merchant_spawn");
	loc4 = GetLocation(oTarget);
	oTarget = GetWaypointByTag("id_oric_spawn2");
	loc5 = GetLocation(oTarget);
	
	oSpawn = CreateObject(OBJECT_TYPE_CREATURE, "id_bodyguard1", loc1);
	oSpawn = CreateObject(OBJECT_TYPE_CREATURE, "id_bodyguard1", loc2);
	SetTag(oSpawn, "id_bodyguard2");
	oSpawn = CreateObject(OBJECT_TYPE_CREATURE, "id_bodyguard1", loc3);
	SetTag(oSpawn, "id_bodyguard3");
	oSpawn = CreateObject(OBJECT_TYPE_CREATURE, "id_slave_merchant1", loc4);
	oSpawn = CreateObject(OBJECT_TYPE_CREATURE, "bub_oric", loc5);
	
	SetGlobalInt ("oric_talk", 2);
	}

if (iDone != 1)
	
	{
	SetLocalInt(oArea, "TalkDone", 1);
	AssignCommand(GetFirstPC(), ActionStartConversation(GetObjectByTag(sTalker),sConv, FALSE, FALSE, TRUE, FALSE));

	DelayCommand(0.2, TalkOnEnter());
	
	return;
	}


}



