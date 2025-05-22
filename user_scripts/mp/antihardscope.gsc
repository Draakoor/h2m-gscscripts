<@1157700979886657619> applyAntiHardscopeSystem()
{
    self endon("disconnect");

    // Prevent duplicate threads
    if (isDefined(self.hardscopeThread))
        return;
    self.hardscopeThread = true;
    // Loop the anti-hardscope system after player death
    for (;;)
    {
        AntiHardScopeEnabled = true;
        MaxScopeTime = 0.5; // Adjust time here
        if (AntiHardScopeEnabled)
        {
            self thread monitorAntiHardscope(MaxScopeTime);
        }
        // Wait until player dies before restarting the system
        self waittill("death");
        
        // Reset the hardscope thread flag to allow a new thread
        self.hardscopeThread = undefined;
        
        // Wait for respawn
        self waittill("spawned_player");
        
        // Set the flag again for the new life
        self.hardscopeThread = true;
    }
}


monitorAntiHardscope(scopeTime)
{
    self endon("disconnect");
    self endon("death");

    if (!isDefined(scopeTime) || scopeTime < 0.05)
        scopeTime = 3;

    adsTime = 0;

    hudWarning = createFontString("objective", 1.6);
    hudWarning setPoint("CENTER", "CENTER", 0, -150);
    hudWarning.alpha = 0;
    hudWarning.hideWhenInMenu = true;

    self thread cleanupAntiHardscopeHUD(hudWarning);

    loopInterval = 0.05;
    scopeLimit = int(scopeTime / loopInterval);

    for (;;)
    {
        if (self playerAds() == 1)
        {
            adsTime++;
        }
        else
        {
            adsTime = 0;
            hudWarning.alpha = 0;
        }

        if (adsTime >= scopeLimit)
        {
            adsTime = 0;

            hudWarning setText("^1No Hardscoping!");
            hudWarning.alpha = 1;

            self allowAds(false);

            while (self playerAds() > 0)
                wait(loopInterval);

            self allowAds(true);

            wait 0.5;
            hudWarning.alpha = 0;
        }

        wait(loopInterval);
    }
}

cleanupAntiHardscopeHUD(hud)
{
    self waittill("death");

    if (isDefined(hud))
        hud destroy();
}
