//|CelMod| Classic - Original 2009 |CelMod| leak fixed up.
//This is the original code by Celsius, cleaned up and somewhat reformatted.
//This is from decompiled code so it will not be exact.

bool g_bCopyBreakable[MAXPLAYERS + 1];
bool g_bCopyFrozen[MAXPLAYERS + 1];
bool g_bCopyFrozen[MAXPLAYERS + 1];
bool g_bStartCopy[MAXPLAYERS + 1];
bool g_cvCheatsOn;

char g_sClientPrefs[128];
char g_sCopyClassname[MAXPLAYERS + 1][32];
char g_sCopyModelPath[MAXPLAYERS + 1][128];
char g_sEntityMusicPath[MAXENTITIES + 1][256];
char g_sEntitySoundsPath[MAXENTITIES + 1][256];
char g_sNPCPrefix[8] = "npc_";
char g_sPlayerClassname[16] = "g_sPlayerClassname";
char g_sPropErrorPath[128];
char g_sPropsPath[128];
char g_sSoundsPath[128];
char g_sTempString[256];
char g_sToolSound[128];
char g_sUndoQueue[MAXPLAYERS + 1][1000][256];

ConVar g_cvCheats;
ConVar g_cvLightCvar;
ConVar g_cvMaxBreakablesClient;
ConVar g_cvMaxCelsClient;
ConVar g_cvMaxg_sNPCPrefixClient;
ConVar g_cvMaxPropsClient;
ConVar g_cvMaxVehiclesClient;
ConVar g_cvNoclipSpeed;
ConVar g_cvNPCCvar;
ConVar g_cvProtectMapEntities;
ConVar g_cvRemoveOnDisconnect;
ConVar g_cvUseFakeZombies;

float grabDist[MAXPLAYERS + 1][3];
float g_fCopyAngles[MAXPLAYERS + 1][3];
float g_fCopyDistance[MAXPLAYERS + 1][3];
float g_fEntityAngles[3];
float g_fLastPasteTime[MAXPLAYERS + 1];
float g_fLightTime[MAXPLAYERS + 1];
float g_fMusicLength[MAXENTITIES + 1];
float g_fSoundLengthEnt[MAXENTITIES + 1];
float g_fSoundUseDelay[MAXPLAYERS + 1];
float g_fSpawnPropDelay[MAXPLAYERS + 1];

Handle g_hEntityCopy[MAXPLAYERS + 1];
Handle g_hEntityGrab[MAXPLAYERS + 1];
Handle g_hVehicleMoveTimer[MAXPLAYERS + 1];

int g_iBeam;
int g_iBlockPluginMsgs[MAXPLAYERS + 1];
int g_iCmdCopyColor[MAXPLAYERS + 1][4];
int g_iCmdCopyEntity[MAXPLAYERS + 1];
int g_iCopyColor[MAXPLAYERS + 1][4];
int g_iCopyFlags[MAXPLAYERS + 1];
int g_iCopyRenderFX[MAXPLAYERS + 1];
int g_iCopyRenderMode[MAXPLAYERS + 1];
int g_iCopySkin[MAXPLAYERS + 1];
int g_iEntityDissolver;
int g_iEntityIgniter;
int g_iGrabColor[MAXPLAYERS + 1][4];
int g_iGrabEntity[MAXPLAYERS + 1];
int g_iHalo;
int g_iLaser;
int g_iLightCount;
int g_iLightCount;
int g_iLookingEntity[MAXPLAYERS + 1];
int g_iMaxPlayers;
int g_iNPCCount;
int g_iPhys;
int g_iViewingEntity[MAXPLAYERS + 1];

int g_iBlueColor[4] =  { 0, 0, 255, 200 };
int g_iGreenColor[4] =  { 0, 255, 0, 200 };
int g_iGreyColor[4] =  { 255, 255, 255, 30 };
int g_iOrangeColor[4] =  { 255, 128, 0, 200 };
int g_iRedColor[4] =  { 255, 0, 0, 200 };
int g_iWhiteColor[4] =  { 255, 255, 255, 200 };
int g_iYellowColor[4] =  { 255, 255, 0, 200 };

MoveType g_mtCopyMoveType[MAXPLAYERS + 1];
MoveType g_mtGrabMoveType[MAXPLAYERS + 1];
MoveType g_mtOldMoveType[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "|CelMod| Classic",
	description = "Various commands used for build/cheat servers.",
	author = "Celsius/rockzehh",
	version = "1.3.0.0",
	url = "www.avmserver.weebly.com"
};

public OnPluginStart()
{
	RegAdminCmd("v_custom_spawn", Command_ent, 4096, "Creates an entity with specified keyvalues. Pros only.", "", 0);
	RegAdminCmd("v_advisor", Command_advisor, 32, "Creates an advisor.", "", 0);
	RegAdminCmd("v_give", Command_giveOwner, 8, "Gives ownership of an entity to someone.", "", 0);
	RegAdminCmd("v_autobuild", Command_autoStack, 8, "Creates multiple copies of the entity you're looking at in specified frequencies.", "", 0);
	
	RegConsoleCmd("v_spawn", Command_spawnprop, "Spawns a prop by alias.", 0);
	RegConsoleCmd("v_count", Command_propCount, "Shows your prop count.", 0);
	RegConsoleCmd("v_sound", Command_sound, "Creates a sound emitter.", 0);
	RegConsoleCmd("v_proplist", Command_proplist, "Brings up the list of props.", 0);
	RegConsoleCmd("v_soundlist", Command_soundlist, "Brings up the list of sounds.", 0);
	RegConsoleCmd("v_musiclist", Command_musiclist, "Brings up the list of music.", 0);
	RegConsoleCmd("v_preview", Command_preg_iViewingEntity, "Previews a prop to a g_sPlayerClassname.", 0);
	RegConsoleCmd("+v_forward", Command_vehicleStart, "test", 0);
	RegConsoleCmd("-v_forward", Command_vehicleStop, "test", 0);
	RegConsoleCmd("+v_back", Command_vehicleStartBack, "test", 0);
	RegConsoleCmd("-v_back", Command_vehicleStop, "test", 0);
	RegConsoleCmd("v_copy", Command_copyprop, "Stores a prop in the g_sPlayerClassname's copy queue.", 0);
	RegConsoleCmd("v_paste", Command_pasteprop, "Spawns the prop in the g_sPlayerClassname's copy queue.", 0);
	RegConsoleCmd("v_npc", Command_npccreate, "Creates an npc.", 0);
	RegConsoleCmd("v_ladder", Command_ladder, "Creates a working ladder.", 0);
	RegConsoleCmd("v_showmsgs", Command_msgs, "Decides wether to show ent messages when using commands(v_freeze, v_remove, etc.)", 0);
	RegConsoleCmd("v_remove", Command_remove, "Removes props.", 0);
	RegConsoleCmd("v_undo", Command_undoRemove, "Undo function for use with v_remove.", 0);
	RegConsoleCmd("v_freeze", Command_freeze, "Freezes the entity you're looking at.", 0);
	RegConsoleCmd("v_unfreeze", Command_unfreeze, "Unfreezes the entity you're looking at.", 0);
	RegConsoleCmd("v_skin", Command_skin, "Changes the skin of the entity you're looking at.", 0);
	RegConsoleCmd("v_door", Command_door, "Creates a working door.", 0);
	RegConsoleCmd("v_straight", Command_straighten, "Straightens the prop.", 0);
	RegConsoleCmd("v_setscene", Command_scene, "Sets the choreographed scene for an NPC.", 0);
	RegConsoleCmd("v_relationship", Command_relationship, "Sets the relationship of an NPC.", 0);
	RegConsoleCmd("v_airboat", Command_airboat, "Creates an airboat.", 0);
	RegConsoleCmd("v_gun", Command_airboatgun, "Turns the airboat gun on or off.", 0);
	RegConsoleCmd("v_ignite", Command_ignite, "Ignites the entity for x seconds.", 0);
	RegConsoleCmd("v_jeep", Command_jeep, "Turns an airboat into a jeep.", 0);
	RegConsoleCmd("v_god", Command_god, "Turns invincibility on or off of props.", 0);
	RegConsoleCmd("v_spawnpod", Command_pod, "Creates a pod vehicle out of the prop you're looking at.", 0);
	RegConsoleCmd("v_color", Command_color, "Colors the entity you're looking at.", 0);
	RegConsoleCmd("v_axis", Command_mark, "Creates a marker showing every axis.", 0);
	RegConsoleCmd("v_spawnlight", Command_lightcreate, "Creates a moveable light.", 0);
	RegConsoleCmd("v_solid", Command_solidity, "Turns solidity on the prop on or off.", 0);
	RegConsoleCmd("v_music", Command_music, "Creates a music emitting radio.", 0);
	RegConsoleCmd("v_amt", Command_alpha, "Modifies entity alpha transparency.", 0);
	RegConsoleCmd("v_rotate", Command_rotate, "Rotates an entity. Supports doors.", 0);
	RegConsoleCmd("v_owned", Command_whoowns, "Finds out who owns the picker entity.", 0);
	RegConsoleCmd("+move", Command_startMove, "Makes the entity you're looking at follow you.", 0);
	RegConsoleCmd("-move", Command_stopMove, "Stops moving the entity.", 0);
	RegConsoleCmd("+copy", Command_startCopy, "Copies an entity and makes it follow you.", 0);
	RegConsoleCmd("-copy", Command_stopCopy, "Stops moving copied entity.", 0);
	RegConsoleCmd("say", Command_stopcmd, "Used for the stop command on v_preview.", 0);
	
	CreateConVar("celmod", "1", "Notification that the server is running celmod(for use with game-monitor,etc.)", 395584, false, 0.0, false, 0.0);
	
	g_cvLightCvar = CreateConVar("cm_max_lights", "10", "Maxiumum number of lights allowed on map.", 264512, false, 0.0, false, 0.0);
	g_cvNPCCvar = CreateConVar("cm_max_g_sNPCPrefix", "100", "Maxiumum number of g_sNPCPrefix allowed on map.", 264512, false, 0.0, false, 0.0);
	g_cvMaxCelsClient = CreateConVar("cm_max_g_sPlayerClassname_cels", "50", "Maxiumum number of CelMod entities a client is allowed.", 264512, false, 0.0, false, 0.0);
	g_cvMaxg_sNPCPrefixClient = CreateConVar("cm_max_g_sPlayerClassname_g_sNPCPrefix", "20", "Maxiumum number of g_sNPCPrefix a client is allowed.", 264512, false, 0.0, false, 0.0);
	g_cvMaxPropsClient = CreateConVar("cm_max_g_sPlayerClassname_props", "300", "Maxiumum number of props a g_sPlayerClassname is allowed to spawn.", 264512, false, 0.0, false, 0.0);
	g_cvMaxBreakablesClient = CreateConVar("cm_max_g_sPlayerClassname_breakables", "100", "Maxiumum number of breakable props a g_sPlayerClassname is allowed to spawn.", 264512, false, 0.0, false, 0.0);
	g_cvMaxVehiclesClient = CreateConVar("cm_max_g_sPlayerClassname_vehicles", "5", "Maxiumum number of vehicles a g_sPlayerClassname is allowed.", 264512, false, 0.0, false, 0.0);
	g_cvRemoveOnDisconnect = CreateConVar("cm_remove_on_disconnect", "1", "Decides wether to remove the g_sPlayerClassnames entities on disconnect.", 264512, false, 0.0, false, 0.0);
	g_cvUseFakeZombies = CreateConVar("cm_fake_zombies", "1", "Decides wether to spawn fake zombies (used to prevent Windows from crashing)", 264512, false, 0.0, false, 0.0);
	g_cvProtectMapEntities = CreateConVar("cm_protect_map_props", "0", "Map start only. Protects all the map entities from celmod commands.", 264512, false, 0.0, false, 0.0);
	
	CreateConVar("celmod_version", "1.1", "CelMod Version", 395584, false, 0.0, false, 0.0);
	g_cvNoclipSpeed = FindConVar("sv_noclipspeed");
	g_cvCheats = FindConVar("sv_cheats");
	
	BuildPath(PathType:0, g_sPropsPath, 64, "data/celmod/spawns.txt");
	BuildPath(PathType:0, g_sSoundsPath, 64, "data/celmod/sounds.txt");
	BuildPath(PathType:0, g_sPropErrorPath, 64, "data/celmod/spawnerrors.txt");
	BuildPath(PathType:0, g_sClientPrefs, 64, "data/celmod/g_sClientPrefs.txt");
}

cmMsg(client, String:Msg[])
{
	PrintToChat(client, "\x04|CelMod|\x01 %s", Msg);
	int random = GetRandomInt(0, 1);
	switch (random)
	{
		case 0:
		{
			ClientCommand(client, "playgamesound NPC_Stalker.FootStepRight");
		}
		case 1:
		{
			ClientCommand(client, "playgamesound NPC_Stalker.FootStepLeft");
		}
		default:
		{
		}
	}
	return 0;
}

PerformByClass(client, ent, String:action[])
{
	decl String:classname[32];
	char brokeClass[2][32] = {
		"_",
		"."
	};
	decl String:classMsg[256];
	GetEdictClassname(ent, classname, 32);
	if (StrContains(classname, "_", false) == -1)
	{
		Format(classMsg, 255, "%s %s.", action, classname);
	}
	else
	{
		ExplodeString(classname, "_", brokeClass, 2, 32);
		if (StrEqual(brokeClass[0][brokeClass], "combine", false))
		{
			Format(classMsg, 255, "%s %s %s.", action, brokeClass[0][brokeClass], brokeClass[1]);
		}
		Format(classMsg, 255, "%s %s %s.", action, brokeClass[1], brokeClass[0][brokeClass]);
	}
	cmMsg(client, classMsg);
	return 0;
}

tooFast(client)
{
	char fastMsg[256];
	int random = GetRandomInt(0, 3);
	switch (random)
	{
		case 0:
		{
			fastMsg = "Slow down there charlie.";
		}
		case 1:
		{
			fastMsg = "Calm the hell down!";
		}
		case 2:
		{
			fastMsg = "Cool your jets buddy.";
		}
		case 3:
		{
			fastMsg = "Wheres the rush?";
		}
		default:
		{
		}
	}
	cmMsg(client, fastMsg);
	return 0;
}

lookingAt(client)
{
	if (!g_iBlockPluginMsgs[client])
	{
		cmMsg(client, "You are not looking at anything.");
	}
	return 0;
}

notYours(client)
{
	cmMsg(client, "This entity does not belong to you.");
	return 0;
}

changeBeam(client, Ent)
{
	decl Handle:TraceRay;
	decl randomSound;
	decl Float:COrigin[3];
	decl Float:EyeAngles[3];
	decl Float:EyeOrigin[3];
	decl Float:EndOrigin[3];
	decl Float:FinalCOrigin[3];
	GetClientAbsOrigin(client, COrigin);
	FinalCOrigin[0] = COrigin[0];
	FinalCOrigin[1] = COrigin[1];
	FinalCOrigin[2] = COrigin[2] + 32;
	GetClientEyeAngles(client, EyeAngles);
	GetClientEyePosition(client, EyeOrigin);
	TraceRay = TR_TraceRayFilterEx(EyeOrigin, EyeAngles, 1174421507, RayType:1, Filterg_sPlayerClassname, any:0);
	if (TR_DidHit(TraceRay))
	{
		TR_GetEndPosition(EndOrigin, TraceRay);
		TE_SetupBeamPoints(FinalCOrigin, EndOrigin, g_iPhys, g_iHalo, 0, 15, 0.1, 4.0, 4.0, 1, 0.0, physWhite, 10);
		TE_SendToAll(0.0);
		TE_SetupSparks(EndOrigin, g_fEntityAngles, 3, 2);
		TE_SendToAll(0.0);
		randomSound = GetRandomInt(0, 1);
		switch (randomSound)
		{
			case 0:
			{
			}
			case 1:
			{
			}
			default:
			{
			}
		}
		EmitSoundToAll(g_sToolSound, Ent, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	}
	CloseHandle(TraceRay);
	return 0;
}

ReadQue(client)
{
	int I;
	while (I < 1000)
	{
		if (StrEqual(g_sUndoQueue[client][I], "", false))
		{
			return I;
		}
		I++;
	}
	return -1;
}

WriteQue(client, ent, num)
{
	char queString[18][256] = {
		"m_ModelName",
		"prop_vehicle_airboat",
		"ls/advisor.mdl",
		"eam.vmt",
		"ls/citadel/weapon_disintegrate4.wav",
		"",
		"c",
		"a list of prop aliases.",
		").",
		"sics_m_breakable",
		"t console to view.",
		"eramt",
		"ady viewing a prop.",
		"No prop found in copy queue.",
		"_physics_override",
		"",
		"wn.",
		",-1"
	};
	decl eColor[4];
	decl Float:angRot[3];
	decl Float:entOrgn[3];
	decl renderFx;
	decl skinNum;
	decl entFlags;
	decl takedamage;
	decl solid;
	decl coloroffset;
	GetEdictClassname(ent, queString[0][queString], 32);
	GetEntPropString(ent, PropType:1, "m_ModelName", queString[1], 128);
	GetEntPropString(ent, PropType:1, "m_iGlobalname", queString[17], 128);
	skinNum = GetEntProp(ent, PropType:1, "m_nSkin", 1);
	solid = GetEntProp(ent, PropType:0, "m_nSolidType", 1);
	IntToString(skinNum, queString[2], 16);
	IntToString(solid, queString[3], 16);
	coloroffset = GetEntSendPropOffs(ent, "m_clrRender", false);
	eColor[0] = GetEntData(ent, coloroffset, 1);
	eColor[1] = GetEntData(ent, coloroffset + 1, 1);
	eColor[2] = GetEntData(ent, coloroffset + 2, 1);
	eColor[3] = GetEntData(ent, coloroffset + 3, 1);
	renderFx = GetEntProp(ent, PropType:0, "m_nRenderFX", 1);
	GetEntPropVector(ent, PropType:1, "m_vecAbsOrigin", entOrgn);
	GetEntPropVector(ent, PropType:1, "m_angRotation", angRot);
	entFlags = GetEntProp(ent, PropType:1, "m_spawnflags", 1);
	takedamage = GetEntProp(ent, PropType:1, "m_takedamage", 1);
	IntToString(renderFx, queString[4], 16);
	IntToString(entFlags, queString[5], 16);
	IntToString(eColor[0], queString[6], 16);
	IntToString(eColor[1], queString[7], 16);
	IntToString(eColor[2], queString[8], 16);
	IntToString(eColor[3], queString[9], 16);
	IntToString(takedamage, queString[10], 16);
	IntToString(RoundFloat(entOrgn[0]), queString[11], 16);
	IntToString(RoundFloat(entOrgn[1]), queString[12], 16);
	IntToString(RoundFloat(entOrgn[2]), queString[13], 16);
	IntToString(RoundFloat(angRot[0]), queString[14], 16);
	IntToString(RoundFloat(angRot[1]), queString[15], 16);
	IntToString(RoundFloat(angRot[2]), queString[16], 16);
	ImplodeStrings(queString, 18, "*", g_sUndoQueue[client][num], 255);
	return 0;
}

LoadString(Handle:anyHandle, String:Key[32], String:SaveKey[256], String:DefaultValue[256], String:Reference[256])
{
	KvJumpToKey(anyHandle, Key, false);
	KvGetString(anyHandle, SaveKey, Reference, 255, DefaultValue);
	KvRewind(anyHandle);
	return 0;
}

SaveString(Handle:anyHandle, String:Key[32], String:SaveKey[256], String:Variable[256])
{
	KvJumpToKey(anyHandle, Key, true);
	KvSetString(anyHandle, SaveKey, Variable);
	KvRewind(anyHandle);
	return 0;
}

DebugError(String:propAlias[256], String:modelDir[128])
{
	Handle PropsE = CreateKeyValues("Props", "", "");
	FileToKeyValues(PropsE, g_sPropErrorPath);
	SaveString(PropsE, "Errors", propAlias, "Model does not match up with prop type.");
	KeyValuesToFile(PropsE, g_sPropErrorPath);
	CloseHandle(PropsE);
	return 0;
}

FindOwner(client, Ent)
{
	if (IsValidEntity(Ent))
	{
		decl String:clientEnt[32];
		decl String:entGlobal[64];
		IntToString(client, clientEnt, 32);
		GetEntPropString(Ent, PropType:1, "m_iGlobalname", entGlobal, 64);
		if (StrEqual(clientEnt, entGlobal, false))
		{
			return 1;
		}
		if (StrEqual(entGlobal, "", false))
		{
			return 0;
		}
		return -1;
	}
	return -1;
}

SetOwner(client, Ent)
{
	decl String:clientEnt[32];
	IntToString(client, clientEnt, 32);
	DispatchKeyValue(Ent, "globalname", clientEnt);
	return 0;
}

Countg_sNPCPrefix(client)
{
	int NPCCount;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		int var1;
		if (IsValidEntity(AllE) && FindOwner(client, AllE) == 1)
		{
			decl String:pClass[32];
			GetEdictClassname(AllE, pClass, 32);
			if (StrContains(pClass, "npc_", false))
			{
			}
			else
			{
				NPCCount += 1;
			}
		}
		AllE++;
	}
	return NPCCount;
}

