# |CelMod|

**|CelMod|** is a fully customized building experience, and extra features to enhance the standard gameplay.

Latest release is *2.0.0*, current working version is *2.1.0*.

Built against SourceMod *1.12.0-git7198* and Metamod: Source *1.12.0-git1219*.

This plugin uses [Updater](https://github.com/rockzehh/updater) to update its files, and is required.
This plugin uses [More Colors](https://forums.alliedmods.net/showthread.php?t=185016) for the text color. It is required if you want to recompile the plugin.

## Installation

Extract the zip file into your server directory with [SourceMod](https://www.sourcemod.net/) and [Metamod: Source](https://www.sourcemm.net/) installed.

## Commands
Command | Description | Aliases | Type | Extra
--- | --- | --- | --- | ---
sm_alpha|Changes the transparency on the prop you are looking at.|sm_amt|Client|
sm_axis|Creates a marker to the player showing every axis.|sm_mark, sm_marker|Client|
sm_balance|Gets the players current balance.|None|Client|
sm_buy|Purchases the current entity you are looking at or command you specified.|None|Client|
sm_color|Colors the prop you are looking at.|sm_paint|Client|
sm_colorlist|Displays the color list.|sm_colors|Client|[Color List](https://celmod.rockzehh.net/colors.html)
sm_commandlist|Displays the command list.|sm_cmds, sm_commands|Client|[Command List](https://celmod.rockzehh.net/cmds.html)
sm_delete|Removes the prop you are looking at.|sm_del, sm_remove|Client|
sm_door|Spawns a working door cel.|None|Client|
sm_effect|Spawns a working effect cel.|sm_emitter|Client|
sm_effectlist|Displays the effect list.|sm_effects|Client|[Effects List](https://celmod.rockzehh.net/effects.html)
sm_fadecolor|Fades the prop you are looking at between two colors.|None|Client|
sm_fly|Enables/disables nocip on the player.|None|Client|
sm_freeze|Freezes the prop you are looking at.|sm_freezeit|Client|
sm_internet|Creates a working internet cel.|None|Client|
sm_land|Creates a building zone.|None|Client|
sm_landdeathmatch|Changes the deathmatch setting within the land.|None|Client|
sm_landgravity|Changes the gravity within the land.|None|Client|
sm_landskin|Changes the skin within the land.|None|Client|This command currently doesn't work.
sm_load|Loads entites from a save file.|None|Client|
sm_nokill|Enables/disables godmode on the player.|None|Client|
sm_proplist|Displays the prop list.|sm_props|Client|[Prop List](https://celmod.rockzehh.net/props.html)
sm_renderfx|Changes the RenderFX on what prop you are looking at.|None|Client|
sm_rotate|Rotates the prop you are looking at.|None|Client|
sm_save|Saves all server entties that are in your land.|None|Client|
sm_sell|Sells the entity you are looking at.|None|Client|
sm_setbalance|Sets the balance of the client you are specifing.|None|Admin|
sm_setowner|Sets the owner of the prop you are looking at.|None|Admin|
sm_seturl|Sets the url of the internet cel you are looking at|None|Client|
sm_smove|Moves the prop you are looking at on it's origin|sm_pmove|Client|
sm_solid|Enables/disables solidicity on the prop you are looking at.|None|Client|
sm_spawn|Spawns a prop by name.|sm_p, sm_s|Client|
sm_stack|Stacks props on the x, y and z axis.|None|Client|
sm_stackinfo|Gets the origin difference between props for help stacking.|None|Client|
sm_stand|Resets the angles on the prop you are looking at.|sm_straight, sm_straighten|Client|
sm_switch|Switches the side the hud is on the screen.|None|Client|
sm_unfreeze|Unfreezes the prop you are looking at.|sm_unfreezeit|Client|

## Developer Commands
Command | Description | Type
--- | --- | ---
cm_exportcolorlist|Exports the color list into a text or html file in 'data/celmod/exports'.|Server
cm_exportcommandlist|Exports the command list into a text or html file in 'data/celmod/exports'.|Server
cm_exportproplist|Exports the prop list into a text or html file in 'data/celmod/exports'.|Server

For the most current command list, [click here](https://raw.githubusercontent.com/rockzehh/celmod/main/addons/sourcemod/data/celmod/exports/commandlist_export.html).

## Additional Information
This plugin is designed with Half-Life 2: Deathmatch in mind. This may work on other source games, but it is not officially tested. All of the plugins functions are open to other plugins using natives, thus making multiple plugins a breeze.

## Contributing
Currently, this project is not accepting outside contributions to the official repository.
