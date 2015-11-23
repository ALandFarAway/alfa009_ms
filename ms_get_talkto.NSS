// gc_global_int

 
//  Wynna: 9-11-2008  creation

#include "ginc_var_ops"
#include "acr_db_persist_i"


int StartingConditional()

{
	object oPC = GetPCSpeaker();
	object oOwner = OBJECT_SELF;	
	string sValuePC = ACR_GetPersistentString(oPC, GetName(oOwner) + "Talkto");
	if(sValuePC == "Known")
			return TRUE;
		else 
		 	return FALSE;
}