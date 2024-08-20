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
#include maps\mp\gametypes\_gamelogic;

#include scripts\mp\_retropack_utility;
#include scripts\mp\_retropack_functions;

init()
{
	self endon("disconnect");
    self.menu = spawnStruct();
    self.hud = spawnStruct();
    self.menu.isOpen = false;

	if ( getDvar( "bots_manage_fill" ) == "" )
		setDvar( "bots_manage_fill", 1 );
	
	if ( getDvar( "bots_manage_add" ) == "" )
		setDvar( "bots_manage_add", 1 );
	level thread addBots_();
	
	level.menuName = "Retro Package"; //spawn in text menu name	
	level.menuHeader = "RETRO PACK"; //in-game menu header	
	level.menuSubHeader = "^5MWR: H2M"; //in-game menu subheader	
	level.menuVersion = "0.9.1"; //menu version	
	level.developer = "@rtros";
	level thread onplayerconnect();
	level thread monitorRounds();
	level.prematch_done_time = 0;
	replaceFunc(maps\mp\_events::firstbloodevent, ::firstbloodevent_); //remove first blood
	replaceFunc(maps\mp\gametypes\_teams::getteamshortname, ::getteamshortname_); //custom team names
}

onplayerconnect()
{
    for(;;)
    {
        level waittill("connected", player);
		
        player thread onplayerspawned();
        player thread initmenu();
        player thread watchDeath();
		player thread doBinds();
        player.spawnText = true;
		self.ebonlyfor = "Snipers";
    }
}

onplayerspawned()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
		if (isSubStr( self.guid, "bot" ))
		{
			self thread loadBotSpawn();
			self maps\mp\_utility::giveperk("specialty_falldamage");
			if(getDvar("g_gametype") == "sd")
			{
				maps\mp\_utility::gameflagwait( "prematch_done" );
				wait 0.01;
				self freezeControls(true);
			}
			if(self.pers["freeze"] == true)
				self freezeControls(true);
			else
				self freezeControls(false);			
		}
		else
		{
			self freezeControls(false);
			if (self.pers["loc"] == true) 
			{
				self setOrigin( self.pers["savePos"] );
				self setPlayerAngles( self.pers["saveAng"] );
			}
			wait 0.02;
			self iprintln("^5" + level.menuName + " " + level.menuVersion);
			self iprintln("^5To open menu press [{+speed_throw}] + [{+Actionslot 1}]");
			if(self.tsperk == undefined || self.tsperk == 1)
			{
				self maps\mp\_utility::giveperk("specialty_longersprint");
				self maps\mp\_utility::giveperk("specialty_fastsprintrecovery");
				self maps\mp\_utility::giveperk("specialty_falldamage");
			}
			self thread doClassChange();
			if(self ishost())
			{
				//add host only stuff here
			}
			self thread monitorGrenade();
			self thread doAmmo();
			self thread doRandomTimerPause();
		}
		setDvar( "timescale", 1.0 );
    }
}

firstbloodevent_()
{}

addBots_()
{
	level endon( "game_ended" );
	self endon("disconnect");
	self endon("death");
	for ( ;; )
	{
		wait 0.5;
		addBots_loop_();
	}
}

addBots_loop_()
{
	botsToAdd = GetDvarInt( "bots_manage_add" );
	if ( botsToAdd > 0 )
	{
		SetDvar( "bots_manage_add", 0 );

		if ( botsToAdd > 64 )
			botsToAdd = 64;

		for ( ; botsToAdd > 0; botsToAdd-- )
		{
			level Spawn_Bot("axis");
			wait 0.25;
		}
	}
	
	fillAmount = getDvarInt( "bots_manage_fill" );
	players = 0;
	bots = 0;
	spec = 0;
	playercount = level.players.size;
	
	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[i];

		if ( player is_bot_() || player.bot == "botent")
			bots++;
		else if ( !isDefined( player.pers["team"] ) || ( player.pers["team"] != "axis" && player.pers["team"] != "allies" ) )
			spec++;
		else
			players++;
	}
	amount = bots;
	if ( amount < fillAmount )
		setDvar( "bots_manage_add", 1 );
}


is_bot_()
{
	assert( isDefined( self ) );
	assert( isPlayer( self ) );

	return ( ( isDefined( self.pers["isBotDumb"] ) && self.pers["isBotDumb"] ) || ( isDefined( self.pers["isBot"] ) && self.pers["isBot"] ) || ( isDefined( self.pers["isBotWarfare"] ) && self.pers["isBotWarfare"] ) || isSubStr( self getguid() + "", "bot" ) );
}


getteamshortname_( team )
{
	if (team == "axis" && game["state"] == "playing")
		return "Bots";
	if (team == "allies" && game["state"] == "playing")
		return "^5Players";
}

monitorGrenade() 
{
	self endon( "disconnect" );
	for(;;) 
	{
		self waittill( "grenade_fire", grenade, weaponName );
		wait 2;
		if ( weaponName == "h1_fraggrenade_mp" )
		{
			wait 4;
			self giveMaxAmmo( weaponName );
		}
		else if ( weaponName == "iw9_throwknife_mp" )
		{
			wait 2;
			self giveMaxAmmo( weaponName );
		}
		else
		{
			self giveMaxAmmo( weaponName );
		}
		wait 0.25;
	}
}

doRandomTimerPause()
{
	Time = randomInt(6);
    if (Time == 0) 
    {
		wait 110.65;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
    }
    else if (Time == 1) 
    {
		wait 150.15;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
    }
    else if (Time == 2) 
    {
		wait 99.52;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
    }
    else if (Time == 3) 
    {
		wait 80.54;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
    }
    else if (Time == 4) 
    {
		wait 130.32;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
	}
	else if (Time == 5) 
    {
		wait 107.23;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
    } 
	else if (Time == 6) 
	{
		wait 128.32;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
    }
}

initmenu()
{
	self endon("disconnect");
	if (!isSubStr( self.guid, "bot" ))
	{
		level.result = 1;
		self.MainX = -100;
		self.MainY = -110;
		self.MenuMaxSize = 7;
		self.MenuMaxSizeHalf = 3;
		self.MenuMaxSizeHalfOne = 4;
		
		self.menu = spawnStruct();
		self.hud = spawnStruct();
		self.menu.isOpen = false;
		self thread buttons();
	}
}

loadMenu(menu)
{
    self.menu.savedPos[self.menu.current] = self.scroller;
    destroyMenuText();
    self.menu.current = menu;

    if(isDefined(self.menu.savedPos[menu]))
        self.scroller = self.menu.savedPos[menu];
    else
        self.scroller = 0;

    buildMenuText();
    updatescroll();
}

buildMenuText()
{

	for(i=0;i<self.MenuMaxSize;i++)
    {
        self.hud.text[i] = createTextElem("default", .65, "LEFT", "CENTER", -55, -110 + (10 * i), 3, (1, 1, 1), 1, (0, 0, 0), 0, self.menu.text[self.menu.current][i]);
        self.hud.text[i].foreground = true;
    }
}

destroyMenuText()
{
    if(isDefined(self.hud.text))
    {
        for(i=0;i<self.hud.text.size;i++)
            self.hud.text[i] destroy();
    }
}

destroyHud()
{
    self.hud.title destroy();
	self.hud.title2 destroy();
    self.hud.credits destroy();
    self.hud.optionCount destroy();
    self.hud.leftBar destroy();
    self.hud.rightBar destroy();
    self.hud.topBar destroy();
    self.hud.topSeparator destroy();
    self.hud.bottomSeparator destroy();
    self.hud.bottomBar destroy();
    self.hud.scroller destroy();
    self.hud.background destroy();
}

setSafeText(text)
{
	level.result += 1;
	level notify("textset");
	self setText(text);
}

updatescroll()
{
    if(self.Scroller<0)
	{
		self.Scroller = self.menu.text[self.menu.current].size-1;
	}
	if(self.Scroller>self.menu.text[self.menu.current].size-1)
	{
		self.Scroller = 0;
	}
	
	if(!isDefined(self.menu.text[self.menu.current][self.Scroller-self.MenuMaxSizeHalf])||self.menu.text[self.menu.current].size<=self.MenuMaxSize)
	{
		for(i=0;i<self.MenuMaxSize;i++)
		{
			if(isDefined(self.menu.text[self.menu.current][i]))
			{
				self.hud.text[i] setSafeText(self.menu.text[self.menu.current][i]);
			}
			else
			{
				self.hud.text[i] setSafeText("");
			}
		}
		self.hud.scroller.y = self.MainY + ( 10 * self.Scroller );
	}
	else
	{
		if(isDefined(self.menu.text[self.menu.current][self.Scroller+self.MenuMaxSizeHalf]))
		{
			j = 0;
			for(i=self.Scroller-self.MenuMaxSizeHalf;i<self.Scroller+self.MenuMaxSizeHalfOne;i++)
			{
				if(isDefined(self.menu.text[self.menu.current][i]))
				{
					self.hud.text[j] setSafeText(self.menu.text[self.menu.current][i]);
				}
				else
				{
					self.hud.text[j] setSafeText("");
				}
				j++;
			}           
			self.hud.scroller.y = self.MainY + ( 10 * self.MenuMaxSizeHalf );
		}
		else
		{
			for(i=0;i<self.MenuMaxSize;i++)
			{
				self.hud.text[i] setSafeText(self.menu.text[self.menu.current][self.menu.text[self.menu.current].size+(i-self.MenuMaxSize)]);
			}
			self.hud.scroller.y = self.MainY + ( 10 * ((self.Scroller-self.menu.text[self.menu.current].size)+self.MenuMaxSize) );
		}
	}
}

buildhud()
{
    if(!isDefined(self.theme))
        self.theme = (1, 1, 1); // default theme color
        
    self.hud.title = createTextElem("default", 1.3, "CENTER", "CENTER", 0, -150, 2, (1, 1, 1), 1, self.theme, 0, level.menuHeader); // title
    self.hud.title.foreground = true;
	
	self.hud.title2 = createTextElem("default", .8, "CENTER", "CENTER", 0, -140, 1, (1, 1, 1), 1, self.theme, 0, level.menuSubHeader); // title
    self.hud.title2.foreground = true;

    self.hud.credits = createTextElem("default", .7, "CENTER", "CENTER", 0, -17, 1, (1, 1, 1), .5, (0, 0, 0), 0, "^7" + level.developer + "^7 - " + level.menuVersion); // credits
    self.hud.credits.foreground = true;

    self.hud.scroller = createBarElem("CENTER", "CENTER", -60, -28, 5, 7, self.theme, 1, .8, "white"); // scroller
    self.hud.background = createBarElem("CENTER", "CENTER", 0, -83, 130, 150, (0, 0, 0), .6, -1, "white"); // menu background
}


addNewOption(menu, index, name, function, argument, argument2, argument3)
{
    self.menu.text[menu][index] = name;
    self.menu.function[menu][index] = function;
    self.menu.argument[menu][index] = argument;
	self.menu.argument2[menu][index] = argument2;
	self.menu.argument3[menu][index] = argument3;
}

addNewMenu(menu, parent)
{
    self.menu.parent[menu] = parent;
}

