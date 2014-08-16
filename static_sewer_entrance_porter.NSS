//Port upon use to WD sewers

void main() {
        object oUser = GetLastUsedBy();
        AssignCommand(oUser, JumpToObject(GetWaypointByTag("WD_SEWERS_LADDER_BOTTOM")));
}