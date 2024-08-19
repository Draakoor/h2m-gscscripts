#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gamelogic;

main()
{
    if (getDvarInt("anticamp") == 1) {
        // Set default values for Dvars if they are not defined
        if (!isDefined(getDvar("campTimeLimit")))
        {
            setDvar("campTimeLimit", "45"); // Default to 60 seconds
        }
        if (!isDefined(getDvar("campDistance")))
        {
            setDvar("campDistance", "64"); // Default to 64 units
        }

        // Load Dvar values into level variables
        level.campTimeLimit = int(getDvar("campTimeLimit"));
        level.campDistance = int(getDvar("campDistance"));

        // Set up player connection handler
        level thread onPlayerConnect();
    }
}

onPlayerConnect()
{
    while (true)
    {
        level waittill("connected", player);
        player iprintlnbold("This server runs anticamp!");
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");

    // Load Dvars into player-specific variables
    self.campTimeLimit = level.campTimeLimit;
    self.campDistance = level.campDistance;

    // Start monitoring player movement
    self thread monitorPlayerMovement();
}

monitorPlayerMovement()
{
    self endon("disconnect");

    // Initialize player's last position and movement time
    self.lastPosition = self.origin;
    self.lastMoveTime = getTime();
    self.countdownStarted = false;

    while (true)
    {
        wait(1); // Check every second

        self.distanceMoved = distance(self.lastPosition, self.origin);

        if (self.distanceMoved > self.campDistance)
        {
            // Player has moved, reset position and time
            self.lastPosition = self.origin;
            self.lastMoveTime = getTime();
            self.countdownStarted = false; // Reset countdown flag
        }

        // Calculate time difference since last move
        self.timeSinceLastMove = (getTime() - self.lastMoveTime) / 1000; // Convert to seconds

        if (self.timeSinceLastMove >= self.campTimeLimit)
        {
            // Start countdown only if it hasn't been started yet
            if (!self.countdownStarted)
            {
                self.countdownStarted = true;
                self iprintlnbold("Stop camping or face consequences!");

                for (i = 3; i > 0; i--)
                {
                    self iprintlnbold("Suicide in " + i + "...");
                    wait(1);

                    // Check if the player has moved during the countdown
                    self.distanceMoved = distance(self.lastPosition, self.origin);
                    if (self.distanceMoved > self.campDistance)
                    {
                        // Player moved during the countdown, reset countdown
                        self.countdownStarted = false;
                        self.lastPosition = self.origin;
                        self.lastMoveTime = getTime();
                        break;
                    }
                }

                // If countdown completed, punish the player
                if (self.countdownStarted)
                {
                    self suicide(); // Punish by killing the player
                }
            }
        }
    }
}