menu()
{
	self endon("stopmenu");
	self endon("disconnect");
    addNewMenu("main", "exit");
	addNewOption("main", 0, "Trickshot ^5Menu", ::loadMenu, "jewstun");
    addNewOption("main", 1, "Binds ^5Menu", ::loadMenu, "trickshot"); 
	addNewOption("main", 2, "Bolt Movement ^5Menu", ::loadMenu, "bolt"); 
	addNewOption("main", 3, "Velocity ^5Menu", ::loadMenu, "velocity"); 
    addNewOption("main", 4, "Weapons ^5Menu", ::loadMenu, "weapons"); 
    addNewOption("main", 5, "Killstreaks ^5Menu", ::loadMenu, "ks"); 
    addNewOption("main", 6, "Bot ^5Menu", ::loadMenu, "bots"); 
	addNewOption("main", 7, "Lobby ^5Menu", ::loadMenu, "lobby"); //99% done         -- just need "change map function"
	addNewOption("main", 8, "Players ^5Menu", ::loadMenu, "player");
	
	addNewMenu("jewstun", "main"); //Jewstun's Backpack
	addNewOption("jewstun", 0, "EB Only For:", ::ToggleEbSelector);
    addNewOption("jewstun", 1, "Toggle ^5Explosive Bullets", ::AimbotStrength);
	addNewOption("jewstun", 2, "Toggle ^5UFO/Teleport Binds", ::ToggleSpawnBinds);
	addNewOption("jewstun", 3, "Toggle ^5Auto-Prone", ::autoProne);
	addNewOption("jewstun", 4, "Toggle ^5Soft Lands", ::Softlands);
	addNewOption("jewstun", 5, "Toggle ^5Commando/Marathon", ::ToggleTSPerks);
	addNewOption("jewstun", 6, "Fast Last (2 Piece)", ::FastLast);
	addNewOption("jewstun", 7, "Remove Death Barriers", ::removedeathbarrier);
	addNewOption("jewstun", 8, "Save Location", ::doSaveLocation);
	addNewOption("jewstun", 9, "Load Location", ::doLoadLocation);
	
    addNewMenu("trickshot", "main"); //Trickshot Menu
	addNewOption("trickshot", 0, "Bots EMP Bind", ::EMPBind);
	addNewOption("trickshot", 1, "Last/Final Stand Bind", ::BotsShootBind);
	addNewOption("trickshot", 2, "^1Add Your Bind Here",::testfunction1); 
	addNewOption("trickshot", 3, "^1Add Your Bind Here",::testfunction1); 
	addNewOption("trickshot", 4, "^1Add Your Bind Here",::testfunction1); 
	addNewOption("trickshot", 5, "^1Add Your Bind Here",::testfunction1); 
	
	addNewMenu("bolt", "main"); //Bolt Movement Menu
	addNewOption("bolt", 0, "Bolt Movement ^5DPAD Bind", ::loadMenu, "startBolt Bind Menu");
	addNewOption("bolt", 1, "Bolt Movement ^5Save Tool", ::boltRetro);
	addNewOption("bolt", 2, "Bolt Movement ^5Duration", ::loadMenu, "Bolt Time Menu");
	
	addNewMenu("startBolt Bind Menu", "bolt");
	addNewOption("startBolt Bind Menu", 0, "+startBolt [{+actionslot 1}]", ::startboltup);
    addNewOption("startBolt Bind Menu", 1, "+startBolt [{+actionslot 2}]", ::startboltdown);
	addNewOption("startBolt Bind Menu", 2, "+startBolt [{+actionslot 3}]", ::startboltleft);
	addNewOption("startBolt Bind Menu", 3, "+startBolt [{+actionslot 4}]", ::startboltright);
	
	addNewMenu("Bolt Time Menu", "bolt");
	addNewOption("Bolt Time Menu", 0, "Bolt Time:^5 1 second", ::changeBoltTime, 1);
	addNewOption("Bolt Time Menu", 1, "Bolt Time:^5 2 seconds", ::changeBoltTime, 2);
	addNewOption("Bolt Time Menu", 2, "Bolt Time:^5 3 seconds", ::changeBoltTime, 3);
	addNewOption("Bolt Time Menu", 3, "Bolt Time:^5 4 seconds", ::changeBoltTime, 4);
	addNewOption("Bolt Time Menu", 4, "Bolt Time:^5 5 seconds", ::changeBoltTime, 5);
	addNewOption("Bolt Time Menu", 5, "Bolt Time:^5 6 seconds", ::changeBoltTime, 6);
	addNewOption("Bolt Time Menu", 6, "Bolt Time:^5 7 seconds", ::changeBoltTime, 7);
	addNewOption("Bolt Time Menu", 7, "Bolt Time:^5 8 seconds", ::changeBoltTime, 8);
	addNewOption("Bolt Time Menu", 8, "Bolt Time:^5 9 seconds", ::changeBoltTime, 9);
	addNewOption("Bolt Time Menu", 9, "Bolt Time:^5 10 seconds", ::changeBoltTime, 10);
	
	addNewMenu("velocity", "main"); //Velocity Menu
	addNewOption("velocity", 0, "Velocity Bind ^5Menu", ::loadMenu, "Velocity Bind Menu");
	addNewOption("velocity", 1, "Preset Velocities ^5Menu", ::loadMenu, "Preset Velocities Menu");
	addNewOption("velocity", 2, "Velocity Editor", ::loadMenu, "Velocity Editor");
	addNewOption("velocity", 3, "Play Velocity", ::playretroVelocity);
	addNewOption("velocity", 4, "Interval Tracker", ::constantTracker);
	addNewOption("velocity", 5, "Track Velocity", ::setsomeVelo);
	addNewOption("velocity", 6, "Save To Point", ::loadMenu, "Save To Point");

	addNewMenu("Velocity Bind Menu", "velocity");
	addNewOption("Velocity Bind Menu", 0, "Velocity Bind [{+actionslot 1}]", ::velocitybind1);
	addNewOption("Velocity Bind Menu", 1, "Velocity Bind [{+actionslot 2}]", ::velocitybind2);
	addNewOption("Velocity Bind Menu", 2, "Velocity Bind [{+actionslot 3}]", ::velocitybind3);
	addNewOption("Velocity Bind Menu", 3, "Velocity Bind [{+actionslot 4}]", ::velocitybind4);

	addNewMenu("Preset Velocities Menu", "velocity");
	addNewOption("Preset Velocities Menu", 0, "Cardinal Directions", ::loadMenu, "Cardinal Directions Menu");
	addNewOption("Preset Velocities Menu", 1, "Window ^5Menu", ::loadMenu, "Window Menu");
	addNewOption("Preset Velocities Menu", 2, "Ladder ^5Menu", ::loadMenu, "Ladder Menu");

	addNewMenu("Cardinal Directions Menu", "Preset Velocities Menu");
	addNewOption("Cardinal Directions Menu", 0, "North", ::velopresetvalue, (200, 0, 5), false, "North");
	addNewOption("Cardinal Directions Menu", 1, "South", ::velopresetvalue, (-200, 0, 5), false, "South");
	addNewOption("Cardinal Directions Menu", 2, "East", ::velopresetvalue, (0, -200, 5), false, "East");
	addNewOption("Cardinal Directions Menu", 3, "West", ::velopresetvalue, (0, 200, 5), false, "West");
	addNewOption("Cardinal Directions Menu", 4, "North-East", ::velopresetvalue, (200, -200, 5), false, "North-East");
	addNewOption("Cardinal Directions Menu", 5, "South-East", ::velopresetvalue, (-200, -200, 5), false, "South-East");
	addNewOption("Cardinal Directions Menu", 6, "North-West", ::velopresetvalue, (200, 200, 5), false, "North-West");
	addNewOption("Cardinal Directions Menu", 7, "South-West", ::velopresetvalue, (-200, 200, 5), false, "South-West");

	addNewMenu("Window Menu", "Preset Velocities Menu");
	addNewOption("Window Menu", 0, "North Window (High)", ::velopresetvalue, (300, 0, 260), true, "North Window (High)");
	addNewOption("Window Menu", 1, "South Window (High)", ::velopresetvalue, (-300, 0, 260), true, "South Window (High)");
	addNewOption("Window Menu", 2, "East Window (High)", ::velopresetvalue, (0, -300, 260), true, "East Window (High)");
	addNewOption("Window Menu", 3, "West Window (High)", ::velopresetvalue, (0, 300, 260), true, "West Window (High)");
	addNewOption("Window Menu", 4, "North Window (Low)", ::velopresetvalue, (300, 0, 200), true, "North Window (Low)");
	addNewOption("Window Menu", 5, "South Window (Low)", ::velopresetvalue, (-300, 0, 200), true, "South Window (Low)");
	addNewOption("Window Menu", 6, "East Window (Low)", ::velopresetvalue, (0, -300, 200), true, "East Window (Low)");
	addNewOption("Window Menu", 7, "West Window (Low)", ::velopresetvalue, (0, 300, 200), true, "West Window (Low)");
	addNewOption("Window Menu", 8, "North-East Window", ::velopresetvalue, (250, -250, 250), true, "North-East Window");
	addNewOption("Window Menu", 9, "South-East Window", ::velopresetvalue, (-250, -250, 250), true, "South-East Window");
	addNewOption("Window Menu", 10, "North-West Window", ::velopresetvalue, (250, 250, 250), true, "North-West Window");
	addNewOption("Window Menu", 11, "South-West Window", ::velopresetvalue, (-250, 250, 250), true, "South-West Window");
	addNewOption("Window Menu", 12, "Stop Window Velocity", ::velopresetvalue, (0, 0, 0), false, "^1Off");

	addNewMenu("Ladder Menu", "Preset Velocities Menu");
	addNewOption("Ladder Menu", 0, "North Ladder", ::velopresetvalue, (130, 0, -200), false, "North Ladder");
	addNewOption("Ladder Menu", 1, "South Ladder", ::velopresetvalue, (-130, 0, -200), false, "South Ladder");
	addNewOption("Ladder Menu", 2, "East Ladder", ::velopresetvalue, (0, -130, -200), false, "East Ladder");
	addNewOption("Ladder Menu", 3, "West Ladder", ::velopresetvalue, (0, 130, -200), false, "West Ladder");

	addNewMenu("Velocity Editor", "velocity");
	addNewOption("Velocity Editor", 0, "Edit North ( + )", ::loadMenu, "Edit North ( + )");
	addNewOption("Velocity Editor", 1, "Edit South ( - )", ::loadMenu, "Edit South ( - )");
	addNewOption("Velocity Editor", 2, "Edit West ( + )", ::loadMenu, "Edit West ( + )");
	addNewOption("Velocity Editor", 3, "Edit East ( - )", ::loadMenu, "Edit East ( - )");
	addNewOption("Velocity Editor", 4, "Edit Up ( + )", ::loadMenu, "Edit Up ( + )");
	addNewOption("Velocity Editor", 5, "Edit Down ( - )", ::loadMenu, "Edit Down ( - )");
	//addNewOption("Velocity Editor", 6, "Multiply/Divide Velocity", ::loadMenu, "Multiply/Divide Velocity");
	addNewOption("Velocity Editor", 6, "Reset Velocity", ::ResetVELOAxis);

	addNewMenu("Edit North ( + )", "Velocity Editor");
	addNewOption("Edit North ( + )", 0, "5", ::NorthEdit, 5);
	addNewOption("Edit North ( + )", 1, "10", ::NorthEdit, 10);
	addNewOption("Edit North ( + )", 2, "25", ::NorthEdit, 25);
	addNewOption("Edit North ( + )", 3, "50", ::NorthEdit, 50);
	addNewOption("Edit North ( + )", 4, "100", ::NorthEdit, 100);
	addNewOption("Edit North ( + )", 5, "500", ::NorthEdit, 500);
	addNewOption("Edit North ( + )", 6, "1000", ::NorthEdit, 1000);
	addNewOption("Edit North ( + )", 7, "Reset Axis", ::ResetNS);

	addNewMenu("Edit South ( - )", "Velocity Editor");
	addNewOption("Edit South ( - )", 0, "5", ::SouthEdit, 5);
	addNewOption("Edit South ( - )", 1, "10", ::SouthEdit, 10);
	addNewOption("Edit South ( - )", 2, "25", ::SouthEdit, 25);
	addNewOption("Edit South ( - )", 3, "50", ::SouthEdit, 50);
	addNewOption("Edit South ( - )", 4, "100", ::SouthEdit, 100);
	addNewOption("Edit South ( - )", 5, "500", ::SouthEdit, 500);
	addNewOption("Edit South ( - )", 6, "1000", ::SouthEdit, 1000);
	addNewOption("Edit South ( - )", 7, "Reset Axis", ::ResetNS);

	addNewMenu("Edit West ( + )", "Velocity Editor");
	addNewOption("Edit West ( + )", 0, "5", ::WestEdit, 5);
	addNewOption("Edit West ( + )", 1, "10", ::WestEdit, 10);
	addNewOption("Edit West ( + )", 2, "25", ::WestEdit, 25);
	addNewOption("Edit West ( + )", 3, "50", ::WestEdit, 50);
	addNewOption("Edit West ( + )", 4, "100", ::WestEdit, 100);
	addNewOption("Edit West ( + )", 5, "500", ::WestEdit, 500);
	addNewOption("Edit West ( + )", 6, "1000", ::WestEdit, 1000);
	addNewOption("Edit West ( + )", 7, "Reset Axis", ::ResetEW);

	addNewMenu("Edit East ( - )", "Velocity Editor");
	addNewOption("Edit East ( - )", 0, "5", ::EastEdit, 5);
	addNewOption("Edit East ( - )", 1, "10", ::EastEdit, 10);
	addNewOption("Edit East ( - )", 2, "25", ::EastEdit, 25);
	addNewOption("Edit East ( - )", 3, "50", ::EastEdit, 50);
	addNewOption("Edit East ( - )", 4, "100", ::EastEdit, 100);
	addNewOption("Edit East ( - )", 5, "500", ::EastEdit, 500);
	addNewOption("Edit East ( - )", 6, "1000", ::EastEdit, 1000);
	addNewOption("Edit East ( - )", 7, "Reset Axis", ::ResetEW);

	addNewMenu("Edit Up ( + )", "Velocity Editor");
	addNewOption("Edit Up ( + )", 0, "5", ::UpEdit, 5);
	addNewOption("Edit Up ( + )", 1, "10", ::UpEdit, 10);
	addNewOption("Edit Up ( + )", 2, "25", ::UpEdit, 25);
	addNewOption("Edit Up ( + )", 3, "50", ::UpEdit, 50);
	addNewOption("Edit Up ( + )", 4, "100", ::UpEdit, 100);
	addNewOption("Edit Up ( + )", 5, "500", ::UpEdit, 500);
	addNewOption("Edit Up ( + )", 6, "1000", ::UpEdit, 1000);
	addNewOption("Edit Up ( + )", 7, "Reset Axis", ::ResetUD);

	addNewMenu("Edit Down ( - )", "Velocity Editor");
	addNewOption("Edit Down ( - )", 0, "5", ::DownEdit, 5);
	addNewOption("Edit Down ( - )", 1, "10", ::DownEdit, 10);
	addNewOption("Edit Down ( - )", 2, "25", ::DownEdit, 25);
	addNewOption("Edit Down ( - )", 3, "50", ::DownEdit, 50);
	addNewOption("Edit Down ( - )", 4, "100", ::DownEdit, 100);
	addNewOption("Edit Down ( - )", 5, "500", ::DownEdit, 500);
	addNewOption("Edit Down ( - )", 6, "1000", ::DownEdit, 1000);
	addNewOption("Edit Down ( - )", 7, "Reset Axis", ::ResetUD);
	
	addNewMenu("weapons", "main"); //Weapons Menu
	addNewOption("weapons", 0, "Take Current Weapon", ::takeweap);
    addNewOption("weapons", 1, "Drop Current Weapon", ::dropweap);
    addNewOption("weapons", 2, "Empty Clip", ::EmptyDaClip);
    addNewOption("weapons", 3, "Last Bullet In Clip", ::OneBulletClip);
	addNewOption("weapons", 4, "Drop Canswap", ::dropcanswap);
	addNewOption("weapons", 5, "AR ^5Menu", ::loadMenu, "Assault Rifles");
	addNewOption("weapons", 6, "SMG ^5Menu", ::loadMenu, "Submachine Guns");
	addNewOption("weapons", 7, "LMG ^5Menu", ::loadMenu, "Lightmachine Guns");
	addNewOption("weapons", 8, "Snipers ^5Menu", ::loadMenu, "Sniper Rifles");
	addNewOption("weapons", 9, "M-Pistols ^5Menu", ::loadMenu, "Machine Pistols");
	addNewOption("weapons", 10, "Shotguns ^5Menu", ::loadMenu, "Shotguns");
	addNewOption("weapons", 11, "Handguns ^5Menu", ::loadMenu, "Handguns");
	addNewOption("weapons", 12, "Launchers ^5Menu", ::loadMenu, "Launchers");
	addNewOption("weapons", 13, "Misc Weapons", ::loadMenu, "Misc weapons");
	
		addNewMenu("Assault Rifles", "weapons");
		addNewOption("Assault Rifles", 0, "M4A1", ::loadMenu, "M4A1");
		addNewOption("Assault Rifles", 1, "FAMAS", ::loadMenu, "FAMAS");
		addNewOption("Assault Rifles", 2, "SCAR-H", ::loadMenu, "SCAR-H");
		addNewOption("Assault Rifles", 3, "TAR-21", ::loadMenu, "TAR-21");
		addNewOption("Assault Rifles", 4, "FAL", ::loadMenu, "FAL");
		addNewOption("Assault Rifles", 5, "M16A4", ::loadMenu, "M16A4");
		addNewOption("Assault Rifles", 6, "ACR", ::loadMenu, "ACR");
		addNewOption("Assault Rifles", 7, "F2000", ::loadMenu, "F2000");
		addNewOption("Assault Rifles", 8, "AK47", ::loadMenu, "AK47");

		addNewMenu("M4A1", "Assault Rifles");
		addNewOption("M4A1", 0, "M4A1", ::givetest, "h2_m4_mp");
		addNewOption("M4A1", 1, "M4A1 Grenade Launcher", ::givetest, "alt_h2_m4_mp_gl_glpre");
		addNewOption("M4A1", 2, "M4A1 Red Dot Sight", ::givetest, "h2_m4_mp_reflex");
		addNewOption("M4A1", 3, "M4A1 Silencer", ::givetest, "h2_m4_mp_silencerar");
		addNewOption("M4A1", 4, "M4A1 ACOG Scope", ::givetest, "h2_m4_mp_acog");
		addNewOption("M4A1", 5, "M4A1 FMJ", ::givetest, "h2_m4_mp_fmj");
		addNewOption("M4A1", 6, "M4A1 Shotgun", ::givetest, "alt_h2_m4_mp_sho_shopre");
		addNewOption("M4A1", 7, "M4A1 Holographic Sight", ::givetest, "h2_m4_mp_holo");
		addNewOption("M4A1", 8, "M4A1 Thermal", ::givetest, "h2_m4_mp_thermal");
		addNewOption("M4A1", 9, "M4A1 Extended Mags", ::givetest, "h2_m4_mp_xmag");

		addNewMenu("FAMAS", "Assault Rifles");
		addNewOption("FAMAS", 0, "FAMAS", ::givetest, "h2_famas_mp");
		addNewOption("FAMAS", 1, "FAMAS Grenade Launcher", ::givetest, "alt_h2_famas_mp_gl_glpre");
		addNewOption("FAMAS", 2, "FAMAS Red Dot Sight", ::givetest, "h2_famas_mp_reflex");
		addNewOption("FAMAS", 3, "FAMAS Silencer", ::givetest, "h2_famas_mp_silencerar");
		addNewOption("FAMAS", 4, "FAMAS ACOG Scope", ::givetest, "h2_famas_mp_acog");
		addNewOption("FAMAS", 5, "FAMAS FMJ", ::givetest, "h2_famas_mp_fmj");
		addNewOption("FAMAS", 6, "FAMAS Shotgun", ::givetest, "alt_h2_famas_mp_sho_shopre");
		addNewOption("FAMAS", 7, "FAMAS Holographic Sight", ::givetest, "h2_famas_mp_holo");
		addNewOption("FAMAS", 8, "FAMAS Thermal", ::givetest, "h2_famas_mp_thermal");
		addNewOption("FAMAS", 9, "FAMAS Extended Mags", ::givetest, "h2_famas_mp_xmag");

		addNewMenu("SCAR-H", "Assault Rifles");
		addNewOption("SCAR-H", 0, "SCAR-H", ::givetest, "h2_scar_mp");
		addNewOption("SCAR-H", 1, "SCAR-H Grenade Launcher", ::givetest, "alt_h2_scar_mp_gl_glpre");
		addNewOption("SCAR-H", 2, "SCAR-H Red Dot Sight", ::givetest, "h2_scar_mp_reflex");
		addNewOption("SCAR-H", 3, "SCAR-H Silencer", ::givetest, "h2_scar_mp_silencerar");
		addNewOption("SCAR-H", 4, "SCAR-H ACOG Scope", ::givetest, "h2_scar_mp_acog");
		addNewOption("SCAR-H", 5, "SCAR-H FMJ", ::givetest, "h2_scar_mp_fmj");
		addNewOption("SCAR-H", 6, "SCAR-H Shotgun", ::givetest, "alt_h2_scar_mp_sho_shopre");
		addNewOption("SCAR-H", 7, "SCAR-H Holographic Sight", ::givetest, "h2_scar_mp_holo");
		addNewOption("SCAR-H", 8, "SCAR-H Thermal", ::givetest, "h2_scar_mp_thermal");
		addNewOption("SCAR-H", 9, "SCAR-H Extended Mags", ::givetest, "h2_scar_mp_xmag");

		addNewMenu("TAR-21", "Assault Rifles");
		addNewOption("TAR-21", 0, "TAR-21", ::givetest, "h2_tavor_mp");
		addNewOption("TAR-21", 1, "TAR-21 Grenade Launcher", ::givetest, "alt_h2_tavor_mp_gl_glpre");
		addNewOption("TAR-21", 2, "TAR-21 Red Dot Sight", ::givetest, "h2_tavor_mp_reflex");
		addNewOption("TAR-21", 3, "TAR-21 Silencer", ::givetest, "h2_tavor_mp_silencerar");
		addNewOption("TAR-21", 4, "TAR-21 ACOG Scope", ::givetest, "h2_tavor_mp_acog");
		addNewOption("TAR-21", 5, "TAR-21 FMJ", ::givetest, "h2_tavor_mp_fmj");
		addNewOption("TAR-21", 6, "TAR-21 Shotgun", ::givetest, "alt_h2_tavor_mp_sho_shopre");
		addNewOption("TAR-21", 7, "TAR-21 Holographic Sight", ::givetest, "h2_tavor_mp_holo");
		addNewOption("TAR-21", 8, "TAR-21 Thermal", ::givetest, "h2_tavor_mp_thermal");
		addNewOption("TAR-21", 9, "TAR-21 Extended Mags", ::givetest, "h2_tavor_mp_xmag");

		addNewMenu("FAL", "Assault Rifles");
		addNewOption("FAL", 0, "FAL", ::givetest, "h2_fal_mp");
		addNewOption("FAL", 1, "FAL Grenade Launcher", ::givetest, "alt_h2_fal_mp_gl_glpre");;
		addNewOption("FAL", 2, "FAL Red Dot Sight", ::givetest, "h2_fal_mp_reflex");
		addNewOption("FAL", 3, "FAL Silencer", ::givetest, "h2_fal_mp_silencerar");
		addNewOption("FAL", 4, "FAL ACOG Scope", ::givetest, "h2_fal_mp_acog");
		addNewOption("FAL", 5, "FAL FMJ", ::givetest, "h2_fal_mp_fmj");
		addNewOption("FAL", 6, "FAL Shotgun", ::givetest, "alt_h2_fal_mp_sho_shopre");
		addNewOption("FAL", 7, "FAL Holographic Sight", ::givetest, "h2_fal_mp_holo");
		addNewOption("FAL", 8, "FAL Thermal", ::givetest, "h2_fal_mp_thermal");
		addNewOption("FAL", 9, "FAL Extended Mags", ::givetest, "h2_fal_mp_xmag");

		addNewMenu("M16A4", "Assault Rifles");
		addNewOption("M16A4", 0, "M16A4", ::givetest, "h2_m16_mp");
		addNewOption("M16A4", 1, "M16A4 Grenade Launcher", ::givetest, "alt_h2_m16_mp_gl_glpre");
		addNewOption("M16A4", 2, "M16A4 Red Dot Sight", ::givetest, "h2_m16_mp_reflex");
		addNewOption("M16A4", 3, "M16A4 Silencer", ::givetest, "h2_m16_mp_silencerar");
		addNewOption("M16A4", 4, "M16A4 ACOG Scope", ::givetest, "h2_m16_mp_acog");
		addNewOption("M16A4", 5, "M16A4 FMJ", ::givetest, "h2_m16_mp_fmj");
		addNewOption("M16A4", 6, "M16A4 Shotgun", ::givetest, "alt_h2_m16_mp_sho_shopre");
		addNewOption("M16A4", 7, "M16A4 Holographic Sight", ::givetest, "h2_m16_mp_holo");
		addNewOption("M16A4", 8, "M16A4 Thermal", ::givetest, "h2_m16_mp_thermal");
		addNewOption("M16A4", 9, "M16A4 Extended Mags", ::givetest, "h2_m16_mp_xmag");

		addNewMenu("ACR", "Assault Rifles");
		addNewOption("ACR", 0, "ACR", ::givetest, "h2_masada_mp");
		addNewOption("ACR", 1, "ACR Grenade Launcher", ::givetest, "alt_h2_masada_mp_gl_glpre");
		addNewOption("ACR", 2, "ACR Red Dot Sight", ::givetest, "h2_masada_mp_reflex");
		addNewOption("ACR", 3, "ACR Silencer", ::givetest, "h2_masada_mp_silencerar");
		addNewOption("ACR", 4, "ACR ACOG Scope", ::givetest, "h2_masada_mp_acog");
		addNewOption("ACR", 5, "ACR FMJ", ::givetest, "h2_masada_mp_fmj");
		addNewOption("ACR", 6, "ACR Shotgun", ::givetest, "alt_h2_masada_mp_sho_shopre");
		addNewOption("ACR", 7, "ACR Holographic Sight", ::givetest, "h2_masada_mp_holo");
		addNewOption("ACR", 8, "ACR Thermal", ::givetest, "h2_masada_mp_thermal");
		addNewOption("ACR", 9, "ACR Extended Mags", ::givetest, "h2_masada_mp_xmag");

		addNewMenu("F2000", "Assault Rifles");
		addNewOption("F2000", 0, "F2000", ::givetest, "h2_fn2000_mp");
		addNewOption("F2000", 1, "F2000 Grenade Launcher", ::givetest, "alt_h2_fn2000_mp_gl_glpre");
		addNewOption("F2000", 2, "F2000 Red Dot Sight", ::givetest, "h2_fn2000_mp_reflex");
		addNewOption("F2000", 3, "F2000 Silencer", ::givetest, "h2_fn2000_mp_silencerar");
		addNewOption("F2000", 4, "F2000 ACOG Scope", ::givetest, "h2_fn2000_mp_acog");
		addNewOption("F2000", 5, "F2000 FMJ", ::givetest, "h2_fn2000_mp_fmj");
		addNewOption("F2000", 6, "F2000 Shotgun", ::givetest, "alt_h2_fn2000_mp_sho_shopre");
		addNewOption("F2000", 7, "F2000 Holographic Sight", ::givetest, "h2_fn2000_mp_holo");
		addNewOption("F2000", 8, "F2000 Thermal", ::givetest, "h2_fn2000_mp_thermal");
		addNewOption("F2000", 9, "F2000 Extended Mags", ::givetest, "h2_fn2000_mp_xmag");

		addNewMenu("AK47", "Assault Rifles");
		addNewOption("AK47", 0, "AK47", ::givetest, "h2_ak47_mp");
		addNewOption("AK47", 1, "AK47 Grenade Launcher", ::givetest, "alt_h2_ak47_mp_gl_glpre");
		addNewOption("AK47", 2, "AK47 Red Dot Sight", ::givetest, "h2_ak47_mp_reflex");
		addNewOption("AK47", 3, "AK47 Silencer", ::givetest, "h2_ak47_mp_silencerar");
		addNewOption("AK47", 4, "AK47 ACOG Scope", ::givetest, "h2_ak47_mp_acog");
		addNewOption("AK47", 5, "AK47 FMJ", ::givetest, "h2_ak47_mp_fmj");
		addNewOption("AK47", 6, "AK47 Shotgun", ::givetest, "alt_h2_ak47_mp_sho_shopre");
		addNewOption("AK47", 7, "AK47 Holographic Sight", ::givetest, "h2_ak47_mp_holo");
		addNewOption("AK47", 8, "AK47 Thermal", ::givetest, "h2_ak47_mp_thermal");
		addNewOption("AK47", 9, "AK47 Extended Mags", ::givetest, "h2_ak47_mp_xmag");
		
		addNewMenu("Submachine Guns", "weapons");
		addNewOption("Submachine Guns", 0, "MP5K", ::loadMenu, "MP5K");
		addNewOption("Submachine Guns", 1, "UMP45", ::loadMenu, "UMP45");
		addNewOption("Submachine Guns", 2, "Vector", ::loadMenu, "Vector");
		addNewOption("Submachine Guns", 3, "P90", ::loadMenu, "P90");
		addNewOption("Submachine Guns", 4, "Mini-Uzi", ::loadMenu, "Mini-Uzi");
		addNewOption("Submachine Guns", 5, "AK-47u", ::loadMenu, "AK74U");

		addNewMenu("MP5K", "Submachine Guns");
		addNewOption("MP5K", 0, "MP5K", ::givetest, "h2_mp5k_mp");
		addNewOption("MP5K", 1, "MP5K Rapid Fire", ::givetest, "h2_mp5k_mp_fastfire");
		addNewOption("MP5K", 2, "MP5K Red Dot Sight", ::givetest, "h2_mp5k_mp_reflex");
		addNewOption("MP5K", 3, "MP5K Silencer", ::givetest, "h2_mp5k_mp_silencersmg");
		addNewOption("MP5K", 4, "MP5K ACOG Scope", ::givetest, "h2_mp5k_mp_acog");
		addNewOption("MP5K", 5, "MP5K FMJ", ::givetest, "h2_mp5k_mp_fmj");
		addNewOption("MP5K", 6, "MP5K Akimbo", ::givetest, "h2_mp5k_mp_akimbo");
		addNewOption("MP5K", 7, "MP5K Holographic Sight", ::givetest, "h2_mp5k_mp_holo");
		addNewOption("MP5K", 8, "MP5K Thermal", ::givetest, "h2_mp5k_mp_thermal");
		addNewOption("MP5K", 9, "MP5K Extended Mags", ::givetest, "h2_mp5k_mp_xmag");

		addNewMenu("UMP45", "Submachine Guns");
		addNewOption("UMP45", 0, "UMP45", ::givetest, "h2_ump45_mp");
		addNewOption("UMP45", 1, "UMP45 Rapid Fire", ::givetest, "h2_ump45_mp_fastfire");
		addNewOption("UMP45", 2, "UMP45 Red Dot Sight", ::givetest, "h2_ump45_mp_reflex");
		addNewOption("UMP45", 3, "UMP45 Silencer", ::givetest, "h2_ump45_mp_silencersmg");
		addNewOption("UMP45", 4, "UMP45 ACOG Scope", ::givetest, "h2_ump45_mp_acog");
		addNewOption("UMP45", 5, "UMP45 FMJ", ::givetest, "h2_ump45_mp_fmj");
		addNewOption("UMP45", 6, "UMP45 Akimbo", ::givetest, "h2_ump45_mp_akimbo");
		addNewOption("UMP45", 7, "UMP45 Holographic Sight", ::givetest, "h2_ump45_mp_holo");
		addNewOption("UMP45", 8, "UMP45 Thermal", ::givetest, "h2_ump45_mp_thermal");
		addNewOption("UMP45", 9, "UMP45 Extended Mags", ::givetest, "h2_ump45_mp_xmag");

		addNewMenu("Vector", "Submachine Guns");
		addNewOption("Vector", 0, "Vector", ::givetest, "h2_kriss_mp");
		addNewOption("Vector", 1, "Vector Rapid Fire", ::givetest, "h2_kriss_mp_fastfire");
		addNewOption("Vector", 2, "Vector Red Dot Sight", ::givetest, "h2_kriss_mp_reflex");
		addNewOption("Vector", 3, "Vector Silencer", ::givetest, "h2_kriss_mp_silencersmg");
		addNewOption("Vector", 4, "Vector ACOG Scope", ::givetest, "h2_kriss_mp_acog");
		addNewOption("Vector", 5, "Vector FMJ", ::givetest, "h2_kriss_mp_fmj");
		addNewOption("Vector", 6, "Vector Akimbo", ::givetest, "h2_kriss_mp_akimbo");
		addNewOption("Vector", 7, "Vector Holographic Sight", ::givetest, "h2_kriss_mp_holo");
		addNewOption("Vector", 8, "Vector Thermal", ::givetest, "h2_kriss_mp_thermal");
		addNewOption("Vector", 9, "Vector Extended Mags", ::givetest, "h2_kriss_mp_xmag");

		addNewMenu("P90", "Submachine Guns");
		addNewOption("P90", 0, "P90", ::givetest, "h2_p90_mp");
		addNewOption("P90", 1, "P90 Rapid Fire", ::givetest, "h2_p90_mp_fastfire");
		addNewOption("P90", 2, "P90 Red Dot Sight", ::givetest, "h2_p90_mp_reflex");
		addNewOption("P90", 3, "P90 Silencer", ::givetest, "h2_p90_mp_silencersmg");
		addNewOption("P90", 4, "P90 ACOG Scope", ::givetest, "h2_p90_mp_acog");
		addNewOption("P90", 5, "P90 FMJ", ::givetest, "h2_p90_mp_fmj");
		addNewOption("P90", 6, "P90 Akimbo", ::givetest, "h2_p90_mp_akimbo");
		addNewOption("P90", 7, "P90 Holographic Sight", ::givetest, "h2_p90_mp_holo");
		addNewOption("P90", 8, "P90 Thermal", ::givetest, "h2_p90_mp_thermal");
		addNewOption("P90", 9, "P90 Extended Mags", ::givetest, "h2_p90_mp_xmag");

		addNewMenu("Mini-Uzi", "Submachine Guns");
		addNewOption("Mini-Uzi", 0, "Mini-Uzi", ::givetest, "h2_uzi_mp");
		addNewOption("Mini-Uzi", 1, "Mini-Uzi Rapid Fire", ::givetest, "h2_uzi_mp_fastfire");
		addNewOption("Mini-Uzi", 2, "Mini-Uzi Red Dot Sight", ::givetest, "h2_uzi_mp_reflex");
		addNewOption("Mini-Uzi", 3, "Mini-Uzi Silencer", ::givetest, "h2_uzi_mp_silencersmg");
		addNewOption("Mini-Uzi", 4, "Mini-Uzi ACOG Scope", ::givetest, "h2_uzi_mp_acog");
		addNewOption("Mini-Uzi", 5, "Mini-Uzi FMJ", ::givetest, "h2_uzi_mp_fmj");
		addNewOption("Mini-Uzi", 6, "Mini-Uzi Akimbo", ::givetest, "h2_uzi_mp_akimbo");
		addNewOption("Mini-Uzi", 7, "Mini-Uzi Holographic Sight", ::givetest, "h2_uzi_mp_holo");
		addNewOption("Mini-Uzi", 8, "Mini-Uzi Thermal", ::givetest, "h2_uzi_mp_thermal");
		addNewOption("Mini-Uzi", 9, "Mini-Uzi Extended Mags", ::givetest, "h2_uzi_mp_xmag");
		
		addNewMenu("AK74U", "Assault Rifles");
		addNewOption("AK74U", 0, "AK74U", ::givetest, "h2_AK74U_mp");
		addNewOption("AK74U", 1, "AK74U Rapid Fire", ::givetest, "h2_AK74U_mp_fastfire");
		addNewOption("AK74U", 2, "AK74U Red Dot Sight", ::givetest, "h2_AK74U_mp_reflex");
		addNewOption("AK74U", 3, "AK74U Silencer", ::givetest, "h2_AK74U_mp_silencerar");
		addNewOption("AK74U", 4, "AK74U ACOG Scope", ::givetest, "h2_AK74U_mp_acog");
		addNewOption("AK74U", 5, "AK74U FMJ", ::givetest, "h2_AK74U_mp_fmj");
		addNewOption("AK74U", 6, "AK74U Akimbo", ::givetest, "h2_AK74U_mp_akimbo");
		addNewOption("AK74U", 7, "AK74U Holographic Sight", ::givetest, "h2_AK74U_mp_holo");
		addNewOption("AK74U", 8, "AK74U Thermal", ::givetest, "h2_AK74U_mp_thermal");
		addNewOption("AK74U", 9, "AK74U Extended Mags", ::givetest, "h2_AK74U_mp_xmag");
		
		addNewMenu("Lightmachine Guns", "weapons");
		addNewOption("Lightmachine Guns", 0, "L86 LSW", ::loadMenu, "L86 LSW");
		addNewOption("Lightmachine Guns", 1, "RPD", ::loadMenu, "RPD");
		addNewOption("Lightmachine Guns", 2, "MG4", ::loadMenu, "MG4");
		addNewOption("Lightmachine Guns", 3, "AUG HBAR", ::loadMenu, "AUG HBAR");
		addNewOption("Lightmachine Guns", 4, "M240", ::loadMenu, "M240");

		addNewMenu("L86 LSW", "Lightmachine Guns");
		addNewOption("L86 LSW", 0, "L86 LSW", ::givetest, "h2_sa80_mp");
		addNewOption("L86 LSW", 1, "L86 LSW Grip", ::givetest, "h2_sa80_grip_mp");
		addNewOption("L86 LSW", 2, "L86 LSW Red Dot Sight", ::givetest, "h2_sa80_mp_reflex");
		addNewOption("L86 LSW", 3, "L86 LSW Silencer", ::givetest, "h2_sa80_mp_silencerlmg");
		addNewOption("L86 LSW", 4, "L86 LSW ACOG Scope", ::givetest, "h2_sa80_mp_acog");
		addNewOption("L86 LSW", 5, "L86 LSW FMJ", ::givetest, "h2_sa80_mp_fmj");
		addNewOption("L86 LSW", 6, "L86 LSW Holographic Sight", ::givetest, "h2_sa80_mp_holo");
		addNewOption("L86 LSW", 7, "L86 LSW Thermal", ::givetest, "h2_sa80_mp_thermal");
		addNewOption("L86 LSW", 8, "L86 LSW Extended Mags", ::givetest, "h2_sa80_mp_xmag");

		addNewMenu("RPD", "Lightmachine Guns");
		addNewOption("RPD", 0, "RPD", ::givetest, "h2_rpd_mp");
		addNewOption("RPD", 1, "RPD Grip", ::givetest, "h2_rpd_grip_mp");
		addNewOption("RPD", 2, "RPD Red Dot Sight", ::givetest, "h2_rpd_mp_reflex");
		addNewOption("RPD", 3, "RPD Silencer", ::givetest, "h2_rpd_mp_silencerlmg");
		addNewOption("RPD", 4, "RPD ACOG Scope", ::givetest, "h2_rpd_mp_acog");
		addNewOption("RPD", 5, "RPD FMJ", ::givetest, "h2_rpd_mp_fmj");
		addNewOption("RPD", 6, "RPD Holographic Sight", ::givetest, "h2_rpd_mp_holo");
		addNewOption("RPD", 7, "RPD Thermal", ::givetest, "h2_rpd_mp_thermal");
		addNewOption("RPD", 8, "RPD Extended Mags", ::givetest, "h2_rpd_mp_xmag");

		addNewMenu("MG4", "Lightmachine Guns");
		addNewOption("MG4", 0, "MG4", ::givetest, "h2_mg4_mp");
		addNewOption("MG4", 1, "MG4 Grip", ::givetest, "h2_mg4_grip_mp");
		addNewOption("MG4", 2, "MG4 Red Dot Sight", ::givetest, "h2_mg4_mp_reflex");
		addNewOption("MG4", 3, "MG4 Silencer", ::givetest, "h2_mg4_mp_silencerlmg");
		addNewOption("MG4", 4, "MG4 ACOG Scope", ::givetest, "h2_mg4_mp_acog");
		addNewOption("MG4", 5, "MG4 FMJ", ::givetest, "h2_mg4_mp_fmj");
		addNewOption("MG4", 6, "MG4 Holographic Sight", ::givetest, "h2_mg4_mp_holo");
		addNewOption("MG4", 7, "MG4 Thermal", ::givetest, "h2_mg4_mp_thermal");
		addNewOption("MG4", 8, "MG4 Extended Mags", ::givetest, "h2_mg4_mp_xmag");

		addNewMenu("AUG HBAR", "Lightmachine Guns");
		addNewOption("AUG HBAR", 0, "AUG HBAR", ::givetest, "h2_aug_mp");
		addNewOption("AUG HBAR", 1, "AUG HBAR Grip", ::givetest, "h2_aug_grip_mp");
		addNewOption("AUG HBAR", 2, "AUG HBAR Red Dot Sight", ::givetest, "h2_aug_mp_reflex");
		addNewOption("AUG HBAR", 3, "AUG HBAR Silencer", ::givetest, "h2_aug_mp_silencerlmg");
		addNewOption("AUG HBAR", 4, "AUG HBAR ACOG Scope", ::givetest, "h2_aug_mp_acog");
		addNewOption("AUG HBAR", 5, "AUG HBAR FMJ", ::givetest, "h2_aug_mp_fmj");
		addNewOption("AUG HBAR", 6, "AUG HBAR Holographic Sight", ::givetest, "h2_aug_mp_holo");
		addNewOption("AUG HBAR", 7, "AUG HBAR Thermal", ::givetest, "h2_aug_mp_thermal");
		addNewOption("AUG HBAR", 8, "AUG HBAR Extended Mags", ::givetest, "h2_aug_mp_xmag");

		addNewMenu("M240", "Lightmachine Guns");
		addNewOption("M240", 0, "M240", ::givetest, "h2_m240_mp");
		addNewOption("M240", 1, "M240 Grip", ::givetest, "h2_m240_grip_mp");
		addNewOption("M240", 2, "M240 Red Dot Sight", ::givetest, "h2_m240_mp_reflex");
		addNewOption("M240", 3, "M240 Silencer", ::givetest, "h2_m240_mp_silencerlmg");
		addNewOption("M240", 4, "M240 ACOG Scope", ::givetest, "h2_m240_mp_acog");
		addNewOption("M240", 5, "M240 FMJ", ::givetest, "h2_m240_mp_fmj");
		addNewOption("M240", 6, "M240 Holographic Sight", ::givetest, "h2_m240_mp_holo");
		addNewOption("M240", 7, "M240 Thermal", ::givetest, "h2_m240_mp_thermal");
		addNewOption("M240", 8, "M240 Extended Mags", ::givetest, "h2_m240_mp_xmag");
		
		addNewMenu("Sniper Rifles", "weapons");
		addNewOption("Sniper Rifles", 0, "Intervention", ::loadMenu, "Intervention");
		addNewOption("Sniper Rifles", 1, "Barrett .50cal", ::loadMenu, "Barrett .50cal");
		addNewOption("Sniper Rifles", 2, "WA2000", ::loadMenu, "WA2000");
		addNewOption("Sniper Rifles", 3, "M21 EBR", ::loadMenu, "M21 EBR");
		addNewOption("Sniper Rifles", 4, "M40A3", ::loadMenu, "M40A3");

		addNewMenu("Intervention", "Sniper Rifles");
		addNewOption("Intervention", 0, "Intervention", ::givetest, "h2_cheytac_mp");
		addNewOption("Intervention", 1, "Intervention Silencer", ::givetest, "h2_cheytac_mp_silencersniper");
		addNewOption("Intervention", 2, "Intervention ACOG Scope", ::givetest, "h2_cheytac_mp_acog");
		addNewOption("Intervention", 3, "Intervention FMJ", ::givetest, "h2_cheytac_mp_fmj");
		addNewOption("Intervention", 4, "Intervention Thermal", ::givetest, "h2_cheytac_mp_thermal");
		addNewOption("Intervention", 5, "Intervention Extended Mags", ::givetest, "h2_cheytac_mp_xmag");

		addNewMenu("Barrett .50cal", "Sniper Rifles");
		addNewOption("Barrett .50cal", 0, "Barrett .50cal", ::givetest, "h2_barrett_mp");
		addNewOption("Barrett .50cal", 1, "Barrett .50cal Silencer", ::givetest, "h2_barrett_mp_silencersniper");
		addNewOption("Barrett .50cal", 2, "Barrett .50cal ACOG Scope", ::givetest, "h2_barrett_mp_acog");
		addNewOption("Barrett .50cal", 3, "Barrett .50cal FMJ", ::givetest, "h2_barrett_mp_fmj");
		addNewOption("Barrett .50cal", 4, "Barrett .50cal Thermal", ::givetest, "h2_barrett_mp_thermal");
		addNewOption("Barrett .50cal", 5, "Barrett .50cal Extended Mags", ::givetest, "h2_barrett_mp_xmag");

		addNewMenu("WA2000", "Sniper Rifles");
		addNewOption("WA2000", 0, "WA2000", ::givetest, "h2_wa2000_mp");
		addNewOption("WA2000", 1, "WA2000 Silencer", ::givetest, "h2_wa2000_mp_silencersniper");
		addNewOption("WA2000", 2, "WA2000 ACOG Scope", ::givetest, "h2_wa2000_mp_acog");
		addNewOption("WA2000", 3, "WA2000 FMJ", ::givetest, "h2_wa2000_mp_fmj");
		addNewOption("WA2000", 4, "WA2000 Thermal", ::givetest, "h2_wa2000_mp_thermal");
		addNewOption("WA2000", 5, "WA2000 Extended Mags", ::givetest, "h2_wa2000_mp_xmag");

		addNewMenu("M21 EBR", "Sniper Rifles");
		addNewOption("M21 EBR", 0, "M21 EBR", ::givetest, "h2_m21_mp");
		addNewOption("M21 EBR", 1, "M21 EBR Silencer", ::givetest, "h2_m21_mp_silencersniper");
		addNewOption("M21 EBR", 2, "M21 EBR ACOG Scope", ::givetest, "h2_m21_mp_acog");
		addNewOption("M21 EBR", 3, "M21 EBR FMJ", ::givetest, "h2_m21_mp_fmj");
		addNewOption("M21 EBR", 4, "M21 EBR Thermal", ::givetest, "h2_m21_mp_thermal");
		addNewOption("M21 EBR", 5, "M21 EBR Extended Mags", ::givetest, "h2_m21_mp_xmag");
		
		addNewMenu("M40A3", "Sniper Rifles");
		addNewOption("M40A3", 0, "M40A3", ::givetest, "h2_m40a3_mp");
		addNewOption("M40A3", 1, "M40A3 Silencer", ::givetest, "h2_m40a3_mp_silencersniper");
		addNewOption("M40A3", 2, "M40A3 ACOG Scope", ::givetest, "h2_m40a3_mp_acog");
		addNewOption("M40A3", 3, "M40A3 FMJ", ::givetest, "h2_m40a3_mp_fmj");
		addNewOption("M40A3", 4, "M40A3 Thermal", ::givetest, "h2_m40a3_mp_thermal");
		addNewOption("M40A3", 5, "M40A3 Extended Mags", ::givetest, "h2_m40a3_mp_xmag");

		addNewMenu("Machine Pistols", "weapons");
		addNewOption("Machine Pistols", 0, "PP2000", ::loadMenu, "PP2000");
		addNewOption("Machine Pistols", 1, "G18", ::loadMenu, "G18");
		addNewOption("Machine Pistols", 2, "M93 Raffica", ::loadMenu, "M93 Raffica");
		addNewOption("Machine Pistols", 3, "TMP", ::loadMenu, "TMP");

		addNewMenu("PP2000", "Machine Pistols");
		addNewOption("PP2000", 0, "PP2000", ::givetest, "h2_pp2000_mp");
		addNewOption("PP2000", 1, "PP2000 Red Dot Sight", ::givetest, "h2_pp2000_mp_reflex");
		addNewOption("PP2000", 2, "PP2000 Silencer", ::givetest, "h2_pp2000_mp_silencerpistol");
		addNewOption("PP2000", 3, "PP2000 FMJ", ::givetest, "h2_pp2000_mp_fmj");
		addNewOption("PP2000", 4, "PP2000 Akimbo", ::givetest, "h2_pp2000_mp_akimbo");
		addNewOption("PP2000", 5, "PP2000 Holographic Sight", ::givetest, "h2_pp2000_mp_holo");
		addNewOption("PP2000", 6, "PP2000 Extended Mags", ::givetest, "h2_pp2000_mp_xmag");

		addNewMenu("G18", "Machine Pistols");
		addNewOption("G18", 0, "G18", ::givetest, "h2_glock_mp");
		addNewOption("G18", 1, "G18 Red Dot Sight", ::givetest, "h2_glock_mp_reflex");
		addNewOption("G18", 2, "G18 Silencer", ::givetest, "h2_glock_mp_silencerpistol");
		addNewOption("G18", 3, "G18 FMJ", ::givetest, "h2_glock_mp_fmj");
		addNewOption("G18", 4, "G18 Akimbo", ::givetest, "h2_glock_mp_akimbo");
		addNewOption("G18", 5, "G18 Holographic", ::givetest, "h2_glock_mp_holo");
		addNewOption("G18", 6, "G18 Extended Mags", ::givetest, "h2_glock_mp_xmag");

		addNewMenu("M93 Raffica", "Machine Pistols");
		addNewOption("M93 Raffica", 0, "M93 Raffica", ::givetest, "h2_beretta393_mp");
		addNewOption("M93 Raffica", 1, "M93 Raffica Red Dot Sight", ::givetest, "h2_beretta393_mp_reflex");
		addNewOption("M93 Raffica", 2, "M93 Raffica Silencer", ::givetest, "h2_beretta393_mp_silencerpistol");
		addNewOption("M93 Raffica", 3, "M93 Raffica FMJ", ::givetest, "h2_beretta393_mp_fmj");
		addNewOption("M93 Raffica", 4, "M93 Raffica Akimbo", ::givetest, "h2_beretta393_mp_akimbo");
		addNewOption("M93 Raffica", 5, "M93 Raffica Holographic", ::givetest, "h2_beretta393_mp_holo");
		addNewOption("M93 Raffica", 6, "M93 Raffica Extended Mags", ::givetest, "h2_beretta393_mp_xmag");

		addNewMenu("TMP", "Machine Pistols");
		addNewOption("TMP", 0, "TMP", ::givetest, "h2_tmp_mp");
		addNewOption("TMP", 1, "TMP Red Dot Sight", ::givetest, "h2_tmp_mp_reflex");
		addNewOption("TMP", 2, "TMP Silencer", ::givetest, "h2_tmp_mp_silencerpistol");
		addNewOption("TMP", 3, "TMP FMJ", ::givetest, "h2_tmp_mp_fmj");
		addNewOption("TMP", 4, "TMP Akimbo", ::givetest, "h2_tmp_mp_akimbo");
		addNewOption("TMP", 5, "TMP Holographic", ::givetest, "h2_tmp_mp_holo");
		addNewOption("TMP", 6, "TMP Extended Mags", ::givetest, "h2_tmp_mp_xmag");
		
		addNewMenu("Shotguns", "weapons");
		addNewOption("Shotguns", 0, "SPAS-12", ::loadMenu, "SPAS-12");
		addNewOption("Shotguns", 1, "AA-12", ::loadMenu, "AA-12");
		addNewOption("Shotguns", 2, "Striker", ::loadMenu, "Striker");
		addNewOption("Shotguns", 3, "Ranger", ::loadMenu, "Ranger");
		addNewOption("Shotguns", 4, "M1014", ::loadMenu, "M1014");
		addNewOption("Shotguns", 5, "Model 1887", ::loadMenu, "Model 1887");

		addNewMenu("SPAS-12", "Shotguns");
		addNewOption("SPAS-12", 0, "SPAS-12", ::givetest, "h2_spas12_mp");
		addNewOption("SPAS-12", 1, "SPAS-12 Red Dot Sight", ::givetest, "h2_spas12_mp_reflex");
		addNewOption("SPAS-12", 2, "SPAS-12 Silencer", ::givetest, "h2_spas12_mp_silencershotgun");
		addNewOption("SPAS-12", 3, "SPAS-12 Grip", ::givetest, "h2_spas12_grip_mp");
		addNewOption("SPAS-12", 4, "SPAS-12 FMJ", ::givetest, "h2_spas12_mp_fmj");
		addNewOption("SPAS-12", 5, "SPAS-12 Holographic Sight", ::givetest, "h2_spas12_mp_holo");
		addNewOption("SPAS-12", 6, "SPAS-12 Extended Mags", ::givetest, "h2_spas12_mp_xmag");

		addNewMenu("AA-12", "Shotguns");
		addNewOption("AA-12", 0, "AA-12", ::givetest, "h2_aa12_mp");
		addNewOption("AA-12", 1, "AA-12 Red Dot Sight", ::givetest, "h2_aa12_mp_reflex");
		addNewOption("AA-12", 2, "AA-12 Silencer", ::givetest, "h2_aa12_mp_silencershotgun");
		addNewOption("AA-12", 3, "AA-12 Grip", ::givetest, "h2_aa12_grip_mp");
		addNewOption("AA-12", 4, "AA-12 FMJ", ::givetest, "h2_aa12_mp_fmj");
		addNewOption("AA-12", 5, "AA-12 Holographic Sight", ::givetest, "h2_aa12_mp_holo");
		addNewOption("AA-12", 6, "AA-12 Extended Mags", ::givetest, "h2_aa12_mp_xmag");

		addNewMenu("Striker", "Shotguns");
		addNewOption("Striker", 0, "Striker", ::givetest, "h2_striker_mp");
		addNewOption("Striker", 1, "Striker Red Dot Sight", ::givetest, "h2_striker_mp_reflex");
		addNewOption("Striker", 2, "Striker Silencer", ::givetest, "h2_striker_mp_silencershotgun");
		addNewOption("Striker", 3, "Striker Grip", ::givetest, "h2_striker_grip_mp");
		addNewOption("Striker", 4, "Striker FMJ", ::givetest, "h2_striker_mp_fmj");
		addNewOption("Striker", 5, "Striker Holographic Sight", ::givetest, "h2_striker_mp_holo");
		addNewOption("Striker", 6, "Striker Extended Mags", ::givetest, "h2_striker_mp_xmag");

		addNewMenu("Ranger", "Shotguns");
		addNewOption("Ranger", 0, "Ranger", ::givetest, "h2_ranger_mp");
		addNewOption("Ranger", 1, "Ranger Akimbo", ::givetest, "h2_ranger_mp_akimbo");
		addNewOption("Ranger", 2, "Ranger FMJ", ::givetest, "h2_ranger_mp_fmj");

		addNewMenu("M1014", "Shotguns");
		addNewOption("M1014", 0, "M1014", ::givetest, "h2_m1014_mp");
		addNewOption("M1014", 1, "M1014 Red Dot Sight", ::givetest, "h2_m1014_mp_reflex");
		addNewOption("M1014", 2, "M1014 Silencer", ::givetest, "h2_m1014_mp_silencershotgun");
		addNewOption("M1014", 3, "M1014 Grip", ::givetest, "h2_m1014_grip_mp");
		addNewOption("M1014", 4, "M1014 FMJ", ::givetest, "h2_m1014_mp_fmj");
		addNewOption("M1014", 5, "M1014 Holographic Sight", ::givetest, "h2_m1014_mp_holo");
		addNewOption("M1014", 6, "M1014 Extended Mags", ::givetest, "h2_m1014_mp_xmag");

		addNewMenu("Model 1887", "Shotguns");
		addNewOption("Model 1887", 0, "Model 1887", ::givetest, "h2_model1887_mp");
		addNewOption("Model 1887", 1, "Model 1887 Akimbo", ::givetest, "h2_model1887_mp_akimbo");
		addNewOption("Model 1887", 2, "Model 1887 FMJ", ::givetest, "h2_model1887_mp_fmj");
		
		addNewMenu("Handguns", "weapons");
		addNewOption("Handguns", 0, "USP .45", ::loadMenu, "USP .45");
		addNewOption("Handguns", 1, "44 Magnum", ::loadMenu, "44 Magnum");
		addNewOption("Handguns", 2, "M9", ::loadMenu, "M9");
		addNewOption("Handguns", 3, "Desert Eagle", ::loadMenu, "Desert Eagle");
		addNewOption("Handguns", 4, "M1911", ::loadMenu, "M1911");

		addNewMenu("USP .45", "Handguns");
		addNewOption("USP .45", 0, "USP", ::givetest, "h2_usp_mp");
		addNewOption("USP .45", 1, "USP FMJ", ::givetest, "h2_usp_mp_fmj");
		addNewOption("USP .45", 2, "USP Silencer", ::givetest, "h2_usp_mp_silencerpistol");
		addNewOption("USP .45", 3, "USP Akimbo", ::givetest, "h2_usp_mp_akimbo");
		addNewOption("USP .45", 4, "USP Tactical Knife", ::givetest, "h2_usp_tactical_mp");
		addNewOption("USP .45", 5, "USP Extended Mags", ::givetest, "h2_usp_mp_xmag");

		addNewMenu("44 Magnum", "Handguns");
		addNewOption("44 Magnum", 0, "44 Magnum", ::givetest, "h2_coltanaconda_mp");
		addNewOption("44 Magnum", 1, "44 Magnum FMJ", ::givetest, "h2_coltanaconda_mp_fmj");
		addNewOption("44 Magnum", 2, "44 Magnum Akimbo", ::givetest, "h2_coltanaconda_mp_akimbo");
		addNewOption("44 Magnum", 3, "44 Magnum Tactical Knife", ::givetest, "h2_coltanaconda_mp_tacknifecolt44");

		addNewMenu("M9", "Handguns");
		addNewOption("M9", 0, "M9", ::givetest, "h2_m9_mp");
		addNewOption("M9", 1, "M9 FMJ", ::givetest, "h2_m9_mp_fmj");
		addNewOption("M9", 2, "M9 Silencer", ::givetest, "h2_m9_mp_silencerpistol");
		addNewOption("M9", 3, "M9 Akimbo", ::givetest, "h2_m9_mp_akimbo");
		addNewOption("M9", 4, "M9 Tactical Knife", ::givetest, "h2_m9_mp_tacknifem9");
		addNewOption("M9", 5, "M9 Extended Mags", ::givetest, "h2_m9_mp_xmag");

		addNewMenu("M1911", "Handguns");
		addNewOption("M1911", 0, "M1911", ::givetest, "h2_colt45_mp");
		addNewOption("M1911", 1, "M1911 FMJ", ::givetest, "h2_colt45_mp_fmj");
		addNewOption("M1911", 2, "M1911 Silencer", ::givetest, "h2_colt45_mp_silencerpistol");
		addNewOption("M1911", 3, "M1911 Akimbo", ::givetest, "h2_colt45_mp_akimbo");
		addNewOption("M1911", 4, "M1911 Tactical Knife", ::givetest, "h2_colt45_mp_tacknifecolt45");
		addNewOption("M1911", 5, "M1911 Extended Mags", ::givetest, "h2_colt45_mp_xmag");

		addNewMenu("Desert Eagle", "Handguns");
		addNewOption("Desert Eagle", 0, "Desert Eagle", ::givetest, "h2_deserteagle_mp");
		addNewOption("Desert Eagle", 1, "Desert Eagle FMJ", ::givetest, "h2_deserteagle_mp_fmj");
		addNewOption("Desert Eagle", 2, "Desert Eagle Akimbo", ::givetest, "h2_deserteagle_mp_akimbo");
		addNewOption("Desert Eagle", 3, "Desert Eagle Tactical Knife", ::givetest, "h2_deserteagle_mp_tacknifedeagle");
		
		addNewMenu("Launchers", "weapons");
		addNewOption("Launchers", 0, "AT4-HS", ::givetest, "at4_mp");
		addNewOption("Launchers", 1, "Thumper", ::givetest, "h2_m79_mp");
		addNewOption("Launchers", 2, "Stinger", ::givetest, "stinger_mp");
		addNewOption("Launchers", 3, "Javelin", ::givetest, "javelin_mp");
		addNewOption("Launchers", 4, "RPG", ::givetest, "h2_rpg_mp");
		
		addNewMenu("Misc weapons", "weapons");
		addNewOption("Misc weapons", 0, "Hatchet", ::givetest, "h2_hatchet_mp");
		addNewOption("Misc weapons", 1, "Sickle", ::givetest, "h2_sickle_mp");
		addNewOption("Misc weapons", 2, "Shovel", ::givetest, "h2_shovel_mp");
		addNewOption("Misc weapons", 3, "Ice Pick", ::givetest, "h2_icepick_mp");
		addNewOption("Misc weapons", 4, "Karambit", ::givetest, "h2_karambit_mp");
	
	addNewMenu("ks", "main"); //Killstreaks Menu
    addNewOption("ks", 0, "Give ^5UAV", ::streak, "radar_mp"); 
    addNewOption("ks", 1, "Give ^5Carepackage", ::streak, "airdrop_marker_mp");
    addNewOption("ks", 2, "Give ^5Counter-UAV", ::streak, "counter_radar_mp"); 
    addNewOption("ks", 3, "Give ^5Sentry Gun", ::streak, "sentry_mp");
    addNewOption("ks", 4, "Give ^5Predator Missile", ::streak, "predator_mp"); 
    addNewOption("ks", 5, "Give ^5Precision Airstrike", ::streak, "airstrike_mp"); 
	addNewOption("ks", 6, "Give ^5Attack Helicopter", ::streak, "helicopter_mp"); 
    addNewOption("ks", 7, "Give ^5Harrier Strike", ::streak, "harrier_airstrike_mp"); 
	addNewOption("ks", 8, "Give ^5Pavelow", ::streak, "pavelow_mp");
	addNewOption("ks", 9, "Give ^5Emergency Airdrop", ::streak, "airdrop_mega_marker_mp");
    addNewOption("ks", 10, "Give ^5Stealth Bomber", ::streak, "stealth_airstrike_mp"); 
    addNewOption("ks", 11, "Give ^5Chopper Gunner", ::streak, "chopper_gunner_mp"); 
    addNewOption("ks", 12, "Give ^5AC130", ::streak, "ac130_mp"); 
    addNewOption("ks", 13, "Give ^5EMP", ::streak, "emp_mp"); 
    addNewOption("ks", 14, "Give ^5Tactical Nuke", ::streak, "nuke_mp"); 
	
	addNewMenu("bots", "main"); //Bots Menu
	addNewOption("bots", 0, "^1Enemy ^7Bots ^5Menu", ::loadMenu, "enemyBots");
	addNewOption("bots", 1, "^2Friendly ^7Bots ^5Menu", ::loadMenu, "friendlyBots");
	
	addNewMenu("enemyBots", "bots"); 
	addNewOption("enemyBots", 0, "^1Spawn Enemy Bot", ::Spawn_Bot, getOtherTeam(self.team));
	addNewOption("enemyBots", 1, "^1Freeze^7/^2Unfreeze ^1Bots", ::ToggleBotFreeze, "axis");
	addNewOption("enemyBots", 2, "^1Kick All Enemy Bots", ::KickBotsEnemy);
	addNewOption("enemyBots", 3, "^1Enemy Bots to Crosshairs", ::TeleportBotEnemy);
	addNewOption("enemyBots", 4, "^1Enemy Bots to You", ::ToggleBotSpawnEnemy);
	//addNewOption("enemyBots", 5, "^1Toggle Enemy Bots Stance", ::StanceBotsEnemy);
	
	addNewMenu("friendlyBots", "bots"); 
	addNewOption("friendlyBots", 0, "^2Spawn Friendly Bot", ::Spawn_Bot, self.team);
	addNewOption("friendlyBots", 1, "^1Freeze^7/^2Unfreeze Bots", ::ToggleBotFreeze, "allies");
	addNewOption("friendlyBots", 2, "^2Kick All Friendly Bots", ::KickBotsFriendly);
	addNewOption("friendlyBots", 3, "^2Friendly Bots to Crosshairs", ::TeleportBotFriendly);
	addNewOption("friendlyBots", 4, "^2Friendly Bots to You", ::ToggleBotSpawnFriendly);
	//addNewOption("friendlyBots", 4, "^2Toggle Friendly Bots Stance", ::StanceBotsFriendly);
	
	addNewMenu("lobby", "main"); //Lobby Menu
	//addNewOption("lobby", 0, "Map ^5Menu ^1(WIP)", ::loadMenu, "map menu"); //wip
    addNewOption("lobby", 0, "Pause/Resume Timer", ::PauseTimer);
	addNewOption("lobby", 1, "Toggle Pickup Radius", ::pickupradius);
	addNewOption("lobby", 2, "Reset Rounds", ::roundreset);
    addNewOption("lobby", 3, "Fast Restart", ::FastRestart);
	
	/*
	addNewMenu("map menu", "lobby");
	addNewOption("map menu", 0, "^5MW2 ^7(2019)", ::loadMenu, "mw2 2019");
	addNewOption("map menu", 1, "^5MW2^7: Campaign Remastered", ::loadMenu, "mw2cr");
	addNewOption("map menu", 2, "^5MW^7: Remastered", ::loadMenu, "mw2r");

	addNewMenu("mw2 2019", "map menu"); //Map Menu
	addNewOption("mw2 2019", 0, "Afghan", ::changeMap, "mp_afghan");
	addNewOption("mw2 2019", 1, "Derail", ::changeMap, "mp_derail");
	addNewOption("mw2 2019", 2, "Estate", ::changeMap, "mp_estate");
	addNewOption("mw2 2019", 3, "Favela", ::changeMap, "mp_favela");
	addNewOption("mw2 2019", 4, "Highrise", ::changeMap, "mp_highrise");
	addNewOption("mw2 2019", 5, "Invasion", ::changeMap, "mp_invasion");
	addNewOption("mw2 2019", 6, "Karachi", ::changeMap, "mp_checkpoint");
	addNewOption("mw2 2019", 7, "Quarry", ::changeMap, "mp_quarry");
	addNewOption("mw2 2019", 8, "Rundown", ::changeMap, "mp_rundown");
	addNewOption("mw2 2019", 9, "Rust", ::changeMap, "mp_rust");
	addNewOption("mw2 2019", 10, "Scrapyard", ::changeMap, "mp_boneyard");
	addNewOption("mw2 2019", 11, "Skidrow", ::changeMap, "mp_nightshift");
	addNewOption("mw2 2019", 12, "Subbase", ::changeMap, "mp_subbase");
	addNewOption("mw2 2019", 13, "Terminal", ::changeMap, "mp_terminal");
	addNewOption("mw2 2019", 14, "Underpass", ::changeMap, "mp_underpass");
	addNewOption("mw2 2019", 15, "Wasteland", ::changeMap, "mp_brecourt");
	addNewOption("mw2 2019", 16, "Bailout", ::changeMap, "mp_complex");
	addNewOption("mw2 2019", 17, "Crash", ::changeMap, "mp_crash");
	addNewOption("mw2 2019", 18, "Salvage", ::changeMap, "mp_compact");
	addNewOption("mw2 2019", 19, "Overgrown", ::changeMap, "mp_overgrown");
	addNewOption("mw2 2019", 20, "Storm", ::changeMap, "mp_storm");
	addNewOption("mw2 2019", 21, "Carnival", ::changeMap, "mp_abandon");
	addNewOption("mw2 2019", 22, "Fuel", ::changeMap, "mp_fuel2");
	addNewOption("mw2 2019", 23, "Strike", ::changeMap, "mp_strike");
	addNewOption("mw2 2019", 24, "Trailer Park", ::changeMap, "mp_trailerpark");
	addNewOption("mw2 2019", 25, "Vacant", ::changeMap, "mp_vacant");
	
	addNewMenu("mw2cr", "map menu");
	addNewOption("mw2cr", 0, "Airport", ::changeMap, "airport");
	addNewOption("mw2cr", 1, "Blizzard", ::changeMap, "cliffhanger");
	addNewOption("mw2cr", 2, "Contingency", ::changeMap, "contingency");
	addNewOption("mw2cr", 3, "DC Burning", ::changeMap, "dcburning");
	addNewOption("mw2cr", 4, "Dumpsite", ::changeMap, "boneyard");
	addNewOption("mw2cr", 5, "Gulag", ::changeMap, "gulag");
	addNewOption("mw2cr", 6, "Safehouse", ::changeMap, "estate");
	addNewOption("mw2cr", 7, "Whiskey Hotel", ::changeMap, "dc_whitehouse");
	
	addNewMenu("mw2r", "map menu");
	addNewOption("mw2r", 0, "Ambush", ::changeMap, "mp_convoy");
	addNewOption("mw2r", 1, "Backlot", ::changeMap, "mp_backlot");
	addNewOption("mw2r", 2, "Bog", ::changeMap, "mp_bog");
	addNewOption("mw2r", 3, "Crossfire", ::changeMap, "mp_crossfire");
	addNewOption("mw2r", 4, "District", ::changeMap, "mp_district");
	addNewOption("mw2r", 5, "Downpour", ::changeMap, "mp_farm");
	addNewOption("mw2r", 6, "Shipment", ::changeMap, "mp_shipment");
	addNewOption("mw2r", 7, "Vacant", ::changeMap, "mp_vacant");
	addNewOption("mw2r", 8, "Broadcast", ::changeMap, "mp_boardcast");
	addNewOption("mw2r", 9, "Chinatown", ::changeMap, "mp_carentan");
	addNewOption("mw2r", 10, "Countdown", ::changeMap, "mp_countdown");
	addNewOption("mw2r", 11, "Bloc", ::changeMap, "mp_bloc");
	addNewOption("mw2r", 12, "Creek", ::changeMap, "mp_creek");
	addNewOption("mw2r", 13, "Killhouse", ::changeMap, "mp_killhouse");
	addNewOption("mw2r", 14, "Pipeline", ::changeMap, "mp_pipeline");
	addNewOption("mw2r", 15, "Strike", ::changeMap, "mp_strike");
	addNewOption("mw2r", 16, "Showdown", ::changeMap, "mp_showdown");
	addNewOption("mw2r", 17, "Wet Work", ::changeMap, "mp_cargoship");
	addNewOption("mw2r", 18, "Winter Crash", ::changeMap, "mp_crash_snow");
	addNewOption("mw2r", 19, "Day Break", ::changeMap, "mp_farm_spring");
	addNewOption("mw2r", 20, "Beach Bog", ::changeMap, "mp_bog_summer");
	*/
		
	addNewMenu("player", "main"); //Player Menu
	for(i=0;i<level.players.size;i++)
	{
		addNewOption("player", i, level.players[i].name, ::loadMenu, level.players[i].name);
		addNewMenu(level.players[i].name, "player");
		addNewOption(level.players[i].name, 0, "Player to Crosshairs", ::toCross, level.players[i]);
		addNewOption(level.players[i].name, 1, "Player to You", ::toYou, level.players[i]);
		addNewOption(level.players[i].name, 2, "Kick Player", ::toKick, level.players[i]);
		addNewOption(level.players[i].name, 3, "Kill Player", ::toKill, level.players[i]);
		addNewOption(level.players[i].name, 4, "(Un)Freeze Player", ::toFreeze, level.players[i]);
		//addNewOption(level.players[i].name, 4, "Change Player Stance", ::toStance, level.players[i]);
	}
}

