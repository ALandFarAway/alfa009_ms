
string generate_dwarf_name(int female)
{
	string str = "";
	switch (Random(20)) {
		case 0:
			str += "B";
			break;
		case 1:
			str += "Bal";
			break;
		case 2:
			str += "Bel";
			break;
		case 3:
			str += "Bof";
			break;
		case 4:
			str += "Bol";
			break;
		case 5:
			str += "D";
			break;
		case 6:
			str += "Dal";
			break;
		case 7:
			str += "Dor";
			break;
		case 8:
			str += "Dw";
			break;
		case 9:
			str += "Far";
			break;
		case 10:
			str += "Gil";
			break;
		case 11:
			str += "Gim";
			break;
		case 12:
			str += "Kil";
			break;
		case 13:
			str += "Mor";
			break;
		case 14:
			str += "Nal";
			break;
		case 15:
			str += "Nor";
			break;
		case 16:
			str += "Ov";
			break;
		case 17:
			str += "Th";
			break;
		case 18:
			str += "Thor";
			break;
		case 19:
			str += "Thr";
			break;
	}

	switch (Random(16)) {
		case 0:
			str += "b";
			break;
		case 1:
			str += "d";
			break;
		case 2:
			str += "f";
			break;
		case 3:
			str += "g";
			break;
		case 4:
			str += "k";
			break;
		case 5:
			str += "m";
			break;
		case 6:
			str += "t";
			break;
		case 7:
			str += "v";
			break;
		case 8:
			str += "z";
			break;
		case 9:
			str += "";
			break;
		case 10:
			str += "";
			break;
		case 11:
			str += "";
			break;
		case 12:
			str += "";
			break;
		case 13:
			str += "";
			break;
		case 14:
			str += "";
			break;
		case 15:
			str += "";
			break;
	}

	if (female) {
		switch (Random(10)) {
			case 0:
				str +=  "a";
				break;
			case 1:
				str +=  "ala";
				break;
			case 2:
				str +=  "ana";
				break;
			case 3:
				str +=  "ip";
				break;
			case 4:
				str +=  "ia";
				break;
			case 5:
				str +=  "ila";
				break;
			case 6:
				str +=  "ina";
				break;
			case 7:
				str +=  "on";
				break;
			case 8:
				str +=  "ola";
				break;
			case 9:
				str +=  "ona";
				break;
		}
	}
	else {
		switch (Random(10)) {
			case 0:
				str +=  "aim";
				break;
			case 1:
				str +=  "ain";
				break;
			case 2:
				str +=  "ak";
				break;
			case 3:
				str +=  "ar";
				break;
			case 4:
				str +=  "i";
				break;
			case 5:
				str +=  "im";
				break;
			case 6:
				str +=  "in";
				break;
			case 7:
				str +=  "o";
				break;
			case 8:
				str +=  "or";
				break;
			case 9:
				str +=  "ur";
				break;
		}
	}

	return str;
}

