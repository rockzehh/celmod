//|CelMod| by rockzehh.

#pragma semicolon 1

#include <celmod>
#include <geoip>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma newdecls required

bool g_bBetaBranchUpdates;
bool g_bLate;
bool g_bIsFlying[MAXPLAYERS + 1];
bool g_bNoKill[MAXPLAYERS + 1];
bool g_bPlayer[MAXPLAYERS + 1];

char g_sAuthID[MAXPLAYERS + 1][64];
char g_sBlacklistDB[PLATFORM_MAX_PATH];
char g_sDownloadPath[PLATFORM_MAX_PATH];
char g_sOverlayPath[PLATFORM_MAX_PATH];
char g_sSpawnDB[PLATFORM_MAX_PATH];

ConVar g_cvBetaBranchUpdates;
ConVar g_cvCelLimit;
ConVar g_cvDownloadPath;
ConVar g_cvOverlayPath;
ConVar g_cvPropLimit;

Handle g_hOnPropSpawn;

int g_iBeam;
int g_iCelCount[MAXPLAYERS + 1];
int g_iCelLimit;
int g_iHalo;
int g_iPhys;
int g_iPropCount[MAXPLAYERS + 1];
int g_iPropLimit;

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_AddToBlacklist", Native_AddToBlacklist);
	CreateNative("Cel_AddToCelCount", Native_AddToCelCount);
	CreateNative("Cel_AddToPropCount", Native_AddToPropCount);
	CreateNative("Cel_ChangeBeam", Native_ChangeBeam);
	CreateNative("Cel_CheckBlacklistDB", Native_CheckBlacklistDB);
	CreateNative("Cel_CheckCelCount", Native_CheckCelCount);
	CreateNative("Cel_CheckPropCount", Native_CheckPropCount);
	CreateNative("Cel_CheckSpawnDB", Native_CheckSpawnDB);
	CreateNative("Cel_DownloadClientFiles", Native_DownloadClientFiles);
	CreateNative("Cel_GetAuthID", Native_GetAuthID);
	CreateNative("Cel_GetBeamMaterial", Native_GetBeamMaterial);
	CreateNative("Cel_GetCelCount", Native_GetCelCount);
	CreateNative("Cel_GetCelLimit", Native_GetCelLimit);
	CreateNative("Cel_GetClientAimTarget", Native_GetClientAimTarget);
	CreateNative("Cel_GetCombinedCount", Native_GetCombinedCount);
	CreateNative("Cel_GetCrosshairHitOrigin", Native_GetCrosshairHitOrigin);
	CreateNative("Cel_GetHaloMaterial", Native_GetHaloMaterial);
	CreateNative("Cel_GetNoKill", Native_GetNoKill);
	CreateNative("Cel_GetPhysicsMaterial", Native_GetPhysicsMaterial);
	CreateNative("Cel_GetPropCount", Native_GetPropCount);
	CreateNative("Cel_GetPropLimit", Native_GetPropLimit);
	CreateNative("Cel_IsPlayer", Native_IsPlayer);
	CreateNative("Cel_RemovalBeam", Native_RemovalBeam);
	CreateNative("Cel_RemoveFromBlacklist", Native_RemoveFromBlacklist);
	CreateNative("Cel_SetAuthID", Native_SetAuthID);
	CreateNative("Cel_SetCelCount", Native_SetCelCount);
	CreateNative("Cel_SetCelLimit", Native_SetCelLimit);
	CreateNative("Cel_SetNoKill", Native_SetNoKill);
	CreateNative("Cel_SetPlayer", Native_SetPlayer);
	CreateNative("Cel_SetPropCount", Native_SetPropCount);
	CreateNative("Cel_SetPropLimit", Native_SetPropLimit);
	CreateNative("Cel_SpawnProp", Native_SpawnProp);
	CreateNative("Cel_SubFromCelCount", Native_SubFromCelCount);
	CreateNative("Cel_SubFromPropCount", Native_SubFromPropCount);
	
	g_bLate = bLate;
	
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "|CelMod|",
	author = CEL_AUTHOR,
	description = "A fully customized building experience with extra features to enhance the standard gameplay.",
	version = CEL_VERSION,
	url = CEL_URL
};

public void OnLibraryAdded(const char[] sName)
{
	if (StrEqual(sName, "updater"))
	{
		Updater_AddPlugin(g_bBetaBranchUpdates ? UPDATE_BETA_URL : UPDATE_URL);
	}
}

