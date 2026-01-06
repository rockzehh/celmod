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
	
	g_bLate = bLate;
	
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
	
	RegConsoleCmd("v_load", Command_LoadBuild, "|CelMod| Loads entities from a save file.");
	RegConsoleCmd("v_save", Command_SaveBuild, "|CelMod| Saves all server entities that are in your land.");
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

//Natives:
/*public int Native_LoadBuild(Handle hPlugin, int iNumParams)
{
	char sAuthID[64], sBuffer[3][PLATFORM_MAX_PATH], sEnt[32], sFile[PLATFORM_MAX_PATH], sKey[32], sPropName[64], sRelPath[PLATFORM_MAX_PATH], sSaveName[96], sTemp[256];
	float fEnt[2][3], fOrigin[3];
	int iClient = GetNativeCell(1), iControllerEntity = -1, iControllerID = -1, iProp = -1;
	StringMap smControllers = new StringMap(), smLinked = new StringMap();
	
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
				fEnt[0][0] = kvLoadBuild.GetFloat("a1");
				fEnt[0][1] = kvLoadBuild.GetFloat("a2");
				fEnt[0][2] = kvLoadBuild.GetFloat("a3");
				
				fEnt[1][0] = kvLoadBuild.GetFloat("o1");
				fEnt[1][1] = kvLoadBuild.GetFloat("o2");
				fEnt[1][2] = kvLoadBuild.GetFloat("o3");
				
				fOrigin[0] = fEnt[1][0] + g_fCrosshairOrigin[iClient][0];
				fOrigin[1] = fEnt[1][1] + g_fCrosshairOrigin[iClient][1];
				fOrigin[2] = fEnt[1][2] + g_fCrosshairOrigin[iClient][2];
				
				kvLoadBuild.GetString("classname", sBuffer[0], sizeof(sBuffer[]));
				kvLoadBuild.GetString("targetname", sBuffer[1], sizeof(sBuffer[]));
				kvLoadBuild.GetString("model", sBuffer[2], sizeof(sBuffer[]));
				
				EntityType etType = view_as<EntityType>(kvLoadBuild.GetNum("entitytype"));
				
				switch(etType)
				{
					case ENTTYPE_CYCLER:
					{
						kvLoadBuild.GetString("propname", sPropName, sizeof(sPropName));
						
						iProp = Cel_SpawnProp(iClient, sPropName, "cycler", sBuffer[2], fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
						
						Entity_SetAnimSequence(iProp, kvLoadBuild.GetNum("animsequence"));
					}
					case ENTTYPE_DOOR:
					{
						iProp = Cel_SpawnDoor(iClient, 1, fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
					}
					case ENTTYPE_DYNAMIC:
					{
						kvLoadBuild.GetString("propname", sPropName, sizeof(sPropName));
						
						iProp = Cel_SpawnProp(iClient, sPropName, "prop_physics_override", sBuffer[2], fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
					}
					case ENTTYPE_EFFECT:
					{
						iProp = Cel_SpawnEffect(iClient, fOrigin, view_as<EffectType>(kvLoadBuild.GetNum("effecttype")), view_as<bool>(kvLoadBuild.GetNum("effectenabled")), kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
					}
					case ENTTYPE_INTERNET:
					{
						char sURL[PLATFORM_MAX_PATH];
						
						kvLoadBuild.GetString("interneturl", sURL, sizeof(sURL));
						
						iProp = Cel_SpawnInternet(iClient, sURL, fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
					}
					case ENTTYPE_LADDER:
					{
						iProp = Cel_SpawnLadder(iClient, sBuffer[2], fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
					}
					case ENTTYPE_LIGHT:
					{
						iProp = Cel_SpawnLight(iClient, fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
					}
					case ENTTYPE_PHYSICS:
					{
						kvLoadBuild.GetString("propname", sPropName, sizeof(sPropName));
						
						iProp = Cel_SpawnProp(iClient, sPropName, "prop_physics_override", sBuffer[2], fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
						
						Cel_SetBreakable(iProp, view_as<bool>(kvLoadBuild.GetNum("breakable")));
					}
					case ENTTYPE_AMMO:
					{
						iProp = Cel_SpawnAmmoBit(iClient, view_as<AmmoBitType>(kvLoadBuild.GetNum("ammobittype")), fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
					}
					case ENTTYPE_AMMOCRATE:
					{
						iProp = Cel_SpawnAmmoCrate(iClient, view_as<AmmoCrateType>(kvLoadBuild.GetNum("ammocratetype")), fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
					}
					case ENTTYPE_CHARGER:
					{
						iProp = Cel_SpawnCharger(iClient, view_as<ChargerType>(kvLoadBuild.GetNum("chargertype")), fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
					}
					case ENTTYPE_WEAPONSPWNER:
					{
						iProp = Cel_SpawnWeaponBit(iClient, view_as<WeaponBitType>(kvLoadBuild.GetNum("weaponbittype")), fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
					}
					case ENTTYPE_MUSIC:
					{
						kvLoadBuild.GetString("musicpath", sTemp, sizeof(sTemp));
						iProp = Cel_SpawnMusic(iClient, sTemp, view_as<bool>(kvLoadBuild.GetNum("loop")), kvLoadBuild.GetFloat("looptime"), view_as<bool>(kvLoadBuild.GetNum("start")), kvLoadBuild.GetFloat("volume"), kvLoadBuild.GetNum("speed"), fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
					}
					case ENTTYPE_SOUND:
					{
						kvLoadBuild.GetString("soundpath", sTemp, sizeof(sTemp));
						iProp = Cel_SpawnSound(iClient, sTemp, kvLoadBuild.GetNum("speed"), fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
					}
					case ENTTYPE_TRIGGER:
					{
						if(StrEqual(sBuffer[0], "bit_trigger_button"))
						{
							iProp = Cel_SpawnButton(iClient, fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
						}else{
							//iProp = Cel_SpawnTrigger(iClient, fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
						}
						
						iControllerID = kvLoadBuild.GetNum("controllerid", -1);
						
						if(iControllerID != -1)
						{
							IntToString(iControllerID, sKey, sizeof(sKey));
						
							smControllers.SetValue(sKey, EntIndexToEntRef(iProp));	
						}
					}
					case ENTTYPE_UNKNOWN:
					{
						kvLoadBuild.GetString("propname", sPropName, sizeof(sPropName));
						
						iProp = Cel_SpawnProp(iClient, sPropName, "prop_physics_override", sBuffer[2], fEnt[0], fOrigin, kvLoadBuild.GetNum("c1"), kvLoadBuild.GetNum("c2"), kvLoadBuild.GetNum("c3"), kvLoadBuild.GetNum("c4"));
					}
				}
				
				Entity_SetName(iProp, sBuffer[1]);
				Cel_SetEntity(iProp, true);
				Entity_SetSpawnFlags(iProp, kvLoadBuild.GetNum("spawnflags"));
				Entity_SetSkin(iProp, kvLoadBuild.GetNum("skin"));
				Cel_SetMotion(iProp, view_as<bool>(kvLoadBuild.GetNum("motion")));
				Cel_SetSolid(iProp, view_as<bool>(kvLoadBuild.GetNum("solid")));
				Cel_SetRenderFX(iProp, view_as<RenderFx>(kvLoadBuild.GetNum("renderfx")));
				Cel_SetOwner(iClient, iProp);
				
				iControllerEntity = kvLoadBuild.GetNum("controllerentity", -1);
				
				if(iControllerEntity != -1)
				{
					IntToString(iControllerEntity, sKey, sizeof(sKey));
							
					smLinked.SetValue(sKey, EntIndexToEntRef(iProp));
				}
				
				Cel_SetColorFade(iProp, view_as<bool>(kvLoadBuild.GetNum("colorfading")), kvLoadBuild.GetNum("fc1-1"), kvLoadBuild.GetNum("fc1-2"), kvLoadBuild.GetNum("fc1-3"), kvLoadBuild.GetNum("fc2-1"), kvLoadBuild.GetNum("fc2-2"), kvLoadBuild.GetNum("fc2-3"));
				Cel_SetRainbow(iProp, view_as<bool>(kvLoadBuild.GetNum("colorrainbow")));
			}
			
			while (kvLoadBuild.GotoNextKey());
		}
		
		StringMapSnapshot smsLinked = smLinked.Snapshot();
		
		for (int i = 0; i < smsLinked.Length; i++)
		{
			int iControlledEnt, iControllerEnt;
			
			smsLinked.GetKey(i, sKey, sizeof(sKey));
			
			if(!smControllers.GetValue(sKey, iControllerEnt))
				continue;
				
			smLinked.GetValue(sKey, iControlledEnt);
			
			Cel_LinkEntity(EntRefToEntIndex(iControllerEnt), EntRefToEntIndex(iControlledEnt));
		}
		
		delete smControllers;
		delete smLinked;
		delete smsLinked;
		
		if(!kvLoadBuild.GotoNextKey())
		{
			kvLoadBuild.Close();	
		}
		
		iProp = -1;
		
		Cel_ReplyToCommand(iClient, "%t", "LoadedBuild", sSaveName);
		
		return true;
	}else{
		kvLoadBuild.Close();
		
		Cel_ReplyToCommand(iClient, "%t", "SaveDoesntExist", sSaveName);
		
		return false;
	}
}*/

