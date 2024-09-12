// Created by Xevrac
// Modify NUKE to MOAB style 
// Use DVAR nukeEndsGame to 0 for no endgame nuke like MW3 MOAB
// Version 2.1.1

//Infinite nukes patch by Sly Elliot

#include scripts\utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gamelogic;
#include maps\mp\h2_killstreaks\_nuke;
#include maps\mp\h2_killstreaks\_emp;

init()
{
    setDvarIfUninitialized("nukeEndsGame", 1);

    replaceFunc(maps\mp\h2_killstreaks\_nuke::nukeDeath, ::customNukeDeath);
    replaceFunc(maps\mp\h2_killstreaks\_nuke::cancelNukeOnDeath, ::customCancelNukeOnDeath);
    replaceFunc(maps\mp\h2_killstreaks\_nuke::nukeEffects, ::customNukeEffects);
    replaceFunc(maps\mp\h2_killstreaks\_nuke::doNuke, ::customDoNuke);


	//level._effect[ "emp_flash" ] = loadfx( "fx/explosions/nuke_flash" );

	level.teamEMPed["allies"] = false;
	level.teamEMPed["axis"] = false;
	level.empPlayer = undefined;

	if ( level.teamBased )
		level thread EMP_TeamTracker();
	else
		level thread EMP_PlayerTracker();

	level.killstreakFuncs["emp_mp"] = ::h2_EMP_Use;

	level thread onPlayerConnect();

    // For use with giveNuke
    // Test thread

    // thread onPlayerConnect();
}

// For use with giveNuke
// Test function

// onPlayerConnect()
// {
//     level endon("game_ended");
//     for(;;)
//     {
//         level waittill("connected", player);
//         player thread onPlayerSpawned();
//     }
// }

// giveNuke onPlayerSpawned
// Test function

// onPlayerSpawned()
// {
//     self endon("disconnect");
//     level endon("game_ended");

//     for(;;)
//     {
//         self waittill("spawned_player");
        


//         self thread giveNuke();
//     }
// }

/*
customNukeSlowMo()
{
	level endon ( "nuke_cancelled" );

	foreach( player in level.players )
	{
		if ( isReallyAlive(player) )
			earthquake( 0.6, 10, player.origin, 1000 );
	}

	// Start slow motion effect
	setSlowMotion( 1.0, 0.25, 0.5 );

	// Wait for the nuke death event
	level waittill( "nuke_death" );

	// Reset to normal speed
	setSlowMotion( 1.0, 1.0, 0.0 );

	// Ensure global reset after the nuke
	level thread resetGameSpeed();
}
*/

/*
customNukeVision()
{
	level endon ( "nuke_cancelled" );

	level.nukeVisionInProgress = true;
	_visionsetnaked( "", 0 );
	visionSetPostApply( "airlift_nuke_flash", 2 );

	level waittill( "nuke_death" );

	_visionsetnaked( "", 0 );
	visionSetPostApply( "", 0 );
	wait 5;
	_visionsetnaked( "", 0 );
	level.nukeVisionInProgress = false;
}
*/

resetGameSpeed()
{
	// Safety delay to ensure all nuke effects have played out
	wait( 4.0 );

	// Ensure the game is back to normal speed
	setSlowMotion( 1.0, 1.0, 0.0 );
}

customDoNuke( allowCancel )
{
	level endon ( "nuke_cancelled" );

	level.nukeInfo = spawnStruct();
	level.nukeInfo.player = self;
	level.nukeInfo.team = self.pers["team"];
	level.nukeinfo.xpscalar = 1;

	level.nukeIncoming = true;

	h2_nukeCountdown();

	if ( level.teambased )
	{
		thread teamPlayerCardSplash( "callout_used_nuke", self, self.team );
	}
	else
	{
		if ( !level.hardcoreMode )
			self iprintlnbold( &"LUA_KS_TNUKE" );
	}

	level thread delaythread_nuke( (level.nukeTimer - 3.3), ::nukeSoundIncoming );
	level thread delaythread_nuke( level.nukeTimer, ::nukeSoundExplosion );
	//level thread delaythread_nuke( level.nukeTimer, ::customNukeSlowMo );
	level thread delaythread_nuke( level.nukeTimer, ::nukeEffects );
	//level thread delaythread_nuke( (level.nukeTimer + 0.25), ::customNukeVision );
	level thread delaythread_nuke( (level.nukeTimer + 1.5), ::nukeDeath );
	level thread delaythread_nuke( (level.nukeTimer + 1.5), ::nukeEarthquake );
	level thread nukeAftermathEffect();

	if ( level.cancelMode && allowCancel )
		level thread cancelNukeOnDeath( self ); 

	// leaks if lots of nukes are called due to endon above.
	clockObject = spawn( "script_origin", (0,0,0) );
	clockObject hide();

	while ( !isDefined( level.nukeDetonated ) )
	{
		clockObject playSound( "h2_nuke_timer" );
		wait( 1.0 );
	}

}

