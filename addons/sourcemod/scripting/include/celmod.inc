#if defined _celmod_included
#endinput
#endif
#define _celmod_included

#include <sdkhooks>
#include <sdktools>
#include <morecolors>
#include <sourcemod>
#include <smlib>
#include <studio_hdr>

enum EntityCatagory
{
	ENTCATAGORY_BIT = 0,
	ENTCATAGORY_CEL = 1,
	ENTCATAGORY_PROP = 2,
	ENTCATAGORY_UNKNOWN = 3,
};

enum EntityType
{
	ENTTYPE_CYCLER = 0,
	ENTTYPE_DOOR = 1,
	ENTTYPE_DYNAMIC = 2,
	ENTTYPE_EFFECT = 3,
	ENTTYPE_INTERNET = 4,
	ENTTYPE_LADDER = 5,
	ENTTYPE_LIGHT = 6,
	ENTTYPE_PHYSICS = 7,
	ENTTYPE_CLEER = 8,
	ENTTYPE_BIT = 9,
	ENTTYPE_AMMO = 10,
	ENTTYPE_AMMOCRATE = 11,
	ENTTYPE_CHARGER = 12,
	ENTTYPE_WEAPONSPWNER = 13,
	ENTTYPE_TRIGGER = 14,
	ENTTYPE_LINK = 15,
	ENTTYPE_MUSIC = 16,
	ENTTYPE_SOUND = 17,
	ENTTYPE_UNKNOWN = 18,
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

enum WeaponBitType
{
	WEPBIT_GRAVGUN = 0,
	WEPBIT_STUNSTICK = 1,
	WEPBIT_CROWBAR = 2,
	WEPBIT_PISTOL = 3,
	WEPBIT_MAGNUM = 4,
	WEPBIT_SMG = 5,
	WEPBIT_AR2 = 6,
	WEPBIT_SHOTGUN = 7,
	WEPBIT_CROSSBOW = 8,
	WEPBIT_GRENADE = 9,
	WEPBIT_RPG = 10,
	WEPBIT_SLAM = 11,
	WEPBIT_UNKNOWN = 12,
};

enum AmmoBitType
{
	AMMOBIT_PISTOL = 0,
	AMMOBIT_MAGNUM = 1,
	AMMOBIT_SMG = 2,
	AMMOBIT_AR2 = 3,
	AMMOBIT_SHOTGUN = 4,
	AMMOBIT_CROSSBOW = 5,
	AMMOBIT_RPG = 6,
	AMMOBIT_UNKNOWN = 7,
};

enum AmmoCrateType
{
	AMMOCRATEBIT_SMG = 1,
	AMMOCRATEBIT_AR2 = 2,
	AMMOCRATEBIT_RPG = 3,
	AMMOCRATEBIT_GRENADE = 5,
	AMMOCRATEBIT_CBALL = 8,
	AMMOCRATEBIT_UNKNOWN = 9,
};

enum ChargerType
{
	CHARGERBIT_HEALTH = 0,
	CHARGERBIT_SUIT = 1,
	CHARGERBIT_UNKNOWN = 2,
};

enum ControlTriggerType
{
	TRIGGERTYPE_BUTTON = 0,
	TRIGGERTYPE_STEP = 1,
};

#define CEL_AUTHOR "rockzehh"
#define CEL_URL "https://github.com/rockzehh/celmod"
#define CEL_VERSION "3.1.0"
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

//Forwards:
forward void Cel_OnCelSpawn(int iCel, int iOwner, EntityType etEntityType);
forward void Cel_OnEffectSpawn(int iEffect, int iOwner, EffectType etEffectType);
forward void Cel_OnEntityRemove(int iEntity, int iOwner, EntityCatagory ecEntityCatagory, EntityType etEntityType);
forward void Cel_OnPropSpawn(int iProp, int iOwner, EntityType etEntityType);

//Natives:
// celmod.sp
native void Cel_AddToBlacklist(char[] sAlias);
native void Cel_AddToCelCount(int iClient);
native void Cel_AddToPropCount(int iClient);
native void Cel_ChangeBeam(int iClient, int iEntity);
native bool Cel_CheckBlacklistDB(const char[] sAlias);
native bool Cel_CheckCelCount(int iClient);
native bool Cel_CheckPropCount(int iClient);
native bool Cel_CheckSpawnDB(const char[] sAlias, char[] sSpawnString, int iMaxLength);
native void Cel_DownloadClientFiles();
native char Cel_GetAuthID(int iClient, char[] sAuthID, int iMaxLength);
native int Cel_GetBeamMaterial();
native int Cel_GetCelCount(int iClient);
native int Cel_GetCelLimit();
native int Cel_GetClientAimTarget(int iClient);
native int Cel_GetCombinedCount(int iClient);
native float Cel_GetCrosshairHitOrigin(int iClient, float fCrosshairOrigin[3]);
native int Cel_GetHaloMaterial();
native int Cel_GetNoKill(int iClient);
native int Cel_GetPhysicsMaterial();
native int Cel_GetPropCount(int iClient);
native int Cel_GetPropLimit();
native bool Cel_IsPlayer(int iClient);
native void Cel_RemovalBeam(int iClient, int iEntity);
native void Cel_RemoveFromBlacklist(char[] sAlias);
native void Cel_SetAuthID(int iClient);
native void Cel_SetCelCount(int iClient, int iCount);
native void Cel_SetCelLimit(int iLimit);
native void Cel_SetNoKill(int iClient, bool bNoKill);
native void Cel_SetPlayer(int iClient, bool bPlayer);
native void Cel_SetPropCount(int iClient, int iCount);
native void Cel_SetPropLimit(int iLimit);
native int Cel_SpawnProp(int iClient, const char[] sAlias, const char[] sEntityType, const char[] sModel, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native void Cel_SubFromCelCount(int iClient);
native void Cel_SubFromPropCount(int iClient);

// celmod-bits.sp
native AmmoBitType Cel_GetAmmoType(int iEntity);
native AmmoBitType Cel_GetAmmoTypeFromName(char[] sAmmo);
native void Cel_GetAmmoTypeName(AmmoBitType abtType, const char[] sName, int iMaxLength);
native AmmoCrateType Cel_GetAmmoCrateType(int iEntity);
native AmmoCrateType Cel_GetAmmoCrateTypeFromName(char[] sAmmoCrate);
native void Cel_GetAmmoCrateTypeName(AmmoCrateType actType, const char[] sName, int iMaxLength);
native ChargerType Cel_GetChargerType(int iEntity);
native ChargerType Cel_GetChargerTypeFromName(char[] sCharger);
native void Cel_GetChargerTypeName(ChargerType ctType, const char[] sName, int iMaxLength);
native int Cel_GetTriggerType(iEntity);
native WeaponBitType Cel_GetWeaponType(int iEntity);
native WeaponBitType Cel_GetWeaponTypeFromName(char[] sWeapon);
native void Cel_GetWeaponTypeName(WeaponBitType wbtType, const char[] sName, int iMaxLength);
native bool Cel_IsTrigger(iEntity);
native int Cel_SpawnAmmoBit(int iClient, AmmoBitType abtType, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native int Cel_SpawnAmmoCrate(int iClient, AmmoCrateType actType, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native int Cel_SpawnButton(iClient, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native int Cel_SpawnCharger(int iClient, ChargerType ctType, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native int Cel_SpawnWeaponBit(int iClient, WeaponBitType wbtType, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native void Cel_TriggerEntity(int iClient, int iEntity);

// celmod-buildsaving.sp
native void Cel_LoadBuild(int iClient, const char[] sSaveName);
native void Cel_SaveBuild(int iClient, const char[] sSaveName);

// celmod-cels.sp
native bool Cel_CheckMusicDB(const char[] sMusic, char[] sMusicString, int iMaxLength);
native bool Cel_CheckSoundDB(const char[] sSound, char[] sSoundString, int iMaxLength);
native char Cel_GetInternetURL(int iEntity, const char[] sURL, int iMaxLength);
native float Cel_GetMusicLoopTime(int iEntity);
native void Cel_GetMusicPath(int iEntity, char[] sMusicPath, int iMaxLength);
native float Cel_GetMusicVolume(int iEntity);
native void Cel_GetSoundPath(int iEntity, char[] sSoundPath, int iMaxLength);
native int Cel_GetSoundSpeed(int iEntity);
native bool Cel_IsMusicActive(int iEntity);
native bool Cel_IsMusicLooping(int iEntity);
native void Cel_KillSound(int iEntity);
native void Cel_SetInternetURL(int iEntity, const char[] sURL);
native int Cel_SpawnDoor(int iClient, int iSkin, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native int Cel_SpawnInternet(int iClient, const char[] sURL, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native int Cel_SpawnLadder(int iClient, const char[] sModel, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native int Cel_SpawnLight(int iClient, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native int Cel_SpawnMusic(int iClient, const char[] sMusicPath, bool bLoop = false, float fLoopTime = 0.0, bool bStart = true, float fVolume, int iSpeed, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);
native int Cel_SpawnSound(int iClient, const char[] sSoundPath, int iSpeed, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);

// celmod-chat.sp
native bool Cel_IsCelCommand(char sCommandString[MAX_MESSAGE_LENGTH]);
native void Cel_NotLooking(int iClient);
native void Cel_NotYours(int iClient, int iEntity);
native void Cel_PlayChatMessageSound(int iClient);
native void Cel_PrintToChat(int iClient, const char[] sMessage, any ...);
native void Cel_PrintToChatAll(const char[] sMessage, any ...);
native void Cel_ReplyToCommand(int iClient, const char[] sMessage, any ...);
native void Cel_ReplyToCommandEntity(int iClient, int iEntity, const char[] sMessage, any ...);

// celmod-clientstorage.sp
native bool Cel_CheckClientPurchase(int iClient, char[] sCommand);
native void Cel_CreateClientPurchases(int iClient);
native void Cel_CreateClientSettings(int iClient);
native float Cel_GetClientSettingFloat(int iClient, char[] sSetting);
native int Cel_GetClientSettingInt(int iClient, char[] sSetting);
native void Cel_GetClientSettingString(int iClient, char[] sSetting, char[] sValue, int iMaxLength);
native void Cel_RemoveClientPurchase(int iClient, char[] sPurchase);
native void Cel_SaveClientPurchase(int iClient, char[] sPurchase, bool bPurchased);
native void Cel_SetClientSettingFloat(int iClient, char[] sSetting, float fValue);
native void Cel_SetClientSettingInt(int iClient, char[] sSetting, int iValue);
native void Cel_SetClientSettingString(int iClient, char[] sSetting, char[] sValue);

// celmod-economy.sp
native void Cel_AddToClientBalance(int iClient, int iBalance);
native void Cel_BuyCommand(int iClient, char[] sCommand, char[] sDisplayText, int iMaxLength);
native void Cel_BuyEntity(int iClient, int iOwner, int iProp, int iPrice);
native void Cel_CancelSale(int iClient, int iProp);
native bool Cel_CheckClientBalance(int iClient, int iPrice);
native bool Cel_CheckShopDB(char[] sCommand, int iPrice, char[] sDisplayText, int iMaxLength);
native int Cel_GetClientBalance(int iClient);
native void Cel_GetClientBalanceTranslated(int iClient, char[] sBalance, int iMaxLength);
native bool Cel_GetClientPurchaseStatus(int iClient, char[] sCommand);
native int Cel_GetEntityPrice(int iEntity);
native bool Cel_IsEntityForSale(int iEntity);
native void Cel_SetClientBalance(int iClient, int iBalance);
native void Cel_StartSale(int iClient, int iEntity, int iPrice);
native void Cel_SubFromClientBalance(int iClient, int iBalance);

// celmod-effects.sp
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

// celmod-entity.sp
native void Cel_ChangePositionRelativeToOrigin(int iEntity, const float fAddOrigin[3]);
native bool Cel_CheckColorDB(const char[] sColor, char[] sColorString, int iMaxLength);
native bool Cel_CheckEntityCatagory(int iEntity, EntityCatagory ecEntityCatagory);
native bool Cel_CheckEntityType(int iEntity, const char[] sTypeCheck);
native bool Cel_CheckOwner(int iClient, int iEntity);
native bool Cel_CheckRenderFX(const int iEntity, const char[] sType);
native void Cel_CopyProp(int iClient, int iProp);
native void Cel_DissolveEntity(int iEntity);
native void Cel_DropEntityToFloor(int iEntity);
native int Cel_GetColor(int iEntity, int iColor[4]);
native EntityCatagory Cel_GetEntityCatagory(int iEntity);
native char Cel_GetEntityCatagoryName(int iEntity, char[] sEntityCatagory, int iMaxLength);
native EntityType Cel_GetEntityType(int iEntity);
native EntityType Cel_GetEntityTypeFromName(const char[] sEntityType);
native char Cel_GetEntityTypeName(EntityType etEntityType, char[] sEntityType, int iMaxLength);
native void Cel_GetFadeColor(int iEntity, iFadeFrom[3], iFadeTo[3]);
native bool Cel_GetMotion(int iEntity);
native int Cel_GetOwner(int iEntity);
native char Cel_GetPropName(int iEntity, const char[] sPropName, int iMaxLength);
native RenderFx Cel_GetRenderFX(int iEntity);
native RenderFx Cel_GetRenderFXFromName(const char[] sRenderFXName);
native char Cel_GetRenderFXName(RenderFx rfRenderFX, char[] sRenderFX, int iMaxLength);
native bool Cel_IsBreakable(int iEntity);
native bool Cel_IsDeleting(int iEntity);
native bool Cel_IsEntity(int iEntity);
native bool Cel_IsFading(int iEntity);
native bool Cel_IsLocked(int iEntity);
native bool Cel_IsRainbow(int iEntity);
native bool Cel_IsSolid(int iEntity);
native void Cel_LockEntity(int iEntity, bool bLocked);
native int Cel_PasteProp(int iClient, float fAngles[3], float fOrigin[3]);
native void Cel_SetBreakable(int iEntity, bool bBreakable);
native void Cel_SetColor(int iEntity, int iR, int iG, int iB, int iA);
native void Cel_SetColorFade(int iEntity, bool bFade, int iR1, int iG1, int iB1, int iR2, int iG2, int iB2);
native void Cel_SetEntity(int iEntity, bool bEntity);
native void Cel_SetMotion(int iEntity, bool bMotion);
native void Cel_SetOwner(int iClient, int iEntity);
native void Cel_SetPropName(int iEntity, const char[] sPropName);
native void Cel_SetRainbow(int iEntity, bool bRainbow);
native void Cel_SetRenderFX(int iEntity, RenderFx rfRenderFX);
native void Cel_SetSolid(int iEntity, bool bSolid);
native void Cel_TeleportInfrontOfClient(int iClient, int iEntity, float fAdd = 0.0);

// celmod-help.sp
native char Cel_CheckInputURL(const char[] sInput, char[] sOutput, int iMaxLength);
native bool Cel_ExportColorList(bool bHTML);
native bool Cel_ExportCommandList(bool bHTML);
native bool Cel_ExportPropList(bool bHTML);
native void Cel_OpenMOTDOnClient(int iClient, bool bShow, const char[] sTitle, const char[] sDestination, int iType = MOTDPANEL_TYPE_URL);

// celmod-hud.sp
native void Cel_ChooseHudColor(int iClient);
native int Cel_GetHudColor(int iClient, int iColor[4]);
native void Cel_SendHudMessage(int iClient, int iChannel, float fX, float fY, int iR, int iG, int iB, int iA, int iEffect, float fFadeIn, float fFadeOut, float fHoldTime, float fFxTime, char[] sMessage);
native void Cel_SetHudColor(int iClient, int iR, int iG, int iB, int iA);

// celmod-land.sp
native void Cel_ClearLand(int iClient);
native int Cel_CreateLand(int iClient, float fMin[3], float fMax[3]);
native void Cel_DrawLandBorders(float fFrom[3], float fTo[3], float fLife, int iColor[4], bool bFlat=true);
native int Cel_GetCurrentLandEntity(int iClient);
native int Cel_GetCurrentLandOwner(int iClient);
native int Cel_GetLandEntity(float fBottomCorner[3], float fTopCorner[3]);
native float Cel_GetLandGravity(int iLandOwner);
native int Cel_GetLandOwner(float fBottomCorner[3], float fTopCorner[3]);
native int Cel_GetLandOwnerFromEntity(int iEntity);
native int Cel_GetLandOwnerFromPosition(float fOrigin[3]);
native float Cel_GetLandPositions(int iClient, int iPosition=1, float fPosition[3]);
native void Cel_GetMiddleOfABox(float fMin[3], float fMax[3], float fBuffer[3]);
native bool Cel_IsClientCrosshairInLand(int iClient);
native bool Cel_IsClientInLand(int iClient);
native bool Cel_IsEntityInLand(int iEntity);
native bool Cel_IsLandCreated(int iClient);
native bool Cel_IsPositionInBox(float fPos[3], float fBottomCorner[3], float fTopCorner[3]);
native void Cel_SetLandGravity(int iLandOwner, float fGravity);
native int Cel_SetCurrentLandEntity(int iClient, int iLandEntity);
native int Cel_SetCurrentLandOwner(int iClient, int iLandOwner);

//Stocks:
stock void Cel_ActivateEffect(int iEntity)
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

public bool Cel_FilterPlayer(int iEntity, int iContentsMask, any aData)
{
	return (iEntity != aData && iEntity > MaxClients);
}

stock void Cel_FixSpawnPosition(int iEntity, float fOrigin[3])
{
	fOrigin[2] = fOrigin[2] += 300;
	
	TeleportEntity(iEntity, fOrigin, NULL_VECTOR, NULL_VECTOR);
	
	Cel_DropEntityToFloor(iEntity);
}

stock void HSVtoRGB(float fH, float fS, float fV, int iRGB[3])
{
	fH -= 360.0 * RoundToFloor(fH / 360.0);
	
	int iSeg = RoundToFloor(fH / 60.0) % 6;
	float fFrac = (fH / 60.0) - iSeg;
	
	float fP = fV * (1.0 - fS);
	float fQ = fV * (1.0 - fFrac * fS);
	float fT = fV * (1.0 - (1.0 - fFrac) * fS);
	
	float fR, fG, fB;
	
	switch (iSeg)
	{
		case 0: { fR = fV; fG = fT; fB = fP; }
		case 1: { fR = fQ; fG = fV; fB = fP; }
		case 2: { fR = fP; fG = fV; fB = fT; }
		case 3: { fR = fP; fG = fQ; fB = fV; }
		case 4: { fR = fT; fG = fP; fB = fV; }
		default:{ fR = fV; fG = fP; fB = fQ; }
	}
	
	iRGB[0] = RoundToFloor(fR * 255.0);
	iRGB[1] = RoundToFloor(fG * 255.0);
	iRGB[2] = RoundToFloor(fB * 255.0);
}

stock void RGBtoHSV(int iR8, int iG8, int iB8, float &fH, float &fS, float &fV)
{
	float fR = iR8 / 255.0;
	float fG = iG8 / 255.0;
	float fB = iB8 / 255.0;
	
	float fCMax = fR;
	if (fG > fCMax) fCMax = fG;
	if (fB > fCMax) fCMax = fB;
	
	float fCMin = fR;
	if (fG < fCMin) fCMin = fG;
	if (fB < fCMin) fCMin = fB;
	
	float fDelta = fCMax - fCMin;
	
	if (fDelta == 0.0)
	{
		fH = 0.0;
	}
	else if (fCMax == fR)
	{
		fH = 60.0 * ((fG - fB) / fDelta);
		if (fH < 0.0) fH += 360.0;
	}
	else if (fCMax == fG)
	{
		fH = 60.0 * (((fB - fR) / fDelta) + 2.0);
	}
	else
	{
		fH = 60.0 * (((fR - fG) / fDelta) + 4.0);
	}
	
	fS = (fCMax == 0.0) ? 0.0 : (fDelta / fCMax);
	fV = fCMax;
}

//Hooks:
public void Hook_EffectUse(int iEntity, int iActivator, int iCaller, UseType utType, float fValue)
{
	if(!Cel_IsLocked(iEntity))
	{
		Cel_ActivateEffect(iEntity);
	}
}

public void Hook_InternetUse(int iEntity, int iActivator, int iCaller, UseType utType, float fValue)
{
	char sURL[PLATFORM_MAX_PATH];
	
	Cel_GetInternetURL(iEntity, sURL, sizeof(sURL));
	
	if(!Cel_IsLocked(iEntity))
	{
		Cel_OpenMOTDOnClient(iActivator, true, "|CelMod| Viewer", sURL, MOTDPANEL_TYPE_URL);
	}
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