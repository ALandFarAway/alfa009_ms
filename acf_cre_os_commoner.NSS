////////////////////////////////////////////////////////////////////////////////
//
//  System Name : ACR Configuration File
//     Filename : acf_cre_onspawnin
//    $Revision:: 280        $ current version of the file
//        $Date:: 2007-03-20#$ date the file was created or modified
//       Author : Cipher
//
//    Var Prefix:
//  Dependencies:
//
//  Description
//  This script calls the ACR's OnSpawnIn event handler for creatures
//  and any custom code a server may need. It is not updated in ACR updates.
//
//  Revision History
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Includes ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
#include "acr_creature_i"
#include "009_randomnpc_i"

////////////////////////////////////////////////////////////////////////////////
// Constants ///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Structures //////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Global Variables ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Function Prototypes /////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Function Definitions ////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

///////FLOCKING CODE REMOVED - SAND////////////////


void main()
{
    ACR_CreatureOnSpawnIn();
	
	///RANDOM NAME/////
	string sSuffix;
	if (GetGender(OBJECT_SELF)==1)
		{
		int iR=d6(1);
		switch (iR)
			{
			case 1:sSuffix="a";break;
			case 2:sSuffix="ie";break;
			case 3:sSuffix="re";break;
			case 4:sSuffix="ele";break;
			case 5:sSuffix="na";break;
			case 6:sSuffix="ni";break;
			}	
		}
	
	
	
	string sName1=RandomName();
	string sName2=RandomName();
	SetFirstName(OBJECT_SELF,sName1+sSuffix+" "+sName2+" {Commoner,CR0.5}");
	
	///RANDOM SCALE///
	float fX=(GetScale(OBJECT_SELF,SCALE_X)-0.1)+(IntToFloat(d20(1))/100);
	float fY=(GetScale(OBJECT_SELF,SCALE_Y)-0.1)+(IntToFloat(d20(1))/100);
	float fZ=(GetScale(OBJECT_SELF,SCALE_Z)-0.1)+(IntToFloat(d20(1))/100);
	SetScale(OBJECT_SELF,fX,fY,fZ);
	
	
	///RANDOM EQUIP/////
	int rCloth=d20(1);
	string sArmType;
	int rBoots=d10(1);
	string sBootType;
	
	//create clothing
	switch (rCloth)
		{
		case 1:sArmType="00_alfa_rand_cloth_comylw2";break;
		case 2:sArmType="00_alfa_rand_cloth_blgl";break;
		case 3:sArmType="00_alfa_rand_cloth_laborbl";break;
		case 4:sArmType="00_alfa_rand_cloth_merchbl";break;
		case 5:sArmType="00_alfa_rand_cloth_sailorgrn";break;
		case 6:sArmType="00_alfa_rand_cloth_merchgrn";break;
		case 7:sArmType="00_alfa_rand_cloth_merchgrn1";break;
		case 8:sArmType="00_alfa_rand_cloth_comylw";break;
		case 9:sArmType="00_alfa_rand_cloth_comylw1";break;
		case 10:sArmType="00_alfa_rand_cloth_nobbrn";break;
		case 11:sArmType="00_alfa_rand_cloth_nobbrn1";break;
		case 12:sArmType="00_alfa_rand_cloth_nobred";break;
		case 13:sArmType="00_alfa_rand_cloth_comred";break;
		case 14:sArmType="00_alfa_rand_cloth_comred1";break;
		case 15:sArmType="00_alfa_rand_cloth_comblk";break;
		case 16:sArmType="00_alfa_rand_cloth_comblk1";break;
		case 17:sArmType="00_alfa_rand_cloth_comblk2";break;
		case 18:sArmType="00_alfa_rand_cloth_compurp";break;
		case 19:sArmType="00_alfa_rand_cloth_compurp1";break;
		case 20:sArmType="00_alfa_rand_cloth_compurp2";break;
		}
	object oArmour=CreateItemOnObject(sArmType);
	AssignCommand(OBJECT_SELF,ActionEquipItem(oArmour,1));
	//create boots
	switch (rBoots)
		{
		case 1:sBootType="00_rand_boot_simple";break;
		case 2:sBootType="00_rand_boot_stud";break;
		case 3:sBootType="00_rand_boot_simple1";break;
		case 4:sBootType="00_rand_boot_simple2";break;
		case 5:sBootType="00_rand_boot_simple3";break;
		case 6:sBootType="00_rand_boot_simple4";break;
		case 7:sBootType="00_rand_boot_hide";break;
		case 8:sBootType="00_rand_boot_fancy";break;
		case 9:sBootType="00_rand_boot_fancy1";break;
		case 10:sBootType="00_rand_boot_fancy3";break;
		}
	object oBoots=CreateItemOnObject(sBootType);
	AssignCommand(OBJECT_SELF,ActionEquipItem(oBoots,2)); 

}




