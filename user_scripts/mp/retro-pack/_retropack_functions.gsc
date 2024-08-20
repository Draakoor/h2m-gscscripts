/*
  _____  ______ _______ _____   ____    
 |  __ \|  ____|__   __|  __ \ / __ \   
 | |__) | |__     | |  | |__) | |  | |  
 |  _  /|  __|    | |  |  _  /| |  | |  
 | | \ \| |____   | |  | | \ \| |__| |  
 |_|__\_\______|__| | /|_| _\_\\____/__                   
 | '_ \ / _` |/ __| |/ / _` |/ _` |/ _ \
 | |_) | (_| | (__|   < (_| | (_| |  __/
 | .__/ \__,_|\___|_|\_\__,_|\__, |\___|
 | |                          __/ |     
 |_|                         |___/   

Version: 0.9.1
Date: August 18, 2024
Compatibility: Modern Warfare Remastered (HM2 Mod)
*/
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\_retropack;
#include scripts\mp\_retropack_utility;
#include scripts\mp\_retropack_bots;

testfunction1()
{
	self iPrintLn("^1Hi");
}

doSaveLocation()
{
	self endon ( "disconnect" );
	self.pers["loc"] = true;
	self.pers["savePos"] = self.origin;
	self.pers["saveAng"] = self.angles;
	self iprintln("^2Saved location");
}

doLoadLocation()
{
	self endon ( "disconnect" );
	if (self.pers["loc"] == true) 
	{
		self setOrigin( self.pers["savePos"] );
		self setPlayerAngles( self.pers["saveAng"] );
	}
}

doClassChange()
{
    self endon("disconnect");
 	oldclass = self.pers["class"];
 	for(;;)
 	{
  		if(self.pers["class"] != oldclass)
		{
			self maps\mp\gametypes\_class::setClass( self.pers["class"]);
			self maps\mp\gametypes\_class::giveloadout(self.pers["team"],self.pers["class"]);
			self maps\mp\gametypes\_class::applyloadout();
			if(self.tsperk == 1)
			{
				self maps\mp\_utility::giveperk("specialty_longersprint");
				self maps\mp\_utility::giveperk("specialty_fastsprintrecovery");
				self maps\mp\_utility::giveperk("specialty_falldamage");
			}
			oldclass = self.pers["class"];
		}
  		wait 0.1;
 	}
}

doAmmo()
{
	self endon("endreplenish");
    while (1)
    {
		wait 10;
		currentWeapon = self getCurrentWeapon();
		currentoffhand = self GetCurrentOffhand();
		secondaryweapon = self.SecondaryWeapon;
        if ( currentWeapon != "none" )
        {
            self GiveMaxAmmo( currentWeapon );
        }
        if ( currentoffhand != "none" )
        {
            self setWeaponAmmoClip( currentoffhand, 9999 );
            self GiveMaxAmmo( currentoffhand );
        }
        if ( secondaryweapon != "none" )
        {
            self GiveMaxAmmo( secondaryweapon );
        }
		/*
		self setWeaponAmmoClip( "concussion_grenade_mp", 9999 );
        self GiveMaxAmmo( "concussion_grenade_mp" );
		//self setWeaponAmmoClip( level.classGrenades[class]["secondary"]["type"], 9999 );
        //self GiveMaxAmmo( level.classGrenades[class]["secondary"]["type"] );
        wait 0.05;
		*/
    }
}

removedeathbarrier()
{
	ents = getEntArray();
    for ( index = 0; index < ents.size; index++ )
    {
        if(isSubStr(ents[index].classname, "trigger_hurt"))
        ents[index].origin = (0, 0, 9999999);
	}
	self iPrintln("Death Barriers: ^1[Removed]");
}

monitorRounds()
{
	if(getDvar("g_gametype") == "sd")
	{
		if(game["roundsWon"]["axis"] == 3 || game["roundsWon"]["allies"] == 3 || game["roundsPlayed"] == 6)
		{
			level thread roundReset();
		}
	}
}

roundReset()
{
	game["roundsWon"]["axis"] = 0;
	game["roundsWon"]["allies"] = 0;
	game["roundsPlayed"] = 0;
	game["teamScores"]["allies"] = 0;
	game["teamScores"]["axis"] = 0;	
	//self iPrintln("Rounds Reset");
}

loadBotSpawn()	
{	
	for(i = 0; i < level.players.size; i++)	
	{	
		if (isSubStr( level.players[i].guid, "bot"))	
		{	
			level.players[i] setOrigin( level.players[i].pers["enemybotorigin"] );	
			level.players[i] setPlayerAngles( level.players[i].pers["enemybotangles"] );	
			level.players[i] setOrigin( level.players[i].pers["friendlybotorigin"] );	
			level.players[i] setPlayerAngles( level.players[i].pers["friendlybotangles"] );	
		}	
	}	
}

KickBotsFriendly()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] == self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot"))
			{
				kick ( level.players[i] getEntityNumber() );
			}
		}
		wait 0.01;
	}
	self iprintln("^2Friendly ^7Bots have been kicked");
}

KickBotsEnemy()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] != self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot"))
			{
				kick ( level.players[i] getEntityNumber() );
			}
			wait 0.01;
		}
	}
	self iprintln("^1Enemy ^7Bots have been kicked");
}

TeleportBotFriendly()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] == self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot" ))
			{
				level.players[i] setOrigin(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"]);
				level.players[i] setplayerangles(vectortoangles(self gettagorigin("j_head") - level.players[i]gettagorigin("j_head")));
				wait 0.01;
				level.players[i].pers["friendlybotorigin"] = level.players[i].origin;
				level.players[i].pers["friendlybotangles"] = level.players[i].angles;
				level.players[i].pers["friendlybotspotstatus"] = "saved";
			}
		}
	}
}

TeleportBotEnemy()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] != self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot" ))
			{
				level.players[i] setOrigin(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"]);
				level.players[i] setplayerangles(vectortoangles(self gettagorigin("j_head") - level.players[i]gettagorigin("j_head")));
				wait 0.01;
				level.players[i].pers["enemybotorigin"] = level.players[i].origin;
				level.players[i].pers["enemybotangles"] = level.players[i].angles;
				level.players[i].pers["enemybotspotstatus"] = "saved";
			}
		}
	}
}

ToggleBotSpawnFriendly()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] == self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot"))
			{
				level.players[i].pers["friendlybotorigin"] = self.origin;
				level.players[i].pers["friendlybotangles"] = self.angles;
				level.players[i].pers["friendlybotspotstatus"] = "saved";
			}
		}
	}
	//self iPrintln("^2Friendly ^7Bot's Position: ^2[Saved]");
	self thread loadBotSpawnFriendly();
}

loadBotSpawnFriendly()
{
	for(i = 0; i < level.players.size; i++)
	{
		if (isSubStr( level.players[i].guid, "bot"))
		{
			if (level.players[i].pers["friendlybotspotstatus"] == "saved") 
			{
				level.players[i] setOrigin( level.players[i].pers["friendlybotorigin"] );
				level.players[i] setPlayerAngles( level.players[i].pers["friendlybotangles"] );
			}
		}
	}
}

