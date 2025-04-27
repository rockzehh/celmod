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
	ENTTYPE_CLEER = 7,
	ENTTYPE_UNKNOWN = 8,
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
#define CEL_VERSION "2.0.0"
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

//========== celmod.smx ==========

/**
 * Called when a Cel entity is spawned.
 *
 * @param iCel          The entity index of the spawned Cel.
 * @param iOwner        The client index of the player who owns the Cel.
 * @param etEntityType  The type of entity being spawned, as defined in the EntityType enum.
 */
forward void Cel_OnCelSpawn(int iCel, int iOwner, EntityType etEntityType);

/**
 * Called when an entity is removed from the game.
 *
 * @param iEntity  The entity index of the removed entity.
 * @param iOwner   The client index of the player who owned the entity, if applicable.
 * @param bCel     True if the entity was a Cel entity, false otherwise.
 */
forward void Cel_OnEntityRemove(int iEntity, int iOwner, bool bCel);

/**
 * Called when a prop entity is spawned.
 *
 * @param iProp         The entity index of the spawned prop.
 * @param iOwner        The client index of the player who owns the prop.
 * @param etEntityType  The type of entity being spawned, as defined in the EntityType enum.
 */
forward void Cel_OnPropSpawn(int iProp, int iOwner, EntityType etEntityType);

/**
 * Increments the Cel entity count for a client.
 *
 * @param iClient  The client index whose Cel count should be increased.
 */
native void Cel_AddToCelCount(int iClient);

/**
 * Increments the prop entity count for a client.
 *
 * @param iClient  The client index whose prop count should be increased.
 */
native void Cel_AddToPropCount(int iClient);

/**
 * Changes the beam effect of an entity.
 *
 * @param iClient  The client index performing the change.
 * @param iEntity  The entity index whose beam effect is being changed.
 */
native void Cel_ChangeBeam(int iClient, int iEntity);

/**
 * Moves an entity by adding an offset to its current position.
 *
 * @param iEntity       The entity index to move.
 * @param fAddOrigin    The float array containing the X, Y, and Z offset values.
 */
native void Cel_ChangePositionRelativeToOrigin(int iEntity, const float fAddOrigin[3]);

/**
 * Checks if a client has reached their Cel entity limit.
 *
 * @param iClient  The client index to check.
 * @return         True if the client is within the limit, false if they have exceeded it.
 */
native bool Cel_CheckCelCount(int iClient);

/**
 * Validates a color name against the internal color database.
 *
 * @param sColor        The input color name to check.
 * @param sColorString  The output string that stores the validated color.
 * @param iMaxLength    The maximum length of the output string.
 * @return              True if the color is valid, false otherwise.
 */
native bool Cel_CheckColorDB(const char[] sColor, char[] sColorString, int iMaxLength);

/**
 * Checks if an entity belongs to a specific category.
 *
 * @param iEntity          The entity index to check.
 * @param ecEntityCatagory The category to compare against (EntityCatagory enum).
 * @return                 True if the entity matches the category, false otherwise.
 */
native bool Cel_CheckEntityCatagory(int iEntity, EntityCatagory ecEntityCatagory);

/**
 * Checks if an entity matches a specific type.
 *
 * @param iEntity      The entity index to check.
 * @param sTypeCheck   The type name to compare against.
 * @return             True if the entity matches the type, false otherwise.
 */
native bool Cel_CheckEntityType(int iEntity, const char[] sTypeCheck);

/**
 * Verifies whether a client is the owner of a given entity.
 *
 * @param iClient  The client index to check.
 * @param iEntity  The entity index to verify ownership.
 * @return         True if the client owns the entity, false otherwise.
 */
native bool Cel_CheckOwner(int iClient, int iEntity);

/**
 * Checks if a client has reached their prop entity limit.
 *
 * @param iClient  The client index to check.
 * @return         True if the client is within the limit, false if they have exceeded it.
 */
native bool Cel_CheckPropCount(int iClient);

/**
 * Checks an entity's render effect type.
 *
 * @param iEntity  The entity index to check.
 * @param sType    The render effect type to compare.
 * @return         True if the entity matches the render effect type, false otherwise.
 */
