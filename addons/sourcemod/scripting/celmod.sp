//|CelMod| by rockzehh.

#pragma semicolon 1

#include <celmod>
#include <geoip>
#include <morecolors>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <updater>

#pragma newdecls required

bool g_bEntity[MAXENTS + 1];
bool g_bFrozen[MAXENTS + 1];
bool g_bLate;
bool g_bNoKill[MAXPLAYERS + 1];
bool g_bPlayer[MAXPLAYERS + 1];
bool g_bSolid[MAXENTS + 1];

char g_sAuthID[MAXPLAYERS + 1][32];
char g_sColorDB[PLATFORM_MAX_PATH];
char g_sDefaultInternetURL[PLATFORM_MAX_PATH];
char g_sInternetURL[MAXENTS + 1][PLATFORM_MAX_PATH];
char g_sMap[PLATFORM_MAX_PATH];
char g_sPropName[MAXENTS + 1][64];
char g_sSpawnDB[PLATFORM_MAX_PATH];

ConVar g_cvCelLimit;
ConVar g_cvDefaultInternetURL;
ConVar g_cvLightLimit;
ConVar g_cvPropLimit;

Handle g_hOnCelSpawn;
Handle g_hOnEntityRemove;
Handle g_hOnPropSpawn;

int g_iBeam;
int g_iCelCount[MAXPLAYERS + 1];
int g_iCelLimit;
int g_iColor[MAXENTS + 1][4];
int g_iEntityDissolve;
int g_iHalo;
int g_iLightCount;
int g_iLightLimit;
int g_iOwner[MAXENTS + 1];
int g_iPhys;
int g_iPropCount[MAXPLAYERS + 1];
int g_iPropLimit;