public int Native_LoadBuild(Handle hPlugin, int iNumParams)
{
    int iClient = GetNativeCell(1);
    char sSaveName[96], sAuthID[64];
    
    GetNativeString(2, sSaveName, sizeof(sSaveName));
    Cel_GetAuthID(iClient, sAuthID, sizeof(sAuthID));
    
    // Update spawn anchor point for relative positioning
    Cel_GetCrosshairHitOrigin(iClient, g_fCrosshairOrigin[iClient]);
    
    char sFile[PLATFORM_MAX_PATH];
    Format(sFile, sizeof(sFile), "data/celmod/users/%s/saves/%s.txt", sAuthID, sSaveName);
    BuildPath(Path_SM, sFile, sizeof(sFile), sFile);
    
    KeyValues kv = new KeyValues("Vault");
    if (!kv.ImportFromFile(sFile))
    {
        delete kv;
        Cel_ReplyToCommand(iClient, "%t", "SaveDoesntExist", sSaveName);
        return false;
    }

    // Two-pass linking setup: Map IDs to spawned entity references
    StringMap smControllers = new StringMap(); 
    StringMap smControlled = new StringMap();

    if (kv.GotoFirstSubKey())
    {
        char sClass[64], sName[64], sModel[PLATFORM_MAX_PATH], sExtra[PLATFORM_MAX_PATH], sKey[32];
        float fAng[3], fRelOff[3], fPos[3];
        
        do
        {
            fAng[0] = kv.GetFloat("a1");
            fAng[1] = kv.GetFloat("a2");
            fAng[2] = kv.GetFloat("a3");
            
            fRelOff[0] = kv.GetFloat("o1");
            fRelOff[1] = kv.GetFloat("o2");
            fRelOff[2] = kv.GetFloat("o3");
            
            // Calculate world position relative to where player is looking
            AddVectors(fRelOff, g_fCrosshairOrigin[iClient], fPos);

            kv.GetString("classname", sClass, sizeof(sClass));
            kv.GetString("targetname", sName, sizeof(sName));
            kv.GetString("model", sModel, sizeof(sModel));
            
            int c1 = kv.GetNum("c1"), c2 = kv.GetNum("c2"), c3 = kv.GetNum("c3"), c4 = kv.GetNum("c4");
            EntityType etType = view_as<EntityType>(kv.GetNum("entitytype"));
            int iProp = -1;

            switch(etType)
            {
                case ENTTYPE_CYCLER: {
                    kv.GetString("propname", sExtra, sizeof(sExtra));
                    iProp = Cel_SpawnProp(iClient, sExtra, "cycler", sModel, fAng, fPos, c1, c2, c3, c4);
                    Entity_SetAnimSequence(iProp, kv.GetNum("animsequence"));
                }
                case ENTTYPE_DOOR: iProp = Cel_SpawnDoor(iClient, 1, fAng, fPos, c1, c2, c3, c4);
                case ENTTYPE_DYNAMIC, ENTTYPE_PHYSICS, ENTTYPE_UNKNOWN: {
                    kv.GetString("propname", sExtra, sizeof(sExtra));
                    iProp = Cel_SpawnProp(iClient, sExtra, "prop_physics_override", sModel, fAng, fPos, c1, c2, c3, c4);
                    if(etType == ENTTYPE_PHYSICS) Cel_SetBreakable(iProp, view_as<bool>(kv.GetNum("breakable")));
                }
                case ENTTYPE_EFFECT: iProp = Cel_SpawnEffect(iClient, fPos, view_as<EffectType>(kv.GetNum("effecttype")), view_as<bool>(kv.GetNum("effectenabled")), c1, c2, c3, c4);
                case ENTTYPE_INTERNET: {
                    kv.GetString("interneturl", sExtra, sizeof(sExtra));
                    iProp = Cel_SpawnInternet(iClient, sExtra, fAng, fPos, c1, c2, c3, c4);
                }
                case ENTTYPE_LADDER: iProp = Cel_SpawnLadder(iClient, sModel, fAng, fPos, c1, c2, c3, c4);
                case ENTTYPE_LIGHT:  iProp = Cel_SpawnLight(iClient, fAng, fPos, c1, c2, c3, c4);
                case ENTTYPE_AMMO:   iProp = Cel_SpawnAmmoBit(iClient, view_as<AmmoBitType>(kv.GetNum("ammobittype")), fAng, fPos, c1, c2, c3, c4);
                case ENTTYPE_AMMOCRATE: iProp = Cel_SpawnAmmoCrate(iClient, view_as<AmmoCrateType>(kv.GetNum("ammocratetype")), fAng, fPos, c1, c2, c3, c4);
                case ENTTYPE_CHARGER:   iProp = Cel_SpawnCharger(iClient, view_as<ChargerType>(kv.GetNum("chargertype")), fAng, fPos, c1, c2, c3, c4);
                case ENTTYPE_WEAPONSPWNER: iProp = Cel_SpawnWeaponBit(iClient, view_as<WeaponBitType>(kv.GetNum("weaponbittype")), fAng, fPos, c1, c2, c3, c4);
                case ENTTYPE_MUSIC: {
                    kv.GetString("musicpath", sExtra, sizeof(sExtra));
                    iProp = Cel_SpawnMusic(iClient, sExtra, view_as<bool>(kv.GetNum("loop")), kv.GetFloat("looptime"), view_as<bool>(kv.GetNum("start")), kv.GetFloat("volume"), kv.GetNum("speed"), fAng, fPos, c1, c2, c3, c4);
                }
                case ENTTYPE_SOUND: {
                    kv.GetString("soundpath", sExtra, sizeof(sExtra));
                    iProp = Cel_SpawnSound(iClient, sExtra, kv.GetNum("speed"), fAng, fPos, c1, c2, c3, c4);
                }
                case ENTTYPE_TRIGGER: {
                    if(StrEqual(sClass, "bit_trigger_button")) iProp = Cel_SpawnButton(iClient, fAng, fPos, c1, c2, c3, c4);
                    
                    int iID = kv.GetNum("controllerid", -1);
                    if(iID != -1) {
                        IntToString(iID, sKey, sizeof(sKey));
                        smControllers.SetValue(sKey, EntIndexToEntRef(iProp));
                    }
                }
            }
            
            if (iProp > 0 && IsValidEntity(iProp))
            {
                Entity_SetName(iProp, sName);
                Cel_SetEntity(iProp, true);
                Entity_SetSpawnFlags(iProp, kv.GetNum("spawnflags"));
                Entity_SetSkin(iProp, kv.GetNum("skin"));
                Cel_SetMotion(iProp, view_as<bool>(kv.GetNum("motion")));
                Cel_SetSolid(iProp, view_as<bool>(kv.GetNum("solid")));
                Cel_SetRenderFX(iProp, view_as<RenderFx>(kv.GetNum("renderfx")));
                Cel_SetOwner(iClient, iProp);
                
                int iLinkID = kv.GetNum("controllerentity", -1);
                if(iLinkID != -1) {
                    IntToString(iLinkID, sKey, sizeof(sKey));
                    smControlled.SetValue(sKey, EntIndexToEntRef(iProp));
                }
                
                Cel_SetColorFade(iProp, view_as<bool>(kv.GetNum("colorfading")), kv.GetNum("fc1-1"), kv.GetNum("fc1-2"), kv.GetNum("fc1-3"), kv.GetNum("fc2-1"), kv.GetNum("fc2-2"), kv.GetNum("fc2-3"));
                Cel_SetRainbow(iProp, view_as<bool>(kv.GetNum("colorrainbow")));
            }
        } while (kv.GotoNextKey());
    }

    // Linking Pass: Executed after all potential entities are spawned
    StringMapSnapshot snap = smControlled.Snapshot();
    for (int i = 0; i < snap.Length; i++)
    {
        char sKey[32]; snap.GetKey(i, sKey, sizeof(sKey));
        int iCtrlRef, iControlledRef;
        
        if (smControllers.GetValue(sKey, iCtrlRef) && smControlled.GetValue(sKey, iControlledRef))
        {
            int iCtrl = EntRefToEntIndex(iCtrlRef);
            int iControlled = EntRefToEntIndex(iControlledRef);
            
            if (iCtrl != INVALID_ENT_REFERENCE && iControlled != INVALID_ENT_REFERENCE)
            {
                Cel_LinkEntity(iCtrl, iControlled); 
            }
        }
    }

    // Cleanup handles
    delete smControllers; delete smControlled; delete snap; delete kv;
    Cel_ReplyToCommand(iClient, "%t", "LoadedBuild", sSaveName);
    return true;
}

