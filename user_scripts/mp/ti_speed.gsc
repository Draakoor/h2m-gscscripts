init()
{
    replacefunc(maps\mp\perks\_perkfunctions::monitortiuse, ::monitor_ti_start);

    level.ti_place_down_time = 1;
}

monitor_ti_start()
{
    self endon("death");
    self endon("disconnect");
    level endon("game_ended");
    self endon("end_monitorTIUse");

    self thread maps\mp\perks\_perkfunctions::updateTISpawnPosition();
    self thread maps\mp\perks\_perkfunctions::clearPreviousTISpawnpoint();

    for ( ;; )
    {
        self waittill("grenade_pullback", weapname);

        if (weapname != "flare_mp" )
            continue;
        
        wait level.ti_place_down_time;

        self takeweapon("flare_mp");
        self setspawnweapon(self.primaryweapon);

        if ( isDefined( self.setSpawnPoint ) )
            self maps\mp\perks\_perkfunctions::deleteTI( self.setSpawnPoint );

        if ( !isDefined( self.TISpawnPosition ) )
            continue;

        if ( self maps\mp\_utility::touchingBadTrigger() )
            continue;

        TIGroundPosition = playerPhysicsTrace( self.TISpawnPosition + (0,0,16), self.TISpawnPosition - (0,0,2048) ) + (0,0,1);

        glowStick = spawn( "script_model", TIGroundPosition );
        glowStick.angles = self.angles;
        glowStick.team = self.team;
        glowStick.enemyTrigger =  spawn( "script_origin", TIGroundPosition );
        glowStick thread maps\mp\perks\_perkfunctions::GlowStickSetupAndWaitForDeath( self );
        glowStick.playerSpawnPos = self.TISpawnPosition;
        glowStick.notti = true;

        glowStick thread maps\mp\gametypes\_weapons::createBombSquadModel( "weapon_light_stick_tactical_bombsquad", "tag_fire_fx", self );

        self.setSpawnPoint = glowStick;	
        self thread maps\mp\perks\_perkfunctions::tactical_respawn();
        return;
    }
}