public void OnPluginStart()
{
	LoadTranslations("celmod.phrases");
	LoadTranslations("common.phrases");
	
	char sPath[PLATFORM_MAX_PATH];
	
	if (g_bLate)
	{
		for (int i = 1; i < MaxClients; i++)
		{
			if (IsClientAuthorized(i))
			{
				Cel_SetAuthID(i);
				
				OnClientPutInServer(i);
			}
		}
		
		OnMapStart();
	}
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod");
	if (!DirExists(sPath))
	{
		CreateDirectory(sPath, 511);
	}
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/users");
	if (!DirExists(sPath))
	{
		CreateDirectory(sPath, 511);
	}
	BuildPath(Path_SM, g_sSpawnDB, sizeof(g_sSpawnDB), "data/celmod/spawns.txt");
	if (!FileExists(g_sSpawnDB))
	{
		ThrowError("|CelMod| %t", "FileNotFound", g_sSpawnDB);
	}
	BuildPath(Path_SM, g_sBlacklistDB, sizeof(g_sBlacklistDB), "data/celmod/blacklist.txt");
	if (!FileExists(g_sBlacklistDB))
	{
		Cel_AddToBlacklist("traintrack01");
	}
	
	AddCommandListener(Handle_Spawn, "say");
	AddCommandListener(Handle_Spawn, "say_team");
	
	g_hOnPropSpawn = CreateGlobalForward("Cel_OnPropSpawn", ET_Hook, Param_Cell, Param_Cell, Param_Cell);
	
	HookEvent("player_connect", Event_Connect, EventHookMode_Pre);
	HookEvent("player_death", Event_Death, EventHookMode_Post);
	HookEvent("player_disconnect", Event_Disconnect, EventHookMode_Pre);
	HookEvent("player_spawn", Event_Spawn, EventHookMode_Post);
	
	RegConsoleCmd("dev_getpos", Dev_GetPos, "");
	
	RegAdminCmd("v_blacklist", Command_Blacklist, ADMFLAG_SLAY, "|CelMod| Adds/removes a prop from the spawn blacklist.");
	RegAdminCmd("v_setowner", Command_SetOwner, ADMFLAG_SLAY, "|CelMod| Sets the owner of the prop you are looking at.");
	
	RegConsoleCmd("v_axis", Command_Axis, "|CelMod| Creates a marker to the player showing every axis.");
	RegConsoleCmd("v_fly", Command_Fly, "|CelMod| Enables/disables noclip on the player.");
	RegConsoleCmd("v_mark", Command_Axis, "|CelMod| Creates a marker to the player showing every axis.");
	RegConsoleCmd("v_marker", Command_Axis, "|CelMod| Creates a marker to the player showing every axis.");
	RegConsoleCmd("v_nokill", Command_NoKill, "|CelMod| Enables/disables godmode on the player.");
	RegConsoleCmd("v_owner", Command_Owner, "|CelMod| Gets the owner of the entity you are looking at.");
	RegConsoleCmd("v_p", Command_Spawn, "|CelMod| Spawns a prop by name.");
	RegConsoleCmd("v_s", Command_Spawn, "|CelMod| Spawns a prop by name.");
	RegConsoleCmd("v_spawn", Command_Spawn, "|CelMod| Spawns a prop by name.");
	
	CreateConVar("celmod", "1", "Notifies the server that the plugin is running.");
	g_cvBetaBranchUpdates = CreateConVar("cm_use_beta_branch", "1", "Chooses which branch to use for updates. Only changed at startup.");
	g_cvCelLimit = CreateConVar("cm_max_player_cels", "20", "Maxiumum number of cel entities a client is allowed.");
	g_cvDownloadPath = CreateConVar("cm_download_list_path", "data/celmod/downloads.txt", "Path for the download list for clients.");
	g_cvPropLimit = CreateConVar("cm_max_player_props", "160", "Maxiumum number of props a player is allowed to spawn.");
	g_cvOverlayPath = CreateConVar("cm_overlay_material_path", "celmod/cm_overlay2.vmt", "Default CelMod overlay path.");
	CreateConVar("cm_version", CEL_VERSION, "The version of the plugin the server is running.");
	
	g_cvCelLimit.AddChangeHook(CM_OnConVarChanged);
	g_cvDownloadPath.AddChangeHook(CM_OnConVarChanged);
	g_cvOverlayPath.AddChangeHook(CM_OnConVarChanged);
	g_cvPropLimit.AddChangeHook(CM_OnConVarChanged);
	
	g_bBetaBranchUpdates = g_cvBetaBranchUpdates.BoolValue;
	Cel_SetCelLimit(g_cvCelLimit.IntValue);
	g_cvDownloadPath.GetString(g_sDownloadPath, sizeof(g_sDownloadPath));
	g_cvOverlayPath.GetString(g_sOverlayPath, sizeof(g_sOverlayPath));
	Cel_SetPropLimit(g_cvPropLimit.IntValue);
	
	AutoExecConfig(true, "celmod.main");
	
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(g_bBetaBranchUpdates ? UPDATE_BETA_URL : UPDATE_URL);
	}
	
	ConCommand_RemoveFlags("r_screenoverlay", FCVAR_CHEAT);
}

public void OnClientAuthorized(int iClient, const char[] sAuthID)
{
	char sClient[128], sCountry[45], sIP[64];
	
	GetClientIP(iClient, sIP, sizeof(sIP), true);
	GetClientName(iClient, sClient, sizeof(sClient));
	GeoipCountry(sIP, sCountry, sizeof(sCountry));
	
	Cel_SetAuthID(iClient);
	
	CPrintToChatAll("{green}[+]{default} %t", "Connecting", sClient, sCountry);
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			PrecacheSound("npc/metropolice/vo/on1.wav");
			
			EmitSoundToClient(i, "npc/metropolice/vo/on1.wav", i, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}
	}
}

