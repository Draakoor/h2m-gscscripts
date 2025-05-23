init()
{
    level thread onPlayerConnect();
    setDvar("lowGravity", "0"); 
    setDvar("gravityValue", "400"); 
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
        if(getDvarInt("lowGravity") == 1)
        {
            self thread applyLowGravity();
        }
    }
}

applyLowGravity()
{
    gravity = getDvarInt("gravityValue");
    setDvar("g_gravity", gravity);
    self iPrintLnBold("^3Low gravity activated: Gravity = " + gravity);
}