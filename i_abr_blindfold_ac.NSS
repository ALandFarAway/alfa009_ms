//
// On Use item script for abr_blindfold
//
// This script will apply blindness to the item's user. Additionally, it will
// create a blindfold VFX and apply it to the user.
//

// Local variable kept on the PC to keep track of their blindfold status.
const string VAR_BLINDFOLDED = "TMP_BLINDFOLDED";

// Checks an effect to see if it is the blindness effect we make.
int GetIsDesiredBlindnessEffect( effect e ) {
	if ( !GetIsEffectValid( e ) ) return FALSE;
	if ( GetEffectCreator( e ) != OBJECT_SELF ) return FALSE;
	if ( GetEffectType( e ) != EFFECT_TYPE_BLINDNESS ) return FALSE;
	if ( GetEffectSubType( e ) != SUBTYPE_SUPERNATURAL ) return FALSE;
	return TRUE;
}

// Fetches the effect file to use for the blindfold.
string GetSpecialEffectFileForBlindfold( object oTarget ) {
	string sEffectFile;
	
	int nRacialType = GetRacialType( oTarget );
	switch ( nRacialType ) {
		case RACIAL_TYPE_DWARF:
			sEffectFile = "acme_fx_blackdomino_dd";
			break;
		case RACIAL_TYPE_GNOME:
			sEffectFile = "acme_fx_blackdomino_gg";
			break;
		case RACIAL_TYPE_GRAYORC:
		case RACIAL_TYPE_HALFORC:
			sEffectFile = "acme_fx_blackdomino_oo";
			break;	
		case RACIAL_TYPE_ELF:
			sEffectFile = "acme_fx_blackdomino_dd";
			break;
		default:
			sEffectFile = "acme_fx_blackdomino_hh";
			break;
	}
	
	return sEffectFile;
}

void main() {
	// Get our target.
	object oPC = GetItemActivator();

	if ( GetLocalInt( oPC, VAR_BLINDFOLDED ) == TRUE ) {
		// PC is blindfolded. Remove effect.
		effect eBlindness = SupernaturalEffect(EffectBlindness());
		
		effect e = GetFirstEffect( oPC);
		while( GetIsEffectValid( e ) ) {
			// Delete blindness/blindfold effects.
			if ( GetIsDesiredBlindnessEffect( e ) ) {
				RemoveEffect( oPC, e );
			
			}
			
			e = GetNextEffect( oPC );
		}
		SendMessageToAllDMs( GetName( oPC ) + " has taken off their blindfold." );
		DeleteLocalInt( oPC, VAR_BLINDFOLDED );
	} else {
		// Add blindness effect.
		effect eBlindness = SupernaturalEffect( EffectBlindness() );
		effect eBlindfold = EffectNWN2SpecialEffectFile( GetSpecialEffectFileForBlindfold( oPC ) );
		effect eCombined = EffectLinkEffects( eBlindfold, eBlindness );
		ApplyEffectToObject( DURATION_TYPE_PERMANENT, eCombined, oPC );
		SendMessageToAllDMs( GetName( oPC ) + " has put on a blindfold." );
		SetLocalInt( oPC, VAR_BLINDFOLDED, TRUE );
	}
}