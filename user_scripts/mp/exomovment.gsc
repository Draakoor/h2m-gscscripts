/*
	Scuffed Exo Movment ported from AW
	By BradsTV
	Version: v1.0.0
*/

init()
{
    if (getDvarInt("exomovment") == 1) {
    setDvars(); 
    //loadCustomFX();
    level thread onPlayerConnect();
    level.playerdamagestub = level.callbackplayerdamage;
    level.callbackplayerdamage = ::onPlayerDamage;
    }
}

setDvars()
{
    setdvar("jump_slowdownEnable", 0);
    setdvar("jump_height", 39);
    setdvar("jump_enableFallDamage", 0);

    setdvar("high_jump_height", 150);
    setdvar("high_jump_cooldown_time_sec", 0.2);

    setdvar("dodge_vel_multiplier", 400);
    setdvar("dodge_vel_z_offset", 150);
    setdvar("dodge_cooldown_time_sec", 0.2);

    setdvar("ground_slam_speed", 150);
    setdvar("ground_slam_min_damage", 50);
    setdvar("ground_slam_max_damage", 110);
    setdvar("ground_slam_min_radius", 75);
    setdvar("ground_slam_max_radius", 125);
}

/*loadCustomFX()
{  
    level._effect["exo_slam_impact"] = loadfx("vfx/code/exo_slam_impact");  
    level._effect["high_jump_exo_land_medium"] = loadfx("vfx/code/high_jump_exo_land_medium");  
    level._effect["high_jump_ground"] = loadfx("vfx/code/high_jump_ground"); 
    level._effect["high_jump_view_air"] = loadfx("vfx/code/high_jump_view_air"); 
}
*/

onPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
    if(sWeapon == "boost_slam_mp" && sMeansOfDeath == "MOD_TRIGGER_HURT")
    {
        if (!self maps\mp\_utility::isusingremote() && !self maps\mp\_utility::isinremotetransition() && !self maps\mp\_flashgrenades::isflashbanged())
        {
            if (iDamage > 10 && !self maps\mp\_utility::_hasperk("specialty_hard_shell"))
                self shellshock("concussion_grenade_mp", 1.5);
                
            self setclientomnvar("ui_hud_shake", 1);
        }
    }

    [[ level.playerdamagestub ]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");

    self thread onPlayerSpawnedOnce();
    for(;;) //on each player spawn
    {
        self waittill("spawned_player");
        self enable_exo_suit();
    } 
}

onPlayerSpawnedOnce()
{
    self endon("disconnect");

    self waittill("spawned_player");
    //self freezecontrols(0);
    self thread monitor_stance_button();
}

enable_exo_suit()
{
    if ( !isdefined( self.boost ) )
        self.boost = [];

    self.boost["in_dash"] = 0;
    self.boost["in_jump"] = 0;
    self.boost["in_slam"] = 0;
    self.boost["dash_count"] = 0;
    self.boost["player_slammed"] = undefined;

    self thread track_player_movement();
    self thread exo_dash();
    self thread exo_jump();
    self thread exo_slam();
}

disable_exo_suit()
{
    self notify("disable_exo");
    self.boost = undefined;
}

track_player_movement()
{
    self endon("disconnect");
    self endon("death");
    self endon("disable_exo");

    if(!isdefined(self.boost["stick_input"]) || !isdefined(self.boost["stick_normalized"]))
    {
        self.boost["stick_input"] = (0, 0, 0);
        self.boost["stick_normalized"] = (0, 0, 0);
    }
        
    for(;;)
    {
        normalized = self getnormalizedmovement();
        normalized = (normalized[0], normalized[1] * -1, 0);
        combined_angles = common_scripts\utility::flat_angle(combineangles(self.angles, vectortoangles(normalized)));
        stick_input = anglestoforward(combined_angles) * length(normalized);
        self.boost["stick_input"] = stick_input;
        self.boost["stick_normalized"] = normalized;
        wait 0.05;
    }
}

exo_dash()
{
    self endon("disconnect");
    self endon("death");
    self endon("disable_exo");

    for(;;)
    {
        waittill_dash_button_pressed();
        if(!self adsbuttonpressed() && self getstance() != "prone" && self ismovingstick() && !self.boost["in_slam"])
        {
            if(self.boost["stick_normalized"][0] < 0.6)
                self boost_dash();
            else if(!self isonground())
                self boost_dash();
        }
        waittill_dash_button_released();
    }
}

exo_jump()
{
    self endon("disconnect");
    self endon("death");
    self endon("disable_exo");

    for(;;)
    {
        waittill_not_on_ground();
        waittill_jump_button_released();
    
        if(!waittill_jump_button_pressed_or_onground())
            continue;

        if (!self isonground() && !self.boost["in_slam"])
            self boost_jump();

        waittill_jump_button_released();
    }
}

exo_slam()
{
    self endon("disconnect");
    self endon("death");
    self endon("disable_exo");

    for(;;)
    {
        waittill_not_on_ground();
        waittill_stance_button_released();
    
        if(!waittill_stance_button_pressed_or_onground())
            continue;

        if (!self isonground())
            self boost_slam();

        waittill_stance_button_released();
    }
}

