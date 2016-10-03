float RandDelay()
{
	int nDelay = d6();
	float fDelay = IntToFloat(nDelay);
	return fDelay;
}
void DelayableAnimation(object oTarget, string sAnim, int nLooping)
{
	PlayCustomAnimation(oTarget, sAnim, nLooping);
}

void main()
{
	int nCheck = GetLocalInt(OBJECT_SELF, "nAnimType");
	if(nCheck == 1)
	{
		int nRand = d2();
	
		if(nRand == 1)
		{
			PlayCustomAnimation(OBJECT_SELF, "sitfidget", 1);
			DelayCommand(RandDelay(), DelayableAnimation(OBJECT_SELF, "sittalk02", 0));
			DelayCommand(RandDelay()+6.0, DelayableAnimation(OBJECT_SELF, "sitread", 0));
			DelayCommand(RandDelay()+12.0, DelayableAnimation(OBJECT_SELF, "sitidle", 0));
			DelayCommand(RandDelay()+18.0, DelayableAnimation(OBJECT_SELF, "sittalk02", 0));
			DelayCommand(RandDelay()+24.0, DelayableAnimation(OBJECT_SELF, "sittalk01", 0));
			DelayCommand(RandDelay()+30.0, DelayableAnimation(OBJECT_SELF, "sitread", 0));
			DelayCommand(RandDelay()+36.0, DelayableAnimation(OBJECT_SELF, "sittalk01", 0));
			DelayCommand(RandDelay()+42.0, DelayableAnimation(OBJECT_SELF, "sitfidget", 0));
		}
		if(nRand == 2)
		{
			PlayCustomAnimation(OBJECT_SELF, "sitfidget", 1);
			DelayCommand(RandDelay(), DelayableAnimation(OBJECT_SELF, "sittalk01", 0));
			DelayCommand(RandDelay()+6.0, DelayableAnimation(OBJECT_SELF, "sittalk02", 0));
			DelayCommand(RandDelay()+12.0, DelayableAnimation(OBJECT_SELF, "sitidle", 0));
			DelayCommand(RandDelay()+18.0, DelayableAnimation(OBJECT_SELF, "sitread", 0));
			DelayCommand(RandDelay()+24.0, DelayableAnimation(OBJECT_SELF, "sittalk01", 0));
			DelayCommand(RandDelay()+30.0, DelayableAnimation(OBJECT_SELF, "sitread", 0));
			DelayCommand(RandDelay()+36.0, DelayableAnimation(OBJECT_SELF, "sittalk02", 0));
			DelayCommand(RandDelay()+42.0, DelayableAnimation(OBJECT_SELF, "sitfidget", 0));
		}
	}
	if(nCheck == 2)
	{
		int nRand = d2();
	
		if(nRand == 1)
		{
			PlayCustomAnimation(OBJECT_SELF, "sitfidget", 1);
			DelayCommand(RandDelay(), DelayableAnimation(OBJECT_SELF, "siteat", 0));
			DelayCommand(RandDelay()+5.0, DelayableAnimation(OBJECT_SELF, "sittalk01", 0));
			DelayCommand(RandDelay()+11.0, DelayableAnimation(OBJECT_SELF, "sittalk02", 0));
			DelayCommand(RandDelay()+17.0, DelayableAnimation(OBJECT_SELF, "siteat", 0));
			DelayCommand(RandDelay()+22.0, DelayableAnimation(OBJECT_SELF, "sitidle", 0));
			DelayCommand(RandDelay()+25.0, DelayableAnimation(OBJECT_SELF, "siteat", 0));
			DelayCommand(RandDelay()+30.0, DelayableAnimation(OBJECT_SELF, "sittalk01", 0));
			DelayCommand(RandDelay()+36.0, DelayableAnimation(OBJECT_SELF, "sitfidget", 0));
			
		}
		if(nRand == 2)
		{
			PlayCustomAnimation(OBJECT_SELF, "sitfidget", 1);
			DelayCommand(RandDelay(), DelayableAnimation(OBJECT_SELF, "sittalk02", 0));
			DelayCommand(RandDelay()+6.0, DelayableAnimation(OBJECT_SELF, "siteat", 0));
			DelayCommand(RandDelay()+11.0, DelayableAnimation(OBJECT_SELF, "sitidle", 0));
			DelayCommand(RandDelay()+14.0, DelayableAnimation(OBJECT_SELF, "siteat", 0));
			DelayCommand(RandDelay()+19.0, DelayableAnimation(OBJECT_SELF, "sittalk01", 0));
			DelayCommand(RandDelay()+25.0, DelayableAnimation(OBJECT_SELF, "siteat", 0));
			DelayCommand(RandDelay()+30.0, DelayableAnimation(OBJECT_SELF, "sittalk01", 0));
			DelayCommand(RandDelay()+36.0, DelayableAnimation(OBJECT_SELF, "sitfidget", 0));
		}
	}
	if(nCheck == 3)
	{
		PlayCustomAnimation(OBJECT_SELF, "proneb", 1);
	}
	if(nCheck == 4)
	{
		int nRand = d2();
		if(nRand == 1)
		{
			PlayCustomAnimation(OBJECT_SELF, "sitfidget", 1);
			DelayCommand(RandDelay(), DelayableAnimation(OBJECT_SELF, "sitdrink", 0));
			DelayCommand(RandDelay()+3.0, DelayableAnimation(OBJECT_SELF, "sittalk01", 0));
			DelayCommand(RandDelay()+9.0, DelayableAnimation(OBJECT_SELF, "sitdrink", 0));
			DelayCommand(RandDelay()+12.0, DelayableAnimation(OBJECT_SELF, "sitdrinkidle", 0));
			DelayCommand(RandDelay()+18.0, DelayableAnimation(OBJECT_SELF, "sittalk01", 0));
			DelayCommand(RandDelay()+24.0, DelayableAnimation(OBJECT_SELF, "sitdrink", 0));
			DelayCommand(RandDelay()+27.0, DelayableAnimation(OBJECT_SELF, "sitdrinkidle", 0));
			DelayCommand(RandDelay()+33.0, DelayableAnimation(OBJECT_SELF, "sittalk02", 0));
			DelayCommand(RandDelay()+39.0, DelayableAnimation(OBJECT_SELF, "sitdrink", 0));
			
		}
		if(nRand == 2)
		{
			PlayCustomAnimation(OBJECT_SELF, "sitfidget", 1);
			DelayCommand(RandDelay(), DelayableAnimation(OBJECT_SELF, "sittalk02", 0));
			DelayCommand(RandDelay()+6.0, DelayableAnimation(OBJECT_SELF, "sittalk01", 0));
			DelayCommand(RandDelay()+12.0, DelayableAnimation(OBJECT_SELF, "sitdrink", 0));
			DelayCommand(RandDelay()+15.0, DelayableAnimation(OBJECT_SELF, "sittalk01", 0));
			DelayCommand(RandDelay()+21.0, DelayableAnimation(OBJECT_SELF, "sitdrink", 0));
			DelayCommand(RandDelay()+24.0, DelayableAnimation(OBJECT_SELF, "sittalk01", 0));
			DelayCommand(RandDelay()+30.0, DelayableAnimation(OBJECT_SELF, "sitdrink", 0));
			DelayCommand(RandDelay()+33.0, DelayableAnimation(OBJECT_SELF, "sitdrink", 0));
			DelayCommand(RandDelay()+36.0, DelayableAnimation(OBJECT_SELF, "sitfidget", 0));
		}
	}
}