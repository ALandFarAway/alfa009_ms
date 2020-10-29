// gc_global_int

//  Set this variable on the Conditionals of the Welcome back line 
//  this line needs to be above the  1st meeting line in the convo tree
//  Arri creation 11/2015

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