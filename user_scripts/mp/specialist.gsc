init()
{
    replacefunc(maps\mp\gametypes\_hud_message::shownotifymessage, ::show_notify_message);
    replacefunc(maps\mp\gametypes\_hud_message::initnotifymessage, ::init_notify_message);
    
    replacefunc(maps\mp\gametypes\_hardpoints::givehardpointitemforstreak, ::give_hard_point_item_for_streak);

    precacheshader("specialty_marathon");
    precacheshader("specialty_marathon_pro");
    precacheshader("specialty_fastreload");
    precacheshader("specialty_fastreload_pro");
    precacheshader("specialty_scavenger");
    precacheshader("specialty_scavenger_pro");
    precacheshader("specialty_bling");
    precacheshader("specialty_blingpro");
    precacheshader("specialty_oma");
    precacheshader("specialty_oma_pro");
    precacheshader("specialty_bulletdamage");
    precacheshader("specialty_bulletdamage_pro");
    precacheshader("specialty_h2lightweight");
    precacheshader("specialty_h2lightweight_pro");
    precacheshader("specialty_hardline");
    precacheshader("specialty_hardline_pro");
    precacheshader("specialty_radarimmune");
    precacheshader("specialty_radarimmune_pro");
    precacheshader("specialty_explosivedamage");
    precacheshader("specialty_explosivedamage_pro");
    precacheshader("specialty_commando");
    precacheshader("specialty_commando_pro");
    precacheshader("specialty_bulletaccuracy");
    precacheshader("specialty_bulletaccuracy_pro");
    precacheshader("specialty_scrambler");
    precacheshader("specialty_scrambler_pro");
    precacheshader("specialty_ninja");
    precacheshader("specialty_ninja_pro");
    precacheshader("specialty_detectexplosive");
    precacheshader("specialty_detectexplosive_pro");
    // precacheshader("specialty_pistoldeath");
    // precacheshader("specialty_pistoldeath_pro");
    precacheshader("combathigh_overlay");

    level.specialist_perks = [
        "specialty_longersprint",
        "specialty_fastmantle",
        "specialty_fastreload",
        "specialty_quickdraw",
        "specialty_scavenger",
        "specialty_extraammo",
        // "specialty_bling",
        // "specialty_secondarybling",
        "specialty_bulletdamage",
        "specialty_armorpiercing",
        "specialty_lightweight",
        "specialty_fastsprintrecovery",
        "specialty_hardline",
        "specialty_rollover",
        "specialty_radarimmune",
        "specialty_spygame",
        "specialty_explosivedamage",
        "specialty_dangerclose",
        "specialty_extendedmelee",
        "specialty_falldamage",
        "specialty_bulletaccuracy",
        "specialty_holdbreath",
        "specialty_localjammer",
        "specialty_delaymine",
        "specialty_heartbreaker",
        "specialty_quieter",
        "specialty_detectexplosive",
        "specialty_selectivehearing"
        // "specialty_pistoldeath",
        // "specialty_laststandoffhand"
    ];

    level.specialistitmes = [];
    level.specialistitems["all_perks"]["cost"]  = 8;
    level.specialistitems["all_perks"]["icon"]  = "specialty_oma";
    level.specialistitems["all_perks"]["sound"] = "mp_snd_bomb_planted";
    level.specialistitems["perk_earned_sound"]  = "earn_perk";

    level thread waittill_connected_thread();
}

reset_action_slots()
{
    maps\mp\_utility::_setactionslot(1, "");

    for(slot = 0; slot <= 4; slot++)
        self setweaponhudiconoverride("actionslot" + slot, "none");
}

waittill_connected_thread()
{
    level endon("game_ended");

    for(;;)
    {
        level waittill("connected", player);

        player thread waittill_player_spawned_thread();
    }
}

waittill_player_spawned_thread()
{
    self endon("disconnect");
    level endon("game_ended");

    for(;;)
    {
        self waittill("spawned_player");

        if (isdefined(self.specialist_all_perks_icon))
            self.specialist_all_perks_icon destroy();
        
        if (isdefined(self.got_all_perks))
            self.got_all_perks = undefined;

        self thread reset_action_slots();
    }
}

