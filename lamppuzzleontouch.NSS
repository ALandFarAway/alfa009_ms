object oPC = GetLastUsedBy();
string sTorchPuzzleDoor = "dr_r26_ruins1_lamppuzzle";
object oTorchPuzzleDoor = GetObjectByTag(sTorchPuzzleDoor);
string sTorchPuzzleLocalInt = "TorchDoorTrapped";

//int XpReward = 1000;

void LightExtinguishLamps(object oSelf, string sLamp)
{
	string sLampWay = sLamp+"waypoint";
	object oWay = GetObjectByTag(sLampWay);
	location lWay = GetLocation(oWay);

	if(GetLocalInt(oSelf, "lit") == 1)
	{
		CreateObject(OBJECT_TYPE_PLACED_EFFECT, "lampfire", lWay, TRUE, sLamp+"lampfire");
		SetLocalInt(oSelf, "lit", 0);
	}
	else
	{
		string sLampEffect = sLamp+"lampfire";
		object oLampEffect = GetObjectByTag(sLampEffect);
		DestroyObject(oLampEffect);
		SetLocalInt(oSelf, "lit", 1);
	}


}

void checkLights(string torch)
{
	string sLamp1 = "puzzlelamp1";
	object oLamp1 = GetObjectByTag(sLamp1);	
	string sLamp2 = "puzzlelamp2";
	object oLamp2 = GetObjectByTag(sLamp2);
	string sLamp3 = "puzzlelamp3";
	object oLamp3 = GetObjectByTag(sLamp3);
	string sLamp4 = "puzzlelamp4";
	object oLamp4 = GetObjectByTag(sLamp4);
	string sLamp5 = "puzzlelamp5";
	object oLamp5 = GetObjectByTag(sLamp5);
	string sLamp6 = "puzzlelamp6";
	object oLamp6 = GetObjectByTag(sLamp6);			

	if(torch == "puzzlelamp1")
	{
		LightExtinguishLamps(oLamp2, sLamp2);	
		LightExtinguishLamps(oLamp3, sLamp3);
	}
	if(torch == "puzzlelamp2")
	{
		LightExtinguishLamps(oLamp1, sLamp1);	
		LightExtinguishLamps(oLamp4, sLamp4);
	}
	if(torch == "puzzlelamp3")
	{
		LightExtinguishLamps(oLamp1, sLamp1);
		LightExtinguishLamps(oLamp4, sLamp4);		
		LightExtinguishLamps(oLamp5, sLamp5);
	}
	if(torch == "puzzlelamp4")
	{
		LightExtinguishLamps(oLamp2, sLamp2);	
		LightExtinguishLamps(oLamp3, sLamp3);
		LightExtinguishLamps(oLamp6, sLamp6);		
	}
	if(torch == "puzzlelamp5")
	{
		LightExtinguishLamps(oLamp3, sLamp3);	
		LightExtinguishLamps(oLamp6, sLamp6);	
	}
	if(torch == "puzzlelamp6")
	{
		LightExtinguishLamps(oLamp4, sLamp4);	
		LightExtinguishLamps(oLamp5, sLamp5);	
	}				

	//Check if all lamps are lit
	if(GetLocalInt(oLamp1, "lit") == 1 && 
	   GetLocalInt(oLamp2, "lit") == 1 &&
	   GetLocalInt(oLamp3, "lit") == 1 &&
	   GetLocalInt(oLamp4, "lit") == 1 &&
	   GetLocalInt(oLamp5, "lit") == 1 &&
	   GetLocalInt(oLamp6, "lit") == 1)
	{
	//	SendMessageToPC(oPC, "You've won");
	
		SetUseableFlag(oLamp1, 0);
		SetUseableFlag(oLamp2, 0);
		SetUseableFlag(oLamp3, 0);
		SetUseableFlag(oLamp4, 0);
		SetUseableFlag(oLamp5, 0);
		SetUseableFlag(oLamp6, 0);
		
		SetLocalInt(oTorchPuzzleDoor, sTorchPuzzleLocalInt, 1);
		ActionOpenDoor(oTorchPuzzleDoor);
		
		//GiveXPToCreature(oPC, XpReward);
		
	}

}

void main()
{
	object oSelf = OBJECT_SELF;
	string sLamp = GetTag(oSelf);
	LightExtinguishLamps(oSelf, sLamp);
	checkLights(sLamp);
}