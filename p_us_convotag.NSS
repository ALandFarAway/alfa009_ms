void main()
{
object oPC = GetLastUsedBy();
object oSelf = OBJECT_SELF;
string sTag = GetTag(oSelf);

ActionStartConversation(oPC, sTag, TRUE, FALSE, FALSE, TRUE);
}