native bool Cel_CheckRenderFX(const int iEntity, const char[] sType);

/**
 * Validates an alias against the internal spawn database.
 *
 * @param sAlias        The alias name to check.
 * @param sSpawnString  The output string containing the valid spawn entity name.
 * @param iMaxLength    The maximum length of the output string.
 * @return              True if the alias exists in the database, false otherwise.
 */
native bool Cel_CheckSpawnDB(const char[] sAlias, char[] sSpawnString, int iMaxLength);

/**
 * Dissolves an entity in the game world.
 *
 * @param iEntity  The entity index to dissolve.
 */
native void Cel_DissolveEntity(int iEntity);

native void Cel_DownloadClientFiles();

native char Cel_GetAuthID(int iClient, char[] sAuthID, int iMaxLength);

/**
 * Retrieves the material used for beams.
 *
 * @return The index of the beam material.
 */
native int Cel_GetBeamMaterial();

/**
 * Retrieves the current Cel entity count for a client.
 *
 * @param iClient  The client index to check.
 * @return         The number of Cels the client currently has spawned.
 */
native int Cel_GetCelCount(int iClient);

/**
 * Retrieves the maximum allowed number of Cels.
 *
 * @return The maximum limit of Cels a client can spawn.
 */
native int Cel_GetCelLimit();

/**
 * Retrieves the entity the client is currently aiming at.
 *
 * @param iClient  The client index to check.
 * @return         The entity index of the aimed target, or -1 if none.
 */
native int Cel_GetClientAimTarget(int iClient);

/**
 * Retrieves the color of an entity.
 *
 * @param iEntity  The entity index.
 * @param iColor   An integer array [R, G, B, A] storing the color values.
 * @return         The color as an integer array.
 */
native int Cel_GetColor(int iEntity, int iColor[4]);

native int Cel_GetCombinedCount(int iClient);

/**
 * Retrieves the world position where a client is aiming.
 *
 * @param iClient             The client index.
 * @param fCrosshairOrigin    The output float array storing the position [X, Y, Z].
 * @return                    The origin coordinates as a float array.
 */
native float Cel_GetCrosshairHitOrigin(int iClient, float fCrosshairOrigin[3]);

/**
 * Retrieves the category of a given entity.
 *
 * @param iEntity  The entity index.
 * @return         The entity's category as an EntityCatagory enum.
 */
native EntityCatagory Cel_GetEntityCatagory(int iEntity);

/**
 * Retrieves the name of an entity category.
 *
 * @param iEntity            The entity index.
 * @param sEntityCatagory    The output string storing the category name.
 * @param iMaxLength         The maximum length of the output string.
 * @return                   The category name as a string.
 */
native char Cel_GetEntityCatagoryName(int iEntity, char[] sEntityCatagory, int iMaxLength);

/**
 * Retrieves the type of a given entity.
 *
 * @param iEntity  The entity index.
 * @return         The entity's type as an EntityType enum.
 */
native EntityType Cel_GetEntityType(int iEntity);

/**
 * Retrieves the EntityType enum from a string.
 *
 * @param sEntityType  The name of the entity type.
 * @return             The corresponding EntityType enum.
 */
native EntityType Cel_GetEntityTypeFromName(const char[] sEntityType);

/**
 * Retrieves the name of an entity type.
 *
 * @param etEntityType  The EntityType enum to convert.
 * @param sEntityType   The output string storing the entity type name.
 * @param iMaxLength    The maximum length of the output string.
 * @return              The entity type name as a string.
 */
native char Cel_GetEntityTypeName(EntityType etEntityType, char[] sEntityType, int iMaxLength);

/**
 * Retrieves the material used for halos.
 *
 * @return The index of the halo material.
 */
native int Cel_GetHaloMaterial();

/**
 * Retrieves the URL associated with an Internet Cel entity.
 *
 * @param iEntity   The entity index.
 * @param sURL      The output string storing the URL.
 * @param iMaxLength The maximum length of the output string.
 * @return          The entity's assigned URL as a string.
 */
native char Cel_GetInternetURL(int iEntity, const char[] sURL, int iMaxLength);

/**
 * Checks if an entity has motion enabled.
 *
 * @param iEntity  The entity index to check.
 * @return         True if the entity has motion, false otherwise.
 */