specialist_notifymessage(title, points, icon)
{
    notifydata              = spawnstruct();
    notifydata.titletext    = title;
    notifydata.notifytext   = points + " Point Streak!";
    notifydata.iconname     = icon;
    notifydata.duration     = 2.0;
    notifydata.resetondeath = true;
    notifydata.sound        = points == self.points_required_for_all_perks ? level.specialistitems["all_perks"]["sound"] : level.specialistitems["perk_earned_sound"];

    thread maps\mp\gametypes\_hud_message::notifymessage(notifydata);
}

combat_high_overlay()
{
    combat_high_overlay             = newclienthudelem(self);
    combat_high_overlay.x           = 0;
    combat_high_overlay.y           = 0;
    combat_high_overlay.alignx      = "left";
    combat_high_overlay.aligny      = "top";
    combat_high_overlay.horzalign   = "fullscreen";
    combat_high_overlay.vertalign   = "fullscreen";
    combat_high_overlay.sort        = -10;
    combat_high_overlay.archived    = true;
    combat_high_overlay setshader("combathigh_overlay", 640, 480);
    
    combat_high_overlay.alpha = 0.0;
    combat_high_overlay fadeovertime(1.0);
    combat_high_overlay.alpha = 0.85;

    wait 1.0;
    
    combat_high_overlay fadeovertime(2.0);
    combat_high_overlay.alpha = 0.0;

    wait 2.0;

    combat_high_overlay destroy();
}

give_all_perks(points)
{
	for(i = 0; i < level.specialist_perks.size; i++)
		maps\mp\_utility::giveperk(level.specialist_perks[i], 0);
    
    self thread combat_high_overlay();
    self thread specialist_notifymessage("All Specialist Perks", points, level.specialistitems["all_perks"]["icon"]);

    self.specialist_all_perks_icon              = self maps\mp\gametypes\_hud_util::createicon(level.specialistitems["all_perks"]["icon"], 18, 18);
    self.specialist_all_perks_icon.alpha        = 1.0;
    self.specialist_all_perks_icon.sort         = 1;
    self.specialist_all_perks_icon.foreground   = true;
    self.specialist_all_perks_icon.archived     = true;
    self.specialist_all_perks_icon maps\mp\gametypes\_hud_util::setpoint("CENTER", "CENTER", undefined, 230);

    self.specialist_all_perks_icon thread maps\mp\gametypes\_hud_util::flashthread();

    say("^2" + self.name + "^7 just got all specialist perks!");
}

give_random_perk(points)
{
    self endon("disconnect");
    level endon("game_ended");

    self.random_perk = level.specialist_perks[randomint(level.specialist_perks.size)];

    if (maps\mp\_utility::_hasperk(self.random_perk))
    {
        while(maps\mp\_utility::_hasperk(self.random_perk))
        {
            self.random_perk = level.specialist_perks[randomint(level.specialist_perks.size)];
            wait .1;
        }
    }

    maps\mp\_utility::giveperk(self.random_perk, 0);

    perk_notify_title   = maps\mp\perks\_perks::perktablelookuplocalizedname(self.random_perk);
    perk_notify_icon    = maps\mp\perks\_perks::perktablelookupimage(self.random_perk);

    switch(points)
    {
        case 2:
            self setweaponhudiconoverride("actionslot3", perk_notify_icon);
            break;
        case 4:
            self setweaponhudiconoverride("actionslot1", perk_notify_icon);
            break;
        case 6:
            self setweaponhudiconoverride("actionslot4", perk_notify_icon);
            break;
        default: break;
    }

    self thread specialist_notifymessage(perk_notify_title, points, perk_notify_icon);
}

give_hard_point_item_for_streak()
{
	if (isbot(self))
		return;

	player_streak   = self.pers["cur_kill_streak"];

    nuke_cost       = level.hardpointitems["nuke_mp"];
    all_perks_cost  = level.specialistitems["all_perks"]["cost"];
    
    if (self maps\mp\_utility::_hasperk("specialty_hardline"))
    {
        nuke_cost--;
        all_perks_cost--;
    }

    self.points_required_for_all_perks = all_perks_cost;

    if (player_streak == all_perks_cost)
    {
        self.got_all_perks = true;
        self thread give_all_perks(player_streak);
        return;
    }

    if (player_streak <= 8 && !(player_streak % 2) && !isdefined(self.got_all_perks))
    {
        self thread give_random_perk(player_streak);
        return;
    }

    if (player_streak == nuke_cost)
    {
        self setweaponhudiconoverride("actionslot4", "nuke_mp");
        maps\mp\_utility::_setactionslot(4, "nuke_mp");
        thread maps\mp\gametypes\_hardpoints::givehardpoint("nuke_mp", player_streak);
    }
}

