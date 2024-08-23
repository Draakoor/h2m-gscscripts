#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_playerlogic;

main()
{
    if (!isDefined(getDvar("switchteamscooldown")))
        {
            setDvar("switchteamscooldown", "60"); // Default to 45 seconds
        }
        if (!isDefined(getDvar("switchteamslimit")))
        {
            setDvar("switchteamslimit", "2"); // Default to 64 units
    }
    level.cooldownTime = int(getDvar("switchteamscooldown")); // Cooldown time in seconds
    level.switchLimit = int(getDvar("switchteamslimit")); // Maximum number of switches per player per game

    level thread onPlayerConnect();
}

onPlayerConnect()
{
    while (true)
    {
        level waittill("connected", player);
        player.switchCount = 0; // Initialize switch count
        player.cooldownEndTime = 0; // Initialize cooldown time
        player thread handleCommands();
    }
}

handleCommands()
{
    self endon("disconnect");

    while (true)
    {
        self waittill("say", msg);

        // Check if the message is the command !switchteams
        if (msg == "!switchteams")
        {
            // Check if the player has reached the switch limit
            if (self.switchCount >= level.switchLimit)
            {
                self iprintlnbold("You have used all your team switches for this game.");
                continue;
            }

            // Check if the player is on cooldown
            currentTime = getTime();
            if (currentTime < self.cooldownEndTime)
            {
                self iprintlnbold("You must wait before switching teams again.");
                continue;
            }

            // Increment the switch count
            self.switchCount++;

            // Set the cooldown end time
            self.cooldownEndTime = currentTime + level.cooldownTime;

            // Notify the player
            self iprintlnbold("You have been switched to the other team. Select your class again please to spawn!");

            // Switch the player's team
            self switchTeams();
        }
    }
}

switchTeams()
{
    currentTeam = self.team;
    newTeam = (currentTeam == "axis") ? "allies" : "axis";
    self notify("menuresponse", "team_marinesopfor", newTeam);
    self maps\mp\gametypes\_menus::setteam(newTeam);
    self thread [[ level.spawnplayer ]]();
}
