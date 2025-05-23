init() {
    level thread player_connect_event();
}

player_connect_event() {
    while( true ) {
        level waittill( "connected", player );
        
        // Log player name and XUID with a unique prefix
        logPrint("XUID_LOG: PlayerConnected: " + player.name + "'s XUID is: " + player.xuid + "\n");
    }
}