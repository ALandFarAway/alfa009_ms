//OnUse for shovel placeable
//Wynna September 2007


#include "acr_placeable_i"

void main()
{
	ACR_PlaceableOnUsed();
    object oUser = GetLastUsedBy();
	 
	//Shovel
	 	
	 if(GetTag(OBJECT_SELF) == "abr_plc_shovel_port")
	 	{object oRubble = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_PLACEABLE);
		 while(oRubble != OBJECT_INVALID){
		 	if((FindSubString(GetTag(oRubble), "rubble") != -1) || (FindSubString(GetTag(oRubble), "rock") != -1) || (FindSubString(GetName(oRubble), "dirt") != -1) || (FindSubString(GetName(oRubble), "bone") != -1)) 
				{DestroyObject(oRubble);
				 SendMessageToPC(oUser, "The area is a littler clearer.");
				 return;
				 }
			 else
			 oRubble = GetNextObjectInShape(SHAPE_SPHERE, 5.0, GetLocation(OBJECT_SELF), FALSE, OBJECT_TYPE_PLACEABLE);
		 }
		 
		 
		 SendMessageToPC(oUser, "The area is clear and you pick up the shovel.");
		 CreateItemOnObject("abr_it_gr_shovel_port", oUser, 1);
		 DestroyObject(OBJECT_SELF, 0.5);
		 }  
		
				
}