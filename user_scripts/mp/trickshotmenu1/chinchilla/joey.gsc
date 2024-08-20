#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\chinchilla\functions;
#include scripts\mp\chinchilla\binds;

menuInit()
{
	if(!isDefined(level.anchorText))
	{
		level.stringCount = 0;
	    level.anchorText = createServerFontString("objective",1.5);
	    level.anchorText setText("anchor");
	    level.anchorText.alpha = 0;
	    level thread monitorOverflow();
	}

    self.scroll = 0;
    self.menuopen = false;
    self.current = undefined;
    self.menus = [];
    self.backmenus = [];
    self thread menuControls();
}

loadMenus()
{
	if(self == level.player)
	{
		self addOption("Fuck Activision", 0, "Main Menu", ::newMenu, "Main Menu");
		self addOption("Fuck Activision", 1, "Game Options", ::newMenu, "Game Options");
		self addOption("Fuck Activision", 2, "Binds", ::newMenu, "Binds");
		self addOption("Fuck Activision", 3, "Glitches", ::newMenu, "Glitches");
		self addOption("Fuck Activision", 4, "Weapons", ::newMenu, "Weapons");
		self addOption("Fuck Activision", 5, "Killstreaks", ::newMenu, "Killstreaks");
		self addOption("Fuck Activision", 6, "EB Settings", ::newMenu, "EB Settings");
		self addOption("Fuck Activision", 7, "Clients", ::newMenu, "Clients");
	}
	else
	{
		self addOption("Fuck Activision", 0, "Main Menu", ::newMenu, "Main Menu");
		self addOption("Fuck Activision", 1, "Binds", ::newMenu, "Binds");
		self addOption("Fuck Activision", 2, "Glitches", ::newMenu, "Glitches");
		self addOption("Fuck Activision", 3, "Weapons", ::newMenu, "Weapons");
		self addOption("Fuck Activision", 4, "Killstreaks", ::newMenu, "Killstreaks");
		self addOption("Fuck Activision", 5, "EB Settings", ::newMenu, "EB Settings");
	}
	
	self.backmenu["Main Menu"] = "Fuck Activision";
    self addOption("Main Menu", 0, "Spawn Bot", ::addmfbot, getotherteam(self.team));
	self addOption("Main Menu", 1, "Save Bot Spawn", ::savebotdefault);
	self addOption("Main Menu", 2, "Take Weapon", ::takeDaGun);
	self addOption("Main Menu", 3, "Drop Weapon", ::dropDaGun);
    self addOption("Main Menu", 4, "EB Range ^1"+ebtext(self.pers["ebrange"]), ::ebrange);
	self addOption("Main Menu", 5, "UFO Bind ^1"+boolToText(self.pers["ufobind"]), ::bindToggle, "ufobind", "UFO Bind");
    self addOption("Main Menu", 6, "God Mode ON", ::enableGodMode);
	self addOption("Main Menu", 7, "God Mode OFF", ::disableGodMode);

	self.backmenu["Game Options"] = "Fuck Activision";
	self addOption("Game Options", 0, "Fast Last", ::autoLast);
	self addOption("Game Options", 1, "Timescale ^1"+getDvar("timescale"), ::slomoTog);
	self addOption("Game Options", 2, "Gravity ^1"+ getDvarInt("g_gravity"), ::gravCycle);
	self addOption("Game Options", 3, "Fast Restart", ::fastRestart);
	self addOption("Game Options", 4, "Spawn Friendly Bot", ::addmfbot, self.team);
	self addOption("Game Options", 5, "Kick All Bots", ::KickAllBots);
	self addOption("Game Options", 6, "Reset Rounds", ::resetDaRounds);

	self.backmenu["Binds"] = "Fuck Activision";
	self addOption("Binds", 0, "Class Change "+bindToText(self.pers["ccb"]), ::bindCycle, "ccb", "Class Change");
	self addOption("Binds", 1, "Canswap "+bindToText(self.pers["canswap"]), ::bindCycle, "canswap", "Canswap");
	self addOption("Binds", 2, "Nac Mod "+bindToText(self.pers["nacmod"]), ::newMenu, "Nac Mod");
	self addOption("Binds", 3, "Instaswap "+bindToText(self.pers["insta"]), ::newMenu, "Instaswap");
	self addOption("Binds", 4, "Velocity "+bindToText(self.pers["velocity"]), ::newMenu, "Velocity");
	self addOption("Binds", 5, "Repeater "+bindToText(self.pers["repeater"]), ::bindCycle, "repeater", "Repeater");
	self addOption("Binds", 6, "Bolt Movement "+bindToText(self.pers["bolt"]), ::newMenu, "Bolt Movement");

	self.backmenu["Bolt Movement"] = "Binds";
	self addOption("Bolt Movement", 0, "Bind "+bindToText(self.pers["bolt"]), ::bindCycle, "bolt", "Bind");
	self addOption("Bolt Movement", 1, "Speed ^1"+self.pers["boltspeed"], ::cycleSpeed);
	self addOption("Bolt Movement", 2, "Save", ::saveBolt);
	self addOption("Bolt Movement", 3, "Delete", ::deleteBolt);

	self.backmenu["Nac Mod"] = "Binds";
	self addOption("Nac Mod", 0, "Bind "+bindToText(self.pers["nacmod"]), ::bindCycle, "nacmod", "Bind");
	self addOption("Nac Mod", 1, "First Weapon ^1"+displayName(self.pers["nacweap1"]), ::bindnacweap, false);
	self addOption("Nac Mod", 2, "Second Weapon ^1"+displayName(self.pers["nacweap2"]), ::bindnacweap, true);

	self.backmenu["Instaswap"] = "Binds";
	self addOption("Instaswap", 0, "Bind "+bindToText(self.pers["insta"]), ::bindCycle, "insta", "Bind");
	self addOption("Instaswap", 1, "First Weapon ^1"+displayName(self.pers["instaweap1"]), ::bindinstaweap, false);
	self addOption("Instaswap", 2, "Second Weapon ^1"+displayName(self.pers["instaweap2"]), ::bindinstaweap, true);
	
	self.backmenu["Glitches"] = "Fuck Activision";
	self addOption("Glitches", 0, "Airspace Full ^1" + boolToText(self.pers["airspace"]), ::bindToggle, "airspace", "Airspace Full");
	self addOption("Glitches", 1, "Always Canswap ^1"+displayName(self.pers["alwayscan_type"]), ::toggleCan);
	self addOption("Glitches", 2, "Instashoot ^1" + displayName(self.pers["instashoot_type"]), ::toggleInsta);
	self addOption("Glitches", 3, "Last Bullet ^1"+displayName(self.pers["last_type"]), ::toggleLast);

	self.backmenu["EB Settings"] = "Fuck Activision";
	self addOption("EB Settings", 0, "EB Range ^1"+ebtext(self.pers["ebrange"]), ::ebrange);
	self addOption("EB Settings", 1, "Auto Prone ^1"+boolToText(self.pers["ebprone"]), ::bindToggle, "ebprone", "Auto Prone");
	self addOption("EB Settings", 2, "EB Type ^1"+displayName(self.pers["ebtype"]), ::ebtoggle);
	self addOption("EB Settings", 3, "Tag Weapon ^1"+displayName(self.pers["ebtag"]), ::hitmarkeb);

	self.backmenu["Velocity"] = "Binds";
	self addOption("Velocity", 0, "Bind "+bindToText(self.pers["velocity"]), ::bindCycle, "velocity", "Bind");
	self addOption("Velocity", 1, "Current ^1"+self.pers["currentvelo"], undefined);
	self addOption("Velocity", 2, "Play Velocity", ::runVelocity);
	self addOption("Velocity", 3, "Increase X", ::editVelocity, "x", true);
	self addOption("Velocity", 4, "Decrease X", ::editVelocity, "x", false);
	self addOption("Velocity", 5, "Increase Y", ::editVelocity, "y", true);
	self addOption("Velocity", 6, "Decrease Y", ::editVelocity, "y", false);
	self addOption("Velocity", 7, "Increase Z", ::editVelocity, "z", true);
	self addOption("Velocity", 8, "Decrease Z", ::editVelocity, "z", false);

	self.backmenu["Weapons"] = "Fuck Activision";
	self addOption("Weapons", 0, "Assault Rifles", ::newMenu, "Assault Rifles");
	self addOption("Weapons", 1, "Submachine Guns", ::newMenu, "Submachine Guns");
	self addOption("Weapons", 2, "Lightmachine Guns", ::newMenu, "Lightmachine Guns");
	self addOption("Weapons", 3, "Sniper Rifles", ::newMenu, "Sniper Rifles");
	self addOption("Weapons", 4, "Machine Pistols", ::newMenu, "Machine Pistols");
	self addOption("Weapons", 5, "Shotguns", ::newMenu, "Shotguns");
	self addOption("Weapons", 6, "Handguns", ::newMenu, "Handguns");
	self addOption("Weapons", 7, "Launchers", ::newMenu, "Launchers");
	self addOption("Weapons", 8, "Other", ::newMenu, "Other");

	self.backmenu["Assault Rifles"] = "Weapons";
	self addOption("Assault Rifles", 0, "M4A1", ::giveWeapon_wrapper, "m4a1_mp");
	self addOption("Assault Rifles", 1, "FAMAS", ::giveWeapon_wrapper, "famas_mp");
	self addOption("Assault Rifles", 2, "SCAR-H", ::giveWeapon_wrapper, "scar_mp");
	self addOption("Assault Rifles", 3, "TAR-21", ::giveWeapon_wrapper, "tavor_mp");
	self addOption("Assault Rifles", 4, "FAL", ::giveWeapon_wrapper, "fal_mp");
	self addOption("Assault Rifles", 5, "M16A4", ::giveWeapon_wrapper, "m16_mp");
	self addOption("Assault Rifles", 6, "ACR", ::giveWeapon_wrapper, "masada_mp");
	self addOption("Assault Rifles", 7, "F2000", ::giveWeapon_wrapper, "fn2000_mp");
	self addOption("Assault Rifles", 8, "AK47", ::giveWeapon_wrapper, "ak47_mp");
	
	self.backmenu["Submachine Guns"] = "Weapons";
	self addOption("Submachine Guns", 0, "MP5K", ::giveWeapon_wrapper, "mp5k_mp");
	self addOption("Submachine Guns", 1, "UMP45", ::giveWeapon_wrapper, "ump45_mp");
	self addOption("Submachine Guns", 2, "Vector", ::giveWeapon_wrapper, "kriss_mp");
	self addOption("Submachine Guns", 3, "P90", ::giveWeapon_wrapper, "p90_mp");
	self addOption("Submachine Guns", 4, "Mini-Uzi", ::giveWeapon_wrapper, "uzi_mp");
	
	self.backmenu["Lightmachine Guns"] = "Weapons";
	self addOption("Lightmachine Guns", 0, "L86 LSW", ::giveWeapon_wrapper, "sa80_mp");
	self addOption("Lightmachine Guns", 1, "RPD", ::giveWeapon_wrapper, "rpd_mp");
	self addOption("Lightmachine Guns", 2, "MG4", ::giveWeapon_wrapper, "mg4_mp");
	self addOption("Lightmachine Guns", 3, "AUG HBAR", ::giveWeapon_wrapper, "aug_mp");
	self addOption("Lightmachine Guns", 4, "M240", ::giveWeapon_wrapper, "m240_mp");
	
	self.backmenu["Sniper Rifles"] = "Weapons";
	self addOption("Sniper Rifles", 0, "Intervention", ::giveWeapon_wrapper, "cheytac_mp");
	self addOption("Sniper Rifles", 1, "Barrett .50cal", ::giveWeapon_wrapper, "barrett_mp");
	self addOption("Sniper Rifles", 2, "WA2000", ::giveWeapon_wrapper, "wa2000_mp");
	self addOption("Sniper Rifles", 3, "M21 EBR", ::giveWeapon_wrapper, "m21_mp");

	self.backmenu["Machine Pistols"] = "Weapons";
	self addOption("Machine Pistols", 0, "PP2000", ::giveWeapon_wrapper, "pp2000_mp");
	self addOption("Machine Pistols", 1, "G18", ::giveWeapon_wrapper, "glock_mp");
	self addOption("Machine Pistols", 2, "M93 Raffica", ::giveWeapon_wrapper, "beretta393_mp");
	self addOption("Machine Pistols", 3, "TMP", ::giveWeapon_wrapper, "tmp_mp");
	
	self.backmenu["Shotguns"] = "Weapons";
	self addOption("Shotguns", 0, "SPAS-12", ::giveWeapon_wrapper, "spas12_mp");
	self addOption("Shotguns", 1, "AA-12", ::giveWeapon_wrapper, "aa12_mp");
	self addOption("Shotguns", 2, "Striker", ::giveWeapon_wrapper, "striker_mp");
	self addOption("Shotguns", 3, "Ranger", ::giveWeapon_wrapper, "ranger_mp");
	self addOption("Shotguns", 4, "M1014", ::giveWeapon_wrapper, "m1014_mp");
	self addOption("Shotguns", 5, "Model 1887", ::giveWeapon_wrapper, "model1887_mp");
	
	self.backmenu["Handguns"] = "Weapons";
	self addOption("Handguns", 0, "USP", ::giveWeapon_wrapper, "usp_mp");
	self addOption("Handguns", 1, "44 Magnum", ::giveWeapon_wrapper, "coltanaconda_mp");
	self addOption("Handguns", 2, "M9", ::giveWeapon_wrapper, "beretta_mp");
	self addOption("Handguns", 3, "Desert Eagle", ::giveWeapon_wrapper, "deserteagle_mp");
	self addOption("Handguns", 4, "Gold Desert Eagle", ::giveWeapon_wrapper, "deserteaglegold_mp");
	
	self.backmenu["Launchers"] = "Weapons";
	self addOption("Launchers", 0, "AT4-HS", ::giveWeapon_wrapper, "at4_mp");
	self addOption("Launchers", 1, "Thumper", ::giveWeapon_wrapper, "m79_mp");
	self addOption("Launchers", 2, "Stinger", ::giveWeapon_wrapper, "stinger_mp");
	self addOption("Launchers", 3, "Javelin", ::giveWeapon_wrapper, "javelin_mp");
	self addOption("Launchers", 4, "RPG", ::giveWeapon_wrapper, "rpg_mp");
	
	self.backmenu["Other"] = "Weapons";
	self addOption("Other", 0, "Riot Shield", ::giveWeapon_wrapper, "riotshield_mp");
	self addOption("Other", 1, "Laptop", ::giveWeapon_wrapper, "killstreak_predator_missile_mp");
	self addOption("Other", 2, "C4 Detonator", ::giveWeapon_wrapper, "c4_mp");
	self addOption("Other", 3, "Bomb", ::giveWeapon_wrapper, "briefcase_bomb_defuse_mp");
	self addOption("Other", 4, "OMA Bag", ::giveWeapon_wrapper, "onemanarmy_mp");

	self.backmenu["Killstreaks"] = "Fuck Activision";
	self addOption("Killstreaks", 0, "UAV", ::giveStreak, "radar_mp");
    self addOption("Killstreaks", 1, "Care Package", ::giveStreak, "airdrop_marker_mp");
    self addOption("Killstreaks", 2, "Counter-UAV", ::giveStreak, "counter_radar_mp");
    self addOption("Killstreaks", 3, "Sentry Gun", ::giveStreak, "sentry_mp");
    self addOption("Killstreaks", 4, "Predator Missile", ::giveStreak, "predator_mp");
    self addOption("Killstreaks", 5, "Precision Airstrike", ::giveStreak, "airstrike_mp");
    self addOption("Killstreaks", 6, "Harrier Strike", ::giveStreak, "harrier_airstrike_mp");
    self addOption("Killstreaks", 7, "Attack Helicopter", ::giveStreak, "helicopter_mp");
    self addOption("Killstreaks", 8, "Emergency Airdrop", ::giveStreak, "airdrop_mega_marker");
    self addOption("Killstreaks", 9, "Pave Low", ::giveStreak, "pavelow_mp");
    self addOption("Killstreaks", 10, "Stealth Bomber", ::giveStreak, "stealth_airstrike_mp");
    self addOption("Killstreaks", 11, "Chopper Gunner", ::giveStreak, "chopper_gunner");
    self addOption("Killstreaks", 12, "AC130", ::giveStreak, "ac130_mp");
    self addOption("Killstreaks", 13, "EMP", ::giveStreak, "emp_mp");
    self addOption("Killstreaks", 14, "Tactical Nuke", ::giveStreak, "nuke_mp");

	self.backmenu["Clients"] = "Fuck Activision";
	for(i=0;i<level.players.size;i++)
	{
		self addOption("Clients", i, "^1[" + level.players[i].team + "]^7 " + level.players[i].name, ::newMenu, level.players[i].name);

		self.backmenu[level.players[i].name] = "Clients";
		self addOption(level.players[i].name, 0, "Save to Crosshairs", ::savebotspawn, level.players[i]);
		self addOption(level.players[i].name, 1, "Kick Player", ::kickPlayer, level.players[i]);
		self addOption(level.players[i].name, 2, "Kill Player", ::killPlayer, level.players[i]);
		self addOption(level.players[i].name, 3, "GUID ^1"+level.players[i] getguid(), undefined);
	}
}

