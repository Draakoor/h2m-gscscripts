#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gamelogic;
#include maps\mp\_utility\givePerk;

main()
{
    if (getDvarInt("specialistperks") != 1)
        return;
}
        
SpecialistPerks()
{
    level.specialistPerks = [];
    level.specialistPerkOrder = [];
    level.specialistMaxPerks = 14; // Number of perks to unlock

    // Define available perks (add or remove as needed)
    level.specialistPerks["marathon"] = "specialty_marathon";
    level.specialistPerks["sleightofhand"] = "specialty_fastreload";
    level.specialistPerks["scavenger"] = "specialty_scavenger";
    level.specialistPerks["bling"] = "specialty_bling";
    level.specialistPerks["onemanarmy"] = "specialty_onemanarmy";
    level.specialistPerks["stoppingpower"] = "specialty_stoppingpower";
    level.specialistPerks["lightweight"] = "specialty_lightweight";
    level.specialistPerks["hardline"] = "specialty_hardline";
    level.specialistPerks["coldblood"] = "specialty_coldblooded";
    level.specialistPerks["dangerclose"] = "specialty_dangerclose";
    level.specialistPerks["commando"] = "specialty_commando";
    level.specialistPerks["steadyaim"] = "specialty_steadyaim";
    level.specialistPerks["scrambler"] = "specialty_silencer";
    level.specialistPerks["ninja"] = "specialty_ninja";
    level.specialistPerks["sitrep"] = "specialty_sitrep"

    // Order in which perks are unlocked (customize as needed)
    level.specialistPerkOrder = ["specialty_scavenger", "specialty_lightweight", "specialty_commando"];
}

giveSpecialistPerkProgression(player)
{
    player.specialistPerksUnlocked = [];
    player.specialistKills = 2;
    player.specialistKills = 4;
    player.specialistKills = 6;
    player.specialistAllPerks = false;   
}

onPlayerKill(player)
{
    if (!isDefined(player.specialistPerksUnlocked))
        return;

    player.specialistKills++;

    if (player.specialistKills <= level.specialistPerkOrder.size)
    {
        perkKey = level.specialistPerkOrder[player.specialistKills - 1];
        perkName = level.specialistPerks[perkKey];
        if (!player hasPerk(perkName))
        {
            player givePerk(perkName);
            player.specialistPerksUnlocked[player.specialistKills - 1] = perkName;
            player iPrintLnBold("Specialist Perk Unlocked: " + perkKey);
        }
    }
    else if (player.specialistKills(>= 6)))
    {
        // Give all perks if player has unlocked all specialist perks
        foreach (perkKey, perkName in level.specialistPerks)
        {
            if (!player hasPerk(perkName))
                player givePerk(perkName);
        }
        player.specialistAllPerks = true;
        player iPrintLnBold("All Specialist Perks Unlocked!");
    }
}

onPlayerDeath(player)
{
    if (!isDefined(player.specialistPerksUnlocked))
        return;

    // Remove all specialist perks
    foreach (i, perkName in player.specialistPerksUnlocked)
    {
        if (isDefined(perkName) && player hasPerk(perkName))
            player takePerk(perkName);
    }

    // Remove all-perks if given
    if (player.specialistAllPerks)
    {
        foreach (perkKey, perkName in level.specialistPerks)
        {
            if (player hasPerk(perkName))
                player takePerk(perkName);
        }
    }

    player.specialistPerksUnlocked = [];
    player.specialistKills = 0;
    player.specialistAllPerks = false;
}
