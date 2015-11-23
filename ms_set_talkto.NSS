 
// Arri 11/2015 creation

#include "ginc_var_ops"
#include "acr_db_persist_i"

void main()

{
	object oPC = GetPCSpeaker();
	object oOwner = OBJECT_SELF;	
	ACR_SetPersistentString(oPC, GetName(oOwner) + "Talkto","Known" );
	 
}