menuControls()
{
    self endon("disconnect");
    for(;;)
    {
		command = self waittill_any_return("dpad1", "dpad2", "usereload", "knife");
		if(!isAlive(self))
		{
			if(self.menuopen)
				self thread menuClose();
	
			continue;
		}
        if(!self.menuopen && command == "dpad1" && self adsButtonPressed())
            self thread menuOpen();
        if(self.menuopen && command == "dpad1")
            self thread scrollMenu("up");
        if(self.menuopen && command == "dpad2" && !self adsButtonPressed())
            self thread scrollMenu("down");
        if(self.menuopen && command == "usereload")
            self thread selectMenu();
        if(self.menuopen && command == "knife")
            self thread backmenu();

        wait 0.05;
    }
}

menuOpen()
{
	self setactionslot( 1, " " );
	self freezeControls(false);
    self.menuopen = true;
    self.bg = self createRectangle("icon", 0, -80, "center", "top", "center", "middle", (0, 0, 0), 0.8, "white", 180, 1, -1);
    self.top = self createRectangle("icon", 0, -80, "center", "top", "center", "middle", (1, 0, 0), 1, "white", 180, 2, 1);
    self.bottom = self createRectangle("icon", 0, -80, "center", "top", "center", "middle", (1, 0, 0), 1, "white", 180, 2, 1);
    self.left = self createRectangle("icon", 90, -80, "center", "top", "center", "middle", (1, 0, 0), 0.8, "white", 2, 1, 1);
    self.right = self createRectangle("icon", -90, -80, "center", "top", "center", "middle", (1, 0, 0), 0.8, "white", 2, 1, 1);
    self.title = self createText("objective", 1.7, "center", "center", 0, -65, 2, (1,0,0), 0, "Fuck Activision");
    self.title affectElement("alpha",0.2,1);
    self.current = "Fuck Activision";
	if(!isDefined(self.lastscroll[self.current]))
        self.scroll = 0;
    else
        self.scroll = self.lastscroll[self.current];
		
	self thread loadMenus();
    for(i=0;i<self.menus[self.current].size;i++)
    {
        self.menutext[i] = self createText("objective", 1.4, "LEFT", "CENTER", -80, -45 + i * 15, 2, (1,1,1), 0, self.menus[self.current][i].text);
        self.menutext[i] affectElement("alpha",0.2,1);
    }
    self thread updateScroll();
    self thread updateBase();
}