string generate_gnome_name(int female,int last)
{
	string str = "";
	int i;

	if (!last) {
		for (i=0; i<=Random(3); ++i) {
		
			switch (Random(40)) {
				case 0:
					str += "Arum";
					break;
				case 1:
					str += "Add";
					break;
				case 2:
					str += "Baer";
					break;
				case 3:
					str += "Bar";
					break;
				case 4:
					str += "Callad";
					break;
				case 5:
					str += "Chik";
					break;
				case 6:
					str += "Dal";
					break;
				case 7:
					str += "Din";
					break;
				case 8:
					str += "Eaus";
					break;
				case 9:
					str += "Erf";
					break;
				case 10:
					str += "Enn";
					break;
				case 11:
					str += "Faer";
					break;
				case 12:
					str += "Flan";
					break;
				case 13:
					str += "Fen";
					break;
				case 14:
					str += "Gaer";
					break;
				case 15:
					str += "Gar";
					break;
				case 16:
					str += "Hed";
					break;
				case 17:
					str += "Herl";
					break;
				case 18:
					str += "Ien";
					break;
				case 19:
					str += "Jan";
					break;
				case 20:
					str += "Kaer";
					break;
				case 21:
					str += "Len";
					break;
				case 22:
					str += "Lun";
					break;
				case 23:
					str += "Mikk";
					break;
				case 24:
					str += "Neb";
					break;
				case 25:
					str += "Oaen";
					break;
				case 26:
					str += "Ow";
					break;
				case 27:
					str += "Pall";
					break;
				case 28:
					str += "Pin";
					break;
				case 29:
					str += "Raer";
					break;
				case 30:
					str += "Ras";
					break;
				case 31:
					str += "Seg";
					break;
				case 32:
					str += "Skor";
					break;
				case 33:
					str += "Tikk";
					break;
				case 34:
					str += "Uran";
					break;
				case 35:
					str += "Urd";
					break;
				case 36:
					str += "Van";
					break;
				case 37:
					str += "Var";
					break;
				case 38:
					str += "Wann";
					break;
				case 39:
					str += "Wed";
					break;
			}
		}
	}
	else {
		switch (Random(20)) {
			case 0:
				str += "Wild";
				break;
			case 1:
				str += "Earth";
				break;
			case 2:
				str += "Fast";
				break;
			case 3:
				str += "Fast";
				break;
			case 4:
				str += "Glitter";
				break;
			case 5:
				str += "Gold";
				break;
			case 6:
				str += "Honor";
				break;
			case 7:
				str += "Iron";
				break;
			case 8:
				str += "Lightning";
				break;
			case 9:
				str += "Moon";
				break;
			case 10:
				str += "Shadow";
				break;
			case 11:
				str += "Shadow";
				break;
			case 12:
				str += "Silver";
				break;
			case 13:
				str += "Sly";
				break;
			case 14:
				str += "Sly";
				break;
			case 15:
				str += "Small";
				break;
			case 16:
				str += "Steel";
				break;
			case 17:
				str += "Stone";
				break;
			case 18:
				str += "Sun";
				break;
			case 19:
				str += "Swift";
				break;
		}
	
		switch (Random(20)) {
			case 0:
				str += "Bones";
				break;
			case 1:
				str += "Caller";
				break;
			case 2:
				str += "Caller";
				break;
			case 3:
				str += "Cloak";
				break;
			case 4:
				str += "Eye";
				break;
			case 5:
				str += "Foot";
				break;
			case 6:
				str += "Fox";
				break;
			case 7:
				str += "Gold";
				break;
			case 8:
				str += "Hand";
				break;
			case 9:
				str += "Hand";
				break;
			case 10:
				str += "Heart";
				break;
			case 11:
				str += "Heart";
				break;
			case 12:
				str += "Leaf";
				break;
			case 13:
				str += (female ? "Lady" : "Man");
				break;
			case 14:
				str += "Skin";
				break;
			case 15:
				str += "Srider";
				break;
			case 16:
				str += "Wanderer";
				break;
			case 17:
				str += "Wanderer";
				break;
			case 18:
				str += "Will";
				break;
			case 19:
				str += "Whisper";
				break;
		}
	}
	
	str = (GetStringUpperCase(GetSubString(str,0,1)) + GetStringLowerCase(GetSubString(str,1,GetStringLength(str))));
	return str;
}

string generate_human_name(int female)
{
	string str = RandomName();

	if (female) {
		switch (Random(6)) {
			case 0:
				str += "a";
				break;
			case 1:
				str += "ie";
				break;
			case 2:
				str += "re";
				break;
			case 3:
				str += "ele";
				break;
			case 4:
				str += "na";
				break;
			case 5:
				str += "ni";
				break;
		}	
	}
	return str;
}

string RandomNameDwarf(int nFemale=0)
{
	return generate_dwarf_name(nFemale);
}

string RandomNameGnome(int nFemale=0,int nLast=0)
{
	return generate_gnome_name(nFemale,nLast);
}

string RandomNameHuman(int nFemale=0)
{
	return generate_human_name(nFemale);
}

