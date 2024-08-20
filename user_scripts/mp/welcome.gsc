init()
{
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread waitForPlayerSpawn();
    }
}

waitForPlayerSpawn()
{
    self endon("disconnect");
    
    // Wait for the player to spawn in
    self waittill("spawned_player");
    
    // Show the welcome message
    self thread showModernWelcomeMessage();
}

showModernWelcomeMessage()
{
    self endon("disconnect");
    
    // Create blur-like overlay
    blurOverlay = newClientHudElem(self);
    blurOverlay.x = 0;
    blurOverlay.y = 0;
    blurOverlay.alignX = "left";
    blurOverlay.alignY = "top";
    blurOverlay.horzAlign = "fullscreen";
    blurOverlay.vertAlign = "fullscreen";
    blurOverlay.alpha = 0;
    blurOverlay setShader("white", 640, 480);
    blurOverlay.color = (0.1, 0.1, 0.2);
    
    // Create gradient background
    background = newClientHudElem(self);
    background.x = 0;
    background.y = 0;
    background.alignX = "left";
    background.alignY = "top";
    background.horzAlign = "fullscreen";
    background.vertAlign = "fullscreen";
    background.alpha = 0;
    background setShader("gradient", 640, 480);
    background.color = (0.1, 0.1, 0.2);
    
    // Create welcome text
    welcomeText = newClientHudElem(self);
    welcomeText.x = 0;
    welcomeText.y = -50;
    welcomeText.alignX = "center";
    welcomeText.alignY = "middle";
    welcomeText.horzAlign = "center";
    welcomeText.vertAlign = "middle";
    welcomeText.fontScale = 2.5;
    welcomeText.alpha = 0;
    welcomeText.color = (1, 1, 1);
    welcomeText setText("Welcome to FerretOps");
    welcomeText.font = "objective";
    
    // Create subtitle text
    subtitleText = newClientHudElem(self);
    subtitleText.x = 0;
    subtitleText.y = 20;
    subtitleText.alignX = "center";
    subtitleText.alignY = "middle";
    subtitleText.horzAlign = "center";
    subtitleText.vertAlign = "middle";
    subtitleText.fontScale = 1.5;
    subtitleText.alpha = 0;
    subtitleText.color = (0.8, 0.8, 0.8);
    subtitleText setText("IW4Admin is watching...");
    subtitleText.font = "objective";
    
    // Fade in elements
    blurOverlay fadeOverTime(0.5);
    blurOverlay.alpha = 0.7;
    background fadeOverTime(1);
    background.alpha = 0.8;
    welcomeText fadeOverTime(1);
    welcomeText.alpha = 1;
    subtitleText fadeOverTime(1);
    subtitleText.alpha = 1;
    
    wait 5;
    
    // Fade out elements
    blurOverlay fadeOverTime(1.5);
    blurOverlay.alpha = 0;
    background fadeOverTime(1);
    background.alpha = 0;
    welcomeText fadeOverTime(1);
    welcomeText.alpha = 0;
    subtitleText fadeOverTime(1);
    subtitleText.alpha = 0;
    
    wait 1.5;
    
    // Destroy elements
    blurOverlay destroy();
    background destroy();
    welcomeText destroy();
    subtitleText destroy();
}