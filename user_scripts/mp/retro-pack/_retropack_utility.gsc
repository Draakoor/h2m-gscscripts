/*
  _____  ______ _______ _____   ____    
 |  __ \|  ____|__   __|  __ \ / __ \   
 | |__) | |__     | |  | |__) | |  | |  
 |  _  /|  __|    | |  |  _  /| |  | |  
 | | \ \| |____   | |  | | \ \| |__| |  
 |_|__\_\______|__| | /|_| _\_\\____/__                   
 | '_ \ / _` |/ __| |/ / _` |/ _` |/ _ \
 | |_) | (_| | (__|   < (_| | (_| |  __/
 | .__/ \__,_|\___|_|\_\__,_|\__, |\___|
 | |                          __/ |     
 |_|                         |___/   

Version: 0.9.1
Date: August 18, 2024
Compatibility: Modern Warfare Remastered (HM2 Mod)
*/
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;


getName()
{
	nT=getSubStr(self.name,0,self.name.size);
	for(i=0;i<nT.size;i++)
	{
		if(nT[i]=="]")
			break;
	}
	if(nT.size!=i)
		nT=getSubStr(nT,i+1,nT.size);
	return nT;
}

changeTheme( color )
{
    self.hud.title.glowColor = color;
    self.hud.title fadeOverTime(3);

    self.hud.leftBar.color = color;
    self.hud.leftBar fadeOverTime(3);

    self.hud.rightBar.color = color;
    self.hud.rightBar fadeOverTime(3);

    self.hud.topBar.color = color;
    self.hud.topBar fadeOverTime(3);

    self.hud.topSeparator.color = color;
    self.hud.topSeparator fadeOverTime(3);

    self.hud.bottomSeparator.color = color;
    self.hud.bottomSeparator fadeOverTime(3);

    self.hud.bottomBar.color = color;
    self.hud.bottomBar fadeOverTime(3);

    self.hud.scroller.color = color;
    self.hud.scroller fadeOverTime(3);
    
    self.theme = color;
}

createTextElem(font, fontscale, align, relative, x, y, sort, color, alpha, glowColor, glowAlpha, text)
{
    fontElem = CreateFontString( font, fontscale );
    fontElem setPoint( align, relative, x, y );
    fontElem.sort = sort;
    fontElem.type = "text";
    fontElem setText(text);
    fontElem.color = color;
    fontElem.alpha = alpha;
    fontElem.glowColor = glowColor;
    fontElem.glowAlpha = glowAlpha;
    fontElem.hideWhenInMenu = true;
    return fontElem;
}

createBarElem(align, relative, x, y, width, height, color, alpha, sort, shader)
{
    barElemBG = newClientHudElem( self );
    barElemBG.elemType = "bar";
    if ( !level.splitScreen )
    {
        barElemBG.x = -2;
        barElemBG.y = -2;
    }
    barElemBG.width = width;
    barElemBG.height = height;
    barElemBG.align = align;
    barElemBG.relative = relative;
    barElemBG.xOffset = 0;
    barElemBG.yOffset = 0;
    barElemBG.children = [];
    barElemBG.color = color;
    barElemBG.alpha = alpha;
    barElemBG setShader( shader, width , height );
    barElemBG.hidden = false;
    barElemBG.sort = sort;
    barElemBG setPoint(align, relative, x, y);
    return barElemBG;
}

abortForfeit()
{
    self endon("disconnect");
    for(;;)
    {
        if(isDefined(level.forfeitInProgress) && level.forfeitInProgress == true)
            level notify("abort_forfeit");

        wait .1;
    }
}

vector_scale(vec, scale)
{
	vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
	return vec;
}

toYou(player)
{
	player setOrigin(self.origin);
	if(player.pers["team"] == self.pers["team"])
	{
		if (isSubStr( player.guid, "bot" ))
		{
			player.pers["friendlybotorigin"] = player.origin;
			player.pers["friendlybotangles"] = player.angles;
			player.pers["friendlybotspotstatus"] = "saved";
		}
	}
	else if(player.pers["team"] != self.pers["team"])
	{
		if (isSubStr( player.guid, "bot" ))
		{
			player.pers["enemybotorigin"] = player.origin;
			player.pers["enemybotangles"] = player.angles;
			player.pers["enemybotspotstatus"] = "saved";
		}
	}
	self iprintln(player + " has been teleported to you");
	player iprintln("^1" + self + " has teleported you");
}

toCross(player)
{
	forward = self getTagOrigin("j_head");
	end = vectorScale(anglestoforward(self getPlayerAngles()), 1000000);
	Location = BulletTrace( forward, end, false, self )["position"];
	player setOrigin(Location);
	if(player.pers["team"] == self.pers["team"])
	{
		if (isSubStr( player.guid, "bot" ))
		{
			player.pers["friendlybotorigin"] = player.origin;
			player.pers["friendlybotangles"] = player.angles;
			player.pers["friendlybotspotstatus"] = "saved";
		}
	}
	else if(player.pers["team"] != self.pers["team"])
	{
		if (isSubStr( player.guid, "bot" ))
		{
			player.pers["enemybotorigin"] = player.origin;
			player.pers["enemybotangles"] = player.angles;
			player.pers["enemybotspotstatus"] = "saved";
		}
	}
	self iprintln(player + " has been teleported to your crosshairs");
	player iprintln("^1" + self + " has teleported you");
}

vectorScale( vector, scale ) //vector
{
	return ( vector[0] * scale, vector[1] * scale, vector[2] * scale );
}


toKill(p)
{
	p suicide();
	self iPrintln("^7" + p.name + " ^1Killed");
	p iprintln("^1" + self + " has killed you");
}

toFreeze(p)
{
	if(p.freezeClient == 1)
	{
		p.freezeClient = 0;
		p freezeControls(true);
		p iPrintln("You were ^1Frozen ^7by " + self);
		self iPrintln("You ^1Froze ^7" + p.name);
	}
	else if(p.freezeClient == 0)
	{
		p.freezeClient = 1;
		p freezeControls(false);
		p iPrintln("You were ^2Unfrozen ^7by " + self);
		self iPrintln("You ^2Unfroze ^7" + p.name);
	}
}

toKick(p)
{
	kick(p getEntityNumber());
	self iPrintln("^7" + p.name + " ^1Kicked");
}

toStance(p)
{
	if (isSubStr( p.guid, "bot"))
	{
		p freezeControls(true);
	}
    if(p.Stance == "Stand")
    {
        p.Stance = "Crouch";
		p SetStance( "crouch" );
    }
    else if(p.Stance == "Crouch")
    {
		p.Stance = "Prone";
		p SetStance( "prone" );
    }
	else if(p.Stance == "Prone")
    {
		p.Stance = "Stand";
		p SetStance( "stand" );
    }
	self iprintln(p + "'s stance has changed to: ^2" + p.Stance);
	p iprintln("^1" + self + " has changed your stance");
}