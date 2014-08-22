void main( object TargetObject, float posX, float posY, float posZ, string ballista, int TargetRegion, int special) 
{
	if(!GetIsObjectValid(TargetObject))
	{
		location targetLoc = Location(GetArea(OBJECT_SELF), Vector(posX, posY, posZ), 0.0f);
		object TargetObject = GetFirstObjectInShape(SHAPE_SPHERE, 2.0f, targetLoc, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
	}
	if(!GetIsObjectValid(TargetObject))
	{
		SendMessageToPC(OBJECT_SELF, "No ballista target found; shot is wasted.");
		return;
	}
	
	object ballistaObject = IntToObject(StringToInt(ballista));
	if(!GetIsObjectValid(TargetObject))
	{
		SendMessageToPC(OBJECT_SELF, "Ballista not found. Nothing to shoot.");
		return;
	}
	
	if(GetLocalInt(ballistaObject, "ROUNDS_TO_LOAD"))
	{
		SendMessageToPC(OBJECT_SELF, "This ballista needs to be reloaded before it can fire again.");
		return;
	}
	
	vector pcPos = GetPosition(OBJECT_SELF);
	vector balPos = GetPosition(ballistaObject);
	
	if(pcPos.x - balPos.x > 1.5f ||
	   pcPos.y - balPos.y > 1.5f)
	{
		SendMessageToPC(OBJECT_SELF, "You are not close enough to the ballista to effectively operate it.");
		DeleteLocalInt(ballistaObject, "ROUNDS_TO_LOAD");
		return;
	}
	
	SetLocalInt(ballistaObject, "ROUNDS_TO_LOAD", 2);
	int AC = 10;
	if(GetObjectType(TargetObject) == OBJECT_TYPE_CREATURE)
	{
		AC = GetAC(TargetObject);
	}
	
	int attackRoll = d20(1);
	int attackMod = GetBaseAttackBonus(OBJECT_SELF) + GetAbilityModifier(ABILITY_DEXTERITY, OBJECT_SELF);
	switch(GetCreatureSize(OBJECT_SELF))
	{
		case CREATURE_SIZE_TINY: attackMod -= 8; break;
		case CREATURE_SIZE_SMALL: attackMod -= 6; break;
		case CREATURE_SIZE_MEDIUM: attackMod -= 4; break;
	}
	int finalHit = attackRoll + attackMod;
	
	string message = GetName(OBJECT_SELF) + " fires ballista: " + IntToString(attackRoll) + " + " + IntToString(attackMod) + " = " + IntToString(finalHit);
	int nAttackType = OVERRIDE_ATTACK_RESULT_MISS;
	float fireDuration = GetProjectileTravelTime(GetLocation(ballistaObject), GetLocation(TargetObject), PROJECTILE_PATH_TYPE_HIGH_BALLISTIC);
	if(attackRoll == 20 || (finalHit >= AC && attackRoll != 1))
	{
		int nDamage = d8(3);
		if(attackRoll >= 19)
		{
			int critRoll = d20(1);
			int finalCrit = critRoll + attackMod;
			message += "(Critical: "+IntToString(critRoll)+" + "+IntToString(attackMod)+" = "+IntToString(finalCrit)+")";
			if(finalCrit >= AC)
			{
				nDamage += d8(3);
				message += " CRITICAL HIT!";
				nAttackType = OVERRIDE_ATTACK_RESULT_CRITICAL_HIT;
			}
			else
			{
				message += " Hit!";
				nAttackType = OVERRIDE_ATTACK_RESULT_HIT_SUCCESSFUL;
			}
		}
		else
		{
			message += " Hit!";
			nAttackType = OVERRIDE_ATTACK_RESULT_HIT_SUCCESSFUL;
		}
		DelayCommand(fireDuration, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_PIERCING), TargetObject, 0.0f));
	}
	SendMessageToPC(OBJECT_SELF, message);
	if(GetIsPC(TargetObject)) SendMessageToPC(TargetObject, message);
	
	SpawnItemProjectile(ballistaObject, TargetObject, GetLocation(ballistaObject), GetLocation(TargetObject),
	                    BASE_ITEM_HEAVYCROSSBOW, PROJECTILE_PATH_TYPE_HIGH_BALLISTIC, nAttackType, DAMAGE_TYPE_PIERCING );
	
}