/*  
	Exploding Barrels By Monty Three Card
	with assistance by Thrym of Markshire 			3/24/07

	This script determines if ANY of the damage taken by the object is Fire damage.
	
	If so, the object Kills itself creating the explosion.  
	
	This simulates volatility.  If the object is damaged enough by non-fire damage it will still explode.  
*/



void main()
{
  // If ANY damage is from FIRE, well then.....BOOM!
 
  // SendMessageToPC(GetFirstPC(), "This Barrel was damaged with " + IntToString(GetDamageDealtByType(DAMAGE_TYPE_FIRE)) + " of Fire");
        
  if (GetDamageDealtByType(DAMAGE_TYPE_FIRE) > 0) ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), OBJECT_SELF);
}
  