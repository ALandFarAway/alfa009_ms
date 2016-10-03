// =============================================================
//
//    File: row_fp_door_close
//    Desc: Rowell's Fair Play Door - Close Event
//  Author: Michael Marzilli
//    Site: http://www.engliton.org
//
// Created: Oct 02, 2006
// Updated: Nov 02, 2006
// Version: 1.0.0
//
// =============================================================

void main() {
	object oDoor = OBJECT_SELF;
	
	if (GetLocalInt(oDoor, "IsLocked")  == 1) { SetLocked(oDoor, TRUE); }
	if (GetLocalInt(oDoor, "IsTrapped") == 1) { SetTrapActive(oDoor, TRUE); }
	SetLocalInt(oDoor, "CurHP", GetMaxHitPoints(oDoor));
	DelayCommand(0.2, ClearAllActions(TRUE));
	
}