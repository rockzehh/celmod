#if defined _celmod_included
#endinput
#endif
#define _celmod_included

#include <sdkhooks>
#include <sdktools>
#include <morecolors>
#include <sourcemod>
#include <smlib>

enum EntityCatagory
{
	ENTCATAGORY_CEL = 0, 
	ENTCATAGORY_PROP = 1, 
	ENTCATAGORY_UNKNOWN = 2, 
};

enum EntityType
{
	ENTTYPE_CYCLER = 0, 
	ENTTYPE_DOOR = 1, 
	ENTTYPE_DYNAMIC = 2, 
	ENTTYPE_EFFECT = 3, 
	ENTTYPE_INTERNET = 4, 
	ENTTYPE_LIGHT = 5, 
	ENTTYPE_PHYSICS = 6, 
	ENTTYPE_UNKNOWN = 7, 
};

enum EffectType
{
	EFFECT_CORE = 0,  
	EFFECT_EXPLOSION = 1, 
	EFFECT_FIRE = 2,  
	EFFECT_SHAKE = 3, 
	EFFECT_SMOKESTACK = 4,  
	EFFECT_SPOTLIGHT = 5,  
	EFFECT_STEAM = 6,  
	EFFECT_UNKNOWN = 7, 
};

#define CEL_AUTHOR "rockzehh" 
#define CEL_URL "https://github.com/rockzehh/celmod"
#define CEL_VERSION "2.0.0.0" 
#define UPDATE_URL "https://raw.githubusercontent.com/rockzehh/celmod/main/addons/sourcemod/celmod_update.upd" 

#define MAXENTITIES 2048 
#define PLAYER_CROWBAR_ATTACK_RADIUS 2.0 
#define PLAYER_USE_RADIUS 80.0

float g_fDown[3] = { 90.0, 0.0, 0.0 };
float g_fUp[3] = { -90.0, 0.0, 0.0 };
float g_fZero[3] = { 0.0, 0.0, 0.0 };

//Colors:
int g_iBlue[4] =  { 0, 0, 255, 175 };
int g_iGray[4] =  { 255, 255, 255, 300 };
int g_iGreen[4] =  { 0, 255, 0, 175 };
int g_iOrange[4] =  { 255, 128, 0, 175 };
int g_iRed[4] =  { 255, 0, 0, 175 };
int g_iWhite[4] =  { 255, 255, 255, 175 };
int g_iYellow[4] =  { 255, 255, 0, 175 };

//========== celmod.smx ==========
forward void Cel_OnCelSpawn(int iCel, int iOwner, EntityType etEntityType);
forward void Cel_OnEntityRemove(int iEntity, int iOwner, bool bCel);
forward void Cel_OnPropSpawn(int iProp, int iOwner, EntityType etEntityType);

