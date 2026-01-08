#pragma semicolon 1

#include <celmod>

#pragma newdecls required

bool g_bLooping[MAXENTITIES + 1];
bool g_bMusicActive[MAXENTITIES + 1];

char g_sDefaultInternetURL[PLATFORM_MAX_PATH];
char g_sInternetURL[MAXENTITIES + 1][PLATFORM_MAX_PATH];
char g_sMusicDB[PLATFORM_MAX_PATH];
char g_sMusicPath[MAXENTITIES + 1][PLATFORM_MAX_PATH];
char g_sSoundPath[MAXENTITIES + 1][PLATFORM_MAX_PATH];

ConVar g_cvDefaultInternetURL;

float g_fLoop[MAXENTITIES + 1];
float g_fVolume[MAXENTITIES + 1];

Handle g_hOnCelSpawn;
Handle g_hMusicLoop[MAXENTITIES + 1];
Handle g_hResetMusic[MAXENTITIES + 1];

int g_iSpeed[MAXENTITIES + 1];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_CheckMusicDB", Native_CheckMusicDB);
	CreateNative("Cel_CheckSoundDB", Native_CheckSoundDB);
	CreateNative("Cel_GetInternetURL", Native_GetInternetURL);
	CreateNative("Cel_GetMusicLoopTime", Native_GetMusicLoopTime);
	CreateNative("Cel_GetMusicPath", Native_GetMusicPath);
	CreateNative("Cel_GetMusicVolume", Native_GetMusicVolume);
	CreateNative("Cel_GetSoundPath", Native_GetSoundPath);
	CreateNative("Cel_GetSoundSpeed", Native_GetSoundSpeed);
	CreateNative("Cel_IsMusicActive", Native_IsMusicActive);
	CreateNative("Cel_IsMusicLooping", Native_IsMusicLooping);
	CreateNative("Cel_KillSound", Native_KillSound);
	CreateNative("Cel_SetInternetURL", Native_SetInternetURL);
	CreateNative("Cel_SpawnDoor", Native_SpawnDoor);
	CreateNative("Cel_SpawnInternet", Native_SpawnInternet);
	CreateNative("Cel_SpawnLadder", Native_SpawnLadder);
	CreateNative("Cel_SpawnLight", Native_SpawnLight);
	CreateNative("Cel_SpawnMusic", Native_SpawnMusic);
	CreateNative("Cel_SpawnSound", Native_SpawnSound);
	
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "|CelMod| Cels",
	author = CEL_AUTHOR,
	description = "Handles anything having to do with cels.",
	version = CEL_VERSION,
	url = CEL_URL
};

public void OnPluginStart()
{
	LoadTranslations("celmod.phrases");
	
	BuildPath(Path_SM, g_sMusicDB, sizeof(g_sMusicDB), "data/celmod/sounds.txt");
	if (!FileExists(g_sMusicDB))
	{
		ThrowError("|CelMod| %t", "FileNotFound", g_sMusicDB);
	}
	
	g_hOnCelSpawn = CreateGlobalForward("Cel_OnCelSpawn", ET_Hook, Param_Cell, Param_Cell, Param_Cell);
	
	RegConsoleCmd("v_door", Command_Door, "|CelMod| Spawns a working door cel.");
	RegConsoleCmd("v_internet", Command_Internet, "|CelMod| Creates a working internet cel.");
	RegConsoleCmd("v_ladder", Command_Ladder, "|CelMod| Creates a working ladder cel.");
	RegConsoleCmd("v_light", Command_Light, "|CelMod| Creates a working light cel.");
	RegConsoleCmd("v_music", Command_Music, "|CelMod| Creates a working music cel.");
	RegConsoleCmd("v_seturl", Command_SetURL, "|CelMod| Sets the url of the internet cel you are looking at.");
	RegConsoleCmd("v_sound", Command_Sound, "|CelMod| Creates a working sound cel.");
	
	g_cvDefaultInternetURL = CreateConVar("cm_default_internet_url", "https://delaware.rockzehh.net", "Default internet cel URL.");
	
	g_cvDefaultInternetURL.AddChangeHook(CMCels_OnConVarChanged);
	
	g_cvDefaultInternetURL.GetString(g_sDefaultInternetURL, sizeof(g_sDefaultInternetURL));
	
	AutoExecConfig(true, "celmod.cels");
}

