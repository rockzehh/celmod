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
	ENTCATAGORY_CEL = 0, /**< Cel entity. cel_internet, effect_*, prop_door_rotating */
	ENTCATAGORY_PROP = 1, /**< Prop entity. cycler, prop_dynamic, prop_dynamic_override, prop_physics, prop_physics_override */
	ENTCATAGORY_UNKNOWN = 2, /**< Unknown entity. */
};

enum EntityType
{
	ENTTYPE_CYCLER = 0, /**< Cycler prop type. cycler */
	ENTTYPE_DOOR = 1, /**< Door prop type. prop_door_rotating */
	ENTTYPE_DYNAMIC = 2, /**< Dynamic prop type. prop_dynamic, prop_dynamic_override */
	ENTTYPE_EFFECT = 3, /**< Effect cel type. effect_* */
	ENTTYPE_INTERNET = 4, /**< Internet cel type. cel_internet */ 
	ENTTYPE_LIGHT = 5, /**< Light cel type. cel_light */ 
	ENTTYPE_PHYSICS = 6, /**< Physics prop type. prop_physics, prop_physics_override */
	ENTTYPE_UNKNOWN = 7, /**< Unknown prop type. */
};

enum EffectType
{
	EFFECT_CORE = 0,  /**< Core effect type. env_citadel_energy_core */
	EFFECT_EXPLOSION = 1, /**< Explosion effect type. env_explosion */
	EFFECT_FIRE = 2,  /**< Fire effect type. env_fire */
	EFFECT_SHAKE = 3, /**< Shake effect type. env_shake */
	EFFECT_SMOKESTACK = 4,  /**< Smokestack effect type. env_smokestack */
	EFFECT_SPOTLIGHT = 5,  /**< Spotlight effect type. point_spotlight */
	EFFECT_STEAM = 6,  /**< Steam effect type. env_steam */
	EFFECT_UNKNOWN = 7, /**< Unknown effect type. */
};

#define MAXENTITIES 2048 /**< Max number of entities Source can handle. */
#define MAX_MESSAGE_LENGTH		256 /**< Max length a message can be. */
#define MAX_BUFFER_LENGTH		(MAX_MESSAGE_LENGTH * 4) /** Max length the buffer can be. */
#define CEL_AUTHOR "rockzehh" /**< Global version. */
#define CEL_VERSION "1.0.1.1" /**< Global version. */
#define UPDATE_URL "https://raw.githubusercontent.com/rockzehh/celmod/main/addons/sourcemod/celmod_update.upd" /**< The url Updater uses to update. */

#define PLAYER_CROWBAR_ATTACK_RADIUS 2.0 /**<Used with Crowbar VGUI. */
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
/**
 * Adds one to the client's cel count.
 *
 * @param iClient		Index of the client.
 */
native void Cel_AddToCelCount(int iClient);

/**
 * Adds one to the client's prop count.
 *
 * @param iClient		Index of the client.
 */
native void Cel_AddToPropCount(int iClient);

/**
 * Sends out a beam to the entity provided from the client signalling a change to the entity.
 *
 * @param iClient		Index of the client.
 * @param iEntity		Index of the entity.
 */
native void Cel_ChangeBeam(int iClient, int iEntity);

/**
 * Changes a entities position relative to it's origin.
 *
 * @param iEntity		Index of the entity.
 * @param fOrigin		Add origin buffer.
 */
native void Cel_ChangePositionRelativeToOrigin(int iEntity, const float fAddOrigin[3]);

/**
 * Checks if the client's cel count has reached the server's cel limit.
 *
 * @param iClient		Index of the client.
 * @return				True if the cel limit has been reached, false if it hasn't.
 */
native bool Cel_CheckCelCount(int iClient);

/**
 * Checks if the color exists in the color database.
 *
 * @param sColor		String to check.
 * @param sColorString	Buffer to store the color string.
 * @param iMaxLength	Maximum length of the buffer.
 * @return				True if the color exists, false if it doesn't.
 */
native bool Cel_CheckColorDB(const char[] sColor, char[] sColorString, int iMaxLength);

native bool Cel_CheckEntityCatagory(int iEntity, EntityCatagory ecEntityCatagory);

/**
 * Checks if the prop type matches the search string.
 *
 * @param iEntity		Prop index.
 * @param sTypeCheck	Prop type to check.
 * @return				True if the string matches the prop type, false if it doesn't.
 */
