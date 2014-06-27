// random_waypoints
//
// Create waypoints called WP_random_waypoints_**
// where ** are numbers starting at 01
//
// set variable on creatures as follows:
//
// WP_TAG = random_waypoints

#include "ginc_wp"

void main()
{
int iWP = GetCurrentWaypoint();
int MaxWPNo = GetNumWaypoints();
int iNextWP = Random(MaxWPNo) + 1;

SetNextWaypoint(iNextWP);

float fPauseTime = IntToFloat(Random(6)+5);// face waypoint direction and pause for 5-10 seconds
FaceAndPause(iWP, fPauseTime);
} 