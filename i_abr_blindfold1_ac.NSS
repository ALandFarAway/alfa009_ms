//
// On Use item script for abr_blindfold
//
// This script will apply blindness to the item's user. Additionally, it will
// create a blindfold VFX and apply it to the user.
//


// 'blindfold'
/*
    OnItemActivated script.

    This script will apply heavy blindness effects to the PC (item-activator).
    Additionally, it will create a blindfold-VFX and apply it.
*/



// Local variable kept on the PC to keep track of their blindfold status.
const string VAR_BLINDFOLDED = "TMP_BLINDFOLDED";


// Checks an effect to see if it is this blindness.
int GetIsDesiredBlindnessEffect(effect eScan, object oPC);

// Fetches an effect-file to use for the blindfold-VFX.
string GetSpecialEffectFileForBlindfold(object oPC);


//
void main()
{
    object oPC = GetItemActivator();


    if (GetLocalInt(oPC, VAR_BLINDFOLDED))
    {
        DeleteLocalInt(oPC, VAR_BLINDFOLDED);

        effect eScan = GetFirstEffect(oPC);
        while (GetIsEffectValid(eScan))
        {
            if (GetIsDesiredBlindnessEffect(eScan, oPC))
            {
                RemoveEffect(oPC, eScan);
                eScan = GetFirstEffect(oPC);
            }
            else
                eScan = GetNextEffect(oPC);
        }

        SendMessageToAllDMs(GetName(oPC) + " has taken off their blindfold.");
    }
    else
    {
        SetLocalInt(oPC, VAR_BLINDFOLDED, TRUE);

        effect eBlind     = EffectBlindness();
        effect eDeaf      = EffectDeaf();
        effect eAC        = EffectACDecrease(2);
        effect eMoveDec   = EffectMovementSpeedDecrease(50);
        effect eSpot      = EffectSkillDecrease(SKILL_SPOT, 50);
        effect eSearch    = EffectSkillDecrease(SKILL_SEARCH, 4);
        effect eBlindfold = EffectNWN2SpecialEffectFile(GetSpecialEffectFileForBlindfold(oPC));

        effect eVis = EffectVisualEffect(VFX_DUR_SPELL_BLIND_DEAF);

        eVis = EffectLinkEffects(eVis, eBlind);
        eVis = EffectLinkEffects(eVis, eDeaf);
        eVis = EffectLinkEffects(eVis, eAC);
        eVis = EffectLinkEffects(eVis, eMoveDec);
        eVis = EffectLinkEffects(eVis, eSpot);
        eVis = EffectLinkEffects(eVis, eSearch);
        eVis = EffectLinkEffects(eVis, eBlindfold);

        int iDex = GetAbilityScore(oPC, ABILITY_DEXTERITY);
        if (iDex > 10)
        {
            int iDecr = iDex - 10;
            effect eDex = EffectAbilityDecrease(ABILITY_DEXTERITY, iDecr);
            eVis = EffectLinkEffects(eVis, eDex);
        }

        eVis = SupernaturalEffect(eVis);

        AssignCommand(oPC, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVis, oPC));

        SendMessageToAllDMs(GetName(oPC) + " has put on a blindfold.");
    }
}


// Checks an effect to see if it is this blindness.
int GetIsDesiredBlindnessEffect(effect eScan, object oPC)
{
    if (   GetIsEffectValid(eScan)
        && GetEffectCreator(eScan) == oPC
        && GetEffectType(eScan) == EFFECT_TYPE_BLINDNESS
        && GetEffectSubType(eScan) == SUBTYPE_SUPERNATURAL)
    {
        return TRUE;
    }
    return FALSE;
}

// Fetches an effect-file to use for the blindfold-VFX.
string GetSpecialEffectFileForBlindfold(object oPC)
{
    string sEffectFile;

    switch (GetRacialType(oPC))
    {
        case RACIAL_TYPE_DWARF:     sEffectFile = "acme_fx_blackdomino_dd"; break;
        case RACIAL_TYPE_GNOME:     sEffectFile = "acme_fx_blackdomino_gg"; break;
        case RACIAL_TYPE_GRAYORC:
        case RACIAL_TYPE_HALFORC:   sEffectFile = "acme_fx_blackdomino_oo"; break;
        case RACIAL_TYPE_ELF:       sEffectFile = "acme_fx_blackdomino_dd"; break;
        default:                    sEffectFile = "acme_fx_blackdomino_hh"; break;
    }
    return sEffectFile;
}
