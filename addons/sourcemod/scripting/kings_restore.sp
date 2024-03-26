#pragma semicolon 1

#include <kingssandbox>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma newdecls required

StringMap smEntities;

public Plugin myinfo = 
{
	name = "King's Sandbox: Restore", 
	author = "King Nothing", 
	description = "Restores the entities spawned incase of crash or reload.", 
	version = SANDBOX_VERSION, 
	url = "https://github.com/rockzehh/kingssandbox"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_reloadsandbox", Command_ReloadSandbox, ADMFLAG_ROOT, "King's Sandbox: Reloads the sandbox plugins except for ks_restore.smx.");
	RegAdminCmd("sm_restoreentities", Command_RestoreEntities, ADMFLAG_ROOT, "King's Sandbox: Restores the plugin entities after a reload.");
	
	smEntities = new StringMap();
}

public void OnMapEnd()
{
	smEntities.Clear();
}

public void KS_OnCelSpawn(int iCel, int iOwner, EntityType etEntityType)
{
	bool bFrozen, bSolid;
	EntityType etType = KS_GetEntityType(iCel);
	char sClassname[PLATFORM_MAX_PATH], sEntity[16], sFinalString[PLATFORM_MAX_PATH], sInternet[PLATFORM_MAX_PATH];
	int iColor[4], iOwnerUpdated;
	
	GetEntityClassname(iCel, sClassname, sizeof(sClassname));
	GetEntityRenderColor(iCel, iColor[0], iColor[1], iColor[2], iColor[3]);
	bFrozen = KS_IsFrozen(iCel);
	bSolid = KS_IsSolid(iCel);
	iOwnerUpdated = KS_GetOwner(iCel);
	
	Format(sFinalString, sizeof(sFinalString), "%s|%i|%i|%i|%i|%i|%i|%i|%i", sClassname, iColor[0], iColor[1], iColor[2], iColor[3], view_as<int>(bFrozen), view_as<int>(bSolid), iOwnerUpdated, view_as<int>(etType));
	
	switch (etType)
	{
		case ENTTYPE_INTERNET:
		{
			KS_GetInternetURL(iCel, sInternet, sizeof(sInternet));
			
			Format(sFinalString, sizeof(sFinalString), "%s|%s", sFinalString, sInternet);
		}
	}
	
	IntToString(iCel, sEntity, sizeof(sEntity));
	
	smEntities.SetString(sEntity, sFinalString, true);
}

public void KS_OnEffectSpawn(int iEffect, int iOwner, EffectType etEffectType)
{
	bool bEffectActive, bFrozen, bSolid;
	char sClassname[PLATFORM_MAX_PATH], sEntity[16], sFinalString[PLATFORM_MAX_PATH];
	EffectType etType = KS_GetEffectType(iEffect);
	int iColor[4], iEffectAttachment, iOwnerUpdated;
	
	GetEntityClassname(iEffect, sClassname, sizeof(sClassname));
	GetEntityRenderColor(iEffect, iColor[0], iColor[1], iColor[2], iColor[3]);
	bFrozen = KS_IsFrozen(iEffect);
	bSolid = KS_IsSolid(iEffect);
	iOwnerUpdated = KS_GetOwner(iEffect);
	bEffectActive = KS_IsEffectActive(iEffect);
	iEffectAttachment = KS_GetEffectAttachment(iEffect);
	
	Format(sFinalString, sizeof(sFinalString), "%s|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i", sClassname, iColor[0], iColor[1], iColor[2], iColor[3], view_as<int>(bFrozen), view_as<int>(bSolid), iOwnerUpdated, view_as<int>(bEffectActive), iEffectAttachment, view_as<int>(etType));
	
	IntToString(iEffect, sEntity, sizeof(sEntity));
	
	smEntities.SetString(sEntity, sFinalString, true);
}

public void KS_OnEntityRemove(int iEntity, int iOwner, bool bCel)
{
	char sEntity[16], sString[PLATFORM_MAX_PATH];
	
	IntToString(iEntity, sEntity, sizeof(sEntity));
	
	if (smEntities.GetString(sEntity, sString, sizeof(sString)))
	{
		smEntities.Remove(sEntity);
	}
}

public void KS_OnPropSpawn(int iProp, int iOwner, EntityType etEntityType)
{
	bool bFrozen, bSolid;
	EntityType etType = KS_GetEntityType(iProp);
	char sClassname[PLATFORM_MAX_PATH], sEntity[16], sFinalString[PLATFORM_MAX_PATH], sPropname[PLATFORM_MAX_PATH];
	int iColor[4], iOwnerUpdated;
	
	GetEntityClassname(iProp, sClassname, sizeof(sClassname));
	GetEntityRenderColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
	bFrozen = KS_IsFrozen(iProp);
	bSolid = KS_IsSolid(iProp);
	iOwnerUpdated = KS_GetOwner(iProp);
	KS_GetPropName(iProp, sPropname, sizeof(sPropname));
	
	Format(sFinalString, sizeof(sFinalString), "%s|%i|%i|%i|%i|%i|%i|%i|%i|%s", sClassname, iColor[0], iColor[1], iColor[2], iColor[3], view_as<int>(bFrozen), view_as<int>(bSolid), iOwnerUpdated, view_as<int>(etType), sPropname);
	
	IntToString(iProp, sEntity, sizeof(sEntity));
	
	smEntities.SetString(sEntity, sFinalString, true);
}