//Colors:
int g_iBlue[4] =  { 0, 0, 255, 175 };
int g_iGray[4] =  { 255, 255, 255, 300 };
int g_iGreen[4] =  { 0, 255, 0, 175 };
int g_iOrange[4] =  { 255, 128, 0, 175 };
int g_iRed[4] =  { 255, 0, 0, 175 };
int g_iWhite[4] =  { 255, 255, 255, 175 };
int g_iYellow[4] =  { 255, 255, 0, 175 };

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_AddToCelCount", Native_AddToCelCount);
	//CreateNative("Cel_AddToLightCount", Native_AddToCelCount);
	CreateNative("Cel_AddToPropCount", Native_AddToPropCount);
	CreateNative("Cel_ChangeBeam", Native_ChangeBeam);
	CreateNative("Cel_ChangePositionRelativeToOrigin", Native_ChangePositionRelativeToOrigin);
	CreateNative("Cel_CheckCelCount", Native_CheckCelCount);
	CreateNative("Cel_CheckColorDB", Native_CheckColorDB);
	CreateNative("Cel_CheckEntityCatagory", Native_CheckEntityCatagory);
	CreateNative("Cel_CheckEntityType", Native_CheckEntityType);
	//CreateNative("Cel_CheckLightCount", Native_CheckLightCount);
	CreateNative("Cel_CheckOwner", Native_CheckOwner);
	CreateNative("Cel_CheckPropCount", Native_CheckPropCount);
	CreateNative("Cel_CheckSpawnDB", Native_CheckSpawnDB);
	CreateNative("Cel_DissolveEntity", Native_DissolveEntity);
	CreateNative("Cel_GetAuthID", Native_GetAuthID);
	CreateNative("Cel_GetBeamMaterial", Native_GetBeamMaterial);
	CreateNative("Cel_GetClientAimTarget", Native_GetClientAimTarget);
	CreateNative("Cel_GetCelCount", Native_GetCelCount);
	CreateNative("Cel_GetCelLimit", Native_GetCelLimit);
	CreateNative("Cel_GetColor", Native_GetColor);
	CreateNative("Cel_GetCrosshairHitOrigin", Native_GetCrosshairHitOrigin);
	CreateNative("Cel_GetEntityCatagory", Native_GetEntityCatagory);
	CreateNative("Cel_GetEntityCatagoryName", Native_GetEntityCatagoryName);
	CreateNative("Cel_GetEntityType", Native_GetEntityType);
	CreateNative("Cel_GetEntityTypeFromName", Native_GetEntityTypeFromName);
	CreateNative("Cel_GetEntityTypeName", Native_GetEntityTypeName);
	CreateNative("Cel_GetHaloMaterial", Native_GetHaloMaterial);
	CreateNative("Cel_GetInternetURL", Native_GetInternetURL);
	CreateNative("Cel_GetNoKill", Native_GetNoKill);
	CreateNative("Cel_GetOwner", Native_GetOwner);
	CreateNative("Cel_GetPhysicsMaterial", Native_GetPhysicsMaterial);
	CreateNative("Cel_GetPropCount", Native_GetPropCount);
	CreateNative("Cel_GetPropLimit", Native_GetPropLimit);
	CreateNative("Cel_GetPropName", Native_GetPropName);
	CreateNative("Cel_IsEntity", Native_IsEntity);
	CreateNative("Cel_IsFrozen", Native_IsFrozen);
	CreateNative("Cel_IsPlayer", Native_IsPlayer);
	CreateNative("Cel_IsSolid", Native_IsSolid);
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
	CreateNative("Cel_SetColor", Native_SetColor);
	CreateNative("Cel_SetEntity", Native_SetEntity);
	CreateNative("Cel_SetFrozen", Native_SetFrozen);
	CreateNative("Cel_SetInternetURL", Native_SetInternetURL);
	CreateNative("Cel_SetNoKill", Native_SetNoKill);
	CreateNative("Cel_SetOwner", Native_SetOwner);
	CreateNative("Cel_SetPlayer", Native_SetPlayer);
	CreateNative("Cel_SetPropCount", Native_SetPropCount);
	CreateNative("Cel_SetPropLimit", Native_SetPropLimit);
	CreateNative("Cel_SetPropName", Native_SetPropName);
	CreateNative("Cel_SetSolid", Native_SetSolid);
	CreateNative("Cel_SpawnDoor", Native_SpawnDoor);
	CreateNative("Cel_SpawnInternet", Native_SpawnInternet);
	//CreateNative("Cel_SpawnLight", Native_SpawnLight);
	CreateNative("Cel_SpawnProp", Native_SpawnProp);
	CreateNative("Cel_SubFromCelCount", Native_SubFromCelCount);
	//CreateNative("Cel_SubFromLightCount", Native_SubFromLightCount);
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
	url = "https://github.com/rockzehh/celmod"
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
	BuildPath(Path_SM, g_sColorDB, sizeof(g_sColorDB), "data/celmod/colors.txt");
	if (!FileExists(g_sColorDB))
	{
		ThrowError("|CelMod| %t", "FileNotFound", g_sColorDB);
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
	
	RegAdminCmd("sm_setowner", Command_SetOwner, ADMFLAG_SLAY, "|CelMod| Sets the owner of the prop you are looking at.");
	RegConsoleCmd("sm_alpha", Command_Alpha, "|CelMod| Changes the transparency on the prop you are looking at.");
	RegConsoleCmd("sm_amt", Command_Alpha, "|CelMod| Changes the transparency on the prop you are looking at.");
	RegConsoleCmd("sm_axis", Command_Axis, "|CelMod| Creates a marker to the player showing every axis.");
	RegConsoleCmd("sm_color", Command_Color, "|CelMod| Colors the prop you are looking at.");
	RegConsoleCmd("sm_del", Command_Delete, "|CelMod| Removes the prop you are looking at.");
	RegConsoleCmd("sm_delete", Command_Delete, "|CelMod| Removes the prop you are looking at.");
	RegConsoleCmd("sm_door", Command_Door, "|CelMod| Spawns a working door cel.");
	RegConsoleCmd("sm_freeze", Command_FreezeIt, "|CelMod| Freezes the prop you are looking at.");
	RegConsoleCmd("sm_freezeit", Command_FreezeIt, "|CelMod| Freezes the prop you are looking at.");
	RegConsoleCmd("sm_internet", Command_Internet, "|CelMod| Creates a working internet cel.");
	RegConsoleCmd("sm_mark", Command_Axis, "|CelMod| Creates a marker to the player showing every axis.");
	RegConsoleCmd("sm_marker", Command_Axis, "|CelMod| Creates a marker to the player showing every axis.");
	RegConsoleCmd("sm_nokill", Command_NoKill, "|CelMod| Enables/disables godmode on the player.");
	RegConsoleCmd("sm_p", Command_Spawn, "|CelMod| Spawns a prop by name.");
	RegConsoleCmd("sm_paint", Command_Color, "|CelMod| Colors the prop you are looking at.");
	RegConsoleCmd("sm_pmove", Command_SMove, "|CelMod| Moves the prop you are looking at on it's origin.");
	RegConsoleCmd("sm_remove", Command_Delete, "|CelMod| Removes the prop you are looking at.");
	RegConsoleCmd("sm_rotate", Command_Rotate, "|CelMod| Rotates the prop you are looking at.");
	RegConsoleCmd("sm_s", Command_Spawn, "|CelMod| Spawns a prop by name.");
	RegConsoleCmd("sm_seturl", Command_SetURL, "|CelMod| Sets the url of the internet cel you are looking at.");
	RegConsoleCmd("sm_smove", Command_SMove, "|CelMod| Moves the prop you are looking at on it's origin.");
	RegConsoleCmd("sm_solid", Command_Solid, "|CelMod| Enables/disables solidicity on the prop you are looking at.");
	RegConsoleCmd("sm_spawn", Command_Spawn, "|CelMod| Spawns a prop by name.");
	RegConsoleCmd("sm_stand", Command_Stand, "|CelMod| Resets the angles on the prop you are looking at.");
	RegConsoleCmd("sm_straight", Command_Stand, "|CelMod| Resets the angles on the prop you are looking at.");
	RegConsoleCmd("sm_straighten", Command_Stand, "|CelMod| Resets the angles on the prop you are looking at.");
	RegConsoleCmd("sm_unfreeze", Command_UnfreezeIt, "|CelMod| Unfreezes the prop you are looking at.");
	RegConsoleCmd("sm_unfreezeit", Command_UnfreezeIt, "|CelMod| Unfreezes the prop you are looking at.");
	
	CreateConVar("celmod", "1", "Notifies the server that the plugin is running.");
	g_cvCelLimit = CreateConVar("cm_max_player_cels", "20", "Maxiumum number of cel entities a client is allowed.");
	g_cvDefaultInternetURL = CreateConVar("cm_default_internet_url", "https://github.com/rockzehh/celmod", "Default internet cel URL.");
	g_cvPropLimit = CreateConVar("cm_max_player_props", "130", "Maxiumum number of props a player is allowed to spawn.");
	CreateConVar("cm_version", CEL_VERSION, "The version of the plugin the server is running.");
	
	g_cvCelLimit.AddChangeHook(CM_OnConVarChanged);
	g_cvDefaultInternetURL.AddChangeHook(CM_OnConVarChanged);
	g_cvPropLimit.AddChangeHook(CM_OnConVarChanged);
	
	Cel_SetCelLimit(g_cvCelLimit.IntValue);
	g_cvDefaultInternetURL.GetString(g_sDefaultInternetURL, sizeof(g_sDefaultInternetURL));
	Cel_SetPropLimit(g_cvPropLimit.IntValue);
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
			//ClientCommand(i, "play npc/metropolice/vo/on1.wav");
			EmitSoundToClient(i, "play npc/metropolice/vo/on1.wav", i, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
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
}

public void OnClientDisconnect(int iClient)
{
	char sClient[128];
	
	GetClientName(iClient, sClient, sizeof(sClient));
	
	Cel_SetCelCount(iClient, 0);
	Cel_SetNoKill(iClient, false);
	Cel_SetPlayer(iClient, false);
	Cel_SetPropCount(iClient, 0);
	
	CPrintToChatAll("{red}[-]{default} %t", "Disconnecting", sClient);
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			//ClientCommand(i, "play npc/metropolice/vo/off1.wav");
			EmitSoundToClient(i, "play npc/metropolice/vo/off1.wav", i, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}
	}
}

