// '009_it_cr_cl_leechwalker'

#include "acr_spells_i"  // HasSizeIncreasingSpellEffect()
//#include "x0_i0_spells"   // GetSizeModifier()


const int iGRAPPLE_DC = 12; // the higher this is, the harder the grapple is to avoid.

//
void main()
{
    SendMessageToPC(GetFirstPC(FALSE), "i_leechwalkerclaw_hc");

    object oItem = GetSpellCastItem();
    SendMessageToPC(GetFirstPC(FALSE), ". item= " + GetName(oItem));

    object oTarget = GetSpellTargetObject();
    SendMessageToPC(GetFirstPC(FALSE), ". target= " + GetName(oTarget));

    object oCreature = OBJECT_SELF;
    SendMessageToPC(GetFirstPC(FALSE), ". self= " + GetName(oCreature));



    int iAttackRoll = d20() + iGRAPPLE_DC
                    + GetAbilityModifier(ABILITY_STRENGTH, oCreature)
                    + GetBaseAttackBonus(oCreature)
                    + GetSizeModifier(oCreature)
                    + (HasSizeIncreasingSpellEffect(oCreature) ? 4 : 0);

    int iTargetRoll = d20()
                    + GetAbilityModifier(ABILITY_STRENGTH, oTarget)
                    + GetBaseAttackBonus(oTarget)
                    + GetSizeModifier(oTarget)
                    + (HasSizeIncreasingSpellEffect(oTarget) ? 4 : 0);

    SendMessageToPC(GetFirstPC(FALSE), ". . attack= " + IntToString(iAttackRoll));
    SendMessageToPC(GetFirstPC(FALSE), ". . target= " + IntToString(iTargetRoll));

    if (iAttackRoll >= iTargetRoll)
    {
        effect eDecrease = EffectAbilityDecrease(ABILITY_CONSTITUTION, 5);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDecrease, oTarget, RoundsToSeconds(1));

        effect eImpact = EffectVisualEffect(VFX_IMP_BIGBYS_FORCEFUL_HAND);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget);
    }
}