init_notify_message()
{
    title_font_scale    = 2.0;
    text_font_scale     = 1.0;
    icon_size           = 16;
    font                = "objective";
    align               = "TOP";
    relative            = "BOTTOM";
    y_offset            = 120;
    x_offset            = 0;

    self.notifytitle = maps\mp\gametypes\_hud_util::createfontstring(font, title_font_scale);
    self.notifytitle maps\mp\gametypes\_hud_util::setpoint(align, undefined, x_offset, y_offset);
    self.notifytitle.hidewheninmenu = 1;
    self.notifytitle.archived = 0;
    self.notifytitle.alpha = 0;
    self.notifytext = maps\mp\gametypes\_hud_util::createfontstring(font, text_font_scale);
    self.notifytext maps\mp\gametypes\_hud_util::setparent(self.notifytitle);
    self.notifytext maps\mp\gametypes\_hud_util::setpoint(align, relative, 0, -5);
    self.notifytext.hidewheninmenu = 1;
    self.notifytext.archived = 0;
    self.notifytext.alpha = 0;
    self.notifytext2 = maps\mp\gametypes\_hud_util::createfontstring(font,text_font_scale);
    self.notifytext2 maps\mp\gametypes\_hud_util::setparent(self.notifytitle);
    self.notifytext2 maps\mp\gametypes\_hud_util::setpoint(align, relative, 0, 0);
    self.notifytext2.hidewheninmenu = 1;
    self.notifytext2.archived = 0;
    self.notifytext2.alpha = 0;
    self.notifyicon = maps\mp\gametypes\_hud_util::createicon("white", icon_size, icon_size);
    self.notifyicon maps\mp\gametypes\_hud_util::setparent(self.notifytext2);
    self.notifyicon maps\mp\gametypes\_hud_util::setpoint(align,relative,0,0);
    self.notifyicon.hidewheninmenu = 1;
    self.notifyicon.archived = 0;
    self.notifyicon.alpha = 0;
    self.notifyoverlay = maps\mp\gametypes\_hud_util::createicon("white", icon_size, icon_size);
    self.notifyoverlay maps\mp\gametypes\_hud_util::setparent(self.notifyicon);
    self.notifyoverlay maps\mp\gametypes\_hud_util::setpoint("CENTER","CENTER",0,0);
    self.notifyoverlay.hidewheninmenu = 1;
    self.notifyoverlay.archived = 0;
    self.notifyoverlay.alpha = 0;
    self.doingsplash = [];
    self.doingsplash[0] = undefined;
    self.doingsplash[1] = undefined;
    self.doingsplash[2] = undefined;
    self.doingsplash[3] = undefined;
    self.splashqueue = [];
    self.splashqueue[0] = [];
    self.splashqueue[1] = [];
    self.splashqueue[2] = [];
    self.splashqueue[3] = [];
}