native bool Cel_GetMotion(int iEntity);

/**
 * Retrieves the NoKill status of a client.
 *
 * @param iClient  The client index.
 * @return         An integer representing the NoKill status.
 */
native int Cel_GetNoKill(int iClient);

/**
 * Retrieves the owner of an entity.
 *
 * @param iEntity  The entity index.
 * @return         The client index of the owner.
 */
native int Cel_GetOwner(int iEntity);

/**
 * Retrieves the default physics material.
 *
 * @return The index of the physics material.
 */
native int Cel_GetPhysicsMaterial();

/**
 * Retrieves the current prop entity count for a client.
 *
 * @param iClient  The client index.
 * @return         The number of props the client currently has spawned.
 */
native int Cel_GetPropCount(int iClient);

/**
 * Retrieves the maximum allowed number of props.
 *
 * @return The maximum limit of props a client can spawn.
 */
native int Cel_GetPropLimit();

/**
 * Retrieves the name of a prop entity.
 *
 * @param iEntity     The entity index.
 * @param sPropName   The output string storing the prop name.
 * @param iMaxLength  The maximum length of the output string.
 * @return            The prop name as a string.
 */
native char Cel_GetPropName(int iEntity, const char[] sPropName, int iMaxLength);

/**
 * Retrieves the render effect applied to an entity.
 *
 * @param iEntity  The entity index.
 * @return         The render effect as a RenderFx enum.
 */
native RenderFx Cel_GetRenderFX(int iEntity);

/**
 * Retrieves the RenderFx enum from a string name.
 *
 * @param sRenderFXName  The render effect name.
 * @return               The corresponding RenderFx enum.
 */
native RenderFx Cel_GetRenderFXFromName(const char[] sRenderFXName);

/**
 * Retrieves the name of a render effect.
 *
 * @param rfRenderFX  The RenderFx enum.
 * @param sRenderFX   The output string storing the render effect name.
 * @param iMaxLength  The maximum length of the output string.
 * @return            The render effect name as a string.
 */
native char Cel_GetRenderFXName(RenderFx rfRenderFX, char[] sRenderFX, int iMaxLength);

/**
 * Checks if an entity is valid.
 *
 * @param iEntity  The entity index.
 * @return         True if the entity exists, false otherwise.
 */
native bool Cel_IsEntity(int iEntity);

/**
 * Checks if a client is a valid player.
 *
 * @param iClient  The client index.
 * @return         True if the client is a player, false otherwise.
 */
native bool Cel_IsPlayer(int iClient);

native bool Cel_IsRainbow(int iEntity);

/**
 * Checks if an entity is solid.
 *
 * @param iEntity  The entity index.
 * @return         True if the entity is solid, false otherwise.
 */
native bool Cel_IsSolid(int iEntity);

/**
 * Notifies a client that they are not looking at a valid entity.
 *
 * @param iClient  The client index.
 */
native void Cel_NotLooking(int iClient);

/**
 * Notifies a client that an entity does not belong to them.
 *
 * @param iClient  The client index.
 * @param iEntity  The entity index.
 */
native void Cel_NotYours(int iClient, int iEntity);

/**
 * Plays a chat message sound for a client.
 *
 * @param iClient  The client index.
 */
native void Cel_PlayChatMessageSound(int iClient);

/**
 * Sends a message to a specific client in chat.
 *
 * @param iClient   The client index.
 * @param sMessage  The message format string.
 * @param ...       Additional formatting arguments.
 */
native void Cel_PrintToChat(int iClient, const char[] sMessage, any ...);

/**
 * Sends a message to all clients in chat.
 *
 * @param sMessage  The message format string.
 * @param ...       Additional formatting arguments.
 */
native void Cel_PrintToChatAll(const char[] sMessage, any ...);

native void Cel_SetRainbow(int iEntity, bool bRainbow);

/**
 * Creates a removal beam effect on an entity.
 *
 * @param iClient  The client index.
 * @param iEntity  The entity index to apply the effect on.
 */
native void Cel_RemovalBeam(int iClient, int iEntity);

