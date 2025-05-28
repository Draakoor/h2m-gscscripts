// patch v2

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    if (getDvarInt("cranked") == 1){
        level.cranked = false;
        level thread on_player_connect();
    }
}


on_player_connect(){
    level endon("game ended");
    
    for(;;){
        level waittill("connected", player);
        player thread on_player_spawn();
    }
}


on_player_spawn(){
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");
        wait 0.2;
        self cranked();

    }

} 

showCrankedTimer(seconds)
{
    level endon("game ended");
    self endon("disconnect");
    self endon("death");
    self endon("stop_cranked_timer");

    if (!isDefined(seconds) || seconds <= 0)
        seconds = 20;

    if (isDefined(self.crankedTimer))
        self.crankedTimer destroy();

    // Create HUD Element
    self.crankedTimer = newClientHudElem(self);
    self.crankedTimer.alignX = "center";
    self.crankedTimer.alignY = "middle";
    self.crankedTimer.horzAlign = "center";
    self.crankedTimer.vertAlign = "middle";
    self.crankedTimer.x = -170;
    self.crankedTimer.y = 135; // match box y prev = 135
    self.crankedTimer.fontScale = 1.7;
    self.crankedTimer.color = (1, 1, 1); // white
    self.crankedTimer.alpha = 1;
    self.crankedTimer.sort = 1;

    timeRemaining = float(seconds);

    for (;;)
    {
        self.crankedTimer setValue(roundToDecimalPlaces(timeRemaining,1));
        wait(0.1);
        timeRemaining -= 0.1;

        if (timeRemaining <= 0){
            break;
        }
            
    }

    self.crankedTimer setValue("0.0");
    self suicide();
    self.crankedTimer.alpha = 0;

    wait 0.3;
    self.crankedTimer destroy();

}



cranked()
{
    self endon("disconnect");

    self.cranked = false;
    self.adsSpeedBoostActive = false;

    // timer
    
    // Cranked timer
    self.crankedHud = newClientHudElem(self);
    self.crankedHud.alignX = "center";
    self.crankedHud.alignY = "top";
    self.crankedHud.horzAlign = "center";
    self.crankedHud.vertAlign = "top";
    self.crankedHud.x = -170;
    self.crankedHud.y = 361;
    self.crankedHud.alpha = 0;
    self.crankedHud.color = (0.133, 0.439, 0.415); 
    self.crankedHud setShader("white", 100, 30); 
    self.crankedHud.sort = 0;

    // Cranked text
    self.crankedText = newClientHudElem(self);
    self.crankedText.alignX = "center";
    self.crankedText.alignY = "middle";
    self.crankedText.horzAlign = "center";
    self.crankedText.vertAlign = "middle";
    self.crankedText.x = -170;
    self.crankedText.y = 160; // match box y
    self.crankedText.fontScale = 1.3;
    self.crankedText.color = (1, 1, 1); // white
    self.crankedText.alpha = 0;
    self.crankedText setText("CRANKED");

    // Black box
    self.crankedBlack = newClientHudElem(self);
    self.crankedBlack.alignX = "center";
    self.crankedBlack.alignY = "top";
    self.crankedBlack.horzAlign = "center";
    self.crankedBlack.vertAlign = "top";
    self.crankedBlack.x = -170;
    self.crankedBlack.y = 390;
    self.crankedBlack.alpha = 0;
    self.crankedBlack.color = (0, 0, 0); 
    self.crankedBlack setShader("white", 100, 20); 

    previous = 0;
    for (;;)
    {
        
        if (self.killstreakcount >= 1)
        {
            if(self.killstreakcount != previous && self.cranked){
                self notify("stop_cranked_timer");
                self thread showCrankedTimer(20);
                previous = self.killstreakcount;
            }


            // Show CRANKED message once
            if (!self.cranked)
            {
                self.cranked = true;
                self SetMoveSpeedScale(1.1);

                self.crankedHud.alpha = 0.5;
                self.crankedText.alpha = 1;
                self.crankedBlack.alpha = 0.5;
                maps\mp\_utility::giveperk("specialty_fastreload",0);
                maps\mp\_utility::giveperk("specialty_quickdraw", 0);
                maps\mp\_utility::giveperk("specialty_fastmantle", 0);
                maps\mp\_utility::giveperk("specialty_longersprint", 0);
                

                self thread showCrankedTimer(20);
            }

            // Only change speed on ADS state change
            if (self PlayerADS())
            {
                if (!self.adsSpeedBoostActive)
                {
                    self SetMoveSpeedScale(1.5);
                    self.adsSpeedBoostActive = true;
                }
            }
            else
            {
                if (self.adsSpeedBoostActive)
                {
                    self SetMoveSpeedScale(1.1);
                    self.adsSpeedBoostActive = false;
                }
            }
        }
        else
        {
            // Reset flags if killstreak ends
            if (self.cranked || self.adsSpeedBoostActive)
            {
                self SetMoveSpeedScale(1.0);
                self.adsSpeedBoostActive = false;
                self.cranked = false;

                self.crankedHud.alpha = 0;
                self.crankedText.alpha = 0;
                self.crankedBlack.alpha = 0;
                self.crankedTimer.alpha = 0;
                previous = 0;
                
                self notify("stop_cranked_timer");

            }

        }

        wait(0.1); 
    }

    
}

roundToDecimalPlaces(number, places)
{
    multiplier = 1;
    for (i = 0; i < places; i++)
        multiplier *= 10;

    return int(number * multiplier + 0.5) / multiplier;
}