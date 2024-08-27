/*
    Author:         Zyrus1337
    Creation Year:  2024
    Git: https://github.com/ZxY137/H2MCMD
*/
init() {
    level thread command_listener();
    level.systemName = "[^:H2M-CMD^7] ";
    level.adminList = ["YOUR-XUID"];
}
isInArray(array, value)
{
    for (i = 0; i < array.size; i++)
    {
        if (array[i] == value)
        {
            return true;
        }
    }
    return false;
}

tell_sender(var_1){
    executeCommand("tellraw t "+level.systemName+ var_1);
}
announce(txt){
    executeCommand("sayraw "+level.systemName + txt);
}

listCommands(player) {
    commands = [
        "!test",
        "!test-admin",
        "!kick [player]",
        "!ban [player]",
        "!warn [player]",
        "!tp [player1] [player2]",
        "!givexp [player] [amount]",
        "!kill [player]",
        "!switch [player]",
        "!exec [command]",
        "!help [cmd]"
    ];

    commandList = "Available Commands: ";
    for(i = 0; i < commands.size; i++) {
        if((commandList.size + commands[i].size + 2) > 100) {  // Check if adding another command would exceed the limit
            tell_sender(commandList);
            commandList = "";  // Reset for the next batch
        }
        commandList += commands[i] + ", ";
    }
    if(commandList != "") {  // Send any remaining commands
        tell_sender(commandList);
    }
}

commandHelp(player, cmd) {
    helpText = "";

    switch(cmd) {
        case "!test":
            helpText = "!test - Test command, returns 'Test OK!'.";
            break;
        case "!test-admin":
            helpText = "!test-admin - Admin-only command, returns 'Test Admin OK!' if the user is an admin.";
            break;
        case "!kick":
            helpText = "!kick [player] - Kicks the specified player from the server.";
            break;
        case "!ban":
            helpText = "!ban [player] - Bans the specified player from the server.";
            break;
        case "!giveXP":
            helpText = "!giveXP [player] [amount] - Gives the specified player a certain amount of XP.";
            break;
        case "!warn":
            helpText = "!warn [player] - Warns the specified player.";
            break;
        case "!tp":
            helpText = "!tp [player1] [player2] - Teleports player1 to player2.";
            break;
        case "!kill":
            helpText = "!kill [player] - Kills the specified player.";
            break;
        case "!switch":
            helpText = "!switch [player] - Switches the specified player's team.";
            break;
        case "!exec":
            helpText = "!exec [command] - Executes a server command.";
            break;
        case "!help":
            helpText = "!help [cmd] - Shows help for the specified command.";
            break;
        default:
            helpText = "No help available for " + cmd;
            break;
    }
    
    tell_sender(helpText);
}
getPlayerByPartialName(partialName) {
    matches = [];
    partialName = toLower(partialName);  // Convert to lowercase for case-insensitive matching

    foreach (player in level.players) {
        playerNameLower = toLower(player.name);
        if (issubstr(playerNameLower, partialName)) {
            matches[matches.size] = player;
        }
    }

    if (matches.size == 1) {
        return matches[0];
    } else if (matches.size > 1) {
        tell_sender("Too many matches: " + joinPlayerNames(matches));
        return undefined;
    }

    return undefined;
}

joinPlayerNames(players) {
    names = "";
    for(i = 0; i < players.size; i++) {
        names += players[i].name;
        if (i < players.size - 1) {
            names += ", ";
        }
    }
    return names;
}