public void OnClientPutInServer(int iClient)
{
	char sAuthID[64], sPath[PLATFORM_MAX_PATH];
	
	Cel_ChooseHudColor(iClient);
	
	Cel_GetAuthID(iClient, sAuthID, sizeof(sAuthID));
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/users/%s", sAuthID);
	if (!DirExists(sPath))
	{
		CreateDirectory(sPath, 511);
	}
	
	Cel_SetCelCount(iClient, 0);
	Cel_SetNoKill(iClient, false);
	Cel_SetPlayer(iClient, true);
	Cel_SetPropCount(iClient, 0);
	
	g_bIsFlying[iClient] = false;
	
	ClientCommand(iClient, "r_screenoverlay %s", g_sOverlayPath);
}

public void OnClientDisconnect(int iClient)
{
	char sClient[128];
	
	GetClientName(iClient, sClient, sizeof(sClient));
	
	Cel_SetCelCount(iClient, 0);
	Cel_SetNoKill(iClient, false);
	Cel_SetPlayer(iClient, false);
	Cel_SetPropCount(iClient, 0);
	
	g_bIsFlying[iClient] = false;
	
	ClientCommand(iClient, "r_screenoverlay 0", g_sOverlayPath);
	
	CPrintToChatAll("{red}[-]{default} %t", "Disconnecting", sClient);
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			PrecacheSound("npc/metropolice/vo/off1.wav");
			
			EmitSoundToClient(i, "npc/metropolice/vo/off1.wav", i, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}
	}
}

public void OnMapStart()
{
	g_iBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_iHalo = PrecacheModel("materials/sprites/halo01.vmt", true);
	g_iPhys = PrecacheModel("materials/sprites/physbeam.vmt", true);
	
	Cel_DownloadClientFiles();
}

public void OnMapEnd()
{
	g_iBeam = -1;
	g_iHalo = -1;
	g_iPhys = -1;
}

public void CM_OnConVarChanged(ConVar cvConVar, const char[] sOldValue, const char[] sNewValue)
{
	if (cvConVar == g_cvCelLimit)
	{
		Cel_SetCelLimit(StringToInt(sNewValue));
		PrintToServer("|CelMod| Cel limit updated to %i.", StringToInt(sNewValue));
	} else if (cvConVar == g_cvDownloadPath)
	{
		g_cvDownloadPath.GetString(g_sDownloadPath, sizeof(g_sDownloadPath));
		PrintToServer("|CelMod| Download list path updated to %s.", sNewValue);
	} else if (cvConVar == g_cvOverlayPath)
	{
		g_cvOverlayPath.GetString(g_sOverlayPath, sizeof(g_sOverlayPath));
		PrintToServer("|CelMod| Default overlay material path updated to %s.", sNewValue);
	} else if (cvConVar == g_cvPropLimit) {
		Cel_SetPropLimit(StringToInt(sNewValue));
		PrintToServer("|CelMod| Prop limit updated to %i.", StringToInt(sNewValue));
	}
}

//Commands:
public Action Dev_GetPos(int iClient, int iArgs)
{
	float fAng[3], fPos[3];
	
	GetClientAbsAngles(iClient, fAng);
	GetClientAbsOrigin(iClient, fPos);
	
	PrintToChat(iClient, "ANG: %f.f %f.f %f.f POS: %f.f %f.f %f.f", fAng[0], fAng[1], fAng[2], fPos[0], fPos[1], fPos[2]);
	
	return Plugin_Handled;
}

public Action Command_Axis(int iClient, int iArgs)
{
	float fClientOrigin[4][3];
	
	GetClientAbsOrigin(iClient, fClientOrigin[0]);
	GetClientAbsOrigin(iClient, fClientOrigin[1]);
	GetClientAbsOrigin(iClient, fClientOrigin[2]);
	GetClientAbsOrigin(iClient, fClientOrigin[3]);
	
	fClientOrigin[1][0] += 50;
	fClientOrigin[2][1] += 50;
	fClientOrigin[3][2] += 50;
	
	TE_SetupBeamPoints(fClientOrigin[0], fClientOrigin[1], Cel_GetBeamMaterial(), Cel_GetHaloMaterial(), 0, 15, 60.0, 3.0, 3.0, 1, 0.0, g_iRed, 10); TE_SendToClient(iClient);
	TE_SetupBeamPoints(fClientOrigin[0], fClientOrigin[2], Cel_GetBeamMaterial(), Cel_GetHaloMaterial(), 0, 15, 60.0, 3.0, 3.0, 1, 0.0, g_iGreen, 10); TE_SendToClient(iClient);
	TE_SetupBeamPoints(fClientOrigin[0], fClientOrigin[3], Cel_GetBeamMaterial(), Cel_GetHaloMaterial(), 0, 15, 60.0, 3.0, 3.0, 1, 0.0, g_iBlue, 10); TE_SendToClient(iClient);
	
	Cel_ReplyToCommand(iClient, "%t", "CreateAxis");
	
	return Plugin_Handled;
}