buttons()
{
    self endon("disconnect");
    self notifyOnPlayerCommand("menu_open", "+actionslot 1");
    for(;;)
    {
        if(!self.menu.isOpen)
        {
            if(self adsbuttonpressed()) //open
            {
				setDvar( "nightVisionDisableEffects", "1" );
				self waittill("menu_open");
                self thread buildHud();
                self thread doMenuUp(); 
                self thread doMenuDown();
				self thread menu();
                self loadMenu("main");
                self.menu.isOpen = true;
				self freezeControls(false);
                wait .2;
            }
        }
        else
        {
            if(self usebuttonpressed()) //confirm
            {
                self thread [[self.menu.function[self.menu.current][self.scroller]]](self.menu.argument[self.menu.current][self.scroller],self.menu.argument2[self.menu.current][self.scroller],self.menu.argument3[self.menu.current][self.scroller]);
                wait .2;
            }
            if(self meleebuttonpressed()) //back
            {
                if(self.menu.parent[self.menu.current] == "exit")
                {
                    destroyHud();
                    destroyMenuText();
                    self.menu.isOpen = false;
                    self notify("stopmenu_up");
                    self notify("stopmenu_down");
					self notify("stopmenu");
                    wait .1;
					setDvar( "nightVisionDisableEffects", "0" );
                }
                else
                {
                    loadMenu(self.menu.parent[self.menu.current]);
                    wait .1;
                }
            }
        }
        wait .15;
    }
}