public void CMCels_OnConVarChanged(ConVar cvConVar, const char[] sOldValue, const char[] sNewValue)
{
	if (cvConVar == g_cvDefaultInternetURL)
	{
		g_cvDefaultInternetURL.GetString(g_sDefaultInternetURL, sizeof(g_sDefaultInternetURL));
		PrintToServer("|CelMod| Default internet cel url updated to %s.", sNewValue);
	}
}

//Commands:
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
	
	int iDoor = Cel_SpawnDoor(iClient, StringToInt(sSkin), fAngles, fOrigin, 255, 255, 255, 255);
	
	Call_StartForward(g_hOnCelSpawn);
	
	Call_PushCell(iDoor);
	Call_PushCell(iClient);
	Call_PushCell(ENTTYPE_DOOR);
	
	Call_Finish();
	
	Cel_ReplyToCommand(iClient, "%t", "DoorSpawn");
	
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
	
	Cel_TeleportInfrontOfClient(iClient, iInternet, 25.0);
	
	Call_StartForward(g_hOnCelSpawn);
	
	Call_PushCell(iInternet);
	Call_PushCell(iClient);
	Call_PushCell(ENTTYPE_INTERNET);
	
	Call_Finish();
	
	Cel_ReplyToCommand(iClient, "%t", "InternetSpawn");
	
	return Plugin_Handled;
}

public Action Command_Ladder(int iClient, int iArgs)
{
	char sModel[64], sOption[32];
	float fAngles[3], fOrigin[3];
	
	if (!Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxCelLimit", Cel_GetCelCount(iClient));
		return Plugin_Handled;
	}
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Ladder");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sOption, sizeof(sOption));
	
	if(!(StringToInt(sOption) == 1 || StringToInt(sOption) == 2))
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Ladder");
		return Plugin_Handled;
	}
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	switch(StringToInt(sOption))
	{
		case 1: Format(sModel, sizeof(sModel), "models/props_c17/metalladder001.mdl");
		case 2: Format(sModel, sizeof(sModel), "models/props_c17/metalladder002.mdl");
	}
	
	int iLadder = Cel_SpawnLadder(iClient, sModel, fAngles, fOrigin, 255, 255, 255, 255);
	
	Call_StartForward(g_hOnCelSpawn);
	
	Call_PushCell(iLadder);
	Call_PushCell(iClient);
	Call_PushCell(ENTTYPE_LADDER);
	
	Call_Finish();
	
	Cel_ReplyToCommand(iClient, "%t", "LadderSpawn");
	
	return Plugin_Handled;
}

public Action Command_Light(int iClient, int iArgs)
{
	float fAngles[3], fOrigin[3];
	
	if (!Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxCelLimit", Cel_GetCelCount(iClient));
		return Plugin_Handled;
	}
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	int iLight = Cel_SpawnLight(iClient, fAngles, fOrigin, 255, 255, 255, 128);
	
	Cel_TeleportInfrontOfClient(iClient, iLight, 25.0);
	
	Call_StartForward(g_hOnCelSpawn);
	
	Call_PushCell(iLight);
	Call_PushCell(iClient);
	Call_PushCell(ENTTYPE_LIGHT);
	
	Call_Finish();
	
	Cel_ReplyToCommand(iClient, "%t", "LightSpawn");
	
	return Plugin_Handled;
}

