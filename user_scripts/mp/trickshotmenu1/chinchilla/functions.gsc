#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\chinchilla\joey;
#include scripts\mp\chinchilla\binds;

coreinit()
{
	self thread changeclassmf();
	self thread savebind();
	self thread loadbind();
	self thread goNoclip();
}

changeclassmf()
{  
    game["strings"]["change_class"] = "";
    self endon("disconnect");
	for(;;)
	{
		self waittill("luinotifyserver",noti,arg);
		if(noti == "class_select" && arg < 60)
		{
			self.class = "custom" + (arg + 1);
            self maps\mp\gametypes\_class::setclass(self.class);
			self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],self.class);
    		self maps\mp\gametypes\_class::applyloadout();
			self maps\mp\gametypes\_hardpoints::giveownedhardpointitem();
		}
		wait 0.05;
    }
}

savebind()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("dpad3");
		if(self getstance() == "crouch" && self.pers["ufobind"])
			self thread savepos();

		wait 0.1;
	}
}

loadbind()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("dpad1");
		if(self getstance() == "crouch")
			self thread loadpos();
		
		wait 0.1;
	}
}

savepos()
{
	self.pers["savepos"] = self.origin;
	self.pers["saveang"] = self.angles;
	self iPrintLn("Origin ^1"+self.origin);
	self iPrintLn("Angles ^1"+self.angles);
	self iPrintLn("Weapon ^1"+self getCurrentWeapon());
}

loadpos()
{
	self setOrigin(self.pers["savepos"]);
	self setPlayerAngles(self.pers["saveang"]);
}


savebotdefault()
{
	self iPrintLn("Bot Spawn ^1Saved");
	cross = self getcrosshair();
	newcross = strTok(cross,",");
	setdvar("botdefault",GetSubStr(newcross[0], 1)+newcross[1]+GetSubStr(newcross[2], 0,newcross[2].size-1)+" "+getDvar("mapname"));
	wait 0.1;
	foreach(player in level.players)
	{
		if(isSubStr(player.guid, "bot"))
			player botload();
	}
}

savebotspawn(player)
{
	cross = self getcrosshair();
	player setOrigin(cross);
	player setPlayerAngles(self.angles + (0,180,0));
	player.pers["savePos"] = player.origin;
	player.pers["saveAng"] = self.angles + (0,180,0);
}

botload()
{
	if(isDefined(self.pers["savePos"]))
	{
		self setOrigin(self.pers["savePos"]);
		self setPlayerAngles(self.pers["saveAng"]);
		return;
	}
	botcoords = strTok(getDvar("botdefault")," ");
	if(getDvar("botdefault") != "none" && botcoords[3] == getDvar("mapname"))
		self setOrigin((Float(botcoords[0]),Float(botcoords[1]),Float(botcoords[2])));
}

resetdarounds()
{
	level.resetscores = true;
	game["roundsWon"]["axis"] = 0;
	game["roundsWon"]["allies"] = 0;
	game["roundsPlayed"] = 0;
	game["teamScores"]["allies"] = 0;
	game["teamScores"]["axis"] = 0;
	self iPrintLn("Rounds ^1Reset");
}

refillAmmo()
{
	gun = self getCurrentWeapon();
	clip = self getweaponammoclip(gun);
	if(gun != "none")
	{
		self givestartammo( gun );
		self setweaponammoclip( gun, clip );
	}
	wait 0.05;
}

fastRestart()
{
	self iPrintLn("^1Restarting Game...");
	wait 1;
	thread kickAllBots();
	wait 1;
	map_restart(false);
}

kickAllBots()
{
	foreach(player in level.players)
	{
		if(isSubStr(player getguid(), "bot")) 
			kick(player getEntityNumber());
	}
}

addmfbot(team)
{
    level thread spawn_bots_stub(1 , team, undefined, undefined, "spawned_player", "Regular");
}

