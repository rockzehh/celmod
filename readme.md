![alt text](https://raw.githubusercontent.com/rockzehh/celmod/refs/heads/main/images/gh-logo.png "CelMod Logo")

**|CelMod|** is a fully customized building experience, and extra features to enhance the standard gameplay.

Latest release is *2.1.4*, current working version is *3.x*.

Built against SourceMod *1.12.0-git7198* and Metamod: Source *1.12.0-git1219*.

This plugin uses [Updater](https://github.com/rockzehh/updater) to update its files, and is required.
This plugin uses [More Colors](https://forums.alliedmods.net/showthread.php?t=185016) for the text color, and [StudioHdr](https://forums.alliedmods.net/showthread.php?t=333857) for advanced model information. It is required if you want to recompile the plugin.

## Installation

Extract the zip file into your server directory with [SourceMod](https://www.sourcemod.net/) and [Metamod: Source](https://www.sourcemm.net/) installed.

## Commands
Command | Description | Aliases | Type | Extra
--- | --- | --- | --- | ---
+copy/-copy|Starts copying and moving the prop you are looking at.|None|Client|
+move/-move|Starts moving the prop you are looking at.|None|Client|
v_alpha|Changes the transparency on the prop you are looking at.|v_amt|Client|
v_ammo|Creates a ammo bit that will give ammo when the player touches it.|None|Client|
v_ammocrate|Creates a ammo crate bit that will give ammo to the player.|None|Client|
v_autobuild|Stacks props on the x, y and z axis.|None|Admin|
v_axis|Creates a marker to the player showing every axis.|v_mark, v_marker|Client|
v_balance|Gets the players current balance.|None|Client|
v_blacklist|Adds/removes a prop from the spawn blacklist.|None|Admin|
v_button|Spawns a button trigger bit.|None|Client|
v_buy|Purchases the current entity you are looking at or command you specified.|None|Client|
v_charger|Creates a health/suit charger bit that will give health/suit to the player.|None|Client|
v_color|Colors the prop you are looking at.|v_paint|Client|
v_colorlist|Displays the color list.|v_colors|Client|[Color List](https://delaware.rockzehh.net/colors.html)
v_commandlist|Displays the command list.|v_cmds, v_commands|Client|[Command List](https://delaware.rockzehh.net/cmds.html)
v_copy|Copies the prop you are looking at into your copy buffer.|None|Client|
v_delete|Removes the prop you are looking at.|v_del, v_remove|Client|
v_dm|Changes the deathmatch setting within the land.|v_landdeathmatch|Client|
v_door|Spawns a working door cel.|None|Client|
v_drop|Teleports the entity you are looking at to the floor.|None|Client|
v_effect|Spawns a working effect cel.|v_emitter|Client|
v_effectlist|Displays the effect list.|v_effects|Client|[Effects List](https://delaware.rockzehh.net/effects.html)
v_fadecolor|Fades the prop you are looking at between two colors.|None|Client|
v_fly|Enables/disables nocip on the player.|None|Client|
v_freeze|Freezes the prop you are looking at.|v_freezeit|Client|
v_god|Enables/disables breakability on the prop you are looking at.|None|Client|
v_gravity|Changes the gravity within the land.|v_landgravity|Client|
v_internet|Creates a working internet cel.|None|Client|
v_ladder|Creates a working ladder cel.|None|Client|
v_land|Creates a building zone.|None|Client|
v_light|Creates a working light cel.|None|Client|
v_link|Creates a link between a trigger bit and an entity.|None|Client|
v_load|Loads entites from a save file.|None|Client|
v_lock|Locks the cel you are looking at.|None|Client|
v_nokill|Enables/disables godmode on the player.|None|Client|
v_paste|Pastes the prop in your copy buffer where you are looking at.|None|Client|
v_proplist|Displays the prop list.|v_props|Client|[Prop List](https://delaware.rockzehh.net/props/index.html)
v_renderfx|Changes the RenderFX on what prop you are looking at.|None|Client|
v_rotate|Rotates the prop you are looking at.|None|Client|
v_save|Saves all server entties that are in your land.|None|Client|
v_sell|Sells the entity you are looking at.|None|Client|
v_setbalance|Sets the balance of the client you are specifing.|None|Admin|
v_setowner|Sets the owner of the prop you are looking at.|None|Admin|
v_seturl|Sets the url of the internet cel you are looking at|None|Client|
v_smove|Moves the prop you are looking at on it's origin|v_pmove|Client|
v_solid|Enables/disables solidicity on the prop you are looking at.|None|Client|
v_spawn|Spawns a prop by name.|v_p, v_s|Client|
v_stack|Stacks props on the x, y and z axis.|None|Client|
v_stackinfo|Gets the origin difference between props for help stacking.|None|Client|
v_stand|Resets the angles on the prop you are looking at.|v_straight, v_straighten|Client|
v_switch|Switches the side the hud is on the screen.|None|Client|
v_unfreeze|Unfreezes the prop you are looking at.|v_unfreezeit|Client|
v_unlock|Unlocks the cel you are looking at.|None|Client|
v_wep|Creates a weapon bit that will give a weapon when the player touches it.|None|Client|

## Developer Commands
Command | Description | Type
--- | --- | ---
cm_exportcolorlist|Exports the color list into a text or html file in 'data/celmod/exports'.|Server
cm_exportcommandlist|Exports the command list into a text or html file in 'data/celmod/exports'.|Server
cm_exportproplist|Exports the prop list into a text or html file in 'data/celmod/exports'.|Server

For the most current command list, [click here](https://raw.githubusercontent.com/rockzehh/celmod/beta/addons/sourcemod/data/celmod/exports/commandlist_export.txt).

## Additional Information
This plugin is designed with Half-Life 2: Deathmatch in mind. This may work on other source games, but it is not officially tested. All of the plugins functions are open to other plugins using natives, thus making multiple plugins a breeze.

## Contributing
Currently, this project is not accepting outside contributions to the official repository.
