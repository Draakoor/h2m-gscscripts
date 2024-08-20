#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\chinchilla\functions;
#include scripts\mp\chinchilla\joey;

bindinit()
{
    self definePers("nacmod",0);
    self definePers("insta",0);
    self definePers("ccb",0);
    self definepers("ccbint",1);
    self definePers("repeater",0);
    self definePers("canswap",0);
    self definePers("velocity",0);
    self definePers("currentvelo",(0,0,0));
    self definePers("gravity",800);
    self definePers("bolt",0);
    self definePers("boltspeed",1);
    self definePers("boltcount",0);
    self definepers("airspace",false);
    self definepers("instashoot",false);
    self definepers("instashoot_type","Off");
    self definepers("alwayscan",false);
    self definepers("alwayscan_type","Off");
    self definePers("last",false);
    self definePers("last_type","Off");
    self definepers("afterhit","none");
    self definePers("ebtype","Sniper");
    self definePers("ebrange",0);
    self definePers("ebprone",false);
    self definePers("ebtag","none");
    self thread bindwatch();
	self thread swapcheck();
    self thread aimbot_main();
}

definePers(var,value)
{
    if(!isDefined(self.pers[var]))
        self.pers[var] = value;
}

boolToText(bool)
{
	if(bool)
		return "^1On";
	else
		return "^1Off";
}

bindToText(bind)
{
	if(bind)
		return "^1[{+actionslot "+bind+"}]";
	else
		return "^1Off";
}

displayName(weapon)
{
    if(!isDefined(weapon) || weapon == "none")
        return "Unbound";

    if(isSubStr(weapon,"_mp"))
    {
        clean = strTok(weapon,"_");
        return clean[1];
    }
    return weapon;
}

bindToggle(var, splash)
{
    if(self.pers[var])
        self.pers[var] = false;
    else
        self.pers[var] = true;

    self.menutext[self.scroll] setSafeText(splash+" ^1"+boolToText(self.pers[var]));
}

bindCycle(var, splash)
{
    if(self.pers[var] == 4)
        self.pers[var] = 0;
    else
        self.pers[var]++;

    self.menutext[self.scroll] setSafeText(splash+" ^1"+bindToText(self.pers[var]));
}

bindwatch()
{
    self endon("disconnect");
    for(;;)
    {
        command = self waittill_any_return("dpad1", "dpad2", "dpad3", "dpad4");
        if(!isAlive(self))
            continue;

        if(!self.menuopen && isSubStr(command,self.pers["nacmod"]))
            self thread nacmod();

        if(!self.menuopen && isSubStr(command,self.pers["insta"]))
            self thread insta();

        if(!self.menuopen && isSubStr(command,self.pers["ccb"]))
            self thread ccb();

        if(!self.menuopen && isSubStr(command,self.pers["repeater"]))
            self thread repeater();

        if(!self.menuopen && isSubStr(command,self.pers["canswap"]))
            self canswap();

        if(!self.menuopen && isSubStr(command,self.pers["velocity"]))
            self thread runVelocity();

        if(!self.menuopen && isSubStr(command,self.pers["bolt"]))
            self thread dobolt();

        wait 0.1;
    }
}

ebtoggle()
{
    if(toLower(self.pers["ebtype"]) == "sniper")
        self.pers["ebtype"] = self getCurrentWeapon();
    else
        self.pers["ebtype"] = "Sniper";

    self.menutext[self.scroll] setSafeText("EB Type ^1"+displayname(self.pers["ebtype"]));
}

ebrange()
{
    if(self.pers["ebrange"] == 1000)
        self.pers["ebrange"] = 99999;
    else if(self.pers["ebrange"] == 99999)
        self.pers["ebrange"] = 0;
    else
        self.pers["ebrange"] = self.pers["ebrange"] + 100;

    self.menutext[self.scroll] setSafeText("EB Range ^1"+ebtext(self.pers["ebrange"]));
}

ebtext(val)
{
    if(val == 99999)
        return "Everywhere";
    else if(val == 0)
        return "Off";
    else
        return val;
}

