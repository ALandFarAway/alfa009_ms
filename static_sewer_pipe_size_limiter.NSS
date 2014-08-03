#include "acr_skills_i"

// Only allow small creatures.
int CreatureCanFit( object oCreature ) {
	// Tiny creatures fit.
	if ( GetCreatureSize( oCreature ) < CREATURE_SIZE_SMALL ) return TRUE;
	
	// Small creatures fit, unless they're enlarged.
	if ( GetCreatureSize( oCreature ) == CREATURE_SIZE_SMALL ) {
		if ( GetHasSpellEffect( SPELL_ENLARGE_PERSON, oCreature ) ) return FALSE;
		if ( GetHasSpellEffect( SPELL_RIGHTEOUS_MIGHT, oCreature ) ) return FALSE;
		return TRUE;
	}
	
// Medium creatures can fit, if they're reduced.
        if ( GetCreatureSize( oCreature ) == CREATURE_SIZE_MEDIUM )  {
                if ( GetHasSpellEffect( SPELL_REDUCE_PERSON, oCreature ) ) return TRUE;
                if ( GetHasSpellEffect( SPELL_REDUCE_PERSON_GREATER, oCreature ) ) return TRUE;
                if ( GetHasSpellEffect( SPELL_REDUCE_PERSON_MASS, oCreature ) ) return TRUE;
                if ( ACR_SkillCheck( 35, oCreature, 25, TRUE ) ) {
				SendMessageToPC( oCreature, "Although the passage is tight, you manage to cram yourself in." );
				return TRUE;
				}else {
				SendMessageToPC( oCreature, "You attempt to fit through the passage, but your fat ass can't squeeze in." );
				return FALSE;
        }}
       
        // Otherwise, nope.
        return FALSE;
}
 
 
void main() {
        object oUser = GetLastUsedBy();
        if ( CreatureCanFit( oUser ) ) {
                // Code you want to happen here.
               
        SendMessageToPC(oUser, "You are able to wriggle through the Sewer pipe");
        AssignCommand(oUser, JumpToObject(GetWaypointByTag("WP_MYLOCATIONYO")));
        }
}