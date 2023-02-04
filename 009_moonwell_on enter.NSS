/*Place this around Moonwells to simulate their healing ability */
// 009_moonwell_on enter   by Arianna0  2/3/2023




void main()
{

object oPC = GetEnteringObject();

if (!GetIsPC(oPC)) return;

int DoOnce = GetLocalInt(oPC, GetTag(OBJECT_SELF));

if (DoOnce==TRUE) return;

SetLocalInt(oPC, GetTag(OBJECT_SELF), TRUE);

object oCaster;
oCaster = GetObjectByTag("009_moonwell_heals");
 {
        SendMessageToPC(oPC, "You feel a gentle warm spread through your body and mind as you enter the water");
        return;
    }


object oTarget;
oTarget = oPC;

AssignCommand(oCaster, ActionCastSpellAtObject(SPELL_HEAL, oTarget, METAMAGIC_ANY, TRUE, 20, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));

}