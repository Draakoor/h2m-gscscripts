// Created by Klutz, MAKE SURE YOU USE HP (HARDPOINT) GAMETYPE
// Also use maps that have an open area for the care packages to spawn.

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\h2_killstreaks\_airdrop;
#include maps\mp\_helicopter;
#include maps\mp\_matchdata;
#include scripts\utility;
#include maps\mp\gametypes\hp;


init()
{
    if (getDvarInt("dropzone") == 1){
        level.waitingtime = 0;
        replaceFunc(maps\mp\gametypes\hp::onzonecapture, ::customOnzonecapture );
        level thread on_player_connect();
    }
}

on_player_connect(){
    level endon("game ended");
    
    for(;;){
        level waittill("connected", player);
        player thread on_player_spawn();
    }
}

on_player_spawn(){
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");
        wait 0.2;
        self.customKillstreaks = []; 

    }
}

customOnzonecapture(var_0){

    wasContested = level.zone.gameobject.iscontested;

    // Timer fix by Twest
    maps\mp\gametypes\_gamelogic::pausetimer();
    
    var_1 = var_0.pers["team"];
    var_2 = maps\mp\_utility::getotherteam( var_1 );
    var_3 = gettime();
    var_0 logstring( "zone captured" );
    level.zone.gameobject.iscontested = 0;
    level.usestartspawns = 0;
    setteamicons( var_1 );

    if( ish1map() )
        level.zone namedborderowned( var_1 );

    if ( !isdefined( self.lastcaptureteam ) || self.lastcaptureteam != var_1 )
    {
        var_4 = [];
        var_5 = getarraykeys( self.touchlist[var_1] );

        for ( var_6 = 0; var_6 < var_5.size; var_6++ ){
            var_4[var_5[var_6]] = self.touchlist[var_1][var_5[var_6]];
        } 
        
        level thread give_capture_credit( var_4, var_3, var_1, self.lastcaptureteam );
        level thread maps\mp\_utility::leaderdialog( "hp_secured", var_1, "gamemode_objective" );
        level thread maps\mp\_utility::leaderdialog( "hp_lost", var_2, "gamemode_objective" );

        var_7 = getarraykeys( var_4 );

        if (!wasContested && level.waitingtime == 0)
        {
            
            wait 0.5;
            for ( var_8 = 0; var_8 < var_4.size; var_8++ )
            {
                var_9 = var_4[var_7[var_8]].player;
                var_9 thread handle_airdrop(var_9);
                break;
            }
        }
    }

    level thread maps\mp\_utility::playsoundonplayers( game["objective_gained_sound"], var_1 );
    level thread maps\mp\_utility::playsoundonplayers( game["objective_lost_sound"], var_2 );
    level.hpcapteam = var_1;
    maps\mp\gametypes\_gameobjects::setownerteam( var_1 );

    if ( isdefined( self.lastcaptureteam ) && self.lastcaptureteam != var_1 )
    {
        for ( var_7 = 0; var_7 < level.players.size; var_7++ )
        {
            var_0 = level.players[var_7];

            if ( var_0.pers["team"] == var_1 )
            {
                if ( isdefined( var_0.lastkilldefendertime ) && var_0.lastkilldefendertime + 500 > gettime() )
                    var_0 maps\mp\gametypes\_missions::processchallenge( "ch_hp_killedLastContester" );
            }
        }
    }

    level thread awardcapturepoints( var_1, self.lastcaptureteam );
    self.capturecount++;
    self.lastcaptureteam = var_1;
    maps\mp\gametypes\_gameobjects::mustmaintainclaim( 1 );
    level notify( "zone_captured" );
    level notify( "zone_captured" + var_1 );

 

}


handle_airdrop(var_1){
    level endon("game ended");
    self endon("disconnect");

    for(;;){

        if(level.waitingtime == 0 && level.lastcaptureteam == var_1 && level.hpcapteam != "neutral" ){
            self thread spawnDirectAirdrop();
            level thread start_timer(var_1);
            level notify("start_timer");
        }

        wait 0.05;
             
    }
}


start_timer(var_1){
    level.waitingtime = 15000;
    level waittill("start_timer");
    wait 15;
    level.waitingtime = 0;
}


spawnDirectAirdrop()
{
    if (!isDefined(self.killstreakIdCounter))
        self.killstreakIdCounter = 0;

    self.killstreakIdCounter++;
    kID = self.killstreakIdCounter;

    self.pers["kIDs_valid"][kID] = true;

    dropType = "airdrop_marker_mp";
    position = self.origin;

    level thread doFlyBy(self, position, randomFloat(360), dropType);
}
