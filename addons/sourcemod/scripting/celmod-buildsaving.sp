#pragma semicolon 1

#include <celmod>

#pragma newdecls required

#define SAVESYSTEM 1
#define SAVESYSTEM_STRING "CELSS-1-"

bool g_bLate;

float g_fCrosshairOrigin[MAXPLAYERS + 1][3];

int g_iSaveOverride[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_GetSaveSystemVersion", Native_GetSaveSystemVersion);
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
	char sAuthID[64], sBuffer[PLATFORM_MAX_PATH], sFile[PLATFORM_MAX_PATH], sSaveName[96];
	File fFile;
	float fDelay = 0.05;
	Handle hLoadTimer;
	int iClient = GetNativeCell(1);
	
	GetNativeString(2, sSaveName, sizeof(sSaveName));
	
	Cel_GetAuthID(iClient, sAuthID, sizeof(sAuthID));
	
	Cel_GetCrosshairHitOrigin(iClient, g_fCrosshairOrigin[iClient]);
	
	BuildPath(Path_SM, sFile, sizeof(sFile), "data/celmod/users/%s/saves/%s.txt", sAuthID, sSaveName);
	
	fFile = OpenFile(sFile, "r");
	
	if (FileExists(sFile))
	{
		while (fFile.ReadLine(sBuffer, sizeof(sBuffer)))
		{
			if(!StrEqual(sBuffer, ""))
			{
				CreateDataTimer(fDelay, Timer_LoadBuild, hLoadTimer);
				
				WritePackCell(hLoadTimer, iClient);
				WritePackString(hLoadTimer, sBuffer);
				
				fDelay += 0.05;
			}
		}
		
		Cel_ReplyToCommand(iClient, "%t", "LoadedBuild", sSaveName);
		
		return true;
	}else{
		Cel_ReplyToCommand(iClient, "%t", "SaveDoesntExist", sSaveName);
		
		return false;
	}
}

//Natives:
public int Native_GetSaveSystemVersion(Handle hPlugin, int iNumParams)
{
	return SAVESYSTEM;
}

