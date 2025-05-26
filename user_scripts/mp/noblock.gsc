#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gamelogic;

init()
{   
    if (getDvarInt("noblock") == 1) {
    setdvar("g_playerCollision", 0);
    setdvar("g_playerEjection", 0);
    }
}
