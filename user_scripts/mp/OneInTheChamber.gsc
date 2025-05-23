#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gamelogic;

init()
{
    setDvar("oneInTheChamber", "0"); 
    setDvar("sv_gametype", "dm"); 
    
    if (getDvarInt("oneInTheChamber") == 1)
    {
        level thread onPlayerConnect();
    }
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
        if(getDvarInt("oneInTheChamber") == 1)
        {
            self thread applyGameMode();
        }
    }
}

applyGameMode()
{
    self.maxhealth = 50;
    self.health = 50;
    
    self takeAllWeapons();
    self giveWeapon("h2_deserteagle_mp");
    self setWeaponAmmoClip("h2_deserteagle_mp", 1);
    self setWeaponAmmoStock("h2_deserteagle_mp", 0);
    wait 0.1; 
    self switchToWeapon("h2_deserteagle_mp");
    
    self clearPerks();
    self takeWeapon("frag_grenade_mp");
    self takeWeapon("flash_grenade_mp");
    
    self iPrintLnBold("^3One in the Chamber (FFA): 1 bullet, 50 HP!");
    
    self thread monitorKills();
    self thread restrictWeapons();
}

monitorKills()
{
    self endon("death");
    self endon("disconnect");
    
    for(;;)
    {
        self waittill("killed_enemy");
        self setWeaponAmmoClip("h2_deserteagle_mp", self getWeaponAmmoClip("h2_deserteagle_mp") + 1);
        self iPrintLnBold("^2+1 bullet for your kill!");
    }
}

restrictWeapons()
{
    self endon("death");
    self endon("disconnect");
    
    for(;;)
    {
        weapon = self getCurrentWeapon();
        if(isDefined(weapon) && weapon != "none" && weapon != "h2_deserteagle_mp")
        {
            self takeWeapon(weapon);
            self giveWeapon("h2_deserteagle_mp");
            self setWeaponAmmoClip("h2_deserteagle_mp", 1);
            wait 0.1; 
            self switchToWeapon("h2_deserteagle_mp");
            self iPrintLnBold("^1Only h2_deserteagle_mp is allowed!");
        }
        wait 0.05;
    }
}