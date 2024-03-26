# King's Sandbox

**King’s Sandbox** is a fully customized building experience, and extra features to enhance the standard gameplay.

Latest release is *1.2.0.0*, current working version is *1.2.0.0*.

Built against SourceMod *1.11.0-git6826* and Metamod: Source *1.12.0-git1157*.

This plugin uses [Updater](https://forums.alliedmods.net/showthread.php?t=169095) to update its files, and is required.
This plugin uses [More Colors](https://forums.alliedmods.net/showthread.php?t=185016) for the text color. It is required if you want to recompile the plugin.

## Installation

Extract the zip file into your server directory with [SourceMod](https://www.sourcemod.net/) and [Metamod: Source](https://www.sourcemm.net/) installed.

## Commands
Command | Description | Aliases | Type | Extra
--- | --- | --- | --- | ---
sm_alpha|Changes the transparency on the prop you are looking at.|sm_amt|Client|
sm_axis|Creates a marker to the player showing every axis.|sm_mark, sm_marker|Client|
sm_color|Colors the prop you are looking at.|sm_paint|Client|
sm_colorlist|Displays the color list.|sm_colors|Client|[Color List](https://raw.githubusercontent.com/rockzehh/kingssandbox/master/docs/1.2.0.0/colorlist_export.txt)
sm_commandlist|Displays the command list.|sm_cmds, sm_commands|Client|[Command List](https://raw.githubusercontent.com/rockzehh/kingssandbox/master/docs/1.2.0.0/commandlist_export.txt)
sm_delete|Removes the prop you are looking at.|sm_del, sm_remove|Client|
sm_door|Spawns a working door cel.|None|Client|
sm_effect|Spawns a working effect cel.|None|Client|
sm_effectlist|Displays the effect list.|sm_effects|Client|[Effects List](https://rockzehh.github.io/kingssandbox/1.1.0.0/effects.html)
sm_freeze|Freezes the prop you are looking at.|sm_freezeit|Client|
sm_internet|Creates a working internet cel.|None|Client|
sm_land|Creates a building zone.|None|Client|
sm_nokill|Enables/disables godmode on the player.|None|Client|
sm_proplist|Displays the prop list.|sm_props|Client|[Prop List](https://rockzehh.github.io/kingssandbox/1.1.0.0/proplist_export.html)
sm_rotate|Rotates the prop you are looking at.|None|Client|
sm_setowner|Sets the owner of the prop you are looking at.|None|Admin|
sm_seturl|Sets the url of the internet cel you are looking at|None|Client|
sm_solid|Enables/disables solidicity on the prop you are looking at.|None|Client|
sm_spawn|Spawns a prop by name.|sm_p, sm_s|Client|
sm_stand|Resets the angles on the prop you are looking at.|sm_straight, sm_straighten|Client|
sm_unfreeze|Unfreezes the prop you are looking at.|sm_unfreezeit|Client|

## Developer Commands
Command | Description | Type
--- | --- | ---
ks_exportcolorlist|Exports the color list into a text or html file in 'data/kingssandbox/exports'.|Server
ks_exportcommandlist|Exports the command list into a text or html file in 'data/kingssandbox/exports'.|Server
ks_exportproplist|Exports the prop list into a text or html file in 'data/kingssandbox/exports'.|Server
ks_reloadserverconvers|Reloads the custom convar settings for the server.|Server

For the most current command list, [click here](https://raw.githubusercontent.com/rockzehh/kingssandbox/master/docs/1.2.0.0/commandlist_export.txt).

## Additional Information
This plugin is designed with Half-Life 2: Deathmatch in mind. This may work on other source games, but it is not officially tested. All of the plugins functions are open to other plugins using natives, thus making multiple plugins a breeze.

## Contributing
Currently, this project is not accepting outside contributions to the official repository.