/**
 * Sends a command response to a client.
 *
 * @param iClient   The client index.
 * @param sMessage  The message format string.
 * @param ...       Additional formatting arguments.
 */
native void Cel_ReplyToCommand(int iClient, const char[] sMessage, any ...);

/**
 * Sets a client's authentication ID.
 *
 * @param iClient  The client index.
 */
native void Cel_SetAuthID(int iClient);

/**
 * Sets the Cel entity count for a client.
 *
 * @param iClient  The client index.
 * @param iCount   The new Cel count.
 */
native void Cel_SetCelCount(int iClient, int iCount);

/**
 * Sets the global Cel entity limit.
 *
 * @param iLimit  The new Cel entity limit.
 */
native void Cel_SetCelLimit(int iLimit);

/**
 * Sets the color of an entity.
 *
 * @param iEntity  The entity index.
 * @param iR       The red component (0-255).
 * @param iG       The green component (0-255).
 * @param iB       The blue component (0-255).
 * @param iA       The alpha component (0-255).
 */
native void Cel_SetColor(int iEntity, int iR, int iG, int iB, int iA);

/**
 * Sets an entity's existence state.
 *
 * @param iEntity   The entity index.
 * @param bEntity   True to enable, false to disable.
 */
native void Cel_SetEntity(int iEntity, bool bEntity);

/**
 * Assigns a URL to an Internet Cel entity.
 *
 * @param iEntity  The entity index.
 * @param sURL     The URL string to associate with the entity.
 */
native void Cel_SetInternetURL(int iEntity, const char[] sURL);

/**
 * Sets the motion state of an entity.
 *
 * @param iEntity  The entity index.
 * @param bMotion  True to enable motion, false to disable.
 */
native void Cel_SetMotion(int iEntity, bool bMotion);

/**
 * Sets the NoKill status of a client.
 *
 * @param iClient  The client index.
 * @param bNoKill  True to enable NoKill, false to disable.
 */
native void Cel_SetNoKill(int iClient, bool bNoKill);

/**
 * Assigns ownership of an entity to a client.
 *
 * @param iClient  The client index.
 * @param iEntity  The entity index.
 */
native void Cel_SetOwner(int iClient, int iEntity);

/**
 * Sets whether a client is treated as a player.
 *
 * @param iClient  The client index.
 * @param bPlayer  True to treat as a player, false otherwise.
 */
native void Cel_SetPlayer(int iClient, bool bPlayer);

/**
 * Sets the current prop count for a client.
 *
 * @param iClient  The client index.
 * @param iCount   The new prop count.
 */
native void Cel_SetPropCount(int iClient, int iCount);

/**
 * Sets the global prop limit.
 *
 * @param iLimit  The new prop limit.
 */
native void Cel_SetPropLimit(int iLimit);

/**
 * Sets the name of a prop entity.
 *
 * @param iEntity    The entity index.
 * @param sPropName  The new name for the prop.
 */
native void Cel_SetPropName(int iEntity, const char[] sPropName);

/**
 * Sets the render effect of an entity.
 *
 * @param iEntity     The entity index.
 * @param rfRenderFX  The render effect to apply.
 */
native void Cel_SetRenderFX(int iEntity, RenderFx rfRenderFX);

/**
 * Sets whether an entity is solid.
 *
 * @param iEntity  The entity index.
 * @param bSolid   True to make solid, false to make non-solid.
 */
native void Cel_SetSolid(int iEntity, bool bSolid);

/**
 * Spawns a door entity.
 *
 * @param iClient   The client index.
 * @param sSkin     The skin name for the door.
 * @param fAngles   The rotation angles of the door.
 * @param fOrigin   The spawn origin of the door.
 * @param iR        Red color component (0-255).
 * @param iG        Green color component (0-255).
 * @param iB        Blue color component (0-255).
 * @param iA        Alpha transparency (0-255).
 * @return          The entity index of the spawned door.
 */
native int Cel_SpawnDoor(int iClient, const char[] sSkin, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);

/**
 * Spawns an Internet entity with a URL.
 *
 * @param iClient   The client index.
 * @param sURL      The associated URL.
 * @param fAngles   The rotation angles of the entity.
 * @param fOrigin   The spawn origin.
 * @param iR        Red color component (0-255).
 * @param iG        Green color component (0-255).
 * @param iB        Blue color component (0-255).
 * @param iA        Alpha transparency (0-255).
 * @return          The entity index of the spawned Internet entity.
 */
