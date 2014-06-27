////////////////////////////////////////////////////////////////////////////////
//
//  System Name : ACR Configuration File
//     Filename : 009_plc_onuse_effectswitch.nss
//         Date : 2013-01-21
//       Author : FoamBats4All
//
//  Description:
//  This script allows the builder to use a placeable to toggle a light and
//  effect on/off. For example, this script can be attached to a firestarter
//  near a fireplace. This script, when the placeable is used, would turn a
//  paired light and fire effect on.
//
//  To use this, place this script on a placeable you wish to be the toggler.
//  Next, you must set one or more local variables on the placeable to link
//  it the other objects in the area.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Includes ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Constants ///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Local variables. The name in the quotation marks must be placed on the object.
const string LVAR_LIGHT_TAG = "switcher_light_tag";               // string
const string LVAR_EFFECT_TAG = "switcher_effect_tag";             // string
const string LVAR_EFFECT_TEMPLATE = "switcher_effect_template";   // string
const string LVAR_EFFECT_ANIMATE = "switcher_effect_animate";     // int
const string LVAR_WAYPOINT_TAG = "switcher_waypoint_tag";         // string
const string LVAR_STATE = "switcher_state";                       // int
const string LVAR_SWITCH_TYPE = "switcher_type";                  // int
const string LVAR_SWITCH_ON_MSG = "switcher_on_msg";              // string
const string LVAR_SWITCH_OFF_MSG = "switcher_off_msg";            // string
const string LVAR_SWITCH_KEY = "switcher_key";                    // string
const string LVAR_SWITCH_KEY_MSG = "switcher_key_msg";            // string
const string LVAR_SWITCH_DISABLED = "switcher_disabled";          // int
const string LVAR_SWITCH_DISABLED_MSG = "switcher_disabled_msg";  // string

// These constants represent the different states the placeable can be in.
const int STATE_OFF = 0;
const int STATE_ON = 1;

// These constants represent how often/when the placeable can be switched.
const int SWITCH_TYPE_ALWAYS = 0;
const int SWITCH_TYPE_ONCE = 1;


////////////////////////////////////////////////////////////////////////////////
// Function Prototypes /////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Called when the placeable is used.
void main();

////////////////////////////////////////////////////////////////////////////////
// Function Definitions ////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void main() {
	// Get our objects.
	object oSwitcher = OBJECT_SELF;
	object oUser = GetLastUsedBy();
	
	// Is the waypoint configured?
	string sWaypointTag = GetLocalString( oSwitcher, LVAR_WAYPOINT_TAG );
	object oWaypoint = GetObjectByTag( sWaypointTag );
	if ( !GetIsObjectValid( oWaypoint ) ) {
		WriteTimestampedLogEntry( "EffectSwitcher : Could not find waypoint '" + sWaypointTag + "' on object '" + GetName( oSwitcher ) + "' in area " + GetTag( GetArea( oSwitcher ) ) + "." );
		SendMessageToPC( oUser, "<C=red>Invalidly configured switcher! Please report this bug.</C>" );
		return;
	}
	
	// Is the switcher disabled?
	if ( GetLocalInt( oSwitcher, LVAR_SWITCH_DISABLED ) == TRUE ) {
		string sMessage = GetLocalString( oSwitcher, LVAR_SWITCH_DISABLED_MSG );
		if ( sMessage != "" ) SendMessageToPC( oUser, sMessage );
		return;
	}
	
	// If a key is required, check for it.
	string sKey = GetLocalString( oSwitcher, LVAR_SWITCH_KEY );
	if ( sKey != "" ) {
		object oKey = GetItemPossessedBy( oUser, sKey );
		if ( !GetIsObjectValid( oKey ) ) {
			SendMessageToPC( oUser, GetLocalString( oSwitcher, LVAR_SWITCH_KEY_MSG ) );
			return;
		}
	}
	
	// Toggle the state.
	int nState = !GetLocalInt( oSwitcher, LVAR_STATE );
	SetLocalInt( oSwitcher, LVAR_STATE, nState );

	// If this is a once-only switch, disable it.
	int nSwitchType = GetLocalInt( oSwitcher, LVAR_SWITCH_TYPE );
	if ( nSwitchType == SWITCH_TYPE_ONCE ) {
		SetLocalInt( oSwitcher, LVAR_SWITCH_DISABLED, TRUE );
	}
	
	// Get the location of the waypoint.
	location lWaypoint = GetLocation( oWaypoint );
	
	// Change the light.
	string sLightTag = GetLocalString( oSwitcher, LVAR_LIGHT_TAG );
	if ( sLightTag != "" ) {
		object oLight = GetObjectByTag( sLightTag );
		if ( GetIsObjectValid( oLight ) ) {
			SetLightActive( oLight, nState );
		} else {
			WriteTimestampedLogEntry( "EffectSwitcher : Could not find light '" + sLightTag + "' on object '" + GetName( oSwitcher ) + "' in area " + GetTag( GetArea( oSwitcher ) ) + "." );
			SendMessageToPC( oUser, "<C=red>Could not find attached light! Please report this bug.</C>" );
		}
	}
	
	// Change the effect.
	string sEffectTag = GetLocalString( oSwitcher, LVAR_EFFECT_TAG );
	if ( sEffectTag != "" ) {
		if ( nState == STATE_ON ) {
			// Turning it on.
			string sEffectTemplate = GetLocalString( oSwitcher, LVAR_EFFECT_TEMPLATE );
			int bUseAnimation = ( GetLocalInt( oSwitcher, LVAR_EFFECT_ANIMATE ) != 0 );
			object oEffect = CreateObject( OBJECT_TYPE_PLACED_EFFECT, sEffectTemplate, lWaypoint, bUseAnimation, sEffectTag );
			if ( GetIsObjectValid( oEffect ) ) {
				string sMessage = GetLocalString( oSwitcher, LVAR_SWITCH_ON_MSG );
				if ( sMessage != "" ) SendMessageToPC( oUser, sMessage );
			} else {
				WriteTimestampedLogEntry( "EffectSwitcher : Could not create effect '" + sEffectTemplate + "' on object '" + GetName( oSwitcher ) + "' in area + " + GetTag( GetArea( oSwitcher ) ) + "." );
				SendMessageToPC( oUser, "<C=red>Could not create effect! Please report this bug.</C>" );
			}
		} else {
			// Turning it off.
			object oEffect = GetObjectByTag( sEffectTag );
			if ( GetIsObjectValid( oEffect ) ) {
				DestroyObject( oEffect );
				string sMessage = GetLocalString( oSwitcher, LVAR_SWITCH_OFF_MSG );
				if ( sMessage != "" ) SendMessageToPC( oUser, sMessage );
			} else {
				WriteTimestampedLogEntry( "EffectSwitcher : Could not find effect '" + sEffectTag + "' on object '" + GetName( oSwitcher ) + "' in area + " + GetTag( GetArea( oSwitcher ) ) + "." );
				SendMessageToPC( oUser, "<C=red>Could not find effect! Please report this bug.</C>" );
			}
		}
	}
}