customNukeEffects()
{
	level endon ( "nuke_cancelled" );

	level.nukeCountdownTimer destroy();
	level.nukeCountdownIcon destroy();

	level.nukeDetonated = true;
	
	level maps\mp\h2_killstreaks\_emp::h2_EMP_Use();
	
	//level maps\mp\h2_killstreaks\_emp::_visionsetnaked( "coup_sunmap blind", 0.1 );
	//thread empEffects();
	level._effect[ "emp_flash" ] = loadfx( "fx/explosions/nuke_flash" );
	//level maps\mp\h2_killstreaks\_emp::empEffects();
	level maps\mp\h2_killstreaks\_emp::destroyActiveVehicles( level.nukeInfo.player );
	//level maps\mp\h2_killstreaks\_emp::EMP_TeamTracker();
	foreach( player in level.players )
	{
		playerForward = anglestoforward( player.angles );
		playerForward = ( playerForward[0], playerForward[1], 0 );
		playerForward = VectorNormalize( playerForward );
		

		nukeDistance = 5000;

		nukeEnt = Spawn( "script_model", player.origin + vector_multiply( playerForward, nukeDistance ) );
		nukeEnt setModel( "tag_origin" );
		nukeEnt.angles = ( 0, (player.angles[1] + 180), 90 );

		nukeEnt thread nukeEffect( player );
		
		player.nuked = true;

		
	}
}

customNukeDeath()
{
    level endon("nuke_cancelled");
    level notify("nuke_death");

    maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
    AmbientStop(1);

    nukeEndsGame = getDvarInt("nukeEndsGame");

    if (nukeEndsGame == 1)
    {
        foreach (player in level.players)
        {
            if (isAlive(player))
                player thread maps\mp\gametypes\_damage::finishPlayerDamageWrapper(level.nukeInfo.player, level.nukeInfo.player, 999999, 0, "MOD_EXPLOSIVE", "nuke_mp", player.origin, player.origin, "none", 0, 0);
        }

        if (level.teamBased)
            thread maps\mp\gametypes\_gamelogic::endGame(level.nukeInfo.team, game["strings"]["nuclear_strike"], true);
        else
        {
            if (isDefined(level.nukeInfo.player))
                thread maps\mp\gametypes\_gamelogic::endGame(level.nukeInfo.player, game["strings"]["nuclear_strike"], true);
            else
                thread maps\mp\gametypes\_gamelogic::endGame(level.nukeInfo, game["strings"]["nuclear_strike"], true);
        }
    }
    else if (nukeEndsGame == 0)
    {
        foreach (player in level.players)
        {
            if (isAlive(player))
                player thread maps\mp\gametypes\_damage::finishPlayerDamageWrapper(level.nukeInfo.player, level.nukeInfo.player, 999999, 0, "MOD_EXPLOSIVE", "nuke_mp", player.origin, player.origin, "none", 0, 0);
                player thread customCancelNukeOnDeath(player);
        }
    }
}


customCancelNukeOnDeath(player)
{
    player waittill_any("death", "disconnect");

    if (isDefined(player) && level.cancelMode == 2)
        player thread maps\mp\h2_killstreaks\_emp::h2_EMP_Use(0, 0);

    maps\mp\gametypes\_gamelogic::resumeTimer();
    level.timeLimitOverride = false;

    level.nukeDetonated = undefined;
    level.nukeInfo = undefined;
    level.nukeIncoming = undefined;
    player.nuked = undefined;

    level.nukeCountdownTimer destroy();
    level.nukeCountdownIcon destroy();

    level notify("nuke_cancelled");
}

// For testing only 
// Gives player nuke onSpawn
// Don't use in prod servers or expect chaos!

// giveNuke()
// {
//     wait 1;

//     self maps\mp\gametypes\_hardpoints::giveHardpoint("nuke_mp", 25);
// }