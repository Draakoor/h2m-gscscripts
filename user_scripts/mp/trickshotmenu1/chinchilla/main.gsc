#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\chinchilla\functions;
#include scripts\mp\chinchilla\joey;
#include scripts\mp\chinchilla\binds;

init()
{
	setDvar("scr_sd_timelimit", 0);
	setDvar("scr_sd_roundswitch", 3);
	setDvar("jump_slowdownenable",0);
	setDvar("nightVisionDisableEffects", 1);
	setDvar("timescale", 1);
    SetDvarIfNotInizialized("botdefault", "none");
	setDvar("pm_bouncing", 1);
	setDvar("pm_bouncingAllAngles", 1);
    level thread onConnect();
    level thread randomround();
    level.onkillscore = level.onplayerkilled;
    level.onplayerkilled = ::onplayerkilled;
    setDvar("sv_cheats", 1);
	level.onOneLeftEvent = undefined;
	level.OriginalCallbackPlayerDamage = level.callbackPlayerDamage;
    level.callbackPlayerDamage = ::CodeCallback_PlayerDamage;

	level.botcount = 0;
	level.botnames[0] = "Fuck Activision";
	level.botnames[1] = "Activision KYS";
	level.botnames[2] = "I H8 Activision";
	level.botnames[3] = "Get Cancer Activision";

	replaceFunc(maps\mp\h2_killstreaks\_airdrop::tryUseAirdrop, ::tryUseAirdrop_stub);

	wait 1;

	level.numkills = 1;
	level.rankedmatch = 0;
    level.allowlatecomers = 1;
    level.graceperiod = 0;
    level.ingraceperiod = 0;
    level.prematchperiod = 0;
    level.waitingforplayers = 0;
    level.prematchperiodend = 0;
}

isSniper( weapon )
{
    return ( 
            isSubstr( weapon, "h2_cheytac") 
        ||  isSubstr( weapon, "h2_barrett" ) 
        ||  isSubstr( weapon, "h2_wa2000" ) 
        ||  isSubstr( weapon, "h2_m21" ) 
        ||  isSubstr( weapon, "h2_m40a3" ) 
        //||  isSubstr( weapon, "h1_febsnp" )
        //||  isSubstr( weapon, "h1_junsnp" )
    );
}

CodeCallback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
      self endon("disconnect");
    if(sMeansOfDeath == "MOD_TRIGGER_HURT" || sMeansOfDeath == "MOD_HIT_BY_OBJECT" || sMeansOfDeath == "MOD_MELEE")
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


onConnect()
{
	level endon("disconnect");
    for(;;)
	{
		level waittill("connected", player);
		if(!isSubStr(player.guid, "bot"))
		{
			player thread playerLoop();
			player thread playerSpawn();
			player thread menuInit();
			player thread coreInit();
			player thread bindInit();
			player notifyOnPlayerCommand("dpad1", "+actionslot 1");
			player notifyOnPlayerCommand("dpad2", "+actionslot 2");
			player notifyOnPlayerCommand("dpad3", "+actionslot 3");
			player notifyOnPlayerCommand("dpad4", "+actionslot 4");
			player notifyOnPlayerCommand("knife", "+melee");
			player notifyOnPlayerCommand("knife", "+melee_zoom");
			player notifyOnPlayerCommand("usereload", "+usereload");
			player notifyOnPlayerCommand("usereload", "+reload");
			if(player == level.player)
				player thread hostStuff();
		}
		else
		{
			player thread botSpawn();
			player thread botLoop();
		}
    }
}

playerSpawn()
{
	self endon("disconnect");	
	for(;;)
	{
		self waittill("spawned_player");
		self freezeControls(false);
		self thread loadPos();
		if(!isDefined(self.pers["first"]))
		{
			self.pers["first"] = true;
			self iPrintLn("Press [{+speed_throw}] and [{+actionslot 1}] to open");
			self iPrintLn("Fuck Activision by ^1joey +  Fixes by ^1Drex");
		}
	}
}

playerLoop()
{
	self endon("disconnect");	
	for(;;)
	{
		self SetMoveSpeedScale( 1 );
        self setPerk("specialty_unlimitedsprint");
		wait 0.1;
	}
}

botSpawn()
{
	self endon( "disconnect" );	
	for(;;)
	{
		self waittill("spawned_player");
		self thread botLoad();
	}
}

botloop()
{
	self endon("disconnect");	
	for(;;)
	{
		self freezeControls(false);
		wait 0.1;
	}
}

hostStuff()
{
	if(!isDefined(self.pers["tscale"]))
		self.pers["tscale"] = 1;
	
	if(self.pers["tscale"] == 0.5)
	{
		wait 2;
		setDvar("timescale", 0.5);
	}
	setDvar("bg_gravity",self.pers["gravity"]);
	self waittill("begin_killcam");
	setDvar("timescale", 1);
}

randomRound()
{
	if(getDvar("g_gametype") != "sd")
		return;

	scoreaxis = RandomIntrange(0, 3);
    scoreallies = RandomIntrange(0, 3);
    total = scoreaxis + scoreallies;
	wait 2;
	game["roundsWon"]["axis"] = scoreaxis;
	game["roundsWon"]["allies"] = scoreallies;
	game["teamScores"]["allies"] = scoreaxis;
	game["teamScores"]["axis"] = scoreallies;
	wait 0.1;	
}

onPlayerKilled(einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration) 
{
    thread [[level.onkillscore]](einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration);
    // ^ this is here so you can still score normally

   attacker iPrintLn("^7You ^1killed ^5" + self.name + " ^7from ^2" + int(distance(self.origin, attacker.origin)*0.0254) + "^2m ^7away");
}

tryUseAirdrop_stub( lifeId, kID, dropType )
{
	result = undefined;

	if ( !isDefined( dropType ) )
		dropType = "airdrop_marker_mp";

	if(self.pers["airspace"])
	{
		self iprintlnbold( &"LUA_KS_UNAVAILABLE_AIRSPACE" );
		return false;
	}

	if ( !isDefined( self.pers["kIDs_valid"][kID] ) )
		return true;

	if ( level.littleBirds >= 3 && dropType != "airdrop_mega_marker_mp")
	{
		self iprintlnbold( &"LUA_KS_UNAVAILABLE_AIRSPACE" );
		return false;
	} 

	if ( isDefined( level.civilianJetFlyBy ) )
	{
		self iprintlnbold( &"MP_CIVILIAN_AIR_TRAFFIC" );
		return false;
	}

	if ( self isUsingRemote() )
	{
		return false;
	}

	if ( dropType != "airdrop_mega_marker_mp" )
	{
		level.littleBirds++;
		self thread maps\mp\h2_killstreaks\_airdrop::watchDisconnect();
	}

	result = self maps\mp\h2_killstreaks\_airdrop::beginAirdropViaMarker( lifeId, kID, dropType );

	if ( (!isDefined( result ) || !result) && isDefined( self.pers["kIDs_valid"][kID] ) )
	{
		self notify( "markerDetermined" );

		if ( dropType != "airdrop_mega_marker_mp" )
			maps\mp\h2_killstreaks\_airdrop::decrementLittleBirdCount();

		return false;
	}

	if ( dropType == "airdrop_mega_marker_mp" )
		thread teamPlayerCardSplash( "callout_used_airdrop_mega", self );

	self notify( "markerDetermined" );
	return true;
}