hitmarkeb()
{
    if(self.pers["ebtag"] == "none")
        self.pers["ebtag"] = self getCurrentWeapon();
    else
        self.pers["ebtag"] = "none";

    self.menutext[self.scroll] setSafeText("Tag Weapon ^1"+displayname(self.pers["ebtag"]));
}

nacmod()
{
    right = 0;
    left = 0;
    clip = 0;
    stock = 0;
    if(self getCurrentWeapon() ==  self.pers["nacweap1"])
    {
        clip = self getweaponammoclip(self.pers["nacweap1"]);
        stock = self getWeaponAmmoStock(self.pers["nacweap1"]);
        self takeWeapon(self.pers["nacweap1"]);
        self switchToWeapon(self.pers["nacweap2"]);
        wait 0.1;
        self giveWeapon(self.pers["nacweap1"]);
        self setweaponammoclip(self.pers["nacweap1"], clip);
        self setWeaponAmmoStock(self.pers["nacweap1"],stock);
    }
    else if(self getCurrentWeapon() ==  self.pers["nacweap2"])
    {
        clip = self getweaponammoclip(self.pers["nacweap2"]);
        stock = self getWeaponAmmoStock(self.pers["nacweap2"]);
        self takeWeapon(self.pers["nacweap2"]);
        self switchToWeapon(self.pers["nacweap1"]);
        wait 0.1;
        self giveWeapon(self.pers["nacweap2"]);
        self setweaponammoclip(self.pers["nacweap2"], clip);
        self setWeaponAmmoStock(self.pers["nacweap2"],stock);
    }
}

insta()
{

    if(self getCurrentWeapon() ==  self.pers["instaweap1"])
    {
        self setSpawnWeapon(self.pers["instaweap2"]);
    }
    else if(self getCurrentWeapon() ==  self.pers["instaweap2"])
    {
        self setSpawnWeapon(self.pers["instaweap1"]);
    }
}

ccb()
{
    if(self.pers["ccbint"] == 4)
        self.pers["ccbint"] = 1;
    else
        self.pers["ccbint"]++;

    self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],self.pers["ccbint"]);
    self maps\mp\gametypes\_class::applyloadout();
    self maps\mp\gametypes\_hardpoints::giveownedhardpointitem();
}

repeater()
{
    weap = self getCurrentWeapon();
    self setSpawnWeapon(weap);
}

bindnacweap(second)
{
    if(second)
    {
        self.pers["nacweap2"] = self getCurrentWeapon();
        self.menutext[self.scroll] setSafeText("Second Weapon ^1"+displayname(self.pers["nacweap2"]));
    }
    else
    {
        self.pers["nacweap1"] = self getCurrentWeapon();
        self.menutext[self.scroll] setSafeText("First Weapon ^1"+displayname(self.pers["nacweap1"]));
    }
}

bindinstaweap(second)
{
    if(second)
    {
        self.pers["instaweap2"] = self getCurrentWeapon();
        self.menutext[self.scroll] setSafeText("Second Weapon ^1"+displayname(self.pers["instaweap2"]));
    }
    else
    {
        self.pers["instaweap1"] = self getCurrentWeapon();
        self.menutext[self.scroll] setSafeText("First Weapon ^1"+displayname(self.pers["instaweap1"]));
    }
}

toggleLast()
{
    if(!self.pers["last"])
    {
        self.pers["last"] = true;
        self.pers["last_type"] = self getCurrentWeapon();
    }
    else
    {
        self.pers["last"] = false;
        self.pers["last_type"] = "Off";
    }
    self.menutext[self.scroll] setSafeText("Last Bullet ^1"+displayName(self.pers["last_type"]));
}

toggleInsta()
{
    if(!self.pers["instashoot"])
    {
        self.pers["instashoot"] = true;
        self.pers["instashoot_type"] = "Sniper";
    }
    else if(self.pers["instashoot"] && self.pers["instashoot_type"] == "Sniper")
    {
        self.pers["instashoot_type"] = "All";
    }
    else if(self.pers["instashoot"] && self.pers["instashoot_type"] == "All")
    {
        self.pers["instashoot_type"] = self getCurrentWeapon();
    }
    else
    {
        self.pers["instashoot"] = false;
        self.pers["instashoot_type"] = "Off";
    }
    self.menutext[self.scroll] setSafeText("Instashoot ^1"+displayName(self.pers["instashoot_type"]));
}

