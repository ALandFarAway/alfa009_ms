// created by  FoamBats4all
//matches up with alfa_blindfold in items


const string VAR_BLINDFOLDED = "TMP_BLINDFOLDED";

int GetIsDesiredBlindnessEffect( effect e ) {
    if ( GetEffectType( e ) != EFFECT_TYPE_BLINDNESS ) return FALSE;
    if ( GetEffectSubType( e ) != SUBTYPE_SUPERNATURAL ) return FALSE;
    if ( GetEffectCreator( e ) != OBJECT_SELF ) return FALSE;
    return TRUE;
}

void main()
{
    object oPC = GetPCItemLastEquippedBy();

    if ( GetLocalInt( oPC, VAR_BLINDFOLDED ) == TRUE ) {
        // PC is blindfolded. Remove effect.
        effect e = GetFirstEffect( oPC);
        effect eBlindness = SupernaturalEffect(EffectBlindness());
        while( GetIsEffectValid( e ) ) {
            if ( GetIsDesiredBlindnessEffect( e ) ) {
                RemoveEffect( oPC, e );
                DeleteLocalInt( oPC, VAR_BLINDFOLDED );
                return;
            }
            e = GetNextEffect( oPC );
        }
    } else {
        // PC is not blindfolded. Add effect.
        effect eBlindness = SupernaturalEffect(EffectBlindness());
        ApplyEffectToObject( DURATION_TYPE_PERMANENT, eBlindness, oPC );
        SetLocalInt( oPC, VAR_BLINDFOLDED, TRUE );
    }
}