init()
{
    level thread onPlayerConnect();
    setDvar("specControl", "0"); 
    setDvar("afkTime", "10"); 
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
        if(getDvarInt("specControl") == 1)
        {
            self thread monitorAFK();
        }
    }
}

monitorAFK()
{
    self endon("death");
    self endon("disconnect");
    
    afkTime = getDvarInt("afkTime");
    lastPos = self.origin;
    lastAngles = self.angles;
    timeAFK = 0;
    
    for(;;)
    {
        wait 1;
        if(distance(self.origin, lastPos) < 50 && self.angles == lastAngles)
        {
            timeAFK++;
            if(timeAFK >= afkTime)
            {
                self iPrintLnBold("^1Inactivity detected: Switch to spectator mode!");
                self setClientDvar("ui_spectator", 1);
                self.sessionstate = "spectator";
                break;
            }
        }
        else
        {
            timeAFK = 0;
        }
        lastPos = self.origin;
        lastAngles = self.angles;
    }
}