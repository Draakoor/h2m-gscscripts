init()
{
	if( getdvar("sv_hostname") == "SERVER_NAME" || getdvar("sv_hostname") == "SERVER_NAME" )
	{
		wait 5;
		executecommand("spawnbot 11");
	}
	else
	{
    	if (isBotServer())
		{
			wait 5;
			executecommand("spawnbot 17");
		}
	}

	level.callbackplayerdisconnect_og = level.callbackplayerdisconnect;
	level.callbackplayerdisconnect = ::callbackplayerdisconnect_stub;
}

callbackplayerdisconnect_stub(reason)
{
	// spawn another bot when a player leaves
	executecommand("spawnbot 1");

	[[ level.callbackplayerdisconnect_og ]](reason);
}

isBotServer()
{
	port = getDvar("net_port");

	switch (port)
	{
		case "27016":
		case "27017":
		case "27018":
		case "27019":
			return true;
		default:
			return false;
	}
}