native void Cel_AddToCelCount(int iClient);
native void Cel_AddToPropCount(int iClient);
native void Cel_ChangeBeam(int iClient, int iEntity);
native void Cel_ChangePositionRelativeToOrigin(int iEntity, const float fAddOrigin[3]);
native bool Cel_CheckCelCount(int iClient);
native bool Cel_CheckColorDB(const char[] sColor, char[] sColorString, int iMaxLength);
native bool Cel_CheckEntityCatagory(int iEntity, EntityCatagory ecEntityCatagory);
native bool Cel_CheckEntityType(int iEntity, const char[] sTypeCheck);
native bool Cel_CheckOwner(int iClient, int iEntity);
native bool Cel_CheckPropCount(int iClient);
native bool Cel_CheckRenderFX(const int iEntity, const char[] sType);
native bool Cel_CheckSpawnDB(const char[] sAlias, char[] sSpawnString, int iMaxLength);
native void Cel_DissolveEntity(int iEntity);
native char Cel_GetAuthID(int iClient, char[] sAuthID, int iMaxLength);
native int Cel_GetBeamMaterial();
native int Cel_GetCelCount(int iClient);
native int Cel_GetCelLimit();
native int Cel_GetClientAimTarget(int iClient);
native int Cel_GetColor(int iEntity, int iColor[4]);
native float Cel_GetCrosshairHitOrigin(int iClient, float fCrosshairOrigin[3]);
native EntityCatagory Cel_GetEntityCatagory(int iEntity);
native char Cel_GetEntityCatagoryName(int iEntity, char[] sEntityCatagory, int iMaxLength);
native EntityType Cel_GetEntityType(int iEntity);
native EntityType Cel_GetEntityTypeFromName(const char[] sEntityType);
native char Cel_GetEntityTypeName(EntityType etEntityType, char[] sEntityType, int iMaxLength);
native int Cel_GetHaloMaterial();
native char Cel_GetInternetURL(int iEntity, const char[] sURL, int iMaxLength);
native bool Cel_GetMotion(int iEntity);
native int Cel_GetNoKill(int iClient);
native int Cel_GetOwner(int iEntity);
native int Cel_GetPhysicsMaterial();
native int Cel_GetPropCount(int iClient);
native int Cel_GetPropLimit();
native char Cel_GetPropName(int iEntity, const char[] sPropName, int iMaxLength);
native RenderFx Cel_GetRenderFX(int iEntity);
native RenderFx Cel_GetRenderFXFromName(const char[] sRenderFXName);
native char Cel_GetRenderFXName(RenderFx rfRenderFX, char[] sRenderFX, int iMaxLength);
native bool Cel_IsEntity(int iEntity);
native bool Cel_IsPlayer(int iClient);
native bool Cel_IsSolid(int iEntity);
native void Cel_LoadBuild(int iClient, const char[] sSaveName);
native void Cel_NotLooking(int iClient);
native void Cel_NotYours(int iClient, int iEntity);
native void Cel_PlayChatMessageSound(int iClient);
native void Cel_PrintToChat(int iClient, const char[] sMessage, any ...);
native void Cel_PrintToChatAll(const char[] sMessage, any ...);
native void Cel_RemovalBeam(int iClient, int iEntity);
native void Cel_ReplyToCommand(int iClient, const char[] sMessage, any ...);
native void Cel_SaveBuild(int iClient, const char[] sSaveName);
native void Cel_SetAuthID(int iClient);
native void Cel_SetCelCount(int iClient, int iCount);
native void Cel_SetCelLimit(int iLimit);
native void Cel_SetColor(int iEntity, int iR, int iG, int iB, int iA);
native void Cel_SetEntity(int iEntity, bool bEntity);
native void Cel_SetInternetURL(int iEntity, const char[] sURL);
native void Cel_SetMotion(int iEntity, bool bMotion);
native void Cel_SetNoKill(int iClient, bool bNoKill);
native void Cel_SetOwner(int iClient, int iEntity);
native void Cel_SetPlayer(int iClient, bool bPlayer);
native void Cel_SetPropCount(int iClient, int iCount);
native void Cel_SetPropLimit(int iLimit);
native void Cel_SetPropName(int iEntity, const char[] sPropName);
native void Cel_SetRenderFX(int iEntity, RenderFx rfRenderFX);
native void Cel_SetSolid(int iEntity, bool bSolid);
native int Cel_SpawnDoor(int iClient, const char[] sSkin, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native int Cel_SpawnInternet(int iClient, const char[] sURL, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native int Cel_SpawnLight(int iClient, float fAngles[3], float fOrigin[3], int iR, int iG, int iB);
native int Cel_SpawnProp(int iClient, const char[] sAlias, const char[] sEntityType, const char[] sModel, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native void Cel_SubFromCelCount(int iClient);
native void Cel_SubFromPropCount(int iClient);

stock void Cel_GetEntityAngles(int iEntity, float fAngles[3])
{
	GetEntPropVector(iEntity, Prop_Data, "m_angAbsRotation", fAngles);
}
stock void Cel_GetEntityOrigin(int iEntity, float fOrigin[3])
{
	GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", fOrigin);
}
//========== celmod-effects.smx ==========
forward void Cel_OnEffectSpawn(int iEffect, int iOwner, EffectType etEffectType);

native bool Cel_CheckEffectType(const int iEffect, const char[] sType);
native int Cel_GetEffectAttachment(int iEffect);
native EffectType Cel_GetEffectType(int iEffect);
native EffectType Cel_GetEffectTypeFromName(const char[] sEffectName);
native char Cel_GetEffectTypeName(EffectType etEffectType, char[] sEffectType, int iMaxLength);
native bool Cel_IsEffectActive(int iEffect);
native void Cel_SetEffectActive(int iEffect, bool bActive);
native void Cel_SetEffectAttachment(int iEffect, int iAttachment);
native void Cel_SetEffectType(int iEffect, EffectType etEffectType);
native int Cel_SpawnEffect(const int iClient, const float fOrigin[3], const EffectType etEffect, bool bActivate, const int iR, const int iG, const int iB, const int iA);
//========== celmod-help.smx ==========
native char Cel_CheckInputURL(const char[] sInput, char[] sOutput, int iMaxLength);
native bool Cel_ExportColorList(bool bHTML);
native bool Cel_ExportCommandList(bool bHTML);
native bool Cel_ExportPropList(bool bHTML);
native void Cel_OpenMOTDOnClient(int iClient, bool bShow, const char[] sTitle, const char[] sDestination, int iType = MOTDPANEL_TYPE_URL);
//========== celmod-hud.smx ==========
native void Cel_ChooseHudColor(int iClient);
native int Cel_GetHudColor(int iClient, int iColor[4]);
native void Cel_SendHudMessage(int iClient, int iChannel, float fX, float fY, int iR, int iG, int iB, int iA, int iEffect, float fFadeIn, float fFadeOut, float fHoldTime, float fFxTime, char[] sMessage);
native void Cel_SetHudColor(int iClient, int iR, int iG, int iB, int iA);
//========== celmod-land.smx ==========
native void Cel_ClearLand(int iClient);
native int Cel_CreateLand(int iClient, float fMin[3], float fMax[3]);
native void Cel_DrawLandBorders(float fFrom[3], float fTo[3], float fLife, int iColor[4], bool bFlat=true);
native int Cel_GetClientCrosshairLandOwner(int iClient);
native int Cel_GetCurrentLandEntity(int iClient);
native int Cel_GetCurrentLandOwner(int iClient);
native int Cel_GetLandEntity(float fBottomCorner[3], float fTopCorner[3]);
native float Cel_GetLandGravity(int iLand);
native int Cel_GetLandOwner(float fBottomCorner[3], float fTopCorner[3]);
native float Cel_GetLandPositions(int iClient, int iPosition=1, float fPosition[3]);
native void Cel_GetMiddleOfABox(float fMin[3], float fMax[3], float fBuffer[3]);
native bool Cel_IsClientCrosshairInLand(int iClient);
native bool Cel_IsClientInLand(int iClient, int iLand);
native bool Cel_IsEntityInLand(int iEntity, const char[] sLandOwner, int iMaxLength);
native bool Cel_IsPositionInBox(float fPos[3], float fBottomCorner[3], float fTopCorner[3]);
native void Cel_SetLandGravity(int iLand);

//Hooks:
public void Hook_EffectUse(int iEntity, int iActivator, int iCaller, UseType utType, float fValue)
{
	switch(Cel_GetEffectType(iEntity))
	{
		case EFFECT_CORE:
		{
			SetVariantFloat(0.0);
			AcceptEntityInput(Cel_GetEffectAttachment(iEntity), Cel_IsEffectActive(iEntity) ? "StartDischarge" : "StartCharge");
		}
		case EFFECT_EXPLOSION:
		{
			AcceptEntityInput(Cel_GetEffectAttachment(iEntity), "Explode");
		}
		case EFFECT_FIRE:
		{
			SetVariantFloat(0.0);
			AcceptEntityInput(Cel_GetEffectAttachment(iEntity), Cel_IsEffectActive(iEntity) ? "StartFire" : "ExtinguishTemporary");
		}
		case EFFECT_SHAKE:
		{
			AcceptEntityInput(Cel_GetEffectAttachment(iEntity), "StartShake");
		}
		case EFFECT_SMOKESTACK:
		{
			AcceptEntityInput(Cel_GetEffectAttachment(iEntity), Cel_IsEffectActive(iEntity) ? "TurnOn" : "TurnOff");
		}
		case EFFECT_SPOTLIGHT:
		{
			AcceptEntityInput(Cel_GetEffectAttachment(iEntity), Cel_IsEffectActive(iEntity) ? "LightOn" : "LightOff");
		}
		case EFFECT_STEAM:
		{
			AcceptEntityInput(Cel_GetEffectAttachment(iEntity), Cel_IsEffectActive(iEntity) ? "TurnOn" : "TurnOff");
		}
	}
	
	Cel_SetEffectActive(iEntity, !Cel_IsEffectActive(iEntity));
}

public void Hook_InternetUse(int iEntity, int iActivator, int iCaller, UseType utType, float fValue)
{
	char sURL[PLATFORM_MAX_PATH];
	
	Cel_GetInternetURL(iEntity, sURL, sizeof(sURL));
	Cel_OpenMOTDOnClient(iActivator, true, "|CelMod| Viewer", sURL, MOTDPANEL_TYPE_URL);
}

//Timers:
public Action Timer_DelayRemove(Handle hTimer, any iRef)
{
	int iEntity = EntRefToEntIndex(iRef);
	
	AcceptEntityInput(iEntity, "kill");
	
	return Plugin_Continue;
}

public Action Timer_DisRemove(Handle hTimer, any iRef)
{
	int iEntity = EntRefToEntIndex(iRef);
	
	Cel_DissolveEntity(iEntity);
	
	return Plugin_Continue;
}

//Stocks:
stock void Cel_DownloadClientFiles()
{
	char sPath[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/downloads.txt");
	
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
}