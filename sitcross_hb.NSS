
// Put this OnHeartbeat.
//  Will make NPC sit on the ground crosslegged  sitgrounddown sitgroundidle	
// Will abort (do nothing) if fighting or talking or if no PCs are in the area.


void main()

{
object oPC = GetLastPerceived();

if (!GetIsPC(oPC)) return;

if (!GetLastPerceptionSeen()) return;
object oTarget;
oTarget = OBJECT_SELF;

	if (GetLocalInt(GetModule(),"Stop Ambient Life"))
	{
		return;
	}

	int nRandom=Random(1);
	if (nRandom==0)

	PlayCustomAnimation(OBJECT_SELF,"sitgroundidle", 1);
	//	AssignCommand(oNPC, ActionPlayAnimation(sitgroundidle));
	
}