/*
public int Native_SaveBuild(Handle hPlugin, int iNumParams)
{
	bool bPropOutside = false;
	char sAuthID[64], sBuffer[3][PLATFORM_MAX_PATH], sFile[2][PLATFORM_MAX_PATH], sPropName[64], sRelPath[PLATFORM_MAX_PATH], sSaveName[96], sCount[32];
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
				iLand = Cel_GetLandOwnerFromEntity(i);
				
				if(iLand == iClient)
				{
					iCount++;
					
					IntToString(iCount, sCount, sizeof(sCount));
					
					Entity_GetRenderColor(i, iColor);
					Cel_GetFadeColor(i, iFadeColor[0], iFadeColor[1]);
					
					Entity_GetClassName(i, sBuffer[0], sizeof(sBuffer[]));
					Entity_GetName(i, sBuffer[1], sizeof(sBuffer[]));
					Entity_GetModel(i, sBuffer[2], sizeof(sBuffer[]));
					
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
					
					switch(Cel_GetEntityType(i))
					{
						case ENTTYPE_CYCLER:
						{
							Cel_GetPropName(i, sPropName, sizeof(sPropName));
							
							kvSaveBuild.SetString("propname", sPropName);
							
							kvSaveBuild.SetNum("animsequence", Entity_GetAnimSequence(i));
						}
						case ENTTYPE_DOOR:
						{
							fOrigin[2] -= 54;
							
							kvSaveBuild.SetFloat("o3", fOrigin[2]);
						}
						case ENTTYPE_DYNAMIC:
						{
							Cel_GetPropName(i, sPropName, sizeof(sPropName));
							
							kvSaveBuild.SetString("propname", sPropName);
						}
						case ENTTYPE_EFFECT:
						{
							kvSaveBuild.SetNum("effecttype", view_as<int>(Cel_GetEffectType(i)));
							kvSaveBuild.SetNum("effectenabled", view_as<int>(Cel_IsEffectActive(i)));
						}
						case ENTTYPE_INTERNET:
						{
							char sURL[PLATFORM_MAX_PATH];
							
							Cel_GetInternetURL(i, sURL, sizeof(sURL));
							
							kvSaveBuild.SetString("interneturl", sURL);
						}
						case ENTTYPE_PHYSICS:
						{
							Cel_GetPropName(i, sPropName, sizeof(sPropName));
							
							kvSaveBuild.SetString("propname", sPropName);
							kvSaveBuild.SetNum("breakable", view_as<int>(Cel_IsBreakable(i)));
						}
						case ENTTYPE_AMMO:
						{
							fEnt[0][1] -= 90;
							
							kvSaveBuild.SetFloat("a2", fEnt[0][1]);
							
							kvSaveBuild.SetNum("ammobittype", Cel_GetAmmoType(i));
						}
						case ENTTYPE_AMMOCRATE:
						{
							fEnt[0][1] -= 180;
							
							kvSaveBuild.SetFloat("a2", fEnt[0][1]);
							
							kvSaveBuild.SetNum("ammocratetype", Cel_GetAmmoCrateType(i));
						}
						case ENTTYPE_CHARGER:
						{
							fEnt[0][1] -= 180;
							
							kvSaveBuild.SetFloat("a2", fEnt[0][1]);
							
							kvSaveBuild.SetNum("chargertype", Cel_GetChargerType(i));
						}
						case ENTTYPE_WEAPONSPWNER:
						{
							fEnt[0][1] -= 90;
							
							kvSaveBuild.SetFloat("a2", fEnt[0][1]);
							
							kvSaveBuild.SetNum("weaponbittype", Cel_GetWeaponType(i));
						}
						case ENTTYPE_MUSIC:
						{
							char sMusicPath[PLATFORM_MAX_PATH];
							
							Cel_GetMusicPath(i, sMusicPath, sizeof(sMusicPath));
							
							fEnt[0][1] -= 180;
							
							kvSaveBuild.SetFloat("a2", fEnt[0][1]);
							
							kvSaveBuild.SetString("musicpath", sMusicPath);
							
							kvSaveBuild.SetNum("loop", view_as<int>(Cel_IsMusicLooping(i)));
							kvSaveBuild.SetNum("start", view_as<int>(Cel_IsMusicActive(i)));
							
							kvSaveBuild.SetFloat("looptime", Cel_GetMusicLoopTime(i));
							kvSaveBuild.SetFloat("volume", Cel_GetMusicVolume(i));
							
							kvSaveBuild.SetNum("speed", Cel_GetSoundSpeed(i));
						}
						case ENTTYPE_SOUND:
						{
							char sSoundPath[PLATFORM_MAX_PATH];
							
							Cel_GetMusicPath(i, sSoundPath, sizeof(sSoundPath));
							
							kvSaveBuild.SetString("soundpath", sSoundPath);
							
							kvSaveBuild.SetNum("speed", Cel_GetSoundSpeed(i));
						}
						case ENTTYPE_TRIGGER:
						{
							fEnt[0][1] -= 180;
							
							kvSaveBuild.SetFloat("a2", fEnt[0][1]);
							
							kvSaveBuild.SetNum("controllerid", i);
						}
					}
					
					if(Cel_GetControllerEntity(i) != -1)
					{
						kvSaveBuild.SetNum("controllerentity", Cel_GetControllerEntity(i));
					}
					
					kvSaveBuild.Rewind();
				}
			}else{
				bPropOutside = true;
			}
		}
	}
	
	kvSaveBuild.ExportToFile(sFile[0]);
	
	kvSaveBuild.Close();
	
	g_iSaveOverride[iClient] = 0;
	
	if (bPropOutside)
	Cel_ReplyToCommand(iClient, "%t", "PropOutsideLand");
	
	Cel_ReplyToCommand(iClient, "%t", "SavedBuild", sSaveName);
	
	return true;
}*/