menuClose()
{
	self.lastscroll[self.current] = self.scroll;
    self.scroll = 0;
    self.menuopen = false;
    self.current = undefined;
    self.title affectElement("alpha",0.2,0);
    self.bg scaleOverTime(0.2,180,1);
    self.left scaleOverTime(0.2,2,1);
    self.right scaleOverTime(0.2,2,1);
    self.bottom affectElement("y",0.2,-80);
    foreach(text in self.menutext)
    {
        text affectElement("alpha",0.2,0);
    }
    wait 0.25;
    self.title destroy();
    self.bg destroy();
    self.top destroy();
    self.bottom destroy();
    self.left destroy();
    self.right destroy();
    foreach(text in self.menutext)
    {
        text destroy();
    }
}

scrollMenu(direction)
{
    max = self.menus[self.current].size - 1;
    if(direction == "down")
    {
        if(self.scroll == max)
            self.scroll = 0;
        else
            self.scroll++;
    }
    else if(direction == "up")
    {
        if(self.scroll == 0)
            self.scroll = max;
        else
            self.scroll--;
    }
    self thread updateScroll();
}

backmenu()
{
    if(!isDefined(self.backmenu[self.current]))
        self thread menuClose();
    else
        self thread newMenu(self.backmenu[self.current]);
}

