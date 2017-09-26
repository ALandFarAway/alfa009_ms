//OnOpened event of placeable
const float RESPAWN_TIMER = 10.0;//
void main()
{
   float fDelay = 6.0f; // << Set respawn delay in seconds
   if(GetLocalInt(OBJECT_SELF, "LOOTED")==1) return;
   string sResRef;
   switch (Random(48) + 1)// << 1 to 12, also change the number 12 to match the number of cases below
   {
      case 1: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 1
      case 2: sResRef = "nw_it_mpotion020"; break;//<< Resref of Item 2

      case 3: sResRef = "cs_it_mpotioncom"; break;//<< Resref of Item 3
      case 4: sResRef = "cs_it_mpotionremcrs"; break;//<< Resref of Item 4

      case 5: sResRef = "cs_it_mpotiondispl"; break;//<< Resref of Item 5
      case 6: sResRef = "cs_it_mpotionenpro"; break;//<< Resref of Item 6
      case 7: sResRef = "cs_it_mpotionrstsns"; break;//<< Resref of Item 7
      case 8: sResRef = "cs_it_mpotionshield"; break;//<< Resref of Item 8

      case 9: sResRef = "cs_it_mpotionether"; break;//<< Resref of Item 9
      case 10: sResRef = "01a_pot_growth"; break;//<< Resref of Item 10
      case 11: sResRef = "01a_pot_endure"; break;//<< Resref of Item 11
      case 12: sResRef = "01a_pot_sprinting"; break;//<< Resref of Item 12
	  
	  case 13: sResRef = "01a_pot_ghost"; break;//<< Resref of Item 1
      case 14: sResRef = "01a_pot_marmor"; break;//<< Resref of Item 2

      case 15: sResRef = "01a_pot_mirror"; break;//<< Resref of Item 3
      case 16: sResRef = "01a_pot_sanctuary"; break;//<< Resref of Item 4

      case 17: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 5
      case 18: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 6
      case 19: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 7
      case 20: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 8

      case 21: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 9
      case 22: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 10
      case 23: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 11
      case 24: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 12

	  case 25: sResRef = "nw_it_mpotion0160"; break;//<< Resref of Item 9
      case 26: sResRef = "nw_it_mpotion0060"; break;//<< Resref of Item 10
      case 27: sResRef = "nw_it_mpotion0050"; break;//<< Resref of Item 11
      case 28: sResRef = "nw_it_mpotion0130"; break;//<< Resref of Item 12

	  case 29: sResRef = "nw_it_mpotion0090"; break;//<< Resref of Item 9
      case 30: sResRef = "nw_it_mpotion0150"; break;//<< Resref of Item 10
      case 31: sResRef = "nw_it_mpotion0140"; break;//<< Resref of Item 11
      case 32: sResRef = "n2_it_mpotion0010"; break;//<< Resref of Item 12

	  case 33: sResRef = "x2_it_mpotion0020"; break;//<< Resref of Item 10
      case 34: sResRef = "nw_it_mpotion0100"; break;//<< Resref of Item 11
      case 35: sResRef = "nw_it_mpotion0170"; break;//<< Resref of Item 12

	  case 36: sResRef = "nw_it_mpotion0080"; break;//<< Resref of Item 10
      case 37: sResRef = "nx1_it_mpotion0040"; break;//<< Resref of Item 11
      case 38: sResRef = "nx1_it_mpotion0410"; break;//<< Resref of Item 12

	  case 39: sResRef = "nw_it_mpotion0190"; break;//<< Resref of Item 10
      case 40: sResRef = "nw_it_mpotion0180"; break;//<< Resref of Item 11
      case 41: sResRef = "cs_it_mpotionrestor"; break;//<< Resref of Item 12

	  case 42: sResRef = "nw_it_mpotion0040"; break;//<< Resref of Item 11
      case 43: sResRef = "nx1_it_mpotion0100"; break;//<< Resref of Item 12
      case 44: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 11
      case 45: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 12
      case 46: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 11
      case 47: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 12
      case 48: sResRef = "nw_it_mpotion001x10"; break;//<< Resref of Item 11

   }
   CreateItemOnObject(sResRef, OBJECT_SELF);
   SetLocalInt(OBJECT_SELF, "LOOTED", 1);
   //DelayCommand(fDelay, DeleteLocalInt(OBJECT_SELF, "LOOTED"));
   DelayCommand(fDelay, SetLocalInt(OBJECT_SELF, "LOOTED", 0));
  }
