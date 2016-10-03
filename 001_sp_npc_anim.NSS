#include "ginc_wp"

const int EVENT_USER_DEFINED_PRESPAWN = 1510;
const int EVENT_USER_DEFINED_POSTSPAWN = 1511;


void main()
{

string sAnim1 = GetLocalString(OBJECT_SELF, "sAnim1");

	
int nUser = GetUserDefinedEventNumber();

    if(nUser == EVENT_HEARTBEAT ) //HEARTBEAT
    {

	int iCurrentWP = GetCurrentWaypoint();
	//ActionSpeakString("Debug", TALKVOLUME_TALK); 
	FaceAndPause(iCurrentWP, 10.0);
	PlayCustomAnimation(OBJECT_SELF, sAnim1, 1, 0.5);

/*

int iCurrentWP = GetCurrentWaypoint();
  int iNextWP;
    switch (iCurrentWP)
    {

	

		case 1:
            iNextWP = Random(GetNumWaypoints()-1) + 4;
            SetNextWaypoint(iNextWP);
			PlayCustomAnimation(OBJECT_SELF, sAnim1, 1, 1.0);
			FaceAndPause(iCurrentWP, IntToFloat(Random(5) + 5));
			break;
        case 2:
            SetNextWaypoint(1);
			PlayCustomAnimation(OBJECT_SELF, sAnim2, 1, 1.0);
			FaceAndPause(iCurrentWP, IntToFloat(Random(5) + 5));
		 	break;
		case 3:
            SetNextWaypoint(1);
			PlayCustomAnimation(OBJECT_SELF, sAnim3, 1, 1.0);
			FaceAndPause(iCurrentWP, IntToFloat(Random(5) + 5));
			break;
        case 4:
            SetNextWaypoint(1);
			break;
			
}		
			
      case 1:
        ClearAllActions();    
		iNextWP = Random(GetNumWaypoints()-1) + 3;
            SetNextWaypoint(iNextWP);
            FaceAndPause(iCurrentWP, IntToFloat(Random(5) + 5));
			PlayCustomAnimation(OBJECT_SELF, sAnim1, 0, 1.0);
			//
            break;
        case 2:
        ClearAllActions();    
		DelayCommand(5.0, SetNextWaypoint(1));
            FaceAndPause(iCurrentWP, IntToFloat(Random(5) + 5));
			PlayCustomAnimation(OBJECT_SELF, sAnim2, 0, 1.0);
			//ClearAllActions();
            break;
        case 3:
        ClearAllActions();
		DelayCommand(5.0, SetNextWaypoint(1));
            FaceAndPause(iCurrentWP, IntToFloat(Random(5) + 5));
			PlayCustomAnimation(OBJECT_SELF, sAnim3, 0, 1.0);
			//ClearAllActions();
            break;
 
		case 4:
            DelayCommand(5.0, SetNextWaypoint(1));
			//ClearAllActions();
            break;	
 
			
			         case 1:
            iNextWP = Random(GetNumWaypoints()-1) + 3;
            SetNextWaypoint(iNextWP);
            FaceAndPause(iCurrentWP, IntToFloat(Random(5) + 5));
			ActionPlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 17.0);
            break;
        case 2:
            SetNextWaypoint(1);
            FaceAndPause(iCurrentWP, IntToFloat(Random(5) + 5));
			ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW, 1.0, 14.0);
            break;
		case 3:
            SetNextWaypoint(1);
            FaceAndPause(iCurrentWP, IntToFloat(Random(5) + 5));
			ActionPlayAnimation(ANIMATION_LOOPING_FORGE01, 1.0, 10.0);
            break;
        case 4:
            SetNextWaypoint(1);
            break;	
	    */
}	
    else if(nUser == EVENT_PERCEIVE) // PERCEIVE
    {

    }
    else if(nUser == EVENT_END_COMBAT_ROUND) // END OF COMBAT
    {

    }
    else if(nUser == EVENT_DIALOGUE) // ON DIALOGUE
    {

    }
    else if(nUser == EVENT_ATTACKED) // ATTACKED
    {

    }
    else if(nUser == EVENT_DAMAGED) // DAMAGED
    {

    }
    else if(nUser == EVENT_DISTURBED) // DISTURBED
    {

    }
    else if (nUser == EVENT_USER_DEFINED_PRESPAWN)
    {

    }
    else if (nUser == EVENT_USER_DEFINED_POSTSPAWN)
    {



}
}