public Action Command_Blacklist(int iClient, int iArgs)
{
	char sOption[64], sProp[64];
	
	if(iArgs < 2)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Blacklist");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sOption, sizeof(sOption));
	GetCmdArg(2, sProp, sizeof(sProp));
	
	if(StrEqual(sOption, "#add", false))
	{
		if(Cel_CheckBlacklistDB(sProp))
		{
			Cel_ReplyToCommand(iClient, "%t", "PropInBlacklist", sProp);
			return Plugin_Handled;
		}
		
		Cel_AddToBlacklist(sProp);
		
		Cel_ReplyToCommand(iClient, "%t", "AddToBlacklist", sProp);
		
		return Plugin_Handled;
	}else if(StrEqual(sOption, "#remove", false))
	{
		if(!Cel_CheckBlacklistDB(sProp))
		{
			Cel_ReplyToCommand(iClient, "%t", "PropNotInBlacklist", sProp);
			return Plugin_Handled;
		}
		
		Cel_RemoveFromBlacklist(sProp);
		
		Cel_ReplyToCommand(iClient, "%t", "RemoveFromBlacklist", sProp);
		
		return Plugin_Handled;
	}else{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Blacklist");
		return Plugin_Handled;
	}
}

public Action Command_Fly(int iClient, int iArgs)
{
	g_bIsFlying[iClient] = !g_bIsFlying[iClient];
	
	SetEntityMoveType(iClient, g_bIsFlying[iClient] ? MOVETYPE_NOCLIP : MOVETYPE_WALK);
	
	Cel_ReplyToCommand(iClient, "%t", "Flying", g_bIsFlying[iClient] ? "enabled" : "disabled");
	
	return Plugin_Handled;
}

public Action Command_NoKill(int iClient, int iArgs)
{
	Cel_SetNoKill(iClient, !Cel_GetNoKill(iClient));
	
	Cel_ReplyToCommand(iClient, "%t", "NoKill", Cel_GetNoKill(iClient) ? "on" : "off");
	
	return Plugin_Handled;
}

public Action Command_Owner(int iClient, int iArgs)
{
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if(Cel_IsEntity(iProp))
	{
		if(Cel_CheckOwner(iClient, iProp))
		{
			Cel_ReplyToCommandEntity(iClient, iProp, "%t", "IsOwner");
		}else{
			Cel_ReplyToCommandEntity(iClient, iProp, "%t", "EntityOwner");
		}
	}
	
	return Plugin_Handled;
}

public Action Command_SetOwner(int iClient, int iArgs)
{
	char sNames[2][PLATFORM_MAX_PATH], sTarget[PLATFORM_MAX_PATH];
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	GetCmdArg(1, sTarget, sizeof(sTarget));
	
	GetClientName(iClient, sNames[0], sizeof(sNames[]));
	
	if (StrEqual(sTarget, ""))
	{
		Cel_SetOwner(iClient, iProp);
		
		Cel_ChangeBeam(iClient, iProp);
		
		Cel_ReplyToCommandEntity(iClient, iProp, "%t", "SetOwnerClient", sNames[0]);
		
		return Plugin_Handled;
	}
	
	int iTarget = FindTarget(iClient, sTarget, true, false);
	
	if (iTarget == -1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CantFindTarget");
		return Plugin_Handled;
	}
	
	GetClientName(iTarget, sNames[1], sizeof(sNames[]));
	
	Cel_SetOwner(iTarget, iProp);
	
	Cel_ChangeBeam(iClient, iProp);
	
	Cel_ReplyToCommandEntity(iClient, iProp, "%t", "SetOwnerClient", sNames[1]);
	Cel_ReplyToCommandEntity(iClient, iProp,  "%t", "SetOwnerTarget", sNames[0], sNames[1]);
	
	return Plugin_Handled;
}

