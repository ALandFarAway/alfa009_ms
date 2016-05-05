// ms_pub_sit_hb
/*
    This is a custom heartbeat script adopted from
    3030_fplace_dwarf_hb in the original campaign.
    It is used by seated, non-bark stringing NPCs.
*/
// 25apr12 RJH

#include "ginc_misc"
#include "ginc_math"
#include "ginc_wp"
#include "acr_creature_i"


const string CURR_ANIM = "CurrAnim";
const int ANIM_IDLE = 0;
const int ANIM_DRINK = 1;
const int ANIM_TALK = 2;

void PlayCustomLoopingAnimation(object oObject, string sAnimationName)
{
    PlayCustomAnimation(oObject, sAnimationName, 1);
}

void PlayCustomOneShotAnimation(object oObject, string sAnimationName)
{
    PlayCustomAnimation(oObject, sAnimationName, 0);
}

// Perform an animation of the same type
void RepeatAnim( object oActor )
{
    int nLastAnim = GetLocalInt( oActor, CURR_ANIM );
    switch ( nLastAnim ) {
        case ANIM_IDLE:
        default:
            if ( d2(1) == 1 ) {
                PlayCustomLoopingAnimation(oActor, "sitidle");
            } else {
                PlayCustomLoopingAnimation(oActor, "sitfidget");
            }
            break;
        case ANIM_DRINK:
            if ( d2(1) == 1 ) {
                PlayCustomLoopingAnimation(oActor, "sitdrink");
            } else {
                PlayCustomLoopingAnimation(oActor, "sitdrinkidle");
            }
            break;
        case ANIM_TALK:
            if ( d2(1) == 1 ) {
                PlayCustomLoopingAnimation(oActor, "sittalk01");
            } else {
                PlayCustomLoopingAnimation(oActor, "sittalk02");
            }
            break;
    }
}

// Perform a random animation
void RandomAnim( object oActor )
{
    int nNextAnim = ANIM_IDLE;
    int nRandom = d10(1);
    switch( nRandom ) {
        case 0:
            PlayCustomLoopingAnimation(oActor, "sitidle");
            break;
        case 1:
            PlayCustomLoopingAnimation(oActor, "sitfidget");
            break;
        case 2:
        case 3:
            PlayCustomLoopingAnimation(oActor, "sitdrink");
            nNextAnim = ANIM_DRINK;
            break;
        case 4:
        case 5:
            PlayCustomLoopingAnimation(oActor, "sitdrinkidle");
            nNextAnim = ANIM_DRINK;
            break;
        case 6:
        case 7:
            PlayCustomLoopingAnimation(oActor, "sittalk01");
            nNextAnim = ANIM_TALK;
            break;
        case 8:
        case 9:
            PlayCustomLoopingAnimation(oActor, "sittalk02");
            nNextAnim = ANIM_TALK;
            break;
        default:
            PlayCustomLoopingAnimation(oActor, "sitidle");
            break;
    }
    SetLocalInt( oActor, CURR_ANIM, nNextAnim );
}

void main()
{
    if (GetAILevel(OBJECT_SELF) == AI_LEVEL_VERY_LOW)
    {
        return;
    }
    
    object oActor = OBJECT_SELF;
    
    if (GetLocalInt(oActor, "SetDefaultAnimation") == 0)
    {
        AssignCommand(oActor, PlayCustomLoopingAnimation(oActor, "sitidle"));
        SetLocalInt(oActor, "SetDefaultAnimation", 1);
    }
    
    if ( d10(1) < 6 ) {
        RepeatAnim( oActor );
    } else {
        RandomAnim( oActor );
    }
}