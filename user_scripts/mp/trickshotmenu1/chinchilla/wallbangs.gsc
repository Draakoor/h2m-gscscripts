#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud;
#include maps\mp\gametypes\_hud_util;

init()
{
    if (getDvarInt("enable_wallbangs") == 1) {
        setdvar("perk_bulletPenetrationMultiplier", 30);
        setdvar("bg_surfacePenetration", 9999);
        setdvar("penetrationCount", 9999);
        setdvar("perk_armorPiercing", 9999);
        setdvar("bullet_ricochetBaseChance", 0.95);
        setdvar("bullet_penetrationMinFxDist", 1024);
        setdvar("bulletrange", 50000);

        setdynamicdvar("perk_bulletPenetrationMultiplier", 30);
        setdynamicdvar("bg_surfacePenetration", 9999);
        setdynamicdvar("penetrationCount", 9999);
        setdynamicdvar("perk_armorPiercing", 9999);
        setdynamicdvar("bullet_ricochetBaseChance", 0.95);
        setdynamicdvar("bullet_penetrationMinFxDist", 1024);
        setdynamicdvar("bulletrange", 50000);
    }
}