public int Native_SaveBuild(Handle hPlugin, int iNumParams)
{
    int iClient = GetNativeCell(1);
    char sSaveName[96], sAuthID[64], sFile[PLATFORM_MAX_PATH];
    float fLandPos[2][3], fMiddle[3];
    
    GetNativeString(2, sSaveName, sizeof(sSaveName));
    Cel_GetLandPositions(iClient, 1, fLandPos[0]);
    Cel_GetLandPositions(iClient, 4, fLandPos[1]);
    
    if (GetVectorLength(fLandPos[0]) == 0.0 && GetVectorLength(fLandPos[1]) == 0.0)
    {
        Cel_ReplyToCommand(iClient, "%t", "PropsWontSave");
        return false;
    }

    Cel_GetAuthID(iClient, sAuthID, sizeof(sAuthID));
    Format(sFile, sizeof(sFile), "data/celmod/users/%s/saves/%s.txt", sAuthID, sSaveName);
    BuildPath(Path_SM, sFile, sizeof(sFile), sFile);

    // Confirmation logic
    if (FileExists(sFile) && g_iSaveOverride[iClient] == 0)
    {
        Cel_ReplyToCommand(iClient, "%t", "SaveOverriteWarning", sSaveName);
        g_iSaveOverride[iClient] = 1;
        return false;
    }
    
    g_iSaveOverride[iClient] = 0;
    
    // Calculate the center/floor for relative saving
    Cel_GetMiddleOfABox(fLandPos[0], fLandPos[1], fMiddle);
    fMiddle[2] = fLandPos[0][2];

    KeyValues kv = new KeyValues("Vault");
    int iCount = 0;
    bool bOutside = false;

    for (int i = MaxClients + 1; i < GetMaxEntities(); i++)
    {
        // PERFORMANCE: Check easy integers before expensive geometry
        if (!IsValidEntity(i) || !Cel_CheckOwner(iClient, i)) continue;
        if (Cel_GetLandOwnerFromEntity(i) != iClient) continue;
        if (!Cel_IsEntityInLand(i)) { bOutside = true; continue; }

        char sIdx[16], sClass[64], sName[64], sModel[PLATFORM_MAX_PATH], sExtra[PLATFORM_MAX_PATH];
        float fAng[3], fPos[3], fRel[3];
        int iCol[4], iFade[2][3];

        iCount++;
        IntToString(iCount, sIdx, sizeof(sIdx));
        kv.JumpToKey(sIdx, true);

        Entity_GetClassName(i, sClass, sizeof(sClass));
        Entity_GetName(i, sName, sizeof(sName));
        Entity_GetModel(i, sModel, sizeof(sModel));
        Cel_GetEntityAngles(i, fAng);
        Cel_GetEntityOrigin(i, fPos);
        Entity_GetRenderColor(i, iCol);
        Cel_GetFadeColor(i, iFade[0], iFade[1]);
        
        SubtractVectors(fPos, fMiddle, fRel);

        kv.SetNum("entitytype", view_as<int>(Cel_GetEntityType(i)));
        kv.SetString("classname", sClass);
        kv.SetString("targetname", sName);
        kv.SetString("model", sModel);
        kv.SetNum("spawnflags", Entity_GetSpawnFlags(i));
        kv.SetNum("skin", Entity_GetSkin(i));
        kv.SetNum("motion", view_as<int>(Cel_GetMotion(i)));
        kv.SetNum("solid", view_as<int>(Cel_IsSolid(i)));
        
        kv.SetNum("c1", iCol[0]); kv.SetNum("c2", iCol[1]); kv.SetNum("c3", iCol[2]); kv.SetNum("c4", iCol[3]);
        kv.SetFloat("a1", fAng[0]); kv.SetFloat("a2", fAng[1]); kv.SetFloat("a3", fAng[2]);
        kv.SetFloat("o1", fRel[0]); kv.SetFloat("o2", fRel[1]); kv.SetFloat("o3", fRel[2]);
        
        kv.SetNum("fc1-1", iFade[0][0]); kv.SetNum("fc1-2", iFade[0][1]); kv.SetNum("fc1-3", iFade[0][2]);
        kv.SetNum("fc2-1", iFade[1][0]); kv.SetNum("fc2-2", iFade[1][1]); kv.SetNum("fc2-3", iFade[1][2]);
        
        kv.SetNum("colorfading", view_as<int>(Cel_IsFading(i)));
        kv.SetNum("colorrainbow", view_as<int>(Cel_IsRainbow(i)));

        EntityType type = Cel_GetEntityType(i);
        
        // Handle specific extra fields
        if (type == ENTTYPE_CYCLER || type == ENTTYPE_DYNAMIC || type == ENTTYPE_PHYSICS) {
            Cel_GetPropName(i, sExtra, sizeof(sExtra));
            kv.SetString("propname", sExtra);
            if(type == ENTTYPE_CYCLER) kv.SetNum("animsequence", Entity_GetAnimSequence(i));
            if(type == ENTTYPE_PHYSICS) kv.SetNum("breakable", view_as<int>(Cel_IsBreakable(i)));
        } else if (type == ENTTYPE_DOOR) {
            kv.SetFloat("o3", fRel[2] - 54.0);
        } else if (type == ENTTYPE_TRIGGER) {
            kv.SetFloat("a2", fAng[1] - 180.0);
            kv.SetNum("controllerid", i); // Store index as ID for linking
        }
        
        // If this entity is controlled by something else
        int iCtrl = Cel_GetControllerEntity(i);
        if(iCtrl != -1) kv.SetNum("controllerentity", iCtrl);

        kv.Rewind();
    }

    kv.ExportToFile(sFile);
    delete kv;
    
    if (bOutside) Cel_ReplyToCommand(iClient, "%t", "PropOutsideLand");
    Cel_ReplyToCommand(iClient, "%t", "SavedBuild", sSaveName);
    
    return true;
}
