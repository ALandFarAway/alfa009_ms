//bm_plc_hb_edm
//heartbeat for electrowhatsit
//when activated will seek out hostiles and zap them.
void main()
{
	int nCharges = GetLocalInt(OBJECT_SELF, "CHARGES");
	if((GetLocalInt(OBJECT_SELF, "ACTIVE") != 0) || (nCharges < 1)) return;
	
	object oPC = GetFirstPC();
	location lSphere = GetLocation(OBJECT_SELF);
	object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 15.0f, lSphere);
	
	while(!GetIsEnemy(oTarget, oPC))
		{
			oTarget = GetNextObjectInShape(SHAPE_SPHERE, 15.0f, lSphere);
		}
		
	object oOrigin = GetObjectByTag("bm_plc_edmorigin");
	effect eDam = EffectDamage(10, DAMAGE_TYPE_ELECTRICAL);
	effect eBeam = EffectBeam(VFX_BEAM_LIGHTNING, oOrigin, BODY_NODE_CHEST);
	effect eHit = EffectVisualEffect(VFX_HIT_SPELL_LIGHTNING);
	location lTarget = GetLocation(oTarget);
	
	nCharges--;
	SetLocalInt(OBJECT_SELF, "ACTIVE", 1);
	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, oTarget, 1.0f);
	ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eHit, lTarget, 1.0f);
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
	SetLocalInt(OBJECT_SELF, "CHARGES", nCharges);	
	DelayCommand(7.0f, SetLocalInt(OBJECT_SELF, "ACTIVE", 0));

}