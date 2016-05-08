    //Written by kevL on the bioware scripting forums
	// Playce a waypoint w/tag "DST_DST_RUGPIT in the area where the PC would fall into
    //place another waypoint w/ tag "DST_RUGPIT_START" where the PC should warp to if either save is successful, 
    
	#include "nw_i0_spells"
     
    void play(object oPC, string sAnimation);
    void finish(object oPC);
    void saved(object oPC, string sWarning);
     
    //
    void main()
    {
        object oPC = GetEnteringObject();
     
        if (GetIsPC(oPC))
        {
            // Show spell-resistance icon if PC's immunity is triggered:
            if (!MySavingThrow(SAVING_THROW_WILL, oPC, 22, SAVING_THROW_TYPE_MIND_SPELLS))
            {
                // Do not show resistance icon:
                if (!ReflexSave(oPC, 22, SAVING_THROW_TYPE_TRAP))
                {
                    // Note that several of these AssignCommands() are required to maintain an unhindered sequence.
                    AssignCommand(oPC, ClearAllActions());
     
                    object oWp = GetNearestObjectByTag("DST_RUGPIT");
                    AssignCommand(oPC, JumpToObject(oWp));
     
                    AssignCommand(oPC, SpeakString("The rug is an illusion and you've fallen into a pit!"));
                    AssignCommand(oPC, DelayCommand(2.9, SpeakString("ouch...")));
     
                    AssignCommand(oPC, PlaySound("thud")); // should change this to a "thud"
     
                    effect eBludgeon = EffectDamage(d6(2), DAMAGE_TYPE_BLUDGEONING);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eBludgeon, oPC);
     
                    effect eDust = EffectNWN2SpecialEffectFile("fx_wooden_explosion");
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDust, oPC);
     
                    AssignCommand(oPC, play(oPC, "pronedamageB"));
     
                    int iVoice = Random(3);
                    switch (iVoice)
                    {
                        case 0: iVoice = VOICE_CHAT_PAIN1; break;
                        case 1: iVoice = VOICE_CHAT_PAIN2; break;
                        case 2: iVoice = VOICE_CHAT_PAIN3;
                    }
                    AssignCommand(oPC, DelayCommand(0.23, PlayVoiceChat(iVoice, oPC)));
                    // The voice-chat won't play if its delay is too short; likely a conflict with PlaySound() above.
     
                    DelayCommand(7.6, finish(oPC));
                    AssignCommand(oPC, SetCommandable(FALSE, oPC));
                }
                else // saved vs Reflex!
                {
                    saved(oPC, "The rug conceals a pit.");
                }
            }
            else // saved vs Mind Spells!
            {
                saved(oPC, "The rug is an illusion.");
            }
        }
    }
     
    //
    void play(object oPC, string sAnimation)
    {
        PlayCustomAnimation(oPC, sAnimation, TRUE);
    }
     
    //
    void finish(object oPC)
    {
        SetCommandable(TRUE, oPC);
        PlayCustomAnimation(oPC, "%", TRUE); // idle
    }
     
    //
    void saved(object oPC, string sWarning)
    {
        AssignCommand(oPC, ClearAllActions());
     
        AssignCommand(oPC, SpeakString(sWarning));
        AssignCommand(oPC, PlayVoiceChat(VOICE_CHAT_CUSS, oPC));
     
        object oWp = GetNearestObjectByTag("DST_RUGPIT_START");
        AssignCommand(oPC, JumpToObject(oWp));
    }