ToggleBotSpawnEnemy()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] != self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot"))
			{
				level.players[i].pers["enemybotorigin"] = self.origin;
				level.players[i].pers["enemybotangles"] = self.angles;
				level.players[i].pers["enemybotspotstatus"] = "saved";
			
			}
		}
	}
	//self iPrintln("^1Enemy^7 Bot's Position: ^2[Saved]");
	self thread loadBotSpawnEnemy();
}

loadBotSpawnEnemy()
{
	for(i = 0; i < level.players.size; i++)
	{
		if (isSubStr( level.players[i].guid, "bot"))
		{
			if (level.players[i].pers["enemybotspotstatus"] == "saved") 
			{
				level.players[i] setOrigin( level.players[i].pers["enemybotorigin"] );
				level.players[i] setPlayerAngles( level.players[i].pers["enemybotangles"] );
			}
		}
	}
}
		
ToggleTSPerks()
{
	if(self.tsperk == 1)
	{
		self.tsperk = 0;
		self maps\mp\_utility::_unsetperk("specialty_longersprint");
		self maps\mp\_utility::_unsetperk("specialty_fastsprintrecovery");
		self maps\mp\_utility::_unsetperk("specialty_falldamage");
		self iPrintln("^5Commando ^7& ^5Marathon ^7Perks: ^1[Removed]");
		
	}
	else if(self.tsperk == 0)
	{
		self.tsperk = 1;
		self maps\mp\_utility::giveperk("specialty_longersprint");
		self maps\mp\_utility::giveperk("specialty_fastsprintrecovery");
		self maps\mp\_utility::giveperk("specialty_falldamage");
		self iPrintln("^5Commando ^7& ^5Marathon ^7Perks: ^2[Given]");
	}
}

ToggleBotFreeze(team)
{
	name = undefined;
	if (team == "allies")
		name = "^2Friendly^7 ";
	else if (team == "axis")
		name = "^1Enemy^7 ";
	
	if(self.botfreeze == 1)
	{
		self.botfreeze = 0;
		self thread FreezeBot(team, "Unfreeze");
		self iPrintln(name + "^1Bots: ^2[Unfrozen]");
	}
	else if(self.botfreeze == 0)
	{
		self.botfreeze = 1;
		self thread FreezeBot(team, "Freeze");
		self iPrintln(name + "^1Bots: ^1[Frozen]");
	}
}

FreezeBot(botteam, freeze)
{
	for(i = 0; i < level.players.size; i++)
	{
		if (isSubStr( level.players[i].guid, "bot"))
		{
			if(botteam == "allies")
			{
				if(level.players[i].pers["team"] == self.pers["team"])
				{
					if (isSubStr( level.players[i].guid, "bot"))
					{
						if (freeze == "Freeze")
						{
							level.players[i] freezeControls(true);
							level.players[i].pers["freeze"] = true;
						}
						else if (freeze == "Unfreeze")
						{
							level.players[i] freezeControls(false);
							level.players[i].pers["freeze"] = false;
						}
					}
				}
			}
			else if(botteam == "axis")
			{
				if(level.players[i].pers["team"] != self.pers["team"])
				{
					if (freeze == "Freeze")
					{
						level.players[i] freezeControls(true);
						level.players[i].pers["freeze"] = true;
					}
					else if (freeze == "Unfreeze")
					{
						level.players[i] freezeControls(false);
						level.players[i].pers["freeze"] = false;
					}
				}
			}
		}
		wait 0.01;
	}
}

ToggleSpawnBinds()
{
	if(self.SpawnBinds == 1)
	{
		self.SpawnBinds = 0;
		self notify("endbinds");
		self iPrintln("UFO & Teleport Binds: ^1[Off]");
		
	}
	else if(self.SpawnBinds == 0)
	{
		self.SpawnBinds = 1;
		self thread doBinds();
		self iPrintln("UFO & Teleport Binds: ^2[On]");
	}
}

ToggleEbSelector()
{
	self endon ("disconnect");
	wait 0.05;
	if (self.selecteb == "0")
	{
		self.ebweap = self getCurrentWeapon();
		self.selecteb = "1";
		self iprintln("Explosive Bullets works only for: ^2"  + self.ebweap);
		self.ebonlyfor = self.ebweap;
	}
	else if (self.selecteb == "1")
	{
		if(self getcurrentweapon() != self.ebweap)
		{
			self.ebweap = self getCurrentWeapon();
			self iprintln("Explosive Bullets works only for: ^2"  + self.ebweap);
			self.ebonlyfor = self.ebweap;
		}
		else
		{
			self.selecteb = "0";
			self iPrintln("Explosive Bullets works only for ^1Snipers");
			self.ebonlyfor = "Snipers";
		}
	}
}

AimbotStrength()
{
	if(self.AimbotRange == "^1Off")
	{
		self notify("NewRange");
		self.claymoreeb = undefined;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,200);
		self.AimbotRange = "^2Normal";
	}
	else if(self.AimbotRange == "^2Normal")
	{
		self notify("NewRange");
		self.claymoreeb = undefined;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,550);
		self.AimbotRange = "^2Strong";
	}
	else if(self.AimbotRange == "^2Strong")
	{
		self notify("NewRange");
		self.claymoreeb = undefined;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,999999999);
		self.AimbotRange = "^2Everywhere";
	}
	else if(self.AimbotRange == "^2Everywhere")
	{
		self notify("NewRange");
		self.claymoreeb = true;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,550);
		self.aimbotRange = "Claymore Only ^2Strong";
	}
	else if(self.AimbotRange == "Claymore Only ^2Strong")
	{
		self notify("NewRange");
		self.claymoreeb = true;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,999999999);
		//self.aimbotRange = "Claymore Only ^2Everywhere";
		self.aimbotRange = "Claymore Only ^2Everywhere";
	}
	/*
	else if(self.AimbotRange == "Claymore Only ^2Everywhere")
	{
		self notify("NewRange");
		self.claymoreeb = undefined;
		self.c4eb = true;
		self thread Aimbot(2147483600,550);
		self.aimbotRange = "C4 Only ^2Strong";
	}
	else if(self.AimbotRange == "C4 Only ^2Strong")
	{
		self notify("NewRange");
		self.claymoreeb = undefined;
		self.c4eb = true;
		self thread Aimbot(2147483600,999999999);
		self.aimbotRange = "C4 Only ^2Everywhere";
	}
	else if(self.AimbotRange == "C4 Only ^2Everywhere")
	*/
	else if(self.AimbotRange == "Claymore Only ^2Everywhere")
	{
		self notify("StopAimbot");
		self.claymoreeb = undefined;
		self.c4eb = undefined;
		self.aimbotRange = "^1Off";
	}
    self iPrintln("Explosive Bullets: ^0" + self.aimbotRange + "^7");
}

