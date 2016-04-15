///put the script on a Generic Trigger's onEnter 
//Causes the nearest object with a tag of 'BeamStatue' to
// fire a cold beam at the PC that walks in front of it. 
//It currently does 2d8 points of damage. 



void main()
{
object oPC = GetEnteringObject();
object oStatue = GetNearestObjectByTag("BeamStatue");
effect eBeam = EffectBeam(VFX_BEAM_COLD,oStatue,BODY_NODE_HAND,FALSE);
effect eDMG = EffectDamage(d8(2) ,DAMAGE_TYPE_COLD);
ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eBeam,oPC,1.0);
ApplyEffectToObject(DURATION_TYPE_INSTANT,eDMG,oPC,0.0);
}