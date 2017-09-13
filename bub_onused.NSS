
//bub_onused


#include "nw_i0_generic"
void main()
{

object oPC = GetLastUsedBy();
if (!GetIsPC(oPC)) return;

	
if (GetTag(OBJECT_SELF) == "bub_painting_a1")
	{
	ActionStartConversation(oPC, "bub_painting_a1");
   return;
   }

if (GetTag(OBJECT_SELF) == "bub_painting_a2")
	{
	ActionStartConversation(oPC, "bub_painting_a2");
   return;
   }
   
if (GetTag(OBJECT_SELF) == "bub_painting_a3")
	{
	ActionStartConversation(oPC, "bub_painting_a3");
   return;
   }
   
if (GetTag(OBJECT_SELF) == "bub_painting_a4")
	{
	ActionStartConversation(oPC, "bub_painting_a4");
   return;
   }
   
if (GetTag(OBJECT_SELF) == "bub_control_book1")
	{
	ActionStartConversation(oPC, "mod_ctrl_book");
   return;
   }
   


if (GetTag(OBJECT_SELF) == "shore_to_boat")
	{
	object oTarget;
	location lTarget;
	oTarget = GetWaypointByTag("shore_to_boat_wp1");
	
	lTarget = GetLocation(oTarget);
	
	if (GetAreaFromLocation(lTarget)==OBJECT_INVALID) return;
	
	oTarget=GetFirstFactionMember(oPC, FALSE);

	while (GetIsObjectValid(oTarget))
   {
   AssignCommand(oTarget, ClearAllActions());

   AssignCommand(oTarget, ActionJumpToLocation(lTarget));
   oTarget=GetNextFactionMember(oPC, FALSE);
   }
   return;
   }
   
if (GetTag(OBJECT_SELF) == "builder_store_statue")
	{
	ActionStartConversation(oPC, "character_builder_store");
	return;
   }
   
if (GetTag(OBJECT_SELF) == "c_a1_pit")
	{
	ActionStartConversation(oPC, "c_a1_trap");
   return;
   }
   
if (GetTag(OBJECT_SELF) == "c_a1_sled")
	{
	ActionStartConversation(oPC, "c_a1_sled");
   return;
   }
   
if (GetTag(OBJECT_SELF) == "ladder_to_b13")
	{
	ActionStartConversation(oPC, "c1_ladder_b13");
   return;
   }
   
if (GetTag(OBJECT_SELF) == "ladder_to_b68")
	{
	ActionStartConversation(oPC, "c1_ladder_b68");
   return;
   }
   
if (GetTag(OBJECT_SELF) == "b08_garbage")
	{
	ActionStartConversation(oPC, "b08_garbage");
   return;
   }
   
if (GetTag(OBJECT_SELF) == "b18_ladder1")
	{
	ActionStartConversation(oPC, "b18_ladder1");
   return;
   }
   
   

	
}