public int Native_SaveBuild(Handle hPlugin, int iNumParams)
{
	char sAuthID[64], sFile[2][PLATFORM_MAX_PATH], sOutput[PLATFORM_MAX_PATH], sSaveName[96];
	float fEnt[2][3], fLandPos[2][3], fMiddle[3], fOrigin[3];
	int iClient = GetNativeCell(1), iColor[4], iLand;
	
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
	
	BuildPath(Path_SM, sFile[0], sizeof(sFile[]), "data/celmod/users/%s/saves/%s.txt", sAuthID, sSaveName);
	
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
				//DeleteFile(sFile[0]);
				
				BuildPath(Path_SM, sFile[1], sizeof(sFile[]), "data/celmod/users/%s/saves/%s_temp.txt", sAuthID, sSaveName);
				
				RenameFile(sFile[1], sFile[0]);
				
				BuildPath(Path_SM, sFile[0], sizeof(sFile[]), "data/celmod/users/%s/saves/%s.txt", sAuthID, sSaveName);
				
				g_iSaveOverride[iClient] = 2;
			}
		}
	}
	
	Cel_GetMiddleOfABox(fLandPos[0], fLandPos[1], fMiddle);
	
	fMiddle[2] = (fLandPos[0][2]);
	
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
					switch(Cel_GetEntityType(i))
					{
						case ENTTYPE_CYCLER:
						{
							char sBuffer[20][PLATFORM_MAX_PATH];
							
							IntToString(view_as<int>(Cel_GetEntityType(i)), sBuffer[0], sizeof(sBuffer[]));
							
							Entity_GetClassName(i, sBuffer[1], sizeof(sBuffer[]));
							Entity_GetName(i, sBuffer[2], sizeof(sBuffer[]));
							Entity_GetModel(i, sBuffer[3], sizeof(sBuffer[]));
							IntToString(Entity_GetSpawnFlags(i), sBuffer[4], sizeof(sBuffer[]));
							IntToString(Entity_GetSkin(i), sBuffer[5], sizeof(sBuffer[]));
							IntToString(view_as<int>(Cel_GetMotion(i)), sBuffer[6], sizeof(sBuffer[]));
							
							IntToString(view_as<int>(Cel_GetRenderFX(i)), sBuffer[7], sizeof(sBuffer[]));
							
							Entity_GetRenderColor(i, iColor);
							IntToString(iColor[0], sBuffer[8], sizeof(sBuffer[]));
							IntToString(iColor[1], sBuffer[9], sizeof(sBuffer[]));
							IntToString(iColor[2], sBuffer[10], sizeof(sBuffer[]));
							IntToString(iColor[3], sBuffer[11], sizeof(sBuffer[]));
							
							Cel_GetEntityAngles(i, fEnt[0]);
							FloatToString(fEnt[0][0], sBuffer[12], sizeof(sBuffer[]));
							FloatToString(fEnt[0][1], sBuffer[13], sizeof(sBuffer[]));
							FloatToString(fEnt[0][2], sBuffer[14], sizeof(sBuffer[]));
							
							Cel_GetEntityOrigin(i, fEnt[1]);
							
							fOrigin[0] = fEnt[1][0] - fMiddle[0];
							fOrigin[1] = fEnt[1][1] - fMiddle[1];
							fOrigin[2] = fEnt[1][2] - fMiddle[2];
							
							FloatToString(fOrigin[0], sBuffer[15], sizeof(sBuffer[]));
							FloatToString(fOrigin[1], sBuffer[16], sizeof(sBuffer[]));
							FloatToString(fOrigin[2], sBuffer[17], sizeof(sBuffer[]));
							
							Cel_GetPropName(i, sBuffer[18], sizeof(sBuffer[]));
							IntToString(Entity_GetAnimSequence(i), sBuffer[19], sizeof(sBuffer[]));
							
							ImplodeStrings(sBuffer, 20, "^", sOutput, sizeof(sOutput));
						}
						case ENTTYPE_DOOR:
						{
							char sBuffer[19][PLATFORM_MAX_PATH];
							
							IntToString(view_as<int>(Cel_GetEntityType(i)), sBuffer[0], sizeof(sBuffer[]));
							
							Entity_GetClassName(i, sBuffer[1], sizeof(sBuffer[]));
							Entity_GetName(i, sBuffer[2], sizeof(sBuffer[]));
							Entity_GetModel(i, sBuffer[3], sizeof(sBuffer[]));
							IntToString(Entity_GetSpawnFlags(i), sBuffer[4], sizeof(sBuffer[]));
							IntToString(Entity_GetSkin(i), sBuffer[5], sizeof(sBuffer[]));
							IntToString(view_as<int>(Cel_GetMotion(i)), sBuffer[6], sizeof(sBuffer[]));
							IntToString(view_as<int>(Cel_IsSolid(i)), sBuffer[7], sizeof(sBuffer[]));
							
							IntToString(view_as<int>(Cel_GetRenderFX(i)), sBuffer[8], sizeof(sBuffer[]));
							
							Entity_GetRenderColor(i, iColor);
							IntToString(iColor[0], sBuffer[9], sizeof(sBuffer[]));
							IntToString(iColor[1], sBuffer[10], sizeof(sBuffer[]));
							IntToString(iColor[2], sBuffer[11], sizeof(sBuffer[]));
							IntToString(iColor[3], sBuffer[12], sizeof(sBuffer[]));
							
							Cel_GetEntityAngles(i, fEnt[0]);
							FloatToString(fEnt[0][0], sBuffer[13], sizeof(sBuffer[]));
							FloatToString(fEnt[0][1], sBuffer[14], sizeof(sBuffer[]));
							FloatToString(fEnt[0][2], sBuffer[15], sizeof(sBuffer[]));
							
							Cel_GetEntityOrigin(i, fEnt[1]);
							
							fOrigin[0] = fEnt[1][0] - fMiddle[0];
							fOrigin[1] = fEnt[1][1] - fMiddle[1];
							fOrigin[2] = fEnt[1][2] - fMiddle[2];
							
							fOrigin[2] -= 54;
							
							FloatToString(fOrigin[0], sBuffer[16], sizeof(sBuffer[]));
							FloatToString(fOrigin[1], sBuffer[17], sizeof(sBuffer[]));
							FloatToString(fOrigin[2], sBuffer[18], sizeof(sBuffer[]));
							
							ImplodeStrings(sBuffer, 19, "^", sOutput, sizeof(sOutput));
						}
						case ENTTYPE_DYNAMIC:
						{
							char sBuffer[20][PLATFORM_MAX_PATH];
							
							IntToString(view_as<int>(ENTTYPE_PHYSICS), sBuffer[0], sizeof(sBuffer[]));
							
							Entity_GetClassName(i, sBuffer[1], sizeof(sBuffer[]));
							Entity_GetName(i, sBuffer[2], sizeof(sBuffer[]));
							Entity_GetModel(i, sBuffer[3], sizeof(sBuffer[]));
							IntToString(Entity_GetSpawnFlags(i), sBuffer[4], sizeof(sBuffer[]));
							IntToString(Entity_GetSkin(i), sBuffer[5], sizeof(sBuffer[]));
							IntToString(view_as<int>(Cel_GetMotion(i)), sBuffer[6], sizeof(sBuffer[]));
							IntToString(view_as<int>(Cel_IsSolid(i)), sBuffer[7], sizeof(sBuffer[]));
							
							IntToString(view_as<int>(Cel_GetRenderFX(i)), sBuffer[8], sizeof(sBuffer[]));
							
							Entity_GetRenderColor(i, iColor);
							IntToString(iColor[0], sBuffer[9], sizeof(sBuffer[]));
							IntToString(iColor[1], sBuffer[10], sizeof(sBuffer[]));
							IntToString(iColor[2], sBuffer[11], sizeof(sBuffer[]));
							IntToString(iColor[3], sBuffer[12], sizeof(sBuffer[]));
							
							Cel_GetEntityAngles(i, fEnt[0]);
							FloatToString(fEnt[0][0], sBuffer[13], sizeof(sBuffer[]));
							FloatToString(fEnt[0][1], sBuffer[14], sizeof(sBuffer[]));
							FloatToString(fEnt[0][2], sBuffer[15], sizeof(sBuffer[]));
							
							Cel_GetEntityOrigin(i, fEnt[1]);
							
							fOrigin[0] = fEnt[1][0] - fMiddle[0];
							fOrigin[1] = fEnt[1][1] - fMiddle[1];
							fOrigin[2] = fEnt[1][2] - fMiddle[2];
							
							FloatToString(fOrigin[0], sBuffer[16], sizeof(sBuffer[]));
							FloatToString(fOrigin[1], sBuffer[17], sizeof(sBuffer[]));
							FloatToString(fOrigin[2], sBuffer[18], sizeof(sBuffer[]));
							
							Cel_GetPropName(i, sBuffer[19], sizeof(sBuffer[]));
							
							ImplodeStrings(sBuffer, 20, "^", sOutput, sizeof(sOutput));
						}
						case ENTTYPE_EFFECT:
						{
							char sBuffer[21][PLATFORM_MAX_PATH];
							
							IntToString(view_as<int>(Cel_GetEntityType(i)), sBuffer[0], sizeof(sBuffer[]));
							
							Entity_GetClassName(i, sBuffer[1], sizeof(sBuffer[]));
							Entity_GetName(i, sBuffer[2], sizeof(sBuffer[]));
							Entity_GetModel(i, sBuffer[3], sizeof(sBuffer[]));
							IntToString(Entity_GetSpawnFlags(i), sBuffer[4], sizeof(sBuffer[]));
							IntToString(Entity_GetSkin(i), sBuffer[5], sizeof(sBuffer[]));
							IntToString(view_as<int>(Cel_GetMotion(i)), sBuffer[6], sizeof(sBuffer[]));
							IntToString(view_as<int>(Cel_IsSolid(i)), sBuffer[7], sizeof(sBuffer[]));
							
							IntToString(view_as<int>(Cel_GetRenderFX(i)), sBuffer[8], sizeof(sBuffer[]));
							
							Entity_GetRenderColor(i, iColor);
							IntToString(iColor[0], sBuffer[9], sizeof(sBuffer[]));
							IntToString(iColor[1], sBuffer[10], sizeof(sBuffer[]));
							IntToString(iColor[2], sBuffer[11], sizeof(sBuffer[]));
							IntToString(iColor[3], sBuffer[12], sizeof(sBuffer[]));
							
							Cel_GetEntityAngles(i, fEnt[0]);
							FloatToString(fEnt[0][0], sBuffer[13], sizeof(sBuffer[]));
							FloatToString(fEnt[0][1], sBuffer[14], sizeof(sBuffer[]));
							FloatToString(fEnt[0][2], sBuffer[15], sizeof(sBuffer[]));
							
							Cel_GetEntityOrigin(i, fEnt[1]);
							
							fOrigin[0] = fEnt[1][0] - fMiddle[0];
							fOrigin[1] = fEnt[1][1] - fMiddle[1];
							fOrigin[2] = fEnt[1][2] - fMiddle[2];
							
							FloatToString(fOrigin[0], sBuffer[16], sizeof(sBuffer[]));
							FloatToString(fOrigin[1], sBuffer[17], sizeof(sBuffer[]));
							FloatToString(fOrigin[2], sBuffer[18], sizeof(sBuffer[]));
							
							IntToString(view_as<int>(Cel_GetEffectType(i)), sBuffer[19], sizeof(sBuffer[]));
							IntToString(view_as<int>(Cel_IsEffectActive(i)), sBuffer[20], sizeof(sBuffer[]));
							
							ImplodeStrings(sBuffer, 21, "^", sOutput, sizeof(sOutput));
						}
						case ENTTYPE_INTERNET:
						{
							char sBuffer[20][PLATFORM_MAX_PATH];
							
							IntToString(view_as<int>(Cel_GetEntityType(i)), sBuffer[0], sizeof(sBuffer[]));
							
							Entity_GetClassName(i, sBuffer[1], sizeof(sBuffer[]));
							Entity_GetName(i, sBuffer[2], sizeof(sBuffer[]));
							Entity_GetModel(i, sBuffer[3], sizeof(sBuffer[]));
							IntToString(Entity_GetSpawnFlags(i), sBuffer[4], sizeof(sBuffer[]));
							IntToString(Entity_GetSkin(i), sBuffer[5], sizeof(sBuffer[]));
							IntToString(view_as<int>(Cel_GetMotion(i)), sBuffer[6], sizeof(sBuffer[]));
							IntToString(view_as<int>(Cel_IsSolid(i)), sBuffer[7], sizeof(sBuffer[]));
							
							IntToString(view_as<int>(Cel_GetRenderFX(i)), sBuffer[8], sizeof(sBuffer[]));
							
							Entity_GetRenderColor(i, iColor);
							IntToString(iColor[0], sBuffer[9], sizeof(sBuffer[]));
							IntToString(iColor[1], sBuffer[10], sizeof(sBuffer[]));
							IntToString(iColor[2], sBuffer[11], sizeof(sBuffer[]));
							IntToString(iColor[3], sBuffer[12], sizeof(sBuffer[]));
							
							Cel_GetEntityAngles(i, fEnt[0]);
							FloatToString(fEnt[0][0], sBuffer[13], sizeof(sBuffer[]));
							FloatToString(fEnt[0][1], sBuffer[14], sizeof(sBuffer[]));
							FloatToString(fEnt[0][2], sBuffer[15], sizeof(sBuffer[]));
							
							Cel_GetEntityOrigin(i, fEnt[1]);
							
							fOrigin[0] = fEnt[1][0] - fMiddle[0];
							fOrigin[1] = fEnt[1][1] - fMiddle[1];
							fOrigin[2] = fEnt[1][2] - fMiddle[2];
							
							FloatToString(fOrigin[0], sBuffer[16], sizeof(sBuffer[]));
							FloatToString(fOrigin[1], sBuffer[17], sizeof(sBuffer[]));
							FloatToString(fOrigin[2], sBuffer[18], sizeof(sBuffer[]));
							
							Cel_GetInternetURL(i, sBuffer[19], sizeof(sBuffer[]));
							
							ImplodeStrings(sBuffer, 20, "^", sOutput, sizeof(sOutput));
						}
						case ENTTYPE_PHYSICS:
						{
							char sBuffer[20][PLATFORM_MAX_PATH];
							
							IntToString(view_as<int>(Cel_GetEntityType(i)), sBuffer[0], sizeof(sBuffer[]));
							
							Entity_GetClassName(i, sBuffer[1], sizeof(sBuffer[]));
							Entity_GetName(i, sBuffer[2], sizeof(sBuffer[]));
							Entity_GetModel(i, sBuffer[3], sizeof(sBuffer[]));
							IntToString(Entity_GetSpawnFlags(i), sBuffer[4], sizeof(sBuffer[]));
							IntToString(Entity_GetSkin(i), sBuffer[5], sizeof(sBuffer[]));
							IntToString(view_as<int>(Cel_GetMotion(i)), sBuffer[6], sizeof(sBuffer[]));
							IntToString(view_as<int>(Cel_IsSolid(i)), sBuffer[7], sizeof(sBuffer[]));
							
							IntToString(view_as<int>(Cel_GetRenderFX(i)), sBuffer[8], sizeof(sBuffer[]));
							
							Entity_GetRenderColor(i, iColor);
							IntToString(iColor[0], sBuffer[9], sizeof(sBuffer[]));
							IntToString(iColor[1], sBuffer[10], sizeof(sBuffer[]));
							IntToString(iColor[2], sBuffer[11], sizeof(sBuffer[]));
							IntToString(iColor[3], sBuffer[12], sizeof(sBuffer[]));
							
							Cel_GetEntityAngles(i, fEnt[0]);
							FloatToString(fEnt[0][0], sBuffer[13], sizeof(sBuffer[]));
							FloatToString(fEnt[0][1], sBuffer[14], sizeof(sBuffer[]));
							FloatToString(fEnt[0][2], sBuffer[15], sizeof(sBuffer[]));
							
							Cel_GetEntityOrigin(i, fEnt[1]);
							
							fOrigin[0] = fEnt[1][0] - fMiddle[0];
							fOrigin[1] = fEnt[1][1] - fMiddle[1];
							fOrigin[2] = fEnt[1][2] - fMiddle[2];
							
							FloatToString(fOrigin[0], sBuffer[16], sizeof(sBuffer[]));
							FloatToString(fOrigin[1], sBuffer[17], sizeof(sBuffer[]));
							FloatToString(fOrigin[2], sBuffer[18], sizeof(sBuffer[]));
							
							Cel_GetPropName(i, sBuffer[19], sizeof(sBuffer[]));
							
							ImplodeStrings(sBuffer, 20, "^", sOutput, sizeof(sOutput));
						}
					}
				}
				
				File fFile = OpenFile(sFile[0], "a+");
				
				if(!StrEqual(sOutput, ""))
				{
					Format(sOutput, sizeof(sOutput), "%s%s", SAVESYSTEM_STRING, sOutput);
					
					fFile.WriteLine(sOutput);
					
					fFile.Flush();
				}
				
				Format(sOutput, sizeof(sOutput), "");
				
				fFile.Close();
			}
		}
	}
	
	if(g_iSaveOverride[iClient] == 2)
	{
		DeleteFile(sFile[1]);
	}
	
	g_iSaveOverride[iClient] = 0;
	
	Cel_ReplyToCommand(iClient, "%t", "SavedBuild", sSaveName);
	
	return true;
}