native int Cel_SpawnInternet(int iClient, const char[] sURL, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);

/**
 * Spawns a prop entity.
 *
 * @param iClient     The client index.
 * @param sAlias      The alias name for the prop.
 * @param sEntityType The type of the entity.
 * @param sModel      The model path for the prop.
 * @param fAngles     The rotation angles.
 * @param fOrigin     The spawn origin.
 * @param iR          Red color component (0-255).
 * @param iG          Green color component (0-255).
 * @param iB          Blue color component (0-255).
 * @param iA          Alpha transparency (0-255).
 * @return            The entity index of the spawned prop.
 */
native int Cel_SpawnProp(int iClient, const char[] sAlias, const char[] sEntityType, const char[] sModel, float fAngles[3], float fOrigin[3], int iR, int iG, int iB, int iA);

/**
 * Subtracts one from the Cel entity count for a client.
 *
 * @param iClient  The client index.
 */
native void Cel_SubFromCelCount(int iClient);

/**
 * Subtracts one from the prop count for a client.
 *
 * @param iClient  The client index.
 */
native void Cel_SubFromPropCount(int iClient);

/**
 * Retrieves the angles of an entity.
 *
 * @param iEntity  The entity index.
 * @param fAngles  The output array storing the entity angles.
 */
stock void Cel_GetEntityAngles(int iEntity, float fAngles[3])
{
    GetEntPropVector(iEntity, Prop_Data, "m_angAbsRotation", fAngles);
}

/**
 * Retrieves the origin position of an entity.
 *
 * @param iEntity   The entity index.
 * @param fOrigin   The output array storing the entity origin.
 */
stock void Cel_GetEntityOrigin(int iEntity, float fOrigin[3])
{
    GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", fOrigin);
}

//========== celmod-effects.smx ==========

/**
 * Called when an effect entity is spawned.
 *
 * @param iEffect       The entity index of the spawned effect.
 * @param iOwner        The client index of the effect owner.
 * @param etEffectType  The type of effect being spawned.
 */
forward void Cel_OnEffectSpawn(int iEffect, int iOwner, EffectType etEffectType);

/**
 * Checks if the given effect matches a specified type.
 *
 * @param iEffect   The entity index of the effect.
 * @param sType     The effect type to check against.
 * @return          True if the effect matches the specified type, false otherwise.
 */
native bool Cel_CheckEffectType(const int iEffect, const char[] sType);

/**
 * Retrieves the attachment index for an effect.
 *
 * @param iEffect   The entity index of the effect.
 * @return          The attachment index used by the effect.
 */
native int Cel_GetEffectAttachment(int iEffect);

/**
 * Gets the type of an effect entity.
 *
 * @param iEffect   The entity index of the effect.
 * @return          The EffectType enumeration of the effect.
 */
native EffectType Cel_GetEffectType(int iEffect);

/**
 * Retrieves the EffectType from a given effect name.
 *
 * @param sEffectName  The name of the effect type.
 * @return             The corresponding EffectType enumeration.
 */
native EffectType Cel_GetEffectTypeFromName(const char[] sEffectName);

/**
 * Retrieves the name of an effect type.
 *
 * @param etEffectType  The EffectType enumeration.
 * @param sEffectType   Buffer to store the effect type name.
 * @param iMaxLength    Maximum length of the buffer.
 */
native char Cel_GetEffectTypeName(EffectType etEffectType, char[] sEffectType, int iMaxLength);

/**
 * Checks if an effect entity is currently active.
 *
 * @param iEffect   The entity index of the effect.
 * @return          True if the effect is active, false otherwise.
 */
native bool Cel_IsEffectActive(int iEffect);

/**
 * Sets the active state of an effect.
 *
 * @param iEffect   The entity index of the effect.
 * @param bActive   True to activate the effect, false to deactivate it.
 */
native void Cel_SetEffectActive(int iEffect, bool bActive);