public Action Command_Spawn(int iClient, int iArgs)
{
	char sAlias[64], sOption[64], sSpawnBuffer[2][128], sSpawnString[256];
	float fAngles[3], fOrigin[3];
	int iOption = 0;
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Spawn");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlias, sizeof(sAlias));
	GetCmdArg(2, sOption, sizeof(sOption));
	
	if (!Cel_CheckPropCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxPropLimit", Cel_GetPropCount(iClient));
		return Plugin_Handled;
	}
	
	if(Cel_CheckBlacklistDB(sAlias))
	{
		Cel_ReplyToCommand(iClient, "%t", "PropNotFound", sAlias);
		return Plugin_Handled;
	}
	
	if(StrEqual(sOption, "drop", false))
	{
		iOption = 1;
	}else if(StrEqual(sOption, "unfrozen", false))
	{
		iOption = 2;
	}else if(StrEqual(sOption, "nogod", false))
	{
		iOption = 3;
	}else if(StrEqual(sOption, "", false))
	{
		iOption = 0;
	}else{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Spawn");
		return Plugin_Handled;
	}
	
	if (Cel_CheckSpawnDB(sAlias, sSpawnString, sizeof(sSpawnString)))
	{
		ExplodeString(sSpawnString, "|", sSpawnBuffer, 2, sizeof(sSpawnBuffer[]));
		
		GetClientAbsAngles(iClient, fAngles);
		Cel_GetCrosshairHitOrigin(iClient, fOrigin);
		
		int iProp = Cel_SpawnProp(iClient, sAlias, sSpawnBuffer[0], sSpawnBuffer[1], fAngles, fOrigin, 255, 255, 255, 255);
		
		Cel_FixSpawnPosition(iProp, fOrigin);
		
		switch(iOption)
		{
			case 1:
			{
				Cel_DropEntityToFloor(iProp);
			}
			case 2:
			{
				Cel_SetMotion(iProp, true);
			}
			case 3:
			{
				Cel_SetBreakable(iProp, true);
			}
		}
		
		Call_StartForward(g_hOnPropSpawn);
		
		Call_PushCell(iProp);
		Call_PushCell(iClient);
		Call_PushCell(Cel_GetEntityType(iProp));
		
		Call_Finish();
		
		Cel_ReplyToCommand(iClient, "%t", "SpawnProp", sAlias);
	} else {
		Cel_ReplyToCommand(iClient, "%t", "PropNotFound", sAlias);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Handle_Spawn(int iClient, char[] sCommand, int iArgs)
{
	char sOption[64], sPropAlias[64], sSpawnBuffer[2][128], sSpawnString[256];
	float fAngles[3], fOrigin[3];
	int iOption = 0;
	
	GetCmdArg(1, sPropAlias, sizeof(sPropAlias));
	
	ReplaceString(sPropAlias, sizeof(sPropAlias), "!", "");
	ReplaceString(sPropAlias, sizeof(sPropAlias), "/", "");
	
	if (Cel_CheckSpawnDB(sPropAlias, sSpawnString, sizeof(sSpawnString)))
	{
		GetCmdArg(2, sOption, sizeof(sOption));
		
		if(StrEqual(sOption, "drop", false))
		{
			iOption = 1;
		}else if(StrEqual(sOption, "unfrozen", false))
		{
			iOption = 2;
		}else if(StrEqual(sOption, "nogod", false))
		{
			iOption = 3;
		}else if(StrEqual(sOption, "", false))
		{
			iOption = 0;
		}else{
			iOption = 0;
		}
		
		if (!Cel_CheckPropCount(iClient))
		{
			Cel_ReplyToCommand(iClient, "%t", "MaxPropLimit", Cel_GetPropCount(iClient));
			return Plugin_Handled;
		}
		
		if(Cel_CheckBlacklistDB(sPropAlias))
		{
			return Plugin_Continue;
		}
		
		ExplodeString(sSpawnString, "|", sSpawnBuffer, 2, sizeof(sSpawnBuffer[]));
		
		GetClientAbsAngles(iClient, fAngles);
		Cel_GetCrosshairHitOrigin(iClient, fOrigin);
		
		int iProp = Cel_SpawnProp(iClient, sPropAlias, sSpawnBuffer[0], sSpawnBuffer[1], fAngles, fOrigin, 255, 255, 255, 255);
		
		Cel_FixSpawnPosition(iProp, fOrigin);
		
		switch(iOption)
		{
			case 1:
			{
				Cel_DropEntityToFloor(iProp);
			}
			case 2:
			{
				Cel_SetMotion(iProp, true);
			}
			case 3:
			{
				Cel_SetBreakable(iProp, true);
			}
		}
		
		Call_StartForward(g_hOnPropSpawn);
		
		Call_PushCell(iProp);
		Call_PushCell(iClient);
		Call_PushCell(Cel_GetEntityType(iProp));
		
		Call_Finish();
		
		Cel_ReplyToCommand(iClient, "%t", "SpawnProp", sPropAlias);
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

//Events:
public Action Event_Connect(Event eEvent, const char[] sName, bool bDontBroadcast)
{
	if (!bDontBroadcast)
	{
		char sClientName[33], sNetworkID[22], sAddress[32];
		
		eEvent.GetString("name", sClientName, sizeof(sClientName));
		eEvent.GetString("networkid", sNetworkID, sizeof(sNetworkID));
		eEvent.GetString("address", sAddress, sizeof(sAddress));
		
		Event eNewEvent = CreateEvent("player_connect", true);
		eNewEvent.SetString("name", sClientName);
		
		eNewEvent.SetInt("index", GetEventInt(eEvent, "index"));
		eNewEvent.SetInt("userid", GetEventInt(eEvent, "userid"));
		
		eNewEvent.SetString("networkid", sNetworkID);
		eNewEvent.SetString("address", sAddress);
		
		eNewEvent.Fire(true);
		
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Event_Death(Event eEvent, const char[] sName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	
	if(Cel_IsPlayer(iClient))
	{
		int iRagdoll = GetEntPropEnt(iClient, Prop_Send, "m_hRagdoll");
		
		IgniteEntity(iRagdoll, 3.0);
		
		CreateTimer(2.0, Timer_DisRemove, EntIndexToEntRef(iRagdoll));
	}
	
	return Plugin_Handled;
}

public Action Event_Disconnect(Event eEvent, const char[] sName, bool bDontBroadcast)
{
	if (!bDontBroadcast)
	{
		char sClientName[33], sNetworkID[22], sReason[65];
		
		eEvent.GetString("name", sClientName, sizeof(sClientName));
		eEvent.GetString("networkid", sNetworkID, sizeof(sNetworkID));
		eEvent.GetString("reason", sReason, sizeof(sReason));
		
		Event eNewEvent = CreateEvent("player_disconnect", true);
		eNewEvent.SetInt("userid", GetEventInt(eEvent, "userid"));
		eNewEvent.SetString("reason", sReason);
		eNewEvent.SetString("name", sClientName);
		eNewEvent.SetString("networkid", sNetworkID);
		
		eNewEvent.Fire(true);
		
		return Plugin_Handled;
	}
	
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	
	for (int i = 0; i < GetMaxEntities(); i++)
	{
		if (Cel_CheckOwner(iClient, i) && IsValidEntity(i))
		{
			if (Cel_CheckEntityType(i, "effect"))
			{
				Cel_SetRainbow(Cel_GetEffectAttachment(i), false);
				Cel_SetColorFade(Cel_GetEffectAttachment(i), false, 0, 0, 0, 0, 0, 0);
				
				AcceptEntityInput(Cel_GetEffectAttachment(i), "TurnOff");
				AcceptEntityInput(Cel_GetEffectAttachment(i), "kill");
			}
			
			AcceptEntityInput(i, "kill");
		}
	}
	
	return Plugin_Handled;
}

public Action Event_Spawn(Event eEvent, const char[] sName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	
	Cel_SetNoKill(iClient, view_as<bool>(Cel_GetNoKill(iClient)));
	
	return Plugin_Continue;
}

//Natives:
public int Native_AddToBlacklist(Handle hPlugin, int iNumParams)
{
	char sProp[64];
	
	GetNativeString(1, sProp, sizeof(sProp));
	
	KeyValues kvBlacklist = new KeyValues("Vault");
	
	kvBlacklist.ImportFromFile(g_sBlacklistDB);
	
	kvBlacklist.JumpToKey("Blacklist", true);
	
	kvBlacklist.SetString(sProp, "blacklist");
	
	kvBlacklist.Rewind();
	
	kvBlacklist.ExportToFile(g_sBlacklistDB);
	
	kvBlacklist.Close();
	
	return true;
}

public int Native_AddToCelCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	int iFinalCount = (g_iCelCount[iClient] += 1);
	
	Cel_SetCelCount(iClient, iFinalCount);
	
	return true;
}

public int Native_AddToPropCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	int iFinalCount = (g_iPropCount[iClient] += 1);
	
	Cel_SetPropCount(iClient, iFinalCount);
	
	return true;
}

public int Native_ChangeBeam(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iEntity = GetNativeCell(2);
	
	char sSound[96];
	
	float fClientOrigin[3], fHitOrigin[3];
	
	GetClientAbsOrigin(iClient, fClientOrigin);
	
	Cel_GetCrosshairHitOrigin(iClient, fHitOrigin);
	
	TE_SetupBeamPoints(fClientOrigin, fHitOrigin, Cel_GetPhysicsMaterial(), Cel_GetHaloMaterial(), 0, 15, 0.25, 5.0, 5.0, 1, 0.0, g_iWhite, 10); TE_SendToAll();
	TE_SetupSparks(fHitOrigin, NULL_VECTOR, 2, 5); TE_SendToAll();
	
	Format(sSound, sizeof(sSound), "weapons/airboat/airboat_gun_lastshot%i.wav", GetRandomInt(1, 2));
	
	PrecacheSound(sSound);
	
	EmitSoundToAll(sSound, iEntity, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	
	return true;
}

public int Native_CheckBlacklistDB(Handle hPlugin, int iNumParams)
{
	char sAlias[64], sSpawnString[128];
	
	GetNativeString(1, sAlias, sizeof(sAlias));
	
	KeyValues kvBlacklist = new KeyValues("Vault");
	
	kvBlacklist.ImportFromFile(g_sBlacklistDB);
	
	kvBlacklist.JumpToKey("Blacklist", false);
	
	kvBlacklist.GetString(sAlias, sSpawnString, sizeof(sSpawnString), "null");
	
	kvBlacklist.Rewind();
	
	delete kvBlacklist;
	
	return (StrEqual(sSpawnString, "null")) ? false : true;
}

public int Native_CheckCelCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	return (Cel_GetCelCount(iClient) >= Cel_GetCelLimit()) ? false : true;
}

public int Native_CheckPropCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	return (Cel_GetPropCount(iClient) >= Cel_GetPropLimit()) ? false : true;
}

public int Native_CheckSpawnDB(Handle hPlugin, int iNumParams)
{
	int iMaxLength = GetNativeCell(3);
	
	char sAlias[64], sSpawnString[128];
	
	GetNativeString(1, sAlias, sizeof(sAlias));
	
	KeyValues kvProps = new KeyValues("Props");
	
	kvProps.ImportFromFile(g_sSpawnDB);
	
	kvProps.JumpToKey("Models", false);
	
	kvProps.GetString(sAlias, sSpawnString, iMaxLength, "null");
	
	kvProps.Rewind();
	
	delete kvProps;
	
	SetNativeString(2, sSpawnString, iMaxLength);
	
	return (StrEqual(sSpawnString, "null")) ? false : true;
}

public int Native_DownloadClientFiles(Handle hPlugin, int iNumParams)
{
	char sPath[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, sPath, sizeof(sPath), g_sDownloadPath);
	
	if(!FileExists(sPath))
	{
		PrintToServer("|CelMod| Cannot download client files. (No download txt file exists at data/celmod/downloads.txt)");
	}else{
		File fDownloadFiles = OpenFile(sPath, "r");
		
		char sBuffer[256];
		
		while (fDownloadFiles.ReadLine(sBuffer, sizeof(sBuffer)))
		{
			int iLen = strlen(sBuffer);
			
			if (sBuffer[iLen-1] == '\n')
			{
				sBuffer[--iLen] = '\0';
			}
			
			if (FileExists(sBuffer))
			{
				AddFileToDownloadsTable(sBuffer);
			}
			
			if(StrContains(sBuffer, ".mdl", false) != -1)
			{
				PrecacheModel(sBuffer, true);
			}
			
			if (fDownloadFiles.EndOfFile())
			{
				fDownloadFiles.Close();
				break;
			}
		}
	}
	
	return true;
}

public int Native_GetAuthID(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1), iMaxLength = GetNativeCell(3);
	
	SetNativeString(2, g_sAuthID[iClient], iMaxLength);
	
	return true;
}

public int Native_GetBeamMaterial(Handle hPlugin, int iNumParams)
{
	return g_iBeam;
}

public int Native_GetCelCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	return g_iCelCount[iClient];
}

public int Native_GetCelLimit(Handle hPlugin, int iNumParams)
{
	return g_iCelLimit;
}

public int Native_GetClientAimTarget(Handle hPlugin, int iNumParams)
{
	float fEyeAngles[3], fEyeOrigin[3], fHitPoint[3];
	int iClient = GetNativeCell(1), iTarget = -1;
	
	GetClientEyeAngles(iClient, fEyeAngles);
	GetClientEyePosition(iClient, fEyeOrigin);
	
	Handle hTraceRay = TR_TraceRayFilterEx(fEyeOrigin, fEyeAngles, (MASK_SHOT_HULL|MASK_SHOT), RayType_Infinite, Cel_FilterPlayer, iClient);
	
	if (TR_DidHit(hTraceRay))
	{
		iTarget = TR_GetEntityIndex(hTraceRay);
		
		if(iTarget == 0) iTarget = -1;
		
		if(iTarget == -1)
		{
			TR_GetEndPosition(fHitPoint, hTraceRay);
			
			TR_GetPointContents(fHitPoint, iTarget);
			
			TR_GetPlaneNormal(hTraceRay, fHitPoint);
			TR_GetPointContents(fHitPoint, iTarget);
		}
		
		CloseHandle(hTraceRay);
	}
	
	return (Cel_IsEntity(iTarget) && !Cel_IsDeleting(iTarget)) ? iTarget : -1;
}

public int Native_GetCombinedCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	return (g_iPropCount[iClient] + g_iCelCount[iClient]);
}