Aimbot(damage,range) //helios port
{
	self endon("disconnect");
	self endon("game_ended");
	self endon("NewRange");
	self endon("StopAimbot");
	for(;;)
	{
		aimAt = undefined;
		claymore = undefined;
		claymoreTarget = undefined;
		c4 = undefined;
		c4Target = undefined;
		self waittill ("weapon_fired");
		
		weaponClass = self getCurrentWeapon();
		forward = self getTagOrigin("tag_eye");
		end = vector_scale(anglestoforward(self getPlayerAngles()), 1000000);
		ExpLocation = BulletTrace( forward, end, false, self )["position"];
		
		foreach(player in level.players)
		{
			if (isDefined(player.claymorearray)) 
			{
				foreach(claymore in player.claymorearray) 
				{
					claymoreTarget = undefined;
					if (distance(claymore.origin, ExpLocation) <= range)
					{
						claymoreTarget = claymore;
					}
				}
			}
			/*
			if (isDefined(player.c4array)) 
			{
				foreach(c4 in player.c4array)
				{
					c4Target = undefined;
					if (distance(c4.origin, ExpLocation) <= range) 
					{
						c4Target = c4;
					}
				}
			}
			*/
			if((player == self) || (!isAlive(player)) || (level.teamBased && self.pers["team"] == player.pers["team"]))
				continue;
			if(isDefined(aimAt))
			{
				if(closer(ExpLocation, player getTagOrigin("tag_eye"), aimAt getTagOrigin("tag_eye")))
				aimAt = player;
			}
			else aimAt = player; 
		}
		
		doMod = "MOD_RIFLE_BULLET";
		doLoc = "torso_upper";
		doDesti = aimAt.origin + (0,0,40);
		
		if(self.selecteb == "0")
		{
			if ( isSubStr(self getCurrentWeapon(), "h2_cheytac") 
			|| isSubStr(self getCurrentWeapon(), "h2_barrett")
			|| isSubStr(self getCurrentWeapon(), "h2_wa2000")
			|| isSubStr(self getCurrentWeapon(), "h2_m21")
			|| isSubStr(self getCurrentWeapon(), "h2_m40a3"))
			{
				if (self.Crosshairs == 1)
				{
					if(isDefined(self.c4eb))
					{
						/*
						if (isDefined(c4Target.trigger)) 
							c4Target.trigger delete();
							c4Target detonate();
							*/
					}
					else if(isDefined(self.claymoreeb))
					{
						if (isDefined(claymoreTarget.trigger)) 
							claymoreTarget.trigger delete();
							claymoreTarget detonate();
					}
					else
					{
						if(distance( aimAt.origin, ExpLocation ) <= range)
						{	
							aimAt thread [[level.callbackPlayerDamage]]( self, self, 192020292, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
						}
					}
				}
				else
				{
					if(isDefined(self.c4eb))
					{
						/*
						if (isDefined(c4Target.trigger)) 
							c4Target.trigger delete();
							c4Target detonate();
							*/
					}
					else if(isDefined(self.claymoreeb))
					{
						if (isDefined(claymoreTarget.trigger)) 
							claymoreTarget.trigger delete();
							claymoreTarget detonate();
					}
					else
					{
						if(distance( aimAt.origin, ExpLocation ) <= range)
						{	
							aimAt thread [[level.callbackPlayerDamage]]( self, self, 192020292, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
						}
					}
				}
			}
		}
		else
		{
			if(weaponClass == self.ebweap)
			{
				if (self.Crosshairs == 1)
				{
					if(isDefined(self.c4eb))
					{
						/*
						if (isDefined(c4Target.trigger)) 
							c4Target.trigger delete();
							c4Target detonate();
							*/
					}
					else if(isDefined(self.claymoreeb))
					{
						if (isDefined(claymoreTarget.trigger)) 
							claymoreTarget.trigger delete();
							claymoreTarget detonate();
					}
					else
					{
						if(distance( aimAt.origin, ExpLocation ) <= range)
						{	
							aimAt thread [[level.callbackPlayerDamage]]( self, self, 192020292, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
						}
					}
				}
				else
				{
					if(isDefined(self.c4eb))
					{
						/*
						if (isDefined(c4Target.trigger)) 
							c4Target.trigger delete();
							c4Target detonate();
							*/
					}
					else if(isDefined(self.claymoreeb))
					{
						if (isDefined(claymoreTarget.trigger)) 
							claymoreTarget.trigger delete();
							claymoreTarget detonate();
					}
					else
					{
						if(distance( aimAt.origin, ExpLocation ) <= range)
						{	
							aimAt thread [[level.callbackPlayerDamage]]( self, self, 192020292, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
						}
					}
				}
			}
		}
		wait 0.05;
	}
}

autoProne()
{
	if(self.AutoProne == 0)
	{
		self.AutoProne = 1;
		self thread prone1();
		self iPrintln("Auto Prone: ^2[On]");
	}
	else if(self.AutoProne == 1)
	{
		self.AutoProne = 0;
		self notify("endprone");
		self iPrintln("Auto Prone: ^1[Off]");
	}
}

prone1()
{
    self endon("endprone");
    self endon("disconnect");
	level waittill("game_ended");
    self SetStance( "prone" );
    wait 0.5;
    self SetStance( "prone" );
    wait 0.5;
    self SetStance( "prone" );
    wait 0.5;
    self SetStance( "prone" );
    wait 0.5;
    self SetStance( "prone" );
    wait 0.5;
    self SetStance( "prone" );
    wait 0.5;
}

Softlands()
{
	if(self.SoftLandsS == 0)
	{
		self.SoftLandsS = 1;
		self iPrintln("Softlands: ^2[On]");
		setDvar( "jump_enableFallDamage", "0");
	}
	else if(self.SoftLandsS == 1)
	{
		self.SoftLandsS = 0;
		self iPrintln("Softlands: ^1[Off]");
		setDvar( "jump_enableFallDamage", "1");
	}
}

dropcanswap()
{
	self giveweapon("h2_mp5k_mp_holo_camo034");
	self dropitem("h2_mp5k_mp_holo_camo034");
	wait 0.1;
}


randomcamo()
{
	camoRandom = "";
	switch(randomint(46))
    {
		case 0 : 
		camoRandom = "none";
		break;

		case 1 : 
		camoRandom = "camo016";
		break;

		case 2 : 
		camoRandom = "camo017";
		break;

		case 3 : 
		camoRandom = "camo018";
		break;

		case 4 : 
		camoRandom = "camo019";
		break;

		case 5 : 
		camoRandom = "camo020";
		break;

		case 6 : 
		camoRandom = "camo021";
		break;

		case 7 : 
		camoRandom = "camo022";
		break;

		case 8 : 
		camoRandom = "camo023";
		break;

		case 9 : 
		camoRandom = "camo024";
		break;

		case 10 : 
		camoRandom = "camo025";
		break;

		case 11 : 
		camoRandom = "camo026";
		break;

		case 12 : 
		camoRandom = "camo027";
		break;

		case 13 : 
		camoRandom = "camo028";
		break;

		case 14 : 
		camoRandom = "camo029";
		break;

		case 15 : 
		camoRandom = "camo030";
		break;

		case 16 : 
		camoRandom = "camo031";
		break;

		case 17 : 
		camoRandom = "camo032";
		break;

		case 18: 
		camoRandom = "camo033";
		break;

		case 19 : 
		camoRandom = "camo034";
		break;

		case 20 : 
		camoRandom = "camo035";
		break;

		case 21 : 
		camoRandom = "camo036";
		break;

		case 22 : 
		camoRandom = "camo037";
		break;

		case 23 : 
		camoRandom = "camo038";
		break;

		case 24 : 
		camoRandom = "camo039";
		break;

		case 25 : 
		camoRandom = "camo040";
		break;

		case 26 : 
		camoRandom = "camo041";
		break;

		case 27 : 
		camoRandom = "camo042";
		break;

		case 28 : 
		camoRandom = "camo043";
		break;

		case 29 : 
		camoRandom = "camo044";
		break;

		case 30 : 
		camoRandom = "camo045";
		break;

		case 31 : 
		camoRandom = "camo046";
		break;

		case 32 : 
		camoRandom = "camo047";
		break;

		case 33 : 
		camoRandom = "camo048";
		break;

		case 34 : 
		camoRandom = "camo049";
		break;

		case 35 : 
		camoRandom = "camo050";
		break;

		case 36 : 
		camoRandom = "camo051";
		break;

		case 37 : 
		camoRandom = "camo052";
		break;

		case 38 : 
		camoRandom = "camo053";
		break;

		case 39 : 
		camoRandom = "camo054";
		break;

		case 40 : 
		camoRandom = "toxicwaste";
		break;

		case 41 : 
		camoRandom = "camo056";
		break;

		case 42 : 
		camoRandom = "camo057";
		break;

		case 43 : 
		camoRandom = "camo058";
		break;

		case 44 : 
		camoRandom = "golddiamond";
		break;

		case 45 : 
		camoRandom = "gold";
        break;
    }
	return camoRandom;
}

givecamo()
{
	//
}

streak(s)
{
	self maps\mp\gametypes\_hardpoints::giveHardpoint(s, ""); // "ffs" -retro
	self iprintln("Killstreak Given: ^5" + s);
}

takeweap()
{
    self.weap = self getCurrentWeapon();
    self takeweapon(self.weap);
}

dropweap()
{
	currentgun = self getcurrentWeapon();
	self dropitem(currentgun);
}

EmptyDaClip()
{
    weap = self getCurrentWeapon();
    clip = self getWeaponAmmoClip(weap);
    self SetWeaponAmmoClip(weap, clip - 100);
}

OneBulletClip()
{
    weap = self getCurrentWeapon();
    self SetWeaponAmmoClip( weap, 1 );
}

givetest(weapon, camo)
{
	if(camo != "")
	{
		self giveWeapon(weapon);
		self switchToWeapon(weapon);
		self iprintln("Weapon Given: ^5" + weapon);
	}
	else
	{
		self giveWeapon(weapon + "_" + camo);
		self switchToWeapon(weapon + "_" + camo);
		self iprintln("Weapon Given: ^5" + weapon + "_" + camo);
	}
}

changeMap(mapName)
{ 	
	//
}	

PauseTimer()
{
	if(self.pausetimer == 0)
	{
		self.pausetimer = 1;
		self iPrintln("Timer Paused: ^2[On]");
		self maps\mp\gametypes\_gamelogic::pauseTimer();
	}
	else if(self.pausetimer == 1)
	{
		self.pausetimer = 0;
		self iPrintln("Timer Paused: ^1[Off]");
		self maps\mp\gametypes\_gamelogic::resumeTimer();
	}
}

pickupradius()
{
	if ( self.puradius == false )
	{
		self.puradius = true;
		setDvar( "player_useRadius", 9999 );
		self iPrintln("Pickup Radius: ^2[9999]");
	}
    else if ( self.puradius == true )
	{
		self.puradius = false;
		setDvar( "player_useRadius", 128 );
		self iPrintln("Pickup Radius: ^1[Default]");
	}
}

FastRestart()
{
	for(i = 0; i < level.players.size; i++)
	{
		if (isSubStr( level.players[i].guid, "bot"))
		{
			kick ( level.players[i] getEntityNumber() );
		}
	}
	wait 1;
	map_restart(false);
}

FastLast()
{
	if(getDvar("g_gametype") == "dm")
	{
		destroyHud();
		destroyMenuText();
		self.menu.isOpen = false;
		self notify("stopmenu_up");
		self notify("stopmenu_down");
		wait 0.05;
		self.score = 23;
		self.pers["score"] = 23;		
		self.kills = 23;
		self.pers["kills"] = 23;
		self freezeControls(true);
		self iPrintlnBold("^22 KILLS UNTIL LAST");
		wait 1;
		self freezeControls(false);
	}
	else if(getDvar("g_gametype") == "war")
	{
		destroyHud();
		destroyMenuText();
		self.menu.isOpen = false;
		self notify("stopmenu_up");
		self notify("stopmenu_down");
		wait 0.05;
		setTeamScore( self.team, 73 );
		self.kills = 73;
		self.score = 7300;
		game["teamScores"][self.team] = 73;
		self freezeControls(true);
		self iPrintlnBold("^22 KILLS UNTIL LAST");
		wait 1;
		self freezeControls(false);
	}
	else
	{
		self iPrintln("^1This gamemode is NOT supported for Fast Last");
	}
	wait 0.01;
}


EMPBind()
{
    self notify("endEMP");
    if(self.empbind == 0)
    {
        self.empbind = 1;
        self.empdpad = "up";
        self thread BotsEMP();
        self iPrintln("^1Bots:^7 EMP Bind [{+actionslot 1}]");
    }
    else if(self.empbind == 1)
    {
        self.empbind = 2;
        self.empdpad = "down";
        self thread BotsEMP();
        self iPrintln("^1Bots:^7 EMP Bind [{+actionslot 2}]");
    }
    else if(self.empbind == 2)
    {
        self.empbind = 3;
        self.empdpad = "left";
        self thread BotsEMP();
        self iPrintln("^1Bots:^7 EMP Bind [{+actionslot 3}]");
    }
    else if(self.empbind == 3)
    {
        self.empbind = 4;
        self.empdpad = "right";
        self thread BotsEMP();
        self iPrintln("^1Bots:^7 EMP Bind [{+actionslot 4}]");
    }
    else if(self.empbind == 4)
    {
        self.empbind = 0;
        self notify("endEMP");
        self iPrintln("^1Bots:^7 EMP Bind [^1OFF^7]");
    }
}

BotsEMP()
{
    self endon("endEMP");
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand(self.empdpad, "+actionslot " + self.empbind);
        self waittill(self.empdpad);
		foreach ( player in level.players )
		if(isSubStr(player.guid, "bot"))
		{
			player thread maps\mp\h2_killstreaks\_emp::h2_EMP_Use( 0, 0 );
		}
    }
}

BotsShootBind()
{
    self notify("endShoot");
    if(self.bshootbind == 0)
    {
        self.bshootbind = 1;
        self.bshootdpad = "up";
        self thread doBotsShoot();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Final Stand Bind [{+actionslot 1}]");
    }
    else if(self.bshootbind == 1)
    {
        self.bshootbind = 2;
        self.bshootdpad = "down";
        self thread doBotsShoot();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Final Stand Bind [{+actionslot 2}]");
    }
    else if(self.bshootbind == 2)
    {
        self.bshootbind = 3;
        self.bshootdpad = "left";
        self thread doBotsShoot();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Final Stand Bind [{+actionslot 3}]");
    }
    else if(self.bshootbind == 3)
    {
        self.bshootbind = 4;
        self.bshootdpad = "right";
        self thread doBotsShoot();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Final Stand Bind [{+actionslot 4}]");
    }
    else if(self.bshootbind == 4)
    {
        self.bshootbind = 0;
        self notify("endShoot");
		level notify("endShoot_");
        self iPrintln("^1Bots:^7 Final Stand Bind [^1OFF^7]");
    }
}

doBotsShoot()
{
    self endon("endShoot");
    self endon("disconnect");
	self notify("botsAim");
    for(;;)
    {
        self notifyOnPlayerCommand(self.bshootdpad, "+actionslot " + self.bshootbind);
        self waittill(self.bshootdpad);
		self givePerk( "specialty_laststandoffhand", false );
		self givePerk( "specialty_pistoldeath", false );
		self freezeControls(false);
		wait 0.01;
		for(i = 0; i < level.players.size; i++)
		{
			if(level.players[i].pers["team"] != self.pers["team"])
			{
				if (isSubStr( level.players[i].guid, "bot"))
				{
					level.players[i] thread botsAim();
					MagicBullet(level.players[i] GetCurrentWeapon(), level.players[i] getTagOrigin("j_head"), self getTagOrigin("j_hip_le"), level.players[i]);
					//self thread [[level.callbackPlayerDamage]](level.players[i], level.players[i], 000000001, 0, "MOD_RIFLE_BULLET", level.players[i] getCurrentWeapon(), (0,0,0), (0,0,0), "j_hip_le", 0);
				}
			}
		}
    }
	self freezeControls(false);
}

tknifeLunge()
{
	if(!self.pers["knifeLunge"])
	{
		self.pers["knifeLunge"] = 1;
		self iprintln("Always Knife Lunge: ^2On");
		self thread knifeLunge();
	}
	else
	{
		self.pers["knifeLunge"] = 0;
		self iprintln("Always Knife Lunge: ^1Off");
		self notify("knifeLunge0");
	}
}

lookAtBot()
{
	self endon("lookend");
	foreach(player in level.players) 
	if(isDefined(player.pers["isBot"])&& player.pers["isBot"]) self.look = player.origin;
	self setPlayerAngles(vectorToAngles(((self.look)) - (self getTagOrigin("j_head"))));
}

knifeLunge()
{
	self endon("disconnect");
	self endon("knifeLunge0");
	if(!self.knifelunge)
	{
		self.knifelunge = true;
		self.midairlunge = true;
		self.clip = true;
		self notifyOnPlayerCommand("lunge", "+melee_zoom");
		for(;;)
		{
			self waittill("lunge");
			if(!self.midairlunge && !(self isOnGround()))
				continue;
			self thread lookAtBot();
			if(isDefined(self.lunge))
				self.lunge delete();
			self.lunge = spawn("script_origin" , self.origin);
			self.lunge setModel("tag_origin");
			self.lunge.origin = self.origin;
			self playerLinkTo(self.lunge, "tag_origin", 0, 180, 180, 180, 180, self.clip);
        	vec = anglesToForward(self getPlayerAngles());
			//lunge = (vec[0] * 999 vec[1] * 999, 400);
			lunge = (vec[0] * 255, vec[1] * 255, 0);
            self.lunge.origin = self.lunge.origin + lunge;
            wait 0.1803;
            self unlink();
       	}
    }
    else
	{
    	self.knifelunge = false;
    	self notify("lungeend");
    }
}

doBotsAim()
{
    self endon("endShoot");
	level endon("endShoot_");
    self endon("disconnect");
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] != self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot"))
			{
				level.players[i] thread botsAim();
			}
		}
	}
}