public Action OnGetGameDescription(char sGameDesc[64])
{
	char sGameInfo[64];
	
	Format(sGameInfo, sizeof(sGameInfo), "|CelMod|");
	
	strcopy(sGameDesc, sizeof(sGameDesc), sGameInfo);
	return Plugin_Changed;
}

public void OnMapStart()
{
	g_iBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_iEntityDissolve = CreateEntityByName("env_entity_dissolver");
	g_iHalo = PrecacheModel("materials/sprites/halo01.vmt", true);
	g_iPhys = PrecacheModel("materials/sprites/physbeam.vmt", true);
	
	DispatchKeyValue(g_iEntityDissolve, "target", "deleted");
	DispatchKeyValue(g_iEntityDissolve, "magnitude", "50");
	DispatchKeyValue(g_iEntityDissolve, "dissolvetype", "3");
	
	DispatchSpawn(g_iEntityDissolve);
	
	DispatchKeyValue(g_iEntityDissolve, "classname", "celmod_entity_dissolver");
}

public void OnMapEnd()
{
	g_iBeam = -1;
	g_iEntityDissolve = -1;
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
	} else if (cvConVar == g_cvPropLimit) {
		Cel_SetPropLimit(StringToInt(sNewValue));
		PrintToServer("|CelMod| Prop limit updated to %i.", StringToInt(sNewValue));
	}
}