boost_dash()
{
    self endon("disconnect");
    self endon("death");
    self endon("disable_exo");

    if(self.boost["dash_count"] >= 2)
    {
        self playlocalsound("mp_exo_bat_empty");
        return;
    }
        
    self notify("new_dash");
    self thread dash_cooldown();
    self.boost["in_dash"] = 1;
    
    //self thread boost_dash_fx();

    z_offset = (0, 0, getdvarfloat("dodge_vel_z_offset", 150));
    x_y_multiplier = getdvarfloat("dodge_vel_multiplier", 400);

    stick_input = self.boost["stick_input"];
    player_vel = self getvelocity();

    modified_velo = player_vel + stick_input * 250 + z_offset;
    velo_normalized = vectornormalize(modified_velo) * x_y_multiplier;
    final_velo = (velo_normalized[0], velo_normalized[1], modified_velo[2]);

    if (stick_input[2] == 0)
        final_velo = (final_velo[0], final_velo[1], final_velo[2] * 0.7);

    self setvelocity(final_velo);
    wait (getdvarfloat("dodge_cooldown_time_sec", 0.2));
    self.boost["in_dash"] = 0;
}

/*boost_dash_fx()
{
    earthquake( 0.2, 1, self.origin, 150 );
    self playlocalsound("pc_boost_dodge");
    thread common_scripts\utility::play_sound_in_space("npc_boost_dodge", self.origin);
    self playrumbleonentity("damage_heavy");
}*/

dash_cooldown()
{
    self endon("disconnect");
    self endon("death");
    self endon("disable_exo");
    self endon("new_dash");

    self.boost["dash_count"]++;
    wait 2.5;
    self.boost["dash_count"] = 0;
}

boost_jump()
{
    self endon("disconnect");
    self endon("death");
    self endon("disable_exo");

    self.boost["in_jump"] = 1;

    //self thread boost_jump_fx();

    height_offset = getdvarfloat("high_jump_height", 150);
    for(i = 0; i < 4; i++)
    {
        velo = self getvelocity();
        z = velo[2];

        if(i == 0)
            z = 0;

        z = z + height_offset;
        self setvelocity((velo[0], velo[1], z));
        wait 0.05;
    }

    waittill_on_ground();
    //self thread boost_land_fx();
    wait (getdvarfloat("high_jump_cooldown_time_sec", 0.2));
    self.boost["in_jump"] = 0;
}

/*boost_jump_fx()
{
    self playlocalsound("pc_boost_jump");
    thread common_scripts\utility::play_sound_in_space("npc_boost_jump", self.origin);

    ground = bullettrace(self.origin, self.origin - (0, 0, 5000), false, self)["position"];
    if(distance(self.origin, ground) < 120)
        playfx(common_scripts\utility::getfx("high_jump_ground"), ground);
    
    playfxontag(common_scripts\utility::getfx("high_jump_view_air"), self, "j_hip_ri");
    earthquake( 0.2, 1, self.origin, 150 );
    self playrumbleonentity("damage_heavy");
}

boost_land_fx()
{
    self playlocalsound("pc_boost_land");
    thread common_scripts\utility::play_sound_in_space("npc_boost_land", self.origin);
    playfx(common_scripts\utility::getfx("high_jump_exo_land_medium"), self.origin);
    self playrumbleonentity("damage_heavy");
}*/

boost_slam()
{
    self endon("disconnect");
    self endon("death");
    self endon("disable_exo");

    if(self getdistancetoground() < 120)
    {
        self playlocalsound("mp_exo_bat_empty");
        return;
    }

    self.boost["in_slam"] = 1;

    self common_scripts\utility::_disableweapon();
    self common_scripts\utility::_disableoffhandweapons();
    self setstance("stand");

    x = (1, 0, 0);
    flat_angle = common_scripts\utility::flat_angle(combineangles(self.angles, vectortoangles(x)));
    forward = anglestoforward(flat_angle) * length(x);

    self.boost["player_slammed"] = undefined;
    self thread get_player_slammed();

    slam_speed = getdvarfloat("ground_slam_speed", 150);
    while(!self isonground() && !isdefined(self.boost["player_slammed"]))
    {
        player_vel = self getvelocity();
        x_y = player_vel * 0.5 + forward * 150;
        z = player_vel[2] - slam_speed; 
        final_velo = (x_y[0], x_y[1], z);
        self setvelocity(final_velo);
        wait 0.05;
    }
    self setvelocity((1, 1, 1));

    self notify("end_player_slammed");
    //self thread boost_slam_fx(self.boost["player_slammed"]);
    self slam_radius_damage(self.boost["player_slammed"]);
    
    self common_scripts\utility::_enableweapon();
    self common_scripts\utility::_enableoffhandweapons();
    
    self.boost["player_slammed"] = undefined;
    self.boost["in_slam"] = 0;
    
}

