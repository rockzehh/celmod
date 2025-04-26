//|CelMod| by rockzehh.

#pragma semicolon 1

#include <celmod>
#include <geoip>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma newdecls required

bool g_bLate;
bool g_bIsFlying[MAXPLAYERS + 1];
bool g_bNoKill[MAXPLAYERS + 1];
bool g_bPlayer[MAXPLAYERS + 1];

char g_sAuthID[MAXPLAYERS + 1][64];
char g_sDefaultInternetURL[PLATFORM_MAX_PATH];
char g_sDownloadPath[PLATFORM_MAX_PATH];
char g_sInternetURL[MAXENTITIES + 1][PLATFORM_MAX_PATH];
char g_sOverlayPath[PLATFORM_MAX_PATH];
char g_sSpawnDB[PLATFORM_MAX_PATH];

ConVar g_cvCelLimit;
ConVar g_cvDefaultInternetURL;
ConVar g_cvDownloadPath;
ConVar g_cvOverlayPath;
ConVar g_cvPropLimit;

Handle g_hOnCelSpawn;
Handle g_hOnEntityRemove;
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
	CreateNative("Cel_AddToCelCount", Native_AddToCelCount);
	CreateNative("Cel_AddToPropCount", Native_AddToPropCount);
	CreateNative("Cel_ChangeBeam", Native_ChangeBeam);
	CreateNative("Cel_CheckCelCount", Native_CheckCelCount);
	CreateNative("Cel_CheckPropCount", Native_CheckPropCount);
	CreateNative("Cel_CheckSpawnDB", Native_CheckSpawnDB);
	CreateNative("Cel_DownloadClientFiles", Native_DownloadClientFiles);
	CreateNative("Cel_GetAuthID", Native_GetAuthID);
	CreateNative("Cel_GetBeamMaterial", Native_GetBeamMaterial);
	CreateNative("Cel_GetCelCount", Native_GetCelCount);
	CreateNative("Cel_GetCelLimit", Native_GetCelLimit);
	CreateNative("Cel_GetCombinedCount", Native_GetCombinedCount);
	CreateNative("Cel_GetCrosshairHitOrigin", Native_GetCrosshairHitOrigin);
	CreateNative("Cel_GetHaloMaterial", Native_GetHaloMaterial);
	CreateNative("Cel_GetInternetURL", Native_GetInternetURL);
	CreateNative("Cel_GetNoKill", Native_GetNoKill);
	CreateNative("Cel_GetPhysicsMaterial", Native_GetPhysicsMaterial);
	CreateNative("Cel_GetPropCount", Native_GetPropCount);
	CreateNative("Cel_GetPropLimit", Native_GetPropLimit);
	CreateNative("Cel_IsPlayer", Native_IsPlayer);
	CreateNative("Cel_NotLooking", Native_NotLooking);
	CreateNative("Cel_NotYours", Native_NotYours);
	CreateNative("Cel_PlayChatMessageSound", Native_PlayChatMessageSound);
	CreateNative("Cel_PrintToChat", Native_PrintToChat);
	CreateNative("Cel_PrintToChatAll", Native_PrintToChatAll);
	CreateNative("Cel_RemovalBeam", Native_RemovalBeam);
	CreateNative("Cel_ReplyToCommand", Native_ReplyToCommand);
	CreateNative("Cel_SetAuthID", Native_SetAuthID);
	CreateNative("Cel_SetCelCount", Native_SetCelCount);
	CreateNative("Cel_SetCelLimit", Native_SetCelLimit);
	CreateNative("Cel_SetInternetURL", Native_SetInternetURL);
	CreateNative("Cel_SetNoKill", Native_SetNoKill);
	CreateNative("Cel_SetPlayer", Native_SetPlayer);
	CreateNative("Cel_SetPropCount", Native_SetPropCount);
	CreateNative("Cel_SetPropLimit", Native_SetPropLimit);
	CreateNative("Cel_SpawnDoor", Native_SpawnDoor);
	CreateNative("Cel_SpawnInternet", Native_SpawnInternet);
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
	description = "A fully customized building experience with roleplay, and extra features to enhance the standard gameplay.",
	version = CEL_VERSION,
	url = CEL_URL
};

