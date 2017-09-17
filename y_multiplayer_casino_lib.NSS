// Black Rain Software 2009

#include "nw_o0_itemmaker"


const int iNumPlayersAllowed = 4;  // GUIs built assuming maximum of 4 players
const int iUsePCName = 1;  // add PC name to player name in all displays

// prototypes

void MPMessageAllPlayers ( object oDealer, string sMessage );
void MPGUIUpdateTexture ( object oDealer, string sGUIName, string sComponentName, string sTexture = "" );
void MPGUIUpdateText ( object oDealer, string sGUIName, string sComponentName, string sText = "" );
void MPGUIDisplayComponent ( object oDealer, string sGUIName, string sComponentName, int iDisplay = 0 );
void MPGUIUpdateMultiComponent ( object oDealer, string sGUIName, string sTexture, string sTextField, string sHideComponent );

// message all human players with sMessage

void MPMessageAllPlayers ( object oDealer, string sMessage ) {
	int i;
	object oPlayer;
	string s;
	
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
			oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
			SendMessageToPC ( oPlayer, sMessage );
		}
	}
}


// -MPGUIUpdateTexture and MPGUIUpdateText update GUI for all human players
// -assumes that oDealer has an int for each player, i1isPlayer, i2isPlayer, etc, set to 1 for human
// -assumes that oDealer has an obj for each player, oPlayer1, oPlayer2, etc
// -sTexture does not need the .tga, the function will add it in
// -if sTexture or sText are blank then the function will hide sComponentName instead of updating

void MPGUIUpdateTexture ( object oDealer, string sGUIName, string sComponentName, string sTexture = "" ) {
	int i;
	object oPlayer;
	string s;
	
	if ( sTexture == "" ) {
		// hide the component
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				SetGUIObjectHidden ( oPlayer, sGUIName, sComponentName, TRUE );
			}
		}
	} else {
		// update the component
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				SetGUITexture ( oPlayer, sGUIName, sComponentName, sTexture + ".tga" );
				SetGUIObjectHidden ( oPlayer, sGUIName, sComponentName, FALSE );				
			}
		}		
	}
}


void MPGUIUpdateText ( object oDealer, string sGUIName, string sComponentName, string sText = "" ) {
	int i;
	object oPlayer;
	string s;
	
	if ( sText == "" ) {
		// hide the component
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				SetGUIObjectHidden ( oPlayer, sGUIName, sComponentName, TRUE );
			}
		}
	} else {
		// update the component
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				SetGUIObjectText ( oPlayer, sGUIName, sComponentName, -1, sText );
				SetGUIObjectHidden ( oPlayer, sGUIName, sComponentName, FALSE );				
			}
		}		
	}	
}


// show or hide a GUI component for all players, 0 is hide

void MPGUIDisplayComponent ( object oDealer, string sGUIName, string sComponentName, int iDisplay = 0 ) {
	int i;
	object oPlayer;
	string s;

	if ( iDisplay == 0 ) {
		// hide the component
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				SetGUIObjectHidden ( oPlayer, sGUIName, sComponentName, TRUE );
			}
		}
	} else {
		// show the component
		for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
			s = IntToString(i);
			if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
				oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
				SetGUIObjectHidden ( oPlayer, sGUIName, sComponentName, FALSE );				
			}
		}		
	}
}


// MPGUIUpdateMultiComponent allows for the updating of multiple GUI components at once
// uses the same assumptions as previous MPGUI functions
// sTexture and TextField update text and texture components
// sHideComponent indicates which components should be shown or hidden
// to pass in components and parameters use the format x=y, with multiple entries separated by ;
// ex: TextField1=test1;TextField2=test2
// this function will *not* error check input format