show_notify_message( notifyData )
{
    self endon( "disconnect" );

    if ( maps\mp\_utility::is_true( notifyData.resetondeath ) )
        self endon( "death" );

    assert( isDefined( notifyData.slot ) );
    slot = notifyData.slot;

    if ( level.gameEnded )
    {
        if ( isDefined( notifyData.type ) && notifyData.type == "rank" )
        {
            self setClientDvar( "ui_promotion", 1 );
            self.postGamePromotion = true;
        }

        if ( self.splashQueue[ slot ].size )
            self thread maps\mp\gametypes\_hud_message::dispatchNotify( slot );

        return;
    }

    self.doingsplash[slot] = notifyData;

    if ( maps\mp\_utility::is_true( notifyData.resetondeath ) )
        thread maps\mp\gametypes\_hud_message::resetondeath();

    thread maps\mp\gametypes\_hud_message::resetoncancel();
    maps\mp\gametypes\_hud_message::waitrequirevisibility( 0 );

    if ( isdefined( notifyData.duration ) )
        duration = notifyData.duration;
    else if ( level.gameended )
        duration = 2.0;
    else
        duration = 4.0;

    if ( isdefined( notifyData.sound ) )
        self playlocalsound( notifyData.sound );

    if ( isdefined( notifyData.leadersound ) )
        maps\mp\_utility::leaderdialogonplayer( notifyData.leadersound );

    var_3 = notifyData.glowcolor;
    var_4 = self.notifytitle;

    if ( isdefined( notifyData.titletext ) )
    {
        self.notifytitle.font = "objective";
        self.notifytitle.fontScale = 1.5;

        if ( isdefined( notifyData.titlelabel ) )
            self.notifytitle.label = notifyData.titlelabel;
        else
            self.notifytitle.label = &"";

        if ( isdefined( notifyData.titlelabel ) && !isdefined( notifyData.titleisstring ) )
            self.notifytitle setvalue( notifyData.titletext );
        else
            self.notifytitle settext( notifyData.titletext );

        if ( isdefined( var_3 ) )
            self.notifytitle.glowcolor = var_3;

        self.notifytitle.alpha = 1;
        self.notifytitle fadeovertime( duration * 1.0 );
        self.notifytitle.alpha = 0;
    }

    if ( isdefined( notifyData.textglowcolor ) )
        var_3 = notifyData.textglowcolor;

    if ( isdefined( notifyData.notifytext ) )
    {
        self.notifytext.font = "objective";
        self.notifytext.fonScale = 1.0;
        if ( isdefined( notifyData.textlabel ) )
            self.notifytext.label = notifyData.textlabel;
        else
            self.notifytext.label = &"";

        if ( isdefined( notifyData.textlabel ) && !isdefined( notifyData.textisstring ) )
            self.notifytext setvalue( notifyData.notifytext );
        else
            self.notifytext settext( notifyData.notifytext );

        if ( isdefined( var_3 ) )
            self.notifytext.glowcolor = var_3;

        self.notifytext.alpha = 1;
        self.notifytext fadeovertime( duration * 1.0 );
        self.notifytext.alpha = 0;
        var_4 = self.notifytext;
    }

    if ( isdefined( notifyData.notifytext2 ) )
    {
        self.notifytext2 maps\mp\gametypes\_hud_util::setparent( var_4 );

        if ( isdefined( notifyData.text2label ) )
            self.notifytext2.label = notifyData.text2label;
        else
            self.notifytext2.label = &"";

        self.notifytext2 settext( notifyData.notifytext2 );

        if ( isdefined( var_3 ) )
            self.notifytext2.glowcolor = var_3;

        self.notifytext2.alpha = 1;
        self.notifytext2 fadeovertime( duration * 1.0 );
        self.notifytext2.alpha = 0;
        var_4 = self.notifytext2;
    }

    if ( isdefined( notifyData.iconname ) )
    {
        self.notifyicon maps\mp\gametypes\_hud_util::setparent( var_4 );

        self.notifyicon setshader( notifyData.iconname, 36, 36);

        self.notifyicon.alpha = 0;

        if ( isdefined( notifyData.iconoverlay ) )
        {
            self.notifyicon fadeovertime( 0.15 );
            self.notifyicon.alpha = 1;
            notifyData.overlayoffsety = 0;
            self.notifyoverlay maps\mp\gametypes\_hud_util::setparent( self.notifyicon );
            self.notifyoverlay maps\mp\gametypes\_hud_util::setpoint( "CENTER", "CENTER", 0, notifyData.overlayoffsety );
            self.notifyoverlay setshader( notifyData.iconoverlay, 511, 511 );
            self.notifyoverlay.alpha = 0;
            self.notifyoverlay.color = game["colors"]["orange"];
            self.notifyoverlay fadeovertime( 0.4 );
            self.notifyoverlay.alpha = 0.85;
            self.notifyoverlay scaleovertime( 0.4, 32, 32 );
            maps\mp\gametypes\_hud_message::waitrequirevisibility( duration );
            self.notifyicon fadeovertime( 0.75 );
            self.notifyicon.alpha = 0;
            self.notifyoverlay fadeovertime( 0.75 );
            self.notifyoverlay.alpha = 0;
        }
        else
        {
            self.notifyicon fadeovertime( 1.0 );
            self.notifyicon.alpha = 1;
            maps\mp\gametypes\_hud_message::waitrequirevisibility( duration );
            self.notifyicon fadeovertime( 0.75 );
            self.notifyicon.alpha = 0;
        }
    }
    else
        maps\mp\gametypes\_hud_message::waitrequirevisibility( duration );

    self notify( "notifyMessageDone" );
    self.doingsplash[slot] = undefined;

    if ( self.splashqueue[slot].size )
        thread maps\mp\gametypes\_hud_message::dispatchnotify( slot );
}
