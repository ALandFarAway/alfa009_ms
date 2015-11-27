#include "acr_nonlethal_i"

void Fall(object faller, float heightFeet, object fallTo = OBJECT_INVALID) {
	AssignCommand(faller, SpeakString("<i>*falls*</i>"));
	
	if(heightFeet == 0.0)
		heightFeet = GetDistanceBetween(faller,fallTo);
	
	if(heightFeet >= 10.0) {
	
		int lethalDice = FloatToInt((heightFeet - 10.0) / 10.0);
		int nonlethalDice = 0;
	
		if(GetIsSkillSuccessful(faller, SKILL_TUMBLE, 15)) {
			if(heightFeet >= 20.0)
				nonlethalDice = nonlethalDice + 1;
			lethalDice = lethalDice - 2;
		}
	
		if(lethalDice > 0)
			ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(lethalDice)), faller);
		if(nonlethalDice > 0)
			ACR_ApplyNonlethalDamageToCreature(faller, d6(nonlethalDice));		
	}
	
	if(fallTo != OBJECT_INVALID) {
		AssignCommand(faller, DelayCommand(0.5, ActionJumpToObject(fallTo)));
	}
}

void Climb(object climber, int dc, object climbTo, float heightFeet, object fallTo = OBJECT_INVALID) {

	if(GetIsSkillSuccessful(climber, 31, dc)) {
		AssignCommand(climber, SpeakString("<i>*successfully makes the climb*</i>"));
		AssignCommand(climber, DelayCommand(0.5, ActionJumpToObject(climbTo)));
	} else {
		Fall(climber, heightFeet, fallTo);
	}
}

void ClimbOnUsed() {
	Climb(
		GetLastUsedBy(),
		GetLocalInt(OBJECT_SELF,"RONAN_CLIMB_DC"),
		GetObjectByTag(GetLocalString(OBJECT_SELF,"RONAN_CLIMB_DEST")),
		GetLocalFloat(OBJECT_SELF,"RONAN_CLIMB_HEIGHT"),
		GetObjectByTag(GetLocalString(OBJECT_SELF,"RONAN_CLIMB_FALL_DEST"))
	);
}