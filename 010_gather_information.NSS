#include "acr_quest_i"
#include "acr_notifications_i"
#include "acr_skills_i"
#include "acr_i"

void main()
{
	object oPC = GetEnteringObject();
	if(!GetIsPC(oPC)) return;
	string sLocale = GetLocalString(OBJECT_SELF, "GI_REGION");
	int nID = GetLocalInt(oPC, "ACR_CID");
	if(sLocale == "BG_CITY")
	{
		int nIntro = ACR_RetrieveQuestState("010_intro", oPC);
		if(nIntro == 1)
		{
			// If this PC hasn't yet been told about BG city, give them a blurb.
			if(!GetLocalInt(oPC, "GI_BG_CITY"))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"\nBaldur's Gate.", 
							"Baldur's Gate is a wealthy city state on the Chionthar river, focused on trade. It is ruled by a council of four dukes: Eltan, Belt, Jannath, and Silvershield. Each having significant power and position in their own right, though Eltan is often most prominent for his leadership of the Flaming Fist, which is the power behind many of the city's military expeditions.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
				SetLocalInt(oPC, "GI_BG_CITY", 1);
			}
			
			// If we've already passed this trigger for this quest, give this a miss.
			if(GetLocalInt(OBJECT_SELF, IntToString(nID) + "_1")) return;
			
			// Otherwise, roll GI and flag this trigger to not repeat for this PC.
			if(ACR_SkillCheck(SKILL_GATHER_INFORMATION, oPC, 15, TRUE, FALSE))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"You catch word of where Beryl is.", 
							"A man with Beryl's description has been seen in the Elfsong tavern, which is a bar just east of the market square, a short walk in from the city's eastern gate.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
			}
			SetLocalInt(OBJECT_SELF, IntToString(nID) + "_1", 1);
		}
		else if(nIntro == 2)
		{
			// If we've already passed this trigger for this quest, give this a miss.
			if(GetLocalInt(OBJECT_SELF, IntToString(nID) + "_2")) return;
			
			// Otherwise, roll GI and flag this trigger to not repeat for this PC.
			if(ACR_SkillCheck(SKILL_GATHER_INFORMATION, oPC, 15, TRUE, FALSE))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"You catch word of where Ginny is.", 
							"A woman like the one Beryl described has been seen heading to the guard post, which is a good walk west of the Elfsong, near the temple of Umberlee.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
			}
			SetLocalInt(OBJECT_SELF, IntToString(nID) + "_2", 1);
		}
		else if(nIntro == 200 || nIntro == 400 || nIntro == 500)
		{
			if(GetLocalInt(OBJECT_SELF, IntToString(nID) + "_200")) return;
			
			if(ACR_SkillCheck(SKILL_GATHER_INFORMATION, oPC, 15, TRUE, FALSE))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"\nWork may be available.", 
							"It sounds from chatter on the streets like Beryl, who you recall from his abuse of his partner and her conversation at the watch post, has been captured and the city is hoping to bring in more help moving him back to the city.\n\nDetails would be available at the Baldur's Gate watch post.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
			}
			SetLocalInt(OBJECT_SELF, IntToString(nID) + "_200", 1);
		}
		else if(nIntro == 100 || nIntro == 300)
		{
			if(GetLocalInt(OBJECT_SELF, IntToString(nID) + "_100")) return;
			
			if(ACR_SkillCheck(SKILL_GATHER_INFORMATION, oPC, 15, TRUE, FALSE))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"\nWork may be available.", 
							"It sounds from chatter on the streets like there is some fuss about the capture of a young man in Ulgoth's Beard, and there might be some work had in response. Near as you can tell, there would be someone to ask outside the eastern gate, near the river.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
			}
			SetLocalInt(OBJECT_SELF, IntToString(nID) + "_100", 1);
		}
		else if(nIntro == 104 || nIntro == 204 || nIntro == 304 || nIntro == 404 || nIntro == 504)
		{
			if(GetLocalInt(OBJECT_SELF, IntToString(nID) + "_104")) return;
			
			if(ACR_SkillCheck(SKILL_GATHER_INFORMATION, oPC, 15, TRUE, FALSE))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"\nSomeone is looking for you.", 
							"You catch word that there was a man looking for someone with your description. The last anyone saw him, he was heading into the post office near the city's eastern gate.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
			}
			SetLocalInt(OBJECT_SELF, IntToString(nID) + "_104", 1);
		}
		
		int nBloodMaw = ACR_RetrieveQuestState("sel_bloodmaw_1", oPC);
		if(nBloodMaw == 1)
		{
			if(GetLocalInt(OBJECT_SELF, IntToString(nID) + "_bloodmaw1")) return;
			SetLocalInt(OBJECT_SELF, IntToString(nID) + "_bloodmaw1", 1);
			
			if(ACR_SkillCheck(SKILL_GATHER_INFORMATION, oPC, 15, TRUE, FALSE))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"\nYou hear something about a certain paladin.", 
							"It sounds like the man you're looking for did pass through Baldur's Gate, but he did not stay. He asked a number of people, not terribly quietly, about members of his family before deciding that they must have gone south and leaving for Beregost.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
				
				
				object oAlly = GetFirstFactionMember(oPC, TRUE);
				while(GetIsObjectValid(oPC))
				{
					if(ACR_RetrieveQuestState("010_intro", oAlly) == 1)
					{
						ACR_AddPersistentJournalQuestEntry("sel_bloodmaw_1", 2, oAlly, FALSE);
					}
					oAlly = GetNextFactionMember(oPC, TRUE);
				}
			}
		}
	}
	else if(sLocale == "ULGOTH")
	{
		int nIntro = ACR_RetrieveQuestState("010_intro", oPC);
		if(nIntro == 101 || nIntro == 201 || nIntro == 301 || nIntro == 401 || nIntro == 501)
		{
						// If this PC hasn't yet been told about BG city, give them a blurb.
			if(!GetLocalInt(oPC, "GI_ULGOTH"))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"\nUlgoth's Beard.", 
							"Ulgoth's Beard is a settlement existing primarily to warn Baldur's Gate in the event of river pirates, who might seek to move up the Chionthar River and attack the valuable Baldurian port. It keeps a very small population and, in recent years, its management and protection has been assigned to a group of Banites calling themselves the Iron Gauntlet, though they are apparently unrelated to the Zhent order.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
				SetLocalInt(oPC, "GI_ULGOTH", 1);
			}
		}
	}
	else if(sLocale == "BEREGOST")
	{
		int nIntro = ACR_RetrieveQuestState("010_intro", oPC);
		if(nIntro == 105 || nIntro == 205 || nIntro == 305 || nIntro == 405 || nIntro == 505)
		{
						// If this PC hasn't yet been told about BG city, give them a blurb.
			if(!GetLocalInt(oPC, "GI_BEREGOST"))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"\nBeregost.", 
							"Beregost is a village on the Trade Way which centers on a large temple to the Morninglord, Lathander. The people are goodly and simple, lead primarily by their governor Kelddath Ormlyr, but the village has traditionally remained neutral to avoid being caught up in the frequent conflicts between Baldurian and Amnian interests.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
				SetLocalInt(oPC, "GI_BEREGOST", 1);
			}
		}
		
		int nBloodMaw = ACR_RetrieveQuestState("sel_bloodmaw_1", oPC);
		if(nBloodMaw == 2)
		{
			if(GetLocalInt(OBJECT_SELF, IntToString(nID) + "_bloodmaw1")) return;
			SetLocalInt(OBJECT_SELF, IntToString(nID) + "_bloodmaw1", 1);
						
			if(ACR_SkillCheck(SKILL_GATHER_INFORMATION, oPC, 20, TRUE, FALSE))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"\nYou hear something about a certain paladin.", 
							"It sounds like the man you're looking for made it to Beregost, but mostly talked to the merchants in the town, and they have since moved on. A few remember him, though, and thought it was odd that he became convinced that he had to ask after them in Gullykin.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
				
				object oAlly = GetFirstFactionMember(oPC, TRUE);
				while(GetIsObjectValid(oPC))
				{
					if(ACR_RetrieveQuestState("sel_bloodmaw_1", oAlly) == 2)
					{	
						ACR_AddPersistentJournalQuestEntry("sel_bloodmaw_1", 3, oAlly, FALSE);
					}
					oAlly = GetNextFactionMember(oPC, TRUE);
				}
			}
		}
	}
	else if(sLocale == "WILDS")
	{
		int nIntro = ACR_RetrieveQuestState("010_intro", oPC);
		if(nIntro == 113 || nIntro == 213 || nIntro == 313 || nIntro == 413 || nIntro == 513)
		{
			// If this PC hasn't yet been sent across dangerous territory, give a little advice.
			if(!GetLocalInt(oPC, "GI_WILDS"))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"\nDangerous Territory.", 
							"There are some areas that are not patroled as regularly as others, like this road. There might be some dangerous creatures on it, but you should be able to avoid them if you keep alert and give anything that looks dangerous a wide berth.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
				SetLocalInt(oPC, "GI_WILDS", 1);
			}
		}
	}
	else if(sLocale == "RUQEL")
	{
		int nIntro = ACR_RetrieveQuestState("010_intro", oPC);
		if(nIntro == 113 || nIntro == 213 || nIntro == 313 || nIntro == 413 || nIntro == 513)
		{
			// If this PC hasn't yet been sent across dangerous territory, give a little advice.
			if(!GetLocalInt(oPC, "GI_RUQEL"))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"\nRuqel.", 
							"Ruqel is a tiny theocracy recently established with an alliance to Candlekeep. They are lead by a champion of Selûne, Teresa Irithyl, and hold the Guardians of Light, an order of Selûne's paladins which had until its found since the days of Netheril. The nation's reputation is mixed, being known both for improving the safety of the region and aggression toward that goal.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
				SetLocalInt(oPC, "GI_RUQEL", 1);
			}
		}
	}
	else if(sLocale == "CANDLEKEEP")
	{
		int nIntro = ACR_RetrieveQuestState("010_intro", oPC);
		if(nIntro == 113 || nIntro == 213 || nIntro == 313 || nIntro == 413 || nIntro == 513)
		{
			// If this PC hasn't yet been sent across dangerous territory, give a little advice.
			if(!GetLocalInt(oPC, "GI_CANDLEKEEP"))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"\nCandlekeep.", 
							"Candlekeep is an isolationist settlement on the coast, dominated by its temple to Oghma, the god of knowledge, and its impressive library. They carefully chronicle lore and history here, including the purportedly-infallible prophecies of Alaundo, but access to these records is notoriously strict-- only allowed to noteworthy scholars or exceptional people who manage to advance knowledge by other means-- and even among members, punishment for damaging the facilities are notoriously brutal.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
				SetLocalInt(oPC, "GI_CANDLEKEEP", 1);
			}
		}
	}
	else if(sLocale == "GULLYKIN")
	{
		int nBloodMaw = ACR_RetrieveQuestState("sel_bloodmaw_1", oPC);
		if(nBloodMaw == 3)
		{
			if(GetLocalInt(OBJECT_SELF, IntToString(nID) + "_bloodmaw1")) return;
			
			if(ACR_SkillCheck(SKILL_GATHER_INFORMATION, oPC, 20, TRUE, FALSE))
			{
				NotifyPlayer(oPC, NOTIFY_TYPE_INFO, 
							"\nYou hear something about a certain paladin.", 
							"It sounds like the man you were looking for was wounded by the time he made it to Gullykin, and spoke increasingly-irrationally to the villagers about his family. It's something of a task to get anyone to talk to you about where he went, as most people just want to talk about how very strange it was. One does tell you, however, that he returned to the north, convinced that he should be checking the fringes of the 'woods'.", 
							NOTIFY_WINDOW_MESSAGE_BOX,"","","OK");
				
				object oAlly = GetFirstFactionMember(oPC, TRUE);
				while(GetIsObjectValid(oPC))
				{
					if(ACR_RetrieveQuestState("sel_bloodmaw_1", oAlly) == 3)
					{	
						ACR_AddPersistentJournalQuestEntry("sel_bloodmaw_1", 4, oAlly, FALSE);
					}
					oAlly = GetNextFactionMember(oPC, TRUE);
				}
				SetLocalInt(OBJECT_SELF, IntToString(nID) + "_bloodmaw1", 1);
			}
		}
	}
}