get_player_slammed()
{
    self notify("end_player_slammed");
    self endon("disconnect");
    self endon("death");
    self endon("disable_exo");
    self endon("end_player_slammed");

    kill_radius = getdvarfloat("ground_slam_kill_radius", 35);
    for(;;)
    {
        foreach(player in level.players)
        {
            if((player.team == self.team && level.teambased) || !maps\mp\_utility::isreallyalive(player) || player == self)
				continue;
            
            if(distance(self getorigin(), player gettagorigin("J_HEAD")) < kill_radius)
            {
                self.boost["player_slammed"] = player;
                return;
            }
        }
        wait 0.05;
    }
}

/*boost_slam_fx(player)
{
    if(isdefined(player) && isplayer(player))
    {
        self playlocalsound("pc_boost_slam_land_dmg_default");
        thread common_scripts\utility::play_sound_in_space("npc_boost_slam_land_dmg_default", self.origin);
    }
    else
    {    
        self playlocalsound("pc_boost_slam_land_default");
        thread common_scripts\utility::play_sound_in_space("npc_boost_slam_land_default", self.origin);
    }
    
    playfx(common_scripts\utility::getfx("exo_slam_impact"), self.origin);
    earthquake(0.3, 1, self.origin, 150);
    self setclientomnvar("ui_hud_shake", 1);
    self playrumbleonentity("damage_heavy");
}*/

slam_radius_damage(player)
{
    min_damage = getdvarfloat("ground_slam_min_damage", 50);
    max_damage = getdvarfloat("ground_slam_max_damage", 110);
    min_radius = getdvarfloat("ground_slam_min_radius", 75);
    max_radius = getdvarfloat("ground_slam_max_radius", 125);

    radius = (max_radius - min_radius) * 0.5 + min_radius;

    if(isdefined(player) && isplayer(player))
        player dodamage(100, self.origin, self, self, "MOD_CRUSH", "boost_slam_mp");
    
    self radiusdamage(self.origin, radius, max_damage, min_damage, self, "MOD_TRIGGER_HURT", "boost_slam_mp");
    physicsexplosionsphere(self.origin, radius, 20, 0.9);
}

waittill_not_on_ground()
{
    self endon("disconnect");
    self endon("death");

    while(self isonground())
        wait 0.05;
    
    return 1;
}

waittill_on_ground()
{
    self endon("disconnect");
    self endon("death");

    while(!self isonground())
        wait 0.05;
    
    return 1;
}

waittill_dash_button_pressed()
{
    self endon("disconnect");
    self endon("death");
    self endon("disable_exo");

    while(!self sprintbuttonpressed())
        wait 0.05;

    return 1;
}

waittill_dash_button_released()
{
    self endon("disconnect");
    self endon("death");

    while(self sprintbuttonpressed())
        wait 0.05;

    return 1;
}

waittill_jump_button_pressed()
{
    self endon("disconnect");
    self endon("death");

    while(!self jumpbuttonpressed())
        wait 0.05;
        
    return 1;
}

waittill_jump_button_pressed_or_onground()
{
    self endon("disconnect");
    self endon("death");

    while(!self jumpbuttonpressed() && !self isonground())
        wait 0.05;
        
    if(self isonground())
        return 0;

    return 1;
}

waittill_jump_button_released()
{
    self endon("disconnect");
    self endon("death");

    while(self jumpbuttonpressed())
        wait 0.05;

    return 1;
}

waittill_stance_button_pressed()
{
    self endon("disconnect");
    self endon("death");

    while(!self stancebuttonpressed())
        wait 0.05;

    return 1;
}

waittill_stance_button_pressed_or_onground()
{
    self endon("disconnect");
    self endon("death");

    while(!self stancebuttonpressed() && !self isonground())
        wait 0.05;
        
    if(self isonground())
        return 0;

    return 1;
}

waittill_stance_button_released()
{
    self endon("disconnect");
    self endon("death");

    while(self stancebuttonpressed())
        wait 0.05;

    return 1;
}

monitor_stance_button()
{
    self endon("disconnect");

    self notifyonplayercommand("stance_down", "+stance");
    self notifyonplayercommand("stance_down", "+movedown");
    self notifyonplayercommand("stance_down", "+togglecrouch");
    self notifyonplayercommand("stance_up", "-stance");
    self notifyonplayercommand("stance_up", "-movedown");
    self notifyonplayercommand("stance_up", "-togglecrouch");
    self.stance_state = 0;

    for(;;)
    {
        notify_msg = self common_scripts\utility::waittill_any_return("stance_down", "stance_up");
        if(notify_msg == "stance_down")
        {
            self.stance_state = 1;
        }

        if(notify_msg == "stance_up")
        {
            self.stance_state = 0;
        }
    }
}

stancebuttonpressed()
{
    return self.stance_state;
}

getdistancetoground()
{
    return distance(self.origin, bullettrace(self.origin, self.origin - (0, 0, 5000), false, self)["position"]);
}

ismovingstick()
{
    stick = self.boost["stick_normalized"];
    if(stick[0] != 0 || stick[1] != 0 || stick[2] != 0)
        return true;

    return false;
}