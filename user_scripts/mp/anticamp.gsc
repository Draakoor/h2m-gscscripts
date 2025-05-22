#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gamelogic;

main()
{
    if (getDvarInt("anticamp") != 1)
        return;

    // Set default Dvars if not defined
    if (!isDefined(getDvar("campTimeLimit")))
        setDvar("campTimeLimit", "5");
    if (!isDefined(getDvar("campDistance")))
        setDvar("campDistance", "100");

    level.campTimeLimit = int(getDvar("campTimeLimit"));
    level.campDistance = int(getDvar("campDistance"));

    // Parse whitelist Dvar
    level.exemptedGUIDs = [];
    if (isDefined(getDvar("anticampwhitelist")))
        level.exemptedGUIDs = getDvarArray("anticampwhitelist");

    level thread anticamp_onPlayerConnect();
}

anticamp_onPlayerConnect()
{
    for (;;)
    {
        level waittill("connected", player);
        player thread anticamp_onPlayerSpawned();
    }
}

anticamp_onPlayerSpawned()
{
    self endon("disconnect");

    self.campTimeLimit = level.campTimeLimit;
    self.campDistance = level.campDistance;
    self.guid = self getGuid();

    if (anticamp_isPlayerWhitelisted(self.guid))
    {
        self iprintlnbold("^2You are exempt from camping rules.");
        return;
    }

    self thread anticamp_monitorCamping();
}

anticamp_monitorCamping()
{
    self endon("disconnect");

    self.lastPosition = self.origin;
    self.lastMoveTime = getTime();
    self.countdownStarted = false;

    for (;;)
    {
        wait(1);

        if (anticamp_usingKillstreak())
        {
            self.lastPosition = self.origin;
            self.lastMoveTime = getTime();
            self.countdownStarted = false;
            continue;
        }

        if (distance(self.lastPosition, self.origin) > self.campDistance)
        {
            self.lastPosition = self.origin;
            self.lastMoveTime = getTime();
            self.countdownStarted = false;
            continue;
        }

        timeStill = (getTime() - self.lastMoveTime) / 1000;
        if (timeStill >= self.campTimeLimit)
        {
            if (!self.countdownStarted)
            {
                self.countdownStarted = true;
                self iprintlnbold("Move or Consequences!");
                wait(3); // Give a short warning period
                if (distance(self.lastPosition, self.origin) > self.campDistance)
                {
                    self.lastPosition = self.origin;
                    self.lastMoveTime = getTime();
                    self.countdownStarted = false;
                    continue;
                }
            }
            // Still camping after warning
            if (self.countdownStarted)
            {
                self suicide();
                self.countdownStarted = false;
                self.lastMoveTime = getTime();
                self.lastPosition = self.origin;
            }
        }
    }
}

anticamp_usingKillstreak()
{
    return isDefined(self.killstreak) && (self.killstreak == "predator_missile" || self.killstreak == "ac130" || self.killstreak == "chopper_gunner");
}

anticamp_isPlayerWhitelisted(guid)
{
    if (!isDefined(level.exemptedGUIDs) || !isArray(level.exemptedGUIDs))
        return false;
    foreach (exemptedGUID in level.exemptedGUIDs)
    {
        if (guid == exemptedGUID)
            return true;
    }
    return false;
}

getDvarArray(dvarName)
{
    dvarString = getDvar(dvarName);
    if (!isDefined(dvarString) || dvarString == "")
        return [];
    return strTok(dvarString, ",");
}