void MPGUIUpdateMultiComponent ( object oDealer, string sGUIName, string sTexture, string sTextField, string sHideComponent ) {
	int i, iComponentCount, iComponentValue, iNumHideComponent, iNumTextField, iNumTexture, iStringLength, iSubStringPos;
	object oPlayer;
	string s, sComponentName, sComponentValue, sSubString;
	
	iNumTexture = 0;	
	iNumTextField = 0;
	iNumHideComponent = 0;
		
	// process each parameter string
	if ( sTexture != "" ) {
		iSubStringPos = FindSubString ( sTexture, ";" );
		while ( iSubStringPos != -1 ) {
			iNumTexture = iNumTexture + 1;
			sSubString = GetSubString ( sTexture, 0, iSubStringPos );
			i = FindSubString ( sSubString, "=" );
			SetLocalArrayString ( oDealer, "sMPGUITextureName", iNumTexture, GetSubString ( sSubString, 0, i ) );
			SetLocalArrayString ( oDealer, "sMPGUITextureValue", iNumTexture, GetStringRight ( sSubString, GetStringLength(sSubString) - ( i + 1 ) ) );
			
			sTexture = GetStringRight ( sTexture, GetStringLength(sTexture) - ( iSubStringPos + 1 ) );
			iSubStringPos = FindSubString ( sTexture, ";" );
		}
		iNumTexture = iNumTexture + 1;
		i = FindSubString ( sTexture, "=" );
		SetLocalArrayString ( oDealer, "sMPGUITextureName", iNumTexture, GetSubString ( sTexture, 0, i ) );
		SetLocalArrayString ( oDealer, "sMPGUITextureValue", iNumTexture, GetStringRight ( sTexture, GetStringLength(sTexture) - ( i + 1 ) ) );
	}				
	
	if ( sTextField != "" ) {
		iSubStringPos = FindSubString ( sTextField, ";" );
		while ( iSubStringPos != -1 ) {
			iNumTextField = iNumTextField + 1;
			sSubString = GetSubString ( sTextField, 0, iSubStringPos );
			i = FindSubString ( sSubString, "=" );
			SetLocalArrayString ( oDealer, "sMPGUITextFieldName", iNumTextField, GetSubString ( sSubString, 0, i ) );
			SetLocalArrayString ( oDealer, "sMPGUITextFieldValue", iNumTextField, GetStringRight ( sSubString, GetStringLength(sSubString) - ( i + 1 ) ) );
			
			sTextField = GetStringRight ( sTextField, GetStringLength(sTextField) - ( iSubStringPos + 1 ) );
			iSubStringPos = FindSubString ( sTextField, ";" );
		}
		iNumTextField = iNumTextField + 1;
		i = FindSubString ( sTextField, "=" );
		SetLocalArrayString ( oDealer, "sMPGUITextFieldName", iNumTextField, GetSubString ( sTextField, 0, i ) );
		SetLocalArrayString ( oDealer, "sMPGUITextFieldValue", iNumTextField, GetStringRight ( sTextField, GetStringLength(sTextField) - ( i + 1 ) ) );
	}	
	
	if ( sHideComponent != "" ) {
		iSubStringPos = FindSubString ( sHideComponent, ";" );
		while ( iSubStringPos != -1 ) {
			iNumHideComponent = iNumHideComponent + 1;
			sSubString = GetSubString ( sHideComponent, 0, iSubStringPos );
			SetLocalArrayString ( oDealer, "sMPGUIHideComponentName", iNumHideComponent, GetStringLeft ( sSubString, GetStringLength(sSubString) - 2 ) );
			SetLocalArrayInt ( oDealer, "iMPGUIHideComponentValue", iNumHideComponent, StringToInt(GetStringRight ( sSubString, 1 )) );
			
			sHideComponent = GetStringRight ( sHideComponent, GetStringLength(sHideComponent) - ( iSubStringPos + 1 ) );
			iSubStringPos = FindSubString ( sHideComponent, ";" );
		}
		iNumHideComponent = iNumHideComponent + 1;
		SetLocalArrayString ( oDealer, "sMPGUIHideComponentName", iNumHideComponent, GetStringLeft ( sHideComponent, GetStringLength(sHideComponent) - 2 ) );
		SetLocalArrayInt ( oDealer, "iMPGUIHideComponentValue", iNumHideComponent, StringToInt(GetStringRight ( sHideComponent, 1 )) );
	}
	
	// cycle through each player position
	for ( i = 1 ; i <= iNumPlayersAllowed ; i++ ) {
		s = IntToString(i);
		if ( GetLocalInt ( oDealer, "i" + s + "isPlayer" ) == 1 ) {
			oPlayer = GetLocalObject ( oDealer, "oPlayer" + s );
			
			// evaluate sTexture
			for ( iComponentCount = 1 ; iComponentCount <= iNumTexture ; iComponentCount++ ) {
				sComponentName = GetLocalArrayString ( oDealer, "sMPGUITextureName", iComponentCount );
				sComponentValue = GetLocalArrayString ( oDealer, "sMPGUITextureValue", iComponentCount );	
				if ( sComponentValue == "" ) {  // hide component
					SetGUIObjectHidden ( oPlayer, sGUIName, sComponentName, TRUE );					
				} else {
					SetGUITexture ( oPlayer, sGUIName, sComponentName, sComponentValue + ".tga" );
					SetGUIObjectHidden ( oPlayer, sGUIName, sComponentName, FALSE );					
				}		
			}			
			
			// evaluate sTextField
			for ( iComponentCount = 1 ; iComponentCount <= iNumTextField ; iComponentCount++ ) {
				sComponentName = GetLocalArrayString ( oDealer, "sMPGUITextFieldName", iComponentCount );
				sComponentValue = GetLocalArrayString ( oDealer, "sMPGUITextFieldValue", iComponentCount );	
				if ( sComponentValue == "" ) {  // hide component
					SetGUIObjectHidden ( oPlayer, sGUIName, sComponentName, TRUE );					
				} else {
					SetGUIObjectText ( oPlayer, sGUIName, sComponentName, -1, sComponentValue );
					SetGUIObjectHidden ( oPlayer, sGUIName, sComponentName, FALSE );					
				}		
			}
		
			// evaluate sHideComponent		
			for ( iComponentCount = 1 ; iComponentCount <= iNumHideComponent ; iComponentCount++ ) {
				sComponentName = GetLocalArrayString ( oDealer, "sMPGUIHideComponentName", iComponentCount );
				iComponentValue = GetLocalArrayInt ( oDealer, "iMPGUIHideComponentValue", iComponentCount );	
				if ( iComponentValue == 0 ) {  // hide component
					SetGUIObjectHidden ( oPlayer, sGUIName, sComponentName, TRUE );					
				} else {
					SetGUIObjectHidden ( oPlayer, sGUIName, sComponentName, FALSE );					
				}		
			}
		}
	}
}