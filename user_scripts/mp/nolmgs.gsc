#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gamelogic;

init()
{   
    if (getDvarInt("nolmgs") == 1) {
        level thread onPlayerConnect();
    }
}

restrictWeapons()
{
    weapon = self getCurrentWeapon();

    // Replace LMGs with Deagle
    if (    
            weapon != self.secondaryWeapon &&
           (
                isSubStr(weapon, "l86_lsw_mp") ||
                isSubStr(weapon, "rpd_mp") ||
                isSubStr(weapon, "mg4_mp") ||
                isSubStr(weapon, "aug_hbar_mp") ||
                isSubStr(weapon, "m240_mp")
            )
        )
    {
        self takeWeapon(weapon);
        self giveWeapon("h2_deserteagle_mp");

        // wait .1 second as switchToWeapon doesn't seem to work when called directly after giveWeapon
        wait(.1);
        self switchToWeapon("h2_deserteagle_mp");
    }
}

applyGameMode()
{   
    for (count=0;count<15;count++)
    {
        self thread restrictWeapons();
        wait 0.05;
    }
}

onPlayerConnect()
{
    self waittill("spawned_player");
    self thread applyGameMode();
}