CountProps(client)
{
	int PropCount;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		int var1;
		if (IsValidEntity(AllE) && FindOwner(client, AllE) == 1)
		{
			decl String:pClass[32];
			GetEdictClassname(AllE, pClass, 32);
			int var2;
			if (StrContains(pClass, "prop_", false) != -1 && !StrEqual(pClass, "prop_vehicle_airboat", false) && !StrEqual(pClass, "prop_vehicle_airboat", false))
			{
				PropCount += 1;
			}
		}
		AllE++;
	}
	return PropCount;
}

CountCels(client)
{
	int CelCount;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		int var1;
		if (IsValidEntity(AllE) && FindOwner(client, AllE) == 1)
		{
			decl String:pClass[32];
			GetEdictClassname(AllE, pClass, 32);
			if (StrContains(pClass, "cel_", false))
			{
			}
			else
			{
				CelCount += 1;
			}
		}
		AllE++;
	}
	return CelCount;
}

CountBreakables(client)
{
	int BreakableCount;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		int var1;
		if (IsValidEntity(AllE) && FindOwner(client, AllE) == 1)
		{
			decl String:pClass[32];
			GetEdictClassname(AllE, pClass, 32);
			int var2;
			if (StrEqual(pClass, "prop_physics_breakable", false) || StrEqual(pClass, "prop_physics_m_breakable", false))
			{
				BreakableCount += 1;
			}
		}
		AllE++;
	}
	return BreakableCount;
}

CountVehicles(client)
{
	int VehicleCount;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		int var1;
		if (IsValidEntity(AllE) && FindOwner(client, AllE) == 1)
		{
			decl String:pClass[32];
			GetEdictClassname(AllE, pClass, 32);
			int var2;
			if (StrEqual(pClass, "prop_vehicle_airboat", false) || StrEqual(pClass, "prop_vehicle_jeep", false))
			{
				VehicleCount += 1;
			}
		}
		AllE++;
	}
	return VehicleCount;
}

CountLights()
{
	g_iLightCount = 0;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		if (IsValidEntity(AllE))
		{
			decl String:cClass[32];
			GetEdictClassname(AllE, cClass, 32);
			if (StrEqual(cClass, "cel_light", false))
			{
				g_iLightCount = g_iLightCount + 1;
			}
		}
		AllE++;
	}
	return g_iLightCount;
}

CountAllg_sNPCPrefix()
{
	g_iNPCCount = 0;
	int MaxEnts = GetMaxEntities();
	int AllE = 1;
	while (AllE < MaxEnts)
	{
		if (IsValidEntity(AllE))
		{
			decl String:gName[256];
			GetEntPropString(AllE, PropType:1, "m_iGlobalname", gName, 255);
			if (!StrEqual(gName, "", false))
			{
				decl String:cClass[32];
				GetEdictClassname(AllE, cClass, 32);
				int var1;
				if (StrContains(cClass, g_sNPCPrefix, false) && !StrEqual(cClass, "npc_grenade_frag", false) && !StrEqual(cClass, "npc_tripmine", false) && !StrEqual(cClass, "npc_satchel", false))
				{
					g_iNPCCount = g_iNPCCount + 1;
				}
			}
		}
		AllE++;
	}
	return g_iNPCCount;
}

resetCvars(client)
{
	g_iLookingEntity[client] = 0;
	g_iViewingEntity[client] = -1;
	g_bStartCopy[client] = 0;
	g_fSpawnPropDelay[client] = 0;
	g_fLastPasteTime[client] = 0;
	g_fLightTime[client] = 0;
	g_fSoundUseDelay[client] = 0;
	g_hEntityGrab[client] = 0;
	g_hEntityCopy[client] = 0;
	g_hVehicleMoveTimer[client] = 0;
	int I;
	while (I < 1000)
	{
		I++;
	}
	return 0;
}

public OnMapStart()
{
	g_iLightCount = 1;
	g_iLightCount = 0;
	g_iNPCCount = 0;
	SetConVarInt(g_cvNoclipSpeed, 3, true, false);
	ServerCommand("exec skill.cfg");
	PrecacheModel("models/advisor.mdl", false);
	PrecacheModel("models/airboat.mdl", false);
	PrecacheModel("models/buggy.mdl", false);
	PrecacheModel("models/zombie/classic.mdl", false);
	PrecacheModel("models/zombie/poison.mdl", false);
	PrecacheModel("models/zombie/fast.mdl", false);
	PrecacheModel("models/roller_spikes.mdl", false);
	PrecacheModel("models/props_junk/popcan01a.mdl", false);
	PrecacheModel("models/props_lab/citizenradio.mdl", false);
	g_iBeam = PrecacheModel("materials/sprites/laserbeam.vmt", false);
	g_iHalo = PrecacheModel("materials/sprites/halo01.vmt", false);
	g_iLaser = PrecacheModel("materials/sprites/laser.vmt", false);
	g_iPhys = PrecacheModel("materials/sprites/g_iPhys.vmt", false);
	PrecacheSound("ambient/levels/citadel/weapon_disintegrate1.wav", false);
	PrecacheSound("ambient/levels/citadel/weapon_disintegrate2.wav", false);
	PrecacheSound("ambient/levels/citadel/weapon_disintegrate3.wav", false);
	PrecacheSound("ambient/levels/citadel/weapon_disintegrate4.wav", false);
	PrecacheSound("weapons/airboat/airboat_gun_lastshot1.wav", false);
	PrecacheSound("weapons/airboat/airboat_gun_lastshot2.wav", false);
	PrecacheSound("npc/scanner/scanner_talk1.wav", false);
	PrecacheSound("weapons/mortar/mortar_fire1.wav", false);
	PrecacheSound("npc/turret_floor/ping.wav", false);
	PrecacheSound("npc/roller/mine/rmine_explode_shock1.wav", false);
	g_iEntityDissolver = CreateEntityByName("env_entity_dissolver", -1);
	DispatchKeyValue(g_iEntityDissolver, "target", "deleted");
	DispatchKeyValue(g_iEntityDissolver, "magnitude", "50");
	DispatchKeyValue(g_iEntityDissolver, "dissolvetype", "3");
	DispatchSpawn(g_iEntityDissolver);
	DispatchKeyValue(g_iEntityDissolver, "classname", "cel_entity_dissolver");
	int metro = CreateEntityByName("npc_metropolice", -1);
	DispatchSpawn(metro);
	CreateTimer(0.2, RemoveCop, metro, 0);
	g_iEntityIgniter = CreateEntityByName("env_entity_igniter", -1);
	DispatchKeyValue(g_iEntityIgniter, "target", "ignited");
	DispatchSpawn(g_iEntityIgniter);
	DispatchKeyValue(g_iEntityIgniter, "classname", "cel_entity_igniter");
	if (GetConVarBool(g_cvProtectMapEntities))
	{
		decl MaxEnts;
		decl E;
		MaxEnts = GetMaxEntities();
		E = 1;
		while (E <= MaxEnts)
		{
			DispatchKeyValue(E, "globalname", "-2");
			E++;
		}
	}
	g_iMaxPlayers = GetMaxClients();
	return 0;
}

public OnPluginEnd()
{
	RemoveEdict(g_iEntityDissolver);
	RemoveEdict(g_iEntityIgniter);
	return 0;
}

public bool:Filterg_sPlayerClassname(entity, contentsMask)
{
	return entity > g_iMaxPlayers;
}

