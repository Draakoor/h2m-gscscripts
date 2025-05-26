#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    if (getDvarInt("cranked") == 1){
        initTimerStrings();
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

initTimerStrings()
{
    // Integer parts from 0 to 25
    level.timerIntStrings = [];
    for (i = 0; i <= 25; i++)
    {
        level.timerIntStrings[i] = i + ".";
    }

    // Decimal parts from 0 to 9
    level.timerDecimalStrings = [];
    for (d = 0; d <= 9; d++)
    {
        level.timerDecimalStrings[d] = d + ""; // Convert int to string
    }
}

showCrankedTimer(seconds)
{
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
    self.crankedTimer.y = 135; // match box y
    self.crankedTimer.fontScale = 1.7;
    self.crankedTimer.color = (1, 1, 1); // white
    self.crankedTimer.alpha = 1;

    timeRemaining = float(seconds);
    lastInt = -1;
    lastDec = -1;

    for (;;)
    {
        intPart = int(timeRemaining);
        decPart = int((timeRemaining - intPart) * 10);

        // messy stuff tried fixing overflow range
        if (intPart < 0) intPart = 0;
        if (intPart > 25) intPart = 25;
        if (decPart < 0) decPart = 0;
        if (decPart > 9) decPart = 9;

        if (intPart != lastInt || decPart != lastDec)
        {
            self.crankedTimer setText(level.timerIntStrings[intPart] + level.timerDecimalStrings[decPart]);
            lastInt = intPart;
            lastDec = decPart;
        }

        wait(0.05);
        timeRemaining -= 0.05;

        if (timeRemaining <= 0)
            break;
    }

    self.crankedTimer setText("0.0");
    self suicide();
    self.crankedTimer fadeOverTime(1);
    self.crankedTimer.alpha = 0;
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
                    self.movement;
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