#include common_scripts\utility;
#include maps\mp\_utility;

Init()
{
    thread Setup();
}

Setup()
{
    level endon( "game_ended" );
    level endon( "end_game" );
    waittillframeend;
    
    level waittill( level.notifyTypes.sharedFunctionsInitialized );
    level.eventBus.gamename = "h2m";    
    user_scripts\mp\_integration_base::RegisterLogger( ::Log2Console );
    
    level.overrideMethods[level.commonFunctions.getTotalShotsFired]      = ::GetTotalShotsFired;
    level.overrideMethods[level.commonFunctions.setDvar]                 = ::SetDvarIfUninitializedWrapper;
    level.overrideMethods[level.commonFunctions.waittillNotifyOrTimeout] = ::WaitillNotifyOrTimeoutWrapper;
    level.overrideMethods[level.commonFunctions.isBot]                   = ::IsBotWrapper;
    level.overrideMethods[level.commonFunctions.getXuid]                 = ::GetXuidWrapper;
    level.overrideMethods[level.commonFunctions.waitTillAnyTimeout]      = ::WaitTillAnyTimeout;
    
    RegisterClientCommands();
        
    level notify( level.notifyTypes.gameFunctionsInitialized );
}

RegisterClientCommands() 
{
    user_scripts\mp\_integration_base::AddClientCommand( "GiveWeapon",     true,  ::GiveWeaponImpl );
    user_scripts\mp\_integration_base::AddClientCommand( "TakeWeapons",    true,  ::TakeWeaponsImpl );
    user_scripts\mp\_integration_base::AddClientCommand( "SwitchTeams",    true,  ::TeamSwitchImpl );
    user_scripts\mp\_integration_base::AddClientCommand( "Hide",           false, ::HideImpl );
    user_scripts\mp\_integration_base::AddClientCommand( "Alert",          true,  ::AlertImpl );
    user_scripts\mp\_integration_base::AddClientCommand( "Goto",           false, ::GotoImpl );
    user_scripts\mp\_integration_base::AddClientCommand( "Kill",           true,  ::KillImpl );
    user_scripts\mp\_integration_base::AddClientCommand( "SetSpectator",   true,  ::SetSpectatorImpl );
    user_scripts\mp\_integration_base::AddClientCommand( "LockControls",   true,  ::LockControlsImpl );
    user_scripts\mp\_integration_base::AddClientCommand( "PlayerToMe",     true,  ::PlayerToMeImpl );
    user_scripts\mp\_integration_base::AddClientCommand( "NoClip",         false, ::NoClipImpl );
}

GetTotalShotsFired()
{
    return self.pers["total_shots"];
}

SetDvarIfUninitializedWrapper( dvar, value )
{
    //maps\mp\_utility::set_dvar_if_unset( dvar, value );
    if (!isDefined(getDvar(dvar)))
        {
            setDvar(dvar, value); // Default to 64 units
        }
}

WaitillNotifyOrTimeoutWrapper( msg, timer )
{
	self endon( msg );
	wait( timer );
}

Log2Console( logLevel, message ) 
{
    Print( "[" + logLevel + "] " + message + "\n" );
}

God()
{
    if ( !IsDefined( self.godmode ) )
    {
        self.godmode = false;
    }
    
    if (!self.godmode )
    {
        self enableInvulnerability();
        self.godmode = true;
    }
    else
    {
        self.godmode = false;
        self disableInvulnerability();
    }
}

IsBotWrapper( client )
{
    return isbot(self);
}

GetXuidWrapper()
{
    return self GetXUID();
}

WaitTillAnyTimeout( timeOut, string1, string2, string3, string4, string5 )
{
    return common_scripts\utility::waittill_any_timeout( timeOut, string1, string2, string3, string4, string5 );
}

//////////////////////////////////
// Command Implementations
/////////////////////////////////

GiveWeaponImpl( event, data )
{
    if ( !IsAlive( self ) )
    {
        return self.name + "^7 is not alive";
    }
    
    if ( isDefined( level.player_too_many_weapons_monitor ) && level.player_too_many_weapons_monitor )
    {
        level.player_too_many_weapons_monitor = false;
        self notify( "stop_player_too_many_weapons_monitor" );
    }
    
    self IPrintLnBold( "You have been given a new weapon" );
    self GiveWeapon( data["weaponName"] );
    self SwitchToWeapon( data["weaponName"] );
    
    return self.name + "^7 has been given ^5" + data["weaponName"]; 
}

TakeWeaponsImpl( event, data )
{
    if ( !IsAlive( self ) )
    {
        return self.name + "^7 is not alive";
    }
    
    self TakeAllWeapons();
    self IPrintLnBold( "All your weapons have been taken" );
    
    return "Took weapons from " + self.name;
}

TeamSwitchImpl( event, data )
{
    if ( !IsAlive( self ) )
    {
        return self + "^7 is not alive";
    }
    
    team = level.allies;
    
    if ( self.team == "allies" ) 
    {
        team = level.axis;
    }
    
    self IPrintLnBold( "You are being team switched" );
    wait( 2 );
    self [[team]]();

    return self.name + "^7 switched to " + self.team;
}