spawn_bots_stub(count, team, callback, stopWhenFull, notifyWhenDone, difficulty)
{
    name = level.botnames[level.botcount];
    if(level.botcount == (level.botnames.size - 1))
        level.botcount = 0;
    else
        level.botcount++;
    
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
    time = gettime() + -5536;
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

goNoclip()
{
	if(!isDefined(self.pers["ufobind"]))
		self.pers["ufobind"] = true;

	self endon("disconnect");
	for(;;)
	{
		self waittill("knife");
		if(self.menuopen || self GetStance() != "crouch")
			continue;

		if(!self.pers["ufobind"])
		{
			self thread refillammo();
			continue;
		}
		if(self.ufomode == 0) 
		{
			self thread penis();
			self.ufomode = 1; 
			wait .05;
			self disableweapons();
		} 
		else 
		{ 
			self.ufomode = 0; 
			self notify("NoclipOff");
			self unlink();
			self enableweapons();
			self thread refillammo();
		}
	}
}

penis()
{ 
	self endon("death"); 
	self endon("NoclipOff");
	if(isdefined(self.newufo)) self.newufo delete(); 
	self.newufo = spawn("script_origin", self.origin); 
	self.newufo.origin = self.origin; 
	self playerlinkto(self.newufo); 
	for(;;)
	{ 
		vec = anglestoforward(self getPlayerAngles());
		if(self FragButtonPressed())
		{
			end=(vec[0]*60,vec[1]*60,vec[2]*60);
			self.newufo.origin=self.newufo.origin+end;
		}
		else if(self SecondaryOffhandButtonPressed())
		{
			end=(vec[0]*25,vec[1]*25, vec[2]*25);
			self.newufo.origin=self.newufo.origin+end;
		} 
		wait 0.05; 
	} 
}


giveWeapon_wrapper(weapon)
{
	weapon = "h2_"+weapon;
	self giveWeapon(weapon);
	self switchToWeapon(weapon);
	if(self getCurrentWeapon() == weapon)
	{
		self dropItem(self getCurrentWeapon());
		return;
	}
}

killPlayer(player)
{
	player suicide();
}

takeDaGun()
{
	self takeWeapon(self getCurrentWeapon());
}

dropDaGun()
{
	self dropItem(self getCurrentWeapon());
}

kickPlayer(player)
{
	kick(player getEntityNumber());
	wait 0.2;
	self thread newMenu("Clients");
}

gravCycle()
{
	if(getDvarInt("g_gravity") == 900)
		setDvar("g_gravity",500);
	else
	{
		gv = (getDvarInt("g_gravity") + 10);
		setDvar("g_gravity", gv);
	}
	self.pers["gravity"] = getDvarInt("G_gravity");
	self.menutext[self.scroll] setSafeText("Gravity ^1" + getDvarInt("g_gravity"));
}

giveStreak(s)
{
	self maps\mp\gametypes\_hardpoints::givehardpoint(s,0);
}

AutoLast()
{
	if(getDvar("g_gametype") == "dm")
	{
		self.score = 139;
		self.pers["score"] = 139;		
		self.kills = 139;
		self.pers["kills"] = 139;
	}
	else if(getDvar("g_gametype") == "war")
	{
		setTeamScore( self.team, 74 );
		self.kills = 74;
		self.score = 74;
		game["teamScores"][self.team] = 74;
	}
	wait 0.5;
}

SetDvarIfNotInizialized(dvar, value)
{
	if (!IsInizialized(dvar))
		setDvar(dvar, value);
}

IsInizialized(dvar)
{
	result = getDvar(dvar);
	return result != "";
}

slomoTog()
{
	if(getDvarFloat("timescale") == 0.5)
		setDvar("timescale", 1);
	else
		setDvar("timescale", 0.5);

	self.pers["tscale"] = getDvarFloat("timescale");	
	self.menutext[self.scroll] setSafeText("Timescale ^1"+getDvar("timescale"));
}