botsAim()
{
	self endon("disconnect");
	self endon("endShoot");
	level endon("endShoot_");
	for(;;) 
	{
		wait 0.01;
		aimAt = undefined;
		foreach(player in level.players)
		{
			if((player == self) || (level.teamBased && self.pers["team"] == player.pers["team"]) || (!isAlive(player)))
				continue;
			if(isDefined(aimAt))
			{
				if(closer(self getTagOrigin("j_hip_le"), player getTagOrigin("j_hip_le"), aimAt getTagOrigin("j_hip_le")))
						aimAt = player;
				}
				else
					aimAt = player;
		}
		if(isDefined(aimAt))
		{
			self setplayerangles(VectorToAngles((aimAt getTagOrigin("j_hip_le")) - (self getTagOrigin("j_hip_le"))));
		}
	}
}

Spawn_Bot(team) //ref: maps/mp/bots/_bots.gsc
{
    level thread _spawn_bot(1 , team, undefined, undefined, "spawned_player", "Recruit");
}

_spawn_bot(count, team, callback, stopWhenFull, notifyWhenDone, difficulty)
{
    name = RandomBotName();
	
    time = gettime() + 10000;
    connectingArray = [];
    squad_index = connectingArray.size;
    while(level.players.size < maps\mp\bots\_bots_util::bot_get_client_limit() && connectingArray.size < count && gettime() < time)
    {
        maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpause(0.05);
        botent                 = addbot(name,team);
        connecting             = spawnstruct();
        connecting.bot         = botent;
        connecting.ready       = 0;
        connecting.abort       = 0;
        connecting.index       = squad_index;
        connecting.difficultyy = difficulty;
        connectingArray[connectingArray.size] = connecting;
        connecting.bot thread maps\mp\bots\_bots::spawn_bot_latent(team,callback,connecting);
        squad_index++;
    }

    connectedComplete = 0;
    time = gettime() + 60000;
    while(connectedComplete < connectingArray.size && gettime() < time)
    {
        connectedComplete = 0;
        foreach(connecting in connectingArray)
        {
            if(connecting.ready || connecting.abort)
                connectedComplete++;
        }
        wait 0.05;
    }

    if(isdefined(notifyWhenDone))
        self notify(notifyWhenDone);
}

