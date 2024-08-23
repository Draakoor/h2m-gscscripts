init()
{
    level endon("game_ended");
    for(;;)
    {
        level waittill("connected", player);
        player notify("luinotifyserver", "team_select", 3); // hardcoded to 3 to allow team select
    }
}
