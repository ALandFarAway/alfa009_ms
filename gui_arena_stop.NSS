#include "009_arena_i"
#include "acr_creature_i"

void main() 
{
	int nRedCount = 0;
	object oRed = GetLocalObject(GetArea(OBJECT_SELF), "RED"+IntToString(nRedCount));
	while(GetIsObjectValid(oRed))
	{
		StopFight(oRed);
		nRedCount++;
		oRed = GetLocalObject(GetArea(OBJECT_SELF), "RED"+IntToString(nRedCount));
	}
	int nBlueCount = 0;
	object oBlue = GetLocalObject(GetArea(OBJECT_SELF), "BLUE"+IntToString(nBlueCount));
	while(GetIsObjectValid(oBlue))
	{
		StopFight(oBlue);
		nBlueCount++;
		oBlue = GetLocalObject(GetArea(OBJECT_SELF), "BLUE"+IntToString(nBlueCount));
	}
}