//////////////////////////////////////////////////////// BOLT STUFF ////////////////////////////////////////////////////////
boltRetro()
{
    self endon("disconnect");
	self endon("dudestopbolt");
	if ( !isDefined( self.pers["poscountBolt"] ) )
	{
		self.pers["poscountBolt"] = 0;
	}
	if ( !isDefined( self.pers["boltTime"] ) )
	{
		self.pers["boltTime"] = 3;
	}
	self thread RetroBoltSave();
	self thread boltTextThread();
}

boltTextThread()
{
	self endon("dudestopbolt");
	while(1)
	{
		self iPrintln("^4Press [{+reload}] to +saveBolt, [{weapnext}] to +delBolt");
		self iPrintln("^4Press [{+actionslot 1}] to disable tool");
		wait 2.5;
	}
	wait 0.01;
}

RetroBoltSave()
{
	destroyHud();
	destroyMenuText();
	self.menu.isOpen = false;
	self notify("stopmenu_up");
	self notify("stopmenu_down");
	wait 1;
	self thread retroDelBolt();
	self thread retroSaveBolt();
	self thread retroDisableBolt();
}

retroSaveBolt()
{
	        self endon("dudestopbolt");
            self notifyOnPlayerCommand("retrowannaboltsave", "+usereload");
			for (;;)
			{
				self waittill("retrowannaboltsave");
				self thread boltSave();
			}
}

