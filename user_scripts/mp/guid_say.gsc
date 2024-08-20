init() {
    level thread player_connect_event();
}

player_connect_event() {
    while( true ) {
        level waittill( "connected", player );

        executeCommand("say " + player.name +"'s  GUID is: " + player.guid );
    }
}