toggleCan()
{
    if(!self.pers["alwayscan"])
    {
        self.pers["alwayscan"] = true;
        self.pers["alwayscan_type"] = "All";
    }
    else if(self.pers["alwayscan"] && self.pers["alwayscan_type"] == "All")
    {
        self.pers["alwayscan_type"] = self getCurrentWeapon();
    }
    else
    {
        self.pers["alwayscan"] = false;
        self.pers["alwayscan_type"] = "Off";
    }
    self.menutext[self.scroll] setSafeText("Always Canswap ^1"+displayName(self.pers["alwayscan_type"]));
}

swapcheck()
{
    lastweap = undefined;
    self endon("disconnect");
    for(;;)
    {
        self waittill("weapon_change", weapon);
        if(self.pers["instashoot"] && shouldInsta(weapon))
			self setSpawnWeapon(weapon);

        if(self.pers["alwayscan"] && shouldcanswap(weapon))
            self canswapmain(weapon);

        if(self.pers["last"] && weapon == self.pers["last_type"] && self getWeaponAmmoClip(weapon) > 1)
			self setWeaponAmmoClip(weapon, 1);
	}
}

canswapmain(weapon)
{
    if(weapon == "none")
        return;

    list = self GetWeaponsListPrimaries();
    foreach(item in list)
    {
        if(weapon != item)
            self alwayscanswap(item);
    }
}

shouldInsta(weapon)
{
    if(self.pers["instashoot_type"] == "Sniper" && getweaponclass(self getCurrentWeapon()) == "weapon_sniper")
        return true;

    if(self.pers["instashoot_type"] == "All")
        return true;

    if(self.pers["instashoot_type"] == weapon)
        return true;

    return false;
}

shouldcanswap(weapon)
{
    if(self.pers["alwayscan"] && self.pers["alwayscan_type"] == weapon)
        return true;
	
    if(self.pers["alwayscan"] && self.pers["alwayscan_type"] == "All")
        return true;

	return false;
}

canswap()
{
    weapon = self getCurrentWeapon();
    clip = 0;
    left = 0;
    right = 0;
	if(isSubStr(weapon, "akimbo"))
    {
        right = self getWeaponAmmoClip( weapon, "right" );
        left = self getWeaponAmmoClip( weapon, "left" );
    }
    else
        clip = self getWeaponAmmoClip(weapon);

    stock = self getWeaponAmmoStock(weapon);
	self takeWeapon(weapon);
	self giveWeapon(weapon);
	self switchToWeapon(weapon);
    if( isSubStr(weapon, "akimbo" ) )
    {
        self setWeaponAmmoClip(weapon, left, "left" );
        self setWeaponAmmoClip(weapon, right, "right" );
    } 
    else 
        self setWeaponAmmoClip(weapon, clip);

	self setWeaponAmmoStock(weapon, stock);
}

alwayscanswap(weapon)
{
    clip = 0;
    left = 0;
    right = 0;
	if(isSubStr(weapon, "akimbo"))
    {
        right = self getWeaponAmmoClip( weapon, "right" );
        left = self getWeaponAmmoClip( weapon, "left" );
    }
    else
        clip = self getWeaponAmmoClip(weapon);

    stock = self getWeaponAmmoStock(weapon);
	self takeWeapon(weapon);
	self giveWeapon(weapon);
    if( isSubStr(weapon, "akimbo" ) )
    {
        self setWeaponAmmoClip(weapon, left, "left" );
        self setWeaponAmmoClip(weapon, right, "right" );
    } 
    else 
        self setWeaponAmmoClip(weapon, clip);

	self setWeaponAmmoStock(weapon, stock);
}

