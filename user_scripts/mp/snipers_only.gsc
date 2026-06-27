#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gamelogic;

init()
{   
	if (getDvarInt("sniperport") == 1) {
	level thread onPlayerConnect();
	level.OriginalCallbackPlayerDamage = level.callbackPlayerDamage;
    level.callbackPlayerDamage = ::CodeCallback_PlayerDamage;
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
		self thread ammoLoop();
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
    //blast shield is not removed maybe buggy
    self takeweapon("specialty_blastshield");
    self maps\mp\_utility::_unsetperk("specialty_blastshield");

	weapon = self getCurrentWeapon();

	// Check for weapon attachments and allowed weapons
	if (	
			weapon != self.secondaryWeapon &&
		   	(
				isSubStr(weapon, "thermal") ||
		   		isSubStr(weapon, "heartbeat") ||
				isSubStr(weapon, "acog") ||
				!(
					isSubStr(weapon, "cheytac") ||
					isSubStr(weapon, "barrett") ||
					isSubStr(weapon, "wa2000") ||
					isSubStr(weapon, "usr") ||
					isSubStr(weapon, "l118a") ||
					isSubStr(weapon, "d25s") ||
					isSubStr(weapon, "m21") ||
					isSubStr(weapon, "as50") ||
					isSubStr(weapon, "msr") ||
					isSubStr(weapon, "m40a3") ||
					isSubStr(weapon, "throwingknife") ||
					isSubStr(weapon, "briefcase_bomb") ||
					isSubStr(weapon, "tacticalinsertion")
				)
			)
		)
	{
		self takeWeapon(weapon);
		self giveWeapon("h2_cheytac_mp");
        //throwing knife doesnt work
        self setlethalweapon("iw9_throwknife_mp");
        self giveWeapon ("iw9_throwknife_mp");

		// wait .1 second as switchToWeapon doesn't seem to work when called directly after giveWeapon
		wait(.1);
		self switchToWeapon("h2_cheytac_mp");
        //should give some sniper perks
        self maps\mp\_utility::giveperk("specialty_fastreload", 0);
		self maps\mp\_utility::giveperk("specialty_quickdraw", 0);
        self maps\mp\_utility::giveperk("specialty_longersprint", 0);
        self maps\mp\_utility::giveperk("specialty_fastmantle", 0);
        self maps\mp\_utility::giveperk("specialty_lightweight", 0);
        self maps\mp\_utility::giveperk("specialty_fastsprintrecovery", 0);
        self maps\mp\_utility::giveperk("specialty_bulletdamage", 0);
        self maps\mp\_utility::giveperk("specialty_armorpiercing", 0);
        self maps\mp\_utility::giveperk("specialty_extendedmelee", 0);
        self maps\mp\_utility::giveperk("specialty_falldamage", 0);
        self maps\mp\_utility::giveperk("specialty_bulletaccuracy", 0);
        self maps\mp\_utility::giveperk("specialty_holdbreath", 0);
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

ammoLoop()
{
	while (true)
	{
		self waittill("weapon_fired");
		ammoWeapon = self getCurrentWeapon();

		if (ammoWeapon != self.secondaryWeapon)
		{
			self giveMaxAmmo(ammoWeapon);
		}
	}
}

isSniper( weapon )
{
    return ( 
            isSubstr( weapon, "h2_cheytac") 
        ||  isSubstr( weapon, "h2_barrett" ) 
        ||  isSubstr( weapon, "h2_wa2000" ) 
        ||  isSubstr( weapon, "h2_m21" ) 
        ||  isSubstr( weapon, "h2_m40a3" ) 
		||  isSubstr( weapon, "h2_as50" ) 
		||  isSubstr( weapon, "h2_d25s" ) 
        ||  IsSubStr( weapon, "h2_msr")
		||  IsSubStr( weapon, "h2_usr")
		||  IsSubStr( weapon, "h2_l118a")
		||  IsSubStr( weapon, "h2_msr")
		||  IsSubStr( weapon, "briefcase_bomb")
        //||  isSubstr( weapon, "h1_febsnp" )
        //||  isSubstr( weapon, "h1_junsnp" )
    );
}

CodeCallback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
      self endon("disconnect");
    if(sMeansOfDeath == "MOD_TRIGGER_HURT" || sMeansOfDeath == "MOD_HIT_BY_OBJECT" || sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_MELEE")
    {
        return;
    }
    else
    {
        if( isSniper( sWeapon ) )
        {
            iDamage = 999;  
        }
        else 
            return;
        
        [[level.OriginalCallbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
    }       
}