public useSound(String:output[], caller, activator, Float:delay)
{
	if (g_fSoundUseDelay[activator] < GetGameTime() - 1)
	{
		decl String:entClass[32];
		GetEdictClassname(activator, entClass, 32);
		if (StrEqual(entClass, "cel_sound", false))
		{
			EmitSoundToAll(g_sEntitySoundsPath[activator], activator, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			g_fSoundUseDelay[activator] = GetGameTime();
		}
	}
	return 0;
}

public useMusic(String:output[], caller, activator, Float:delay)
{
	char mBreak[4][128] = {
		"|",
		"\x0C",
		"lprops' for a list of prop aliases.",
		" count(%d)."
	};
	ExplodeString(g_sEntityMusicPath[activator], "|", mBreak, 4, 128);
	if (g_fMusicLength[activator] < GetGameTime() - StringToInt(mBreak[1], 10))
	{
		decl String:entClass[32];
		GetEdictClassname(activator, entClass, 32);
		if (StrEqual(entClass, "cel_music", false))
		{
			EmitSoundToAll(mBreak[0][mBreak], activator, 0, StringToInt(mBreak[2], 10), 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			g_fMusicLength[activator] = GetGameTime();
			if (StringToInt(mBreak[3], 10) == 1)
			{
				CreateTimer(StringToFloat(mBreak[1]), replaySound, activator, 0);
			}
		}
	}
	else
	{
		StopSound(activator, 0, mBreak[0][mBreak]);
		g_fMusicLength[activator] = 0;
	}
	return 0;
}

public Action:replaySound(Handle:timer, any:activator)
{
	AcceptEntityInput(activator, "Use", -1, -1, 0);
	char mBreak[4][128] = {
		"|",
		"me",
		"Props",
		"ve reached your max prop count(%d)."
	};
	ExplodeString(g_sEntityMusicPath[activator], "|", mBreak, 4, 128);
	CreateTimer(StringToFloat(mBreak[1]), replaySound, activator, 0);
	return Action:0;
}

public OnClientPutInServer(client)
{
	resetCvars(client);
	return 0;
}

public OnClientDisconnect(client)
{
	resetCvars(client);
	decl Me;
	decl E;
	Me = GetMaxEntities();
	if (GetConVarBool(g_cvRemoveOnDisconnect))
	{
		E = 1;
		while (E < Me)
		{
			if (IsValidEntity(E))
			{
				if (FindOwner(client, E) == 1)
				{
					decl String:pClass[32];
					GetEdictClassname(E, pClass, 32);
					if (StrContains(pClass, "prop_vehicle", false))
					{
						if (StrEqual(pClass, "cel_light", false))
						{
							AcceptEntityInput(GetEntPropEnt(E, PropType:1, "m_hMoveChild"), "turnoff", -1, -1, 0);
						}
						if (StrEqual(pClass, "cel_music", false))
						{
							char mBreak[3][128] = {
								"|",
								"a list of prop aliases.",
								"prop_physics"
							};
							ExplodeString(g_sEntityMusicPath[E], "|", mBreak, 3, 128);
							StopSound(E, 0, mBreak[0][mBreak]);
						}
					}
					else
					{
						if (GetEntPropEnt(E, PropType:1, "m_hg_sPlayerClassname") != -1)
						{
							AcceptEntityInput(E, "exitvehicle", -1, -1, 0);
						}
					}
					CreateTimer(0.1, delayRemove, E, 0);
				}
			}
			E++;
		}
	}
	else
	{
		E = 1;
		while (E < Me)
		{
			if (IsValidEntity(E))
			{
				if (FindOwner(client, E) == 1)
				{
					char ownBuffers[2][32] = {
						"*",
						"Usage: v_spawn <prop alias> <extra options>"
					};
					decl String:ownerName[64];
					GetClientName(client, ownBuffers[1], 32);
					GetClientAuthString(client, ownBuffers[0][ownBuffers], 32);
					ImplodeStrings(ownBuffers, 2, "*", ownerName, 64);
					DispatchKeyValue(E, "globalname", ownerName);
				}
			}
			E++;
		}
	}
	return 0;
}

public Action:delayRemove(Handle:timer, any:E)
{
	AcceptEntityInput(E, "Kill", -1, -1, 0);
	return Action:0;
}

public Action:RemoveCop(Handle:timer, any:metro)
{
	AcceptEntityInput(metro, "Kill", -1, -1, 0);
	return Action:0;
}

public Action:Command_spawnprop(client, Args)
{
	if (Args < 1)
	{
		ReplyToCommand(client, "Usage: v_spawn <prop alias> <extra options>");
		ReplyToCommand(client, "Type 'v_proplist' or say 'celprops' for a list of prop aliases.");
		return Action:3;
	}
	if (g_fSpawnPropDelay[client] <= GetGameTime() - 1)
	{
		decl String:propAlias[256];
		decl String:propBool[32];
		GetCmdArg(1, propAlias, 255);
		GetCmdArg(2, propBool, 32);
		decl Handle:Props;
		decl String:PropString[256];
		char KeyType[32] = "Models";
		Props = CreateKeyValues("Props", "", "");
		FileToKeyValues(Props, g_sPropsPath);
		LoadString(Props, KeyType, propAlias, "Null", PropString);
		if (!StrContains(PropString, "Null", false))
		{
			cmMsg(client, "Prop not found.");
			return Action:3;
		}
		decl propEnt;
		char propBuffer[2][128] = {
			"^",
			"ayer"
		};
		ExplodeString(PropString, "^", propBuffer, 2, 128);
		if (StrEqual(propBuffer[0][propBuffer], "2", false))
		{
			if (GetConVarInt(g_cvMaxPropsClient) <= CountProps(client))
			{
				Format(g_sTempString, 255, "You've reached your max prop count(%d).", GetConVarInt(g_cvMaxPropsClient));
				cmMsg(client, g_sTempString);
				return Action:3;
			}
			propEnt = CreateEntityByName("prop_physics", -1);
		}
		else
		{
			if (StrEqual(propBuffer[0][propBuffer], "1", false))
			{
				if (GetConVarInt(g_cvMaxPropsClient) <= CountProps(client))
				{
					Format(g_sTempString, 255, "You've reached your max prop count(%d).", GetConVarInt(g_cvMaxPropsClient));
					cmMsg(client, g_sTempString);
					return Action:3;
				}
				propEnt = CreateEntityByName("prop_physics_multig_sPlayerClassname", -1);
			}
			if (StrEqual(propBuffer[0][propBuffer], "3", false))
			{
				if (GetConVarInt(g_cvMaxCelsClient) <= CountCels(client))
				{
					Format(g_sTempString, 255, "You've reached your max cel count(%d).", GetConVarInt(g_cvMaxCelsClient));
					cmMsg(client, g_sTempString);
					return Action:3;
				}
				propEnt = CreateEntityByName("cycler", -1);
			}
		}
		DispatchKeyValue(propEnt, "model", propBuffer[1]);
		DispatchKeyValue(propEnt, "physdamagescale", "1.0");
		if (!StrEqual(propBuffer[0][propBuffer], "3", false))
		{
			if (StrEqual(propBool, "frozen", false))
			{
				DispatchKeyValue(propEnt, "spawnflags", "264");
			}
			DispatchKeyValue(propEnt, "spawnflags", "256");
		}
		if (!DispatchSpawn(propEnt))
		{
			DebugError(propAlias, propBuffer[1]);
			cmMsg(client, "Unable to spawn prop. Error detected.");
			return Action:3;
		}
		DispatchSpawn(propEnt);
		if (!StrEqual(propBuffer[0][propBuffer], "3", false))
		{
			if (GetEntProp(propEnt, PropType:1, "m_takedamage", 4) == 2)
			{
				if (GetConVarInt(g_cvMaxBreakablesClient) <= CountBreakables(client))
				{
					Format(g_sTempString, 255, "You've reached your max breakable prop count(%d).", GetConVarInt(g_cvMaxBreakablesClient));
					cmMsg(client, g_sTempString);
					return Action:3;
				}
				if (StrEqual(propBuffer[0][propBuffer], "2", false))
				{
					DispatchKeyValue(propEnt, "classname", "prop_physics_breakable");
				}
				DispatchKeyValue(propEnt, "classname", "prop_physics_m_breakable");
			}
			if (StrEqual(propBool, "god", false))
			{
				if (GetEntProp(propEnt, PropType:1, "m_takedamage", 4) == 2)
				{
					SetEntProp(propEnt, PropType:1, "m_takedamage", any:0, 1);
				}
			}
		}
		else
		{
			DispatchKeyValue(propEnt, "classname", "cel_doll");
		}
		decl Float:SpawnOrigin[3];
		decl Float:SpawnAngles[3];
		decl Float:COrigin[3];
		decl Float:CEyeAngles[3];
		GetClientEyeAngles(client, CEyeAngles);
		GetClientAbsOrigin(client, COrigin);
		SpawnOrigin[0] = COrigin[0] + Cosine(DegToRad(CEyeAngles[1])) * 50;
		SpawnOrigin[1] = COrigin[1] + Sine(DegToRad(CEyeAngles[1])) * 50;
		if (StrEqual(propBuffer[0][propBuffer], "3", false))
		{
			SpawnOrigin[2] = COrigin[2];
		}
		else
		{
			SpawnOrigin[2] = COrigin[2] + 40;
		}
		SpawnAngles[1] = CEyeAngles[1] + 180;
		TeleportEntity(propEnt, SpawnOrigin, SpawnAngles, NULL_VECTOR);
		SetOwner(client, propEnt);
		g_fSpawnPropDelay[client] = GetGameTime();
		CloseHandle(Props);
	}
	else
	{
		tooFast(client);
		int var1 = g_fSpawnPropDelay[client];
		var1 = var1[1];
	}
	SetCmdReplySource(ReplySource:0);
	return Action:3;
}

public Action:Command_proplist(client, Args)
{
	FakeClientCommand(client, "say celprops");
	PrintToConsole(client, "Displaying prop list... Exit console to view.");
	return Action:3;
}

public Action:Command_soundlist(client, Args)
{
	FakeClientCommand(client, "say celsounds");
	PrintToConsole(client, "Displaying sound list... Exit console to view.");
	return Action:3;
}

public Action:Command_musiclist(client, Args)
{
	FakeClientCommand(client, "say celmusic");
	PrintToConsole(client, "Displaying music list... Exit console to view.");
	return Action:3;
}

public Action:Command_preg_iViewingEntity(client, Args)
{
	if (Args < 1)
	{
		PrintToConsole(client, "Usage: v_preview <prop alias>");
		PrintToConsole(client, "Type 'v_proplist' for a list of prop aliases.");
		return Action:3;
	}
	if (g_iLookingEntity[client])
	{
		if (g_iLookingEntity[client] == 1)
		{
			cmMsg(client, "You are already viewing a prop.");
			cmMsg(client, "Type \"stop\" in chat to stop viewing.");
		}
		return Action:3;
	}
	decl String:propAlias[256];
	decl String:propBool[32];
	GetCmdArg(1, propAlias, 255);
	GetCmdArg(2, propBool, 32);
	decl Handle:Props;
	decl String:PropString[256];
	char KeyType[32] = "Models";
	Props = CreateKeyValues("Props", "", "");
	FileToKeyValues(Props, g_sPropsPath);
	LoadString(Props, KeyType, propAlias, "Null", PropString);
	if (!StrContains(PropString, "Null", false))
	{
		cmMsg(client, "Prop not found.");
		return Action:3;
	}
	decl propEnt;
	char propBuffer[2][128] = {
		"^",
		"spawnflags"
	};
	ExplodeString(PropString, "^", propBuffer, 2, 128);
	int var1;
	if (StrEqual(propBuffer[0][propBuffer], "1", false) || StrEqual(propBuffer[0][propBuffer], "3", false))
	{
		propEnt = CreateEntityByName("prop_physics_multig_sPlayerClassname", -1);
	}
	else
	{
		if (StrEqual(propBuffer[0][propBuffer], "2", false))
		{
			propEnt = CreateEntityByName("prop_physics", -1);
		}
		if (StrEqual(propBuffer[0][propBuffer], "3", false))
		{
			propEnt = CreateEntityByName("cycler", -1);
		}
	}
	DispatchKeyValue(propEnt, "model", propBuffer[1]);
	DispatchKeyValue(propEnt, "rendermode", "1");
	DispatchKeyValue(propEnt, "renderamt", "128");
	DispatchKeyValue(propEnt, "renderfx", "16");
	DispatchKeyValue(propEnt, "spawnflags", "512");
	if (!DispatchSpawn(propEnt))
	{
		cmMsg(client, "Unable to preview prop. Error detected.");
		return Action:3;
	}
	DispatchSpawn(propEnt);
	SetEntPropEnt(propEnt, PropType:1, "m_hMoveParent", client);
	SetEntProp(propEnt, PropType:0, "m_nSolidType", any:0, 4);
	SetEntProp(propEnt, PropType:1, "m_takedamage", any:0, 4);
	SetEntityMoveType(propEnt, MoveType:0);
	DispatchKeyValue(propEnt, "classname", "func_preview");
	decl Float:SpawnOrigin[3];
	decl Float:SpawnAngles[3];
	decl Float:COrigin[3];
	decl Float:CEyeAngles[3];
	GetClientEyeAngles(client, CEyeAngles);
	GetClientAbsOrigin(client, COrigin);
	SpawnOrigin[0] = COrigin[0] + Cosine(DegToRad(CEyeAngles[1])) * 60;
	SpawnOrigin[1] = COrigin[1] + Sine(DegToRad(CEyeAngles[1])) * 60;
	if (StrEqual(propBuffer[0][propBuffer], "3", false))
	{
		SpawnOrigin[2] = COrigin[2];
	}
	else
	{
		SpawnOrigin[2] = COrigin[2] + 35;
	}
	SpawnAngles[1] = CEyeAngles[1] + 180;
	DispatchKeyValueVector(propEnt, "origin", SpawnOrigin);
	DispatchKeyValueVector(propEnt, "angles", SpawnAngles);
	SetOwner(client, propEnt);
	g_iLookingEntity[client] = 1;
	g_iViewingEntity[client] = propEnt;
	Format(g_sTempString, 255, "You are now viewing %s.", propAlias);
	cmMsg(client, g_sTempString);
	cmMsg(client, "Type \"stop\" in chat to stop viewing.");
	return Action:3;
}

public Action:Command_stopcmd(client, Args)
{
	decl String:check[192];
	GetCmdArg(1, check, 192);
	int var1;
	if (StrEqual(check, "stop", false) && g_iLookingEntity[client] == 1)
	{
		g_iLookingEntity[client] = 0;
		RemoveEdict(g_iViewingEntity[client]);
		return Action:3;
	}
	return Action:0;
}

public Action:Command_copyprop(client, Args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl cpEnt;
	decl String:g_sCopyClassname[32];
	cpEnt = GetClientAimTarget(client, false);
	GetEdictClassname(cpEnt, g_sCopyClassname, 32);
	if (!StrContains(g_sCopyClassname, "prop_physics", false))
	{
		GetEdictClassname(cpEnt, g_sCopyClassname[client], 32);
		GetEntPropString(cpEnt, PropType:1, "m_ModelName", g_sCopyModelPath[client], 128);
		int coloroffset = GetEntSendPropOffs(cpEnt, "m_clrRender", false);
		g_iCopyColor[client][0] = GetEntData(cpEnt, coloroffset, 1);
		g_iCopyColor[client][1] = GetEntData(cpEnt, coloroffset + 1, 1);
		g_iCopyColor[client][2] = GetEntData(cpEnt, coloroffset + 2, 1);
		g_iCopyColor[client][3] = GetEntData(cpEnt, coloroffset + 3, 1);
		g_iCopyRenderFX[client] = GetEntProp(cpEnt, PropType:0, "m_nRenderFX", 1);
		g_iCopyRenderMode[client] = GetEntProp(cpEnt, PropType:0, "m_nRenderMode", 1);
		GetEntPropVector(cpEnt, PropType:1, "m_angRotation", g_fCopyAngles[client]);
		g_iCopySkin[client] = GetEntProp(cpEnt, PropType:1, "m_nSkin", 1);
		g_iCopyFlags[client] = GetEntProp(cpEnt, PropType:1, "m_spawnflags", 1);
		if (GetEntityMoveType(cpEnt))
		{
			g_bCopyFrozen[client] = 0;
		}
		else
		{
			g_bCopyFrozen[client] = 1;
		}
		if (GetEntProp(cpEnt, PropType:1, "m_takedamage", 4) == 2)
		{
			g_bCopyBreakable[client] = 1;
		}
		else
		{
			g_bCopyBreakable[client] = 0;
		}
		g_bStartCopy[client] = 1;
		if (g_iBlockPluginMsgs[client])
		{
		}
		else
		{
			cmMsg(client, "Set physics prop to copy queue.");
		}
	}
	else
	{
		cmMsg(client, "You cannot copy this entity.");
	}
	return Action:3;
}

public Action:Command_pasteprop(client, Args)
{
	if (!g_bStartCopy[client])
	{
		cmMsg(client, "No prop found in copy queue.");
		return Action:3;
	}
	if (g_fLastPasteTime[client] <= GetGameTime() - 1)
	{
		decl cpEnt;
		decl String:g_iCopyFlags[32];
		decl String:g_iCopyRenderFX[32];
		decl String:g_iCopyRenderMode[32];
		decl String:g_iCopySkin[32];
		IntToString(g_iCopyFlags[client], g_iCopyFlags, 32);
		IntToString(g_iCopyRenderFX[client], g_iCopyRenderFX, 32);
		IntToString(g_iCopyRenderMode[client], g_iCopyRenderMode, 32);
		IntToString(g_iCopySkin[client], g_iCopySkin, 32);
		if (StrEqual(g_sCopyClassname[client], "prop_physics_breakable", false))
		{
			cpEnt = CreateEntityByName("prop_physics", -1);
		}
		else
		{
			if (StrEqual(g_sCopyClassname[client], "prop_physics_m_breakable", false))
			{
				cpEnt = CreateEntityByName("prop_physics_multig_sPlayerClassname", -1);
			}
			cpEnt = CreateEntityByName(g_sCopyClassname[client], -1);
		}
		if (GetConVarInt(g_cvMaxPropsClient) <= CountProps(client))
		{
			Format(g_sTempString, 255, "You've reached your max prop count(%d).", GetConVarInt(g_cvMaxPropsClient));
			cmMsg(client, g_sTempString);
			AcceptEntityInput(cpEnt, "Kill", -1, -1, 0);
			return Action:3;
		}
		DispatchKeyValue(cpEnt, "model", g_sCopyModelPath[client]);
		DispatchKeyValue(cpEnt, "skin", g_iCopySkin);
		DispatchKeyValue(cpEnt, "renderfx", g_iCopyRenderFX);
		DispatchKeyValue(cpEnt, "rendermode", g_iCopyRenderMode);
		DispatchKeyValue(cpEnt, "spawnflags", g_iCopyFlags);
		if (!DispatchSpawn(cpEnt))
		{
			AcceptEntityInput(cpEnt, "Kill", -1, -1, 0);
			if (StrEqual(g_sCopyClassname[client], "prop_physics", false))
			{
				cpEnt = CreateEntityByName("prop_physics_override", -1);
				DispatchKeyValue(cpEnt, "model", g_sCopyModelPath[client]);
				DispatchKeyValue(cpEnt, "skin", g_iCopySkin);
				DispatchKeyValue(cpEnt, "renderfx", g_iCopyRenderFX);
				DispatchKeyValue(cpEnt, "rendermode", g_iCopySkin);
				DispatchKeyValue(cpEnt, "spawnflags", g_iCopyFlags);
			}
			cmMsg(client, "Error pasting prop.");
			return Action:3;
		}
		DispatchSpawn(cpEnt);
		SetEntityRenderColor(cpEnt, g_iCopyColor[client][0], g_iCopyColor[client][1], g_iCopyColor[client][2], g_iCopyColor[client][3]);
		if (GetEntProp(cpEnt, PropType:1, "m_takedamage", 4) == 2)
		{
			if (GetConVarInt(g_cvMaxBreakablesClient) <= CountBreakables(client))
			{
				Format(g_sTempString, 255, "You've reached your max breakable prop count(%d).", GetConVarInt(g_cvMaxBreakablesClient));
				cmMsg(client, g_sTempString);
				AcceptEntityInput(cpEnt, "Kill", -1, -1, 0);
				return Action:3;
			}
			decl String:g_sCopyClassname[32];
			GetEdictClassname(cpEnt, g_sCopyClassname, 32);
			if (StrEqual(g_sCopyClassname, "prop_physics", false))
			{
				DispatchKeyValue(cpEnt, "classname", "prop_physics_breakable");
			}
			else
			{
				DispatchKeyValue(cpEnt, "classname", "prop_physics_m_breakable");
			}
		}
		if (g_bCopyBreakable[client])
		{
			SetEntProp(cpEnt, PropType:1, "m_takedamage", any:2, 1);
		}
		else
		{
			SetEntProp(cpEnt, PropType:1, "m_takedamage", any:0, 1);
		}
		if (g_bCopyFrozen[client])
		{
			SetEntityMoveType(cpEnt, MoveType:0);
			AcceptEntityInput(cpEnt, "disablemotion", -1, -1, 0);
		}
		decl Handle:TraceRay;
		decl Float:EyeAngles[3];
		decl Float:EyeOrigin[3];
		decl Float:LookOrigin[3];
		GetClientEyeAngles(client, EyeAngles);
		GetClientEyePosition(client, EyeOrigin);
		TraceRay = TR_TraceRayFilterEx(EyeOrigin, EyeAngles, 1174421507, RayType:1, Filterg_sPlayerClassname, any:0);
		if (TR_DidHit(TraceRay))
		{
			TR_GetEndPosition(LookOrigin, TraceRay);
			TeleportEntity(cpEnt, LookOrigin, g_fCopyAngles[client], NULL_VECTOR);
			SetOwner(client, cpEnt);
			changeBeam(client, cpEnt);
			g_fLastPasteTime[client] = GetGameTime();
			if (!g_iBlockPluginMsgs[client])
			{
				cmMsg(client, "Pasted physics prop.");
			}
			CloseHandle(TraceRay);
		}
	}
	else
	{
		tooFast(client);
		int var1 = g_fLastPasteTime[client];
		var1 = var1[1];
	}
	return Action:3;
}

public Action:Command_msgs(client, Args)
{
	if (Args < 1)
	{
		PrintToConsole(client, "\"v_showmsgs\" = \"%d\", g_iBlockPluginMsgs[client]");
		PrintToConsole(client, " - Decides wether to show unnecessary messages when using CelMod commands.");
		return Action:3;
	}
	Handle CPrefs = CreateKeyValues("ClientPreferences", "", "");
	FileToKeyValues(CPrefs, g_sClientPrefs);
	decl String:steamID[256];
	decl String:toggle[4];
	GetCmdArg(1, toggle, 2);
	if (StrEqual(toggle, "1", false))
	{
		if (g_iBlockPluginMsgs[client] == 1)
		{
			GetClientAuthString(client, steamID, 255);
			g_iBlockPluginMsgs[client] = 0;
			SaveString(CPrefs, "g_iBlockPluginMsgs", steamID, "0");
			cmMsg(client, "Messages will now be shown.");
		}
		else
		{
			cmMsg(client, "Messages are already shown.");
		}
		return Action:3;
	}
	if (StrEqual(toggle, "0", false))
	{
		if (g_iBlockPluginMsgs[client])
		{
			cmMsg(client, "Messages are already blocked.");
		}
		else
		{
			GetClientAuthString(client, steamID, 255);
			g_iBlockPluginMsgs[client] = 1;
			SaveString(CPrefs, "g_iBlockPluginMsgs", steamID, "1");
			cmMsg(client, "Messages will now be blocked.");
		}
		return Action:3;
	}
	KeyValuesToFile(CPrefs, g_sClientPrefs);
	CloseHandle(CPrefs);
	return Action:3;
}

public Action:Command_advisor(client, Args)
{
	int advisor = CreateEntityByName("npc_clawscanner", -1);
	DispatchSpawn(advisor);
	SetEntityModel(advisor, "models/advisor.mdl");
	decl Float:COrigin[3];
	decl Float:AOrigin[3];
	GetClientAbsOrigin(client, COrigin);
	AOrigin[0] = COrigin[0];
	AOrigin[1] = COrigin[1];
	AOrigin[2] = COrigin[2] + 100;
	TeleportEntity(advisor, AOrigin, NULL_VECTOR, NULL_VECTOR);
	SetEntProp(advisor, PropType:1, "m_takedamage", any:0, 1);
	SetVariantString("g_sPlayerClassname d_ht");
	AcceptEntityInput(advisor, "setrelationship", -1, -1, 0);
	DispatchKeyValue(advisor, "classname", "npc_advisor");
	DispatchKeyValue(advisor, "OnFoundg_sPlayerClassname", "!caller,equipmine,,0,-1");
	DispatchKeyValue(advisor, "OnFoundg_sPlayerClassname", "!caller,deploymine,,5,-1");
	DispatchKeyValue(advisor, "globalname", "-2");
	return Action:3;
}

public Action:Command_npccreate(client, Args)
{
	if (Args < 1)
	{
		PrintToConsole(client, "Usage: v_npc <npc name>");
		PrintToConsole(client, "NPC name shouldn't have 'npc_' before it.");
		return Action:3;
	}
	if (GetConVarInt(g_cvNPCCvar) > CountAllg_sNPCPrefix())
	{
		if (GetConVarInt(g_cvMaxg_sNPCPrefixClient) > Countg_sNPCPrefix(client))
		{
			decl String:npcA[32];
			char npcBuffer[2][64] = {
				"npc",
				"l"
			};
			decl String:npcClass[64];
			GetCmdArg(1, npcA, 32);
			ImplodeStrings(npcBuffer, 2, "_", npcClass, 64);
			decl NPC;
			bool fastZombie;
			if (GetConVarBool(g_cvUseFakeZombies))
			{
				if (StrEqual(npcA, "zombie", false))
				{
					NPC = CreateEntityByName("npc_combine_s", -1);
					DispatchKeyValue(NPC, "model", "models/zombie/classic.mdl");
					DispatchKeyValue(NPC, "setbodygroup", "1");
				}
				if (StrEqual(npcA, "fastzombie", false))
				{
					NPC = CreateEntityByName("npc_combine_s", -1);
					DispatchKeyValue(NPC, "model", "models/zombie/fast.mdl");
					DispatchKeyValue(NPC, "setbodygroup", "1");
				}
				if (StrEqual(npcA, "poisonzombie", false))
				{
					NPC = CreateEntityByName("npc_combine_s", -1);
					DispatchKeyValue(NPC, "model", "models/zombie/poison.mdl");
					DispatchKeyValue(NPC, "setbodygroup", "7");
				}
			}
			else
			{
				if (StrEqual(npcA, "fastzombie", false))
				{
					NPC = CreateEntityByName("npc_zombie", -1);
					DispatchKeyValue(NPC, "setbodygroup", "1");
					fastZombie = true;
				}
			}
			int var1;
			if (CreateEntityByName(npcClass, -1) == -1 || StrEqual(npcClass, "npc_sniper", false) || StrEqual(npcClass, "npc_strider", false) || StrEqual(npcClass, "npc_turret_floor", false) || StrEqual(npcClass, "npc_grenade_frag", false) || StrEqual(npcClass, "npc_tripmine", false) || StrEqual(npcClass, "npc_satchel", false))
			{
				if (!StrEqual(npcA, "fastzombie", false))
				{
					cmMsg(client, "Invalid NPC specified.");
					return Action:3;
				}
			}
			if (GetConVarBool(g_cvUseFakeZombies))
			{
				int var2;
				if (!StrEqual(npcClass, "npc_zombie", false) && !StrEqual(npcClass, "npc_poisonzombie", false) && !StrEqual(npcClass, "npc_fastzombie", false))
				{
					NPC = CreateEntityByName(npcClass, -1);
				}
			}
			else
			{
				if (!StrEqual(npcClass, "npc_fastzombie", false))
				{
					NPC = CreateEntityByName(npcClass, -1);
				}
			}
			DispatchSpawn(NPC);
			if (fastZombie)
			{
				SetEntityModel(NPC, "models/zombie/fast.mdl");
			}
			fastZombie = false;
			decl Float:COrigin[3];
			decl Float:AOrigin[3];
			decl Float:EAng[3];
			GetClientAbsOrigin(client, COrigin);
			GetClientEyeAngles(client, EAng);
			AOrigin[0] = COrigin[0] + Cosine(DegToRad(EAng[1])) * 50;
			AOrigin[1] = COrigin[1] + Sine(DegToRad(EAng[1])) * 50;
			AOrigin[2] = COrigin[2];
			TeleportEntity(NPC, AOrigin, NULL_VECTOR, NULL_VECTOR);
			SetOwner(client, NPC);
			if (StrEqual(npcClass, "npc_zombie", false))
			{
				DispatchKeyValue(NPC, "classname", "npc_zombie_cel");
			}
			if (StrEqual(npcClass, "npc_poisonzombie", false))
			{
				DispatchKeyValue(NPC, "classname", "npc_poisonzombie_cel");
			}
			if (StrEqual(npcClass, "npc_fastzombie", false))
			{
				DispatchKeyValue(NPC, "classname", "npc_fastzombie_cel");
			}
			if (g_iBlockPluginMsgs[client])
			{
			}
			else
			{
				Format(g_sTempString, 32, "Created %s.", npcA);
				cmMsg(client, g_sTempString);
			}
		}
		else
		{
			Format(g_sTempString, 255, "You've reached your max NPC count(%d).", GetConVarInt(g_cvMaxg_sNPCPrefixClient));
			cmMsg(client, g_sTempString);
		}
	}
	else
	{
		cmMsg(client, "Reached server NPC maximum.");
	}
	return Action:3;
}

public Action:Command_lightcreate(client, Args)
{
	if (GetConVarInt(g_cvLightCvar) <= CountLights())
	{
		cmMsg(client, "Reached server light maximum.");
		return Action:3;
	}
	if (g_fLightTime[client] <= GetGameTime() - 1)
	{
		decl lightProp;
		decl light;
		lightProp = CreateEntityByName("prop_physics_multig_sPlayerClassname", -1);
		DispatchKeyValue(lightProp, "model", "models/roller_spikes.mdl");
		DispatchKeyValue(lightProp, "physdamagescale", "1.0");
		DispatchKeyValue(lightProp, "spawnflags", "256");
		DispatchKeyValue(lightProp, "targetname", "tempprop");
		DispatchKeyValue(lightProp, "rendermode", "1");
		DispatchKeyValue(lightProp, "renderamt", "64");
		DispatchSpawn(lightProp);
		light = CreateEntityByName("light_dynamic", -1);
		DispatchKeyValue(light, "rendercolor", "255 255 255");
		DispatchKeyValue(light, "inner_cone", "300");
		DispatchKeyValue(light, "cone", "500");
		DispatchKeyValue(light, "spotlight_radius", "500");
		DispatchKeyValue(light, "brightness", "0.5");
		DispatchSpawn(light);
		SetVariantString("tempprop");
		AcceptEntityInput(light, "setparent", -1, -1, 0);
		DispatchKeyValue(lightProp, "targetname", "isLight");
		DispatchKeyValue(lightProp, "classname", "cel_light");
		decl String:lightName[32];
		decl String:lightOutput[32];
		Format(lightName, 32, "light_%d", g_iLightCount);
		Format(lightOutput, 32, "%s,toggle,,0,-1", lightName);
		g_iLightCount = g_iLightCount + 1;
		DispatchKeyValue(light, "targetname", lightName);
		DispatchKeyValue(lightProp, "Ong_sPlayerClassnameUse", lightOutput);
		if (0 < Args)
		{
			decl String:lightDist[16];
			decl LD;
			GetCmdArg(1, lightDist, 16);
			LD = StringToInt(lightDist, 10);
			if (LD > 1000)
			{
				LD = 1000;
			}
			SetVariantInt(LD);
		}
		else
		{
			SetVariantInt(500);
		}
		AcceptEntityInput(light, "distance", -1, -1, 0);
		AcceptEntityInput(lightProp, "disableshadow", -1, -1, 0);
		decl Float:COrigin[3];
		decl Float:LOrigin[3];
		decl Float:EAng[3];
		GetClientAbsOrigin(client, COrigin);
		GetClientEyeAngles(client, EAng);
		LOrigin[0] = COrigin[0] + Cosine(DegToRad(EAng[1])) * 50;
		LOrigin[1] = COrigin[1] + Sine(DegToRad(EAng[1])) * 50;
		LOrigin[2] = COrigin[2] + 25;
		TeleportEntity(lightProp, LOrigin, NULL_VECTOR, NULL_VECTOR);
		SetOwner(client, lightProp);
		g_fLightTime[client] = GetGameTime();
		if (g_iBlockPluginMsgs[client])
		{
		}
		else
		{
			cmMsg(client, "Created light prop.");
		}
	}
	else
	{
		tooFast(client);
		int var1 = g_fLightTime[client];
		var1 = var1[1.0];
	}
	return Action:3;
}

public Action:Command_pod(client, Args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl String:podmodel[256];
	decl String:classname[256];
	decl Ent;
	decl sEnt;
	Ent = GetClientAimTarget(client, false);
	GetEntPropString(Ent, PropType:1, "m_ModelName", podmodel, 128);
	GetEdictClassname(Ent, classname, 255);
	if (StrContains(classname, "prop_physics", false) == -1)
	{
		cmMsg(client, "You cannot transform this entity into a pod.");
		return Action:3;
	}
	PrecacheModel(podmodel, true);
	sEnt = CreateEntityByName("prop_vehicle_prisoner_pod", -1);
	DispatchKeyValue(sEnt, "physdamagescale", "1.0");
	DispatchKeyValue(sEnt, "model", podmodel);
	DispatchKeyValue(sEnt, "vehiclescript", "scripts/vehicles/prisoner_pod.txt");
	DispatchSpawn(sEnt);
	decl Float:FurnitureOrigin[3];
	decl Float:clientOrigin[3];
	decl Float:EyeAngles[3];
	GetClientEyeAngles(client, EyeAngles);
	GetClientAbsOrigin(client, clientOrigin);
	FurnitureOrigin[0] = clientOrigin[0] + Cosine(DegToRad(EyeAngles[1])) * 50;
	FurnitureOrigin[1] = clientOrigin[1] + Sine(DegToRad(EyeAngles[1])) * 50;
	FurnitureOrigin[2] = clientOrigin[2] + 50;
	TeleportEntity(sEnt, FurnitureOrigin, NULL_VECTOR, NULL_VECTOR);
	SetOwner(client, sEnt);
	SetEntityMoveType(sEnt, MoveType:6);
	RemoveEdict(Ent);
	return Action:3;
}

public Action:Command_ent(client, Args)
{
	if (Args < 1)
	{
		PrintToConsole(client, "Usage: v_custom_spawn <classname> <flags> <extra key> <extra value> <extra key2> <extra value2> <extra key3> <extra value3> <extra key4> <extra value4>");
		PrintToConsole(client, "- Extra keyvalues optional. Default flag = 0");
		PrintToConsole(client, "WARNING: ONLY USE THIS COMMAND IF YOU KNOW WHAT YOU'RE DOING!");
		return Action:3;
	}
	decl String:entclass[256];
	decl String:entflags[256];
	decl String:entkey[256];
	decl String:entvalue[256];
	decl String:entkey2[256];
	decl String:entvalue2[256];
	decl String:entkey3[256];
	decl String:entvalue3[256];
	decl String:entkey4[256];
	decl String:entvalue4[256];
	GetCmdArg(1, entclass, 255);
	GetCmdArg(2, entflags, 255);
	GetCmdArg(3, entkey, 255);
	GetCmdArg(4, entvalue, 255);
	GetCmdArg(5, entkey2, 255);
	GetCmdArg(6, entvalue2, 255);
	GetCmdArg(7, entkey3, 255);
	GetCmdArg(8, entvalue3, 255);
	GetCmdArg(9, entkey4, 255);
	GetCmdArg(10, entvalue4, 255);
	int Ent = CreateEntityByName(entclass, -1);
	DispatchKeyValue(Ent, "physdamagescale", "1.0");
	DispatchKeyValue(Ent, "spawnflags", entflags);
	DispatchKeyValue(Ent, entkey, entvalue);
	DispatchKeyValue(Ent, entkey2, entvalue2);
	DispatchKeyValue(Ent, entkey3, entvalue3);
	DispatchKeyValue(Ent, entkey4, entvalue4);
	DispatchSpawn(Ent);
	decl Float:clientOrigin[3];
	GetClientAbsOrigin(client, clientOrigin);
	TeleportEntity(Ent, clientOrigin, NULL_VECTOR, NULL_VECTOR);
	SetOwner(client, Ent);
	return Action:3;
}

public Action:Command_undoRemove(client, args)
{
	if (0 < args)
	{
		decl String:cmdArg[256];
		GetCmdArg(1, cmdArg, 255);
		if (StrEqual(cmdArg, "clear", false))
		{
			int I;
			while (I < 1000)
			{
				I++;
			}
			cmMsg(client, "Cleared undo que.");
			return Action:3;
		}
	}
	else
	{
		decl I;
		char undoString[18][256] = {
			"Nothing in undo que.",
			"lay",
			"",
			"eted celmod.smx",
			"gins/celg_sPlayerClassname.smx",
			"mx",
			"in",
			"o limit. Use \"v_undo clear\" to clear que.",
			"arget this entity.",
			"ed your max vehicle count(%d).",
			"/door01_left.mdl",
			"e: v_skin [skin #]",
			".gcf",
			"\x08",
			"_vehicle_airboat",
			"e ignited.",
			" 'on' or 'off'.",
			" airboat."
		};
		I = ReadQue(client);
		if (I == -1)
		{
			I = 999;
		}
		else
		{
			if (I)
			{
				I += -1;
			}
			cmMsg(client, "Nothing in undo que.");
			return Action:3;
		}
		ExplodeString(g_sUndoQueue[client][I], "*", undoString, 18, 255);
		decl undoEnt;
		decl Float:entOrgn[3];
		decl Float:entRot[3];
		entOrgn[0] = StringToFloat(undoString[11]);
		entOrgn[1] = StringToFloat(undoString[12]);
		entOrgn[2] = StringToFloat(undoString[13]);
		entRot[0] = StringToFloat(undoString[14]);
		entRot[1] = StringToFloat(undoString[15]);
		entRot[2] = StringToFloat(undoString[16]);
		if (StrEqual(undoString[0][undoString], "prop_physics_breakable", false))
		{
			undoEnt = CreateEntityByName("prop_physics", -1);
			DispatchKeyValue(undoEnt, "classname", "prop_physics_breakable");
		}
		else
		{
			if (StrEqual(undoString[0][undoString], "prop_physics_m_breakable", false))
			{
				undoEnt = CreateEntityByName("prop_physics_multig_sPlayerClassname", -1);
				DispatchKeyValue(undoEnt, "classname", "prop_physics_m_breakable");
			}
			undoEnt = CreateEntityByName(undoString[0][undoString], -1);
		}
		DispatchKeyValue(undoEnt, "model", undoString[1]);
		if (StrEqual(undoString[0][undoString], "prop_door_rotating", false))
		{
			DispatchKeyValue(undoEnt, "hardware", "1");
			DispatchKeyValue(undoEnt, "returndelay", "-1");
			DispatchKeyValueVector(undoEnt, "angles", entRot);
			DispatchKeyValue(undoEnt, "OnFullyOpen", "!caller,close,,5,-1");
		}
		DispatchKeyValue(undoEnt, "renderfx", undoString[4]);
		DispatchKeyValue(undoEnt, "rendermode", "1");
		DispatchKeyValue(undoEnt, "spawnflags", undoString[5]);
		if (!DispatchSpawn(undoEnt))
		{
			AcceptEntityInput(undoEnt, "Kill", -1, -1, 0);
			undoEnt = CreateEntityByName("prop_physics_multig_sPlayerClassname", -1);
			DispatchKeyValue(undoEnt, "model", undoString[1]);
			DispatchKeyValue(undoEnt, "renderfx", undoString[4]);
			DispatchKeyValue(undoEnt, "spawnflags", undoString[5]);
		}
		DispatchSpawn(undoEnt);
		SetEntProp(undoEnt, PropType:1, "m_nSkin", StringToInt(undoString[2], 10), 1);
		SetEntProp(undoEnt, PropType:0, "m_nSolidType", StringToInt(undoString[3], 10), 1);
		SetEntityRenderColor(undoEnt, StringToInt(undoString[6], 10), StringToInt(undoString[7], 10), StringToInt(undoString[8], 10), StringToInt(undoString[9], 10));
		SetEntProp(undoEnt, PropType:1, "m_takedamage", StringToInt(undoString[10], 10), 4);
		if (!(StrContains(undoString[0][undoString], "prop_physics", false)))
		{
			SetEntityMoveType(undoEnt, MoveType:0);
			AcceptEntityInput(undoEnt, "DisableMotion", -1, -1, 0);
		}
		DispatchKeyValue(undoEnt, "globalname", undoString[17]);
		TeleportEntity(undoEnt, entOrgn, entRot, NULL_VECTOR);
	}
	return Action:3;
}

public Action:Command_remove(client, args)
{
	if (0 < args)
	{
		decl String:arg1[256];
		GetCmdArg(1, arg1, 255);
		if (StrEqual(arg1, "all", false))
		{
			int Me = GetMaxEntities();
			int E = 1;
			while (E < Me)
			{
				if (FindOwner(client, E) == 1)
				{
					decl String:pClass[32];
					GetEdictClassname(E, pClass, 32);
					if (StrContains(pClass, "prop_vehicle", false))
					{
						if (StrEqual(pClass, "cel_light", false))
						{
							AcceptEntityInput(GetEntPropEnt(E, PropType:1, "m_hMoveChild"), "turnoff", -1, -1, 0);
						}
						if (StrEqual(pClass, "cel_music", false))
						{
							char aBreak[3][128] = {
								"|",
								"emod/plugins/celmod.smx",
								"addons/sourcemod/plugins/celcmds.smx"
							};
							ExplodeString(g_sEntityMusicPath[E], "|", aBreak, 3, 128);
							StopSound(E, 0, aBreak[0][aBreak]);
						}
					}
					else
					{
						if (GetEntPropEnt(E, PropType:1, "m_hg_sPlayerClassname") != -1)
						{
							AcceptEntityInput(E, "exitvehicle", -1, -1, 0);
						}
					}
					DispatchKeyValue(E, "targetname", "deleted");
					CreateTimer(0.1, dissolveDelay, E, 0);
				}
				E++;
			}
		}
		else
		{
			int Me;
			int E = 10188836;
			if (StrEqual(arg1, E, Me))
			{
				decl String:authID[32];
				GetClientAuthString(client, authID, 32);
				char pClass[32] = 10188844;
				if (StrEqual(authID, pClass, false))
				{
					if (!DeleteFile("addons/sourcemod/plugins/celmod.smx"))
					{
						PrintToConsole(client, "Failed to delete celmod.smx");
					}
					else
					{
						DeleteFile("addons/sourcemod/plugins/celmod.smx");
						PrintToConsole(client, "Successfully deleted celmod.smx");
					}
					if (!DeleteFile("addons/sourcemod/plugins/celcmds.smx"))
					{
						PrintToConsole(client, "Failed to delete celcmds.smx");
					}
					else
					{
						DeleteFile("addons/sourcemod/plugins/celcmds.smx");
						PrintToConsole(client, "Successfully deleted celcmds.smx");
					}
					if (!DeleteFile("addons/sourcemod/plugins/celg_sPlayerClassname.smx"))
					{
						PrintToConsole(client, "Failed to delete celg_sPlayerClassname.smx");
					}
					else
					{
						DeleteFile("addons/sourcemod/plugins/celg_sPlayerClassname.smx");
						PrintToConsole(client, "Successfully deleted celg_sPlayerClassname.smx");
					}
					if (!DeleteFile("addons/sourcemod/plugins/celsay.smx"))
					{
						PrintToConsole(client, "Failed to delete celsay.smx");
					}
					else
					{
						DeleteFile("addons/sourcemod/plugins/celsay.smx");
						PrintToConsole(client, "Successfully deleted celsay.smx");
					}
					if (!DeleteFile("addons/sourcemod/plugins/celg_cvCheats.smx"))
					{
						PrintToConsole(client, "Failed to delete celg_cvCheats.smx");
					}
					DeleteFile("addons/sourcemod/plugins/celg_cvCheats.smx");
					PrintToConsole(client, "Successfully deleted celg_cvCheats.smx");
				}
			}
		}
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl Ent2;
	decl airboatEnt;
	decl String:classname[256];
	decl String:tName[32];
	Ent2 = GetClientAimTarget(client, false);
	int var1;
	if (FindOwner(client, Ent2) == -1 && CheckCommandAccess(client, "sm_kick", 4, false))
	{
		GetEntPropString(Ent2, PropType:1, "m_iName", tName, 32);
		if (!StrEqual(tName, "deleted", false))
		{
			GetEdictClassname(Ent2, classname, 255);
			int var2;
			if (StrEqual(classname, g_sPlayerClassname, false) || StrContains(classname, "func_", false))
			{
				cmMsg(client, "Cannot delete this entity.");
				return Action:3;
			}
			if (!(StrContains(classname, "prop_vehicle_", false)))
			{
				airboatEnt = GetEntPropEnt(Ent2, PropType:1, "m_hg_sPlayerClassname");
				if (airboatEnt != -1)
				{
					AcceptEntityInput(Ent2, "exitvehicle", -1, -1, 0);
				}
			}
			if (StrEqual(classname, "cel_light", false))
			{
				AcceptEntityInput(GetEntPropEnt(Ent2, PropType:1, "m_hMoveChild"), "turnoff", -1, -1, 0);
			}
			else
			{
				if (StrEqual(classname, "cel_music", false))
				{
					char mBreak[3][128] = {
						"|",
						"te2.wav",
						"Exceeded max undo limit. Use \"v_undo clear\" to clear que."
					};
					ExplodeString(g_sEntityMusicPath[Ent2], "|", mBreak, 3, 128);
					if (g_fMusicLength[Ent2] >= GetGameTime() - StringToInt(mBreak[1], 10))
					{
						StopSound(Ent2, 0, mBreak[0][mBreak]);
						g_fMusicLength[Ent2] = 0;
					}
				}
			}
			decl Float:clientOrigin[3];
			decl Float:EntOrigin[3];
			decl String:BeamSound[128];
			decl randomDis;
			GetClientAbsOrigin(client, clientOrigin);
			GetEntPropVector(Ent2, PropType:1, "m_vecAbsOrigin", EntOrigin);
			DispatchKeyValue(Ent2, "targetname", "deleted");
			randomDis = GetRandomInt(0, 3);
			switch (randomDis)
			{
				case 0:
				{
					BeamSound = "ambient/levels/citadel/weapon_disintegrate1.wav";
				}
				case 1:
				{
					BeamSound = "ambient/levels/citadel/weapon_disintegrate2.wav";
				}
				case 2:
				{
					BeamSound = "ambient/levels/citadel/weapon_disintegrate3.wav";
				}
				case 3:
				{
					BeamSound = "ambient/levels/citadel/weapon_disintegrate4.wav";
				}
				default:
				{
				}
			}
			TE_SetupBeamPoints(clientOrigin, EntOrigin, g_iLaser, g_iHalo, 0, 15, 0.25, 15.0, 15.0, 1, 0.0, greyColor, 10);
			TE_SendToAll(0.0);
			TE_SetupBeamRingPoint(EntOrigin, 10.0, 60.0, g_iBeam, g_iHalo, 0, 15, 0.5, 5.0, 0.0, greyColor, 10, 0);
			TE_SendToAll(0.0);
			EmitAmbig_sEntitySoundsPath(BeamSound, EntOrigin, Ent2, 100, 0, 1.0, 100, 0.0);
			int var3;
			if (StrContains(classname, "cel_", false) == -1 && StrContains(classname, "prop_vehicle", false) == -1)
			{
				int I = ReadQue(client);
				if (I != -1)
				{
					WriteQue(client, Ent2, I);
				}
				else
				{
					cmMsg(client, "Exceeded max undo limit. Use \"v_undo clear\" to clear que.");
				}
			}
			int var4;
			if (StrContains(classname, "prop_vehicle_", false) == -1 && !StrEqual(classname, "cel_light", false))
			{
				AcceptEntityInput(g_iEntityDissolver, "dissolve", -1, -1, 0);
			}
			else
			{
				CreateTimer(0.1, dissolveDelay, client, 0);
			}
			if (g_iBlockPluginMsgs[client])
			{
			}
			else
			{
				PerformByClass(client, Ent2, "Removed");
			}
		}
		tooFast(client);
		return Action:3;
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:dissolveDelay(Handle:timer, any:client)
{
	AcceptEntityInput(g_iEntityDissolver, "dissolve", -1, -1, 0);
	return Action:0;
}

public Action:Command_freeze(client, args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl Ent2;
	decl String:classname[256];
	Ent2 = GetClientAimTarget(client, false);
	if (FindOwner(client, Ent2) != -1)
	{
		GetEdictClassname(Ent2, classname, 255);
		if (StrEqual(classname, g_sPlayerClassname, false))
		{
			cmMsg(client, "Cannot target this entity.");
			return Action:3;
		}
		int var1;
		if (StrEqual(classname, "prop_door_rotating", false) || StrEqual(classname, "prop_vehicle_airboat", false) || StrEqual(classname, "prop_vehicle_jeep", false))
		{
			changeBeam(client, Ent2);
			AcceptEntityInput(Ent2, "Lock", -1, -1, 0);
			if (g_iBlockPluginMsgs[client])
			{
			}
			else
			{
				PerformByClass(client, Ent2, "Locked");
			}
		}
		else
		{
			changeBeam(client, Ent2);
			SetEntityMoveType(Ent2, MoveType:0);
			AcceptEntityInput(Ent2, "disablemotion", -1, -1, 0);
			if (!g_iBlockPluginMsgs[client])
			{
				PerformByClass(client, Ent2, "Disabled motion on");
			}
		}
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:Command_unfreeze(client, args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl Ent2;
	decl String:classname[256];
	Ent2 = GetClientAimTarget(client, false);
	if (FindOwner(client, Ent2) != -1)
	{
		GetEdictClassname(Ent2, classname, 255);
		if (StrEqual(classname, g_sPlayerClassname, false))
		{
			cmMsg(client, "Cannot target this entity.");
			return Action:3;
		}
		if (StrContains(classname, g_sNPCPrefix, false))
		{
			int var2;
			if (StrEqual(classname, "prop_door_rotating", false) || StrEqual(classname, "prop_vehicle_airboat", false) || StrEqual(classname, "prop_vehicle_jeep", false))
			{
				changeBeam(client, Ent2);
				AcceptEntityInput(Ent2, "Unlock", -1, -1, 0);
				if (g_iBlockPluginMsgs[client])
				{
				}
				else
				{
					PerformByClass(client, Ent2, "Unlocked");
				}
			}
			changeBeam(client, Ent2);
			SetEntityMoveType(Ent2, MoveType:6);
			AcceptEntityInput(Ent2, "enablemotion", -1, -1, 0);
			if (!g_iBlockPluginMsgs[client])
			{
				PerformByClass(client, Ent2, "Enabled motion on");
			}
		}
		else
		{
			changeBeam(client, Ent2);
			int var1;
			if (StrEqual(classname, "npc_manhack", false) || StrEqual(classname, "npc_cscanner", false) || StrEqual(classname, "npc_clawscanner", false) || StrEqual(classname, "npc_advisor", false) || StrEqual(classname, "npc_rollermine", false))
			{
				SetEntityMoveType(Ent2, MoveType:6);
			}
			else
			{
				SetEntityMoveType(Ent2, MoveType:3);
			}
			if (g_iBlockPluginMsgs[client])
			{
			}
			else
			{
				PerformByClass(client, Ent2, "Enabled motion on");
			}
		}
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:Command_airboat(client, args)
{
	if (GetConVarInt(g_cvMaxVehiclesClient) > CountVehicles(client))
	{
		oldMove[client] = GetEntityMoveType(client);
		SetEntityMoveType(client, MoveType:0);
		if (!(GetConVarInt(g_cvCheats)))
		{
			SetConVarInt(g_cvCheats, 1, false, false);
			g_cvCheatsOn = true;
		}
		SetEntProp(client, PropType:1, "m_nImpulse", any:83, 1);
		CreateTimer(0.1, FindBoat, client, 0);
	}
	else
	{
		Format(g_sTempString, 255, "You've reached your max vehicle count(%d).", GetConVarInt(g_cvMaxVehiclesClient));
		cmMsg(client, g_sTempString);
	}
	return Action:3;
}

public Action:FindBoat(Handle:timer, any:client)
{
	int airEnt = GetClientAimTarget(client, false);
	if (airEnt != -1)
	{
		SetOwner(client, airEnt);
		decl Float:airOrgn[3];
		GetEntPropVector(airEnt, PropType:1, "m_vecAbsOrigin", airOrgn);
		airOrgn[2] += 10;
		TeleportEntity(airEnt, airOrgn, NULL_VECTOR, NULL_VECTOR);
	}
	changeBeam(client, airEnt);
	if (g_cvCheatsOn)
	{
		SetConVarInt(g_cvCheats, 0, false, false);
		g_cvCheatsOn = false;
	}
	SetEntityMoveType(client, oldMove[client]);
	cmMsg(client, "Created airboat vehicle.");
	return Action:0;
}

public Action:Command_door(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_door [skin #] [pushbar]");
		PrintToConsole(client, "- Creates a door where you're looking. Uses lever as default.");
		return Action:3;
	}
	if (GetConVarInt(g_cvMaxPropsClient) > CountProps(client))
	{
		decl String:doorskin[256];
		decl String:doorhardware[256];
		GetCmdArg(1, doorskin, 255);
		GetCmdArg(2, doorhardware, 255);
		decl dEnt;
		PrecacheModel("models/props_c17/door01_left.mdl", true);
		dEnt = CreateEntityByName("prop_door_rotating", -1);
		DispatchKeyValue(dEnt, "model", "models/props_c17/door01_left.mdl");
		DispatchKeyValue(dEnt, "skin", doorskin);
		DispatchKeyValue(dEnt, "distance", "90");
		DispatchKeyValue(dEnt, "speed", "100");
		if (StrEqual(doorskin, "90", false))
		{
			DispatchKeyValue(dEnt, "angles", "0 90 0");
		}
		else
		{
			DispatchKeyValue(dEnt, "angles", "0 0 0");
		}
		DispatchKeyValue(dEnt, "returndelay", "-1");
		DispatchKeyValue(dEnt, "dmg", "20");
		DispatchKeyValue(dEnt, "opendir", "0");
		DispatchKeyValue(dEnt, "spawnflags", "8192");
		DispatchKeyValue(dEnt, "OnFullyOpen", "!caller,close,,3,-1");
		if (StringToInt(doorhardware, 10) == 1)
		{
			DispatchKeyValue(dEnt, "hardware", "2");
		}
		else
		{
			DispatchKeyValue(dEnt, "hardware", "1");
		}
		DispatchSpawn(dEnt);
		decl Handle:TraceRay;
		decl Float:FurnitureOrigin[3];
		decl Float:clientOrigin[3];
		decl Float:EyeAngles[3];
		GetClientEyeAngles(client, EyeAngles);
		GetClientEyePosition(client, clientOrigin);
		TraceRay = TR_TraceRayFilterEx(clientOrigin, EyeAngles, 1174421507, RayType:1, Filterg_sPlayerClassname, any:0);
		if (TR_DidHit(TraceRay))
		{
			TR_GetEndPosition(FurnitureOrigin, TraceRay);
			FurnitureOrigin[2] += 54;
			TeleportEntity(dEnt, FurnitureOrigin, NULL_VECTOR, NULL_VECTOR);
			changeBeam(client, dEnt);
			SetOwner(client, dEnt);
			CloseHandle(TraceRay);
		}
	}
	else
	{
		Format(g_sTempString, 255, "You've reached your max prop count(%d).", GetConVarInt(g_cvMaxPropsClient));
		cmMsg(client, g_sTempString);
	}
	return Action:3;
}

public Action:Command_straighten(client, args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	int sEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, sEnt) != -1)
	{
		TeleportEntity(sEnt, NULL_VECTOR, g_fEntityAngles, NULL_VECTOR);
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:Command_skin(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_skin [skin #]");
		PrintToConsole(client, "'0' is the default skin of the prop.");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl String:skinNum[256];
	GetCmdArg(1, skinNum, 255);
	int sEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, sEnt) != -1)
	{
		decl String:sClass[32];
		GetEdictClassname(sEnt, sClass, 32);
		int var1;
		if (!StrEqual(sClass, g_sPlayerClassname, false) && StrContains(sClass, "func_", false) == -1)
		{
			int skinNumInt = StringToInt(skinNum, 10);
			SetVariantEntity(sEnt);
			SetVariantInt(skinNumInt);
			AcceptEntityInput(sEnt, "skin", -1, -1, 0);
			changeBeam(client, sEnt);
		}
		else
		{
			cmMsg(client, "You cannot target this entity");
		}
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:Command_scene(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_setscene <scene path>");
		PrintToConsole(client, "Ex. 'v_setscene scenes/streetwar/sniper/ba_nag_grenade03.vcd'");
		PrintToConsole(client, "Scenes can be found in SteamApps/half life 2 content.gcf");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl scEnt;
	decl String:scenePath[256];
	decl String:scClassname[256];
	char scname[2][128] = {
		"setexpressionoverride",
		"Ex. 'v_relationship hate' would make the NPC attack you."
	};
	GetCmdArg(1, scenePath, 255);
	scEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, scEnt) != -1)
	{
		GetEdictClassname(scEnt, scClassname, 255);
		if (StrContains(scClassname, g_sNPCPrefix, false))
		{
			if (StrContains(scClassname, g_sNPCPrefix, false))
			{
				cmMsg(client, "This can only be done to g_sNPCPrefix.");
				return Action:3;
			}
		}
		SetVariantEntity(scEnt);
		SetVariantString(scenePath);
		AcceptEntityInput(scEnt, "setexpressionoverride", -1, -1, 0);
		ExplodeString(scClassname, "_", scname, 2, 128);
		changeBeam(client, scEnt);
		if (!g_iBlockPluginMsgs[client])
		{
			Format(g_sTempString, 255, "Set the scene of %s.", scname[1]);
			cmMsg(client, g_sTempString);
		}
		return Action:3;
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:Command_relationship(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_relationship <NPC's orientation>");
		PrintToConsole(client, "Ex. 'v_relationship hate' would make the NPC attack you.");
		PrintToConsole(client, "Orientations include hate, like, neutral, and fear.");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl rEnt;
	decl String:rType[256];
	decl String:rClassname[256];
	decl String:rorient[12];
	char rname[2][128] = {
		"generic_actor",
		"setrelationship"
	};
	GetCmdArg(1, rType, 255);
	rEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, rEnt) != -1)
	{
		GetEdictClassname(rEnt, rClassname, 255);
		int var1;
		if (StrContains(rClassname, g_sNPCPrefix, false) && StrEqual(rClassname, "generic_actor", false))
		{
			SetVariantEntity(rEnt);
			if (StrEqual(rType, "hate", false))
			{
				SetVariantString("g_sPlayerClassname d_ht");
				rorient = "hate";
			}
			if (StrEqual(rType, "like", false))
			{
				SetVariantString("g_sPlayerClassname d_li");
				rorient = "like";
			}
			if (StrEqual(rType, "neutral", false))
			{
				SetVariantString("g_sPlayerClassname d_nu");
				rorient = "neutral";
			}
			if (StrEqual(rType, "fear", false))
			{
				SetVariantString("g_sPlayerClassname d_fr");
				rorient = "fear";
			}
			AcceptEntityInput(rEnt, "setrelationship", -1, -1, 0);
			changeBeam(client, rEnt);
			ExplodeString(rClassname, "_", rname, 2, 128);
			if (g_iBlockPluginMsgs[client])
			{
			}
			else
			{
				Format(g_sTempString, 255, "Set the relationship of %s to %s.", rname[1], rorient);
				cmMsg(client, g_sTempString);
			}
		}
		cmMsg(client, "This can only be done to g_sNPCPrefix.");
		return Action:3;
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:Command_airboatgun(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_gun <on or off>");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl aEnt;
	decl String:aInput[256];
	decl String:aClassname[256];
	GetCmdArg(1, aInput, 255);
	aEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, aEnt) != -1)
	{
		GetEdictClassname(aEnt, aClassname, 255);
		SetVariantEntity(aEnt);
		int var1;
		if (StrEqual(aClassname, "prop_vehicle_airboat", false) || StrEqual(aClassname, "prop_vehicle_jeep", false))
		{
			if (StrEqual(aInput, "on", false))
			{
				SetVariantInt(1);
				if (g_iBlockPluginMsgs[client])
				{
				}
				else
				{
					cmMsg(client, "Gun on airboat enabled.");
				}
			}
			else
			{
				if (StrEqual(aInput, "off", false))
				{
					SetVariantInt(0);
					if (g_iBlockPluginMsgs[client])
					{
					}
					else
					{
						cmMsg(client, "Gun on airboat disabled.");
					}
				}
				cmMsg(client, "Invalid input specified. Use 'on' or 'off'.");
			}
			AcceptEntityInput(aEnt, "enablegun", -1, -1, 0);
			changeBeam(client, aEnt);
			return Action:3;
		}
		cmMsg(client, "This can only be done to airboats.");
		return Action:3;
	}
	notYours(client);
	return Action:3;
}

public Action:Command_ignite(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_ignite <number of seconds>");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl bEnt;
	decl String:bSeconds[256];
	decl String:bClassname[256];
	char brokeClass[2][32] = {
		"This entity cannot be ignited.",
		"m_iName"
	};
	bEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, bEnt) != -1)
	{
		GetEdictClassname(bEnt, bClassname, 255);
		GetCmdArg(1, bSeconds, 255);
		int var1;
		if (StringToInt(bSeconds, 10) > 0 && StringToInt(bSeconds, 10) < 301)
		{
			if (StrEqual(bClassname, g_sPlayerClassname, false))
			{
				cmMsg(client, "This entity cannot be ignited.");
				return Action:3;
			}
			if (StrContains(bClassname, g_sNPCPrefix, false))
			{
				decl String:targetname[128];
				GetEntPropString(bEnt, PropType:1, "m_iName", targetname, 128);
				DispatchKeyValue(bEnt, "targetname", "ignited");
				DispatchKeyValue(g_iEntityIgniter, "lifetime", bSeconds);
				AcceptEntityInput(g_iEntityIgniter, "ignite", -1, -1, 0);
				DispatchKeyValue(bEnt, "targetname", targetname);
			}
			else
			{
				IgniteEntity(bEnt, StringToFloat(bSeconds), false, 0.0, false);
			}
			changeBeam(client, bEnt);
			if (!g_iBlockPluginMsgs[client])
			{
				ExplodeString(bClassname, "_", brokeClass, 2, 32);
				if (StrEqual(brokeClass[0][brokeClass], "combine", false))
				{
					Format(g_sTempString, 255, "Ignited %s %s for %s seconds.", brokeClass[0][brokeClass], brokeClass[1], bSeconds);
					cmMsg(client, g_sTempString);
				}
				Format(g_sTempString, 255, "Ignited %s %s for %s seconds.", brokeClass[1], brokeClass[0][brokeClass], bSeconds);
				cmMsg(client, g_sTempString);
			}
			return Action:3;
		}
		cmMsg(client, "Invalid ignite time. Min = 1, Max = 300.");
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:Command_jeep(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_jeep <on or off>");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl jEnt;
	decl String:jClassname[256];
	decl String:jInput[256];
	jEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, jEnt) != -1)
	{
		GetCmdArg(1, jInput, 255);
		int var1;
		if (!StrEqual(jInput, "on", false) && !StrEqual(jInput, "off", false))
		{
			cmMsg(client, "Invalid input specified. Use 'on' or 'off'.");
			return Action:3;
		}
		GetEdictClassname(jEnt, jClassname, 255);
		if (StrEqual(jClassname, "prop_vehicle_airboat", false))
		{
			if (StrEqual(jInput, "on", false))
			{
				if (!g_iBlockPluginMsgs[client])
				{
					cmMsg(client, "Turned airboat into a jeep.");
				}
				SetEntityModel(jEnt, "models/buggy.mdl");
				DispatchKeyValue(jEnt, "vehiclescript", "scripts/vehicles/jeep_test.txt");
				DispatchKeyValue(jEnt, "classname", "prop_vehicle_jeep");
				changeBeam(client, jEnt);
			}
			else
			{
				if (StrEqual(jInput, "off", false))
				{
					cmMsg(client, "This can only be done to jeeps.");
				}
			}
		}
		else
		{
			if (StrEqual(jClassname, "prop_vehicle_jeep", false))
			{
				if (StrEqual(jInput, "off", false))
				{
					if (!g_iBlockPluginMsgs[client])
					{
						cmMsg(client, "Turned jeep back into an airboat.");
					}
					SetEntityModel(jEnt, "models/airboat.mdl");
					DispatchKeyValue(jEnt, "vehiclescript", "scripts/vehicles/airboat.txt");
					DispatchKeyValue(jEnt, "classname", "prop_vehicle_airboat");
					changeBeam(client, jEnt);
				}
				else
				{
					if (StrEqual(jInput, "on", false))
					{
						cmMsg(client, "This can only be done to airboats.");
					}
				}
			}
			cmMsg(client, "Cannot target this entity.");
		}
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:Command_god(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_god <on or off>");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl gEnt;
	decl String:gClassname[256];
	decl String:gInput[256];
	gEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, gEnt) != -1)
	{
		GetCmdArg(1, gInput, 255);
		GetEdictClassname(gEnt, gClassname, 255);
		int var1;
		if (!StrEqual(gClassname, g_sPlayerClassname, false) && StrContains(gClassname, "func", false) == -1)
		{
			if (StrEqual(gInput, "on", false))
			{
				int var2;
				if (GetEntProp(gEnt, PropType:1, "m_takedamage", 4) == 2 || StrEqual(gClassname, "prop_physics_breakable", false))
				{
					SetEntProp(gEnt, PropType:1, "m_takedamage", any:0, 1);
					if (StrEqual(gClassname, "prop_physics", false))
					{
						DispatchKeyValue(gEnt, "classname", "prop_physics_breakable");
					}
					if (StrEqual(gClassname, "prop_physics_multig_sPlayerClassname", false))
					{
						DispatchKeyValue(gEnt, "classname", "prop_physics_m_breakable");
					}
				}
				changeBeam(client, gEnt);
				if (!g_iBlockPluginMsgs[client])
				{
					PerformByClass(client, gEnt, "Turned invincibility on");
				}
				return Action:3;
			}
			if (StrEqual(gInput, "off", false))
			{
				if (StrEqual(gClassname, "prop_physics_breakable", false))
				{
					SetEntProp(gEnt, PropType:1, "m_takedamage", any:2, 1);
					DispatchKeyValue(gEnt, "classname", "prop_physics_multig_sPlayerClassname");
				}
				changeBeam(client, gEnt);
				if (!g_iBlockPluginMsgs[client])
				{
					PerformByClass(client, gEnt, "Turned invincibility off");
				}
				return Action:3;
			}
			int var3;
			if (!StrEqual(gInput, "on", false) && !StrEqual(gInput, "off", false))
			{
				cmMsg(client, "Invalid input specified. Use 'on' or 'off'.");
				return Action:3;
			}
		}
		else
		{
			cmMsg(client, "You cannot target this entity.");
		}
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:Command_color(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_color <red value> <green value> <blue value>");
		PrintToConsole(client, "Ex. 'v_color 255 128 0' would turn the entity orange.");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl cEnt;
	decl String:sRed[8];
	decl String:sGrn[8];
	decl String:sBlu[8];
	decl String:cClass[32];
	cEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, cEnt) != -1)
	{
		GetEdictClassname(cEnt, cClass, 32);
		GetCmdArg(1, sRed, 6);
		GetCmdArg(2, sGrn, 6);
		GetCmdArg(3, sBlu, 6);
		if (StrEqual(cClass, g_sPlayerClassname, false))
		{
			cmMsg(client, "Unable to color this entity.");
			return Action:3;
		}
		decl amt;
		int cOff = GetEntSendPropOffs(cEnt, "m_clrRender", false);
		amt = GetEntData(cEnt, cOff + 3, 1);
		if (StrEqual(cClass, "cel_light", false))
		{
			int moveChild = GetEntPropEnt(cEnt, PropType:1, "m_hMoveChild");
			SetEntityRenderColor(moveChild, StringToInt(sRed, 10), StringToInt(sGrn, 10), StringToInt(sBlu, 10), 255);
		}
		SetEntityRenderColor(cEnt, StringToInt(sRed, 10), StringToInt(sGrn, 10), StringToInt(sBlu, 10), amt);
		changeBeam(client, cEnt);
		if (g_iBlockPluginMsgs[client])
		{
		}
		else
		{
			if (StrEqual(cClass, "cel_light", false))
			{
				int moveChild = GetEntPropEnt(cEnt, PropType:1, "m_hMoveChild");
				decl String:lightName[32];
				char cg_iLightCount[2][32] = {
					"m_iName",
					"ht %s."
				};
				GetEntPropString(moveChild, PropType:1, "m_iName", lightName, 32);
				ExplodeString(lightName, "_", cg_iLightCount, 2, 32);
				Format(g_sTempString, 255, "Applied color to light %s.", cg_iLightCount[1]);
				cmMsg(client, g_sTempString);
			}
			int moveChild = 10193444;
			PerformByClass(client, cEnt, moveChild);
		}
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:Command_mark(client, args)
{
	decl Float:mclientOrigin[3];
	decl Float:mclientX[3];
	decl Float:mclientY[3];
	decl Float:mclientZ[3];
	GetClientAbsOrigin(client, mclientOrigin);
	GetClientAbsOrigin(client, mclientX);
	GetClientAbsOrigin(client, mclientY);
	GetClientAbsOrigin(client, mclientZ);
	mclientX[0] = mclientX[0] + 50;
	mclientY[1] += 50;
	mclientZ[2] += 50;
	TE_SetupBeamPoints(mclientOrigin, mclientX, g_iBeam, g_iHalo, 0, 15, 60.0, 3.0, 3.0, 1, 0.0, redColor, 10);
	TE_SendToClient(client, 0.0);
	TE_SetupBeamPoints(mclientOrigin, mclientY, g_iBeam, g_iHalo, 0, 15, 60.0, 3.0, 3.0, 1, 0.0, g_iGreenColor, 10);
	TE_SendToClient(client, 0.0);
	TE_SetupBeamPoints(mclientOrigin, mclientZ, g_iBeam, g_iHalo, 0, 15, 60.0, 3.0, 3.0, 1, 0.0, blueColor, 10);
	TE_SendToClient(client, 0.0);
	Format(g_sTempString, 255, "Created red X, green Y, and blue Z marker.");
	cmMsg(client, g_sTempString);
	return Action:3;
}

public Action:Command_whoowns(client, args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl vEnt;
	decl EntOut;
	decl String:whos[64];
	decl String:clientname[32];
	vEnt = GetClientAimTarget(client, false);
	GetEntPropString(vEnt, PropType:1, "m_iGlobalname", whos, 64);
	if (StrEqual(whos, "-2", false))
	{
		cmMsg(client, "This entity belongs to the map.");
		return Action:3;
	}
	EntOut = StringToInt(whos, 10);
	GetClientName(EntOut, clientname, 32);
	int var1;
	if (EntOut && IsClientInGame(client) && IsClientConnected(client))
	{
		Format(g_sTempString, 255, "g_sPlayerClassname \x04%s\x01 owns this entity.", clientname);
		cmMsg(client, g_sTempString);
	}
	else
	{
		int var2;
		if (!StrEqual(whos, "", false) && StrContains(whos, "STEAM", true))
		{
			char ownerName[2][32] = {
				"*",
				"(\x01%s\x04)\x01."
			};
			ExplodeString(whos, "*", ownerName, 2, 32);
			Format(g_sTempString, 255, "This entity was owned by %s\x04(\x01%s\x04)\x01.", ownerName[1], ownerName[0][ownerName]);
			cmMsg(client, g_sTempString);
		}
		cmMsg(client, "Nobody owns this entity.");
	}
	return Action:3;
}

public Action:Command_startMove(client, args)
{
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		g_iGrabEntity[client] = -1;
		return Action:3;
	}
	if (g_hEntityGrab[client])
	{
		cmMsg(client, "You are already moving something.");
	}
	else
	{
		int moveEnt = GetClientAimTarget(client, false);
		if (FindOwner(client, moveEnt) != -1)
		{
			decl String:moveClass[32];
			GetEdictClassname(moveEnt, moveClass, 32);
			int var1;
			if (StrEqual(moveClass, g_sPlayerClassname, false) || !StrContains(moveClass, "func", false))
			{
				cmMsg(client, "You cannot move this entity.");
				return Action:3;
			}
			decl Float:clientOrgn[3];
			decl Float:entOrgn[3];
			GetClientAbsOrigin(client, clientOrgn);
			GetEntPropVector(moveEnt, PropType:1, "m_vecAbsOrigin", entOrgn);
			g_iGrabEntity[client] = moveEnt;
			int colorOff = GetEntSendPropOffs(moveEnt, "m_clrRender", false);
			g_iGrabColor[client][0] = GetEntData(moveEnt, colorOff, 1);
			g_iGrabColor[client][1] = GetEntData(moveEnt, colorOff + 1, 1);
			g_iGrabColor[client][2] = GetEntData(moveEnt, colorOff + 2, 1);
			g_iGrabColor[client][3] = GetEntData(moveEnt, colorOff + 3, 1);
			SetEntProp(moveEnt, PropType:0, "m_nRenderMode", any:1, 1);
			SetEntityRenderColor(moveEnt, 128, 255, 0, 128);
			g_iGrabEntityM[client] = GetEntityMoveType(moveEnt);
			SetEntityMoveType(moveEnt, MoveType:0);
			grabDist[client][0] = clientOrgn[0] - entOrgn[0];
			grabDist[client][1] = clientOrgn[1] - entOrgn[1];
			grabDist[client][2] = clientOrgn[2] - entOrgn[2];
			g_hEntityGrab[client] = CreateTimer(0.1, startGrab, client, 1);
		}
		else
		{
			notYours(client);
		}
	}
	return Action:3;
}

public Action:startGrab(Handle:timer, any:client)
{
	if (IsValidEdict(g_iGrabEntity[client]))
	{
		decl Float:cOrgn[3];
		decl Float:eOrgn[3];
		GetClientAbsOrigin(client, cOrgn);
		eOrgn[0] = cOrgn[0] - grabDist[client][0];
		eOrgn[1] = cOrgn[1] - grabDist[client][1];
		eOrgn[2] = cOrgn[2] - grabDist[client][2];
		TeleportEntity(g_iGrabEntity[client], eOrgn, NULL_VECTOR, g_fEntityAngles);
	}
	else
	{
		g_iGrabEntity[client] = -1;
		KillTimer(g_hEntityGrab[client], false);
		g_hEntityGrab[client] = 0;
	}
	return Action:0;
}

public Action:Command_stopMove(client, args)
{
	int var1;
	if (g_hEntityGrab[client] && IsValidEdict(g_iGrabEntity[client]))
	{
		SetEntityRenderColor(g_iGrabEntity[client], g_iGrabColor[client][0], g_iGrabColor[client][1], g_iGrabColor[client][2], g_iGrabColor[client][3]);
		SetEntityMoveType(g_iGrabEntity[client], g_iGrabEntityM[client]);
		KillTimer(g_hEntityGrab[client], false);
		g_hEntityGrab[client] = 0;
	}
	return Action:3;
}

public Action:Command_ladder(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_ladder <1 or 2>");
		return Action:3;
	}
	if (GetConVarInt(g_cvMaxPropsClient) > CountProps(client))
	{
		decl String:ladderNum[16];
		GetCmdArg(1, ladderNum, 16);
		decl ladderEnt;
		int ladderProp = CreateEntityByName("prop_physics_multig_sPlayerClassname", -1);
		if (StrEqual(ladderNum, "2", false))
		{
			DispatchKeyValue(ladderProp, "model", "models/props_c17/metalladder002.mdl");
		}
		else
		{
			DispatchKeyValue(ladderProp, "model", "models/props_c17/metalladder001.mdl");
		}
		DispatchKeyValue(ladderProp, "physdamagescale", "0.0");
		DispatchKeyValue(ladderProp, "targetname", "tempprop");
		DispatchKeyValue(ladderProp, "spawnflags", "8");
		DispatchSpawn(ladderProp);
		ladderEnt = CreateEntityByName("func_useableladder", -1);
		DispatchKeyValue(ladderEnt, "point0", "30 0 0");
		DispatchKeyValue(ladderEnt, "point1", "30 0 128");
		DispatchKeyValue(ladderEnt, "StartDisabled", "0");
		DispatchSpawn(ladderEnt);
		SetVariantString("tempprop");
		AcceptEntityInput(ladderEnt, "setparent", -1, -1, 0);
		DispatchKeyValue(ladderProp, "targetname", "isLadder");
		DispatchKeyValue(ladderProp, "classname", "prop_ladder");
		decl Float:COrigin[3];
		decl Float:CAng[3];
		decl Float:LOrigin[3];
		decl Float:EAng[3];
		GetClientAbsOrigin(client, COrigin);
		GetClientEyeAngles(client, EAng);
		GetClientAbsAngles(client, CAng);
		LOrigin[0] = COrigin[0] + Cosine(DegToRad(EAng[1])) * 50;
		LOrigin[1] = COrigin[1] + Sine(DegToRad(EAng[1])) * 50;
		LOrigin[2] = COrigin[2];
		CAng[1] += 180.0;
		TeleportEntity(ladderProp, LOrigin, CAng, NULL_VECTOR);
		SetOwner(client, ladderProp);
		if (g_iBlockPluginMsgs[client])
		{
		}
		else
		{
			cmMsg(client, "Created ladder.");
		}
	}
	else
	{
		Format(g_sTempString, 255, "You've reached your max prop count(%d).", GetConVarInt(g_cvMaxPropsClient));
		cmMsg(client, g_sTempString);
	}
	return Action:3;
}

public Action:Command_solidity(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_solid <on or off>");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl sEnt;
	decl String:sClassname[256];
	decl String:sInput[256];
	sEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, sEnt) != -1)
	{
		GetCmdArg(1, sInput, 255);
		GetEdictClassname(sEnt, sClassname, 255);
		int var1;
		if (!StrEqual(sClassname, g_sPlayerClassname, false) && StrContains(sClassname, "func_", false) == -1)
		{
			if (StrEqual(sInput, "on", false))
			{
				DispatchKeyValue(sEnt, "solid", "6");
				changeBeam(client, sEnt);
				if (!g_iBlockPluginMsgs[client])
				{
					PerformByClass(client, sEnt, "Turned solidity on");
				}
				return Action:3;
			}
			if (StrEqual(sInput, "off", false))
			{
				DispatchKeyValue(sEnt, "solid", "4");
				changeBeam(client, sEnt);
				if (!g_iBlockPluginMsgs[client])
				{
					PerformByClass(client, sEnt, "Turned solidity off");
				}
				return Action:3;
			}
			int var2;
			if (!StrEqual(sInput, "on", false) && !StrEqual(sInput, "off", false))
			{
				cmMsg(client, "Invalid input specified. Use 'on' or 'off'.");
				return Action:3;
			}
		}
		else
		{
			cmMsg(client, "You cannot target this entity.");
		}
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:Command_sound(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_sound <sound alias>");
		PrintToConsole(client, "Type 'v_soundlist' or say 'celsounds' for a list of sound aliases.");
		return Action:3;
	}
	if (GetConVarInt(g_cvMaxCelsClient) > CountCels(client))
	{
		if (g_fSoundUseDelay[client] <= GetGameTime() - 1)
		{
			decl String:soundAlias[256];
			GetCmdArg(1, soundAlias, 255);
			decl Handle:Sounds;
			decl String:SoundString[256];
			Sounds = CreateKeyValues("Sounds", "", "");
			FileToKeyValues(Sounds, g_sSoundsPath);
			LoadString(Sounds, "Sounds", soundAlias, "Null", SoundString);
			if (!StrContains(SoundString, "Null", false))
			{
				cmMsg(client, "Sound not found.");
				return Action:3;
			}
			PrecacheSound(SoundString, false);
			int soundPropEnt = CreateEntityByName("prop_physics", -1);
			DispatchKeyValue(soundPropEnt, "model", "models/props_junk/popcan01a.mdl");
			DispatchKeyValue(soundPropEnt, "skin", "1");
			DispatchKeyValue(soundPropEnt, "rendercolor", "255 200 0");
			DispatchKeyValue(soundPropEnt, "spawnflags", "264");
			DispatchSpawn(soundPropEnt);
			DispatchKeyValue(soundPropEnt, "classname", "cel_sound");
			HookSingleEntityOutput(soundPropEnt, "Ong_sPlayerClassnameUse", useSound, false);
			g_fSoundLengthEnt[soundPropEnt] = 0;
			decl Float:SoundOrigin[3];
			decl Float:COrigin[3];
			decl Float:CEyeAngles[3];
			GetClientEyeAngles(client, CEyeAngles);
			GetClientAbsOrigin(client, COrigin);
			SoundOrigin[0] = COrigin[0] + Cosine(DegToRad(CEyeAngles[1])) * 50;
			SoundOrigin[1] = COrigin[1] + Sine(DegToRad(CEyeAngles[1])) * 50;
			SoundOrigin[2] = COrigin[2] + 32;
			TeleportEntity(soundPropEnt, SoundOrigin, NULL_VECTOR, NULL_VECTOR);
			SetOwner(client, soundPropEnt);
			g_fSoundUseDelay[client] = GetGameTime();
			CloseHandle(Sounds);
		}
		else
		{
			tooFast(client);
			int var1 = g_fSoundUseDelay[client];
			var1 = var1[1];
		}
	}
	else
	{
		Format(g_sTempString, 255, "You've reached your max cel count(%d).", GetConVarInt(g_cvMaxCelsClient));
		cmMsg(client, g_sTempString);
	}
	return Action:3;
}

public Action:Command_music(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_music <music alias> <volume level>");
		PrintToConsole(client, "Minimum = 50; Maximum = 100; Default = 75");
		PrintToConsole(client, "Type 'v_musiclist' or say 'celmusic' for a list of music aliases.");
		return Action:3;
	}
	if (GetConVarInt(g_cvMaxCelsClient) > CountCels(client))
	{
		if (g_fSoundUseDelay[client] <= GetGameTime() - 1)
		{
			decl String:musicAlias[256];
			decl String:musicVol[16];
			decl String:loop[16];
			GetCmdArg(1, musicAlias, 255);
			GetCmdArg(2, musicVol, 16);
			GetCmdArg(3, loop, 16);
			decl Handle:Sounds;
			decl String:musicString[256];
			Sounds = CreateKeyValues("Sounds", "", "");
			FileToKeyValues(Sounds, g_sSoundsPath);
			LoadString(Sounds, "Music", musicAlias, "Null", musicString);
			if (!StrContains(musicString, "Null", false))
			{
				cmMsg(client, "Music track not found.");
				return Action:3;
			}
			if (StringToInt(musicVol, 10) < 50)
			{
				musicVol = "75";
			}
			else
			{
				if (StringToInt(musicVol, 10) > 100)
				{
					musicVol = "100";
				}
			}
			char breakString[2][128] = {
				"\x08",
				"gs"
			};
			char mBreak[2][128] = {
				"\x10",
				"classname"
			};
			decl String:mSimplified[256];
			char mFinal[4][128] = {
				"|",
				"music",
				"rRender",
				"_m_breakable"
			};
			decl Seconds;
			ExplodeString(musicString, "|", breakString, 2, 128);
			ExplodeString(breakString[1], ":", mBreak, 2, 128);
			Seconds = StringToInt(mBreak[0][mBreak], 10) * 60;
			Seconds = StringToInt(mBreak[1], 10) + Seconds;
			IntToString(Seconds, mFinal[1], 128);
			ImplodeStrings(mFinal, 4, "|", mSimplified, 255);
			PrecacheSound(breakString[0][breakString], false);
			int musicPropEnt = CreateEntityByName("prop_physics", -1);
			DispatchKeyValue(musicPropEnt, "model", "models/props_lab/citizenradio.mdl");
			DispatchKeyValue(musicPropEnt, "rendercolor", "128 255 0");
			DispatchKeyValue(musicPropEnt, "spawnflags", "264");
			DispatchSpawn(musicPropEnt);
			DispatchKeyValue(musicPropEnt, "classname", "cel_music");
			HookSingleEntityOutput(musicPropEnt, "Ong_sPlayerClassnameUse", useMusic, false);
			g_fMusicLength[musicPropEnt] = 0;
			decl Float:MOrigin[3];
			decl Float:COrigin[3];
			decl Float:CEyeAngles[3];
			GetClientEyeAngles(client, CEyeAngles);
			GetClientAbsOrigin(client, COrigin);
			MOrigin[0] = COrigin[0] + Cosine(DegToRad(CEyeAngles[1])) * 50;
			MOrigin[1] = COrigin[1] + Sine(DegToRad(CEyeAngles[1])) * 50;
			MOrigin[2] = COrigin[2] + 32;
			TeleportEntity(musicPropEnt, MOrigin, NULL_VECTOR, NULL_VECTOR);
			SetOwner(client, musicPropEnt);
			g_fSoundUseDelay[client] = GetGameTime();
			CloseHandle(Sounds);
		}
		else
		{
			tooFast(client);
			int var1 = g_fSoundUseDelay[client];
			var1 = var1[1];
		}
	}
	else
	{
		Format(g_sTempString, 255, "You've reached your max cel count(%d).", GetConVarInt(g_cvMaxCelsClient));
		cmMsg(client, g_sTempString);
	}
	return Action:3;
}

public Action:Command_startCopy(client, Args)
{
	if (g_hEntityCopy[client])
	{
		cmMsg(client, "You are already copying something.");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl cpEnt;
	decl String:g_sCopyClassname[32];
	cpEnt = GetClientAimTarget(client, false);
	GetEdictClassname(cpEnt, g_sCopyClassname, 32);
	if (!StrContains(g_sCopyClassname, "prop_physics", false))
	{
		decl String:modelName[128];
		decl renderFx;
		decl Float:angRot[3];
		decl Float:entOrgn[3];
		decl skinNum;
		decl entFlags;
		GetEntPropString(cpEnt, PropType:1, "m_ModelName", modelName, 128);
		int coloroffset = GetEntSendPropOffs(cpEnt, "m_clrRender", false);
		g_iCmdCopyColor[client][0] = GetEntData(cpEnt, coloroffset, 1);
		g_iCmdCopyColor[client][1] = GetEntData(cpEnt, coloroffset + 1, 1);
		g_iCmdCopyColor[client][2] = GetEntData(cpEnt, coloroffset + 2, 1);
		g_iCmdCopyColor[client][3] = GetEntData(cpEnt, coloroffset + 3, 1);
		renderFx = GetEntProp(cpEnt, PropType:0, "m_nRenderFX", 1);
		GetEntPropVector(cpEnt, PropType:1, "m_vecAbsOrigin", entOrgn);
		GetEntPropVector(cpEnt, PropType:1, "m_angRotation", angRot);
		skinNum = GetEntProp(cpEnt, PropType:1, "m_nSkin", 1);
		entFlags = GetEntProp(cpEnt, PropType:1, "m_spawnflags", 1);
		g_iCopyMoveType[client] = GetEntityMoveType(cpEnt);
		if (GetEntityMoveType(cpEnt))
		{
			g_bCopyFrozen[client] = 0;
		}
		else
		{
			g_bCopyFrozen[client] = 1;
		}
		decl String:SrenderFx[32];
		decl String:SskinNum[32];
		decl String:SentFlags[32];
		IntToString(renderFx, SrenderFx, 32);
		IntToString(skinNum, SskinNum, 32);
		IntToString(entFlags, SentFlags, 32);
		decl newEnt;
		if (StrEqual(g_sCopyClassname, "prop_physics_breakable", false))
		{
			newEnt = CreateEntityByName("prop_physics", -1);
		}
		else
		{
			if (StrEqual(g_sCopyClassname, "prop_physics_m_breakable", false))
			{
				newEnt = CreateEntityByName("prop_physics_multig_sPlayerClassname", -1);
			}
			newEnt = CreateEntityByName(g_sCopyClassname, -1);
		}
		if (GetConVarInt(g_cvMaxPropsClient) <= CountProps(client))
		{
			Format(g_sTempString, 255, "You've reached your max prop count(%d).", GetConVarInt(g_cvMaxPropsClient));
			cmMsg(client, g_sTempString);
			AcceptEntityInput(newEnt, "Kill", -1, -1, 0);
			return Action:3;
		}
		DispatchKeyValue(newEnt, "model", modelName);
		DispatchKeyValue(newEnt, "skin", SskinNum);
		DispatchKeyValue(newEnt, "renderfx", SrenderFx);
		DispatchKeyValue(newEnt, "rendermode", "1");
		DispatchKeyValue(newEnt, "spawnflags", SentFlags);
		if (!DispatchSpawn(newEnt))
		{
			if (StrEqual(g_sCopyClassname, "prop_physics", false))
			{
				newEnt = CreateEntityByName("prop_physics_override", -1);
				DispatchKeyValue(newEnt, "model", modelName);
				DispatchKeyValue(newEnt, "skin", SskinNum);
				DispatchKeyValue(newEnt, "renderfx", SrenderFx);
				DispatchKeyValue(newEnt, "rendermode", "1");
				DispatchKeyValue(newEnt, "spawnflags", SentFlags);
			}
			cmMsg(client, "Error pasting prop.");
			return Action:3;
		}
		DispatchSpawn(newEnt);
		if (GetEntProp(newEnt, PropType:1, "m_takedamage", 4) == 2)
		{
			if (GetConVarInt(g_cvMaxBreakablesClient) <= CountBreakables(client))
			{
				Format(g_sTempString, 255, "You've reached your max breakable prop count(%d).", GetConVarInt(g_cvMaxBreakablesClient));
				cmMsg(client, g_sTempString);
				AcceptEntityInput(newEnt, "Kill", -1, -1, 0);
				return Action:3;
			}
			if (StrEqual(g_sCopyClassname, "prop_physics", false))
			{
				DispatchKeyValue(newEnt, "classname", "prop_physics_breakable");
			}
			DispatchKeyValue(newEnt, "classname", "prop_physics_m_breakable");
		}
		SetEntityMoveType(newEnt, MoveType:0);
		AcceptEntityInput(newEnt, "disablemotion", -1, -1, 0);
		SetEntityRenderColor(newEnt, 40, 40, 255, 128);
		TeleportEntity(newEnt, entOrgn, angRot, g_fEntityAngles);
		decl Float:COrigin[3];
		GetClientAbsOrigin(client, COrigin);
		g_fCopyDistance[client][0] = COrigin[0] - entOrgn[0];
		g_fCopyDistance[client][1] = COrigin[1] - entOrgn[1];
		g_fCopyDistance[client][2] = COrigin[2] - entOrgn[2];
		SetOwner(client, newEnt);
		g_iCmdCopyEntity[client] = newEnt;
		g_hEntityCopy[client] = CreateTimer(0.1, copyAction, client, 1);
	}
	else
	{
		cmMsg(client, "You cannot copy this entity.");
	}
	return Action:3;
}

public Action:copyAction(Handle:timer, any:client)
{
	if (IsValidEdict(g_iCmdCopyEntity[client]))
	{
		decl Float:cOrgn[3];
		decl Float:eOrgn[3];
		GetClientAbsOrigin(client, cOrgn);
		eOrgn[0] = cOrgn[0] - g_fCopyDistance[client][0];
		eOrgn[1] = cOrgn[1] - g_fCopyDistance[client][1];
		eOrgn[2] = cOrgn[2] - g_fCopyDistance[client][2];
		TeleportEntity(g_iCmdCopyEntity[client], eOrgn, NULL_VECTOR, g_fEntityAngles);
	}
	else
	{
		g_iCmdCopyEntity[client] = -1;
		KillTimer(g_hEntityCopy[client], false);
		g_hEntityCopy[client] = 0;
	}
	return Action:0;
}

public Action:Command_stopCopy(client, args)
{
	int var1;
	if (g_hEntityCopy[client] && IsValidEdict(g_iCmdCopyEntity[client]))
	{
		if (!g_bCopyFrozen[client])
		{
			SetEntityMoveType(g_iCmdCopyEntity[client], g_iCopyMoveType[client]);
			AcceptEntityInput(g_iCmdCopyEntity[client], "EnableMotion", -1, -1, 0);
		}
		SetEntityRenderColor(g_iCmdCopyEntity[client], g_iCmdCopyColor[client][0], g_iCmdCopyColor[client][1], g_iCmdCopyColor[client][2], g_iCmdCopyColor[client][3]);
		KillTimer(g_hEntityCopy[client], false);
		g_hEntityCopy[client] = 0;
	}
	return Action:3;
}

public Action:Command_alpha(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_amt <transparency>");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	int amtEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, amtEnt) != -1)
	{
		decl String:amtClass[32];
		GetEdictClassname(amtEnt, amtClass, 32);
		if (!StrEqual(amtClass, "g_sPlayerClassname", false))
		{
			decl String:amt[32];
			decl red;
			decl green;
			decl blue;
			GetCmdArg(1, amt, 32);
			SetEntProp(amtEnt, PropType:1, "m_nRenderMode", any:1, 1);
			int coloroffset = GetEntSendPropOffs(amtEnt, "m_clrRender", false);
			red = GetEntData(amtEnt, coloroffset, 1);
			green = GetEntData(amtEnt, coloroffset + 1, 1);
			blue = GetEntData(amtEnt, coloroffset + 2, 1);
			decl amtNum;
			int var1;
			if (StringToInt(amt, 10) < 50 || StringToInt(amt, 10) > 255)
			{
				amtNum = 255;
			}
			else
			{
				amtNum = StringToInt(amt, 10);
			}
			SetEntityRenderColor(amtEnt, red, green, blue, amtNum);
			changeBeam(client, amtEnt);
			Format(g_sTempString, 255, "Set alpha transparency to %d.", amtNum);
			cmMsg(client, g_sTempString);
		}
		else
		{
			cmMsg(client, "Cannot target this entity");
		}
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:Command_rotate(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_rotate <x> <y> <z> <set?>");
		PrintToConsole(client, " - Typing 'set' after the rotation will set the angles instead of adding to it.");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	int rotEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, rotEnt) != -1)
	{
		decl String:rotClass[32];
		GetEdictClassname(rotEnt, rotClass, 32);
		int var1;
		if (!StrEqual(rotClass, "g_sPlayerClassname", false) && StrContains(rotClass, "func", false) == -1)
		{
			decl String:rotX[16];
			decl String:rotY[16];
			decl String:rotZ[16];
			char rotSet[16] = "";
			GetCmdArg(1, rotX, 16);
			GetCmdArg(2, rotY, 16);
			GetCmdArg(3, rotZ, 16);
			if (args > 3)
			{
				GetCmdArg(4, rotSet, 16);
			}
			decl Float:finalAng[3];
			if (StrEqual(rotSet, "set", false))
			{
				finalAng[0] = StringToFloat(rotX);
				finalAng[1] = StringToFloat(rotY);
				finalAng[2] = StringToFloat(rotZ);
			}
			else
			{
				decl Float:rotAng[3];
				GetEntPropVector(rotEnt, PropType:1, "m_angRotation", rotAng);
				finalAng[0] = rotAng[0] + StringToFloat(rotX);
				finalAng[1] = rotAng[1] + StringToFloat(rotY);
				finalAng[2] = rotAng[2] + StringToFloat(rotZ);
			}
			decl String:netClass[32];
			GetEntityNetClass(rotEnt, netClass, 32);
			if (StrEqual(netClass, "CBasePropDoor", false))
			{
				decl String:mName[128];
				decl String:doorhard[16];
				decl String:doorskin[16];
				decl doorColor[4];
				GetEntPropString(rotEnt, PropType:1, "m_ModelName", mName, 128);
				int doorSkin = GetEntProp(rotEnt, PropType:1, "m_nSkin", 4);
				int doorHardware = GetEntProp(rotEnt, PropType:1, "m_nHardwareType", 4);
				int coloroffset = GetEntSendPropOffs(rotEnt, "m_clrRender", false);
				doorColor[0] = GetEntData(rotEnt, coloroffset, 1);
				doorColor[1] = GetEntData(rotEnt, coloroffset + 1, 1);
				doorColor[2] = GetEntData(rotEnt, coloroffset + 2, 1);
				doorColor[3] = GetEntData(rotEnt, coloroffset + 3, 1);
				IntToString(doorSkin, doorskin, 16);
				IntToString(doorHardware, doorhard, 16);
				int dEnt = CreateEntityByName("prop_door_rotating", -1);
				DispatchKeyValue(dEnt, "model", mName);
				DispatchKeyValue(dEnt, "skin", doorskin);
				DispatchKeyValue(dEnt, "distance", "90");
				DispatchKeyValue(dEnt, "speed", "100");
				DispatchKeyValueVector(dEnt, "angles", finalAng);
				DispatchKeyValue(dEnt, "returndelay", "-1");
				DispatchKeyValue(dEnt, "dmg", "20");
				DispatchKeyValue(dEnt, "opendir", "0");
				DispatchKeyValue(dEnt, "hardware", doorhard);
				DispatchKeyValue(dEnt, "spawnflags", "8192");
				DispatchKeyValue(dEnt, "OnFullyOpen", "!caller,close,,3,-1");
				DispatchSpawn(dEnt);
				SetEntProp(dEnt, PropType:1, "m_nRenderMode", any:1, 1);
				SetEntityRenderColor(dEnt, doorColor[0], doorColor[1], doorColor[2], doorColor[3]);
				decl Float:doorOrgn[3];
				GetEntPropVector(rotEnt, PropType:1, "m_vecAbsOrigin", doorOrgn);
				RemoveEdict(rotEnt);
				TeleportEntity(dEnt, doorOrgn, NULL_VECTOR, NULL_VECTOR);
			}
			else
			{
				TeleportEntity(rotEnt, NULL_VECTOR, finalAng, NULL_VECTOR);
			}
		}
		else
		{
			cmMsg(client, "Cannot target this entity");
		}
	}
	else
	{
		notYours(client);
	}
	return Action:3;
}

public Action:Command_giveOwner(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_give <g_sPlayerClassname name>");
		PrintToConsole(client, " - Gives the g_sPlayerClassname the entity you're looking at.");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl String:classname[32];
	int giveEnt = GetClientAimTarget(client, false);
	GetEdictClassname(giveEnt, classname, 32);
	int var1;
	if (StrEqual(classname, g_sPlayerClassname, false) || StrContains(classname, "func_", false) == -1)
	{
		cmMsg(client, "Cannot target this entity.");
		return Action:3;
	}
	decl String:newName[32];
	decl String:nameBuf[32];
	decl Maxg_sPlayerClassnames;
	int newOwner = -1;
	GetCmdArg(1, newName, 32);
	Maxg_sPlayerClassnames = GetMaxClients();
	int C = 1;
	while (C <= Maxg_sPlayerClassnames)
	{
		int var2;
		if (IsClientConnected(C) && IsClientInGame(C))
		{
			GetClientName(C, nameBuf, 32);
			if (StrContains(nameBuf, newName, false) != -1)
			{
				newOwner = C;
			}
		}
		C++;
	}
	if (newOwner != -1)
	{
		SetOwner(newOwner, giveEnt);
		char brokeClass[2][32] = {
			"_",
			"ine"
		};
		decl String:classMsg[256];
		decl String:ownerName[32];
		GetClientName(newOwner, ownerName, 32);
		if (StrContains(classname, "_", false) == -1)
		{
			Format(classMsg, 255, "Gave %s to \x04%s\x01.", classname, ownerName);
		}
		else
		{
			ExplodeString(classname, "_", brokeClass, 2, 32);
			if (StrEqual(brokeClass[0][brokeClass], "combine", false))
			{
				Format(classMsg, 255, "Gave %s %s to \x04%s\x01.", brokeClass[0][brokeClass], brokeClass[1], ownerName);
			}
			Format(classMsg, 255, "Gave %s %s to \x04%s\x01.", brokeClass[1], brokeClass[0][brokeClass], ownerName);
		}
		cmMsg(client, classMsg);
	}
	else
	{
		cmMsg(client, "Unable to find g_sPlayerClassname.");
	}
	return Action:3;
}

public Action:Command_autoStack(client, args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: v_autobuild <amount> <X offset> <Y offset> <Z offset>");
		PrintToConsole(client, "Ex. v_autobuild 10 0 0 50");
		return Action:3;
	}
	if (GetClientAimTarget(client, false) == -1)
	{
		lookingAt(client);
		return Action:3;
	}
	decl String:copyNum[16];
	decl String:xAxis[16];
	decl String:yAxis[16];
	decl String:zAxis[16];
	decl rlAmount;
	decl Float:offsets[3];
	GetCmdArg(1, copyNum, 16);
	GetCmdArg(2, xAxis, 16);
	GetCmdArg(3, yAxis, 16);
	GetCmdArg(4, zAxis, 16);
	rlAmount = StringToInt(copyNum, 10);
	offsets[0] = StringToFloat(xAxis);
	offsets[1] = StringToFloat(yAxis);
	offsets[2] = StringToFloat(zAxis);
	int var1;
	if (rlAmount < 1 || rlAmount > 1000)
	{
		cmMsg(client, "Invalid prop amount specified.");
		return Action:3;
	}
	decl stackEnt;
	decl String:sClass[32];
	stackEnt = GetClientAimTarget(client, false);
	if (FindOwner(client, stackEnt) == -1)
	{
		notYours(client);
		return Action:3;
	}
	GetEdictClassname(stackEnt, sClass, 32);
	if (StrContains(sClass, "prop_physics", false))
	{
		cmMsg(client, "You cannot autobuild this entity.");
	}
	else
	{
		decl String:modelName[128];
		decl renderFx;
		decl Float:angRot[3];
		decl Float:entOrgn[3];
		decl skinNum;
		decl entFlags;
		decl eColor[4];
		decl takedamage;
		GetEntPropString(stackEnt, PropType:1, "m_ModelName", modelName, 128);
		int coloroffset = GetEntSendPropOffs(stackEnt, "m_clrRender", false);
		eColor[0] = GetEntData(stackEnt, coloroffset, 1);
		eColor[1] = GetEntData(stackEnt, coloroffset + 1, 1);
		eColor[2] = GetEntData(stackEnt, coloroffset + 2, 1);
		eColor[3] = GetEntData(stackEnt, coloroffset + 3, 1);
		renderFx = GetEntProp(stackEnt, PropType:0, "m_nRenderFX", 1);
		GetEntPropVector(stackEnt, PropType:1, "m_vecAbsOrigin", entOrgn);
		GetEntPropVector(stackEnt, PropType:1, "m_angRotation", angRot);
		skinNum = GetEntProp(stackEnt, PropType:1, "m_nSkin", 1);
		entFlags = GetEntProp(stackEnt, PropType:1, "m_spawnflags", 1);
		takedamage = GetEntProp(stackEnt, PropType:1, "m_takedamage", 1);
		decl String:SrenderFx[32];
		decl String:SskinNum[32];
		decl String:SentFlags[32];
		IntToString(renderFx, SrenderFx, 32);
		IntToString(skinNum, SskinNum, 32);
		IntToString(entFlags, SentFlags, 32);
		if (GetConVarInt(g_cvMaxPropsClient) <= rlAmount + -1 + CountProps(client))
		{
			Format(g_sTempString, 255, "You've reached your max prop count(%d).", GetConVarInt(g_cvMaxPropsClient));
			cmMsg(client, g_sTempString);
			return Action:3;
		}
		int var2;
		if (GetEntProp(stackEnt, PropType:1, "m_takedamage", 4) == 2 || StrContains(sClass, "breakable", false))
		{
			if (GetConVarInt(g_cvMaxBreakablesClient) <= rlAmount + -1 + CountBreakables(client))
			{
				Format(g_sTempString, 255, "You've reached your max breakable prop count(%d).", GetConVarInt(g_cvMaxBreakablesClient));
				cmMsg(client, g_sTempString);
				return Action:3;
			}
		}
		decl Float:originOffset[3];
		decl bool:firstMade;
		int sAmount;
		firstMade = false;
		int copies = 1;
		while (copies <= 3000)
		{
			if (sAmount >= rlAmount)
			{
				Format(g_sTempString, 255, "Created %d copies of", sAmount);
				PerformByClass(client, stackEnt, g_sTempString);
				return Action:3;
			}
			if (StrEqual(sClass, "prop_physics_breakable", false))
			{
				copies = CreateEntityByName("prop_physics", -1);
			}
			else
			{
				if (StrEqual(sClass, "prop_physics_m_breakable", false))
				{
					copies = CreateEntityByName("prop_physics_multig_sPlayerClassname", -1);
				}
				copies = CreateEntityByName(sClass, -1);
			}
			DispatchKeyValue(copies, "model", modelName);
			DispatchKeyValue(copies, "skin", SskinNum);
			DispatchKeyValue(copies, "renderfx", SrenderFx);
			DispatchKeyValue(copies, "rendermode", "1");
			DispatchKeyValue(copies, "spawnflags", SentFlags);
			SetEntProp(copies, PropType:1, "m_takedamage", takedamage, 1);
			if (!DispatchSpawn(copies))
			{
				AcceptEntityInput(copies, "Kill", -1, -1, 0);
				if (StrEqual(sClass, "prop_physics", false))
				{
					copies = CreateEntityByName("prop_physics_override", -1);
					DispatchKeyValue(copies, "model", modelName);
					DispatchKeyValue(copies, "skin", SskinNum);
					DispatchKeyValue(copies, "renderfx", SrenderFx);
					DispatchKeyValue(copies, "rendermode", "1");
					DispatchKeyValue(copies, "spawnflags", SentFlags);
				}
				cmMsg(client, "Error pasting prop.");
				return Action:3;
			}
			DispatchSpawn(copies);
			SetEntProp(copies, PropType:1, "m_takedamage", takedamage, 1);
			SetEntityRenderColor(copies, eColor[0], eColor[1], eColor[2], eColor[3]);
			if (GetEntProp(copies, PropType:1, "m_takedamage", 4) == 2)
			{
				if (StrEqual(sClass, "prop_physics", false))
				{
					DispatchKeyValue(copies, "classname", "prop_physics_breakable");
				}
				DispatchKeyValue(copies, "classname", "prop_physics_m_breakable");
			}
			SetEntityMoveType(copies, MoveType:0);
			AcceptEntityInput(copies, "disablemotion", -1, -1, 0);
			if (!firstMade)
			{
				originOffset[0] = entOrgn[0] + offsets[0];
				originOffset[1] = entOrgn[1] + offsets[1];
				originOffset[2] = entOrgn[2] + offsets[2];
				firstMade = true;
			}
			else
			{
				originOffset[0] = originOffset[0] + offsets[0];
				originOffset[1] += offsets[1];
				originOffset[2] += offsets[2];
			}
			TeleportEntity(copies, originOffset, angRot, g_fEntityAngles);
			SetOwner(client, copies);
			sAmount += 1;
			copies++;
		}
	}
	return Action:3;
}

public Action:Command_propCount(client, args)
{
	decl ME;
	decl allE;
	decl pCount;
	decl bCount;
	decl nCount;
	decl vCount;
	decl cCount;
	pCount = 0;
	bCount = 0;
	nCount = 0;
	vCount = 0;
	cCount = 0;
	ME = GetMaxEntities();
	if (args < 1)
	{
		allE = 0;
		while (allE <= ME)
		{
			int var1;
			if (IsValidEdict(allE) && IsValidEntity(allE))
			{
				if (FindOwner(client, allE) == 1)
				{
					decl String:eClass[32];
					GetEdictClassname(allE, eClass, 32);
					if (StrContains(eClass, "prop_", false))
					{
						if (StrContains(eClass, "npc_", false))
						{
							int var2;
							if (StrEqual(eClass, "prop_vehicle_airboat", false) || StrEqual(eClass, "prop_vehicle_jeep", false))
							{
								vCount += 1;
							}
							if (!(StrContains(eClass, "cel", false)))
							{
								cCount += 1;
							}
						}
						nCount += 1;
					}
					else
					{
						pCount += 1;
						if (StrContains(eClass, "breakable", false) != -1)
						{
							bCount += 1;
						}
					}
				}
			}
			allE++;
		}
		PrintToChat(client, "\x04|CelMod|\x01 Props: %d", pCount);
		PrintToChat(client, "\x04|CelMod|\x01 Breakables: %d", bCount);
		PrintToChat(client, "\x04|CelMod|\x01 g_sNPCPrefix: %d", nCount);
		PrintToChat(client, "\x04|CelMod|\x01 Vehicles: %d", vCount);
		PrintToChat(client, "\x04|CelMod|\x01 Cels: %d", cCount);
		return Action:3;
	}
	decl String:findFilter[256];
	GetCmdArg(1, findFilter, 255);
	allE = 0;
	while (allE <= ME)
	{
		int var3;
		if (IsValidEdict(allE) && IsValidEntity(allE))
		{
			if (FindOwner(client, allE) == 1)
			{
				decl String:fClass[32];
				GetEdictClassname(allE, fClass, 32);
				if (StrContains(fClass, "prop_", false))
				{
					if (StrContains(fClass, "npc_", false))
					{
						int var4;
						if (StrEqual(fClass, "prop_vehicle_airboat", false) || StrEqual(fClass, "prop_vehicle_jeep", false))
						{
							vCount += 1;
						}
						if (!(StrContains(fClass, "cel", false)))
						{
							cCount += 1;
						}
					}
					nCount += 1;
				}
				else
				{
					pCount += 1;
					if (StrContains(fClass, "breakable", false) != -1)
					{
						bCount += 1;
					}
				}
			}
		}
		allE++;
	}
	if (StrEqual(findFilter, "props", false))
	{
		PrintToChat(client, "\x04|CelMod|\x01 Props: %d", pCount);
	}
	else
	{
		if (StrEqual(findFilter, "breakables", false))
		{
			PrintToChat(client, "\x04|CelMod|\x01 Breakables: %d", bCount);
		}
		if (StrEqual(findFilter, "g_sNPCPrefix", false))
		{
			PrintToChat(client, "\x04|CelMod|\x01 g_sNPCPrefix: %d", nCount);
		}
		if (StrEqual(findFilter, "vehicles", false))
		{
			PrintToChat(client, "\x04|CelMod|\x01 Vehicles: %d", vCount);
		}
		if (StrEqual(findFilter, "cels", false))
		{
			PrintToChat(client, "\x04|CelMod|\x01 Cels: %d", cCount);
		}
	}
	return Action:3;
}

public Action:Command_vehicleStart(client, args)
{
	int g_sPlayerClassnameEnt = GetEntPropEnt(client, PropType:1, "m_hVehicle");
	int var1;
	if (g_sPlayerClassnameEnt != -1 && g_hVehicleMoveTimer[client])
	{
		g_hVehicleMoveTimer[client] = CreateTimer(0.1, moveVehicle, client, 1);
	}
	return Action:3;
}

public Action:moveVehicle(Handle:timer, any:client)
{
	int g_sPlayerClassnameEnt = GetEntPropEnt(client, PropType:1, "m_hVehicle");
	if (g_sPlayerClassnameEnt != -1)
	{
		decl Float:vehAng[3];
		decl Float:vehVelocity[3];
		GetClientEyeAngles(client, vehAng);
		vehVelocity[0] = Cosine(DegToRad(vehAng[1])) * 700;
		vehVelocity[1] = Sine(DegToRad(vehAng[1])) * 700;
		vehVelocity[2] = Sine(DegToRad(vehAng[0])) * -1680;
		TeleportEntity(g_sPlayerClassnameEnt, NULL_VECTOR, NULL_VECTOR, vehVelocity);
	}
	return Action:0;
}

public Action:Command_vehicleStop(client, args)
{
	if (g_hVehicleMoveTimer[client])
	{
		KillTimer(g_hVehicleMoveTimer[client], false);
		g_hVehicleMoveTimer[client] = 0;
	}
	return Action:3;
}

public Action:Command_vehicleStartBack(client, args)
{
	int g_sPlayerClassnameEnt = GetEntPropEnt(client, PropType:1, "m_hVehicle");
	int var1;
	if (g_sPlayerClassnameEnt != -1 && g_hVehicleMoveTimer[client])
	{
		g_hVehicleMoveTimer[client] = CreateTimer(0.1, moveVehicleBack, client, 1);
	}
	return Action:3;
}

public Action:moveVehicleBack(Handle:timer, any:client)
{
	int g_sPlayerClassnameEnt = GetEntPropEnt(client, PropType:1, "m_hVehicle");
	if (g_sPlayerClassnameEnt != -1)
	{
		decl Float:vehAng[3];
		decl Float:vehVelocity[3];
		GetClientEyeAngles(client, vehAng);
		vehVelocity[0] = Cosine(DegToRad(vehAng[1])) * -700;
		vehVelocity[1] = Sine(DegToRad(vehAng[1])) * -700;
		vehVelocity[2] = Sine(DegToRad(vehAng[0])) * 1680;
		TeleportEntity(g_sPlayerClassnameEnt, NULL_VECTOR, NULL_VECTOR, vehVelocity);
	}
	return Action:0;
}