string RandomNameDrowPrefix( int nGender ) {
	switch ( Random(100) ) {
		case 1: return ( ( nGender == GENDER_FEMALE ) ? "akor" : "alak" );
		case 2: return ( ( nGender == GENDER_FEMALE ) ? "alaun" : "alton" );
		case 3: return ( ( nGender == GENDER_FEMALE ) ? "aly" : "kel" );
		case 4: return ( ( nGender == GENDER_FEMALE ) ? "ang" : "adin" );
		case 5: return ( ( nGender == GENDER_FEMALE ) ? "ardul" : "amal" );
		case 6: return ( ( nGender == GENDER_FEMALE ) ? "aun" : "ant" );
		case 7: return ( ( nGender == GENDER_FEMALE ) ? "bae" : "bar" );
		case 8: return ( ( nGender == GENDER_FEMALE ) ? "bal" : "bel" );
		case 9: return ( ( nGender == GENDER_FEMALE ) ? "belar" : "bruh" );
		case 10: return ( ( nGender == GENDER_FEMALE ) ? "briz" : "berg" );
		case 11: return ( ( nGender == GENDER_FEMALE ) ? "bur" : "bhin" );
		case 12: return ( ( nGender == GENDER_FEMALE ) ? "chal" : "chasz" );
		case 13: return ( ( nGender == GENDER_FEMALE ) ? "char" : "kron" );
		case 14: return ( ( nGender == GENDER_FEMALE ) ? "chess" : "cal" );
		case 15: return "dhaun";
		case 16: return ( ( nGender == GENDER_FEMALE ) ? "dil" : "dur" );
		case 17: return ( ( nGender == GENDER_FEMALE ) ? "dirz" : "div" );
		case 18: return ( ( nGender == GENDER_FEMALE ) ? "dris" : "riz" );
		case 19: return ( ( nGender == GENDER_FEMALE ) ? "eclave" : "elk" );
		case 20: return ( ( nGender == GENDER_FEMALE ) ? "elvan" : "kalan" );
		case 21: return ( ( nGender == GENDER_FEMALE ) ? "elv" : "elaug" );
		case 22: return ( ( nGender == GENDER_FEMALE ) ? "erel" : "rhyl" );
		case 23: return ( ( nGender == GENDER_FEMALE ) ? "ethe" : "erth" );
		case 24: return ( ( nGender == GENDER_FEMALE ) ? "faer" : "selds" );
		case 25: return ( ( nGender == GENDER_FEMALE ) ? "felyn" : "fil" );
		case 26: return ( ( nGender == GENDER_FEMALE ) ? "filf" : "phar" );
		case 27: return ( ( nGender == GENDER_FEMALE ) ? "gauss" : "orgoll" );
		case 28: return "g'eld";
		case 29: return "ghaun";
		case 30: return ( ( nGender == GENDER_FEMALE ) ? "gin" : "din" );
		case 31: return ( ( nGender == GENDER_FEMALE ) ? "grey" : "gul" );
		case 32: return ( ( nGender == GENDER_FEMALE ) ? "hael" : "hatch" );
		case 33: return ( ( nGender == GENDER_FEMALE ) ? "hal" : "sol" );
		case 34: return ( ( nGender == GENDER_FEMALE ) ? "houn" : "rik" );
		case 35: return ( ( nGender == GENDER_FEMALE ) ? "iliv" : "dip" );
		case 36: return "ilm";
		case 37: return ( ( nGender == GENDER_FEMALE ) ? "illiam" : "im" );
		case 38: return ( ( nGender == GENDER_FEMALE ) ? "in" : "sorn" );
		case 39: return "ilph";
		case 40: return ( ( nGender == GENDER_FEMALE ) ? "irae" : "ilzt" );
		case 41: return ( ( nGender == GENDER_FEMALE ) ? "irr" : "izz" );
		case 42: return ( ( nGender == GENDER_FEMALE ) ? "iym" : "ist" );
		case 43: return ( ( nGender == GENDER_FEMALE ) ? "jhan" : "duag" );
		case 44: return ( ( nGender == GENDER_FEMALE ) ? "jhael" : "gel" );
		case 45: return ( ( nGender == GENDER_FEMALE ) ? "jhul" : "jar" );
		case 46: return ( ( nGender == GENDER_FEMALE ) ? "jys" : "driz" );
		case 47: return ( ( nGender == GENDER_FEMALE ) ? "lael" : "llt" );
		case 48: return ( ( nGender == GENDER_FEMALE ) ? "lar" : "les" );
		case 49: return ( ( nGender == GENDER_FEMALE ) ? "lineeer" : "mourn" );
		case 50: return ( ( nGender == GENDER_FEMALE ) ? "lird" : "ryld" );
		case 51: return ( ( nGender == GENDER_FEMALE ) ? "lua" : "lyme" );
		case 52: return ( ( nGender == GENDER_FEMALE ) ? "mal" : "malag" );
		case 53: return ( ( nGender == GENDER_FEMALE ) ? "may" : "mas" );
		case 54: return "micar";
		case 55: return ( ( nGender == GENDER_FEMALE ) ? "min" : "ran" );
		case 56: return ( ( nGender == GENDER_FEMALE ) ? "mol" : "go" );
		case 57: return ( ( nGender == GENDER_FEMALE ) ? "myr" : "nym" );
		case 58: return ( ( nGender == GENDER_FEMALE ) ? "nath" : "mer" );
		case 59: return ( ( nGender == GENDER_FEMALE ) ? "ned" : "nad" );
		case 60: return ( ( nGender == GENDER_FEMALE ) ? "nhil" : "nal" );
		case 61: return "neer";
		case 62: return ( ( nGender == GENDER_FEMALE ) ? "null" : "nil" );
		case 63: return ( ( nGender == GENDER_FEMALE ) ? "olor" : "omar" );
		case 64: return ( ( nGender == GENDER_FEMALE ) ? "pellan" : "relon" );
		case 65: return ( ( nGender == GENDER_FEMALE ) ? "phaer" : "vorn" );
		case 66: return ( ( nGender == GENDER_FEMALE ) ? "phyr" : "phyx" );
		case 67: return ( ( nGender == GENDER_FEMALE ) ? "qualn" : "quil" );
		case 68: return "quar";
		case 69: return ( ( nGender == GENDER_FEMALE ) ? "quav" : "quev" );
		case 70: return ( ( nGender == GENDER_FEMALE ) ? "qil" : "quil" );
		case 71: return ( ( nGender == GENDER_FEMALE ) ? "rauv" : "welv" );
		case 72: return ( ( nGender == GENDER_FEMALE ) ? "ril" : "ryl" );
		case 73: return ( ( nGender == GENDER_FEMALE ) ? "sabal" : "szor" );
		case 74: return ( ( nGender == GENDER_FEMALE ) ? "sab" : "tsab" );
		case 75: return ( ( nGender == GENDER_FEMALE ) ? "shi'n" : "kren" );
		case 76: return ( ( nGender == GENDER_FEMALE ) ? "shri" : "ssz" );
		case 77: return ( ( nGender == GENDER_FEMALE ) ? "shur" : "shar" );
		case 78: return "shynt";
		case 79: return ( ( nGender == GENDER_FEMALE ) ? "sin" : "szin" );
		case 80: return ( ( nGender == GENDER_FEMALE ) ? "ssap" : "that" );
		case 81: return ( ( nGender == GENDER_FEMALE ) ? "susp" : "spir" );
		case 82: return ( ( nGender == GENDER_FEMALE ) ? "talab" : "tluth" );
		case 83: return ( ( nGender == GENDER_FEMALE ) ? "tal" : "tar" );
		case 84: return ( ( nGender == GENDER_FEMALE ) ? "triel" : "taz" );
		case 85: return ( ( nGender == GENDER_FEMALE ) ? "t'riss" : "teb" );
		case 86: return ( ( nGender == GENDER_FEMALE ) ? "ulviir" : "uhls" );
		case 87: return ( ( nGender == GENDER_FEMALE ) ? "umrae" : "hurz" );
		case 88: return ( ( nGender == GENDER_FEMALE ) ? "vas" : "vesz" );
		case 89: return "vic";
		case 90: return ( ( nGender == GENDER_FEMALE ) ? "vier" : "val" );
		case 91: return ( ( nGender == GENDER_FEMALE ) ? "vlon" : "wod" );
		case 92: return ( ( nGender == GENDER_FEMALE ) ? "waer" : "wehl" );
		case 93: return ( ( nGender == GENDER_FEMALE ) ? "wuyon" : "wruz" );
		case 94: return ( ( nGender == GENDER_FEMALE ) ? "xull" : "url" );
		case 95: return "xun";
		case 96: return ( ( nGender == GENDER_FEMALE ) ? "yas" : "yaz" );
		case 97: return ( ( nGender == GENDER_FEMALE ) ? "zar" : "zakn" );
		case 98: return ( ( nGender == GENDER_FEMALE ) ? "zebey" : "zek" );
		case 99: return ( ( nGender == GENDER_FEMALE ) ? "zes" : "zez" );
		default: return ( ( nGender == GENDER_FEMALE ) ? "zilv" : "vuz" );
	}
	return "";
}