aimbot_main()
{
	self endon( "disconnect" );
	self endon( "game_ended" );
	for(;;)
	{
		self waittill ("weapon_fired");
		cross = self getcrosshair();
		blood = randomInt(13);  
		if (blood < 11) 
		{
			mod = "MOD_RIFLE_BULLET";
			location = "torso_upper";
		} 
		else
		{
			mod = "MOD_HEAD_SHOT";
			location = "head";	
		}
		foreach(player in level.players)
		{
			if(self isvalidenemy(player) && distance(player.origin, cross) < self.pers["ebrange"] && self goodweap())
			{
				player thread [[level.callbackPlayerDamage]] ( self, self, 2000000, 8, mod, self getcurrentweapon(), ( 0, 0, 0 ), ( 0, 0, 0 ), location, 0, 0 );
                if(self.pers["ebprone"])
                    self setstance("prone");

                break;
			}
		}
        if(self getCurrentWeapon() == self.pers["ebtag"] && self.pers["ebtag"] != "none")
            self thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback(" ");

		wait 0.05;
	}
}

getcrosshair()
{
	forward = self getTagOrigin("tag_eye");
	end = vector_scale(anglestoforward(self getPlayerAngles()), 1000000);
	cross = BulletTrace( forward, end, false, self )["position"];
	return cross;
}

vector_scale(vector, scale)
{
	return(vector[0] * scale, vector[1] * scale, vector[2] * scale);
}

goodweap()
{
	if(ToLower(self.pers["ebtype"]) == "sniper")
	{
		if(getweaponclass(self getCurrentWeapon()) == "weapon_sniper")
			return true;
        else
		    return false;
	}
	else
	{
		if(self.pers["ebtype"] == self getCurrentWeapon())
			return true;
		else
    		return false;
	}
}

isvalidenemy(player)
{
	if(isAlive(player) && player != self )
	{
		if(level.teamBased && player.team != self.team)
			return true;
		else if(!level.teambased)
			return true;
		else
            return false;
	}
	return false;
}

savebolt()
{
    self.pers["boltcount"]++;
    self.pers["boltorigin"+self.pers["boltcount"]] = self GetOrigin();
    self iPrintLn("Position ^1" + self.pers["boltcount"] + " ^7Saved ^1" + self.origin );
}

deletebolt()
{
    if (self.pers["boltcount"] == 0)
    {
        self iPrintLn("^1Error ^7No Points To Remove");
        return;
    }
    self iPrintLn("Position ^1" + self.pers["boltcount"] + " ^7Removed");
    self.pers["boltorigin"+self.pers["boltcount"]] = undefined;
    self.pers["boltcount"]--;
}

cyclespeed()
{
    if(self.pers["boltspeed"] == 5)
        self.pers["boltspeed"] = 0.25;
    else
        self.pers["boltspeed"] = self.pers["boltspeed"] + 0.25;

    self.menutext[self.scroll] setSafeText("Speed ^1"+self.pers["boltspeed"]);
}

dobolt()
{
    if (self.pers["boltcount"] == 0)
    {
        self iPrintLn("^1Error ^7No Points");
        return;
    }

    boltModel = spawn("script_model", self.origin); 
	boltModel.origin = self.origin; 
    self playerLinkTo( boltModel );

    for (i=1 ; i < self.pers["boltcount"] + 1 ; i++)
    {
        boltModel MoveTo( self.pers["boltorigin"+i],  self.pers["boltspeed"] / self.pers["boltcount"], 0, 0 );
        wait ( self.pers["boltspeed"] / self.pers["boltcount"] );
    }

    self Unlink();
    boltModel delete();
}

editVelocity(axis, up)
{
    current = undefined;
    if(axis == "x")
    {
        if(up)
            current = self.pers["currentvelo"] + (10,0,0);
        else
            current = self.pers["currentvelo"] - (10,0,0);
    }
    else if(axis == "y")
    {
        if(up)
            current = self.pers["currentvelo"] + (0,10,0);
        else
            current = self.pers["currentvelo"] - (0,10,0);
    }
    else if(axis == "z")
    {
        if(up)
            current = self.pers["currentvelo"] + (0,0,10);
        else
            current = self.pers["currentvelo"] - (0,0,10);
    }
    self.pers["currentvelo"] = current;
    self.menutext[1] setSafeText("Current ^1"+self.pers["currentvelo"]);
}

runVelocity()
{
    self setVelocity(self.pers["currentvelo"]);
}