public void OnLibraryAdded(const char[] sName)
{
	if (StrEqual(sName, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
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
	}
	
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
	
	AddCommandListener(Handle_Chat, "say");
	AddCommandListener(Handle_Chat, "say_team");
	
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
	
	g_hOnCelSpawn = CreateGlobalForward("Cel_OnCelSpawn", ET_Hook, Param_Cell, Param_Cell, Param_Cell);
	g_hOnEntityRemove = CreateGlobalForward("Cel_OnEntityRemove", ET_Hook, Param_Cell, Param_Cell, Param_Cell);
	g_hOnPropSpawn = CreateGlobalForward("Cel_OnPropSpawn", ET_Hook, Param_Cell, Param_Cell, Param_Cell);
	
	HookEvent("player_connect", Event_Connect, EventHookMode_Pre);
	HookEvent("player_death", Event_Death, EventHookMode_Post);
	HookEvent("player_disconnect", Event_Disconnect, EventHookMode_Pre);
	HookEvent("player_spawn", Event_Spawn, EventHookMode_Post);
	
	AddCommandListener(CL_Noclip, "noclip");
	
	RegConsoleCmd("dev_getpos", Dev_GetPos, "");
	
	RegAdminCmd("sm_setowner", Command_SetOwner, ADMFLAG_SLAY, "|CelMod| Sets the owner of the prop you are looking at.");
	
	RegConsoleCmd("sm_axis", Command_Axis, "|CelMod| Creates a marker to the player showing every axis.");
	RegConsoleCmd("sm_del", Command_Delete, "|CelMod| Removes the prop you are looking at.");
	RegConsoleCmd("sm_delete", Command_Delete, "|CelMod| Removes the prop you are looking at.");
	RegConsoleCmd("sm_door", Command_Door, "|CelMod| Spawns a working door cel.");
	RegConsoleCmd("sm_fly", Command_Fly, "|CelMod| Enables/disables noclip on the player.");
	RegConsoleCmd("sm_internet", Command_Internet, "|CelMod| Creates a working internet cel.");
	//RegConsoleCmd("sm_ladder", Command_Ladder, "|CelMod| Creates a working ladder cel.");
	//RegConsoleCmd("sm_light", Command_Light, "|CelMod| Creates a working light cel.");
	RegConsoleCmd("sm_mark", Command_Axis, "|CelMod| Creates a marker to the player showing every axis.");
	RegConsoleCmd("sm_marker", Command_Axis, "|CelMod| Creates a marker to the player showing every axis.");
	RegConsoleCmd("sm_nokill", Command_NoKill, "|CelMod| Enables/disables godmode on the player.");
	RegConsoleCmd("sm_p", Command_Spawn, "|CelMod| Spawns a prop by name.");
	RegConsoleCmd("sm_remove", Command_Delete, "|CelMod| Removes the prop you are looking at.");
	RegConsoleCmd("sm_s", Command_Spawn, "|CelMod| Spawns a prop by name.");
	RegConsoleCmd("sm_seturl", Command_SetURL, "|CelMod| Sets the url of the internet cel you are looking at.");
	RegConsoleCmd("sm_spawn", Command_Spawn, "|CelMod| Spawns a prop by name.");
	
	CreateConVar("celmod", "1", "Notifies the server that the plugin is running.");
	g_cvCelLimit = CreateConVar("cm_max_player_cels", "20", "Maxiumum number of cel entities a client is allowed.");
	g_cvDefaultInternetURL = CreateConVar("cm_default_internet_url", "https://github.com/rockzehh/celmod", "Default internet cel URL.");
	g_cvDownloadPath = CreateConVar("cm_download_list_path", "data/celmod/downloads.txt", "Path for the download list for clients.");
	g_cvPropLimit = CreateConVar("cm_max_player_props", "130", "Maxiumum number of props a player is allowed to spawn.");
	g_cvOverlayPath = CreateConVar("cm_overlay_material_path", "celmod/cm_overlay3.vmt", "Default CelMod overlay path.");
	CreateConVar("cm_version", CEL_VERSION, "The version of the plugin the server is running.");
	
	g_cvCelLimit.AddChangeHook(CM_OnConVarChanged);
	g_cvDefaultInternetURL.AddChangeHook(CM_OnConVarChanged);
	g_cvDownloadPath.AddChangeHook(CM_OnConVarChanged);
	g_cvOverlayPath.AddChangeHook(CM_OnConVarChanged);
	g_cvPropLimit.AddChangeHook(CM_OnConVarChanged);
	
	Cel_SetCelLimit(g_cvCelLimit.IntValue);
	g_cvDefaultInternetURL.GetString(g_sDefaultInternetURL, sizeof(g_sDefaultInternetURL));
	g_cvDownloadPath.GetString(g_sDownloadPath, sizeof(g_sDownloadPath));
	g_cvOverlayPath.GetString(g_sOverlayPath, sizeof(g_sOverlayPath));
	Cel_SetPropLimit(g_cvPropLimit.IntValue);
	
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") - FCVAR_CHEAT);
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
	} else if (cvConVar == g_cvDefaultInternetURL)
	{
		g_cvDefaultInternetURL.GetString(g_sDefaultInternetURL, sizeof(g_sDefaultInternetURL));
		PrintToServer("|CelMod| Default internet cel url updated to %s.", sNewValue);
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
public Action CL_Noclip(int iClient, const char[] sCommand, int iArgs)
{
	FakeClientCommand(iClient, "sm_fly");
	
	return Plugin_Handled;
}

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

public Action Command_Delete(int iClient, int iArgs)
{
	char sEntityType[32], sOption[32], sRemoveCount[64];
	int iRemoveCount = 0;
	
	GetCmdArg(1, sOption, sizeof(sOption));
	
	if (iArgs == 1)
	{
		if(StrContains(sOption, "all", false) !=-1)
		{
			for (int i = 0; i < GetMaxEntities(); i++)
			{
				if (Cel_CheckOwner(iClient, i) && Cel_IsEntity(i) && IsValidEdict(i))
				{
					Cel_GetEntityTypeName(Cel_GetEntityType(i), sEntityType, sizeof(sEntityType));
					
					(Cel_CheckEntityCatagory(i, ENTCATAGORY_PROP)) ? Cel_SubFromPropCount(iClient) : Cel_SubFromCelCount(iClient);
					
					Call_StartForward(g_hOnEntityRemove);
					
					Call_PushCell(i);
					Call_PushCell(iClient);
					Call_PushCell(view_as<int>(!Cel_CheckEntityCatagory(i, ENTCATAGORY_PROP)));
					
					Call_Finish();
					
					if (Cel_CheckEntityType(i, "effect"))
					{
						AcceptEntityInput(Cel_GetEffectAttachment(i), "TurnOff");
						AcceptEntityInput(Cel_GetEffectAttachment(i), "kill");
					}
					
					AcceptEntityInput(i, "kill");
					
					iRemoveCount++;
				}
			}
			
			Format(sRemoveCount, sizeof(sRemoveCount), "{green}%i{default} %s", iRemoveCount, iRemoveCount == 1 ? "entity" : "entities");
			
			Cel_ReplyToCommand(iClient, "%t", "RemoveAll", sRemoveCount);
			
			iRemoveCount = 0;
			
			return Plugin_Handled;
		}else if(StrContains(sOption, "land", false) !=-1)
		{
			Cel_ClearLand(iClient);
			
			Cel_ReplyToCommand(iClient, "%t", "LandCleared");
			
			return Plugin_Handled;
		}else{
			Cel_ReplyToCommand(iClient, "%t", "CMD_Remove");
			return Plugin_Handled;
		}
	}else{
		if (Cel_GetClientAimTarget(iClient) == -1)
		{
			Cel_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		int iProp = Cel_GetClientAimTarget(iClient);
		
		if (Cel_CheckOwner(iClient, iProp))
		{
			Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
			
			(Cel_CheckEntityCatagory(iProp, ENTCATAGORY_PROP)) ? Cel_SubFromPropCount(iClient) : Cel_SubFromCelCount(iClient);
			
			Call_StartForward(g_hOnEntityRemove);
			
			Call_PushCell(iProp);
			Call_PushCell(iClient);
			Call_PushCell(view_as<int>(!Cel_CheckEntityCatagory(iProp, ENTCATAGORY_PROP)));
			
			Call_Finish();
			
			if (Cel_CheckEntityType(iProp, "effect"))
			{
				AcceptEntityInput(Cel_GetEffectAttachment(iProp), "TurnOff");
				AcceptEntityInput(Cel_GetEffectAttachment(iProp), "kill");
			}
			
			Cel_RemovalBeam(iClient, iProp);
			
			Cel_DissolveEntity(iProp);
			
			Cel_ReplyToCommand(iClient, "%t", "Remove", sEntityType);
		} else {
			Cel_NotYours(iClient, iProp);
			return Plugin_Handled;
		}
	}
	
	return Plugin_Handled;
}

public Action Command_Door(int iClient, int iArgs)
{
	char sSkin[32];
	float fAngles[3], fOrigin[3];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Door");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sSkin, sizeof(sSkin));
	
	if (!Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxCelLimit", Cel_GetCelCount(iClient));
		return Plugin_Handled;
	}
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	int iDoor = Cel_SpawnDoor(iClient, sSkin, fAngles, fOrigin, 255, 255, 255, 255);
	
	Call_StartForward(g_hOnCelSpawn);
	
	Call_PushCell(iDoor);
	Call_PushCell(iClient);
	Call_PushCell(ENTTYPE_DOOR);
	
	Call_Finish();
	
	Cel_ReplyToCommand(iClient, "%t", "DoorSpawn");
	
	return Plugin_Handled;
}

public Action Command_Fly(int iClient, int iArgs)
{
	g_bIsFlying[iClient] = !g_bIsFlying[iClient];
	
	SetEntityMoveType(iClient, g_bIsFlying[iClient] ? MOVETYPE_NOCLIP : MOVETYPE_WALK);
	
	Cel_ReplyToCommand(iClient, "%t", "Flying", g_bIsFlying[iClient] ? "enabled" : "disabled");
	
	return Plugin_Handled;
}

public Action Command_Internet(int iClient, int iArgs)
{
	float fAngles[3], fOrigin[3];
	
	if (!Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxCelLimit", Cel_GetCelCount(iClient));
		return Plugin_Handled;
	}
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	int iInternet = Cel_SpawnInternet(iClient, g_sDefaultInternetURL, fAngles, fOrigin, 255, 255, 255, 255);
	
	Call_StartForward(g_hOnCelSpawn);
	
	Call_PushCell(iInternet);
	Call_PushCell(iClient);
	Call_PushCell(ENTTYPE_INTERNET);
	
	Call_Finish();
	
	Cel_ReplyToCommand(iClient, "%t", "InternetSpawn");
	
	return Plugin_Handled;
}

public Action Command_NoKill(int iClient, int iArgs)
{
	Cel_SetNoKill(iClient, !Cel_GetNoKill(iClient));
	
	Cel_ReplyToCommand(iClient, "%t", "NoKill", Cel_GetNoKill(iClient) ? "on" : "off");
	
	return Plugin_Handled;
}

public Action Command_SetOwner(int iClient, int iArgs)
{
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	char sEntityType[64], sNames[2][PLATFORM_MAX_PATH], sTarget[PLATFORM_MAX_PATH];
	int iProp = Cel_GetClientAimTarget(iClient);
	
	GetCmdArg(1, sTarget, sizeof(sTarget));
	
	GetClientName(iClient, sNames[0], sizeof(sNames[]));
	
	if (StrEqual(sTarget, ""))
	{
		Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
		
		Cel_SetOwner(iClient, iProp);
		
		Cel_ChangeBeam(iClient, iProp);
		
		Cel_ReplyToCommand(iClient, "%t", "SetOwnerClient", sEntityType, sNames[0]);
		
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
	
	Cel_ReplyToCommand(iClient, "%t", "SetOwnerClient", sEntityType, sNames[1]);
	Cel_ReplyToCommand(iTarget, "%t", "SetOwnerTarget", sNames[0], sEntityType, sNames[1]);
	
	return Plugin_Handled;
}

public Action Command_SetURL(int iClient, int iArgs)
{
	char sURL[PLATFORM_MAX_PATH];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_SetURL");
		return Plugin_Handled;
	}
	
	GetCmdArgString(sURL, sizeof(sURL));
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		if (Cel_CheckEntityType(iProp, "internet"))
		{
			Cel_SetInternetURL(iProp, sURL);
			
			Cel_ChangeBeam(iClient, iProp);
			
			Cel_ReplyToCommand(iClient, "%t", "SetURL");
			
			return Plugin_Handled;
		} else {
			Cel_ReplyToCommand(iClient, "%t", "OnlyOnInternetCels");
			return Plugin_Handled;
		}
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
}

public Action Command_Spawn(int iClient, int iArgs)
{
	char sAlias[64], sSpawnBuffer[2][128], sSpawnString[256];
	float fAngles[3], fOrigin[3];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Spawn");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlias, sizeof(sAlias));
	
	if (!Cel_CheckPropCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxPropLimit", Cel_GetPropCount(iClient));
		return Plugin_Handled;
	}
	
	if (Cel_CheckSpawnDB(sAlias, sSpawnString, sizeof(sSpawnString)))
	{
		ExplodeString(sSpawnString, "|", sSpawnBuffer, 2, sizeof(sSpawnBuffer[]));
		
		GetClientAbsAngles(iClient, fAngles);
		Cel_GetCrosshairHitOrigin(iClient, fOrigin);
		
		int iProp = Cel_SpawnProp(iClient, sAlias, sSpawnBuffer[0], sSpawnBuffer[1], fAngles, fOrigin, 255, 255, 255, 255);
		
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

public Action Handle_Chat(int iClient, char[] sCommand, int iArgs)
{
	char sPropAlias[64], sSpawnBuffer[2][128], sSpawnString[256];
	float fAngles[3], fOrigin[3];
	
	GetCmdArg(1, sPropAlias, sizeof(sPropAlias));
	
	ReplaceString(sPropAlias, sizeof(sPropAlias), "!", "");
	ReplaceString(sPropAlias, sizeof(sPropAlias), "/", "");
	
	if (Cel_CheckSpawnDB(sPropAlias, sSpawnString, sizeof(sSpawnString)))
	{
		if (!Cel_CheckPropCount(iClient))
		{
			Cel_ReplyToCommand(iClient, "%t", "MaxPropLimit", Cel_GetPropCount(iClient));
			return Plugin_Handled;
		}
		
		ExplodeString(sSpawnString, "|", sSpawnBuffer, 2, sizeof(sSpawnBuffer[]));
		
		GetClientAbsAngles(iClient, fAngles);
		Cel_GetCrosshairHitOrigin(iClient, fOrigin);
		
		int iProp = Cel_SpawnProp(iClient, sPropAlias, sSpawnBuffer[0], sSpawnBuffer[1], fAngles, fOrigin, 255, 255, 255, 255);
		
		Call_StartForward(g_hOnPropSpawn);
		
		Call_PushCell(iProp);
		Call_PushCell(iClient);
		Call_PushCell(Cel_GetEntityType(iProp));
		
		Call_Finish();
		
		Cel_ReplyToCommand(iClient, "%t", "SpawnProp", sPropAlias);
		
		return Plugin_Handled;
	} else if (IsChatTrigger())
	{
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
		if (Cel_CheckOwner(iClient, i))
		{
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
	
	Handle hTraceRay = TR_TraceRayFilterEx(fEyeOrigin, fEyeAngles, MASK_ALL, RayType_Infinite, Cel_FilterPlayer);
	
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

public int Native_GetInternetURL(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1), iMaxLength = GetNativeCell(3);
	
	SetNativeString(2, g_sInternetURL[iEntity], iMaxLength);
	
	return true;
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

public int Native_NotLooking(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	Cel_ReplyToCommand(iClient, "%t", "NotLooking");
	
	return true;
}

public int Native_NotYours(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iEntity = GetNativeCell(2);
	
	char sEntityType[32];
	
	Cel_GetEntityTypeName(Cel_GetEntityType(iEntity), sEntityType, sizeof(sEntityType));
	
	Cel_ReplyToCommand(iClient, "%t", "NotYours", sEntityType);
	
	return true;
}

public int Native_PlayChatMessageSound(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	ClientCommand(iClient, "play npc/stalker/stalker_footstep_%s1", GetRandomInt(0, 1) ? "left" : "right");
	
	return true;
}

public int Native_PrintToChat(Handle hPlugin, int iNumParams)
{
	char sBuffer[MAX_MESSAGE_LENGTH];
	
	int iPlayer = GetNativeCell(1), iWritten;
	
	FormatNativeString(0, 2, 3, sizeof(sBuffer), iWritten, sBuffer);
	
	CPrintToChat(iPlayer, "{blue}|CelMod|{default} %s", sBuffer);
	
	Cel_PlayChatMessageSound(iPlayer);
	
	return true;
}

public int Native_PrintToChatAll(Handle hPlugin, int iNumParams)
{
	char sBuffer[MAX_MESSAGE_LENGTH];
	
	int iWritten;
	
	FormatNativeString(0, 1, 2, sizeof(sBuffer), iWritten, sBuffer);
	
	CPrintToChatAll("{blue}|CM|{default} %s", sBuffer);
	
	return true;
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

public int Native_ReplyToCommand(Handle hPlugin, int iNumParams)
{
	char sBuffer[MAX_MESSAGE_LENGTH];
	
	int iPlayer = GetNativeCell(1), iWritten;
	
	FormatNativeString(0, 2, 3, sizeof(sBuffer), iWritten, sBuffer);
	
	ReplaceString(sBuffer, sizeof(sBuffer), "[tag]", GetCmdReplySource() == SM_REPLY_TO_CONSOLE ? "sm_" : "!", true);
	
	if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		CRemoveTags(sBuffer, sizeof(sBuffer));
		
		PrintToConsole(iPlayer, "|CelMod| %s", sBuffer);
	} else {
		CPrintToChat(iPlayer, "{blue}|CelMod|{default} %s", sBuffer);
		
		Cel_PlayChatMessageSound(iPlayer);
	}
	
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

public int Native_SetInternetURL(Handle hPlugin, int iNumParams)
{
	char sURL[PLATFORM_MAX_PATH];
	
	int iEntity = GetNativeCell(1);
	
	GetNativeString(2, sURL, sizeof(sURL));
	
	Cel_CheckInputURL(sURL, g_sInternetURL[iEntity], sizeof(g_sInternetURL[]));
	
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

public int Native_SpawnDoor(Handle hPlugin, int iNumParams)
{
	char sAngles[16], sSkin[16];
	float fAngles[3], fOrigin[3];
	int iClient = GetNativeCell(1), iColor[4];
	
	GetNativeString(2, sSkin, sizeof(sSkin));
	
	GetNativeArray(3, fAngles, 3);
	GetNativeArray(4, fOrigin, 3);
	
	iColor[0] = GetNativeCell(5);
	iColor[1] = GetNativeCell(6);
	iColor[2] = GetNativeCell(7);
	iColor[3] = GetNativeCell(8);
	
	Format(sAngles, sizeof(sAngles), "%f %f %f", fAngles[0], fAngles[1], fAngles[2]);
	
	int iDoor = CreateEntityByName("prop_door_rotating");
	
	if (iDoor == -1)
	return -1;
	
	PrecacheModel("models/props_c17/door01_left.mdl");
	
	DispatchKeyValue(iDoor, "ajarangles", sAngles);
	DispatchKeyValue(iDoor, "model", "models/props_c17/door01_left.mdl");
	DispatchKeyValue(iDoor, "classname", "cel_door");
	DispatchKeyValue(iDoor, "skin", sSkin);
	DispatchKeyValue(iDoor, "distance", "90");
	DispatchKeyValue(iDoor, "speed", "100");
	DispatchKeyValue(iDoor, "returndelay", "-1");
	DispatchKeyValue(iDoor, "dmg", "-20");
	DispatchKeyValue(iDoor, "opendir", "0");
	DispatchKeyValue(iDoor, "spawnflags", "8192");
	DispatchKeyValue(iDoor, "OnFullyOpen", "!caller,Close,,3,-1");
	DispatchKeyValue(iDoor, "hardware", "1");
	
	fOrigin[2] += 54;
	
	TeleportEntity(iDoor, fOrigin, NULL_VECTOR, NULL_VECTOR);
	
	DispatchSpawn(iDoor);
	
	Cel_AddToCelCount(iClient);
	
	Cel_SetColor(iDoor, iColor[0], iColor[1], iColor[2], iColor[3]);
	
	Cel_SetEntity(iDoor, true);
	
	Cel_SetMotion(iDoor, false);
	
	Cel_SetOwner(iClient, iDoor);
	
	Cel_SetSolid(iDoor, true);
	
	Cel_SetRenderFX(iDoor, RENDERFX_NONE);
	
	return iDoor;
}

public int Native_SpawnInternet(Handle hPlugin, int iNumParams)
{
	char sURL[PLATFORM_MAX_PATH];
	float fAngles[3], fOrigin[3];
	int iClient = GetNativeCell(1), iColor[4];
	
	GetNativeString(2, sURL, sizeof(sURL));
	
	GetNativeArray(3, fAngles, 3);
	GetNativeArray(4, fOrigin, 3);
	
	iColor[0] = GetNativeCell(5);
	iColor[1] = GetNativeCell(6);
	iColor[2] = GetNativeCell(7);
	iColor[3] = GetNativeCell(8);
	
	int iInternet = CreateEntityByName("prop_physics_override");
	
	if (iInternet == -1)
	return -1;
	
	PrecacheModel("models/props_lab/monitor02.mdl");
	
	DispatchKeyValue(iInternet, "model", "models/props_lab/monitor02.mdl");
	DispatchKeyValue(iInternet, "classname", "cel_internet");
	DispatchKeyValue(iInternet, "skin", "1");
	
	TeleportEntity(iInternet, fOrigin, fAngles, NULL_VECTOR);
	
	DispatchSpawn(iInternet);
	
	Cel_AddToCelCount(iClient);
	
	Cel_SetColor(iInternet, iColor[0], iColor[1], iColor[2], iColor[3]);
	
	Cel_SetEntity(iInternet, true);
	
	Cel_SetMotion(iInternet, false);
	
	Cel_SetInternetURL(iInternet, sURL);
	
	Cel_SetOwner(iClient, iInternet);
	
	Cel_SetSolid(iInternet, true);
	
	Cel_SetRenderFX(iInternet, RENDERFX_NONE);
	
	SDKHook(iInternet, SDKHook_UsePost, Hook_InternetUse);
	
	return iInternet;
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
	
	TeleportEntity(iProp, fOrigin, fAngles, NULL_VECTOR);
	
	DispatchSpawn(iProp);
	
	Cel_AddToPropCount(iClient);
	
	Cel_SetColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
	
	Cel_SetEntity(iProp, true);
	
	Cel_SetMotion(iProp, false);
	
	Cel_SetOwner(iClient, iProp);
	
	Cel_SetPropName(iProp, sAlias);
	
	Cel_SetRenderFX(iProp, RENDERFX_NONE);
	
	if (!StrEqual(sEntityType, "cycler"))
	Cel_SetSolid(iProp, true);
	
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

//Stocks:
public bool Cel_FilterPlayer(int iEntity, int iContentsMask)
{
	return iEntity > MaxClients;
}