watchDeath()
{
    self endon("disconnect");
	if (!isSubStr( self.guid, "bot" ))
	{
		for(;;)
		{
			self waittill("death");
			
			if(self.menu.isOpen)
			{
				destroyHud();
				destroyMenuText();
				self.menu.isOpen = false;
				self notify("stopmenu_up");
				self notify("stopmenu_down");
			}

			wait .1;
		}
	}
}

doMenuUp()
{
    self endon("disconnect");
    self endon("stopmenu_up");

    self notifyOnPlayerCommand("menu_up", "+actionslot 1");
    for(;;)
    {
        self waittill("menu_up");
        self.scroller--;
        self updatescroll();
        wait .1;
    }
}

doMenuDown()
{
    self endon("disconnect");
    self endon("stopmenu_down");

    self notifyOnPlayerCommand("menu_down", "+actionslot 2");
    for(;;)
    {
        
        self waittill("menu_down");
        self.scroller++;
        self updatescroll();
        wait .1;
    }
}

doBinds()
{
	if (!isSubStr( self.guid, "bot" ))
	{
		self thread bindLocations();
		self thread bindUFO();	
		self thread bindTeleportBots();
	}
}

bindLocations() 
{
	self endon("disconnect");
	self endon("endtog"); 
	self endon ("endbinds");
	self notifyOnPlayerCommand("locsave", "+actionslot 2");
	for ( ;; )
	{
		self waittill("locsave");
		if ( self GetStance() == "crouch" )
		{
			self thread doLoadLocation();
		} 
		else if(self GetStance() == "prone" )
		{
			self.locsav = 1;
			self setClientDvar("location_saver", 1);
			self thread doSaveLocation();
		}
		wait 0.01;
	}
}