boltSave()
{
		self.pers["poscountBolt"] += 1;
		self.pers["originBolt"][self.pers["poscountBolt"]] = self GetOrigin();
		self.pers["anglesBolt"][self.pers["poscountBolt"]] = self GetPlayerAngles();
		if(self.pers["poscountBolt"] == 1) //saves first bolt location as spawn too
		{
			self.pers["loc"] = true;
			self.pers["savePos"] = self.origin;
			self.pers["saveAng"] = self.angles;
		}
		self iPrintLn("^0Position ^5#" + self.pers["poscountBolt"] + " saved : ^7" + self.origin );
}

boltDel()
{
	{
		if( self.pers["poscountBolt"] == 0 )
		{
			self IPrintLn("^1There's no bolt positions to delete");
		}
		else
		{
			self.pers["originBolt"][self.pers["poscountBolt"]] = undefined;
			self.pers["anglesBolt"][self.pers["poscountBolt"]] = undefined;
			self IPrintLn( "^0Position ^5#" + self.pers["poscountBolt"] + " ^1deleted" );
			self.pers["poscountBolt"] -= 1;
		}
	}
}

retroDelBolt()
{
			self endon("dudestopbolt");
			self notifyOnPlayerCommand("retrowannadelbolt", "weapnext");
			for (;;)
			{
			self waittill("retrowannadelbolt");
			self thread boltDel();
			}
}



retroDisableBolt()
{
			self endon("dudestopbolt");
			self notifyOnPlayerCommand("boltretro3", "+actionslot 1");
			for (;;)
			{
			self waittill("boltretro3");
			self iPrintln("^5Bolt Movement Tool: ^1[Disabled]");
			self notify ("dudestopbolt");
			wait 1;
			self thread fullydisablebolt();
			}
}

fullyDisableBolt()
{
	self notifyOnPlayerCommand("emptynessnothingretro", "+actionslot 1");
	for (;;)
	{
	self waittill("emptynessnothingretro");
	self notify ("dudestopbolt");
	}
}

startBoltUp()
{
    if(!self.sb1)
    {
        self.sb1 = true;
		self.boltdpad = 1;
		self.boltbind = "up";
        self thread bindNonLoop();
        self iPrintln("^5Press [{+actionslot 1}] to activate Bolt Movement");
    }
    else
    {
        self.sb1 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt Off");
    }
}

startBoltDown()
{
    if(!self.sb2)
    {
        self.sb2 = true;
		self.boltdpad = 2;
		self.boltbind = "down";
        self thread bindNonLoop();
        self iPrintln("^5Press [{+actionslot 2}] to activate Bolt Movement");
    }
    else
    {
        self.sb2 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt Off");
    }
}


startBoltLeft()
{
    if(!self.sb3)
    {
        self.sb3 = true;
		self.boltdpad = 3;
		self.boltbind = "left";
        self thread bindNonLoop();
        self iPrintln("^5Press [{+actionslot 3}] to activate Bolt Movement");
    }
    else
    {
        self.sb3 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt Off");
    }
}

startBoltRight()
{
    if(!self.sb4)
    {
        self.sb4 = true;
		self.boltdpad = 4;
		self.boltbind = "right";
        self thread bindNonLoop();
        self iPrintln("^5Press [{+actionslot 4}] to activate Bolt Movement");
    }
    else
    {
        self.sb4 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt Off");
    }
}

bindNonLoop()
{
    self endon("stopboltbind");
    for(;;)
    {
		self notifyOnPlayerCommand( self.boltbind, "+actionslot " + self.boltdpad );
		self waittill(self.boltbind);
		if(self.boltdpad != "")
		{
			self thread BoltStart();
		}
		wait 0.01;
	}
}

BoltStart()
{
	self notify ("stopboltbind");
    self endon("disconnect");
    self endon("detachBolt");

        if (self.pers["poscountBolt"] == 0)
        {
            self IPrintLn("^1There is no bolt point to travel to");
        }
        
        boltModel = spawn( "script_model", self.origin );
        boltModel SetModel( "tag_origin" );
        boltModel EnableLinkTo();
        self PlayerLinkTo(boltModel);
        self thread WatchJumping(boltModel);

        for (i=1 ; i < self.pers["poscountBolt"] + 1 ; i++)
        {
            boltModel MoveTo( self.pers["originBolt"][i],  self.pers["boltTime"] / self.pers["poscountBolt"], 0, 0 );
            wait ( self.pers["boltTime"] / self.pers["poscountBolt"] );
        }
        self Unlink();
        boltModel delete();
		self thread bindNonLoop();
		
}

WatchJumping(model)
{
    self endon("disconnect");
    self notifyOnplayerCommand( "detachBolt", "+gostand" );

    for(;;)
    {
        self waittill("detachBolt");
        self Unlink();
        model delete();
    }
}

changeBoltTime(time)
{
		//setDvar( "boltTime", time );
		//self setClientDvar(  "boltTime", time );
		//self.bolt_time = time;
		self.pers["boltTime"] = time;
		if(time == 1)
		{
			self iPrintln("^5Bolt Time Set to:^0 " + time + " second");
		}
		else
		{
			self iPrintln("^5Bolt Time Set to:^0 " + time + " seconds");
		}
}
//////////////////////////////////////////////////////// BOLT STUFF ////////////////////////////////////////////////////////

//////////////////////////////////////////////////////// VELO STUFF ////////////////////////////////////////////////////////
velocitybind1()
{
	if(!self.velobinder)
	{
		self.velobinder = true;
		self thread velocitybind11();
	}
	else
	{
		self.velobinder = false;
		self notify("stopvelobind");
		self iPrintln("Velocity Bind: ^1Off");
	}
}



velocitybind11()
{
	self endon("stopvelobind");
	self iPrintLn("Velocity Bind set to: [{+actionslot 1}]");
	self iPrintLn("Current Velocity Bind: " + self.pers["RetroVelocity"] + " ");
	for(;;)
	{
	self notifyOnPlayerCommand("RetroVelocityBind1", "+actionslot 1");
	self waittill ("RetroVelocityBind1");
	if(self.CurrentMenu == "Closed")
	{
		//no multiple points
	if(!isDefined (self.pers["velopoint1"]))
	{
	self.VelocityRetro = self.pers["RetroVelocity"];
	self setVelocity((self.VelocityRetro));
			if(self.windowshot == true)
			{
			self setStance("crouch");
			}
			else
			{
				
			}
	}
	//start multiple points
	if(isDefined (self.pers["velopoint1"]))
	{
		self thread VelocityPointTracker();
	}
	}
	}
}