//Timers:
public Action Timer_LoadBuild(Handle hTimer, Handle hPack)
{
	ResetPack(hPack);
	
	char sFileBuffer[PLATFORM_MAX_PATH];
	float fEnt[2][3], fOrigin[3];
	int iClient = ReadPackCell(hPack);
	
	ReadPackString(hPack, sFileBuffer, sizeof(sFileBuffer));
	
	if(!(StrContains(sFileBuffer, SAVESYSTEM_STRING, false) != -1))
	{
		Cel_ReplyToCommand(iClient, "%t", "OutdatedSaveSystem");
		return Plugin_Handled;
	}
	
	ReplaceString(sFileBuffer, sizeof(sFileBuffer), SAVESYSTEM_STRING, "");
	
	EntityType etType = view_as<EntityType>(StringToInt(sFileBuffer[0]));
	
	switch(etType)
	{
		case ENTTYPE_CYCLER:
		{
			char sBuffer[20][PLATFORM_MAX_PATH];
			
			ExplodeString(sFileBuffer, "^", sBuffer, 20, sizeof(sBuffer[]));
			
			fEnt[0][0] = StringToFloat(sBuffer[12]);
			fEnt[0][1] = StringToFloat(sBuffer[13]);
			fEnt[0][2] = StringToFloat(sBuffer[14]);
			
			fEnt[1][0] = StringToFloat(sBuffer[15]);
			fEnt[1][1] = StringToFloat(sBuffer[16]);
			fEnt[1][2] = StringToFloat(sBuffer[17]);
			
			fOrigin[0] = fEnt[1][0] + g_fCrosshairOrigin[iClient][0];
			fOrigin[1] = fEnt[1][1] + g_fCrosshairOrigin[iClient][1];
			fOrigin[2] = fEnt[1][2] + g_fCrosshairOrigin[iClient][2];
			
			int iCycler = Cel_SpawnProp(iClient, sBuffer[18], "cycler", sBuffer[3], fEnt[0], fOrigin, StringToInt(sBuffer[8]), StringToInt(sBuffer[9]), StringToInt(sBuffer[10]), StringToInt(sBuffer[11]));
			
			Cel_SetEntity(iCycler, true);
			Entity_SetName(iCycler, sBuffer[2]);
			Entity_SetSpawnFlags(iCycler, StringToInt(sBuffer[4]));
			Entity_SetSkin(iCycler, StringToInt(sBuffer[5]));
			Cel_SetMotion(iCycler, view_as<bool>(StringToInt(sBuffer[6])));
			Cel_SetRenderFX(iCycler, view_as<RenderFx>(StringToInt(sBuffer[7])));
			Cel_SetOwner(iClient, iCycler);
			Cel_SetPropName(iCycler, sBuffer[18]);
			
			Entity_SetAnimSequence(iCycler, StringToInt(sBuffer[19]));
		}
		case ENTTYPE_DOOR:
		{
			char sBuffer[19][PLATFORM_MAX_PATH];
			
			ExplodeString(sFileBuffer, "^", sBuffer, 19, sizeof(sBuffer[]));
			
			fEnt[0][0] = StringToFloat(sBuffer[13]);
			fEnt[0][1] = StringToFloat(sBuffer[14]);
			fEnt[0][2] = StringToFloat(sBuffer[15]);
			
			fEnt[1][0] = StringToFloat(sBuffer[16]);
			fEnt[1][1] = StringToFloat(sBuffer[17]);
			fEnt[1][2] = StringToFloat(sBuffer[18]);
			
			fOrigin[0] = g_fCrosshairOrigin[iClient][0] + fEnt[1][0];
			fOrigin[1] = g_fCrosshairOrigin[iClient][1] + fEnt[1][1];
			fOrigin[2] = g_fCrosshairOrigin[iClient][2] + fEnt[1][2];
			
			int iProp = Cel_SpawnDoor(iClient, sBuffer[5], fEnt[0], fOrigin, StringToInt(sBuffer[9]), StringToInt(sBuffer[10]), StringToInt(sBuffer[11]), StringToInt(sBuffer[12]));
			
			Entity_SetName(iProp, sBuffer[2]);
			Entity_SetSpawnFlags(iProp, StringToInt(sBuffer[4]));
			Cel_SetMotion(iProp, view_as<bool>(StringToInt(sBuffer[6])));
			Cel_SetSolid(iProp, view_as<bool>(StringToInt(sBuffer[7])));
			Cel_SetRenderFX(iProp, view_as<RenderFx>(StringToInt(sBuffer[8])));
		}
		case ENTTYPE_DYNAMIC:
		{
			char sBuffer[20][PLATFORM_MAX_PATH];
			
			ExplodeString(sFileBuffer, "^", sBuffer, 20, sizeof(sBuffer[]));
			
			fEnt[0][0] = StringToFloat(sBuffer[13]);
			fEnt[0][1] = StringToFloat(sBuffer[14]);
			fEnt[0][2] = StringToFloat(sBuffer[15]);
			
			fEnt[1][0] = StringToFloat(sBuffer[16]);
			fEnt[1][1] = StringToFloat(sBuffer[17]);
			fEnt[1][2] = StringToFloat(sBuffer[18]);
			
			fOrigin[0] = g_fCrosshairOrigin[iClient][0] + fEnt[1][0];
			fOrigin[1] = g_fCrosshairOrigin[iClient][1] + fEnt[1][1];
			fOrigin[2] = g_fCrosshairOrigin[iClient][2] + fEnt[1][2];
			
			int iProp = Cel_SpawnProp(iClient, sBuffer[19], "prop_physics_override", sBuffer[3], fEnt[0], fOrigin, StringToInt(sBuffer[9]), StringToInt(sBuffer[10]), StringToInt(sBuffer[11]), StringToInt(sBuffer[12]));
			
			Entity_SetName(iProp, sBuffer[2]);
			Entity_SetSpawnFlags(iProp, StringToInt(sBuffer[4]));
			Entity_SetSkin(iProp, StringToInt(sBuffer[5]));
			Cel_SetMotion(iProp, view_as<bool>(StringToInt(sBuffer[6])));
			Cel_SetSolid(iProp, view_as<bool>(StringToInt(sBuffer[7])));
			Cel_SetRenderFX(iProp, view_as<RenderFx>(StringToInt(sBuffer[8])));
		}
		case ENTTYPE_EFFECT:
		{
			char sBuffer[21][PLATFORM_MAX_PATH];
			
			ExplodeString(sFileBuffer, "^", sBuffer, 21, sizeof(sBuffer[]));
			
			fEnt[0][0] = StringToFloat(sBuffer[13]);
			fEnt[0][1] = StringToFloat(sBuffer[14]);
			fEnt[0][2] = StringToFloat(sBuffer[15]);
			
			fEnt[1][0] = StringToFloat(sBuffer[16]);
			fEnt[1][1] = StringToFloat(sBuffer[17]);
			fEnt[1][2] = StringToFloat(sBuffer[18]);
			
			fOrigin[0] = g_fCrosshairOrigin[iClient][0] + fEnt[1][0];
			fOrigin[1] = g_fCrosshairOrigin[iClient][1] + fEnt[1][1];
			fOrigin[2] = g_fCrosshairOrigin[iClient][2] + fEnt[1][2];
			
			int iProp = Cel_SpawnEffect(iClient, fOrigin, view_as<EffectType>(StringToInt(sBuffer[19])), view_as<bool>(StringToInt(sBuffer[20])), StringToInt(sBuffer[9]), StringToInt(sBuffer[10]), StringToInt(sBuffer[11]), StringToInt(sBuffer[12]));
			
			Entity_SetName(iProp, sBuffer[2]);
			Entity_SetSpawnFlags(iProp, StringToInt(sBuffer[4]));
			Entity_SetSkin(iProp, StringToInt(sBuffer[5]));
			Cel_SetMotion(iProp, view_as<bool>(StringToInt(sBuffer[6])));
			Cel_SetSolid(iProp, view_as<bool>(StringToInt(sBuffer[7])));
			Cel_SetRenderFX(iProp, view_as<RenderFx>(StringToInt(sBuffer[8])));
			
			Cel_SetEffectActive(iProp, view_as<bool>(StringToInt(sBuffer[20])));
		}
		case ENTTYPE_INTERNET:
		{
			char sBuffer[20][PLATFORM_MAX_PATH];
			
			ExplodeString(sFileBuffer, "^", sBuffer, 20, sizeof(sBuffer[]));
			
			fEnt[0][0] = StringToFloat(sBuffer[13]);
			fEnt[0][1] = StringToFloat(sBuffer[14]);
			fEnt[0][2] = StringToFloat(sBuffer[15]);
			
			fEnt[1][0] = StringToFloat(sBuffer[16]);
			fEnt[1][1] = StringToFloat(sBuffer[17]);
			fEnt[1][2] = StringToFloat(sBuffer[18]);
			
			fOrigin[0] = g_fCrosshairOrigin[iClient][0] + fEnt[1][0];
			fOrigin[1] = g_fCrosshairOrigin[iClient][1] + fEnt[1][1];
			fOrigin[2] = g_fCrosshairOrigin[iClient][2] + fEnt[1][2];
			
			int iProp = Cel_SpawnInternet(iClient, sBuffer[19], fEnt[0], fOrigin, StringToInt(sBuffer[9]), StringToInt(sBuffer[10]), StringToInt(sBuffer[11]), StringToInt(sBuffer[12]));
			
			Entity_SetName(iProp, sBuffer[2]);
			Entity_SetSpawnFlags(iProp, StringToInt(sBuffer[4]));
			Entity_SetSkin(iProp, StringToInt(sBuffer[5]));
			Cel_SetMotion(iProp, view_as<bool>(StringToInt(sBuffer[6])));
			Cel_SetSolid(iProp, view_as<bool>(StringToInt(sBuffer[7])));
			Cel_SetRenderFX(iProp, view_as<RenderFx>(StringToInt(sBuffer[8])));
		}
		case ENTTYPE_PHYSICS:
		{
			char sBuffer[20][PLATFORM_MAX_PATH];
			
			ExplodeString(sFileBuffer, "^", sBuffer, 20, sizeof(sBuffer[]));
			
			PrintToServer(sFileBuffer);
			
			fEnt[0][0] = StringToFloat(sBuffer[13]);
			fEnt[0][1] = StringToFloat(sBuffer[14]);
			fEnt[0][2] = StringToFloat(sBuffer[15]);
			
			fEnt[1][0] = StringToFloat(sBuffer[16]);
			fEnt[1][1] = StringToFloat(sBuffer[17]);
			fEnt[1][2] = StringToFloat(sBuffer[18]);
			
			fOrigin[0] = g_fCrosshairOrigin[iClient][0] + fEnt[1][0];
			fOrigin[1] = g_fCrosshairOrigin[iClient][1] + fEnt[1][1];
			fOrigin[2] = g_fCrosshairOrigin[iClient][2] + fEnt[1][2];
			
			int iProp = Cel_SpawnProp(iClient, sBuffer[19], "prop_physics_override", sBuffer[3], fEnt[0], fOrigin, StringToInt(sBuffer[9]), StringToInt(sBuffer[10]), StringToInt(sBuffer[11]), StringToInt(sBuffer[12]));
			
			Entity_SetName(iProp, sBuffer[2]);
			Entity_SetSpawnFlags(iProp, StringToInt(sBuffer[4]));
			Entity_SetSkin(iProp, StringToInt(sBuffer[5]));
			Cel_SetMotion(iProp, view_as<bool>(StringToInt(sBuffer[6])));
			Cel_SetSolid(iProp, view_as<bool>(StringToInt(sBuffer[7])));
			Cel_SetRenderFX(iProp, view_as<RenderFx>(StringToInt(sBuffer[8])));
		}
		case ENTTYPE_UNKNOWN:
		{
			char sBuffer[20][PLATFORM_MAX_PATH];
			
			ExplodeString(sFileBuffer, "^", sBuffer, 20, sizeof(sBuffer[]));
			
			fEnt[0][0] = StringToFloat(sBuffer[13]);
			fEnt[0][1] = StringToFloat(sBuffer[14]);
			fEnt[0][2] = StringToFloat(sBuffer[15]);
			
			fEnt[1][0] = StringToFloat(sBuffer[16]);
			fEnt[1][1] = StringToFloat(sBuffer[17]);
			fEnt[1][2] = StringToFloat(sBuffer[18]);
			
			fOrigin[0] = g_fCrosshairOrigin[iClient][0] + fEnt[1][0];
			fOrigin[1] = g_fCrosshairOrigin[iClient][1] + fEnt[1][1];
			fOrigin[2] = g_fCrosshairOrigin[iClient][2] + fEnt[1][2];
			
			int iProp = Cel_SpawnProp(iClient, sBuffer[19], "prop_physics_override", sBuffer[3], fEnt[0], fOrigin, StringToInt(sBuffer[9]), StringToInt(sBuffer[10]), StringToInt(sBuffer[11]), StringToInt(sBuffer[12]));
			
			Entity_SetName(iProp, sBuffer[2]);
			Entity_SetSpawnFlags(iProp, StringToInt(sBuffer[4]));
			Entity_SetSkin(iProp, StringToInt(sBuffer[5]));
			Cel_SetMotion(iProp, view_as<bool>(StringToInt(sBuffer[6])));
			Cel_SetSolid(iProp, view_as<bool>(StringToInt(sBuffer[7])));
			Cel_SetRenderFX(iProp, view_as<RenderFx>(StringToInt(sBuffer[8])));
		}
	}
	
	return Plugin_Continue;
}
