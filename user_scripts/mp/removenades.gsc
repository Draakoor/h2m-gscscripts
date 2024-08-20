#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gamelogic;

init()
{   
	if (getDvarInt("removenades") == 1) {
	level thread onPlayerConnect();
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

restrictWeapons()
{
	self takeWeapon("h2_semtex_mp");
    self takeweapon("h1_fraggrenade_mp");
    self takeweapon("h1_claymore_mp");
    self takeweapon("h1_c4_mp");
    self takeWeapon("h1_flashgrenade_mp");
	self takeWeapon("h1_concussiongrenade_mp");
	self takeWeapon("h1_smokegrenade_mp");
    self takeweapon("h2m_weapon_c4");
    self takeweapon("h2m_weapon_claymore");
    self maps\mp\_utility::_unsetperk("specialty_blastshield");
}

applyGameMode()
{	
	for (count=0;count<15;count++)
	{
		self restrictWeapons();

		wait(3);
	}
}