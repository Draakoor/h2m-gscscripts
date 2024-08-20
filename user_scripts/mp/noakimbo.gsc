#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gamelogic;

init()
{   
	if (getDvarInt("noakimbo") == 1) {
	level thread onPlayerConnect();
	}
}

restrictWeapons()
{
	weapon = self getCurrentWeapon();

    //replace secondary launchers with desert eagle, only allow stinger for killstreaks etc
    if (	
			weapon != self.secondaryWeapon &&
		   	(
				isSubStr(weapon, "akimbo")
			)
		)
	{
		self takeWeapon(weapon);
		self giveWeapon("h2_ump45_mp");

		// wait .1 second as switchToWeapon doesn't seem to work when called directly after giveWeapon
		wait(.1);
		self switchToWeapon("h2_ump45_mp");
	}
     if (	
			weapon != self.PrimaryWeapon &&
		   	(
				isSubStr(weapon, "akimbo")
			)
		)
	{
		self takeWeapon(weapon);
		self giveWeapon("h2_usp_mp");

		// wait .1 second as switchToWeapon doesn't seem to work when called directly after giveWeapon
		wait(.1);
		self switchToWeapon("h2_usp_mp");
	}
}

applyGameMode()
{	
	for (count=0;count<15;count++)
	{
		self restrictWeapons();
		wait(3);
	}
}

onPlayerConnect()
{
	while (true)
	{
		level waittill("connected", player);		

		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	
	while (true)
	{
		self waittill("spawned_player");

		self thread applyGameMode();
	}
}