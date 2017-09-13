// Black Rain 2008

void main() {
	float fFacing;
	int iCounter;
	string s;
	
	if ( GetTag(OBJECT_SELF) == "c_seated" ) {
		fFacing = GetLocalFloat ( OBJECT_SELF, "facing" );
		SetFacing(fFacing);
	}
	
	iCounter = 1;
	while ( GetLocalString ( OBJECT_SELF, "conv" + IntToString(iCounter) ) != "" ) {
		iCounter = iCounter + 1;
	}	
	
	iCounter = Random ( iCounter - 1 ) + 1;
	s = GetLocalString ( OBJECT_SELF, "conv" + IntToString(iCounter) );
	SpeakString(s);
}