velocitybind2()
{
	if(!self.velobinder)
	{
		self.velobinder = true;
		self thread velocitybind22();
	}
	else
	{
		self.velobinder = false;
		self notify("stopvelobind");
		self iPrintln("Velocity Bind: ^3Off");
	}
}



velocitybind22()
{
	self endon("stopvelobind");
	self iPrintLn("Velocity Bind set to: [{+actionslot 2}]");
	self iPrintLn("Current Velocity Bind: " + self.pers["RetroVelocity"] + " ");
	for(;;)
	{
	self notifyOnPlayerCommand("RetroVelocityBind2", "+actionslot 2");
	self waittill ("RetroVelocityBind2");
	if(self.CurrentMenu == "Closed")
	{
		//no multiple points
	if(!isDefined (self.pers["velopoint1"]))
	{
	self.VelocityRetro = self.pers["RetroVelocity"];
	self setVelocity((self.VelocityRetro));
			if(self.windowshot == true)
			{
			self setStance("crouch");
			}
			else
			{
				
			}
	}
	//start multiple points
	if(isDefined (self.pers["velopoint1"]))
	{
		self thread VelocityPointTracker();
	}
	}
	}
}

velocitybind3()
{
	if(!self.velobinder)
	{
		self.velobinder = true;
		self thread velocitybind33();
	}
	else
	{
		self.velobinder = false;
		self notify("stopvelobind");
		self iPrintln("Velocity Bind: ^3Off");
	}
}

velocitybind33()
{
	self endon("stopvelobind");
	self iPrintLn("Velocity Bind set to: [{+actionslot 3}]");
	self iPrintLn("Current Velocity Bind: " + self.pers["RetroVelocity"] + " ");
	for(;;)
	{
	self notifyOnPlayerCommand("RetroVelocityBind3", "+actionslot 3");
	self waittill ("RetroVelocityBind3");
	if(self.CurrentMenu == "Closed")
	{
		//no multiple points
	if(!isDefined (self.pers["velopoint1"]))
	{
	self.VelocityRetro = self.pers["RetroVelocity"];
	self setVelocity((self.VelocityRetro));
			if(self.windowshot == true)
			{
			self setStance("crouch");
			}
			else
			{
				
			}
	}
	//start multiple points
	if(isDefined (self.pers["velopoint1"]))
	{
		self thread VelocityPointTracker();
	}
	}
	}
}

velocitybind4()
{
	if(!self.velobinder)
	{
		self.velobinder = true;
		self thread velocitybind44();
	}
	else
	{
		self.velobinder = false;
		self notify("stopvelobind");
		self iPrintln("Velocity Bind: ^3Off");
	}
}

velocitybind44()
{
	self endon("stopvelobind");
	self iPrintLn("Velocity Bind set to: [{+actionslot 4}]");
	self iPrintLn("Current Velocity Bind: " + self.pers["RetroVelocity"] + " ");
	for(;;)
	{
		self notifyOnPlayerCommand("RetroVelocityBind4", "+actionslot 4");
		self waittill ("RetroVelocityBind4");
		if(self.CurrentMenu == "Closed")
		{
			//no multiple points
			if(!isDefined (self.pers["velopoint1"]))
			{
				self.VelocityRetro = self.pers["RetroVelocity"];
				self setVelocity((self.VelocityRetro));
				if(self.windowshot == true)
				{
					self setStance("crouch");
				}
			}
			//start multiple points
			if(isDefined (self.pers["velopoint1"]))
			{
				self thread VelocityPointTracker();
			}
		}
	}
}


VelocityPointTracker()
{
	if(isDefined (self.didvelocity == undefined))
	{
		if(!isDefined(self.pers["velopoint2"]))
		{
		self.didvelocity = undefined;
		}
		else
		{
		self.didvelocity = 1;
		}
		self setVelocity((self.pers["velopoint1"]));
		self setStance("stand");
		if(isDefined (self.pers["velo1crouch"]))
		{
			self setStance("crouch");
		}
	}
	else if(self.didvelocity == 1)
	{
		if(!isDefined(self.pers["velopoint3"]))
		{
		self.didvelocity = undefined;
		}
		else
		{
		self.didvelocity = 2;
		}
		self setVelocity((self.pers["velopoint2"]));
		self setStance("stand");
		if(isDefined (self.pers["velo2crouch"]))
		{
			self setStance("crouch");
		}
	}
	else if(self.didvelocity == 2)
	{
		if(!isDefined(self.pers["velopoint4"]))
		{
		self.didvelocity = undefined;
		}
		else
		{
		self.didvelocity = 3;
		}
		self setVelocity((self.pers["velopoint3"]));
		self setStance("stand");
		if(isDefined (self.pers["velo3crouch"]))
		{
			self setStance("crouch");
		}
	}
	else if(self.didvelocity == 3)
	{
		if(!isDefined(self.pers["velopoint4"]))
		{
		self.didvelocity = undefined;
		}
		else
		{
		self.didvelocity = 4;
		}
		self setVelocity((self.pers["velopoint4"]));
		self setStance("stand");
		if(isDefined (self.pers["velo4crouch"]))
		{
			self setStance("crouch");
		}
	}
	else if(self.didvelocity == 4)
	{
		if(isDefined(self.pers["velopoint5"]))
		{
			self.didvelocity = undefined;
			self setVelocity((self.pers["velopoint5"]));
			self setStance("stand");
			if(isDefined (self.pers["velo5crouch"]))
			{
				self setStance("crouch");
			}
		}
	}
}

printVeloPoints()
{	if(isDefined(self.pers["velopoint1"]))
	{
	self iPrintLn(" Point 1:" + self.pers["velopoint1"] + " ");
	}
	if(isDefined(self.pers["velopoint2"]))
	{
	self iPrintLn("Point 2 " + self.pers["velopoint2"] + " ");
	}
	if(isDefined(self.pers["velopoint3"]))
	{
	self iPrintLn("Point 3 " + self.pers["velopoint3"] + " ");
	}
	if(isDefined(self.pers["velopoint4"]))
	{
	self iPrintLn("Point 4 " + self.pers["velopoint4"] + " ");
	}
	if(isDefined(self.pers["velopoint5"]))
	{
	self iPrintLn("Point 5 " + self.pers["velopoint5"] + " ");
	}
}

oneVelocity() 
{
	for(;;)
	{
	self notifyOnPlayerCommand("oneVelocity", "+oneVelocity");
	self waittill ("oneVelocity");
	self setVelocity((self.pers["velopoint1"])); 
	}
}

twoVelocity()
{
	for(;;)
	{
	self notifyOnPlayerCommand("twoVelocity", "+twoVelocity");
	self waittill ("twoVelocity");
	self setVelocity((self.pers["velopoint2"])); 
	}
}