LockControlsImpl( event, data )
{
    if ( !IsAlive( self ) )
    {
        return self.name + "^7 is not alive";
    }

    if ( !IsDefined ( self.isControlLocked ) )
    {
        self.isControlLocked = false;
    }

    if ( !self.isControlLocked )
    {
        self freezeControls( true );
        self God();
        self Hide();

        info = [];
        info[ "alertType" ] = "Alert!";
        info[ "message" ] = "You have been frozen!";
        
        self AlertImpl( undefined, info );

        self.isControlLocked = true;
        
        return self.name + "\'s controls are locked";
    }
    else
    {
        self freezeControls( false );
        self God();
        self Show();

        self.isControlLocked = false;

        return self.name + "\'s controls are unlocked";
    }
}

NoClipImpl( event, data )
{
    /*if ( !IsAlive( self ) )
    {
        self IPrintLnBold( "You are not alive" );
    }
    
    if ( !IsDefined ( self.isNoClipped ) )
    {
        self.isNoClipped = false;
    }

    if ( !self.isNoClipped )
    {
        self SetClientDvar( "sv_cheats", 1 );
        self SetClientDvar( "cg_thirdperson", 1 );
        self SetClientDvar( "sv_cheats", 0 );
        
        self God();
        self Noclip();
        self Hide();
        
        self.isNoClipped = true;
        
        self IPrintLnBold( "NoClip enabled" );
    }
    else
    {
        self SetClientDvar( "sv_cheats", 1 );
        self SetClientDvar( "cg_thirdperson", 1 );
        self SetClientDvar( "sv_cheats", 0 );
        
        self God();
        self Noclip();
        self Hide();
        
        self.isNoClipped = false;
        
        self IPrintLnBold( "NoClip disabled" );
    }

    self IPrintLnBold( "NoClip enabled" );*/

    user_scripts\mp\_integration_base::LogWarning( "NoClip is not supported on H2M!" );

}

HideImpl( event, data )
{
    if ( !IsAlive( self ) )
    {
        self IPrintLnBold( "You are not alive" );
        return;
    }
    
    if ( !IsDefined ( self.isHidden ) )
    {
        self.isHidden = false;
    }

    if ( !self.isHidden )
    {
        self SetClientDvar( "sv_cheats", 1 );
        self SetClientDvar( "cg_thirdperson", 1 );
        self SetClientDvar( "sv_cheats", 0 );
        
        self God();
        self Hide();
        
        self.isHidden = true;
        
        self IPrintLnBold( "Hide enabled" );
    }
    else
    {
        self SetClientDvar( "sv_cheats", 1 );
        self SetClientDvar( "cg_thirdperson", 0 );
        self SetClientDvar( "sv_cheats", 0 );
        
        self God();
        self Show();
        
        self.isHidden = false;
        
        self IPrintLnBold( "Hide disabled" );
    }
}

AlertImpl( event, data )
{
	self maps\mp\gametypes\_hud_message::notifymessage ( data["alertType"], data["message"], undefined, ( 1, 0, 0 ), "mpl_sab_ui_suitcasebomb_timer", 7.5 );
    return "Sent alert to " + self.name; 
}

GotoImpl( event, data )
{
    if ( IsDefined( event.target ) )
    {
        return self GotoPlayerImpl( event.target );
    }
    else
    {
        return self GotoCoordImpl( data );
    }
}

GotoCoordImpl( data )
{
    if ( !IsAlive( self ) )
    {
        self IPrintLnBold( "You are not alive" );
        return;
    }

    position = ( int( data["x"] ), int( data["y"] ), int( data["z"]) );
    self SetOrigin( position );
    self IPrintLnBold( "Moved to " + "("+ position[0] + "," + position[1] + "," + position[2] + ")" );
}

GotoPlayerImpl( target )
{
    if ( !IsAlive( target ) )
    {
        self IPrintLnBold( target.name + " is not alive" );
        return;
    }

    self SetOrigin( target GetOrigin() );
    self IPrintLnBold( "Moved to " + target.name );
}

PlayerToMeImpl( event, data )
{
    if ( !IsAlive( self ) )
    {
        return self.name + " is not alive";
    }

    self SetOrigin( event.origin GetOrigin() );
    return "Moved here " + self.name;    
}

KillImpl( event, data )
{
    if ( !IsAlive( self ) )
    {
        return self.name + " is not alive";
    }

    self Suicide();
    self IPrintLnBold( "You were killed by " + self.name );

    return "You killed " + self.name;
}

SetSpectatorImpl( event, data )
{
    if ( self.pers["team"] == "spectator" ) 
    {
        return self.name + " is already spectating";
    }
    
    self [[level.spectator]]();
    self IPrintLnBold( "You have been moved to spectator" );
    
    return self.name + " has been moved to spectator";
}