selectMenu()
{
    func = self.menus[self.current][self.scroll].func;
    arg1 = self.menus[self.current][self.scroll].arg1;
    arg2 = self.menus[self.current][self.scroll].arg2;
    if(!isDefined(arg1))
        self thread [[func]]();
    if(isDefined(arg1) && !isDefined(arg2))
        self thread [[func]](arg1);
    if(isDefined(arg1) && isDefined(arg2))
        self thread [[func]](arg1, arg2);
}

addOption(menu, index, text, func, arg1, arg2)
{
    if(!isDefined(self.menus[menu]))
        self.menus[menu] = [];

    self.menus[menu][index] = spawnStruct();
    self.menus[menu][index].text = text;
    self.menus[menu][index].func = func;
    if(isDefined(arg1))
        self.menus[menu][index].arg1 = arg1;
    if(isDefined(arg2))
        self.menus[menu][index].arg2 = arg2;
}

newMenu(menu, fade)
{
    foreach(text in self.menutext)
    {
        text destroy();
    }
	self thread loadMenus();
    self.lastscroll[self.current] = self.scroll;
    if(!isDefined(self.lastscroll[menu]))
        self.scroll = 0;
    else
        self.scroll = self.lastscroll[menu];

    self.current = menu;
    self.title setSafeText(menu);
    for(i=0;i<self.menus[menu].size;i++)
    {
        self.menutext[i] = self createText("objective", 1.4, "LEFT", "CENTER", -80, -45 + i * 15, 2, (1,1,1), 1, self.menus[menu][i].text);
    }
    self thread updateScroll();
    self thread updateBase();
}

