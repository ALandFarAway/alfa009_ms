// Arri 11/2015 creation
//set this in the  actions of the line of the convo that the PC first hears
// the set line must be below the welcome back line
//  add variable to the NPC using the convo   Talkto = Known

#include "ginc_var_ops"
#include "acr_db_persist_i"

void main()

{
	object oPC = GetPCSpeaker();
	object oOwner = OBJECT_SELF;	
	ACR_SetPersistentString(oPC, GetName(oOwner) + "Talkto","Known" );
	 
}