public int Native_GetCrosshairHitOrigin(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	float fCrosshairOrigin[3], fEyeAngles[3], fEyeOrigin[3];
	
	GetClientEyeAngles(iClient, fEyeAngles);
	GetClientEyePosition(iClient, fEyeOrigin);
	
	Handle hTraceRay = TR_TraceRayFilterEx(fEyeOrigin, fEyeAngles, (MASK_SHOT_HULL|MASK_SHOT), RayType_Infinite, Cel_FilterPlayer, iClient);
	
	if (TR_DidHit(hTraceRay))
	{
		TR_GetEndPosition(fCrosshairOrigin, hTraceRay);
		
		CloseHandle(hTraceRay);
	}
	
	SetNativeArray(2, fCrosshairOrigin, 3);
	
	return true;
}

public int Native_GetHaloMaterial(Handle hPlugin, int iNumParams)
{
	return g_iHalo;
}

public int Native_GetNoKill(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	return g_bNoKill[iClient];
}

public int Native_GetPhysicsMaterial(Handle hPlugin, int iNumParams)
{
	return g_iPhys;
}

public int Native_GetPropCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	return g_iPropCount[iClient];
}

public int Native_GetPropLimit(Handle hPlugin, int iNumParams)
{
	return g_iPropLimit;
}

