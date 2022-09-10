void PrepForDestruction(object oTarget)
{
	SetPlotFlag(oTarget,FALSE);
    SetImmortal(oTarget,FALSE);
    AssignCommand(oTarget,SetIsDestroyable(TRUE,FALSE,FALSE));
}



void CreateEffects(object oPC, object oArea)
{

object oCreature = GetObjectByTag("invisibleman");
object oBoulder = GetObjectByTag("boulders_l");

ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectNWN2SpecialEffectFile("fx_rockslide_after"), oCreature);

effect eShake = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eShake, GetLocation(oPC));

PrepForDestruction(oCreature);
DestroyObject(oCreature,0.5); 
PrepForDestruction(oBoulder);
DestroyObject(oBoulder,0.5); 

}

void CreateCreature(object oPC)
{

CreateObject(OBJECT_TYPE_CREATURE, "invisibleman", GetLocation(oPC), FALSE);
CreateObject(OBJECT_TYPE_PLACEABLE, "boulders_l", GetLocation(oPC), FALSE);

}


void main()
{

object oPC = GetFirstPC();
object oArea = GetObjectByTag("sanctumhalls");

//if(!GetGlobalInt("cavecollapse")) return;

if(GetArea(oPC) != oArea) return;

DelayCommand(4.0,CreateCreature(oPC));

DelayCommand(4.2,CreateEffects(oPC,oArea));


}