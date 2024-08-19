#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level thread hudLoop();
}

hudLoopBOTTOM()
{
	info = level createServerFontString("objective", 0.95);
	info setPoint("CENTER", "BOTTOM", 0, -10);
	info.glowalpha = .6;
	info.hideWhenInMenu = true;

	while (true)
	{
		info.glowcolor = ( .7, .3, 1 );
		info setText("Draakkoor's Servernetwork");
		wait 20;
		info.glowcolor = ( 0, 1, 0 );
		info setText("discord.gg/Jx6xXPb6KF");
		wait 14;
		info.glowcolor = ( 1, 0, 0 );
		info setText("Join our community!");
		wait 8;
	}
}