//Commands:
public Action Command_Alpha(int iClient, int iArgs)
{
	char sAlpha[16], sEntityType[32], sOption[32];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Alpha");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlpha, sizeof(sAlpha));
	
	int iAlpha = StringToInt(sAlpha) < 50 ? 255 : StringToInt(sAlpha);
	
	if (iArgs > 1)
	{
		GetCmdArg(2, sOption, sizeof(sOption));
		
		if(StrContains(sOption, "all", false) !=-1)
		{
			for (int i = 0; i < GetMaxEntities(); i++)
			{
				if (Cel_CheckOwner(iClient, i) && Cel_IsEntity(i) && IsValidEdict(i))
				{
					Cel_SetColor(i, -1, -1, -1, iAlpha);
					if (Cel_CheckEntityType(i, "effect"))
					Cel_SetColor(Cel_GetEffectAttachment(i), -1, -1, -1, iAlpha);
				}
			}
			
			Cel_ReplyToCommand(iClient, "%t", "SetAllTransparency", iAlpha);
		}else{
			Cel_ReplyToCommand(iClient, "%t", "CMD_Alpha");
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
			
			Cel_SetColor(iProp, -1, -1, -1, iAlpha);
			if (Cel_CheckEntityType(iProp, "effect"))
			Cel_SetColor(Cel_GetEffectAttachment(iProp), -1, -1, -1, iAlpha);
			
			Cel_ChangeBeam(iClient, iProp);
			
			Cel_ReplyToCommand(iClient, "%t", "SetTransparency", sEntityType, iAlpha);
		} else {
			Cel_NotYours(iClient, iProp);
			return Plugin_Handled;
		}	
	}
	
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

public Action Command_Color(int iClient, int iArgs)
{
	char sColor[64], sColorBuffer[3][6], sColorString[16], sEntityType[32], sOption[32];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Color");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sColor, sizeof(sColor));
	
	if (iArgs > 1)
	{
		GetCmdArg(2, sOption, sizeof(sOption));
		
		if (Cel_CheckColorDB(sColor, sColorString, sizeof(sColorString)))
		{
			if(StrContains(sOption, "all", false) !=-1)
			{
				for (int i = 0; i < GetMaxEntities(); i++)
				{
					if (Cel_CheckOwner(iClient, i) && Cel_IsEntity(i) && IsValidEdict(i))
					{
						ExplodeString(sColorString, "^", sColorBuffer, 3, sizeof(sColorBuffer[]));
						
						Cel_GetEntityTypeName(Cel_GetEntityType(i), sEntityType, sizeof(sEntityType));
						
						Cel_SetColor(i, StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
						
						if (Cel_CheckEntityType(i, "effect"))
						Cel_SetColor(Cel_GetEffectAttachment(i), StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
					}
				}
				Cel_ReplyToCommand(iClient, "%t", "SetAllColor", sColor);
			}else if(StrContains(sOption, "hud", false) !=-1)
			{
				ExplodeString(sColorString, "^", sColorBuffer, 3, sizeof(sColorBuffer[]));
				
				Cel_SetHudColor(iClient, StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
				
				Cel_ReplyToCommand(iClient, "%t", "SetHudColor", sColor);
			}else{
				Cel_ReplyToCommand(iClient, "%t", "CMD_Color");
				return Plugin_Handled;
			}
		} else {
			Cel_ReplyToCommand(iClient, "%t", "ColorNotFound", sColor);
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
			if (Cel_CheckColorDB(sColor, sColorString, sizeof(sColorString)))
			{
				ExplodeString(sColorString, "^", sColorBuffer, 3, sizeof(sColorBuffer[]));
				
				Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
				
				Cel_SetColor(iProp, StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
				if (Cel_CheckEntityType(iProp, "effect"))
				Cel_SetColor(Cel_GetEffectAttachment(iProp), StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
				
				Cel_ChangeBeam(iClient, iProp);
				
				Cel_ReplyToCommand(iClient, "%t", "SetColor", sEntityType, sColor);
			} else {
				Cel_ReplyToCommand(iClient, "%t", "ColorNotFound", sColor);
				return Plugin_Handled;
			}
		} else {
			Cel_NotYours(iClient, iProp);
			return Plugin_Handled;
		}
		
		return Plugin_Handled;
	}
	
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
					AcceptEntityInput(Cel_GetEffectAttachment(i), "TurnOff");
					
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
			
			Cel_ReplyToCommand(iClient, "Land cleared.");
			
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
			AcceptEntityInput(Cel_GetEffectAttachment(iProp), "TurnOff");
			
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

public Action Command_FreezeIt(int iClient, int iArgs)
{
	char sEntityType[32];
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
		
		if (Cel_CheckEntityType(iProp, "door"))
		{
			Cel_ReplyToCommand(iClient, "%t", "DoorLock");
			
			AcceptEntityInput(iProp, "lock");
		} else {
			Cel_ReplyToCommand(iClient, "%t", "DisableMotion", sEntityType);
			
			Cel_SetFrozen(iProp, true);
		}
		
		Cel_ChangeBeam(iClient, iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
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

public Action Command_Rotate(int iClient, int iArgs)
{
	char sX[32], sY[32], sZ[32];
	float fAngles[3], fOrigin[3], fPropAngles[3];
	
	if (iArgs < 3)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Rotate");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sX, sizeof(sX));
	GetCmdArg(2, sY, sizeof(sY));
	GetCmdArg(3, sZ, sizeof(sZ));
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityOrigin(iProp, fOrigin);
		Cel_GetEntityAngles(iProp, fPropAngles);
		
		fAngles[0] = fPropAngles[0] += StringToFloat(sX);
		fAngles[1] = fPropAngles[1] += StringToFloat(sY);
		fAngles[2] = fPropAngles[2] += StringToFloat(sZ);
		
		if (Cel_CheckEntityType(iProp, "door"))
		{
			DispatchKeyValueVector(iProp, "angles", fAngles);
		} else {
			TeleportEntity(iProp, NULL_VECTOR, fAngles, NULL_VECTOR);
		}
		
		TE_SetupBeamRingPoint(fOrigin, 0.0, 15.0, Cel_GetBeamMaterial(), Cel_GetHaloMaterial(), 0, 15, 0.5, 3.0, 0.0, g_iOrange, 10, 0); TE_SendToAll();
		
		PrecacheSound("buttons/lever7.wav");
		
		EmitSoundToAll("buttons/lever7.wav", iProp, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
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

public Action Command_SMove(int iClient, int iArgs)
{
	char sX[32], sY[32], sZ[32];
	float fOrigin[3], fPropOrigin[3];
	
	if (iArgs < 3)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_SMove");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sX, sizeof(sX));
	GetCmdArg(2, sY, sizeof(sY));
	GetCmdArg(3, sZ, sizeof(sZ));
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityOrigin(iProp, fPropOrigin);
		
		fOrigin[0] = fPropOrigin[0] += StringToFloat(sX);
		fOrigin[1] = fPropOrigin[1] += StringToFloat(sY);
		fOrigin[2] = fPropOrigin[2] += StringToFloat(sZ);
		
		TeleportEntity(iProp, fOrigin, NULL_VECTOR, NULL_VECTOR);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Spawn(int iClient, int iArgs)
{
	char sAlias[64], sSpawnBuffer[2][128], sSpawnString[256];
	float fAngles[3], fOrigin[3];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]spawn{default} <prop name>");
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
		ExplodeString(sSpawnString, "^", sSpawnBuffer, 2, sizeof(sSpawnBuffer[]));
		
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

public Action Command_Solid(int iClient, int iArgs)
{
	char sEntityType[128];
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
		
		if (Cel_CheckEntityType(iProp, "cycler"))
		{
			Cel_ReplyToCommand(iClient, "%t", "CantUseCommand-Prop");
			return Plugin_Handled;
		}
		
		Cel_SetSolid(iProp, !Cel_IsSolid(iProp));
		
		Cel_ReplyToCommand(iClient, "%t", "SetSolidicity", Cel_IsSolid(iProp) ? "on" : "off", sEntityType);
		
		Cel_ChangeBeam(iClient, iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Stand(int iClient, int iArgs)
{
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		TeleportEntity(iProp, NULL_VECTOR, g_fZero, NULL_VECTOR);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_UnfreezeIt(int iClient, int iArgs)
{
	char sEntityType[32];
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
		
		if (Cel_CheckEntityType(iProp, "door"))
		{
			Cel_ReplyToCommand(iClient, "%t", "DoorUnlock");
			
			AcceptEntityInput(iProp, "unlock");
		} else {
			Cel_ReplyToCommand(iClient, "%t", "EnableMotion", sEntityType);
			
			Cel_SetFrozen(iProp, false);
		}
		
		Cel_ChangeBeam(iClient, iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Handle_Chat(int iClient, char[] sCommand, int iArgs)
{
	if (IsChatTrigger())
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
	
	PrintToServer("Removing Props");
	
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
	
	int iCount = Cel_GetCelCount(iClient), iFinalCount = iCount += 1;
	
	Cel_SetCelCount(iClient, iFinalCount);
	
	return true;
}

public int Native_AddToPropCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	int iCount = Cel_GetPropCount(iClient), iFinalCount = iCount += 1;
	
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

public int Native_ChangePositionRelativeToOrigin(Handle hPlugin, int iNumParams)
{
	
	return true;
}

public int Native_CheckCelCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	return (Cel_GetCelCount(iClient) >= Cel_GetCelLimit()) ? false : true;
}

public int Native_CheckColorDB(Handle hPlugin, int iNumParams)
{
	int iMaxLength = GetNativeCell(3);
	
	char sColor[64], sColorLine[32];
	
	GetNativeString(1, sColor, sizeof(sColor));
	
	KeyValues kvColors = new KeyValues("Colors");
	
	kvColors.ImportFromFile(g_sColorDB);
	
	kvColors.JumpToKey("RGB", false);
	
	kvColors.GetString(sColor, sColorLine, iMaxLength, "null");
	
	kvColors.Rewind();
	
	delete kvColors;
	
	SetNativeString(2, sColorLine, iMaxLength);
	
	return (StrEqual(sColorLine, "null")) ? false : true;
}

public int Native_CheckOwner(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iEntity = GetNativeCell(2);
	
	return (Cel_GetOwner(iEntity) == iClient) ? true : false;
}

public int Native_CheckPropCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	return (Cel_GetPropCount(iClient) >= Cel_GetPropLimit()) ? false : true;
}

public int Native_CheckEntityCatagory(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return (Cel_GetEntityCatagory(iEntity) == view_as<EntityCatagory>(GetNativeCell(2))) ? true : false;
}

public int Native_CheckEntityType(Handle hPlugin, int iNumParams)
{
	char sPropCheck[PLATFORM_MAX_PATH];
	
	int iEntity = GetNativeCell(1);
	
	GetNativeString(2, sPropCheck, sizeof(sPropCheck));
	
	return (Cel_GetEntityType(iEntity) == Cel_GetEntityTypeFromName(sPropCheck)) ? true : false;
}

public int Native_CheckSpawnDB(Handle hPlugin, int iNumParams)
{
	int iMaxLength = GetNativeCell(3);
	
	char sAlias[64], sSpawnString[128];
	
	GetNativeString(1, sAlias, sizeof(sAlias));
	
	KeyValues kvProps = new KeyValues("Props");
	
	kvProps.ImportFromFile(g_sSpawnDB);
	
	kvProps.JumpToKey("Default", false);
	
	kvProps.GetString(sAlias, sSpawnString, iMaxLength, "null");
	
	kvProps.Rewind();
	
	delete kvProps;
	
	SetNativeString(2, sSpawnString, iMaxLength);
	
	return (StrEqual(sSpawnString, "null")) ? false : true;
}

public int Native_DissolveEntity(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	DispatchKeyValue(iEntity, "classname", "deleted");
	
	AcceptEntityInput(g_iEntityDissolve, "dissolve");
	
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

public int Native_GetClientAimTarget(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		return -1;
	}
	
	int iTarget = GetClientAimTarget(iClient, false);
	
	return (Cel_IsEntity(iTarget)) ? iTarget : -1;
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

public int Native_GetColor(Handle hPlugin, int iNumParams)
{
	int iColor[4];
	int iEntity = GetNativeCell(1);
	
	if (g_iColor[iEntity][0] == 0 && g_iColor[iEntity][1] == 0 && g_iColor[iEntity][2] == 0 && g_iColor[iEntity][3] == 0)
	{
		GetEntityRenderColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
		Cel_SetColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
	}
	
	iColor = g_iColor[iEntity];
	
	SetNativeArray(2, iColor, 4);
	
	return true;
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

public int Native_GetEntityCatagory(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	EntityType etEntityType = Cel_GetEntityType(iEntity);
	
	if (etEntityType == ENTTYPE_DOOR || etEntityType == ENTTYPE_EFFECT || etEntityType == ENTTYPE_INTERNET)
	{
		return view_as<int>(ENTCATAGORY_CEL);
	} else if (etEntityType == ENTTYPE_CYCLER || etEntityType == ENTTYPE_DYNAMIC || etEntityType == ENTTYPE_PHYSICS)
	{
		return view_as<int>(ENTCATAGORY_PROP);
	} else {
		return view_as<int>(ENTCATAGORY_UNKNOWN);
	}
}

public int Native_GetEntityCatagoryName(Handle hPlugin, int iNumParams)
{
	char sEntityCatagory[PLATFORM_MAX_PATH];
	int iMaxLength = GetNativeCell(3);
	
	switch (view_as<EntityCatagory>(GetNativeCell(1)))
	{
		case ENTCATAGORY_CEL:
		{
			Format(sEntityCatagory, sizeof(sEntityCatagory), "cel entity");
		}
		case ENTCATAGORY_PROP:
		{
			Format(sEntityCatagory, sizeof(sEntityCatagory), "prop entity");
		}
		case ENTCATAGORY_UNKNOWN:
		{
			Format(sEntityCatagory, sizeof(sEntityCatagory), "unknown entity");
		}
	}
	
	SetNativeString(2, sEntityCatagory, iMaxLength);
	
	return true;
}

public int Native_GetEntityType(Handle hPlugin, int iNumParams)
{
	char sClassname[64];
	
	int iEntity = GetNativeCell(1);
	
	GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
	
	if (StrEqual(sClassname, "cycler", false))
	{
		return view_as<int>(ENTTYPE_CYCLER);
	} else if (StrEqual(sClassname, "cel_door", false))
	{
		return view_as<int>(ENTTYPE_DOOR);
	} else if (StrEqual(sClassname, "cel_internet", false))
	{
		return view_as<int>(ENTTYPE_INTERNET);
	} else if (StrContains(sClassname, "effect_", false) != -1)
	{
		return view_as<int>(ENTTYPE_EFFECT);
	} else if (StrContains(sClassname, "prop_dynamic", false) != -1)
	{
		return view_as<int>(ENTTYPE_DYNAMIC);
	} else if (StrContains(sClassname, "prop_physics", false) != -1)
	{
		return view_as<int>(ENTTYPE_PHYSICS);
	} else {
		return view_as<int>(ENTTYPE_UNKNOWN);
	}
}

public int Native_GetEntityTypeFromName(Handle hPlugin, int iNumParams)
{
	char sEntityType[PLATFORM_MAX_PATH];
	
	GetNativeString(1, sEntityType, sizeof(sEntityType));
	
	if (StrEqual(sEntityType, "cycler", false))
	{
		return view_as<int>(ENTTYPE_CYCLER);
	} else if (StrEqual(sEntityType, "door", false))
	{
		return view_as<int>(ENTTYPE_DOOR);
	} else if (StrEqual(sEntityType, "dynamic", false))
	{
		return view_as<int>(ENTTYPE_DYNAMIC);
	} else if (StrEqual(sEntityType, "effect", false))
	{
		return view_as<int>(ENTTYPE_EFFECT);
	} else if (StrEqual(sEntityType, "internet", false))
	{
		return view_as<int>(ENTTYPE_INTERNET);
	} else if (StrEqual(sEntityType, "physics", false))
	{
		return view_as<int>(ENTTYPE_PHYSICS);
	} else {
		return view_as<int>(ENTTYPE_UNKNOWN);
	}
}

public int Native_GetEntityTypeName(Handle hPlugin, int iNumParams)
{
	char sEntityType[PLATFORM_MAX_PATH];
	int iMaxLength = GetNativeCell(3);
	
	switch (view_as<EntityType>(GetNativeCell(1)))
	{
		case ENTTYPE_CYCLER:
		{
			Format(sEntityType, sizeof(sEntityType), "cycler prop");
		}
		case ENTTYPE_DOOR:
		{
			Format(sEntityType, sizeof(sEntityType), "door cel");
		}
		case ENTTYPE_DYNAMIC:
		{
			Format(sEntityType, sizeof(sEntityType), "dynamic prop");
		}
		case ENTTYPE_EFFECT:
		{
			Format(sEntityType, sizeof(sEntityType), "effect cel");
		}
		case ENTTYPE_INTERNET:
		{
			Format(sEntityType, sizeof(sEntityType), "internet cel");
		}
		case ENTTYPE_PHYSICS:
		{
			Format(sEntityType, sizeof(sEntityType), "physics prop");
		}
		case ENTTYPE_UNKNOWN:
		{
			Format(sEntityType, sizeof(sEntityType), "unknown prop type");
		}
	}
	
	SetNativeString(2, sEntityType, iMaxLength);
	
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

public int Native_GetOwner(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return GetClientFromSerial(g_iOwner[iEntity]);
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

public int Native_GetPropName(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	int iMaxLength = GetNativeCell(3);
	
	SetNativeString(2, g_sPropName[iEntity], iMaxLength);
	
	return true;
}

public int Native_IsEntity(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	if(iEntity > -1)
	{
		return g_bEntity[iEntity];
	}
	
	return false;
}

public int Native_IsFrozen(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return g_bFrozen[iEntity];
}

public int Native_IsPlayer(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	return g_bPlayer[iClient];
}

public int Native_IsSolid(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return g_bSolid[iEntity];
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

public int Native_SetColor(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	int iR = GetNativeCell(2), iG = GetNativeCell(3), iB = GetNativeCell(4), iA = GetNativeCell(5);
	
	SetEntityRenderColor(iEntity, iR == -1 ? g_iColor[iEntity][0] : iR, iG == -1 ? g_iColor[iEntity][1] : iG, iB == -1 ? g_iColor[iEntity][2] : iB, iA == -1 ? g_iColor[iEntity][3] : iA);
	SetEntityRenderMode(iEntity, RENDER_TRANSALPHA);
	
	g_iColor[iEntity][0] = iR == -1 ? g_iColor[iEntity][0] : iR, g_iColor[iEntity][1] = iG == -1 ? g_iColor[iEntity][1] : iG, g_iColor[iEntity][2] = iB == -1 ? g_iColor[iEntity][2] : iB, g_iColor[iEntity][3] = iA == -1 ? g_iColor[iEntity][3] : iA;
	
	return true;
}

public int Native_SetEntity(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	bool bEntity = view_as<bool>(GetNativeCell(2));
	
	g_bEntity[iEntity] = bEntity;
	
	return true;
}

public int Native_SetFrozen(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	bool bFrozen = view_as<bool>(GetNativeCell(2));
	
	bFrozen ? AcceptEntityInput(iEntity, "disablemotion") : AcceptEntityInput(iEntity, "enablemotion");
	
	g_bFrozen[iEntity] = bFrozen;
	
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

public int Native_SetOwner(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iEntity = GetNativeCell(2);
	
	g_iOwner[iEntity] = GetClientSerial(iClient);
	
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

public int Native_SetPropName(Handle hPlugin, int iNumParams)
{
	char sPropName[64];
	
	int iEntity = GetNativeCell(1);
	
	GetNativeString(2, sPropName, sizeof(sPropName));
	
	Format(g_sPropName[iEntity], sizeof(g_sPropName), sPropName);
	
	return true;
}

public int Native_SetSolid(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	bool bSolid = view_as<bool>(GetNativeCell(2));
	
	bSolid ? DispatchKeyValue(iEntity, "solid", "6") : DispatchKeyValue(iEntity, "solid", "4");
	
	g_bSolid[iEntity] = bSolid;
	
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
	
	DispatchSpawn(iDoor);
	
	fOrigin[2] += 54;
	
	TeleportEntity(iDoor, fOrigin, NULL_VECTOR, NULL_VECTOR);
	
	Cel_AddToCelCount(iClient);
	
	Cel_SetColor(iDoor, iColor[0], iColor[1], iColor[2], iColor[3]);
	
	Cel_SetEntity(iDoor, true);
	
	Cel_SetFrozen(iDoor, true);
	
	Cel_SetOwner(iClient, iDoor);
	
	Cel_SetSolid(iDoor, true);
	
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
	
	DispatchSpawn(iInternet);
	
	TeleportEntity(iInternet, fOrigin, fAngles, NULL_VECTOR);
	
	Cel_AddToCelCount(iClient);
	
	Cel_SetColor(iInternet, iColor[0], iColor[1], iColor[2], iColor[3]);
	
	Cel_SetEntity(iInternet, true);
	
	Cel_SetFrozen(iInternet, true);
	
	Cel_SetInternetURL(iInternet, sURL);
	
	Cel_SetOwner(iClient, iInternet);
	
	Cel_SetSolid(iInternet, true);
	
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
	
	DispatchSpawn(iProp);
	
	TeleportEntity(iProp, fOrigin, fAngles, NULL_VECTOR);
	
	Cel_AddToPropCount(iClient);
	
	Cel_SetColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
	
	Cel_SetEntity(iProp, true);
	
	Cel_SetFrozen(iProp, true);
	
	Cel_SetOwner(iClient, iProp);
	
	Cel_SetPropName(iProp, sAlias);
	
	if (!StrEqual(sEntityType, "cycler"))
	Cel_SetSolid(iProp, true);
	
	return iProp;
}

public int Native_SubFromCelCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	int iCount = Cel_GetCelCount(iClient), iFinalCount = iCount -= 1;
	
	Cel_SetCelCount(iClient, iFinalCount);
	
	return true;
}

public int Native_SubFromPropCount(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	int iCount = Cel_GetPropCount(iClient), iFinalCount = iCount -= 1;
	
	Cel_SetPropCount(iClient, iFinalCount);
	
	return true;
}

//Stocks:
stock bool Cel_FilterPlayer(int iEntity, any iContentsMask)
{
	return iEntity > MaxClients;
}