public Action Command_Music(int iClient, int iArgs)
{
	bool bLoop = false;
	char sAlias[64], sLoop[64], sMusicBuffer[2][128], sMusicString[256], sSpeed[64], sVolume[64];
	float fAngles[3], fOrigin[3], fVolume = 0.9;
	int iSpeed = 100;
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Music");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlias, sizeof(sAlias));
	GetCmdArg(2, sLoop, sizeof(sLoop));
	GetCmdArg(3, sVolume, sizeof(sVolume));
	GetCmdArg(4, sSpeed, sizeof(sSpeed));
	
	if (!Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxCelLimit", Cel_GetCelCount(iClient));
		return Plugin_Handled;
	}
	
	if(StrEqual(sLoop, "1", false))
	{
		bLoop = true;
	}else if(StrEqual(sLoop, "0", false))
	{
		bLoop = false;
	}else if(StrEqual(sLoop, "", false))
	{
		bLoop = false;
	}else{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Music");
		return Plugin_Handled;
	}
	
	if(StringToInt(sVolume) < 50 || StringToInt(sVolume) > 90)
	{
		fVolume = 0.9;
	}else if(StringToInt(sVolume) > 50 || StringToInt(sVolume) < 90)
	{
		fVolume = float(StringToInt(sVolume)) / 100.0;
	}else if(StrEqual(sVolume, "", false))
	{
		fVolume = 0.9;
	}else{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Music");
		return Plugin_Handled;
	}
	
	if(StringToInt(sSpeed) < 10 || StringToInt(sSpeed) > 250)
	{
		iSpeed = 100;
	}else if(StringToInt(sSpeed) > 10 || StringToInt(sSpeed) < 250)
	{
		iSpeed = StringToInt(sSpeed);
	}else if(StrEqual(sSpeed, "", false))
	{
		iSpeed = 100;
	}else{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Music");
		return Plugin_Handled;
	}
	
	if (Cel_CheckMusicDB(sAlias, sMusicString, sizeof(sMusicString)))
	{
		ExplodeString(sMusicString, "|", sMusicBuffer, 2, sizeof(sMusicBuffer[]));
		
		GetClientAbsAngles(iClient, fAngles);
		Cel_GetCrosshairHitOrigin(iClient, fOrigin);
		
		PrecacheSound(sMusicBuffer[0]);
		
		int iMusic = Cel_SpawnMusic(iClient, sMusicBuffer[0], bLoop, StringToFloat(sMusicBuffer[1]), false, fVolume, iSpeed, fAngles, fOrigin, 64, 255, 0, 255);
		
		Cel_TeleportInfrontOfClient(iClient, iMusic, 25.0);
		
		Call_StartForward(g_hOnCelSpawn);
		
		Call_PushCell(iMusic);
		Call_PushCell(iClient);
		Call_PushCell(ENTTYPE_MUSIC);
		
		Call_Finish();
		
		Cel_ReplyToCommand(iClient, "%t", "SpawnMusic", sAlias);
	} else {
		Cel_ReplyToCommand(iClient, "%t", "MusicNotFound", sAlias);
		return Plugin_Handled;
	}
	
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

public Action Command_Sound(int iClient, int iArgs)
{
	char sAlias[64], sMusicString[256], sSpeed[64];
	float fAngles[3], fOrigin[3];
	int iSpeed = 100;
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Sound");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlias, sizeof(sAlias));
	GetCmdArg(2, sSpeed, sizeof(sSpeed));
	
	if (!Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxCelLimit", Cel_GetCelCount(iClient));
		return Plugin_Handled;
	}
	
	if(StringToInt(sSpeed) < 10 || StringToInt(sSpeed) > 250)
	{
		iSpeed = 100;
	}else if(StringToInt(sSpeed) > 10 || StringToInt(sSpeed) < 250)
	{
		iSpeed = StringToInt(sSpeed);
	}else if(StrEqual(sSpeed, "", false))
	{
		iSpeed = 100;
	}else{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Sound");
		return Plugin_Handled;
	}
	
	if (Cel_CheckSoundDB(sAlias, sMusicString, sizeof(sMusicString)))
	{
		GetClientAbsAngles(iClient, fAngles);
		Cel_GetCrosshairHitOrigin(iClient, fOrigin);
		
		PrecacheSound(sMusicString);
		
		int iSound = Cel_SpawnSound(iClient, sMusicString, iSpeed, fAngles, fOrigin, 255, 200, 0, 255);
		
		Cel_TeleportInfrontOfClient(iClient, iSound, 30.0);
		
		Call_StartForward(g_hOnCelSpawn);
		
		Call_PushCell(iSound);
		Call_PushCell(iClient);
		Call_PushCell(ENTTYPE_SOUND);
		
		Call_Finish();
		
		Cel_ReplyToCommand(iClient, "%t", "SpawnSound", sAlias);
	} else {
		Cel_ReplyToCommand(iClient, "%t", "SoundNotFound", sAlias);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

//Natives:
public int Native_CheckMusicDB(Handle hPlugin, int iNumParams)
{
	int iMaxLength = GetNativeCell(3);
	
	char sAlias[64], sMusicString[128];
	
	GetNativeString(1, sAlias, sizeof(sAlias));
	
	KeyValues kvMusic = new KeyValues("Sounds");
	
	kvMusic.ImportFromFile(g_sMusicDB);
	
	kvMusic.JumpToKey("Music", false);
	
	kvMusic.GetString(sAlias, sMusicString, iMaxLength, "null");
	
	kvMusic.Rewind();
	
	delete kvMusic;
	
	SetNativeString(2, sMusicString, iMaxLength);
	
	return (StrEqual(sMusicString, "null")) ? false : true;
}

public int Native_CheckSoundDB(Handle hPlugin, int iNumParams)
{
	int iMaxLength = GetNativeCell(3);
	
	char sAlias[64], sMusicString[128];
	
	GetNativeString(1, sAlias, sizeof(sAlias));
	
	KeyValues kvMusic = new KeyValues("Sounds");
	
	kvMusic.ImportFromFile(g_sMusicDB);
	
	kvMusic.JumpToKey("Sounds", false);
	
	kvMusic.GetString(sAlias, sMusicString, iMaxLength, "null");
	
	kvMusic.Rewind();
	
	delete kvMusic;
	
	SetNativeString(2, sMusicString, iMaxLength);
	
	return (StrEqual(sMusicString, "null")) ? false : true;
}

public int Native_GetInternetURL(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1), iMaxLength = GetNativeCell(3);
	
	SetNativeString(2, g_sInternetURL[iEntity], iMaxLength);
	
	return true;
}

public int Native_GetMusicLoopTime(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return view_as<int>(g_fLoop[iEntity]);
}

public int Native_GetMusicPath(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1), iMaxLength = GetNativeCell(3);
	
	SetNativeString(2, g_sMusicPath[iEntity], iMaxLength);
	
	return true;
}

public int Native_GetMusicVolume(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return view_as<int>(g_fVolume[iEntity]);
}

public int Native_GetSoundPath(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1), iMaxLength = GetNativeCell(3);
	
	SetNativeString(2, g_sSoundPath[iEntity], iMaxLength);
	
	return true;
}