string RandomNameDrowSuffix( int nGender ) {
	switch ( Random(100) ) {
		case 1: return ( ( nGender == GENDER_FEMALE ) ? "a" : "agh" );
		case 2: return ( ( nGender == GENDER_FEMALE ) ? "ace" : "as" );
		case 3: return ( ( nGender == GENDER_FEMALE ) ? "ae" : "aun" );
		case 4: return ( ( nGender == GENDER_FEMALE ) ? "aere" : "d" );
		case 5: return ( ( nGender == GENDER_FEMALE ) ? "afae" : "afein" );
		case 6: return ( ( nGender == GENDER_FEMALE ) ? "afay" : "aufein" );
		case 7: return ( ( nGender == GENDER_FEMALE ) ? "ala" : "launim" );
		case 8: return ( ( nGender == GENDER_FEMALE ) ? "anna" : "erin" );
		case 9: return ( ( nGender == GENDER_FEMALE ) ? "arra" : "atar" );
		case 10: return "aste";
		case 11: return ( ( nGender == GENDER_FEMALE ) ? "avin" : "aonar" );
		case 12: return ( ( nGender == GENDER_FEMALE ) ? "ayne" : "al" );
		case 13: return ( ( nGender == GENDER_FEMALE ) ? "baste" : "gloth" );
		case 14: return ( ( nGender == GENDER_FEMALE ) ? "breena" : "antar" );
		case 15: return ( ( nGender == GENDER_FEMALE ) ? "bryn" : "lyn" );
		case 16: return ( ( nGender == GENDER_FEMALE ) ? "cice" : "roos" );
		case 17: return ( ( nGender == GENDER_FEMALE ) ? "cyrl" : "axle" );
		case 18: return ( ( nGender == GENDER_FEMALE ) ? "da" : "daer" );
		case 19: return ( ( nGender == GENDER_FEMALE ) ? "dia" : "drin" );
		case 20: return ( ( nGender == GENDER_FEMALE ) ? "diira" : "diirn" );
		case 21: return ( ( nGender == GENDER_FEMALE ) ? "dra" : "zar" );
		case 22: return ( ( nGender == GENDER_FEMALE ) ? "driira" : "driirn" );
		case 23: return ( ( nGender == GENDER_FEMALE ) ? "dril" : "dorl" );
		case 24: return "e";
		case 25: return ( ( nGender == GENDER_FEMALE ) ? "eari" : "erd" );
		case 26: return "eyl";
		case 27: return ( ( nGender == GENDER_FEMALE ) ? "ffyn" : "fein" );
		case 28: return "fryn";
		case 29: return ( ( nGender == GENDER_FEMALE ) ? "iara" : "ica" );
		case 30: return ( ( nGender == GENDER_FEMALE ) ? "ice" : "eth" );
		case 31: return ( ( nGender == GENDER_FEMALE ) ? "idil" : "imar" );
		case 32: return ( ( nGender == GENDER_FEMALE ) ? "iira" : "inid" );
		case 33: return "inidia";
		case 34: return ( ( nGender == GENDER_FEMALE ) ? "inil" : "in" );
		case 35: return "intra";
		case 36: return ( ( nGender == GENDER_FEMALE ) ? "isstra" : "atlab" );
		case 37: return ( ( nGender == GENDER_FEMALE ) ? "ithra" : "irahc" );
		case 38: return ( ( nGender == GENDER_FEMALE ) ? "jra" : "gos" );
		case 39: return "jss";
		case 40: return ( ( nGender == GENDER_FEMALE ) ? "kacha" : "kah" );
		case 41: return ( ( nGender == GENDER_FEMALE ) ? "kiira" : "raen" );
		case 42: return ( ( nGender == GENDER_FEMALE ) ? "lay" : "dyn" );
		case 43: return ( ( nGender == GENDER_FEMALE ) ? "lara" : "aghar" );
		case 44: return "lin";
		case 45: return "lochar";
		case 46: return ( ( nGender == GENDER_FEMALE ) ? "mice" : "myr" );
		case 47: return "mur'ss";
		case 48: return ( ( nGender == GENDER_FEMALE ) ? "na" : "nar" );
		case 49: return ( ( nGender == GENDER_FEMALE ) ? "nilee" : "olil" );
		case 50: return ( ( nGender == GENDER_FEMALE ) ? "niss" : "nozz" );
		case 51: return ( ( nGender == GENDER_FEMALE ) ? "nitra" : "net" );
		case 52: return "nolu";
		case 53: return "olin";
		case 54: return ( ( nGender == GENDER_FEMALE ) ? "onia" : "onim" );
		case 55: return ( ( nGender == GENDER_FEMALE ) ? "oyss" : "omph" );
		case 56: return "qualyn";
		case 57: return ( ( nGender == GENDER_FEMALE ) ? "quarra" : "net" );
		case 58: return ( ( nGender == GENDER_FEMALE ) ? "quiri" : "oj" );
		case 59: return ( ( nGender == GENDER_FEMALE ) ? "ra" : "or" );
		case 60: return ( ( nGender == GENDER_FEMALE ) ? "rae" : "rar" );
		case 61: return ( ( nGender == GENDER_FEMALE ) ? "raema" : "orvir" );
		case 62: return ( ( nGender == GENDER_FEMALE ) ? "raena" : "olvir" );
		case 63: return ( ( nGender == GENDER_FEMALE ) ? "riia" : "rak" );
		case 64: return "ril";
		case 65: return ( ( nGender == GENDER_FEMALE ) ? "riina" : "ree" );
		case 66: return ( ( nGender == GENDER_FEMALE ) ? "ryna" : "oyn" );
		case 67: return ( ( nGender == GENDER_FEMALE ) ? "ryne" : "ryn" );
		case 68: return ( ( nGender == GENDER_FEMALE ) ? "shalee" : "ral" );
		case 69: return ( ( nGender == GENDER_FEMALE ) ? "ssysn" : "rysn" );
		case 70: return ( ( nGender == GENDER_FEMALE ) ? "stin" : "trin" );
		case 71: return ( ( nGender == GENDER_FEMALE ) ? "stra" : "tran" );
		case 72: return ( ( nGender == GENDER_FEMALE ) ? "tana" : "ton" );
		case 73: return ( ( nGender == GENDER_FEMALE ) ? "thara" : "tar" );
		case 74: return ( ( nGender == GENDER_FEMALE ) ? "thrae" : "olg" );
		case 75: return ( ( nGender == GENDER_FEMALE ) ? "tree" : "tel" );
		case 76: return "tyrr";
		case 77: return ( ( nGender == GENDER_FEMALE ) ? "ual" : "dan" );
		case 78: return ( ( nGender == GENDER_FEMALE ) ? "ue" : "dor" );
		case 79: return ( ( nGender == GENDER_FEMALE ) ? "uit" : "dar" );
		case 80: return ( ( nGender == GENDER_FEMALE ) ? "une" : "dinn" );
		case 81: return "uque";
		case 82: return ( ( nGender == GENDER_FEMALE ) ? "urra" : "dax" );
		case 83: return ( ( nGender == GENDER_FEMALE ) ? "va" : "ven" );
		case 84: return "vayas";
		case 85: return "vyll";
		case 86: return ( ( nGender == GENDER_FEMALE ) ? "vrae" : "vyr" );
		case 87: return ( ( nGender == GENDER_FEMALE ) ? "wae" : "hrae" );
		case 88: return ( ( nGender == GENDER_FEMALE ) ? "wiira" : "hriir" );
		case 89: return ( ( nGender == GENDER_FEMALE ) ? "wyss" : "hrys" );
		case 90: return ( ( nGender == GENDER_FEMALE ) ? "xae" : "zaer" );
		case 91: return ( ( nGender == GENDER_FEMALE ) ? "xena" : "zen" );
		case 92: return ( ( nGender == GENDER_FEMALE ) ? "xyra" : "zyr" );
		case 93: return "yl";
		case 94: return ( ( nGender == GENDER_FEMALE ) ? "ylene" : "yln" );
		case 95: return ( ( nGender == GENDER_FEMALE ) ? "ymma" : "inyon" );
		case 96: return ( ( nGender == GENDER_FEMALE ) ? "ynda" : "yrd" );
		case 97: return ( ( nGender == GENDER_FEMALE ) ? "ynrae" : "yraen" );
		case 98: return "vrae";
		case 99: return "yrr";
		default: return ( ( nGender == GENDER_FEMALE ) ? "zyne" : "zt" );
	}
	return "";
}

string RandomNameDrow( int nGender ) {
	// They see me rollin'
	int rRoll = d10();
	string sName = "";
	if ( rRoll <= 5 ) {
		sName = RandomNameDrowPrefix( nGender ) + RandomNameDrowSuffix( nGender );
	} else if ( rRoll <= 8 ) {
		sName = RandomNameDrowPrefix( nGender ) + RandomNameDrowSuffix( nGender ) + RandomNameDrowSuffix( nGender );
	} else if ( rRoll <= 9 ) {
		sName = RandomNameDrowPrefix( nGender ) + RandomNameDrowSuffix( nGender ) + "'" + RandomNameDrowSuffix( nGender );
	} else {
		sName = RandomNameDrowSuffix( nGender ) + "'" + RandomNameDrowPrefix( nGender ) + RandomNameDrowSuffix( nGender );
	}
	
	// They hatin'
	return GetStringUpperCase( GetSubString( sName, 1, 1 ) ) + GetSubString( sName, 2, GetStringLength( sName ) - 1 );
}