native bool Cel_CheckEntityType(int iEntity, const char[] sTypeCheck);

/**
 * Checks if the client is the owner of the entity.
 *
 * @param iClient		Client index.
 * @param iEntity		Entity index.
 * @return				True if the client is the owner of the entity, false if it isn't.
 */
native bool Cel_CheckOwner(int iClient, int iEntity);

/**
 * Checks if the client's prop count has reached the server's prop limit.
 *
 * @param iClient		Index of the client.
 * @return				True if the prop limit has been reached, false if it hasn't.
 */
native bool Cel_CheckPropCount(int iClient);

/**
 * Checks if the prop exists in the spawn database.
 *
 * @param sAlias		String to check.
 * @param sSpawnString	Buffer to store the spawn string.
 * @param iMaxLength	Maximum length of the buffer.
 * @return				True if the prop exists, false if it doesn't.
 */
native bool Cel_CheckSpawnDB(const char[] sAlias, char[] sSpawnString, int iMaxLength);

/**
 * Dissolves the entity provided.
 *
 * @param iEntity		Entity index.
 */
native void Cel_DissolveEntity(int iEntity);

/**
 * Gets the client's auth id and stores it.
 *
 * @param iClient		Client index.
 * @param sAuthID		Buffer to store the auth id.
 * @param iMaxLength	Maximum length of the buffer.
 */
native char Cel_GetAuthID(int iClient, char[] sAuthID, int iMaxLength);

native int Cel_GetBeamMaterial();

/**
 * Gets the entity index that the client is looking at and checks if it belongs to the plugin.
 *
 * @param iClient		Client index.
 * @return				Entity index if it belongs to the plugin, -1 if it doesn't.
 */
native int Cel_GetClientAimTarget(int iClient);

/**
 * Gets the client's cel count.
 *
 * @param iClient		Client index.
 * @return				Returns the client's cel count.
 */
native int Cel_GetCelCount(int iClient);

/**
 * Gets the server's cel limit.
 *
 * @return				Returns the server's cel limit.
 */
native int Cel_GetCelLimit();

/**
 * Gets the entity color.
 *
 * @param iEntity		Entity index.
 * @param iColor		Buffer to store the color values.
 */
native int Cel_GetColor(int iEntity, int iColor[4]);

/**
 * Gets the crosshair origin.
 *
 * @param iClient			Client index.
 * @param fCrosshairOrigin	Buffer to store the crosshair origin.
 */
native float Cel_GetCrosshairHitOrigin(int iClient, float fCrosshairOrigin[3]);

stock void Cel_GetEntityAngles(int iEntity, float fAngles[3])
{
	GetEntPropVector(iEntity, Prop_Data, "m_angAbsRotation", fAngles);
}

native EntityCatagory Cel_GetEntityCatagory(int iEntity);

native char Cel_GetEntityCatagoryName(int iEntity, char[] sEntityCatagory, int iMaxLength);

stock void Cel_GetEntityOrigin(int iEntity, float fOrigin[3])
{
	GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", fOrigin);
}

/**
 * Gets the prop type.
 *
 * @param iEntity		Entity index.
 * @return				Returns the prop type.
 */
native EntityType Cel_GetEntityType(int iEntity);

/**
 * Gets the prop type from name.
 *
 * @param sEntityType		String to check.
 * @return				Returns the prop type, ENTTYPE_UNKNOWN if the name is invalid.
 */
native EntityType Cel_GetEntityTypeFromName(const char[] sEntityType);

/**
 * Gets the prop type name from prop type.
 *
 * @param etEntityType	Prop type.
 * @param sEntityType		Buffer to store the prop type.
 * @param iMaxLength	Maximum length of the buffer.
 */
native char Cel_GetEntityTypeName(EntityType etEntityType, char[] sEntityType, int iMaxLength);

native int Cel_GetHaloMaterial();

/**
 * Gets the internet cel url.
 *
 * @param iEntity		Entity index.
 * @param sURL			Buffer to store the url.
 * @param iMaxLength	Maximum length of the buffer.
 */
native char Cel_GetInternetURL(int iEntity, const char[] sURL, int iMaxLength);

/**
 * Checks if the entity is movable or not.
 *
 * @param iEffect		Entity index.
 * @return				True if the entity is movable, false if it isn't.
 */
native bool Cel_GetMotion(int iEntity);