//Plugin Commands:
public Action Command_ReloadSandbox(int iClient, int iArgs)
{
	char sFilename[PLATFORM_MAX_PATH];
	
	Handle hPluginIterator = GetPluginIterator();
	
	while (MorePlugins(hPluginIterator))
	{
		Handle hCurrentPlugin = ReadPlugin(hPluginIterator);
		
		GetPluginFilename(hCurrentPlugin, sFilename, sizeof(sFilename));
		
		if (StrContains(sFilename, "kings_") != -1 || StrContains(sFilename, "kingssandbox") != -1)
		{
			if (StrContains(sFilename, "kings_restore") != -1)
			{
				//Don't reload ks_restore!
			}else{
				ServerCommand("sm plugins reload %s", sFilename);
			}
		}
	}
	
	return Plugin_Handled;
}

public Action Command_RestoreEntities(int iClient, int iArgs)
{
	EntityType etType;
	char sEntity[16], sString[PLATFORM_MAX_PATH];
	
	for (int i = 0; i < GetMaxEntities(); i++)
	{
		IntToString(i, sEntity, sizeof(sEntity));
		
		if (smEntities.GetString(sEntity, sString, sizeof(sString)))
		{
			etType = KS_GetEntityType(i);
			
			if (etType == ENTTYPE_INTERNET)
			{
				char sPropString[10][128];
				
				ExplodeString(sString, "|", sPropString, 10, sizeof(sPropString));
				
				DispatchKeyValue(i, "classname", sPropString[0]);
				
				KS_AddToCelCount(StringToInt(sPropString[7]));
				
				KS_SetColor(i, StringToInt(sPropString[1]), StringToInt(sPropString[2]), StringToInt(sPropString[3]), StringToInt(sPropString[4]));
				
				KS_SetEntity(i, true);
				
				KS_SetFrozen(i, view_as<bool>(StringToInt(sPropString[5])));
				
				KS_SetInternetURL(i, sPropString[9]);
				
				KS_SetOwner(StringToInt(sPropString[7]), i);
				
				KS_SetSolid(i, view_as<bool>(StringToInt(sPropString[6])));
				
				SDKHook(i, SDKHook_UsePost, Hook_InternetUse);
			} else if (etType == ENTTYPE_DOOR)
			{
				char sPropString[9][128];
				
				ExplodeString(sString, "|", sPropString, 9, sizeof(sPropString));
				
				DispatchKeyValue(i, "classname", sPropString[0]);
				
				KS_AddToCelCount(StringToInt(sPropString[7]));
				
				KS_SetColor(i, StringToInt(sPropString[1]), StringToInt(sPropString[2]), StringToInt(sPropString[3]), StringToInt(sPropString[4]));
				
				KS_SetEntity(i, true);
				
				KS_SetFrozen(i, view_as<bool>(StringToInt(sPropString[5])));
				
				KS_SetOwner(StringToInt(sPropString[7]), i);
				
				KS_SetSolid(i, view_as<bool>(StringToInt(sPropString[6])));
			} else if (etType == ENTTYPE_EFFECT)
			{
				char sPropString[11][128];
				
				ExplodeString(sString, "|", sPropString, 11, sizeof(sPropString));
				
				DispatchKeyValue(i, "classname", sPropString[0]);
				
				KS_AddToCelCount(StringToInt(sPropString[7]));
				
				KS_SetColor(i, StringToInt(sPropString[1]), StringToInt(sPropString[2]), StringToInt(sPropString[3]), StringToInt(sPropString[4]));
				
				KS_SetEntity(i, true);
				
				KS_SetFrozen(i, view_as<bool>(StringToInt(sPropString[5])));
				
				KS_SetOwner(StringToInt(sPropString[7]), i);
				
				KS_SetSolid(i, view_as<bool>(StringToInt(sPropString[6])));
				
				KS_SetEffectAttachment(i, StringToInt(sPropString[9]));
				
				KS_SetColor(KS_GetEffectAttachment(i), StringToInt(sPropString[1]), StringToInt(sPropString[2]), StringToInt(sPropString[3]), StringToInt(sPropString[4]));
				KS_SetEntity(KS_GetEffectAttachment(i), true);
				KS_SetOwner(StringToInt(sPropString[7]), KS_GetEffectAttachment(i));
				
				SDKHook(i, SDKHook_UsePost, Hook_EffectUse);
				
				KS_SetEffectActive(i, view_as<bool>(StringToInt(sPropString[8])));
				
				KS_SetEffectType(i, view_as<EffectType>(StringToInt(sPropString[10])));
			} else if (etType == ENTTYPE_CYCLER || etType == ENTTYPE_DYNAMIC || etType == ENTTYPE_PHYSICS)
			{
				char sPropString[10][128];
				
				ExplodeString(sString, "|", sPropString, 10, sizeof(sPropString));
				
				DispatchKeyValue(i, "classname", sPropString[0]);
				
				KS_AddToPropCount(StringToInt(sPropString[7]));
				
				KS_SetColor(i, StringToInt(sPropString[1]), StringToInt(sPropString[2]), StringToInt(sPropString[3]), StringToInt(sPropString[4]));
				
				KS_SetEntity(i, true);
				
				KS_SetFrozen(i, view_as<bool>(StringToInt(sPropString[5])));
				
				KS_SetOwner(StringToInt(sPropString[7]), i);
				
				KS_SetSolid(i, view_as<bool>(StringToInt(sPropString[6])));
				
				KS_SetPropName(i, sPropString[9]);
			}
		}
	}
}
