// on_enter_rock_fall
/*
    This is an On Enter script for a custom trigger. It
    simulates debris falling on the entering PC. This is
    suitable for caverns or mines with weakened roofs.
    If the trigger has a local integer named "d6damage",
    up to that many d6 dice of bludgeoning damage is
    applied to any targets in the area of effect. That
    parameter is also used to compute the DCs for the
    saving throws.
	The trigger needs to have a "d6damage" integer variable set to 
	a non-zero value. Otherwise all it does is perform a knockdown check.
	 It's mentioned in the comments for the DoRockslideDamage 
*/
// 08jul12 RJH

#include "ginc_effect"

const string HAS_RUN = "has_run_before";
const string D6_DAMAGE = "d6damage";
const string IPOINT_RESREF = "plc_ipoint "; // Deliberate space
const string SPEAKER_TAG = "RockFallIPoint";
const string ROCKSLIDE_SEF = "fx_rockslide.sef";
const string AFTERMATH_SEF = "fx_rockslide_after.sef";
const string CRUMBLE_WAV = "as_cv_bldgcrumb1";
const float IMPACT_DELAY = 1.5f; // Time based on CRUMBLE_WAV

// Cause the IPoint to self-destruct
void CleanupIPoint()
{
    string sTag = GetTag( OBJECT_SELF );
    if ( StringCompare( sTag, SPEAKER_TAG ) == 0 )
        DestroyObject( OBJECT_SELF, 0.1f, FALSE );
}

/*    This routine applies damage to each target in the area,
    whether friend or foe. The number of d6-dice of damage
    is determined by the local "d6damage" variable. A
    Reflex check is made to reduce or avoid any damage at
    DC = 10 + (d6-dice/2). A Strength check is made by
    each target at DC 15 + (d6-dice/2) to see if a half-
    round knockdown effect is applied. 
*/
void DoRockslideDamage()
{
    object oLeader = GetFactionLeader( GetFirstPC() );
    location locSpeaker = GetLocation( OBJECT_SELF );
    effect eImpact = EffectVisualEffect( 354 );
    effect eTrip = EffectKnockdown();
    float fDelay;
    
    int nDamageDice = GetLocalInt( OBJECT_SELF, D6_DAMAGE );
    int nSaveDC = 10 + ( nDamageDice / 2 );
    
    // Cycle through the creatures in the spherical shape
    object oTarget = GetFirstObjectInShape( SHAPE_SPHERE,
        RADIUS_SIZE_HUGE, locSpeaker, TRUE );
    while ( GetIsObjectValid( oTarget ) ) {
        // Use the distance to the target to calculate the delay
        location locTarget = GetLocation( oTarget );
        fDelay = GetDistanceBetweenLocations( locSpeaker, locTarget ) / 20;
        
        // Roll damage
        int nDamage = 0;
        if ( nDamageDice > 0 ) {
            nDamage = d6( nDamageDice );
            nDamage = GetReflexAdjustedDamage( nDamage, oTarget,
                nSaveDC, SAVING_THROW_TYPE_TRAP );
        }
        
        // Apply concussion damage, if any
        if ( nDamage > 0 ) {
            effect eDamage = EffectDamage( nDamage,
                DAMAGE_TYPE_BLUDGEONING );
            DelayCommand( fDelay + 0.1f, ApplyEffectAtLocation(
                DURATION_TYPE_INSTANT, eImpact, locTarget ) );
            DelayCommand( fDelay + 0.2f, ApplyEffectToObject(
                DURATION_TYPE_INSTANT, eDamage, oTarget ) );
        }
        
        // Do an opposed Strength check
        int nSourceStrChk = d20() + 15 + ( nDamageDice / 2 );
        int nTargetStrChk = d20() + GetAbilityScore( oTarget, ABILITY_STRENGTH );
        if ( nSourceStrChk >= nTargetStrChk ) {
            // Apply a knockdown
            DelayCommand( fDelay + 0.2f, ApplyEffectToObject(
                DURATION_TYPE_TEMPORARY, eTrip, oTarget, 3.0f ) );
        }
        
        // Select the next target within the shape
        oTarget = GetNextObjectInShape( SHAPE_SPHERE,
            RADIUS_SIZE_HUGE, locSpeaker, TRUE );
    }
}

// Run a sequence of effects to simulate a rockslide
void DoRockslide( int nDamageDice )
{
    float fDelay = IMPACT_DELAY; // Delay between sound and rockfall
    
    // Store the damage dice on the speaker
    SetLocalInt( OBJECT_SELF, D6_DAMAGE, nDamageDice );
    
    // Set the stage with a crumbling noise
    DelayCommand( 0.1f, PlaySound( CRUMBLE_WAV ) );
    
    // Apply the initial rockslide effect
    location locSpeaker = GetLocation( OBJECT_SELF );
    DelayCommand( fDelay, ApplySEFToLocation(
        ROCKSLIDE_SEF, locSpeaker, 4.0f ) );
    
    // Apply a shudder impact effect
    effect eImpact = EffectVisualEffect( 460 );
    DelayCommand( fDelay + 0.1f, ApplyEffectAtLocation(
        DURATION_TYPE_INSTANT, eImpact, locSpeaker ) );
    
    // Run the damage routine
    DelayCommand( fDelay + 0.6f, DoRockslideDamage() );
    
    // Apply an aftermath effect
    DelayCommand( fDelay + 1.0f, ApplySEFToLocation(
        AFTERMATH_SEF, locSpeaker, 5.0f ) );
    
    // Perform cleanup
    DelayCommand( 30.0f, CleanupIPoint() );
}

void main()
{
    // Check if this has been triggered before
    int bHasRun = GetLocalInt( OBJECT_SELF, HAS_RUN );
    if ( bHasRun )
        return;
    SetLocalInt( OBJECT_SELF, HAS_RUN, TRUE );
    
    // Check if the entering object is valid
    object oTarget = GetEnteringObject();
    if ( ! GetIsObjectValid( oTarget ) )
        return; // Invalid object
    
    // Only continue if the entering object is player controlled
    if ( ! GetIsPC( oTarget ) )
        return;
    
    // This creates an IPoint to run the rockslide
    location locTarget = GetLocation( oTarget );
    object oSpeaker = CreateObject( OBJECT_TYPE_PLACEABLE,
        IPOINT_RESREF, locTarget, FALSE, SPEAKER_TAG );
    if ( GetIsObjectValid( oSpeaker ) ) {
        // Run the rockslide from the IPoint
        SetFirstName( oSpeaker, "Rock fall" );
        int d6damage = GetLocalInt( OBJECT_SELF, D6_DAMAGE );
        AssignCommand( oSpeaker, DoRockslide( d6damage ) );
    }
}