updateScroll()
{
    foreach(option in self.menutext)
    {
        option.color = (1,1,1);
    }
    self.menutext[self.scroll].color = (1,0,0);
}

updateBase()
{
	self.bg scaleOverTime(0.2,180,32 + (self.menus[self.current].size * 15));
	self.left scaleOverTime(0.2,2,32 + (self.menus[self.current].size * 15));
	self.right scaleOverTime(0.2,2,32 + (self.menus[self.current].size * 15));
	self.bottom affectElement("y",0.2,-49 + (self.menus[self.current].size * 15));
}
 
createText(font, fontscale, align, relative, x, y, sort, color, alpha, text) 
{
    elem = createFontString(font, fontscale);
    elem setPoint(align, relative, x, y);
    elem.archived = false;
    elem.hidewheninmenu = true;
    elem.sort = sort;
    elem.alpha = alpha;
    elem.color = color;
    elem.type = "text";
    elem setSafeText(text);
    return elem;
}

createRectangle(type, x, y, alignx, aligny, horzalign, vertalign, color, alpha, material, matwidth, matlength, sort)
{
	elem = newclienthudelem(self);
    elem.elemType = type;
    elem.x = x;
    elem.y = y;
    elem.alignx = alignx;
    elem.aligny = aligny;
    elem.horzalign = horzalign;
    elem.vertalign = vertalign;
    elem.color = color;
    elem.alpha = alpha;
    elem.sort = sort;
	elem.archived = false;
    elem.shader = material;
    elem setshader(material, matwidth, matlength);
    elem.hidewheninmenu = true;
    return elem;
}

