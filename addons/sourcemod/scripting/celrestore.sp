#pragma semicolon 1

#include <celmod>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma newdecls required

StringMap smEntities;

public Plugin myinfo = 
{
	name = "CelMod: Restore", 
	author = "rockzehh", 
	description = "Restores the entities spawned incase of crash or reload.", 
	version = CEL_VERSION, 
	url = "https://github.com/rockzehh/celmod"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_reloadsandbox", Command_ReloadSandbox, ADMFLAG_ROOT, "CelMod: Reloads the sandbox plugins except for celrestore.smx.");
	RegAdminCmd("sm_restoreentities", Command_RestoreEntities, ADMFLAG_ROOT, "CelMod: Restores the plugin entities after a reload.");
	
	smEntities = new StringMap();
}

public void OnMapEnd()
{
	smEntities.Clear();
}

public void Cel_OnCelSpawn(int iCel, int iOwner, EntityType etEntityType)
{
	bool bFrozen, bSolid;
	EntityType etType = Cel_GetEntityType(iCel);
	char sClassname[PLATFORM_MAX_PATH], sEntity[16], sFinalString[PLATFORM_MAX_PATH], sInternet[PLATFORM_MAX_PATH];
	int iColor[4], iOwnerUpdated;
	
	GetEntityClassname(iCel, sClassname, sizeof(sClassname));
	GetEntityRenderColor(iCel, iColor[0], iColor[1], iColor[2], iColor[3]);
	bFrozen = Cel_IsFrozen(iCel);
	bSolid = Cel_IsSolid(iCel);
	iOwnerUpdated = Cel_GetOwner(iCel);
	
	Format(sFinalString, sizeof(sFinalString), "%s|%i|%i|%i|%i|%i|%i|%i|%i", sClassname, iColor[0], iColor[1], iColor[2], iColor[3], view_as<int>(bFrozen), view_as<int>(bSolid), iOwnerUpdated, view_as<int>(etType));
	
	switch (etType)
	{
		case ENTTYPE_INTERNET:
		{
			Cel_GetInternetURL(iCel, sInternet, sizeof(sInternet));
			
			Format(sFinalString, sizeof(sFinalString), "%s|%s", sFinalString, sInternet);
		}
	}
	
	IntToString(iCel, sEntity, sizeof(sEntity));
	
	smEntities.SetString(sEntity, sFinalString, true);
}

public void Cel_OnEffectSpawn(int iEffect, int iOwner, EffectType etEffectType)
{
	bool bEffectActive, bFrozen, bSolid;
	char sClassname[PLATFORM_MAX_PATH], sEntity[16], sFinalString[PLATFORM_MAX_PATH];
	EffectType etType = Cel_GetEffectType(iEffect);
	int iColor[4], iEffectAttachment, iOwnerUpdated;
	
	GetEntityClassname(iEffect, sClassname, sizeof(sClassname));
	GetEntityRenderColor(iEffect, iColor[0], iColor[1], iColor[2], iColor[3]);
	bFrozen = Cel_IsFrozen(iEffect);
	bSolid = Cel_IsSolid(iEffect);
	iOwnerUpdated = Cel_GetOwner(iEffect);
	bEffectActive = Cel_IsEffectActive(iEffect);
	iEffectAttachment = Cel_GetEffectAttachment(iEffect);
	
	Format(sFinalString, sizeof(sFinalString), "%s|%i|%i|%i|%i|%i|%i|%i|%i|%i|%i", sClassname, iColor[0], iColor[1], iColor[2], iColor[3], view_as<int>(bFrozen), view_as<int>(bSolid), iOwnerUpdated, view_as<int>(bEffectActive), iEffectAttachment, view_as<int>(etType));
	
	IntToString(iEffect, sEntity, sizeof(sEntity));
	
	smEntities.SetString(sEntity, sFinalString, true);
}

public void Cel_OnEntityRemove(int iEntity, int iOwner, bool bCel)
{
	char sEntity[16], sString[PLATFORM_MAX_PATH];
	
	IntToString(iEntity, sEntity, sizeof(sEntity));
	
	if (smEntities.GetString(sEntity, sString, sizeof(sString)))
	{
		smEntities.Remove(sEntity);
	}
}