/**
 * Sets the attachment index for an effect entity.
 *
 * @param iEffect      The entity index of the effect.
 * @param iAttachment  The new attachment index.
 */
native void Cel_SetEffectAttachment(int iEffect, int iAttachment);

/**
 * Changes the effect type of an entity.
 *
 * @param iEffect       The entity index of the effect.
 * @param etEffectType  The new EffectType to assign.
 */
native void Cel_SetEffectType(int iEffect, EffectType etEffectType);

/**
 * Spawns an effect at a specified location.
 *
 * @param iClient    The client index of the player spawning the effect.
 * @param fOrigin    The origin coordinates where the effect will be spawned.
 * @param etEffect   The EffectType to be spawned.
 * @param bActivate  Whether the effect should be active upon spawning.
 * @param iR         The red color component (0-255).
 * @param iG         The green color component (0-255).
 * @param iB         The blue color component (0-255).
 * @param iA         The alpha (transparency) component (0-255).
 * @return           The entity index of the spawned effect.
 */
native int Cel_SpawnEffect(const int iClient, const float fOrigin[3], const EffectType etEffect, bool bActivate, const int iR, const int iG, const int iB, const int iA);

//========== celmod-help.smx ==========

/**
 * Validates and processes a given input URL.
 *
 * @param sInput     The input URL to validate.
 * @param sOutput    Buffer to store the processed or validated URL.
 * @param iMaxLength Maximum length of the output buffer.
 * @return           The processed URL as a string.
 */
native char Cel_CheckInputURL(const char[] sInput, char[] sOutput, int iMaxLength);

/**
 * Exports the color list to a file.
 *
 * @param bHTML   If true, exports in HTML format; otherwise, exports in plain text.
 * @return        True on success, false on failure.
 */
native bool Cel_ExportColorList(bool bHTML);

/**
 * Exports the list of available CelMod commands.
 *
 * @param bHTML   If true, exports in HTML format; otherwise, exports in plain text.
 * @return        True on success, false on failure.
 */
native bool Cel_ExportCommandList(bool bHTML);

/**
 * Exports the list of available prop entities.
 *
 * @param bHTML   If true, exports in HTML format; otherwise, exports in plain text.
 * @return        True on success, false on failure.
 */
native bool Cel_ExportPropList(bool bHTML);

/**
 * Opens a Message of the Day (MOTD) panel for a client.
 *
 * @param iClient      The client index of the player.
 * @param bShow        True to show the MOTD panel, false to close it.
 * @param sTitle       The title of the MOTD window.
 * @param sDestination The URL or text content to be displayed.
 * @param iType        The type of MOTD panel (default is MOTDPANEL_TYPE_URL).
 */
native void Cel_OpenMOTDOnClient(int iClient, bool bShow, const char[] sTitle, const char[] sDestination, int iType = MOTDPANEL_TYPE_URL);
//========== celmod-hud.smx ==========
/**
 * Opens a menu for the client to choose a custom HUD color.
 *
 * @param iClient  The client index of the player.
 */
native void Cel_ChooseHudColor(int iClient);

/**
 * Retrieves the current HUD color settings for a client.
 *
 * @param iClient  The client index of the player.
 * @param iColor   Array to store the RGBA color values.
 * @return         The HUD color as an integer array (R, G, B, A).
 */
native int Cel_GetHudColor(int iClient, int iColor[4]);

/**
 * Sends a HUD message to a client with specific positioning, color, and effects.
 *
 * @param iClient   The client index of the player.
 * @param iChannel  The HUD channel to use (0-4).
 * @param fX        The X position of the message (0.0 - 1.0).
 * @param fY        The Y position of the message (0.0 - 1.0).
 * @param iR        Red color component (0-255).
 * @param iG        Green color component (0-255).
 * @param iB        Blue color component (0-255).
 * @param iA        Alpha (transparency) value (0-255).
 * @param iEffect   Text effect type (0 = none, 1 = fade in/out, 2 = flicker).
 * @param fFadeIn   Time for fade-in effect (in seconds).
 * @param fFadeOut  Time for fade-out effect (in seconds).
 * @param fHoldTime Duration the message stays on screen (in seconds).
 * @param fFxTime   Effect duration (for flicker or other effects).
 * @param sMessage  The message to display.
 */