affectElement(type, time, value)
{
	if (type == "x" || type == "y")
		self moveOverTime(time);
	else
		self fadeOverTime(time);
	if (type == "x")
		self.x = value;
	if (type == "y")
		self.y = value;
	if (type == "alpha")
		self.alpha = value;
	if (type == "color")
		self.color = value;
}

monitorOverflow()
{
    level endon("disconnect");
    for(;;)
    {
        level waittill("overflow");
        level.anchorText clearAllTextAfterHudElem();
        level.stringCount = 0;
		wait 0.05;
        foreach(player in level.players)
        {
            player recreateText();
        }
        wait 0.05;
    }
}
 
setSafeText(text)
{
    level.stringCount++;
    if(level.stringCount >= 60)
    {
        level notify("overflow");
        return;
    }
    else
        self setText(text);
}
 
enableGodMode()
{
    self.health = 999999; // Set an extremely high health value (effectively infinite)
    self.maxHealth = 999999; // Ensure max health is also very high
    
    // Optionally, flag the player as invincible to prevent damage from being applied
    self.isGodMode = true; // A custom flag to track God Mode state
}

disableGodMode()
{
    self.health = 100; // Set back to normal health
    self.maxHealth = 100; // Set back to default max health
    self.isGodMode = false; // Disable the God Mode flag
}

recreateText()
{
    if(isDefined(self.menuopen) && self.menuopen)
	{
		self.title setSafeText(self.current);
		for(i=0;i<self.menus[self.current].size;i++)
		{
			self.menutext[i] setSafeText(self.menus[self.current][i].text);
		}
	}
}