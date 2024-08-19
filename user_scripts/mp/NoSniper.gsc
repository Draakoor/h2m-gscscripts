#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gamelogic;

init()
{   
	if (getDvarInt("nosniper") == 1) {
	level thread onPlayerConnect();
	}
}

restrictWeapons()
{
	weapon = self getCurrentWeapon();

	// Check if weapon is a sniper
	if (	
			weapon != self.secondaryWeapon &&
		   	(
				isSubStr(weapon, "cheytac") ||
				isSubStr(weapon, "barrett") ||
				isSubStr(weapon, "wa2000") ||
				isSubStr(weapon, "m21") ||
				isSubStr(weapon, "m40a3")
			)
		)
	{
		self takeWeapon(weapon);
		self giveWeapon("h2_m4_mp");

		// wait .1 second as switchToWeapon doesn't seem to work when called directly after giveWeapon
		wait(.1);
		self switchToWeapon("h2_m4_mp");
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