public int Native_IsPlayer(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	return g_bPlayer[iClient];
}

public int Native_RemovalBeam(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iEntity = GetNativeCell(2);
	
	char sSound[96];
	
	float fClientOrigin[3], fEntityOrigin[3];
	
	GetClientAbsOrigin(iClient, fClientOrigin);
	
	Cel_GetEntityOrigin(iEntity, fEntityOrigin);
	
	TE_SetupBeamPoints(fClientOrigin, fEntityOrigin, Cel_GetBeamMaterial(), Cel_GetHaloMaterial(), 0, 15, 0.25, 5.0, 5.0, 1, 0.0, g_iGray, 10); TE_SendToAll();
	
	TE_SetupBeamRingPoint(fEntityOrigin, 0.0, 15.0, Cel_GetBeamMaterial(), Cel_GetHaloMaterial(), 0, 15, 0.5, 5.0, 0.0, g_iGray, 10, 0); TE_SendToAll();
	
	Format(sSound, sizeof(sSound), "ambient/levels/citadel/weapon_disintegrate%i.wav", GetRandomInt(1, 4));
	
	PrecacheSound(sSound);
	
	EmitAmbientSound(sSound, fEntityOrigin, iEntity, 100, 0, 1.0, 100, 0.0);
	
	return true;
}

