init()
{
	if ( !isDefined("enableRestrictedKillstreaks") )
    {
        setDvarIfUninitialized("enableRestrictedKillstreaks", 1); 
    }

    if ( getDvarInt("enableRestrictedKillstreaks") != 1 )
    {
        return; 
    }

    level thread constantMessageLoop();
}

constantMessageLoop()
{
    while(1)
    {
        foreach (player in level.players)
        {
            if (isDefined(player.pers["killstreaks"]) && player.pers["killstreaks"].size > 0)
            {
                for (i = 0; i < player.pers["killstreaks"].size; i++)
                {
                    if (player.pers["killstreaks"][i].streakName == "counter_radar_mp")
                    {
                        player.pers["killstreaks"][i].streakName = "radar_mp";
                        player iprintlnbold("^7Counter UAV has been replaced with UAV to stick to the server theme.");
                        player SetActionSlot(4, "");
                        player giveweapon("radar_mp");
                        player givemaxammo("radar_mp");
                        player setactionslot(4, "weapon", "radar_mp");
                    }
					else if (player.pers["killstreaks"][i].streakName == "airdrop_marker_mp")
					{
						player.pers["killstreaks"][i].streakName = "radar_mp";
                        player iprintlnbold("^7Care Package has been replaced with UAV to stick to the server theme.");
                        player SetActionSlot(4, "");
                        player giveweapon("radar_mp");
                        player givemaxammo("radar_mp");
                        player setactionslot(4, "weapon", "radar_mp");
					}
					else if (player.pers["killstreaks"][i].streakName == "sentry_mp")
					{
						player.pers["killstreaks"][i].streakName = "radar_mp";
                        player iprintlnbold("^7Sentry Gun has been replaced with UAV to stick to the server theme.");
                        player SetActionSlot(4, "");
                        player giveweapon("radar_mp");
                        player givemaxammo("radar_mp");
                        player setactionslot(4, "weapon", "radar_mp");
					}
					else if (player.pers["killstreaks"][i].streakName == "predator_mp")
					{
						player.pers["killstreaks"][i].streakName = "radar_mp";
                        player iprintlnbold("^7Predator Missile has been replaced with UAV to stick to the server theme.");
                        player SetActionSlot(4, "");
                        player giveweapon("radar_mp");
                        player givemaxammo("radar_mp");
                        player setactionslot(4, "weapon", "radar_mp");
					}
					else if (player.pers["killstreaks"][i].streakName == "harrier_airstrike_mp")
					{
						player.pers["killstreaks"][i].streakName = "airstrike_mp";
                        player iprintlnbold("^7Harrier Strike has been replaced with Airstrike to stick to the server theme.");
                        player SetActionSlot(4, "");
                        player giveweapon("airstrike_mp");
                        player givemaxammo("airstrike_mp");
                        player setactionslot(4, "weapon", "airstrike_mp");
					}
					else if (player.pers["killstreaks"][i].streakName == "airdrop_mega_marker_mp")
					{
						player.pers["killstreaks"][i].streakName = "helicopter_mp";
                        player iprintlnbold("^7Emergency Airdrop has been replaced with Helicopter to stick to the server theme.");
                        player SetActionSlot(4, "");
                        player giveweapon("helicopter_mp");
                        player givemaxammo("helicopter_mp");
                        player setactionslot(4, "weapon", "helicopter_mp");
					}
					else if (player.pers["killstreaks"][i].streakName == "pavelow_mp")
					{
						player.pers["killstreaks"][i].streakName = "helicopter_mp";
                        player iprintlnbold("^7Pave Low has been replaced with Helicopter to stick to the server theme.");
                        player SetActionSlot(4, "");
                        player giveweapon("helicopter_mp");
                        player givemaxammo("helicopter_mp");
                        player setactionslot(4, "weapon", "helicopter_mp");
					}
					else if (player.pers["killstreaks"][i].streakName == "stealth_airstrike_mp")
					{
						player.pers["killstreaks"][i].streakName = "airstrike_mp";
                        player iprintlnbold("^7Stealth Bomber has been replaced with Airstrike to stick to the server theme.");
                        player SetActionSlot(4, "");
                        player giveweapon("airstrike_mp");
                        player givemaxammo("airstrike_mp");
                        player setactionslot(4, "weapon", "airstrike_mp");
					}
					else if (player.pers["killstreaks"][i].streakName == "chopper_gunner_mp")
					{
						player.pers["killstreaks"][i].streakName = "airstrike_mp";
                        player iprintlnbold("^7Chopper Gunner has been replaced with Airstrike to stick to the server theme.");
                        player SetActionSlot(4, "");
                        player giveweapon("airstrike_mp");
                        player givemaxammo("airstrike_mp");
                        player setactionslot(4, "weapon", "airstrike_mp");
					}
					else if (player.pers["killstreaks"][i].streakName == "ac130_mp")
					{
						player.pers["killstreaks"][i].streakName = "airstrike_mp";
                        player iprintlnbold("^7AC130 has been replaced with Airstrike to stick to the server theme.");
                        player SetActionSlot(4, "");
                        player giveweapon("airstrike_mp");
                        player givemaxammo("airstrike_mp");
                        player setactionslot(4, "weapon", "airstrike_mp");
					}
					else if (player.pers["killstreaks"][i].streakName == "emp_mp")
					{
						player.pers["killstreaks"][i].streakName = "helicopter_mp";
                        player iprintlnbold("^7EMP has been replaced with Helicopter to stick to the server theme.");
                        player SetActionSlot(4, "");
                        player giveweapon("helicopter_mp");
                        player givemaxammo("helicopter_mp");
                        player setactionslot(4, "weapon", "helicopter_mp");
					}
					else if (player.pers["killstreaks"][i].streakName == "nuke_mp")
					{
						player.pers["killstreaks"][i].streakName = "airstrike_mp";
                        player iprintlnbold("^7Nuke has been replaced with Airstrike to stick to the server theme.");
                        player SetActionSlot(4, "");
                        player giveweapon("airstrike_mp");
                        player givemaxammo("airstrike_mp");
                        player setactionslot(4, "weapon", "airstrike_mp");
					}
                }
            }
        }

        // Wait for a few seconds before checking again
        wait 0.2;
    }
}