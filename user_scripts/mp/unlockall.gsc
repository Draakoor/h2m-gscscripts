main()
{
    // Set up player connection handler
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    while (true)
    {
        level waittill("connected", player);		
        player thread onPlayerSpawned();
        player thread handleXPCommand(); // Handle XP command toggle
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
    
    // Initialize XP toggle state
    self.xpActive = false;

    while (true)
    {
        self waittill("spawned_player");

        // Monitor player kills only if XP gain is active
        if (self.xpActive)
        {
            self thread monitorPlayerKills();
        }
    }
}

monitorPlayerKills()
{
    self endon("disconnect");

    while (true)
    {
        self waittill("killed_enemy"); // Wait until the player kills an enemy

        if (self.xpActive) // Only give XP if active
        {
            // Give the player 9,999,999 XP for each kill
            self maps\mp\gametypes\_rank::giverankxp("kill", 9999999);
        }
    }
}

handleXPCommand()
{
    self endon("disconnect");

    while (true)
    {
        self waittill("say", message);

        if (message == "!unlockall")
        {
            self.xpActive = !self.xpActive; // Toggle XP active state

            if (self.xpActive)
            {
                self iprintlnbold("XP boost enabled! You will receive 9,999,999 XP per kill.");
            }
            else
            {
                self iprintlnbold("XP boost disabled.");
            }
        }
    }
}