native void Cel_SendHudMessage(int iClient, int iChannel, float fX, float fY, int iR, int iG, int iB, int iA, int iEffect, float fFadeIn, float fFadeOut, float fHoldTime, float fFxTime, char[] sMessage);

/**
 * Sets the custom HUD color for a client.
 *
 * @param iClient  The client index of the player.
 * @param iR       Red color component (0-255).
 * @param iG       Green color component (0-255).
 * @param iB       Blue color component (0-255).
 * @param iA       Alpha (transparency) value (0-255).
 */
native void Cel_SetHudColor(int iClient, int iR, int iG, int iB, int iA);

//========== celmod-land.smx ==========

/**
 * Clears the land data associated with a client.
 *
 * @param iClient  The client index of the player.
 */
native void Cel_ClearLand(int iClient);

/**
 * Creates a land area for a client based on the provided coordinates.
 *
 * @param iClient  The client index of the player.
 * @param fMin     The minimum (bottom corner) coordinates of the land.
 * @param fMax     The maximum (top corner) coordinates of the land.
 * @return         The entity index of the created land.
 */
native int Cel_CreateLand(int iClient, float fMin[3], float fMax[3]);

/**
 * Draws visual border lines for a land area.
 *
 * @param fFrom   The starting coordinate of the border.
 * @param fTo     The ending coordinate of the border.
 * @param fLife   The duration the border remains visible (in seconds).
 * @param iColor  RGBA color array for the border.
 * @param bFlat   Whether the borders should be drawn flat (default: true).
 */
native void Cel_DrawLandBorders(float fFrom[3], float fTo[3], float fLife, int iColor[4], bool bFlat=true);

/**
 * Retrieves the current land entity associated with a client.
 *
 * @param iClient  The client index of the player.
 * @return         The entity index of the land.
 */
native int Cel_GetCurrentLandEntity(int iClient);

/**
 * Retrieves the current owner of the land associated with a client.
 *
 * @param iClient  The client index of the player.
 * @return         The client index of the land owner.
 */
native int Cel_GetCurrentLandOwner(int iClient);

/**
 * Sets the current land entity for a client.
 *
 * @param iClient      The client index of the player.
 * @param iLandEntity  The entity index of the land to set.
 */
native int Cel_SetCurrentLandEntity(int iClient, int iLandEntity);

/**
 * Sets the current land owner for a client.
 *
 * @param iClient     The client index of the player.
 * @param iLandOwner  The client index of the new land owner.
 */
native int Cel_SetCurrentLandOwner(int iClient, int iLandOwner);

/**
 * Retrieves the land entity within the given coordinate range.
 *
 * @param fBottomCorner  The bottom corner of the search area.
 * @param fTopCorner     The top corner of the search area.
 * @return               The entity index of the land found, or -1 if none.
 */
native int Cel_GetLandEntity(float fBottomCorner[3], float fTopCorner[3]);

/**
 * Gets the gravity setting of a specific land area.
 *
 * @param iLandOwner  The client index of the land owner.
 * @return            The gravity value of the land.
 */
native float Cel_GetLandGravity(int iLandOwner);

/**
 * Gets the owner of a specific land area based on coordinates.
 *
 * @param fBottomCorner  The bottom corner of the search area.
 * @param fTopCorner     The top corner of the search area.
 * @return               The client index of the land owner, or -1 if none.
 */
native int Cel_GetLandOwner(float fBottomCorner[3], float fTopCorner[3]);

native int Cel_GetLandOwnerFromPosition(float fOrigin[3]);

/**
 * Retrieves a position from a land entity, useful for determining points in a land area.
 *
 * @param iClient    The client index of the player.
 * @param iPosition  The position type (default: 1).
 * @param fPosition  The retrieved position stored in an array.
 * @return           The position as a float array.
 */
native float Cel_GetLandPositions(int iClient, int iPosition=1, float fPosition[3]);

/**
 * Calculates the center point of a box given two opposite corners.
 *
 * @param fMin      The minimum (bottom corner) coordinates.
 * @param fMax      The maximum (top corner) coordinates.
 * @param fBuffer   The output buffer storing the center coordinates.
 */
