![H2M](https://github.com/user-attachments/assets/42656b5e-5052-457d-a780-bc8f5fa22df3)

# h2m_gscs
This is a collection of our GSCs. Credits are included in each script respectively or in the readme.

# Install steps
Steps are super simple so I will keep it high level.

* Drop the scripts into `.\h2m-mod\user_scripts\mp\`.
* Some scripts require a DVAR to enable / disable, use where required.

# Which scripts are available?
* Sniper Only
  * Only Snipers are allowed, other weapons will be replaced, throwingknife and tactical insertion allowed. Perk replacing is not working at the moment
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
 
* Retropack/VanityTS/Trickshotmenu
  * Trickshot Scripts
 
* More scripts coming soon!

# References

[H2M GSC Dump](https://github.com/Jeffx539/h2m-gsc-dump/tree/main)

# More Scripts
* Check Xevrac's repo as well: [Xevra's Repo](https://github.com/Xevrac/h2m_gscs)
* DoktorSAS Mapvote and VanityTS [Trickshot](https://github.com/DoktorSAS/VanityTS) [Mapvote](https://github.com/DoktorSAS/H1Mapvote/tree/main) [General Scripts](https://github.com/DoktorSAS/GSC/tree/main)
* Justin's Retropack [His Repo](https://github.com/justinabellera/retro-pack)

# Credits
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
