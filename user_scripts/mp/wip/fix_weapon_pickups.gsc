//modified by SlyElliot
#include scripts\utility;
#include maps\mp\gametypes\_weapons;


dropweaponfordeath( var_0, var_1 )
{
    if ( !maps\mp\_utility::isusingremote() )
        waittillframeend;

    if ( isdefined( level.blockweapondrops ) )
        return;

    if ( !isdefined( self ) )
        return;

    if ( isdefined( self.droppeddeathweapon ) )
        return;

    if ( level.ingraceperiod )
        return;

    var_2 = self.lastdroppableweapon;

    if ( !isdefined( var_2 ) )
        return;

    if ( var_2 == "none" )
        return;

    if ( !self hasweapon( var_2 ) )
        return;

    if ( maps\mp\_utility::isjuggernaut() )
        return;

    if ( isdefined( level.gamemodemaydropweapon ) && !self [[ level.gamemodemaydropweapon ]]( var_2 ) )
        return;

    var_3 = maps\mp\_utility::getweaponnametokens( var_2 );

    if ( var_3[0] == "alt" )
    {
        for ( var_4 = 0; var_4 < var_3.size; var_4++ )
        {
            if ( var_4 > 0 && var_4 < 2 )
            {
                var_2 += var_3[var_4];
                continue;
            }

            if ( var_4 > 0 )
            {
                var_2 += ( "_" + var_3[var_4] );
                continue;
            }

            var_2 = "";
        }
    }

     if ( var_2 != "riotshield_mp" )
    {
        if ( !self anyammoforweaponmodes( var_2 ) )
            return;

        var_5 = self getweaponammoclip( var_2, "right" );
        var_6 = self getweaponammoclip( var_2, "left" );

        if ( !var_5 && !var_6 )
            return;

        var_7 = self getweaponammostock( var_2 );
        var_8 = weaponmaxammo( var_2 );

        if ( var_7 > var_8 )
            var_7 = var_8;

        var_9 = self dropitem( var_2 );

        if ( !isdefined( var_9 ) )
            return;

        // Adjust position slightly to prevent clipping into the ground
        var_9.origin = ( var_9.origin[0], var_9.origin[1], var_9.origin[2] + 10 );

        if ( maps\mp\_utility::ismeleemod( var_1 ) )
            var_9.origin = ( var_9.origin[0], var_9.origin[1], var_9.origin[2] + 10 );

        var_9 itemweaponsetammo( var_5, var_7, var_6 );
    }
    else
    {
        var_9 = self dropitem( var_2 );

        if ( !isdefined( var_9 ) )
            return;

        var_9 itemweaponsetammo( 1, 1, 0 );
    }

   // Perform a bullet trace to check for ground level
    var_trace = bullettrace(var_9.origin, (var_9.origin[0], var_9.origin[1], var_9.origin[2] - 20), false, self);
    var_hitFraction = var_trace["fraction"];
    var_hitPosition = var_trace["position"];

    // Adjust weapon position if it is below ground
    if (var_hitFraction < 1.0) {
        var_9.origin = (var_hitPosition[0], var_hitPosition[1], var_hitPosition[2] + 10);
    }

    var_9 itemweaponsetammo( 0, 0, 0, 1 );
    self.droppeddeathweapon = 1;
    var_9.owner = self;
    var_9.ownersattacker = var_0;
    var_9.targetname = "dropped_weapon";
    var_9 thread watchpickup();
    var_9 thread deletepickupafterawhile();
}