public int Native_RemoveFromBlacklist(Handle hPlugin, int iNumParams)
{
	char sProp[64];
	
	GetNativeString(1, sProp, sizeof(sProp));
	
	KeyValues kvBlacklist = new KeyValues("Vault");
	
	kvBlacklist.ImportFromFile(g_sBlacklistDB);
	
	kvBlacklist.JumpToKey("Blacklist", true);
	
	kvBlacklist.DeleteKey(sProp);
	
	kvBlacklist.Rewind();
	
	kvBlacklist.ExportToFile(g_sBlacklistDB);
	
	kvBlacklist.Close();
	
	return true;
}

public int Native_SetAuthID(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	GetClientAuthId(iClient, AuthId_SteamID64, g_sAuthID[iClient], sizeof(g_sAuthID));
	
	return true;
}

public int Native_SetCelCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iCount = GetNativeCell(2);
	
	g_iCelCount[iClient] = iCount;
	
	return true;
}

public int Native_SetCelLimit(Handle hPlugin, int iNumParams)
{
	int iLimit = GetNativeCell(1);
	
	g_iCelLimit = iLimit;
	
	return true;
}

public int Native_SetNoKill(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	bool bNoKill = view_as<bool>(GetNativeCell(2));
	
	bNoKill ? SetEntProp(iClient, Prop_Data, "m_takedamage", 0, 1) : SetEntProp(iClient, Prop_Data, "m_takedamage", 2, 1);
	
	g_bNoKill[iClient] = bNoKill;
	
	return true;
}

public int Native_SetPlayer(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	g_bPlayer[iClient] = view_as<bool>(GetNativeCell(2));
	
	return true;
}

public int Native_SetPropCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iCount = GetNativeCell(2);
	
	g_iPropCount[iClient] = iCount;
	
	return true;
}

public int Native_SetPropLimit(Handle hPlugin, int iNumParams)
{
	int iLimit = GetNativeCell(1);
	
	g_iPropLimit = iLimit;
	
	return true;
}

public int Native_SpawnProp(Handle hPlugin, int iNumParams)
{
	char sAlias[64], sModel[64], sEntityType[64];
	float fAngles[3], fOrigin[3];
	int iClient = GetNativeCell(1), iColor[4];
	
	GetNativeString(2, sAlias, sizeof(sAlias));
	GetNativeString(3, sEntityType, sizeof(sEntityType));
	GetNativeString(4, sModel, sizeof(sModel));
	
	GetNativeArray(5, fAngles, 3);
	GetNativeArray(6, fOrigin, 3);
	
	iColor[0] = GetNativeCell(7);
	iColor[1] = GetNativeCell(8);
	iColor[2] = GetNativeCell(9);
	iColor[3] = GetNativeCell(10);
	
	int iProp = CreateEntityByName(sEntityType);
	
	if (iProp == -1)
	return -1;
	
	PrecacheModel(sModel);
	
	DispatchKeyValue(iProp, "model", sModel);
	DispatchKeyValue(iProp, "classname", "cel_physics");
	
	Entity_SetSolidType(iProp, SOLID_VPHYSICS);
	Entity_SetCollisionGroup(iProp, COLLISION_GROUP_NONE);
	
	if (StrEqual(sEntityType, "cycler"))
	{
		DispatchKeyValue(iProp, "classname", "cel_doll");
		DispatchKeyValue(iProp, "DefaultAnim", "ragdoll");
	}
	
	TeleportEntity(iProp, fOrigin, fAngles, NULL_VECTOR);
	
	DispatchSpawn(iProp);
	
	Cel_AddToPropCount(iClient);
	
	Cel_SetColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
	
	Cel_SetRainbow(iProp, false);
	
	Cel_SetEntity(iProp, true);
	
	Cel_SetMotion(iProp, false);
	
	Cel_SetOwner(iClient, iProp);
	
	Cel_SetPropName(iProp, sAlias);
	
	Cel_SetRenderFX(iProp, RENDERFX_NONE);
	
	Cel_SetSolid(iProp, true);
	
	Cel_SetBreakable(iProp, false);
	
	return iProp;
}

public int Native_SubFromCelCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	int iFinalCount = (g_iCelCount[iClient] -= 1);
	
	Cel_SetCelCount(iClient, iFinalCount);
	
	return true;
}

public int Native_SubFromPropCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	int iFinalCount = (g_iPropCount[iClient] -= 1);
	
	Cel_SetPropCount(iClient, iFinalCount);
	
	return true;
}
