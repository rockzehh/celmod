#pragma semicolon 1

#include <celmod>

#pragma newdecls required

bool g_bLate;

float g_fCrosshairOrigin[MAXPLAYERS + 1][3];

int g_iSaveOverride[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_LoadBuild", Native_LoadBuild);
	CreateNative("Cel_SaveBuild", Native_SaveBuild);
	
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "|CelMod| Build Saving System",
	author = CEL_AUTHOR,
	description = "Handles saving/loading of client buildings.",
	version = CEL_VERSION,
	url = CEL_URL
};

public void OnPluginStart()
{
	LoadTranslations("celmod.phrases");
	
	if (g_bLate)
	{
		for (int i = 1; i < MaxClients; i++)
		{
			if (IsClientAuthorized(i))
			{
				OnClientPutInServer(i);
			}
		}
	}
	
	RegConsoleCmd("sm_load", Command_LoadBuild, "|CelMod| Loads entities from a save file.");
	RegConsoleCmd("sm_save", Command_SaveBuild, "|CelMod| Saves all server entities that are in your land.");
}

public void OnClientPutInServer(int iClient)
{
	char sAuthID[64], sPath[PLATFORM_MAX_PATH];
	
	Cel_ChooseHudColor(iClient);
	
	Cel_GetAuthID(iClient, sAuthID, sizeof(sAuthID));
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/users/%s/saves", sAuthID);
	if (!DirExists(sPath))
	{
		CreateDirectory(sPath, 511);
	}
}

public Action Command_LoadBuild(int iClient, int iArgs)
{
	char sSaveName[64];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_LoadBuild");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sSaveName, sizeof(sSaveName));
	
	Cel_LoadBuild(iClient, sSaveName);
	
	return Plugin_Handled;
}

public Action Command_SaveBuild(int iClient, int iArgs)
{
	char sSaveName[64];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_SaveBuild");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sSaveName, sizeof(sSaveName));
	
	Cel_SaveBuild(iClient, sSaveName);
	
	return Plugin_Handled;
}

