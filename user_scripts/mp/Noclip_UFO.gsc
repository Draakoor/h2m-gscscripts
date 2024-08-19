//Created by Matt
//Ported from BO2

init()
{
    level thread on_player_connected();
}

on_player_connected()
{
    level endon("game_ended");

    for(;;)
    {
        level waittill("connected", player);
        player thread on_player_spawned();
    }
}

on_player_spawned()
{
    self endon("disconnect");
    self endon("game_ended");

    for(;;)
    {
        self waittill("spawned_player");
        self thread on_player_spawned();
        self thread UFOMode();
    }
} 

UFOMode()
{
    if(self.UFOMode == false)
    {
        self thread doUFOMode();
        self.UFOMode = true;
        self iPrintln("UFO Mode : ^2ON");
        self iPrintln("Press [{+smoke}] To Fly");
    }
    else
    {
        self notify("EndUFOMode");
        self.UFOMode = false;
        self iPrintln("UFO Mode : ^1OFF^7");
    }
}

doUFOMode()
{
    self endon("EndUFOMode");
    self.Fly = 0;
    UFO = spawn("script_model",self.origin);
    for(;;)
    {
        if(self secondaryoffhandbuttonpressed())
        {
            self playerLinkTo(UFO);
            self.Fly = 1;
        }
        else
        {
            self.Fly = 0;
        }
        if(self AdsButtonPressed() && self.fly == 0)
        {
            self unlink();
            self.Fly = 0;
            self.UFo delete();
        }
        if(self.Fly == 1)
        {
            Fly = self.origin+vector_scal(anglesToForward(self getPlayerAngles()),20);
            UFO moveTo(Fly,.03);
        }
        wait .001;
    }
}

vector_scal(vec, scale)
{
    vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
    return vec;
}