public void Cel_OnPropSpawn(int iProp, int iOwner, EntityType etEntityType)
{
	bool bFrozen, bSolid;
	EntityType etType = Cel_GetEntityType(iProp);
	char sClassname[PLATFORM_MAX_PATH], sEntity[16], sFinalString[PLATFORM_MAX_PATH], sPropname[PLATFORM_MAX_PATH];
	int iColor[4], iOwnerUpdated;
	
	GetEntityClassname(iProp, sClassname, sizeof(sClassname));
	GetEntityRenderColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
	bFrozen = Cel_IsFrozen(iProp);
	bSolid = Cel_IsSolid(iProp);
	iOwnerUpdated = Cel_GetOwner(iProp);
	Cel_GetPropName(iProp, sPropname, sizeof(sPropname));
	
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
		
		if (StrContains(sFilename, "celmod") != -1 || StrContains(sFilename, "cel") != -1)
		{
			if (StrContains(sFilename, "celrestore") != -1)
			{
				//Don't reload Cel_restore!
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
			etType = Cel_GetEntityType(i);
			
			if (etType == ENTTYPE_INTERNET)
			{
				char sPropString[10][128];
				
				ExplodeString(sString, "|", sPropString, 10, sizeof(sPropString));
				
				DispatchKeyValue(i, "classname", sPropString[0]);
				
				Cel_AddToCelCount(StringToInt(sPropString[7]));
				
				Cel_SetColor(i, StringToInt(sPropString[1]), StringToInt(sPropString[2]), StringToInt(sPropString[3]), StringToInt(sPropString[4]));
				
				Cel_SetEntity(i, true);
				
				Cel_SetFrozen(i, view_as<bool>(StringToInt(sPropString[5])));
				
				Cel_SetInternetURL(i, sPropString[9]);
				
				Cel_SetOwner(StringToInt(sPropString[7]), i);
				
				Cel_SetSolid(i, view_as<bool>(StringToInt(sPropString[6])));
				
				SDKHook(i, SDKHook_UsePost, Hook_InternetUse);
			} else if (etType == ENTTYPE_DOOR)
			{
				char sPropString[9][128];
				
				ExplodeString(sString, "|", sPropString, 9, sizeof(sPropString));
				
				DispatchKeyValue(i, "classname", sPropString[0]);
				
				Cel_AddToCelCount(StringToInt(sPropString[7]));
				
				Cel_SetColor(i, StringToInt(sPropString[1]), StringToInt(sPropString[2]), StringToInt(sPropString[3]), StringToInt(sPropString[4]));
				
				Cel_SetEntity(i, true);
				
				Cel_SetFrozen(i, view_as<bool>(StringToInt(sPropString[5])));
				
				Cel_SetOwner(StringToInt(sPropString[7]), i);
				
				Cel_SetSolid(i, view_as<bool>(StringToInt(sPropString[6])));
			} else if (etType == ENTTYPE_EFFECT)
			{
				char sPropString[11][128];
				
				ExplodeString(sString, "|", sPropString, 11, sizeof(sPropString));
				
				DispatchKeyValue(i, "classname", sPropString[0]);
				
				Cel_AddToCelCount(StringToInt(sPropString[7]));
				
				Cel_SetColor(i, StringToInt(sPropString[1]), StringToInt(sPropString[2]), StringToInt(sPropString[3]), StringToInt(sPropString[4]));
				
				Cel_SetEntity(i, true);
				
				Cel_SetFrozen(i, view_as<bool>(StringToInt(sPropString[5])));
				
				Cel_SetOwner(StringToInt(sPropString[7]), i);
				
				Cel_SetSolid(i, view_as<bool>(StringToInt(sPropString[6])));
				
				Cel_SetEffectAttachment(i, StringToInt(sPropString[9]));
				
				Cel_SetColor(Cel_GetEffectAttachment(i), StringToInt(sPropString[1]), StringToInt(sPropString[2]), StringToInt(sPropString[3]), StringToInt(sPropString[4]));
				Cel_SetEntity(Cel_GetEffectAttachment(i), true);
				Cel_SetOwner(StringToInt(sPropString[7]), Cel_GetEffectAttachment(i));
				
				SDKHook(i, SDKHook_UsePost, Hook_EffectUse);
				
				Cel_SetEffectActive(i, view_as<bool>(StringToInt(sPropString[8])));
				
				Cel_SetEffectType(i, view_as<EffectType>(StringToInt(sPropString[10])));
			} else if (etType == ENTTYPE_CYCLER || etType == ENTTYPE_DYNAMIC || etType == ENTTYPE_PHYSICS)
			{
				char sPropString[10][128];
				
				ExplodeString(sString, "|", sPropString, 10, sizeof(sPropString));
				
				DispatchKeyValue(i, "classname", sPropString[0]);
				
				Cel_AddToPropCount(StringToInt(sPropString[7]));
				
				Cel_SetColor(i, StringToInt(sPropString[1]), StringToInt(sPropString[2]), StringToInt(sPropString[3]), StringToInt(sPropString[4]));
				
				Cel_SetEntity(i, true);
				
				Cel_SetFrozen(i, view_as<bool>(StringToInt(sPropString[5])));
				
				Cel_SetOwner(StringToInt(sPropString[7]), i);
				
				Cel_SetSolid(i, view_as<bool>(StringToInt(sPropString[6])));
				
				Cel_SetPropName(i, sPropString[9]);
			}
		}
	}
	
	return Plugin_Handled;
}