/**
 * Checks if the client has nokill enabled.
 *
 * @param iClient			Client index.
 * @return					True if the client does, false if they don't.
 */
native int Cel_GetNoKill(int iClient);

/**
 * Gets the entity's owner index.
 *
 * @param iEntity			Entity index.
 * @return					Returns the owner's client index.
 */
native int Cel_GetOwner(int iEntity);

native int Cel_GetPhysicsMaterial();

/**
 * Gets the client's prop count.
 *
 * @param iClient		Client index.
 * @return				Returns the client's prop count.
 */
native int Cel_GetPropCount(int iClient);

/**
 * Gets the client's prop limit.
 *
 * @return				Returns the server's prop limit.
 */
native int Cel_GetPropLimit();

/**
 * Gets the name of the prop.
 *
 * @param iEntity		Entity index.
 * @param sPropNamm		Buffer to store the propname.
 * @param iMaxLength	Maximum length of the buffer.
 */
native char Cel_GetPropName(int iEntity, const char[] sPropName, int iMaxLength);

/**
 * Checks if the entity is a plugin entity.
 *
 * @param iEntity		Entity index.
 * @return				True if the entity is, false if it isn't.
 */
native bool Cel_IsEntity(int iEntity);

native bool Cel_IsPlayer(int iClient);

/**
 * Checks if the entity is solid.
 *
 * @param iEffect		Entity index.
 * @return				True if the entity is, false if it isn't.
 */
native bool Cel_IsSolid(int iEntity);

native void Cel_NotLooking(int iClient);

native void Cel_NotYours(int iClient, int iEntity);

forward void Cel_OnCelSpawn(int iCel, int iOwner, EntityType etEntityType);

forward void Cel_OnEntityRemove(int iEntity, int iOwner, bool bCel);

forward void Cel_OnPropSpawn(int iProp, int iOwner, EntityType etEntityType);

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

native void Cel_SetSolid(int iEntity, bool bSolid);

native int Cel_SpawnDoor(int iClient, const char[] sSkin, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);

native int Cel_SpawnInternet(int iClient, const char[] sURL, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);

native int Cel_SpawnLight(int iClient, float fAngles[3], float fOrigin[3], int iR, int iG, int iB);

native int Cel_SpawnProp(int iClient, const char[] sAlias, const char[] sEntityType, const char[] sModel, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);

native void Cel_SubFromCelCount(int iClient);

native void Cel_SubFromPropCount(int iClient);

/**
 * Checks if the effect type matches the search string.
 *
 * @param iEntity		Entity index.
 * @param sType			Entity type to check.
 * @return				True if the string matches the RenderFX type, false if it doesn't.
 */
native bool Cel_CheckRenderFX(const int iEntity, const char[] sType);

/**
 * Gets the RenderFX type.
 *
 * @param iEntity		Entity index.
 * @return				Returns the RenderFX type.
 */
native RenderFx Cel_GetRenderFX(int iEntity);

/**
 * Gets the RenderFX type from name.
 *
 * @param sEntityName	String to check.
 * @return				Returns the effect type, RENDERFX_NONE if the name is invalid.
 */
native RenderFx Cel_GetRenderFXFromName(const char[] sRenderFXName);

/**
 * Gets the RenderFX type name from RenderFX type.
 *
 * @param rfRenderFX	RenderFX type.
 * @param sRenderFX		Buffer to store the RenderFX type.
 * @param iMaxLength	Maximum length of the buffer.
 */
native char Cel_GetRenderFXName(RenderFx rfRenderFX, char[] sRenderFX, int iMaxLength);

native void Cel_SetRenderFX(int iEntity, RenderFx rfRenderFX);

//========== celeffects.smx ==========
/**
 * Checks if the effect type matches the search string.
 *
 * @param iEffect		Effect index.
 * @param sType			Effect type to check.
 * @return				True if the string matches the effect type, false if it doesn't.
 */
native bool Cel_CheckEffectType(const int iEffect, const char[] sType);

/**
 * Gets the effect attachment entity index.
 *
 * @param iEffect		Effect index.
 * @return				Returns the effect attachment index.
 */
native int Cel_GetEffectAttachment(int iEffect);

/**
 * Gets the effect type.
 *
 * @param iEffect		Effect index.
 * @return				Returns the effect type.
 */
native EffectType Cel_GetEffectType(int iEffect);

