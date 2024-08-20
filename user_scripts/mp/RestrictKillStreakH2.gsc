#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    wait 0.1;
    replaceFunc( maps\mp\gametypes\_hardpoints::givehardpoint, ::customgivehardpoint);
    SetDvarIfNotInizialized("streaksRestricted", "none"); //set streaksRestricted "radar_mp counter_radar_mp airdrop_marker_mp sentry_mp predator_mp airstrike_mp harrier_airstrike_mp helicopter_mp airdrop_mega_marker_mp stealth_airstrike_mp pavelow_mp chopper_gunner_mp ac130_mp emp_mp nuke_mp" // put in your cfg server
    level.arrayStreaksRectrited =  strTok(getDvar("streaksRestricted"), " ");
}

customgivehardpoint( streakName, streakCost)
{
	self notify( "giveHardpoint" );
	self endon( "giveHardpoint" );
	self endon( "disconnect" );
	self endon( "death" );

	if ( level.gameended && level.gameendtime != gettime() )
		return;

	if ( !maps\mp\_utility::is_true( level.killstreaksenabled ) )
		return;

	if ( getdvar( "scr_game_hardpoints" ) != "" && getdvarint( "scr_game_hardpoints" ) == 0 )
		return;

	if ( !isdefined( level.hardpointitems[streakName] ) || !level.hardpointitems[streakName] )
		return;

    if(inArray(level.arrayStreaksRectrited, streakName)) // RestrictStreak from liststreaks
        return;

	// shuffle existing killstreaks up a notch
	for( i = self.pers["killstreaks"].size; i >= 0; i-- )	
		self.pers["killstreaks"][i + 1] = self.pers["killstreaks"][i]; 	

	self.pers["killstreaks"][0] = spawnStruct();
	self.pers["killstreaks"][0].streakName = streakName;

	self.pers["killstreaks"][0].kID = self.pers["kID"];
	self.pers["kIDs_valid"][self.pers["kID"]] = true;

	self.pers["kID"]++;

	if ( !isDefined( streakCost ) )
		self.pers["killstreaks"][0].lifeId = -1;
	else
		self.pers["killstreaks"][0].lifeId = self.pers["deaths"];

	self maps\mp\gametypes\_hardpoints::giveHardpointWeapon( streakName );
	self thread maps\mp\gametypes\_hardpoints::hardpointnotify( streakName, streakCost );
}

inArray(array, text)
{
    for( i = 0; i < array.size; i++)
    {
        if(array[i] == text)
		{
			return true;
		}
    }
    return false;
}

SetDvarIfNotInizialized(dvar, value)
{
	if(!IsInizialized(dvar))
		setDvar(dvar, value);
}

IsInizialized(dvar)
{
	result = getDvar(dvar);
	return !isDefined(result) || result != "";
}