threeVelocity()
{
	for(;;)
	{
	self notifyOnPlayerCommand("threevelo", "+threevelocity");
	self waittill ("threevelo");
	self setVelocity((self.pers["velopoint3"])); 
	}
}

fourVelocity()
{
	for(;;)
	{
	self notifyOnPlayerCommand("fourvelo", "+fourvelocity");
	self waittill ("fourvelo");
	self setVelocity((self.pers["velopoint4"]));
	}
}

fiveVelocity()
{
	for(;;)
	{
	self notifyOnPlayerCommand("fiveVelo", "+fiveVelocity");
	self waittill ("fiveVelo");
	self setVelocity((self.pers["velopoint5"]));
	}
}

playRetroVelocity()
{
	self setVelocity((self.VelocityRetro));
}

settingSpeedVelo( retroSpeed )
{
	self.VelocityRetro = (self.VelocityRetro * retroSpeed);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

settingSpeedVelodivide( retroSpeed )
{
	self.VelocityRetro = (self.VelocityRetro / retroSpeed);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

velopresetvalue(value, window, text)
{
	self.windowshot = window;
	self.VelocityRetro = (value);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
	self iPrintln("^4Velocity Preset Value: ^2" + text);
}

//custom momentum
velospeed0()
{
self thread settingSpeedVelo( 1.05 );
}
velospeed1()
{
self thread settingSpeedVelo( 1.10 );
}
velospeed2()
{
self thread settingSpeedVelo( 1.15 );
}
velospeed3()
{
self thread settingSpeedVelo( 1.20 );
}
velospeed4()
{
self thread settingSpeedVelo( 1.25 );
}
velospeed5()
{
self thread settingSpeedVelo( 1.30 );
}
velospeed6()
{
self thread settingSpeedVelo( 1.35 );
}
velospeed7()
{
self thread settingSpeedVelo( 1.40 );
}
velospeed8()
{
self thread settingSpeedVelo( 1.50 );
}
velospeed9()
{
self thread settingSpeedVelo( 2.00 );
}

velodivide0()
{
self thread settingSpeedVelodivide( 1.05 );
}

velodivide1()
{
self thread settingSpeedVelodivide( 1.10 );
}
velodivide2()
{
self thread settingSpeedVelodivide( 1.15 );
}
velodivide3()
{
self thread settingSpeedVelodivide( 1.20 );
}
velodivide4()
{
self thread settingSpeedVelodivide( 1.25 );
}
velodivide5()
{
self thread settingSpeedVelodivide( 1.30 );
}
velodivide6()
{
self thread settingSpeedVelodivide( 1.35 );
}

cfgVelo() 
{
	for(;;)
	{
	self notifyOnPlayerCommand("Velocity123", "+velo");
	self waittill ("Velocity123");
	self.momentum1 = getDvarFloat("cg_hudproneY");
	self.momentum2 = getDvarFloat("ui_altscene");
	self.momentum3 = getDvarFloat("ui_browserfriendlyfire");
	waitframe();
	//self setVelocity(self.pers["newvelocity"]);
	self setVelocity(((self.momentum1),(self.momentum2),(self.momentum3)));
	//self setStance ("crouch");
	}
}

cfgTele() 
{
	for(;;)
	{
	self notifyOnPlayerCommand("cfgtele", "+tele");
	self waittill ("cfgtele");
	self.teleport1 = getDvarFloat("cg_hudproneY");
	self.teleport2 = getDvarFloat("ui_altscene");
	self.teleport3 = getDvarFloat("ui_browserfriendlyfire");
	waitframe();
	self setOrigin(((self.teleport1),(self.teleport2),(self.teleport3)));
	}
}

cfgAngles() 
{
	for(;;)
	{
	self notifyOnPlayerCommand("cfgangles", "+angles");
	self waittill ("cfgangles");
	self.angles1 = getDvarFloat("cg_hudproneY");
	self.angles2 = getDvarFloat("ui_altscene");
	waitframe();
	self setPlayerAngles(((self.angles1),(self.angles2), 0));
	}
}


NorthEdit(number)
{
	self.VelocityRetro = ((self.VelocityRetro[0] + number), self.VelocityRetro[1], self.VelocityRetro[2]);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

SouthEdit(number)
{
	self.VelocityRetro = ((self.VelocityRetro[0] - number), self.VelocityRetro[1], self.VelocityRetro[2]);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

WestEdit(number)
{
	self.VelocityRetro = (self.VelocityRetro[0], (self.VelocityRetro[1] + number), self.VelocityRetro[2]);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}


EastEdit(number)
{
	self.VelocityRetro = (self.VelocityRetro[0], (self.VelocityRetro[1] - number), self.VelocityRetro[2]);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

UpEdit(number)
{
	self.VelocityRetro = (self.VelocityRetro[0], self.VelocityRetro[1], (self.VelocityRetro[2] + number));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

DownEdit(number)
{
	self.VelocityRetro = (self.VelocityRetro[0], self.VelocityRetro[1], (self.VelocityRetro[2] - number));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

ResetNS()
{
	self.VelocityRetro = ( 0, self.VelocityRetro[1], self.VelocityRetro[2]);
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

ResetEW()
{
	self.VelocityRetro = (self.VelocityRetro[0], 0, self.VelocityRetro[2]);
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

ResetUD()
{
	self.VelocityRetro = (self.VelocityRetro[0], self.VelocityRetro[1], 0);
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

constantTracker()
{
	if(!self.tracktoggle)
	{
		self.tracktoggle = true;
		self thread constantTrack();
		self iPrintln("Constant Tracker: ^3On");
	}
	else
	{
		self.tracktoggle = false;
		self notify("stopTracking");
		self iPrintln("Constant Tracker: ^3Off");
	}
}

constantTrack()
{
	self endon ("stopTracking");
	for(;;)
	{
	self.sayvelocity =  self getVelocity();
	self iPrintLn ("Momentum Value: " + self.sayvelocity + " ");
	wait .3;
	}
}


setsomeVelo()
{
	self.VelocityRetro = self getVelocity();
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
	self iPrintLn ("Velocity Tracked: " + self.VelocityRetro + " ");
}

getVeloBind()
{
	self endon ("stopvelocity");
	self iprintLn ("^3 Press [{+actionslot 1}] to Set Momentum");
	
	for(;;) //Loop
	{
	self notifyOnPlayerCommand("velocity5", "+actionslot 1");
	self waittill ("velocity5");
	if(self.CurrentMenu == "Closed")
	{
		self.pers["newvelocity"] = self getVelocity();
		wait .1;
		self.sayvelocity = self.pers["newvelocity"];
		self iPrintLn ("Momentum: " + self.sayvelocity + " ");
	}
	}
	wait .1;
}

ResetVELOAxis()
{
	self.VelocityRetro = ((0,0,0));
	self.pers["RetroVelocity"] = self.VelocityRetro;
}
//////////////////////////////////////////////////////// VELO STUFF ////////////////////////////////////////////////////////