native void Cel_GetMiddleOfABox(float fMin[3], float fMax[3], float fBuffer[3]);

native bool Cel_IsClientCrosshairInLand(int iClient);

native bool Cel_IsClientInLand(int iClient);

native bool Cel_IsEntityInLand(int iEntity);

/**
 * Checks if a given position is inside a defined land area.
 *
 * @param fPos           The position to check.
 * @param fBottomCorner  The bottom corner of the land area.
 * @param fTopCorner     The top corner of the land area.
 * @return               True if the position is inside the area, false otherwise.
 */
native bool Cel_IsPositionInBox(float fPos[3], float fBottomCorner[3], float fTopCorner[3]);

/**
 * Sets the gravity level for a specific land area.
 *
 * @param iLandOwner  The client index of the land owner.
 * @param fGravity    The new gravity value.
 */
native void Cel_SetLandGravity(int iLandOwner, float fGravity);

//========== celmod-clientstorage.smx ==========

native bool Cel_CheckClientPurchase(int iClient, char[] sCommand);

/**
 * Creates an initial set of purchases for the specified client.
 *
 * @param iClient  The client index.
 */
native void Cel_CreateClientPurchases(int iClient);

/**
 * Creates default settings for a client.
 *
 * @param iClient  The client index.
 */
native void Cel_CreateClientSettings(int iClient);

/**
 * Gets a client's setting value as a float.
 *
 * @param iClient  The client index.
 * @param sSetting The setting name to retrieve.
 * @return         The value of the setting as a float.
 */
native float Cel_GetClientSettingFloat(int iClient, char[] sSetting);

/**
 * Gets a client's setting value as an integer.
 *
 * @param iClient  The client index.
 * @param sSetting The setting name to retrieve.
 * @return         The value of the setting as an integer.
 */
native int Cel_GetClientSettingInt(int iClient, char[] sSetting);

/**
 * Gets a client's setting value as a string.
 *
 * @param iClient    The client index.
 * @param sSetting   The setting name to retrieve.
 * @param sValue     The output string that will hold the setting's value.
 * @param iMaxLength The maximum length of the output string.
 */
native void Cel_GetClientSettingString(int iClient, char[] sSetting, char[] sValue, int iMaxLength);

/**
 * Removes a specific purchase for a client.
 *
 * @param iClient   The client index.
 * @param sPurchase The purchase to remove.
 */
native void Cel_RemoveClientPurchase(int iClient, char[] sPurchase);

/**
 * Saves a purchase state for a client.
 *
 * @param iClient   The client index.
 * @param sPurchase The purchase name.
 * @param bPurchased The state of the purchase (true if purchased, false otherwise).
 */
native void Cel_SaveClientPurchase(int iClient, char[] sPurchase, bool bPurchased);

/**
 * Sets a client's setting value as a float.
 *
 * @param iClient  The client index.
 * @param sSetting The setting name to modify.
 * @param fValue   The new value to set for the setting (as a float).
 */
native void Cel_SetClientSettingFloat(int iClient, char[] sSetting, float fValue);

/**
 * Sets a client's setting value as an integer.
 *
 * @param iClient  The client index.
 * @param sSetting The setting name to modify.
 * @param iValue   The new value to set for the setting (as an integer).
 */
native void Cel_SetClientSettingInt(int iClient, char[] sSetting, int iValue);

/**
 * Sets a client's setting value as a string.
 *
 * @param iClient  The client index.
 * @param sSetting The setting name to modify.
 * @param sValue   The new value to set for the setting (as a string).
 */
native void Cel_SetClientSettingString(int iClient, char[] sSetting, char[] sValue);

//========== celmod-buildsaving.smx ==========

native int Cel_GetSaveSystemVersion();

/**
 * Loads a saved build for a client.
 *
 * @param iClient   The client index.
 * @param sSaveName The name of the save file.
 */
native void Cel_LoadBuild(int iClient, const char[] sSaveName);

/**
 * Saves a client's current build.
 *
 * @param iClient   The client index.
 * @param sSaveName The name of the save file.
 */
native void Cel_SaveBuild(int iClient, const char[] sSaveName);

//========== celmod-economy.smx ==========

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