bindUFO()
{
        self endon("disconnect");
		self endon ("endbinds");
        if(isdefined(self.newufo))
        self.newufo delete();
        self.newufo = spawn("script_origin", self.origin);
        self.UfoOn = 0;
        for(;;)
        {
                if(self meleebuttonpressed() && self GetStance() == "crouch")
                {
                        if(self.UfoOn == 0)
                        {
                                self.UfoOn = 1;
								foreach(player in level.players)
								{
									player setClientDvar("con_gameMsgWindow0MsgTime", "1");
									player iprintln("^1Clip Warning: ^7" + self.name + "^7 is using UFO");
									wait 0.02;
									player setClientDvar("con_gameMsgWindow0MsgTime", "5");
								}
                                self.origweaps = self getWeaponsListOffhands();
                                foreach(weap in self.origweaps)
                                        self takeweapon(weap);
                                self.newufo.origin = self.origin;
                                self playerlinkto(self.newufo);
                        }
                        else
                        {
                                self.UfoOn = 0;
                                self unlink();
                                foreach(weap in self.origweaps)
                                        self giveweapon(weap);
                        }
                        wait 0.05;
                }
                if(self.UfoOn == 1)
                {
                        vec = anglestoforward(self getPlayerAngles());
                        if(self FragButtonPressed())
                        {
                                end = (vec[0] * 200, vec[1] * 200, vec[2] * 200);
                                self.newufo.origin = self.newufo.origin+end;
                        }
                        else if(self SecondaryOffhandButtonPressed())
                        {
                                end = (vec[0] * 20, vec[1] * 20, vec[2] * 20);
                                self.newufo.origin = self.newufo.origin+end;
                        }
                }
                wait 0.05;
        }
}

bindTeleportBots() 
{
	self endon("disconnect");
	self endon("endtog"); 
	self endon ("endbinds");
	self notifyOnPlayerCommand("bottele", "+actionslot 3");
	for ( ;; )
	{
		self waittill("bottele");
		if ( self GetStance() == "crouch" )
		{
			self thread TeleportBotEnemy();
		} 
	}
}