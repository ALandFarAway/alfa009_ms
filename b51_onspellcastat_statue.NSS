
// b51_onspellcastat_statue
// bealzebub 8/18/2012
// thanks Pain and the CSL

#include "_CSLCore_class_c"
#include "_CSLCore_Feats_c"
#include "_SCInclude_CacheStats"

void main()

if ( GetName(GetAreaFromLocation(GetLocation(oCaster)))=="b51_wizard_guild" )
{
SCfizzleSpell("Start convo.", oCaster );

// trigger conversation here
DelayCommand(3.0, AssignCommand(oSpeaker, ActionStartConversation(oPC, "b51_examiner", FALSE, FALSE)));

	return;
}



{
	object oPC = GetLastSpellCaster(); 
	object oSpeaker = GetNearestObjectByTag("b51_examiner", oPC);	        	

	int iClass = 10;
	int iLevel = SCPrep_GetCasterLevel (iClass, oPC);			

  SendMessageToPC(oPC, "DEBUG- ");
	
	
	SetLocalInt(oSpeaker,"SpellCast", iLevel);
	
   

}