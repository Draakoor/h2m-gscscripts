![H2M](https://github.com/user-attachments/assets/42656b5e-5052-457d-a780-bc8f5fa22df3)

# h2m_gscs
This is a collection of our GSCs. Credits are included in each script respectively or in the readme.

Buy me a coffe if you want: [click](https://paypal.me/draakoor)
# Install steps
Steps are super simple so I will keep it high level.

* Drop the scripts into `.\h2m-mod\user_scripts\mp\`.
* Some scripts require a DVAR to enable / disable, use where required.

# Which scripts are available?

* Specialist Perks
  * Adds the specialist killstreak from original mw3 back to the game
  * Set specialistperks 1 in your server.cfg (is enabled for all)
  * order can be customized in the gsc

* Dropzone
  * https://callofduty.fandom.com/wiki/Drop_Zone
  * Make sure you set the gametype to hardpoint
  * Only working on open maps (no maps with building fights like broadcast)

* Cranked
  * Adds the gamemode from call of duty ghosts
  * you get a speedboost and some perks after you killed someone
  * keep your streak going or you explode

* TI Speed
  * Almost instantly deploys tactical insertion

* Sniper selector
  * Adds chat commands so player can choose sniper
  * Script will remember your choice for the whole round/map
  * Commands: !weaponmenu, !intervention, !barrett, !wa2000, !m40, !as50, !msr

* Sniper Only
  * Only Snipers are allowed, other weapons will be replaced, throwingknife and tactical insertion allowed. Perk replacing is working at the moment
  * Enable/Disable DVAR `set sniperport "0"` (off) or `set sniperport "1"` (on)

* Restrict Weapons
  * Multiple scripts for restricting weapon types
  * Enable/Disable DVAR  are `set noshotty/nolaunchers/nogl/nosniper/boltsonly/nolmgs/removenades/noakimbo "1"` (on) or `set noshotty/nolaunchers/nogl/nosniper/boltsonly/nolmgs/removenades/noakimbo "0"` (off) (note: each script needs its own dvar)

* Anticamp
  * Punishes player that are not moving in a period of time
  * Enable/Disable DVAR `set anticamp "0"` (off) or `set anticamp "1"` (on)
  * You can set the timer for camptime with `set campTimeLimit "45"`
  * You can set the distance that needs to be traveld with `set campDistance "65"`
  * You can whitelist campers with `set anticampwhitelist "yourguid,yourguid"`

* Restrict Killstreaks
  * Allows you to restrict killstreaks
  * Choose disabled killstreaks with `set streaksRestricted "radar_mp counter_radar_mp airdrop_marker_mp sentry_mp predator_mp airstrike_mp harrier_airstrike_mp helicopter_mp airdrop_mega_marker_mp stealth_airstrike_mp pavelow_mp chopper_gunner_mp ac130_mp emp_mp nuke_mp"`

* Replace Killstreaks
  * Replaces killstreaks with the one which is in the script (at the moment uav drone)
  * Enable/Disable DVAR `set enableRestrictedKillstreaks "0"` (off) or `set enableRestrictedKillstreaks "1"` (on)
  * To change killstreak you must edit the the script.
 
* Private Matches
  * Allows to earn exp in private matches
 
* Welcome
  * Shows a welcome message to players after joining and spawning for the first time.

* Exo Movement
  * Allows to double jump, dash and slam like in advanced warfare
  * Enable/Disable DVAR `set exomovment "0"` (off) or `set exomovment "1"` (on)
    
* Misc
  * Enables Elevators at the moment
  * Enables sv_cheats to 1
 
* Wallbang everything
  * Allows wallbanging everything
  *  Enable/Disable DVAR `enable_wallbangs "0"` (off) or `enable_wallbangs "1"` (on)
 
* Bots
  * Spawns bots automaticlly
  * You need to add your server port in the script
 
 * Switchteams
  * Allows Players to switch teams with the command `!switchteams` but only 2 times with a cooldown of 60 seconds, server does automaticlly autobalance
  * DVAR Cooldown `set switchteamscooldown 60` and DVAR Limit `set switchteamslimit 2`
 
* Retropack/Trickshotmenu
  * Trickshot Scripts

* Allow Team Selection
  * This is a client script, which allows to select teams after connecting to a dedicated server

 * WIP Scripts
  * These scripts are not supported and might be unstable or dont work!
 
* More scripts coming soon!

# References

[H2M GSC Dump](https://github.com/Jeffx539/h2m-gsc-dump/tree/main)

# More Scripts
* Check Xevrac's repo as well: [Xevra's Repo](https://github.com/Xevrac/h2m_gscs)
* DoktorSAS Mapvote and VanityTS [Trickshot](https://github.com/DoktorSAS/VanityTS) ~~[Mapvote](https://github.com/DoktorSAS/H1Mapvote/tree/main)~~ [General Scripts](https://github.com/DoktorSAS/GSC/tree/main) Nightshade ready: [My Version of DoctorSAS Mapvote](https://github.com/Draakoor/H1Mapvote/tree/main)
* Justin's Retropack [His Repo](https://github.com/justinabellera/retro-pack)
* SSH's Adminmenu [Repo](https://github.com/S3RAPH-1M/H2M-Admin-Menu)
* HyperBeats Scripts [Repo](https://github.com/HyperBeats/h2m-gscscripts)

# Credits
* Thanks to Zyrus1337 for his admin commmands script!
* Thanks to SSH for his scripts (say_xuid, say_guid)!
* Thanks to MXVE for the iw4x sniper script (https://github.com/mxve)  
* Thanks to FOE for his only sniper script  
* Thanks to Flex for bolts only and nolmgs scripts 
* Thanks to Matt for noclip/ufo script  
* Thanks to Kalitos for the restrict killstreak script  
* Thanks to Joey for his trickshot script and thanks to drex for fixing it  
* Thanks to Justinabellera for his trickshot script and repo  
* Thanks to Matt.T for the fix for vanity trickshot script  
* Thanks to Valacdi for the replace killstreak script  
* Thanks to FerretOps for the welcome script
* Thanks to Xevra for his repo and scripts
* Thanks to DoktorSAS for his repo and scripts
* Thanks to Craig for his wallbang script
* Thanks to ripzie for fixing the antihardcope script
* Thanks to Zynzs for fixing the anticamp script
* Thanks to cat for the cranked gamemode
* Thanks to HyperBeats for his scripts