/**
 * Gets the effect type from name.
 *
 * @param sEffectName	String to check.
 * @return				Returns the effect type, EFFECT_UNKNOWN if the name is invalid.
 */
native EffectType Cel_GetEffectTypeFromName(const char[] sEffectName);

/**
 * Gets the effect type name from effect type.
 *
 * @param etEffectType	Effect type.
 * @param sEffectType	Buffer to store the effect type.
 * @param iMaxLength	Maximum length of the buffer.
 */
native char Cel_GetEffectTypeName(EffectType etEffectType, char[] sEffectType, int iMaxLength);

/**
 * Checks if the effect is active.
 *
 * @param iEffect		Effect index.
 * @return				True if the effect is, false if it isn't.
 */
native bool Cel_IsEffectActive(int iEffect);

forward void Cel_OnEffectSpawn(int iEffect, int iOwner, EffectType etEffectType);

native void Cel_SetEffectActive(int iEffect, bool bActive);

native void Cel_SetEffectAttachment(int iEffect, int iAttachment);

native void Cel_SetEffectType(int iEffect, EffectType etEffectType);

native int Cel_SpawnEffect(const int iClient, const float fOrigin[3], const EffectType etEffect, bool bActivate, const int iR, const int iG, const int iB, const int iA);

//========== celhelp.smx ==========
native char Cel_CheckInputURL(const char[] sInput, char[] sOutput, int iMaxLength);

/**
 * Exports the color list to a file.
 *
 * @param bHTML			If true, a html list will be generated.
 * @return				True if the list could be generated, false if it couldn't.
 */
native bool Cel_ExportColorList(bool bHTML);

/**
 * Exports the command list to a file.
 *
 * @param bHTML			If true, a html list will be generated.
 * @return				True if the list could be generated, false if it couldn't.
 */
native bool Cel_ExportCommandList(bool bHTML);

/**
 * Exports the prop list to a file.
 *
 * @param bHTML			If true, a html list will be generated.
 * @return				True if the list could be generated, false if it couldn't.
 */
native bool Cel_ExportPropList(bool bHTML);

native void Cel_OpenMOTDOnClient(int iClient, bool bShow, const char[] sTitle, const char[] sDestination, int iType = MOTDPANEL_TYPE_URL);

//========== celhud.smx ==========
native void Cel_ChooseHudColor(int iClient);

native int Cel_GetHudColor(int iClient, int iColor[4]);

native void Cel_SendHudMessage(int iClient, int iChannel, float fX, float fY, int iR, int iG, int iB, int iA, int iEffect, float fFadeIn, float fFadeOut, float fHoldTime, float fFxTime, char[] sMessage);

native void Cel_SetHudColor(int iClient, int iR, int iG, int iB, int iA);

//========== celland.smx ==========
native int Cel_CreateLandEntity(int iUserID, float fMin[3], float fMax[3]);

native void Cel_ClearLand(int iClient);

native void Cel_DrawLand(float fFrom[3], float fTo[3], float fLife, int iColor[4], bool bFlat=true);

native int Cel_GetClientCrosshairLandOwner(int iClient);

native float Cel_GetLandGravity(int iLand);

native int Cel_GetLandOwner(float fBottomCorner[3], float fTopCorner[3]);

native int Cel_GetLandOwnerUserId(int iLand);

native float Cel_GetLandPositions(int iClient, int iPosition=0, float fPosition[3]);

native void Cel_GetMiddleOfABox(float fMin[3], float fMax[3], float fBuffer[3]);

native bool Cel_IsClientInLand(int iClient, int iLand);

native bool Cel_IsClientCrosshairInLand(int iClient);

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
stock int Cel_GetBlueColor()
{
	return g_iBlue;
}

stock int Cel_GetGrayColor()
{
	return g_iGray;
}

stock int Cel_GetGreenColor()
{
	return g_iGreen;
}

stock int Cel_GetOrangeColor()
{
	return g_iOrange;
}

stock int Cel_GetRedColor()
{
	return g_iRed;
}

stock int Cel_GetWhiteColor()
{
	return g_iWhite;
}

stock int Cel_GetYellowColor()
{
	return g_iYellow;
}

stock float Cel_GetDownVector()
{
	return g_fDown;
}

stock float Cel_GetUpVector()
{
	return g_fUp;
}

stock float Cel_GetZeroVector()
{
	return g_fZero;
}