command_listener(){
    admins = level.adminList;
    self endon("disconnect");
    
    while (true){
        self waittill("say", player, message);
        if (getsubstr(message, 0, 1) == "!"){

            args = strTok(message, " ");  // Split message into arguments
            args[0] = toLower(args[0]); 
            switch(args[0]){
                case "!test":
                    tell_sender("Test OK!");
                    break;
                    
                case "!test-admin":
                    if(isInArray(admins, player.xuid)){
                        tell_sender("Test Admin OK!");
                    } else {
                        tell_sender("not enough permissions");
                    }
                    break;
                    
                case "!kick":
                    if(isInArray(admins, player.xuid)){
                        if(args.size >= 2){
                            targetPlayer = getPlayerByPartialName(args[1]);
                            if(targetPlayer != undefined){
                                kickPlayer(targetPlayer);
                                announce("Kicked player " + targetPlayer.name);

                            } else {
                                tell_sender("Player not found");
                            }
                        } else {
                            tell_sender("Please specify a player name");
                        }
                    } else {
                        tell_sender("not enough permissions");
                    }
                    break;
                    
                case "!ban":
                    if(isInArray(admins, player.xuid)){
                        if(args.size >= 2){
                            targetPlayer = getPlayerByPartialName(args[1]);
                            if(targetPlayer != undefined){
                                banPlayer(targetPlayer);
                                announce("Banned player " + targetPlayer.name);
                            } else {
                                tell_sender("Player not found");
                            }
                        } else {
                            tell_sender("Please specify a player name");
                        }
                    } else {
                        tell_sender("not enough permissions");
                    }
                    break;
                    
                case "!warn":
                    if(isInArray(admins, player.xuid)){
                        if(args.size >= 2){
                            targetPlayer = getPlayerByPartialName(args[1]);
                            if(targetPlayer != undefined){
                                warnPlayer(targetPlayer);
                                announce("Warned player " + targetPlayer.name);
                            } else {
                                tell_sender("Player not found");
                            }
                        } else {
                            tell_sender("Please specify a player name");
                        }
                    } else {
                        tell_sender("not enough permissions");
                    }
                    break;
                    
                case "!tp":
                    if(isInArray(admins, player.xuid)){
                        if(args.size >= 3){
                            targetPlayer1 = getPlayerByPartialName(args[1]);
                            targetPlayer2 = getPlayerByPartialName(args[2]);
                            if(targetPlayer1 != undefined && targetPlayer2 != undefined){
                                teleportPlayer(targetPlayer1, targetPlayer2);
                                tell_sender("Teleported " + targetPlayer1.name + " to " + targetPlayer2.name);
                            } else {
                                tell_sender("One or both players not found");
                            }
                        } else {
                            tell_sender("Please specify two player names");
                        }
                    } else {
                        tell_sender("not enough permissions");
                    }
                    break;
                    
                case "!kill":
                    if(isInArray(admins, player.xuid)){
                        if(args.size >= 2){
                            targetPlayer = getPlayerByPartialName(args[1]);
                            if(targetPlayer != undefined){
                                killPlayer(targetPlayer);
                                tell_sender("Killed player " + targetPlayer.name);
                            } else {
                                tell_sender("Player not found");
                            }
                        } else {
                            tell_sender("Please specify a player name");
                        }
                    } else {
                        tell_sender("not enough permissions");
                    }
                    break;
                    
                case "!switch":
                    if(isInArray(admins, player.xuid)){
                        if(args.size >= 2){
                            targetPlayer = getPlayerByPartialName(args[1]);
                            if(targetPlayer != undefined){
                                switchTeam(targetPlayer);
                                announce("Switched team of player " + targetPlayer.name);
                            } else {
                                tell_sender("Player not found");
                            }
                        } else {
                            tell_sender("Please specify a player name");
                        }
                    } else {
                        tell_sender("not enough permissions");
                    }
                    break;

                case "!exec":
                   if(isInArray(admins, player.xuid)){
                        if(args.size >= 2){
                            command = "";
                            for(i = 1; i < args.size; i++){
                                command += args[i];
                                if (i < args.size - 1) {
                                    command += " ";  // Add space between arguments
                                }
                            }
                            executeCommand(command);
                            tell_sender("Executed command: " + command);
                        } else {
                            tell_sender("Please specify a command to execute");
                        }
                    } else {
                        tell_sender("not enough permissions");
                    }
                    break;

                case "!commands":
                    listCommands(player);
                    break;

                case "!help":
                    if(args.size >= 2) {
                        commandHelp(player, args[1]);
                    } else {
                        tell_sender("Please specify a command for help.");
                    }
                    break;
                case "!givexp":
                    if(isInArray(admins, player.xuid)){
                        if(args.size >= 3){
                            targetPlayer = getPlayerByPartialName(args[1]);
                            xpAmount = int(args[2]);  // Convert the XP amount to an integer
                            if(targetPlayer != undefined){
                                giveXPPlayer(targetPlayer, xpAmount);
                                tell_sender("Gave " + xpAmount + " XP to player " + targetPlayer.name);
                            } else {
                                tell_sender("Player not found");
                            }
                        } else {
                            tell_sender("Please specify a player name and an XP amount");
                        }
                    } else {
                        tell_sender("not enough permissions");
                    }
                    break;
                default:
                    tell_sender("Unknown Command");
                    break;
            }
        }
    }
}

getPlayerByName(name) {
    foreach (player in level.players) {
        if (player.name == name) {
            return player;
        }
    }
    return undefined;
}

kickPlayer(player) {
    kick(player getentitynumber(), "Kicked by an admin.");
}

banPlayer(player) {
    // Add player to ban list (implement your ban logic here)
    kick(player getentitynumber(), "Banned by an admin.");
}

warnPlayer(player) {
    player maps\mp\_utility::freezecontrolswrapper( 1 );

    player VisionSetNakedForPlayer("black_bw", 1);
    player setclienttriggervisionset("black_bw", 1);
    
    //classic way
    //player iPrintlnBold("^1Warning: ^7You have been warned by an admin.");
    /*notifyData = spawnstruct();
	notifyData.titleText = "^1 You have been warned by an Admin";
	notifyData.notifyText = "^:Be careful! Any further violation";
	notifyData.iconName = "i_infect_eye_unlit_c";
	notifyData.glowColor = (0, 1, 0);
	notifyData.notifyText2 = "^1may result in a Kick/Ban";
	notifyData.duration = 5;
    */
	player thread maps\mp\gametypes\_hud_message::oldnotifyMessage("^1 You have been warned by an Admin","^:Be careful! Any further violation result in Kick/Ban","headicon_dead",(0, 1, 0),"",7);

    wait(4);

    player VisionSetNakedForPlayer("",1);
    player setclienttriggervisionset("", 1);
    player maps\mp\_utility::freezecontrolswrapper( 0 );
}

teleportPlayer(player1, player2) {
    player1 setOrigin(player2.origin);
}

killPlayer(player) {
    player suicide();
}

switchTeam(player) {
    player.team = player.team == "axis" ? "allies" : "axis";
    player suicide();
}
giveXPPlayer(player, amount) {
    player maps\mp\gametypes\_rank::giverankxp("kill", amount);
    player maps\mp\_utility::logxpgains();
    player iPrintlnBold("^2You have been given " + amount + " XP.");
}
