// 'plc_explode'

void main()
{
    if (!GetLocalInt(OBJECT_SELF, "done"))
    {
        object oPC = GetLastHostileActor();
        if (GetIsObjectValid(oPC))
        {
            SetLocalInt(OBJECT_SELF, "done", TRUE);

            AssignCommand(oPC, ClearAllActions(TRUE));

            effect eVis1 = EffectBeam(VFX_BEAM_LIGHTNING, OBJECT_SELF, BODY_NODE_CHEST);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis1, oPC, 2.5f);

            effect eVis2 = EffectVisualEffect(VFX_HIT_SPELL_LIGHTNING);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis2, oPC, 2.5f);

            effect eElec = EffectDamage(d10(3), DAMAGE_TYPE_ELECTRICAL, DAMAGE_POWER_ENERGY);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eElec, oPC);

            DestroyObject(OBJECT_SELF);
        }
    }
}