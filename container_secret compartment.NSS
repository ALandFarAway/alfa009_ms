// OnInventoryDisturbed
void main()
{

int iType = GetInventoryDisturbType();
object oItem = GetInventoryDisturbItem();
object oPC = GetLastUsedBy();
string sTemplate = GetLocalString(OBJECT_SELF, "sItem");
int nQuantity = GetLocalInt(OBJECT_SELF, "nQuantity");

if(GetLocalInt(OBJECT_SELF, GetTag(OBJECT_SELF)) == TRUE) return;

switch(iType)
{
case INVENTORY_DISTURB_TYPE_REMOVED:
{
if(oItem == GetObjectByTag("sItemTag")) // sItemTag is simply the tag of your junk item in quotes " "
{
SetLocalInt(OBJECT_SELF, GetTag(OBJECT_SELF), TRUE);

CreateItemOnObject(sTemplate, OBJECT_SELF, nQuantity);

ActionSpeakString("*SUCCESS* You found a secret compartment in the chest.");
}
else return;
}
}

}