public int Native_GetSoundSpeed(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return g_iSpeed[iEntity];
}

public int Native_IsMusicActive(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return g_bMusicActive[iEntity];
}

public int Native_IsMusicLooping(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return g_bLooping[iEntity];
}

public int Native_KillSound(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	if(Cel_GetEntityType(iEntity) == ENTTYPE_MUSIC)
	{
		StopSound(iEntity, SNDCHAN_AUTO, g_sMusicPath[iEntity]);
		
		if(Cel_IsMusicLooping(iEntity))
		{
			g_hMusicLoop[iEntity].Close();
		}else{
			g_hResetMusic[iEntity].Close();
		}
	}else if(Cel_GetEntityType(iEntity) == ENTTYPE_SOUND)
	{
		StopSound(iEntity, SNDCHAN_AUTO, g_sSoundPath[iEntity]);
	}
	
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

public int Native_SpawnDoor(Handle hPlugin, int iNumParams)
{
	char sAngles[16], sSkin[16];
	float fAngles[3], fOrigin[3];
	int iClient = GetNativeCell(1), iColor[4];
	
	IntToString(GetNativeCell(2), sSkin, sizeof(sSkin));
	
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
	
	DispatchKeyValue(iDoor, "angles", sAngles);
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
	
	Cel_SetRainbow(iDoor, false);
	
	Cel_SetEntity(iDoor, true);
	
	Cel_SetMotion(iDoor, false);
	
	Cel_SetOwner(iClient, iDoor);
	
	Cel_SetSolid(iDoor, true);
	
	Cel_LockEntity(iDoor, false);
	
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
	DispatchKeyValue(iInternet, "spawnflags", "256");
	
	TeleportEntity(iInternet, fOrigin, fAngles, NULL_VECTOR);
	
	DispatchSpawn(iInternet);
	
	Cel_AddToCelCount(iClient);
	
	Cel_SetColor(iInternet, iColor[0], iColor[1], iColor[2], iColor[3]);
	
	Cel_SetRainbow(iInternet, false);
	
	Cel_SetEntity(iInternet, true);
	
	Cel_SetMotion(iInternet, false);
	
	Cel_SetInternetURL(iInternet, sURL);
	
	Cel_SetOwner(iClient, iInternet);
	
	Cel_SetSolid(iInternet, true);
	
	Cel_SetRenderFX(iInternet, RENDERFX_NONE);
	
	SDKHook(iInternet, SDKHook_Use, Hook_InternetUse);
	
	return iInternet;
}

public int Native_SpawnLadder(Handle hPlugin, int iNumParams)
{
	char sModel[64];
	float fAngles[3], fOrigin[3];
	int iClient = GetNativeCell(1), iColor[4];
	
	GetNativeString(2, sModel, sizeof(sModel));
	
	GetNativeArray(3, fAngles, 3);
	GetNativeArray(4, fOrigin, 3);
	
	iColor[0] = GetNativeCell(5);
	iColor[1] = GetNativeCell(6);
	iColor[2] = GetNativeCell(7);
	iColor[3] = GetNativeCell(8);
	
	int iProp = CreateEntityByName("prop_physics_override");
	
	if (iProp == -1)
	return -1;
	
	PrecacheModel(sModel);
	
	DispatchKeyValue(iProp, "model", sModel);
	DispatchKeyValue(iProp, "classname", "cel_ladder");
	DispatchKeyValue(iProp, "physdamagescale", "0.0");
	DispatchKeyValue(iProp, "spawnflags", "8");
	
	DispatchSpawn(iProp);
	
	int iLadder = CreateEntityByName("func_useableladder");
	
	DispatchKeyValue(iLadder, "point0", "30 0 0");
	DispatchKeyValue(iLadder, "point1", "30 0 128");
	DispatchKeyValue(iLadder, "StartDisabled", "0");
	
	DispatchSpawn(iLadder);
	
	SetVariantString("!activator");
	
	AcceptEntityInput(iLadder, "setparent", iProp);
	
	TeleportEntity(iProp, fOrigin, fAngles, NULL_VECTOR);
	
	Cel_AddToCelCount(iClient);
	
	Cel_SetColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
	
	Cel_SetRainbow(iProp, false);
	
	Cel_SetEntity(iProp, true);
	
	Cel_SetMotion(iProp, false);
	
	Cel_SetOwner(iClient, iProp);
	
	Cel_SetSolid(iProp, true);
	
	Cel_SetRenderFX(iProp, RENDERFX_NONE);
	
	return iProp;
}

public int Native_SpawnLight(Handle hPlugin, int iNumParams)
{
	char sLightName[32], sLightOutput[32], sLightColor[32], sLightAlpha[32];
	float fAngles[3], fOrigin[3];
	int iClient = GetNativeCell(1), iColor[4];
	
	GetNativeArray(2, fAngles, 3);
	GetNativeArray(3, fOrigin, 3);
	
	iColor[0] = GetNativeCell(4);
	iColor[1] = GetNativeCell(5);
	iColor[2] = GetNativeCell(6);
	iColor[3] = GetNativeCell(7);
	
	Format(sLightColor, sizeof(sLightColor), "%d %d %d", iColor[0], iColor[1], iColor[2]);
	IntToString(iColor[3], sLightAlpha, sizeof(sLightAlpha));
	
	int iProp = CreateEntityByName("prop_physics_override");
	
	if (iProp == -1)
	return -1;
	
	PrecacheModel("models/roller_spikes.mdl");
	
	DispatchKeyValue(iProp, "model", "models/roller_spikes.mdl");
	DispatchKeyValue(iProp, "physdamagescale", "1.0");
	DispatchKeyValue(iProp, "classname", "cel_light");
	DispatchKeyValue(iProp, "spawnflags", "256");
	DispatchKeyValue(iProp, "rendermode", "1");
	DispatchKeyValue(iProp, "renderamt", sLightAlpha);
	
	DispatchSpawn(iProp);
	
	int iLight = CreateEntityByName("light_dynamic");
	
	DispatchKeyValue(iLight, "rendercolor", sLightColor);
	DispatchKeyValue(iLight, "classname", "cel_light");
	DispatchKeyValue(iLight, "inner_cone", "300");
	DispatchKeyValue(iLight, "cone", "500");
	DispatchKeyValue(iLight, "spotlight_radius", "500");
	DispatchKeyValue(iLight, "brightness", "0.5");
	
	DispatchSpawn(iLight);
	
	SetVariantString("!activator");
	
	AcceptEntityInput(iLight, "setparent", iProp);
	
	int iRandom = iClient + GetRandomInt(1, 1000);
	
	Format(sLightName, 32, "light_%d", iRandom);
	Format(sLightOutput, 32, "%s,toggle,,0,-1", sLightName);
	
	DispatchKeyValue(iLight, "targetname", sLightName);
	DispatchKeyValue(iProp, "OnPlayerUse", sLightOutput);
	
	SetVariantInt(500);
	
	AcceptEntityInput(iLight, "distance");
	AcceptEntityInput(iProp, "disableshadow");
	AcceptEntityInput(iLight, "TurnOn");
	
	TeleportEntity(iProp, fOrigin, fAngles, NULL_VECTOR);
	
	Cel_AddToCelCount(iClient);
	
	Cel_SetColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
	
	Cel_SetRainbow(iProp, false);
	
	Cel_SetEntity(iProp, true);
	
	Cel_SetMotion(iProp, false);
	
	Cel_SetOwner(iClient, iProp);
	
	Cel_SetSolid(iProp, true);
	
	Cel_SetRenderFX(iProp, RENDERFX_NONE);
	
	return iProp;
}

public int Native_SpawnMusic(Handle hPlugin, int iNumParams)
{
	bool bLoop = view_as<bool>(GetNativeCell(3)), bStart = view_as<bool>(GetNativeCell(5));
	char sMusicPath[PLATFORM_MAX_PATH];
	float fAngles[3], fLoopTime = view_as<float>(GetNativeCell(4)), fOrigin[3], fVolume = view_as<float>(GetNativeCell(6));
	int iClient = GetNativeCell(1), iColor[4], iSpeed = GetNativeCell(7);
	
	GetNativeString(2, sMusicPath, sizeof(sMusicPath));
	
	GetNativeArray(8, fAngles, 3);
	GetNativeArray(9, fOrigin, 3);
	
	iColor[0] = GetNativeCell(10);
	iColor[1] = GetNativeCell(11);
	iColor[2] = GetNativeCell(12);
	iColor[3] = GetNativeCell(13);
	
	int iMusic = CreateEntityByName("prop_physics_override");
	
	if (iMusic == -1)
	return -1;
	
	PrecacheModel("models/props_lab/citizenradio.mdl");
	
	DispatchKeyValue(iMusic, "model", "models/props_lab/citizenradio.mdl");
	DispatchKeyValue(iMusic, "classname", "cel_music");
	DispatchKeyValue(iMusic, "spawnflags", "256");
	
	fAngles[1] += 180;
	
	TeleportEntity(iMusic, fOrigin, fAngles, NULL_VECTOR);
	
	DispatchSpawn(iMusic);
	
	Cel_AddToCelCount(iClient);
	
	Cel_SetColor(iMusic, iColor[0], iColor[1], iColor[2], iColor[3]);
	
	Cel_SetRainbow(iMusic, false);
	
	Cel_SetEntity(iMusic, true);
	
	Cel_SetMotion(iMusic, false);
	
	g_bMusicActive[iMusic] = false;
	
	g_bLooping[iMusic] = bLoop;
	
	g_fLoop[iMusic] = fLoopTime;
	
	g_iSpeed[iMusic] = iSpeed;
	
	g_fVolume[iMusic] = fVolume;
	
	Format(g_sMusicPath[iMusic], sizeof(g_sMusicPath[]), sMusicPath);
	
	Cel_SetOwner(iClient, iMusic);
	
	Cel_SetSolid(iMusic, true);
	
	Cel_SetRenderFX(iMusic, RENDERFX_NONE);
	
	SDKHook(iMusic, SDKHook_Use, Hook_MusicUse);
	
	if(bStart)
	{
		AcceptEntityInput(iMusic, "Use", iClient);
	}
	
	return iMusic;
}

public int Native_SpawnSound(Handle hPlugin, int iNumParams)
{
	char sSound[PLATFORM_MAX_PATH];
	float fAngles[3], fOrigin[3];
	int iClient = GetNativeCell(1), iColor[4], iSpeed = GetNativeCell(3);
	
	GetNativeString(2, sSound, sizeof(sSound));
	
	GetNativeArray(4, fAngles, 3);
	GetNativeArray(5, fOrigin, 3);
	
	iColor[0] = GetNativeCell(6);
	iColor[1] = GetNativeCell(7);
	iColor[2] = GetNativeCell(8);
	iColor[3] = GetNativeCell(9);
	
	int iSound = CreateEntityByName("prop_physics_override");
	
	if (iSound == -1)
	return -1;
	
	PrecacheModel("models/props_junk/popcan01a.mdl");
	
	DispatchKeyValue(iSound, "model", "models/props_junk/popcan01a.mdl");
	DispatchKeyValue(iSound, "classname", "cel_sound");
	DispatchKeyValue(iSound, "spawnflags", "256");
	
	TeleportEntity(iSound, fOrigin, fAngles, NULL_VECTOR);
	
	DispatchSpawn(iSound);
	
	Cel_AddToCelCount(iClient);
	
	Cel_SetColor(iSound, iColor[0], iColor[1], iColor[2], iColor[3]);
	
	Cel_SetRainbow(iSound, false);
	
	Cel_SetEntity(iSound, true);
	
	Cel_SetMotion(iSound, false);
	
	Format(g_sSoundPath[iSound], sizeof(g_sSoundPath[]), sSound);
	
	g_iSpeed[iSound] = iSpeed;
	
	Cel_SetOwner(iClient, iSound);
	
	Cel_SetSolid(iSound, true);
	
	Cel_SetRenderFX(iSound, RENDERFX_NONE);
	
	SDKHook(iSound, SDKHook_Use, Hook_SoundUse);
	
	return iSound;
}

//Hooks:
public void Hook_MusicUse(int iEntity, int iActivator, int iCaller, UseType utType, float fValue)
{
	if(g_bMusicActive[iEntity])
	{
		StopSound(iEntity, SNDCHAN_AUTO, g_sMusicPath[iEntity]);
		
		if(g_bLooping[iEntity])
		{
			g_hMusicLoop[iEntity].Close();
		}else{
			g_hResetMusic[iEntity].Close();
		}
		
		g_bMusicActive[iEntity] = false;
	}else{
		EmitSoundToAll(g_sMusicPath[iEntity], iEntity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, g_fVolume[iEntity], Cel_GetSoundSpeed(iEntity));
		
		if(g_bLooping[iEntity])
		{
			g_hMusicLoop[iEntity] = CreateTimer(Cel_GetMusicLoopTime(iEntity), Timer_LoopMusic, iEntity, TIMER_REPEAT);
		}else{
			g_hResetMusic[iEntity] = CreateTimer(Cel_GetMusicLoopTime(iEntity) + 0.2, Timer_ResetMusic, iEntity);
		}
		
		g_bMusicActive[iEntity] = true;
	}
}

public void Hook_SoundUse(int iEntity, int iActivator, int iCaller, UseType utType, float fValue)
{
	EmitSoundToAll(g_sSoundPath[iEntity], iEntity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.9, Cel_GetSoundSpeed(iEntity));
}

//Timers:
public Action Timer_LoopMusic(Handle hTimer, any iEntity)
{
	if(g_bMusicActive[iEntity] && g_bLooping[iEntity])
	{
		StopSound(iEntity, SNDCHAN_AUTO, g_sMusicPath[iEntity]);
		
		EmitSoundToAll(g_sMusicPath[iEntity], iEntity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, g_fVolume[iEntity], Cel_GetSoundSpeed(iEntity));
	}
	
	return Plugin_Continue;
}

public Action Timer_ResetMusic(Handle hTimer, any iEntity)
{
	g_bMusicActive[iEntity] = false;
	
	return Plugin_Continue;
}