public int Native_LoadBuild(Handle hPlugin, int iNumParams)
{
	char sAuthID[64], sFile[PLATFORM_MAX_PATH], sRelPath[PLATFORM_MAX_PATH], sSaveName[96];
	float fEnt[2][3], fOrigin[3];
	
	int iClient = GetNativeCell(1);
	
	GetNativeString(2, sSaveName, sizeof(sSaveName));
	
	Cel_GetAuthID(iClient, sAuthID, sizeof(sAuthID));
	
	Cel_GetCrosshairHitOrigin(iClient, g_fCrosshairOrigin[iClient]);
	
	Format(sRelPath, sizeof(sRelPath), "data/celmod/users/%s/saves/%s.txt", sAuthID, sSaveName);
	
	BuildPath(Path_SM, sFile, sizeof(sFile), sRelPath);
	
	KeyValues kvLoadBuild = new KeyValues("Vault");
	
	if(kvLoadBuild.ImportFromFile(sFile))
	{
		if (kvLoadBuild.GotoFirstSubKey())
		{
			do
			{
				EntityType etType = view_as<EntityType>(kvLoadBuild.GetNum("entitytype"));
				
				switch(etType)
				{
					case ENTTYPE_CYCLER:
					{
						char sBuffer[4][PLATFORM_MAX_PATH];
						
						kvLoadBuild.GetString("classname", sBuffer[0], sizeof(sBuffer[]));
						kvLoadBuild.GetString("targetname", sBuffer[1], sizeof(sBuffer[]));
						kvLoadBuild.GetString("model", sBuffer[2], sizeof(sBuffer[]));
						kvLoadBuild.GetString("propname", sBuffer[3], sizeof(sBuffer[]));
						
						fEnt[0][0] = kvLoadBuild.GetFloat("a1");
						fEnt[0][1] = kvLoadBuild.GetFloat("a2");
						fEnt[0][2] = kvLoadBuild.GetFloat("a3");
						
						fEnt[1][0] = kvLoadBuild.GetFloat("o1");
						fEnt[1][1] = kvLoadBuild.GetFloat("o2");
						fEnt[1][2] = kvLoadBuild.GetFloat("o3");
						
						fOrigin[0] = fEnt[1][0] + g_fCrosshairOrigin[iClient][0];
						fOrigin[1] = fEnt[1][1] + g_fCrosshairOrigin[iClient][1];
						fOrigin[2] = fEnt[1][2] + g_fCrosshairOrigin[iClient][2];
						
						int iProp = Cel_SpawnProp(iClient, sBuffer[3], "cycler", sBuffer[2], fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
						
						Cel_SetEntity(iProp, true);
						Entity_SetName(iProp, sBuffer[1]);
						Entity_SetSpawnFlags(iProp, kvLoadBuild.GetNum("spawnflags"));
						Entity_SetSkin(iProp, kvLoadBuild.GetNum("skin"));
						Cel_SetMotion(iProp, view_as<bool>(kvLoadBuild.GetNum("motion")));
						Cel_SetRenderFX(iProp, view_as<RenderFx>(kvLoadBuild.GetNum("renderfx")));
						Cel_SetOwner(iClient, iProp);
						Cel_SetPropName(iProp, sBuffer[3]);
						
						Cel_SetColorFade(iProp, view_as<bool>(kvLoadBuild.GetNum("colorfading")), kvLoadBuild.GetNum("fc1-1"), kvLoadBuild.GetNum("fc1-2"), kvLoadBuild.GetNum("fc1-3"), kvLoadBuild.GetNum("fc2-1"), kvLoadBuild.GetNum("fc2-2"), kvLoadBuild.GetNum("fc2-3"));
						Cel_SetRainbow(iProp, view_as<bool>(kvLoadBuild.GetNum("colorrainbow")));
						
						Entity_SetAnimSequence(iProp, kvLoadBuild.GetNum("animsequence"));
					}
					case ENTTYPE_DOOR:
					{
						char sBuffer[3][PLATFORM_MAX_PATH];
						
						kvLoadBuild.GetString("classname", sBuffer[0], sizeof(sBuffer[]));
						kvLoadBuild.GetString("targetname", sBuffer[1], sizeof(sBuffer[]));
						kvLoadBuild.GetString("model", sBuffer[2], sizeof(sBuffer[]));
						
						fEnt[0][0] = kvLoadBuild.GetFloat("a1");
						fEnt[0][1] = kvLoadBuild.GetFloat("a2");
						fEnt[0][2] = kvLoadBuild.GetFloat("a3");
						
						fEnt[1][0] = kvLoadBuild.GetFloat("o1");
						fEnt[1][1] = kvLoadBuild.GetFloat("o2");
						fEnt[1][2] = kvLoadBuild.GetFloat("o3");
						
						fOrigin[0] = fEnt[1][0] + g_fCrosshairOrigin[iClient][0];
						fOrigin[1] = fEnt[1][1] + g_fCrosshairOrigin[iClient][1];
						fOrigin[2] = fEnt[1][2] + g_fCrosshairOrigin[iClient][2];
						
						int iProp = Cel_SpawnDoor(iClient, "1", fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
						
						Cel_SetEntity(iProp, true);
						Entity_SetName(iProp, sBuffer[1]);
						Entity_SetSpawnFlags(iProp, kvLoadBuild.GetNum("spawnflags"));
						Entity_SetSkin(iProp, kvLoadBuild.GetNum("skin"));
						Cel_SetMotion(iProp, view_as<bool>(kvLoadBuild.GetNum("motion")));
						Cel_SetSolid(iProp, view_as<bool>(kvLoadBuild.GetNum("solid")));
						Cel_SetRenderFX(iProp, view_as<RenderFx>(kvLoadBuild.GetNum("renderfx")));
						Cel_SetOwner(iClient, iProp);
						
						Cel_SetColorFade(iProp, view_as<bool>(kvLoadBuild.GetNum("colorfading")), kvLoadBuild.GetNum("fc1-1"), kvLoadBuild.GetNum("fc1-2"), kvLoadBuild.GetNum("fc1-3"), kvLoadBuild.GetNum("fc2-1"), kvLoadBuild.GetNum("fc2-2"), kvLoadBuild.GetNum("fc2-3"));
						Cel_SetRainbow(iProp, view_as<bool>(kvLoadBuild.GetNum("colorrainbow")));
					}
					case ENTTYPE_DYNAMIC:
					{
						char sBuffer[4][PLATFORM_MAX_PATH];
						
						kvLoadBuild.GetString("classname", sBuffer[0], sizeof(sBuffer[]));
						kvLoadBuild.GetString("targetname", sBuffer[1], sizeof(sBuffer[]));
						kvLoadBuild.GetString("model", sBuffer[2], sizeof(sBuffer[]));
						kvLoadBuild.GetString("propname", sBuffer[3], sizeof(sBuffer[]));
						
						fEnt[0][0] = kvLoadBuild.GetFloat("a1");
						fEnt[0][1] = kvLoadBuild.GetFloat("a2");
						fEnt[0][2] = kvLoadBuild.GetFloat("a3");
						
						fEnt[1][0] = kvLoadBuild.GetFloat("o1");
						fEnt[1][1] = kvLoadBuild.GetFloat("o2");
						fEnt[1][2] = kvLoadBuild.GetFloat("o3");
						
						fOrigin[0] = fEnt[1][0] + g_fCrosshairOrigin[iClient][0];
						fOrigin[1] = fEnt[1][1] + g_fCrosshairOrigin[iClient][1];
						fOrigin[2] = fEnt[1][2] + g_fCrosshairOrigin[iClient][2];
						
						int iProp = Cel_SpawnProp(iClient, sBuffer[3], "prop_physics_override", sBuffer[2], fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
						
						Cel_SetEntity(iProp, true);
						Entity_SetName(iProp, sBuffer[1]);
						Entity_SetSpawnFlags(iProp, kvLoadBuild.GetNum("spawnflags"));
						Entity_SetSkin(iProp, kvLoadBuild.GetNum("skin"));
						Cel_SetMotion(iProp, view_as<bool>(kvLoadBuild.GetNum("motion")));
						Cel_SetSolid(iProp, view_as<bool>(kvLoadBuild.GetNum("solid")));
						Cel_SetRenderFX(iProp, view_as<RenderFx>(kvLoadBuild.GetNum("renderfx")));
						Cel_SetOwner(iClient, iProp);
						Cel_SetPropName(iProp, sBuffer[3]);
						
						Cel_SetColorFade(iProp, view_as<bool>(kvLoadBuild.GetNum("colorfading")), kvLoadBuild.GetNum("fc1-1"), kvLoadBuild.GetNum("fc1-2"), kvLoadBuild.GetNum("fc1-3"), kvLoadBuild.GetNum("fc2-1"), kvLoadBuild.GetNum("fc2-2"), kvLoadBuild.GetNum("fc2-3"));
						Cel_SetRainbow(iProp, view_as<bool>(kvLoadBuild.GetNum("colorrainbow")));
					}
					case ENTTYPE_EFFECT:
					{
						char sBuffer[3][PLATFORM_MAX_PATH];
						
						kvLoadBuild.GetString("classname", sBuffer[0], sizeof(sBuffer[]));
						kvLoadBuild.GetString("targetname", sBuffer[1], sizeof(sBuffer[]));
						kvLoadBuild.GetString("model", sBuffer[2], sizeof(sBuffer[]));
						
						fEnt[0][0] = kvLoadBuild.GetFloat("a1");
						fEnt[0][1] = kvLoadBuild.GetFloat("a2");
						fEnt[0][2] = kvLoadBuild.GetFloat("a3");
						
						fEnt[1][0] = kvLoadBuild.GetFloat("o1");
						fEnt[1][1] = kvLoadBuild.GetFloat("o2");
						fEnt[1][2] = kvLoadBuild.GetFloat("o3");
						
						fOrigin[0] = fEnt[1][0] + g_fCrosshairOrigin[iClient][0];
						fOrigin[1] = fEnt[1][1] + g_fCrosshairOrigin[iClient][1];
						fOrigin[2] = fEnt[1][2] + g_fCrosshairOrigin[iClient][2];
						
						int iProp = Cel_SpawnEffect(iClient, fOrigin, view_as<EffectType>(kvLoadBuild.GetNum("effecttype")), view_as<bool>(kvLoadBuild.GetNum("effectenabled")), kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
						
						Cel_SetEntity(iProp, true);
						Entity_SetName(iProp, sBuffer[1]);
						Entity_SetSpawnFlags(iProp, kvLoadBuild.GetNum("spawnflags"));
						Entity_SetSkin(iProp, kvLoadBuild.GetNum("skin"));
						Cel_SetMotion(iProp, view_as<bool>(kvLoadBuild.GetNum("motion")));
						Cel_SetSolid(iProp, view_as<bool>(kvLoadBuild.GetNum("solid")));
						Cel_SetRenderFX(iProp, view_as<RenderFx>(kvLoadBuild.GetNum("renderfx")));
						Cel_SetOwner(iClient, iProp);
						
						Cel_SetColorFade(iProp, view_as<bool>(kvLoadBuild.GetNum("colorfading")), kvLoadBuild.GetNum("fc1-1"), kvLoadBuild.GetNum("fc1-2"), kvLoadBuild.GetNum("fc1-3"), kvLoadBuild.GetNum("fc2-1"), kvLoadBuild.GetNum("fc2-2"), kvLoadBuild.GetNum("fc2-3"));
						Cel_SetRainbow(iProp, view_as<bool>(kvLoadBuild.GetNum("colorrainbow")));
					}
					case ENTTYPE_INTERNET:
					{
						char sBuffer[4][PLATFORM_MAX_PATH];
						
						kvLoadBuild.GetString("classname", sBuffer[0], sizeof(sBuffer[]));
						kvLoadBuild.GetString("targetname", sBuffer[1], sizeof(sBuffer[]));
						kvLoadBuild.GetString("model", sBuffer[2], sizeof(sBuffer[]));
						kvLoadBuild.GetString("interneturl", sBuffer[3], sizeof(sBuffer[]));
						
						fEnt[0][0] = kvLoadBuild.GetFloat("a1");
						fEnt[0][1] = kvLoadBuild.GetFloat("a2");
						fEnt[0][2] = kvLoadBuild.GetFloat("a3");
						
						fEnt[1][0] = kvLoadBuild.GetFloat("o1");
						fEnt[1][1] = kvLoadBuild.GetFloat("o2");
						fEnt[1][2] = kvLoadBuild.GetFloat("o3");
						
						fOrigin[0] = fEnt[1][0] + g_fCrosshairOrigin[iClient][0];
						fOrigin[1] = fEnt[1][1] + g_fCrosshairOrigin[iClient][1];
						fOrigin[2] = fEnt[1][2] + g_fCrosshairOrigin[iClient][2];
						
						int iProp = Cel_SpawnInternet(iClient, sBuffer[3], fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
						
						Cel_SetEntity(iProp, true);
						Entity_SetName(iProp, sBuffer[1]);
						Entity_SetSpawnFlags(iProp, kvLoadBuild.GetNum("spawnflags"));
						Entity_SetSkin(iProp, kvLoadBuild.GetNum("skin"));
						Cel_SetMotion(iProp, view_as<bool>(kvLoadBuild.GetNum("motion")));
						Cel_SetSolid(iProp, view_as<bool>(kvLoadBuild.GetNum("solid")));
						Cel_SetRenderFX(iProp, view_as<RenderFx>(kvLoadBuild.GetNum("renderfx")));
						Cel_SetOwner(iClient, iProp);
						
						Cel_SetColorFade(iProp, view_as<bool>(kvLoadBuild.GetNum("colorfading")), kvLoadBuild.GetNum("fc1-1"), kvLoadBuild.GetNum("fc1-2"), kvLoadBuild.GetNum("fc1-3"), kvLoadBuild.GetNum("fc2-1"), kvLoadBuild.GetNum("fc2-2"), kvLoadBuild.GetNum("fc2-3"));
						Cel_SetRainbow(iProp, view_as<bool>(kvLoadBuild.GetNum("colorrainbow")));
					}
					case ENTTYPE_PHYSICS:
					{
						char sBuffer[4][PLATFORM_MAX_PATH];
						
						kvLoadBuild.GetString("classname", sBuffer[0], sizeof(sBuffer[]));
						kvLoadBuild.GetString("targetname", sBuffer[1], sizeof(sBuffer[]));
						kvLoadBuild.GetString("model", sBuffer[2], sizeof(sBuffer[]));
						kvLoadBuild.GetString("propname", sBuffer[3], sizeof(sBuffer[]));
						
						fEnt[0][0] = kvLoadBuild.GetFloat("a1");
						fEnt[0][1] = kvLoadBuild.GetFloat("a2");
						fEnt[0][2] = kvLoadBuild.GetFloat("a3");
						
						fEnt[1][0] = kvLoadBuild.GetFloat("o1");
						fEnt[1][1] = kvLoadBuild.GetFloat("o2");
						fEnt[1][2] = kvLoadBuild.GetFloat("o3");
						
						fOrigin[0] = fEnt[1][0] + g_fCrosshairOrigin[iClient][0];
						fOrigin[1] = fEnt[1][1] + g_fCrosshairOrigin[iClient][1];
						fOrigin[2] = fEnt[1][2] + g_fCrosshairOrigin[iClient][2];
						
						int iProp = Cel_SpawnProp(iClient, sBuffer[3], "prop_physics_override", sBuffer[2], fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
						
						Cel_SetEntity(iProp, true);
						Entity_SetName(iProp, sBuffer[1]);
						Entity_SetSpawnFlags(iProp, kvLoadBuild.GetNum("spawnflags"));
						Entity_SetSkin(iProp, kvLoadBuild.GetNum("skin"));
						Cel_SetMotion(iProp, view_as<bool>(kvLoadBuild.GetNum("motion")));
						Cel_SetSolid(iProp, view_as<bool>(kvLoadBuild.GetNum("solid")));
						Cel_SetRenderFX(iProp, view_as<RenderFx>(kvLoadBuild.GetNum("renderfx")));
						Cel_SetOwner(iClient, iProp);
						Cel_SetPropName(iProp, sBuffer[3]);
						
						Cel_SetColorFade(iProp, view_as<bool>(kvLoadBuild.GetNum("colorfading")), kvLoadBuild.GetNum("fc1-1"), kvLoadBuild.GetNum("fc1-2"), kvLoadBuild.GetNum("fc1-3"), kvLoadBuild.GetNum("fc2-1"), kvLoadBuild.GetNum("fc2-2"), kvLoadBuild.GetNum("fc2-3"));
						Cel_SetRainbow(iProp, view_as<bool>(kvLoadBuild.GetNum("colorrainbow")));
					}
					case ENTTYPE_UNKNOWN:
					{
						char sBuffer[4][PLATFORM_MAX_PATH];
						
						kvLoadBuild.GetString("classname", sBuffer[0], sizeof(sBuffer[]));
						kvLoadBuild.GetString("targetname", sBuffer[1], sizeof(sBuffer[]));
						kvLoadBuild.GetString("model", sBuffer[2], sizeof(sBuffer[]));
						kvLoadBuild.GetString("propname", sBuffer[3], sizeof(sBuffer[]));
						
						fEnt[0][0] = kvLoadBuild.GetFloat("a1");
						fEnt[0][1] = kvLoadBuild.GetFloat("a2");
						fEnt[0][2] = kvLoadBuild.GetFloat("a3");
						
						fEnt[1][0] = kvLoadBuild.GetFloat("o1");
						fEnt[1][1] = kvLoadBuild.GetFloat("o2");
						fEnt[1][2] = kvLoadBuild.GetFloat("o3");
						
						fOrigin[0] = fEnt[1][0] + g_fCrosshairOrigin[iClient][0];
						fOrigin[1] = fEnt[1][1] + g_fCrosshairOrigin[iClient][1];
						fOrigin[2] = fEnt[1][2] + g_fCrosshairOrigin[iClient][2];
						
						int iProp = Cel_SpawnProp(iClient, sBuffer[3], "prop_physics_override", sBuffer[2], fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
						
						Cel_SetEntity(iProp, true);
						Entity_SetName(iProp, sBuffer[1]);
						Entity_SetSpawnFlags(iProp, kvLoadBuild.GetNum("spawnflags"));
						Entity_SetSkin(iProp, kvLoadBuild.GetNum("skin"));
						Cel_SetMotion(iProp, view_as<bool>(kvLoadBuild.GetNum("motion")));
						Cel_SetSolid(iProp, view_as<bool>(kvLoadBuild.GetNum("solid")));
						Cel_SetRenderFX(iProp, view_as<RenderFx>(kvLoadBuild.GetNum("renderfx")));
						Cel_SetOwner(iClient, iProp);
						Cel_SetPropName(iProp, sBuffer[3]);
						
						Cel_SetColorFade(iProp, view_as<bool>(kvLoadBuild.GetNum("colorfading")), kvLoadBuild.GetNum("fc1-1"), kvLoadBuild.GetNum("fc1-2"), kvLoadBuild.GetNum("fc1-3"), kvLoadBuild.GetNum("fc2-1"), kvLoadBuild.GetNum("fc2-2"), kvLoadBuild.GetNum("fc2-3"));
						Cel_SetRainbow(iProp, view_as<bool>(kvLoadBuild.GetNum("colorrainbow")));
					}
				}
			}
			
			while (kvLoadBuild.GotoNextKey());
		}
		
		if(!kvLoadBuild.GotoNextKey())
		{
			kvLoadBuild.Close();	
		}
		
		Cel_ReplyToCommand(iClient, "%t", "LoadedBuild", sSaveName);
		
		return true;
	}else{
		kvLoadBuild.Close();
		
		Cel_ReplyToCommand(iClient, "%t", "SaveDoesntExist", sSaveName);
		
		return false;
	}
}

//Natives:
public int Native_SaveBuild(Handle hPlugin, int iNumParams)
{
	char sAuthID[64], sFile[2][PLATFORM_MAX_PATH], sRelPath[PLATFORM_MAX_PATH], sSaveName[96], sCount[32];
	float fEnt[2][3], fLandPos[2][3], fMiddle[3], fOrigin[3];
	int iClient = GetNativeCell(1), iColor[4], iCount = 0, iFadeColor[2][3], iLand;
	
	GetNativeString(2, sSaveName, sizeof(sSaveName));
	
	Cel_GetLandPositions(iClient, 1, fLandPos[0]);
	Cel_GetLandPositions(iClient, 4, fLandPos[1]);
	
	if(fLandPos[0][0] == 0.0 && fLandPos[0][1] == 0.0 && fLandPos[0][2] == 0.0 && fLandPos[1][0] == 0.0 && fLandPos[1][1] == 0.0 && fLandPos[1][2] == 0.0)
	{
		Cel_ReplyToCommand(iClient, "%t", "PropsWontSave");
		Cel_ReplyToCommand(iClient, "%t", "SetUpLandArea");
		
		return false;
	}
	
	Cel_GetAuthID(iClient, sAuthID, sizeof(sAuthID));
	
	Format(sRelPath, sizeof(sRelPath), "data/celmod/users/%s/saves/%s.txt", sAuthID, sSaveName);
	
	BuildPath(Path_SM, sFile[0], sizeof(sFile[]), sRelPath);
	
	if (FileExists(sFile[0]))
	{
		switch(g_iSaveOverride[iClient])
		{
			case 0:
			{
				Cel_ReplyToCommand(iClient, "%t", "SaveOverriteWarning", sSaveName);
				Cel_ReplyToCommand(iClient, "%t", "SaveOverriteConfirm", sSaveName);
				
				g_iSaveOverride[iClient] = 1;
				
				return false;
			}
			
			case 1:
			{
				DeleteFile(sFile[0]);
				
				BuildPath(Path_SM, sFile[0], sizeof(sFile[]), sRelPath);
				
				g_iSaveOverride[iClient] = 0;
			}
		}
	}
	
	Cel_GetMiddleOfABox(fLandPos[0], fLandPos[1], fMiddle);
	
	fMiddle[2] = (fLandPos[0][2]);
	
	KeyValues kvSaveBuild = new KeyValues("Vault");
	
	kvSaveBuild.ImportFromFile(sFile[0]);
	
	for (int i = 0; i < GetMaxEntities(); i++)
	{
		if (Cel_CheckOwner(iClient, i))
		{
			if(Cel_IsEntityInLand(i))
			{
				Cel_GetEntityOrigin(i, fEnt[1]);
				
				iLand = Cel_GetLandOwnerFromPosition(fEnt[1]);
				
				if(iLand == iClient)
				{
					iCount++;
					
					IntToString(iCount, sCount, sizeof(sCount));
					
					switch(Cel_GetEntityType(i))
					{
						case ENTTYPE_CYCLER:
						{
							char sBuffer[4][PLATFORM_MAX_PATH];
							
							Entity_GetClassName(i, sBuffer[0], sizeof(sBuffer[]));
							Entity_GetName(i, sBuffer[1], sizeof(sBuffer[]));
							Entity_GetModel(i, sBuffer[2], sizeof(sBuffer[]));
							Cel_GetPropName(i, sBuffer[3], sizeof(sBuffer[]));
							
							Entity_GetRenderColor(i, iColor);
							Cel_GetFadeColor(i, iFadeColor[0], iFadeColor[1]);
							
							Cel_GetEntityAngles(i, fEnt[0]);
							
							Cel_GetEntityOrigin(i, fEnt[1]);
							
							fOrigin[0] = fEnt[1][0] - fMiddle[0];
							fOrigin[1] = fEnt[1][1] - fMiddle[1];
							fOrigin[2] = fEnt[1][2] - fMiddle[2];
							
							kvSaveBuild.JumpToKey(sCount, true);
							
							kvSaveBuild.SetNum("entitytype", view_as<int>(Cel_GetEntityType(i)));
							
							kvSaveBuild.SetString("classname", sBuffer[0]);
							kvSaveBuild.SetString("targetname", sBuffer[1]);
							kvSaveBuild.SetString("model", sBuffer[2]);
							kvSaveBuild.SetString("propname", sBuffer[3]);
							
							kvSaveBuild.SetNum("spawnflags", Entity_GetSpawnFlags(i));
							kvSaveBuild.SetNum("skin", Entity_GetSkin(i));
							kvSaveBuild.SetNum("motion", view_as<int>(Cel_GetMotion(i)));
							kvSaveBuild.SetNum("renderfx", view_as<int>(Cel_GetRenderFX(i)));
							kvSaveBuild.SetNum("animsequence", Entity_GetAnimSequence(i));
							
							kvSaveBuild.SetNum("c1", iColor[0]);
							kvSaveBuild.SetNum("c2", iColor[1]);
							kvSaveBuild.SetNum("c3", iColor[2]);
							kvSaveBuild.SetNum("c4", iColor[3]);
							
							kvSaveBuild.SetFloat("a1", fEnt[0][0]);
							kvSaveBuild.SetFloat("a2", fEnt[0][1]);
							kvSaveBuild.SetFloat("a3", fEnt[0][2]);
							
							kvSaveBuild.SetFloat("o1", fOrigin[0]);
							kvSaveBuild.SetFloat("o2", fOrigin[1]);
							kvSaveBuild.SetFloat("o3", fOrigin[2]);
							
							kvSaveBuild.SetNum("fc1-1", iFadeColor[0][0]);
							kvSaveBuild.SetNum("fc1-2", iFadeColor[0][1]);
							kvSaveBuild.SetNum("fc1-3", iFadeColor[0][2]);
							kvSaveBuild.SetNum("fc2-1", iFadeColor[1][0]);
							kvSaveBuild.SetNum("fc2-2", iFadeColor[1][1]);
							kvSaveBuild.SetNum("fc2-3", iFadeColor[1][2]);
							
							kvSaveBuild.SetNum("colorfading", view_as<int>(Cel_IsFading(i)));
							kvSaveBuild.SetNum("colorrainbow", view_as<int>(Cel_IsRainbow(i)));
							
							kvSaveBuild.Rewind();
						}
						case ENTTYPE_DOOR:
						{
							char sBuffer[3][PLATFORM_MAX_PATH];
							
							Entity_GetClassName(i, sBuffer[0], sizeof(sBuffer[]));
							Entity_GetName(i, sBuffer[1], sizeof(sBuffer[]));
							Entity_GetModel(i, sBuffer[2], sizeof(sBuffer[]));
							
							Entity_GetRenderColor(i, iColor);
							Cel_GetFadeColor(i, iFadeColor[0], iFadeColor[1]);
							
							Cel_GetEntityAngles(i, fEnt[0]);
							
							Cel_GetEntityOrigin(i, fEnt[1]);
							
							fOrigin[0] = fEnt[1][0] - fMiddle[0];
							fOrigin[1] = fEnt[1][1] - fMiddle[1];
							fOrigin[2] = fEnt[1][2] - fMiddle[2];
							
							fOrigin[2] -= 54;
							
							kvSaveBuild.JumpToKey(sCount, true);
							
							kvSaveBuild.SetNum("entitytype", view_as<int>(Cel_GetEntityType(i)));
							
							kvSaveBuild.SetString("classname", sBuffer[0]);
							kvSaveBuild.SetString("targetname", sBuffer[1]);
							kvSaveBuild.SetString("model", sBuffer[2]);
							
							kvSaveBuild.SetNum("spawnflags", Entity_GetSpawnFlags(i));
							kvSaveBuild.SetNum("skin", Entity_GetSkin(i));
							kvSaveBuild.SetNum("motion", view_as<int>(Cel_GetMotion(i)));
							kvSaveBuild.SetNum("renderfx", view_as<int>(Cel_GetRenderFX(i)));
							kvSaveBuild.SetNum("solid", view_as<int>(Cel_IsSolid(i)));
							
							kvSaveBuild.SetNum("c1", iColor[0]);
							kvSaveBuild.SetNum("c2", iColor[1]);
							kvSaveBuild.SetNum("c3", iColor[2]);
							kvSaveBuild.SetNum("c4", iColor[3]);
							
							kvSaveBuild.SetFloat("a1", fEnt[0][0]);
							kvSaveBuild.SetFloat("a2", fEnt[0][1]);
							kvSaveBuild.SetFloat("a3", fEnt[0][2]);
							
							kvSaveBuild.SetFloat("o1", fOrigin[0]);
							kvSaveBuild.SetFloat("o2", fOrigin[1]);
							kvSaveBuild.SetFloat("o3", fOrigin[2]);
							
							kvSaveBuild.SetNum("fc1-1", iFadeColor[0][0]);
							kvSaveBuild.SetNum("fc1-2", iFadeColor[0][1]);
							kvSaveBuild.SetNum("fc1-3", iFadeColor[0][2]);
							kvSaveBuild.SetNum("fc2-1", iFadeColor[1][0]);
							kvSaveBuild.SetNum("fc2-2", iFadeColor[1][1]);
							kvSaveBuild.SetNum("fc2-3", iFadeColor[1][2]);
							
							kvSaveBuild.SetNum("colorfading", view_as<int>(Cel_IsFading(i)));
							kvSaveBuild.SetNum("colorrainbow", view_as<int>(Cel_IsRainbow(i)));
							
							kvSaveBuild.Rewind();
						}
						case ENTTYPE_DYNAMIC:
						{
							char sBuffer[4][PLATFORM_MAX_PATH];
							
							Entity_GetClassName(i, sBuffer[0], sizeof(sBuffer[]));
							Entity_GetName(i, sBuffer[1], sizeof(sBuffer[]));
							Entity_GetModel(i, sBuffer[2], sizeof(sBuffer[]));
							Cel_GetPropName(i, sBuffer[3], sizeof(sBuffer[]));
							
							Entity_GetRenderColor(i, iColor);
							Cel_GetFadeColor(i, iFadeColor[0], iFadeColor[1]);
							
							Cel_GetEntityAngles(i, fEnt[0]);
							
							Cel_GetEntityOrigin(i, fEnt[1]);
							
							fOrigin[0] = fEnt[1][0] - fMiddle[0];
							fOrigin[1] = fEnt[1][1] - fMiddle[1];
							fOrigin[2] = fEnt[1][2] - fMiddle[2];
							
							kvSaveBuild.JumpToKey(sCount, true);
							
							kvSaveBuild.SetNum("entitytype", view_as<int>(ENTTYPE_PHYSICS));
							
							kvSaveBuild.SetString("classname", sBuffer[0]);
							kvSaveBuild.SetString("targetname", sBuffer[1]);
							kvSaveBuild.SetString("model", sBuffer[2]);
							kvSaveBuild.SetString("propname", sBuffer[3]);
							
							kvSaveBuild.SetNum("spawnflags", Entity_GetSpawnFlags(i));
							kvSaveBuild.SetNum("skin", Entity_GetSkin(i));
							kvSaveBuild.SetNum("motion", view_as<int>(Cel_GetMotion(i)));
							kvSaveBuild.SetNum("renderfx", view_as<int>(Cel_GetRenderFX(i)));
							kvSaveBuild.SetNum("solid", view_as<int>(Cel_IsSolid(i)));
							
							kvSaveBuild.SetNum("c1", iColor[0]);
							kvSaveBuild.SetNum("c2", iColor[1]);
							kvSaveBuild.SetNum("c3", iColor[2]);
							kvSaveBuild.SetNum("c4", iColor[3]);
							
							kvSaveBuild.SetFloat("a1", fEnt[0][0]);
							kvSaveBuild.SetFloat("a2", fEnt[0][1]);
							kvSaveBuild.SetFloat("a3", fEnt[0][2]);
							
							kvSaveBuild.SetFloat("o1", fOrigin[0]);
							kvSaveBuild.SetFloat("o2", fOrigin[1]);
							kvSaveBuild.SetFloat("o3", fOrigin[2]);
							
							kvSaveBuild.SetNum("fc1-1", iFadeColor[0][0]);
							kvSaveBuild.SetNum("fc1-2", iFadeColor[0][1]);
							kvSaveBuild.SetNum("fc1-3", iFadeColor[0][2]);
							kvSaveBuild.SetNum("fc2-1", iFadeColor[1][0]);
							kvSaveBuild.SetNum("fc2-2", iFadeColor[1][1]);
							kvSaveBuild.SetNum("fc2-3", iFadeColor[1][2]);
							
							kvSaveBuild.SetNum("colorfading", view_as<int>(Cel_IsFading(i)));
							kvSaveBuild.SetNum("colorrainbow", view_as<int>(Cel_IsRainbow(i)));
							
							kvSaveBuild.Rewind();
						}
						case ENTTYPE_EFFECT:
						{
							char sBuffer[3][PLATFORM_MAX_PATH];
							
							Entity_GetClassName(i, sBuffer[0], sizeof(sBuffer[]));
							Entity_GetName(i, sBuffer[1], sizeof(sBuffer[]));
							Entity_GetModel(i, sBuffer[2], sizeof(sBuffer[]));
							
							Entity_GetRenderColor(i, iColor);
							Cel_GetFadeColor(i, iFadeColor[0], iFadeColor[1]);
							
							Cel_GetEntityAngles(i, fEnt[0]);
							
							Cel_GetEntityOrigin(i, fEnt[1]);
							
							fOrigin[0] = fEnt[1][0] - fMiddle[0];
							fOrigin[1] = fEnt[1][1] - fMiddle[1];
							fOrigin[2] = fEnt[1][2] - fMiddle[2];
							
							kvSaveBuild.JumpToKey(sCount, true);
							
							kvSaveBuild.SetNum("entitytype", view_as<int>(Cel_GetEntityType(i)));
							
							kvSaveBuild.SetString("classname", sBuffer[0]);
							kvSaveBuild.SetString("targetname", sBuffer[1]);
							kvSaveBuild.SetString("model", sBuffer[2]);
							
							kvSaveBuild.SetNum("spawnflags", Entity_GetSpawnFlags(i));
							kvSaveBuild.SetNum("skin", Entity_GetSkin(i));
							kvSaveBuild.SetNum("motion", view_as<int>(Cel_GetMotion(i)));
							kvSaveBuild.SetNum("renderfx", view_as<int>(Cel_GetRenderFX(i)));
							kvSaveBuild.SetNum("solid", view_as<int>(Cel_IsSolid(i)));
							kvSaveBuild.SetNum("effecttype", view_as<int>(Cel_GetEffectType(i)));
							kvSaveBuild.SetNum("effectenabled", view_as<int>(Cel_IsEffectActive(i)));
							
							kvSaveBuild.SetNum("c1", iColor[0]);
							kvSaveBuild.SetNum("c2", iColor[1]);
							kvSaveBuild.SetNum("c3", iColor[2]);
							kvSaveBuild.SetNum("c4", iColor[3]);
							
							kvSaveBuild.SetFloat("a1", fEnt[0][0]);
							kvSaveBuild.SetFloat("a2", fEnt[0][1]);
							kvSaveBuild.SetFloat("a3", fEnt[0][2]);
							
							kvSaveBuild.SetFloat("o1", fOrigin[0]);
							kvSaveBuild.SetFloat("o2", fOrigin[1]);
							kvSaveBuild.SetFloat("o3", fOrigin[2]);
							
							kvSaveBuild.SetNum("fc1-1", iFadeColor[0][0]);
							kvSaveBuild.SetNum("fc1-2", iFadeColor[0][1]);
							kvSaveBuild.SetNum("fc1-3", iFadeColor[0][2]);
							kvSaveBuild.SetNum("fc2-1", iFadeColor[1][0]);
							kvSaveBuild.SetNum("fc2-2", iFadeColor[1][1]);
							kvSaveBuild.SetNum("fc2-3", iFadeColor[1][2]);
							
							kvSaveBuild.SetNum("colorfading", view_as<int>(Cel_IsFading(i)));
							kvSaveBuild.SetNum("colorrainbow", view_as<int>(Cel_IsRainbow(i)));
							
							kvSaveBuild.Rewind();
						}
						case ENTTYPE_INTERNET:
						{
							char sBuffer[4][PLATFORM_MAX_PATH];
							
							Entity_GetClassName(i, sBuffer[0], sizeof(sBuffer[]));
							Entity_GetName(i, sBuffer[1], sizeof(sBuffer[]));
							Entity_GetModel(i, sBuffer[2], sizeof(sBuffer[]));
							Cel_GetInternetURL(i, sBuffer[3], sizeof(sBuffer[]));
							
							Entity_GetRenderColor(i, iColor);
							Cel_GetFadeColor(i, iFadeColor[0], iFadeColor[1]);
							
							Cel_GetEntityAngles(i, fEnt[0]);
							
							Cel_GetEntityOrigin(i, fEnt[1]);
							
							fOrigin[0] = fEnt[1][0] - fMiddle[0];
							fOrigin[1] = fEnt[1][1] - fMiddle[1];
							fOrigin[2] = fEnt[1][2] - fMiddle[2];
							
							kvSaveBuild.JumpToKey(sCount, true);
							
							kvSaveBuild.SetNum("entitytype", view_as<int>(Cel_GetEntityType(i)));
							
							kvSaveBuild.SetString("classname", sBuffer[0]);
							kvSaveBuild.SetString("targetname", sBuffer[1]);
							kvSaveBuild.SetString("model", sBuffer[2]);
							kvSaveBuild.SetString("interneturl", sBuffer[3]);
							
							kvSaveBuild.SetNum("spawnflags", Entity_GetSpawnFlags(i));
							kvSaveBuild.SetNum("skin", Entity_GetSkin(i));
							kvSaveBuild.SetNum("motion", view_as<int>(Cel_GetMotion(i)));
							kvSaveBuild.SetNum("renderfx", view_as<int>(Cel_GetRenderFX(i)));
							kvSaveBuild.SetNum("solid", view_as<int>(Cel_IsSolid(i)));
							
							kvSaveBuild.SetNum("c1", iColor[0]);
							kvSaveBuild.SetNum("c2", iColor[1]);
							kvSaveBuild.SetNum("c3", iColor[2]);
							kvSaveBuild.SetNum("c4", iColor[3]);
							
							kvSaveBuild.SetFloat("a1", fEnt[0][0]);
							kvSaveBuild.SetFloat("a2", fEnt[0][1]);
							kvSaveBuild.SetFloat("a3", fEnt[0][2]);
							
							kvSaveBuild.SetFloat("o1", fOrigin[0]);
							kvSaveBuild.SetFloat("o2", fOrigin[1]);
							kvSaveBuild.SetFloat("o3", fOrigin[2]);
							
							kvSaveBuild.SetNum("fc1-1", iFadeColor[0][0]);
							kvSaveBuild.SetNum("fc1-2", iFadeColor[0][1]);
							kvSaveBuild.SetNum("fc1-3", iFadeColor[0][2]);
							kvSaveBuild.SetNum("fc2-1", iFadeColor[1][0]);
							kvSaveBuild.SetNum("fc2-2", iFadeColor[1][1]);
							kvSaveBuild.SetNum("fc2-3", iFadeColor[1][2]);
							
							kvSaveBuild.SetNum("colorfading", view_as<int>(Cel_IsFading(i)));
							kvSaveBuild.SetNum("colorrainbow", view_as<int>(Cel_IsRainbow(i)));
							
							kvSaveBuild.Rewind();
						}
						case ENTTYPE_PHYSICS:
						{
							char sBuffer[4][PLATFORM_MAX_PATH];
							
							Entity_GetClassName(i, sBuffer[0], sizeof(sBuffer[]));
							Entity_GetName(i, sBuffer[1], sizeof(sBuffer[]));
							Entity_GetModel(i, sBuffer[2], sizeof(sBuffer[]));
							Cel_GetPropName(i, sBuffer[3], sizeof(sBuffer[]));
							
							Entity_GetRenderColor(i, iColor);
							Cel_GetFadeColor(i, iFadeColor[0], iFadeColor[1]);
							
							Cel_GetEntityAngles(i, fEnt[0]);
							
							Cel_GetEntityOrigin(i, fEnt[1]);
							
							fOrigin[0] = fEnt[1][0] - fMiddle[0];
							fOrigin[1] = fEnt[1][1] - fMiddle[1];
							fOrigin[2] = fEnt[1][2] - fMiddle[2];
							
							kvSaveBuild.JumpToKey(sCount, true);
							
							kvSaveBuild.SetNum("entitytype", view_as<int>(Cel_GetEntityType(i)));
							
							kvSaveBuild.SetString("classname", sBuffer[0]);
							kvSaveBuild.SetString("targetname", sBuffer[1]);
							kvSaveBuild.SetString("model", sBuffer[2]);
							kvSaveBuild.SetString("propname", sBuffer[3]);
							
							kvSaveBuild.SetNum("spawnflags", Entity_GetSpawnFlags(i));
							kvSaveBuild.SetNum("skin", Entity_GetSkin(i));
							kvSaveBuild.SetNum("motion", view_as<int>(Cel_GetMotion(i)));
							kvSaveBuild.SetNum("renderfx", view_as<int>(Cel_GetRenderFX(i)));
							kvSaveBuild.SetNum("solid", view_as<int>(Cel_IsSolid(i)));
							
							kvSaveBuild.SetNum("c1", iColor[0]);
							kvSaveBuild.SetNum("c2", iColor[1]);
							kvSaveBuild.SetNum("c3", iColor[2]);
							kvSaveBuild.SetNum("c4", iColor[3]);
							
							kvSaveBuild.SetFloat("a1", fEnt[0][0]);
							kvSaveBuild.SetFloat("a2", fEnt[0][1]);
							kvSaveBuild.SetFloat("a3", fEnt[0][2]);
							
							kvSaveBuild.SetFloat("o1", fOrigin[0]);
							kvSaveBuild.SetFloat("o2", fOrigin[1]);
							kvSaveBuild.SetFloat("o3", fOrigin[2]);
							
							kvSaveBuild.SetNum("fc1-1", iFadeColor[0][0]);
							kvSaveBuild.SetNum("fc1-2", iFadeColor[0][1]);
							kvSaveBuild.SetNum("fc1-3", iFadeColor[0][2]);
							kvSaveBuild.SetNum("fc2-1", iFadeColor[1][0]);
							kvSaveBuild.SetNum("fc2-2", iFadeColor[1][1]);
							kvSaveBuild.SetNum("fc2-3", iFadeColor[1][2]);
							
							kvSaveBuild.SetNum("colorfading", view_as<int>(Cel_IsFading(i)));
							kvSaveBuild.SetNum("colorrainbow", view_as<int>(Cel_IsRainbow(i)));
							
							kvSaveBuild.Rewind();
						}
					}
				}
			}
		}
	}
	
	kvSaveBuild.ExportToFile(sFile[0]);
	
	kvSaveBuild.Close();
	
	g_iSaveOverride[iClient] = 0;
	
	Cel_ReplyToCommand(iClient, "%t", "SavedBuild", sSaveName);
	
	return true;
}
