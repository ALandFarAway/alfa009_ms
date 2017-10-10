// 'spellhook_geas'

const string sTAG_GEAS = "009_necromancy_geas";


void main()
{
    object oCaster = OBJECT_SELF;

    object oGeas = GetItemPossessedBy(oCaster, sTAG_GEAS);
    if (GetIsObjectValid(oGeas))
    {
        //int SPELL_SCHOOL_NECROMANCY = 7;
        // note: If you find a core function that gets the spellschool
        //       it should be used instead of ->

        if (Get2DAString("spells", "School", GetSpellId()) == "N") // spell is Necromantic
        {
            effect eGeas = EffectDamage(d6(3),
                                        DAMAGE_TYPE_MAGICAL,
                                        DAMAGE_POWER_NORMAL,
                                        TRUE);
            DelayCommand(0.1f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eGeas, oCaster));
        }
    }
}