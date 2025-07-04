#pragma semicolon 1

#include <celmod>

#pragma newdecls required

const float M_PI = 3.14159265358979323846;
const float PERIOD = 3.4;

bool g_bBreakable[MAXENTITIES + 1];
bool g_bCopyFading[MAXPLAYERS + 1];
bool g_bCopyRainbow[MAXPLAYERS + 1];
bool g_bMotion[MAXENTITIES + 1];
bool g_bLate;
bool g_bLocked[MAXENTITIES + 1];
bool g_bHasCopyEntity[MAXPLAYERS + 1];
bool g_bIsFading[MAXENTITIES + 1];
bool g_bRainbow[MAXENTITIES + 1];
bool g_bSolid[MAXENTITIES + 1];

char g_sColorDB[PLATFORM_MAX_PATH];
char g_sCopyBuffer[MAXPLAYERS + 1][22][128];
char g_sPropName[MAXENTITIES + 1][64];

float g_fCopyOrigin[MAXPLAYERS + 1][3];
float g_fCopyMoveOrigin[MAXPLAYERS + 1][3];
float g_fFadeTime[MAXENTITIES + 1];
float g_fRainbowTime[MAXENTITIES + 1];

Handle g_hOnEntityRemove;

int g_iColor[MAXENTITIES + 1][4];
int g_iFadeColor[MAXENTITIES + 1][6];
int g_iEntityDissolve;
int g_iMoveCopyEntity[MAXPLAYERS + 1];
int g_iMoveEntity[MAXPLAYERS + 1];
int g_iStackInfoEnt[MAXPLAYERS + 1];
int g_iStackInfoStatus[MAXPLAYERS + 1];

RenderFx g_rfRenderFX[MAXENTITIES + 1];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_ChangePositionRelativeToOrigin", Native_ChangePositionRelativeToOrigin);
	CreateNative("Cel_CheckColorDB", Native_CheckColorDB);
	CreateNative("Cel_CheckEntityCatagory", Native_CheckEntityCatagory);
	CreateNative("Cel_CheckEntityType", Native_CheckEntityType);
	CreateNative("Cel_CheckOwner", Native_CheckOwner);
	CreateNative("Cel_CheckRenderFX", Native_CheckRenderFX);
	CreateNative("Cel_CopyProp", Native_CopyProp);
	CreateNative("Cel_DissolveEntity", Native_DissolveEntity);
	CreateNative("Cel_DropEntityToFloor", Native_DropEntityToFloor);
	CreateNative("Cel_GetColor", Native_GetColor);
	CreateNative("Cel_GetEntityCatagory", Native_GetEntityCatagory);
	CreateNative("Cel_GetEntityCatagoryName", Native_GetEntityCatagoryName);
	CreateNative("Cel_GetEntityType", Native_GetEntityType);
	CreateNative("Cel_GetEntityTypeFromName", Native_GetEntityTypeFromName);
	CreateNative("Cel_GetEntityTypeName", Native_GetEntityTypeName);
	CreateNative("Cel_GetFadeColor", Native_GetFadeColor);
	CreateNative("Cel_GetMotion", Native_GetMotion);
	CreateNative("Cel_GetOwner", Native_GetOwner);
	CreateNative("Cel_GetPropName", Native_GetPropName);
	CreateNative("Cel_GetRenderFX", Native_GetRenderFX);
	CreateNative("Cel_GetRenderFXFromName", Native_GetRenderFXFromName);
	CreateNative("Cel_GetRenderFXName", Native_GetRenderFXName);
	CreateNative("Cel_IsBreakable", Native_IsFading);
	CreateNative("Cel_IsEntity", Native_IsEntity);
	CreateNative("Cel_IsFading", Native_IsFading);
	CreateNative("Cel_IsLocked", Native_IsLocked);
	CreateNative("Cel_IsRainbow", Native_IsRainbow);
	CreateNative("Cel_IsSolid", Native_IsSolid);
	CreateNative("Cel_LockEntity", Native_LockEntity);
	CreateNative("Cel_PasteProp", Native_PasteProp);
	CreateNative("Cel_SetBreakable", Native_SetBreakable);
	CreateNative("Cel_SetColor", Native_SetColor);
	CreateNative("Cel_SetColorFade", Native_SetColorFade);
	CreateNative("Cel_SetEntity", Native_SetEntity);
	CreateNative("Cel_SetMotion", Native_SetMotion);
	CreateNative("Cel_SetOwner", Native_SetOwner);
	CreateNative("Cel_SetPropName", Native_SetPropName);
	CreateNative("Cel_SetRainbow", Native_SetRainbow);
	CreateNative("Cel_SetRenderFX", Native_SetRenderFX);
	CreateNative("Cel_SetSolid", Native_SetSolid);
	CreateNative("Cel_TeleportInfrontOfClient", Native_TeleportInfrontOfClient);
	
	g_bLate = bLate;
	
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "|CelMod| Entity Manipulator",
	author = CEL_AUTHOR,
	description = "Handles all the entity manipulation commands.",
	version = CEL_VERSION,
	url = CEL_URL
};

public void OnPluginStart()
{
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
	
	LoadTranslations("celmod.phrases");
	LoadTranslations("common.phrases");
	
	BuildPath(Path_SM, g_sColorDB, sizeof(g_sColorDB), "data/celmod/colors.txt");
	if (!FileExists(g_sColorDB))
	{
		ThrowError("|CelMod| %t", "FileNotFound", g_sColorDB);
	}
	
	g_hOnEntityRemove = CreateGlobalForward("Cel_OnEntityRemove", ET_Hook, Param_Cell, Param_Cell, Param_Cell);
	
	RegAdminCmd("v_autobuild", Command_AutoBuild, ADMFLAG_SLAY, "|CelMod| Stacks props on the x, y and z axis.");
	RegConsoleCmd("+copy", Command_StartCopy, "|CelMod| Starts copying and moving the prop you are looking at.");
	RegConsoleCmd("+move", Command_StartGrab, "|CelMod| Starts moving the prop you are looking at.");
	RegConsoleCmd("-copy", Command_StopCopy, "|CelMod| Stops copying and moving the prop you are looking at.");
	RegConsoleCmd("-move", Command_StopGrab, "|CelMod| Stops moving the prop you are looking at.");
	RegConsoleCmd("v_alpha", Command_Alpha, "|CelMod| Changes the transparency on the prop you are looking at.");
	RegConsoleCmd("v_amt", Command_Alpha, "|CelMod| Changes the transparency on the prop you are looking at.");
	RegConsoleCmd("v_color", Command_Color, "|CelMod| Colors the prop you are looking at.");
	RegConsoleCmd("v_copy", Command_CopyProp, "|CelMod| Copies the prop you are looking at into your copy buffer.");
	RegConsoleCmd("v_del", Command_Delete, "|CelMod| Removes the prop you are looking at.");
	RegConsoleCmd("v_delall", Command_DeleteAll, "|CelMod| Removes all the entities that you own.");
	RegConsoleCmd("v_delete", Command_Delete, "|CelMod| Removes the prop you are looking at.");
	RegConsoleCmd("v_deleteall", Command_DeleteAll, "|CelMod| Removes all the entities that you own.");
	RegConsoleCmd("v_drop", Command_Drop, "|CelMod| Teleports the entity you are looking at to the floor.");
	RegConsoleCmd("v_fadecolor", Command_FadeColor, "|CelMod| Fades the prop you are looking at between two colors.");
	RegConsoleCmd("v_flip", Command_HookFlip, "|CelMod| Flips the prop you are looking at.");
	RegConsoleCmd("v_freeze", Command_FreezeIt, "|CelMod| Freezes the prop you are looking at.");
	RegConsoleCmd("v_freezeit", Command_FreezeIt, "|CelMod| Freezes the prop you are looking at.");
	RegConsoleCmd("v_god", Command_God, "|CelMod| Enables/disables breakability on the prop you are looking at.");
	RegConsoleCmd("v_lock", Command_Lock, "|CelMod| Locks the cel you are looking at.");
	RegConsoleCmd("v_paint", Command_Color, "|CelMod| Colors the prop you are looking at.");
	RegConsoleCmd("v_paste", Command_PasteProp, "|CelMod| Pastes the prop in your copy buffer where you are looking at.");
	RegConsoleCmd("v_pmove", Command_SMove, "|CelMod| Moves the prop you are looking at on it's origin.");
	RegConsoleCmd("v_r", Command_HookRotate, "|CelMod| Rotates the prop you are looking at.");
	RegConsoleCmd("v_remove", Command_Delete, "|CelMod| Removes the prop you are looking at.");
	RegConsoleCmd("v_removeall", Command_DeleteAll, "|CelMod| Removes all the entities that you own.");
	RegConsoleCmd("v_renderfx", Command_RenderFX, "|CelMod| Changes the RenderFX on the prop you are looking at.");
	RegConsoleCmd("v_replace", Command_Replace, "|CelMod| Replaces the model on the entity you are looking at.");
	RegConsoleCmd("v_roll", Command_HookRoll, "|CelMod| Rolls the prop you are looking at.");
	RegConsoleCmd("v_rotate", Command_Rotate, "|CelMod| Flips, rotates and rolls the prop you are looking at.");
	RegConsoleCmd("v_skin", Command_Skin, "|CelMod| Changes the skin on the prop you are looking at.");
	RegConsoleCmd("v_smove", Command_SMove, "|CelMod| Moves the prop you are looking at on it's origin.");
	RegConsoleCmd("v_solid", Command_Solid, "|CelMod| Enables/disables solidicity on the prop you are looking at.");
	RegConsoleCmd("v_stack", Command_Stack, "|CelMod| Stacks one prop on the x, y and z axis.");
	RegConsoleCmd("v_stackinfo", Command_StackInfo, "|CelMod| Gets the origin difference between props for help stacking.");
	RegConsoleCmd("v_stand", Command_Stand, "|CelMod| Resets the angles on the prop you are looking at.");
	RegConsoleCmd("v_straight", Command_Stand, "|CelMod| Resets the angles on the prop you are looking at.");
	RegConsoleCmd("v_straighten", Command_Stand, "|CelMod| Resets the angles on the prop you are looking at.");
	RegConsoleCmd("v_unfreeze", Command_UnfreezeIt, "|CelMod| Unfreezes the prop you are looking at.");
	RegConsoleCmd("v_unfreezeit", Command_UnfreezeIt, "|CelMod| Unfreezes the prop you are looking at.");
	RegConsoleCmd("v_unlock", Command_Unlock, "|CelMod| Unlocks the cel you are looking at.");
}

public void OnClientPutInServer(int iClient)
{
	g_bCopyFading[iClient] = false;
	g_bCopyRainbow[iClient] = false;
	g_bHasCopyEntity[iClient] = false;
	
	g_fCopyOrigin[iClient] = g_fZero;
	g_fCopyMoveOrigin[iClient] = g_fZero;
	
	g_iMoveEntity[iClient] = -1;
	g_iMoveCopyEntity[iClient] = -1;
	
	g_iStackInfoEnt[iClient] = -1;
	g_iStackInfoStatus[iClient] = 0;
}

public void OnClientDisconnect(int iClient)
{
	g_bCopyFading[iClient] = false;
	g_bCopyRainbow[iClient] = false;
	g_bHasCopyEntity[iClient] = false;
	
	g_fCopyOrigin[iClient] = g_fZero;
	g_fCopyMoveOrigin[iClient] = g_fZero;
	
	g_iMoveEntity[iClient] = -1;
	g_iMoveCopyEntity[iClient] = -1;
	
	g_iStackInfoEnt[iClient] = -1;
	g_iStackInfoStatus[iClient] = 0;
}

public void OnMapStart()
{
	g_iEntityDissolve = CreateEntityByName("env_entity_dissolver");
	
	DispatchKeyValue(g_iEntityDissolve, "target", "deleted");
	DispatchKeyValue(g_iEntityDissolve, "magnitude", "50");
	DispatchKeyValue(g_iEntityDissolve, "dissolvetype", "3");
	
	DispatchSpawn(g_iEntityDissolve);
	
	DispatchKeyValue(g_iEntityDissolve, "classname", "cm_entity_dissolver");
}

public void OnMapEnd()
{
	g_iEntityDissolve = -1;
}

public void OnEntityDestroyed(int iEntity)
{
	if(Cel_IsEntity(iEntity))
	{
		if(Cel_IsPlayer(Cel_GetOwner(iEntity)))
		{
			(Cel_CheckEntityCatagory(iEntity, ENTCATAGORY_PROP)) ? Cel_SubFromPropCount(Cel_GetOwner(iEntity)) : Cel_SubFromCelCount(Cel_GetOwner(iEntity));
		}
		
		Call_StartForward(g_hOnEntityRemove);
		
		Call_PushCell(iEntity);
		Call_PushCell(Cel_GetOwner(iEntity));
		Call_PushCell(view_as<int>(Cel_GetEntityCatagory(iEntity)));
		Call_PushCell(view_as<int>(Cel_GetEntityType(iEntity)));
		
		Call_Finish();
		
		Cel_SetColorFade(iEntity, false, 0, 0, 0, 0, 0, 0);
		Cel_SetOwner(-1, iEntity);
		Cel_SetRainbow(iEntity, false);
		Cel_SetEntity(iEntity, false);
	}
}

public Action Command_Alpha(int iClient, int iArgs)
{
	char sAlpha[16], sOption[32];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Alpha");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlpha, sizeof(sAlpha));
	
	int iAlpha = StringToInt(sAlpha) < 50 ? 255 : StringToInt(sAlpha);
	
	if (iArgs > 1)
	{
		GetCmdArg(2, sOption, sizeof(sOption));
		
		if(StrContains(sOption, "#all", false) !=-1)
		{
			for (int i = 0; i < GetMaxEntities(); i++)
			{
				if (Cel_CheckOwner(iClient, i) && Cel_IsEntity(i) && IsValidEntity(i))
				{
					Cel_SetColor(i, -1, -1, -1, iAlpha);
					
					if(Cel_GetEntityType(i) == ENTTYPE_EFFECT)
					Cel_SetColor(Cel_GetEffectAttachment(i), -1, -1, -1, iAlpha);
				}
			}
			
			Cel_ReplyToCommand(iClient, "%t", "SetAllTransparency", iAlpha);
		}else{
			Cel_ReplyToCommand(iClient, "%t", "CMD_Alpha");
			return Plugin_Handled;
		}
	}else{
		if (Cel_GetClientAimTarget(iClient) == -1)
		{
			Cel_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		int iProp = Cel_GetClientAimTarget(iClient);
		
		if (Cel_CheckOwner(iClient, iProp))
		{
			Cel_SetColor(iProp, -1, -1, -1, iAlpha);
			
			if(Cel_GetEntityType(iProp) == ENTTYPE_EFFECT)
			Cel_SetColor(Cel_GetEffectAttachment(iProp), -1, -1, -1, iAlpha);
			
			Cel_ChangeBeam(iClient, iProp);
			
			Cel_ReplyToCommandEntity(iClient, iProp, "%t", "SetTransparency", iAlpha);
		} else {
			Cel_NotYours(iClient, iProp);
			return Plugin_Handled;
		}
	}
	
	return Plugin_Handled;
}

public Action Command_AutoBuild(int iClient, int iArgs)
{
	char sArgs[4][32], sEntity[4][64];
	float fAngles[3], fFinalOrigin[3], fOrigin[3];
	int iColor[4], iCount = 0;
	
	if (iArgs < 4)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_AutoBuild");
		return Plugin_Handled;
	}
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sArgs[0], sizeof(sArgs[]));
	GetCmdArg(2, sArgs[1], sizeof(sArgs[]));
	GetCmdArg(3, sArgs[2], sizeof(sArgs[]));
	GetCmdArg(4, sArgs[3], sizeof(sArgs[]));
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		if(Cel_CheckEntityType(iProp, "physics") || Cel_CheckEntityType(iProp, "dynamic"))
		{
			Entity_GetClassName(iProp, sEntity[0], sizeof(sEntity[]));
			Entity_GetName(iProp, sEntity[1], sizeof(sEntity[]));
			Entity_GetModel(iProp, sEntity[2], sizeof(sEntity[]));
			
			Cel_GetPropName(iProp, sEntity[3], sizeof(sEntity[3]));
			
			Entity_GetRenderColor(iProp, iColor);
			
			Cel_GetEntityAngles(iProp, fAngles);
			
			Cel_GetEntityOrigin(iProp, fOrigin);
			
			for(int i = 0; i < StringToInt(sArgs[0]); i++)
			{
				if (!Cel_CheckPropCount(iClient))
				{
					Cel_ReplyToCommand(iClient, "%t", "MaxPropLimit", Cel_GetPropCount(iClient));
					return Plugin_Handled;
				}
				
				fFinalOrigin[0] = fOrigin[0] += StringToFloat(sArgs[1]);
				fFinalOrigin[1] = fOrigin[1] += StringToFloat(sArgs[2]);
				fFinalOrigin[2] = fOrigin[2] += StringToFloat(sArgs[3]);
				
				int iNewProp = Cel_SpawnProp(iClient, sEntity[3], "prop_physics_override", sEntity[2], fAngles, fFinalOrigin, iColor[0], iColor[1], iColor[2], iColor[3]);
				
				Entity_SetClassName(iNewProp, sEntity[0]);
				Entity_SetName(iNewProp, sEntity[1]);
				
				Entity_SetSpawnFlags(iNewProp, Entity_GetSpawnFlags(iProp));
				Entity_SetSkin(iNewProp, Entity_GetSkin(iProp));
				Cel_SetMotion(iNewProp, Cel_GetMotion(iProp));
				Cel_SetSolid(iNewProp, Cel_IsSolid(iProp));
				
				Cel_SetRenderFX(iNewProp, Cel_GetRenderFX(iProp));
				
				Cel_SetColorFade(iNewProp, Cel_IsFading(iProp), g_iFadeColor[iProp][0], g_iFadeColor[iProp][1], g_iFadeColor[iProp][2], g_iFadeColor[iProp][3], g_iFadeColor[iProp][4], g_iFadeColor[iProp][5]);
				Cel_SetRainbow(iNewProp, Cel_IsRainbow(iProp));
				
				iCount++;
			}
			
			Cel_ReplyToCommandEntity(iClient, iProp, "%t", "StackedProps", iCount);
		}else{
			Cel_ReplyToCommand(iClient, "%t", "CantUseCommand-Prop");
			return Plugin_Handled;
		}
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Color(int iClient, int iArgs)
{
	char sColor[64], sColorBuffer[3][6], sColorString[16], sOption[32];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Color");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sColor, sizeof(sColor));
	
	if (iArgs > 1)
	{
		GetCmdArg(2, sOption, sizeof(sOption));
		
		if(StrContains(sOption, "#all", false) !=-1)
		{
			for (int i = 0; i < GetMaxEntities(); i++)
			{
				if (Cel_CheckOwner(iClient, i) && Cel_IsEntity(i) && IsValidEntity(i))
				{
					if(StrEqual(sColor, "rainbow", false))
					{
						Cel_SetRainbow(i, true);
					}else if(StrEqual(sColor, "error", false))
					{
						Cel_SetColorFade(i, true, 255, 32, 0, 0, 0, 0);
					}else if (Cel_CheckColorDB(sColor, sColorString, sizeof(sColorString)))
					{
						ExplodeString(sColorString, "|", sColorBuffer, 3, sizeof(sColorBuffer[]));
						
						Cel_SetRainbow(i, false);
						Cel_SetColorFade(i, false, 0, 0, 0, 0, 0, 0);
						
						Cel_SetColor(i, StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
						
						if(Cel_GetEntityType(i) == ENTTYPE_EFFECT)
						{
							Cel_SetRainbow(Cel_GetEffectAttachment(i), false);
							
							Cel_SetColor(Cel_GetEffectAttachment(i), StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
						}
						
						if(Cel_GetEntityType(i) == ENTTYPE_LIGHT)
						{
							Cel_SetRainbow(Entity_GetEntityAttachment(i), false);
							
							Cel_SetColor(Entity_GetEntityAttachment(i), StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
						}
					}else {
						Cel_ReplyToCommand(iClient, "%t", "ColorNotFound", sColor);
						return Plugin_Handled;
					}
				}
			}
			Cel_ReplyToCommand(iClient, "%t", "SetAllColor", sColor);
		}else if(StrContains(sOption, "#hud", false) !=-1)
		{
			if (Cel_CheckColorDB(sColor, sColorString, sizeof(sColorString)))
			{
				ExplodeString(sColorString, "|", sColorBuffer, 3, sizeof(sColorBuffer[]));
				
				Cel_SetHudColor(iClient, StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
				
				Cel_ReplyToCommand(iClient, "%t", "SetHudColor", sColor);
			}else {
				Cel_ReplyToCommand(iClient, "%t", "ColorNotFound", sColor);
				return Plugin_Handled;
			}
		}else{
			Cel_ReplyToCommand(iClient, "%t", "CMD_Color");
			return Plugin_Handled;
		}
	}else{
		if (Cel_GetClientAimTarget(iClient) == -1)
		{
			Cel_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		int iProp = Cel_GetClientAimTarget(iClient);
		
		if (Cel_CheckOwner(iClient, iProp))
		{
			if(StrEqual(sColor, "rainbow", false))
			{
				Cel_SetRainbow(iProp, true);
				
				Cel_ChangeBeam(iClient, iProp);
				
				Cel_ReplyToCommandEntity(iClient, iProp, "%t", "SetColor", "rainbow");
			}else if(StrEqual(sColor, "error", false))
			{
				Cel_SetColorFade(iProp, true, 255, 32, 0, 0, 0, 0);
				
				Cel_ChangeBeam(iClient, iProp);
				
				Cel_ReplyToCommandEntity(iClient, iProp, "%t", "SetColor", "error");
			}else if (Cel_CheckColorDB(sColor, sColorString, sizeof(sColorString)))
			{
				ExplodeString(sColorString, "|", sColorBuffer, 3, sizeof(sColorBuffer[]));
				
				Cel_SetRainbow(iProp, false);
				Cel_SetColorFade(iProp, false, 0, 0, 0, 0, 0, 0);
				
				Cel_SetColor(iProp, StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
				
				if(Cel_GetEntityType(iProp) == ENTTYPE_EFFECT)
				{
					Cel_SetRainbow(Cel_GetEffectAttachment(iProp), false);
					
					Cel_SetColor(Cel_GetEffectAttachment(iProp), StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
				}
				
				if(Cel_GetEntityType(iProp) == ENTTYPE_LIGHT)
				{
					Cel_SetRainbow(Entity_GetEntityAttachment(iProp), false);
					
					Cel_SetColor(Entity_GetEntityAttachment(iProp), StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
				}
				
				Cel_ChangeBeam(iClient, iProp);
				
				Cel_ReplyToCommandEntity(iClient, iProp, "%t", "SetColor", sColor);
			} else {
				Cel_ReplyToCommand(iClient, "%t", "ColorNotFound", sColor);
				return Plugin_Handled;
			}
		} else {
			Cel_NotYours(iClient, iProp);
			return Plugin_Handled;
		}
		
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_CopyProp(int iClient, int iArgs)
{
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		if(Cel_CheckEntityType(iProp, "physics") || Cel_CheckEntityType(iProp, "dynamic"))
		{
			Cel_CopyProp(iClient, iProp);
			
			g_bHasCopyEntity[iClient] = true;
			
			Cel_ChangeBeam(iClient, iProp);
			
			Cel_ReplyToCommandEntity(iClient, iProp, "%t", "AddedToCopyQueue");
		}else{
			Cel_ReplyToCommand(iClient, "%t", "CantUseCommand-Prop");
			return Plugin_Handled;
		}
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Delete(int iClient, int iArgs)
{
	char sOption[32];
	
	GetCmdArg(1, sOption, sizeof(sOption));
	
	if (iArgs == 1)
	{
		if(StrContains(sOption, "#land", false) !=-1)
		{
			if(Cel_IsLandCreated(iClient))
			{
				Cel_ClearLand(iClient);
				
				Cel_ReplyToCommand(iClient, "%t", "LandCleared");
			}else{
				Cel_ReplyToCommand(iClient, "%t", "LandNotStarted");
			}
			
			return Plugin_Handled;
		}else{
			Cel_ReplyToCommand(iClient, "%t", "CMD_Remove");
			return Plugin_Handled;
		}
	}else{
		if (Cel_GetClientAimTarget(iClient) == -1)
		{
			Cel_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		int iProp = Cel_GetClientAimTarget(iClient);
		
		if (Cel_CheckOwner(iClient, iProp))
		{
			if (Cel_CheckEntityType(iProp, "effect"))
			{
				Cel_SetRainbow(Cel_GetEffectAttachment(iProp), false);
				Cel_SetColorFade(Cel_GetEffectAttachment(iProp), false, 0, 0, 0, 0, 0, 0);
				
				AcceptEntityInput(Cel_GetEffectAttachment(iProp), "TurnOff");
				AcceptEntityInput(Cel_GetEffectAttachment(iProp), "kill");
			}
			
			Cel_RemovalBeam(iClient, iProp);
			
			Cel_ReplyToCommandEntity(iClient, iProp, "%t", "Remove");
			
			Cel_DissolveEntity(iProp);
		} else {
			Cel_NotYours(iClient, iProp);
			return Plugin_Handled;
		}
	}
	
	return Plugin_Handled;
}

public Action Command_DeleteAll(int iClient, int iArgs)
{
	char sRemoveCount[64];
	int iRemoveCount = 0;
	
	for (int i = 0; i < GetMaxEntities(); i++)
	{
		if (Cel_CheckOwner(iClient, i) && Cel_IsEntity(i) && IsValidEntity(i))
		{
			if (Cel_CheckEntityType(i, "effect"))
			{
				Cel_SetRainbow(Cel_GetEffectAttachment(i), false);
				Cel_SetColorFade(Cel_GetEffectAttachment(i), false, 0, 0, 0, 0, 0, 0);
				
				AcceptEntityInput(Cel_GetEffectAttachment(i), "TurnOff");
				AcceptEntityInput(Cel_GetEffectAttachment(i), "kill");
			}
			
			AcceptEntityInput(i, "kill");
			
			iRemoveCount++;
		}
	}
	
	Format(sRemoveCount, sizeof(sRemoveCount), "{green}%i{default} %s", iRemoveCount, iRemoveCount == 1 ? "entity" : "entities");
	
	Cel_ReplyToCommand(iClient, "%t", "RemoveAll", sRemoveCount);
	
	iRemoveCount = 0;
	
	return Plugin_Handled;
}

//Thanks instakill for the direction.
public Action Command_Drop(int iClient, int iArgs)
{
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_DropEntityToFloor(iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_FadeColor(int iClient, int iArgs)
{
	char sColor[2][64], sColorBuffer[3][6], sColorString[16], sOption[32];
	int iColor[6];
	
	if (iArgs < 2)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_FadeColor");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sColor[0], sizeof(sColor[]));
	GetCmdArg(2, sColor[1], sizeof(sColor[]));
	
	if (iArgs > 2)
	{
		GetCmdArg(3, sOption, sizeof(sOption));
		
		if(StrContains(sOption, "#all", false) !=-1)
		{
			for (int i = 0; i < GetMaxEntities(); i++)
			{
				if (Cel_CheckOwner(iClient, i) && Cel_IsEntity(i) && IsValidEntity(i))
				{
					if (Cel_CheckColorDB(sColor[0], sColorString, sizeof(sColorString)))
					{
						ExplodeString(sColorString, "|", sColorBuffer, 3, sizeof(sColorBuffer[]));
						
						iColor[0] = StringToInt(sColorBuffer[0]),
						iColor[1] = StringToInt(sColorBuffer[1]),
						iColor[2] = StringToInt(sColorBuffer[2]);
					} else {
						Cel_ReplyToCommand(iClient, "%t", "ColorNotFound", sColor[0]);
						return Plugin_Handled;
					}
					
					if (Cel_CheckColorDB(sColor[1], sColorString, sizeof(sColorString)))
					{
						ExplodeString(sColorString, "|", sColorBuffer, 3, sizeof(sColorBuffer[]));
						
						iColor[3] = StringToInt(sColorBuffer[0]),
						iColor[4] = StringToInt(sColorBuffer[1]),
						iColor[5] = StringToInt(sColorBuffer[2]);
					} else {
						Cel_ReplyToCommand(iClient, "%t", "ColorNotFound", sColor[1]);
						return Plugin_Handled;
					}
					
					Cel_SetColorFade(i, true, iColor[0], iColor[1], iColor[2], iColor[3], iColor[4], iColor[5]);
				}
			}
			Cel_ReplyToCommand(iClient, "%t", "SetAllFadingColors", sColor[0], sColor[1]);
		}else{
			Cel_ReplyToCommand(iClient, "%t", "CMD_FadeColor");
			return Plugin_Handled;
		}
	}else{
		if (Cel_GetClientAimTarget(iClient) == -1)
		{
			Cel_NotLooking(iClient);
			return Plugin_Handled;
		}
		
		int iProp = Cel_GetClientAimTarget(iClient);
		
		if (Cel_CheckOwner(iClient, iProp))
		{
			if (Cel_CheckColorDB(sColor[0], sColorString, sizeof(sColorString)))
			{
				ExplodeString(sColorString, "|", sColorBuffer, 3, sizeof(sColorBuffer[]));
				
				iColor[0] = StringToInt(sColorBuffer[0]),
				iColor[1] = StringToInt(sColorBuffer[1]),
				iColor[2] = StringToInt(sColorBuffer[2]);
			} else {
				Cel_ReplyToCommand(iClient, "%t", "ColorNotFound", sColor[0]);
				return Plugin_Handled;
			}
			
			if (Cel_CheckColorDB(sColor[1], sColorString, sizeof(sColorString)))
			{
				ExplodeString(sColorString, "|", sColorBuffer, 3, sizeof(sColorBuffer[]));
				
				iColor[3] = StringToInt(sColorBuffer[0]),
				iColor[4] = StringToInt(sColorBuffer[1]),
				iColor[5] = StringToInt(sColorBuffer[2]);
			} else {
				Cel_ReplyToCommand(iClient, "%t", "ColorNotFound", sColor[1]);
				return Plugin_Handled;
			}
			
			Cel_SetColorFade(iProp, true, iColor[0], iColor[1], iColor[2], iColor[3], iColor[4], iColor[5]);
			
			Cel_ChangeBeam(iClient, iProp);
			
			Cel_ReplyToCommandEntity(iClient, iProp, "%t", "SetFadingColors", sColor[0], sColor[1]);
		} else {
			Cel_NotYours(iClient, iProp);
			return Plugin_Handled;
		}
		
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_FreezeIt(int iClient, int iArgs)
{
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		if(Cel_CheckEntityCatagory(iProp, ENTCATAGORY_BIT))
		{
			Cel_ReplyToCommand(iClient, "%t", "CantUseCommand-Entity");
			return Plugin_Handled;
		}
		
		Cel_ReplyToCommandEntity(iClient, iProp, "%t", "DisableMotion");
		
		Cel_SetMotion(iProp, false);
		
		Cel_ChangeBeam(iClient, iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_God(int iClient, int iArgs)
{
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		if(Cel_CheckEntityCatagory(iProp, ENTCATAGORY_BIT))
		{
			Cel_ReplyToCommand(iClient, "%t", "CantUseCommand-Entity");
			return Plugin_Handled;
		}
		
		if (!Cel_CheckEntityType(iProp, "physics"))
		{
			Cel_ReplyToCommand(iClient, "%t", "CantUseCommand-Prop");
			return Plugin_Handled;
		}
		
		Cel_SetBreakable(iProp, !Cel_IsBreakable(iProp));
		
		Cel_ReplyToCommandEntity(iClient, iProp, "%t", "SetBreakability", Cel_IsBreakable(iProp) ? "on" : "off");
		
		Cel_ChangeBeam(iClient, iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_HookFlip(int iClient, int iArgs)
{
	char sDegree[64];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_HookFlip");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sDegree, sizeof(sDegree));
	
	ReplySource rsOldReplySrc = GetCmdReplySource();
	
	SetCmdReplySource(SM_REPLY_TO_CHAT);
	
	FakeClientCommand(iClient, "v_rotate %i 0 0", StringToInt(sDegree));
	
	SetCmdReplySource(rsOldReplySrc);
	
	return Plugin_Handled;
}

public Action Command_HookRotate(int iClient, int iArgs)
{
	char sDegree[64];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_HookRotate");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sDegree, sizeof(sDegree));
	
	ReplySource rsOldReplySrc = GetCmdReplySource();
	
	SetCmdReplySource(SM_REPLY_TO_CHAT);
	
	FakeClientCommand(iClient, "v_rotate 0 %i 0", StringToInt(sDegree));
	
	SetCmdReplySource(rsOldReplySrc);
	
	return Plugin_Handled;
}

public Action Command_HookRoll(int iClient, int iArgs)
{
	char sDegree[64];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_HookRoll");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sDegree, sizeof(sDegree));
	
	ReplySource rsOldReplySrc = GetCmdReplySource();
	
	SetCmdReplySource(SM_REPLY_TO_CHAT);
	
	FakeClientCommand(iClient, "v_rotate 0 0 %i", StringToInt(sDegree));
	
	SetCmdReplySource(rsOldReplySrc);
	
	return Plugin_Handled;
}

public Action Command_Lock(int iClient, int iArgs)
{
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		if(Cel_CheckEntityType(iProp, "cycler") || Cel_CheckEntityType(iProp, "dynamic") || Cel_CheckEntityType(iProp, "ladder") || 
			Cel_CheckEntityType(iProp, "physics") || Cel_CheckEntityType(iProp, "cleer") || Cel_CheckEntityType(iProp, "bit") || Cel_CheckEntityType(iProp, "unknown"))
		{
			Cel_ReplyToCommand(iClient, "%t", "CannotLock");
			return Plugin_Handled;
		}
		
		Cel_LockEntity(iProp, true);
		
		Cel_ReplyToCommandEntity(iClient, iProp, "%t", "Locked");
		
		Cel_ChangeBeam(iClient, iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_PasteProp(int iClient, int iArgs)
{
	float fAngles[3], fOrigin[3];
	
	if(!g_bHasCopyEntity[iClient])
	{
		Cel_ReplyToCommand(iClient, "%t", "NoPropInQueue");
		return Plugin_Handled;
	}
	
	if (!Cel_CheckPropCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxPropLimit", Cel_GetPropCount(iClient));
		return Plugin_Handled;
	}
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	int iProp = Cel_PasteProp(iClient, fAngles, fOrigin);
	
	Cel_ChangeBeam(iClient, iProp);
	
	Cel_ReplyToCommandEntity(iClient, iProp, "%t", "PastedFromCopyQueue");
	
	return Plugin_Handled;
}

public Action Command_Replace(int iClient, int iArgs)
{
	char sAlias[64], sSpawnBuffer[2][128], sSpawnString[256];
	float fAngles[3], fOrigin[3];
	int iColor[4];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Replace");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sAlias, sizeof(sAlias));
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if(Cel_CheckBlacklistDB(sAlias))
	{
		Cel_ReplyToCommand(iClient, "%t", "PropNotFound", sAlias);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if(!Cel_CheckEntityCatagory(iProp, ENTCATAGORY_PROP))
	{
		Cel_ReplyToCommand(iClient, "%t", "CantReplace");
	}
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		if (Cel_CheckSpawnDB(sAlias, sSpawnString, sizeof(sSpawnString)))
		{
			ExplodeString(sSpawnString, "|", sSpawnBuffer, 2, sizeof(sSpawnBuffer[]));
			
			Entity_GetRenderColor(iProp, iColor);
			
			Cel_GetEntityAngles(iProp, fAngles);
			
			Cel_GetEntityOrigin(iProp, fOrigin);
			
			Cel_SubFromPropCount(iClient);
			
			int iReplaceProp = Cel_SpawnProp(iClient, sAlias, sSpawnBuffer[0], sSpawnBuffer[1], fAngles, fOrigin, iColor[0], iColor[1], iColor[2], iColor[3]);
			
			Entity_SetSpawnFlags(iReplaceProp, Entity_GetSpawnFlags(iProp));
			Entity_SetSkin(iReplaceProp, Entity_GetSkin(iProp));
			Cel_SetMotion(iReplaceProp, Cel_GetMotion(iProp));
			Cel_SetSolid(iReplaceProp, Cel_IsSolid(iProp));
			
			Cel_SetRenderFX(iReplaceProp, Cel_GetRenderFX(iProp));
			
			Cel_SetColorFade(iReplaceProp, Cel_IsFading(iProp), g_iFadeColor[iProp][0], g_iFadeColor[iProp][1], g_iFadeColor[iProp][2], g_iFadeColor[iProp][3], g_iFadeColor[iProp][4], g_iFadeColor[iProp][5]);
			Cel_SetRainbow(iReplaceProp, Cel_IsRainbow(iProp));
			
			Cel_SetColorFade(iProp, false, g_iFadeColor[iProp][0], g_iFadeColor[iProp][1], g_iFadeColor[iProp][2], g_iFadeColor[iProp][3], g_iFadeColor[iProp][4], g_iFadeColor[iProp][5]);
			Cel_SetRainbow(iProp, false);
			
			AcceptEntityInput(iProp, "kill");
			
			Cel_ChangeBeam(iClient, iReplaceProp);
			
			Cel_ReplyToCommandEntity(iClient, iProp, "%t", "ReplacedModel", sAlias);
		} else {
			Cel_ReplyToCommand(iClient, "%t", "PropNotFound", sAlias);
			return Plugin_Handled;
		}
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_RenderFX(int iClient, int iArgs)
{
	char sRenderFX[PLATFORM_MAX_PATH];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_RenderFX");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sRenderFX, sizeof(sRenderFX));
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		RenderFx rfRenderFX = Cel_GetRenderFXFromName(sRenderFX);
		
		Cel_SetRenderFX(iProp, rfRenderFX);
		
		Cel_ChangeBeam(iClient, iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Rotate(int iClient, int iArgs)
{
	char sTemp[16];
	float fAddAngles[3], fAngles[3], fOrigin[3], fPropAngles[3];
	
	if (iArgs < 3)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Rotate");
		return Plugin_Handled;
	}
	
	for (int i = 0; i < 3; i++)
	{
		GetCmdArg(i+1, sTemp, sizeof(sTemp));
		
		fAddAngles[i] = StringToFloat(sTemp);
	}
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityOrigin(iProp, fOrigin);
		Cel_GetEntityAngles(iProp, fPropAngles);
		
		fAngles[0] = fPropAngles[0] += fAddAngles[0];
		fAngles[1] = fPropAngles[1] += fAddAngles[1];
		fAngles[2] = fPropAngles[2] += fAddAngles[2];
		
		TeleportEntity(iProp, NULL_VECTOR, fAngles, NULL_VECTOR);
		
		if (Cel_CheckEntityType(iProp, "door"))
		{
			DispatchSpawn(iProp);
		}
		
		TE_SetupBeamRingPoint(fOrigin, 0.0, 15.0, Cel_GetBeamMaterial(), Cel_GetHaloMaterial(), 0, 15, 0.5, 3.0, 0.0, g_iOrange, 10, 0); TE_SendToAll();
		
		PrecacheSound("buttons/lever7.wav");
		
		EmitSoundToAll("buttons/lever7.wav", iProp, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Skin(int iClient, int iArgs)
{
	char sSkin[16];
	int iMaxSkins, iSkin;
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Skin");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sSkin, sizeof(sSkin));
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		if(Cel_CheckEntityCatagory(iProp, ENTCATAGORY_BIT))
		{
			Cel_ReplyToCommand(iClient, "%t", "CantUseCommand-Entity");
			return Plugin_Handled;
		}
		
		//Inspired from InkMod (https://github.com/stakillion/InkMod) and BotinTV.
		iMaxSkins = (StudioHdr.FromEntity(iProp).numskinfamilies - 1);
		
		if(String_IsNumeric(sSkin))
		{
			iSkin = StringToInt(sSkin);
		}else if(StrEqual(sSkin, "prev", false))
		{
			if(Entity_GetSkin(iProp) <= 0)
			{
				iSkin = iMaxSkins;
			}else{
				iSkin = (Entity_GetSkin(iProp) - 1);
			}
		}else if(StrEqual(sSkin, "next", false))
		{
			if(Entity_GetSkin(iProp) >= iMaxSkins)
			{
				iSkin = 0;
			}else{
				iSkin = (Entity_GetSkin(iProp) + 1);
			}
		}else{
			Cel_ReplyToCommand(iClient, "%t", "CMD_Skin");
			return Plugin_Handled;
		}
		
		Entity_SetSkin(iProp, iSkin);
		
		Cel_ChangeBeam(iClient, iProp);
		
		Cel_ReplyToCommandEntity(iClient, iProp, "%t", "SetSkin", iSkin);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_SMove(int iClient, int iArgs)
{
	char sTemp[16];
	float fAddOrigin[3];
	
	if (iArgs < 3)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_SMove");
		return Plugin_Handled;
	}
	
	for (int i = 0; i < 3; i++)
	{
		GetCmdArg(i+1, sTemp, sizeof(sTemp));
		
		fAddOrigin[i] = StringToFloat(sTemp);
	}
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_ChangePositionRelativeToOrigin(iProp, fAddOrigin);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Solid(int iClient, int iArgs)
{
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		if(Cel_CheckEntityCatagory(iProp, ENTCATAGORY_BIT))
		{
			Cel_ReplyToCommand(iClient, "%t", "CantUseCommand-Entity");
			return Plugin_Handled;
		}
		
		if (Cel_CheckEntityType(iProp, "cycler"))
		{
			Cel_ReplyToCommand(iClient, "%t", "CantUseCommand-Prop");
			return Plugin_Handled;
		}
		
		Cel_SetSolid(iProp, !Cel_IsSolid(iProp));
		
		Cel_ReplyToCommandEntity(iClient, iProp, "%t", "SetSolidicity", Cel_IsSolid(iProp) ? "on" : "off");
		
		Cel_ChangeBeam(iClient, iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Stack(int iClient, int iArgs)
{
	char sArgs[3][32], sEntity[4][64];
	float fAngles[3], fFinalOrigin[3], fOrigin[3];
	int iColor[4];
	
	if (iArgs < 4)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Stack");
		return Plugin_Handled;
	}
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sArgs[0], sizeof(sArgs[]));
	GetCmdArg(2, sArgs[1], sizeof(sArgs[]));
	GetCmdArg(3, sArgs[2], sizeof(sArgs[]));
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		if(Cel_CheckEntityType(iProp, "physics") || Cel_CheckEntityType(iProp, "dynamic"))
		{
			Entity_GetClassName(iProp, sEntity[0], sizeof(sEntity[]));
			Entity_GetName(iProp, sEntity[1], sizeof(sEntity[]));
			Entity_GetModel(iProp, sEntity[2], sizeof(sEntity[]));
			
			Cel_GetPropName(iProp, sEntity[3], sizeof(sEntity[3]));
			
			Entity_GetRenderColor(iProp, iColor);
			
			Cel_GetEntityAngles(iProp, fAngles);
			
			Cel_GetEntityOrigin(iProp, fOrigin);
			
			for(int i = 0; i < StringToInt(sArgs[0]); i++)
			{
				if (!Cel_CheckPropCount(iClient))
				{
					Cel_ReplyToCommand(iClient, "%t", "MaxPropLimit", Cel_GetPropCount(iClient));
					return Plugin_Handled;
				}
				
				fFinalOrigin[0] = fOrigin[0] += StringToFloat(sArgs[0]);
				fFinalOrigin[1] = fOrigin[1] += StringToFloat(sArgs[1]);
				fFinalOrigin[2] = fOrigin[2] += StringToFloat(sArgs[2]);
				
				int iNewProp = Cel_SpawnProp(iClient, sEntity[3], "prop_physics_override", sEntity[2], fAngles, fFinalOrigin, iColor[0], iColor[1], iColor[2], iColor[3]);
				
				Entity_SetClassName(iNewProp, sEntity[0]);
				Entity_SetName(iNewProp, sEntity[1]);
				
				Entity_SetSpawnFlags(iNewProp, Entity_GetSpawnFlags(iProp));
				Entity_SetSkin(iNewProp, Entity_GetSkin(iProp));
				Cel_SetMotion(iNewProp, Cel_GetMotion(iProp));
				Cel_SetSolid(iNewProp, Cel_IsSolid(iProp));
				Cel_SetBreakable(iNewProp, Cel_IsBreakable(iProp));
				
				Cel_SetRenderFX(iNewProp, Cel_GetRenderFX(iProp));
				
				Cel_SetColorFade(iNewProp, Cel_IsFading(iProp), g_iFadeColor[iProp][0], g_iFadeColor[iProp][1], g_iFadeColor[iProp][2], g_iFadeColor[iProp][3], g_iFadeColor[iProp][4], g_iFadeColor[iProp][5]);
				Cel_SetRainbow(iNewProp, Cel_IsRainbow(iProp));
			}
			
			Cel_ReplyToCommandEntity(iClient, iProp, "%t", "StackedProps", 1);
		}else{
			Cel_ReplyToCommand(iClient, "%t", "CantUseCommand-Prop");
			return Plugin_Handled;
		}
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_StackInfo(int iClient, int iArgs)
{
	float fOrigin[3][3];
	int iEntity = Cel_GetClientAimTarget(iClient);
	
	switch(g_iStackInfoStatus[iClient])
	{
		case 0:
		{
			if(Cel_IsEntity(iEntity) && Cel_GetEntityCatagory(iEntity) == ENTCATAGORY_PROP)
			{
				g_iStackInfoEnt[iClient] = iEntity;
				
				g_iStackInfoStatus[iClient] = 1;
				
				Cel_ReplyToCommand(iClient, "%t", "StackInfo_First");
			}else{
				g_iStackInfoEnt[iClient] = -1;
				
				g_iStackInfoStatus[iClient] = 0;
				
				Cel_ReplyToCommand(iClient, "%t", "CantStack");
			}
		}
		
		case 1:
		{
			if(Cel_IsEntity(iEntity) && Cel_IsEntity(g_iStackInfoEnt[iClient]) && Cel_GetEntityCatagory(iEntity) == ENTCATAGORY_PROP)
			{
				if(g_iStackInfoEnt[iClient] == iEntity)
				{
					g_iStackInfoStatus[iClient] = 1;
					
					Cel_ReplyToCommand(iClient, "%t", "CantStackSame");
				}else{
					g_iStackInfoStatus[iClient] = 0;
					
					Cel_GetEntityOrigin(g_iStackInfoEnt[iClient], fOrigin[0]);
					Cel_GetEntityOrigin(iEntity, fOrigin[1]);
					
					g_iStackInfoEnt[iClient] = -1;
					
					fOrigin[2][0] = fOrigin[1][0] - fOrigin[0][0];
					fOrigin[2][1] = fOrigin[1][1] - fOrigin[0][1];
					fOrigin[2][2] = fOrigin[1][2] - fOrigin[0][2];
					
					Cel_ReplyToCommand(iClient, "%t", "StackInfo_Info", fOrigin[2][0], fOrigin[2][1], fOrigin[2][2]);
				}
			}else{
				g_iStackInfoEnt[iClient] = -1;
				
				g_iStackInfoStatus[iClient] = 0;
				
				Cel_ReplyToCommand(iClient, "%t", "CantStack");
			}
		}
	}
	
	return Plugin_Handled;
}

public Action Command_Stand(int iClient, int iArgs)
{
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		TeleportEntity(iProp, NULL_VECTOR, g_fZero, NULL_VECTOR);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_StartCopy(int iClient, int iArgs)
{
	float fAngles[3], fOrigin[2][3];
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if(g_iMoveCopyEntity[iClient] != -1)
	{
		Cel_ReplyToCommand(iClient, "%t", "AlreadyCopyingProp");
		return Plugin_Handled;
	}
	
	if (!Cel_CheckPropCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxPropLimit", Cel_GetPropCount(iClient));
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		if(!Cel_CheckEntityCatagory(iProp, ENTCATAGORY_PROP))
		{
			Cel_ReplyToCommand(iClient, "%t", "CantReplace");
		}
		
		Cel_GetEntityAngles(iProp, fAngles);
		Cel_GetEntityOrigin(iProp, fOrigin[0]);
		GetClientAbsOrigin(iClient, fOrigin[1]);
		
		g_fCopyOrigin[iClient][0] = fOrigin[0][0] - fOrigin[1][0];
		g_fCopyOrigin[iClient][1] = fOrigin[0][1] - fOrigin[1][1];
		g_fCopyOrigin[iClient][2] = fOrigin[0][2] - fOrigin[1][2];
		
		g_bCopyFading[iClient] = g_bIsFading[iProp];
		g_bCopyRainbow[iClient] = g_bRainbow[iProp];
		
		Cel_CopyProp(iClient, iProp);
		
		g_iMoveCopyEntity[iClient] = Cel_PasteProp(iClient, fAngles, fOrigin[0]);
		
		g_bIsFading[g_iMoveCopyEntity[iClient]] = false;
		g_bRainbow[g_iMoveCopyEntity[iClient]] = false;
		
		SetEntityRenderColor(g_iMoveCopyEntity[iClient], 32, 32, 255, 128);
		
		RequestFrame(Frame_CopyProp, iClient);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_StartGrab(int iClient, int iArgs)
{
	float fOrigin[2][3];
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	if(g_iMoveEntity[iClient] != -1)
	{
		Cel_ReplyToCommand(iClient, "%t", "AlreadyGrabbingProp");
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityOrigin(iProp, fOrigin[0]);
		GetClientAbsOrigin(iClient, fOrigin[1]);
		
		g_fCopyMoveOrigin[iClient][0] = fOrigin[0][0] - fOrigin[1][0];
		g_fCopyMoveOrigin[iClient][1] = fOrigin[0][1] - fOrigin[1][1];
		g_fCopyMoveOrigin[iClient][2] = fOrigin[0][2] - fOrigin[1][2];
		
		g_bCopyFading[iClient] = g_bIsFading[iProp];
		g_bCopyRainbow[iClient] = g_bRainbow[iProp];
		
		g_bIsFading[iProp] = false;
		g_bRainbow[iProp] = false;
		
		g_iMoveEntity[iClient] = iProp;
		
		SetEntityRenderColor(g_iMoveEntity[iClient], 32, 255, 32, 128);
		
		RequestFrame(Frame_MoveProp, iClient);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_StopCopy(int iClient, int iArgs)
{
	if(g_iMoveCopyEntity[iClient] == -1)
	{
		Cel_ReplyToCommand(iClient, "%t", "NotCopyingProp");
		return Plugin_Handled;
	}
	
	Cel_SetColor(g_iMoveCopyEntity[iClient], StringToInt(g_sCopyBuffer[iClient][8]), StringToInt(g_sCopyBuffer[iClient][9]), StringToInt(g_sCopyBuffer[iClient][10]), StringToInt(g_sCopyBuffer[iClient][11]));
	Cel_SetRenderFX(g_iMoveCopyEntity[iClient], view_as<RenderFx>(StringToInt(g_sCopyBuffer[iClient][17])));
	
	Cel_SetColorFade(g_iMoveCopyEntity[iClient], g_bCopyFading[iClient], StringToInt(g_sCopyBuffer[iClient][14]), StringToInt(g_sCopyBuffer[iClient][15]), StringToInt(g_sCopyBuffer[iClient][16]), StringToInt(g_sCopyBuffer[iClient][17]), StringToInt(g_sCopyBuffer[iClient][18]), StringToInt(g_sCopyBuffer[iClient][19]));
	Cel_SetRainbow(g_iMoveCopyEntity[iClient], g_bCopyRainbow[iClient]);
	
	g_iMoveCopyEntity[iClient] = -1;
	
	return Plugin_Handled;
}

public Action Command_StopGrab(int iClient, int iArgs)
{
	if(g_iMoveEntity[iClient] == -1)
	{
		Cel_ReplyToCommand(iClient, "%t", "NotGrabbingProp");
		return Plugin_Handled;
	}
	
	Cel_SetColor(g_iMoveEntity[iClient], g_iColor[g_iMoveEntity[iClient]][0], g_iColor[g_iMoveEntity[iClient]][1], g_iColor[g_iMoveEntity[iClient]][2], g_iColor[g_iMoveEntity[iClient]][3]);
	Cel_SetRenderFX(g_iMoveEntity[iClient], g_rfRenderFX[g_iMoveEntity[iClient]]);
	
	Cel_SetColorFade(g_iMoveEntity[iClient], g_bCopyFading[iClient], g_iFadeColor[g_iMoveEntity[iClient]][0], g_iFadeColor[g_iMoveEntity[iClient]][1], g_iFadeColor[g_iMoveEntity[iClient]][2], g_iFadeColor[g_iMoveEntity[iClient]][3], g_iFadeColor[g_iMoveEntity[iClient]][4], g_iFadeColor[g_iMoveEntity[iClient]][5]);
	Cel_SetRainbow(g_iMoveEntity[iClient], g_bCopyRainbow[iClient]);
	
	g_iMoveEntity[iClient] = -1;
	
	return Plugin_Handled;
}

public Action Command_UnfreezeIt(int iClient, int iArgs)
{
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		if(Cel_CheckEntityCatagory(iProp, ENTCATAGORY_BIT))
		{
			Cel_ReplyToCommand(iClient, "%t", "CantUseCommand-Entity");
			return Plugin_Handled;
		}
		
		Cel_ReplyToCommandEntity(iClient, iProp, "%t", "EnableMotion");
		
		Cel_SetMotion(iProp, true);
		
		Cel_ChangeBeam(iClient, iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Unlock(int iClient, int iArgs)
{
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		if(Cel_CheckEntityType(iProp, "cycler") || Cel_CheckEntityType(iProp, "dynamic") || Cel_CheckEntityType(iProp, "ladder") || 
			Cel_CheckEntityType(iProp, "physics") || Cel_CheckEntityType(iProp, "cleer") || Cel_CheckEntityType(iProp, "bit") || Cel_CheckEntityType(iProp, "unknown"))
		{
			Cel_ReplyToCommandEntity(iClient, iProp, "%t", "CannotUnlock");
			return Plugin_Handled;
		}
		
		Cel_LockEntity(iProp, false);
		
		Cel_ReplyToCommandEntity(iClient, iProp, "%t", "Unlocked");
		
		Cel_ChangeBeam(iClient, iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

//Frames:
public void Frame_CopyProp(any iClient)
{
	float fOrigin[2][3];
	
	if(g_iMoveCopyEntity[iClient] != -1 && Cel_IsEntity(g_iMoveCopyEntity[iClient]) && IsValidEntity(g_iMoveCopyEntity[iClient]))
	{
		GetClientAbsOrigin(iClient, fOrigin[0]);
		
		fOrigin[1][0] = fOrigin[0][0] + g_fCopyOrigin[iClient][0];
		fOrigin[1][1] = fOrigin[0][1] + g_fCopyOrigin[iClient][1];
		fOrigin[1][2] = fOrigin[0][2] + g_fCopyOrigin[iClient][2];
		
		TeleportEntity(g_iMoveCopyEntity[iClient], fOrigin[1], NULL_VECTOR, NULL_VECTOR);
		
		RequestFrame(Frame_CopyProp, iClient);
	}
}

public void Frame_FadeColor(any iProp)
{
	int iColor[3];
	
	if (Cel_IsEntity(iProp) && IsValidEntity(iProp) && g_bIsFading[iProp])
	{
		float fAge  = GetGameTime() - g_fFadeTime[iProp];
		float fColorFade = ((fAge % PERIOD) <= (PERIOD * 0.5)) ? ((fAge % PERIOD) / (PERIOD * 0.5)) : (1.0 - ((fAge % PERIOD) - (PERIOD * 0.5)) / (PERIOD * 0.5));
		
		iColor[0] = RoundToFloor((1.0 - fColorFade) * g_iFadeColor[iProp][0] + fColorFade * g_iFadeColor[iProp][3]);
		iColor[1] = RoundToFloor((1.0 - fColorFade) * g_iFadeColor[iProp][1] + fColorFade * g_iFadeColor[iProp][4]);
		iColor[2] = RoundToFloor((1.0 - fColorFade) * g_iFadeColor[iProp][2] + fColorFade * g_iFadeColor[iProp][5]);
		
		Cel_SetColor(iProp, iColor[0], iColor[1], iColor[2], g_iColor[iProp][3]);
		
		if(Cel_GetEntityType(iProp) == ENTTYPE_EFFECT)
		{
			Cel_SetColor(Cel_GetEffectAttachment(iProp), iColor[0], iColor[1], iColor[2], g_iColor[iProp][3]);
		}
		
		if(Cel_GetEntityType(iProp) == ENTTYPE_LIGHT)
		{
			Cel_SetColor(Entity_GetEntityAttachment(iProp), iColor[0], iColor[1], iColor[2], g_iColor[iProp][3]);
		}
		
		RequestFrame(Frame_FadeColor, iProp);
	}	
}

public void Frame_MoveProp(any iClient)
{
	float fOrigin[2][3];
	
	if(g_iMoveEntity[iClient] != -1 && Cel_IsEntity(g_iMoveEntity[iClient]) && IsValidEntity(g_iMoveEntity[iClient]))
	{
		GetClientAbsOrigin(iClient, fOrigin[0]);
		
		fOrigin[1][0] = fOrigin[0][0] + g_fCopyMoveOrigin[iClient][0];
		fOrigin[1][1] = fOrigin[0][1] + g_fCopyMoveOrigin[iClient][1];
		fOrigin[1][2] = fOrigin[0][2] + g_fCopyMoveOrigin[iClient][2];
		
		TeleportEntity(g_iMoveEntity[iClient], fOrigin[1], NULL_VECTOR, NULL_VECTOR);
		
		RequestFrame(Frame_MoveProp, iClient);
	}
}

public void Frame_Rainbow(any iProp)
{
	int iColor[3];
	
	if (Cel_IsEntity(iProp) && IsValidEntity(iProp) && g_bRainbow[iProp])
	{
		/*float fTime = (GetGameTime() - g_fRainbowTime[iProp]) * ((2.0 * M_PI) / PERIOD);

		iColor[0] = RoundToFloor((Cosine(fTime) + 1.0) * 127.5);
		iColor[1] = RoundToFloor((Cosine(fTime - (2.0 * M_PI / 3.0)) + 1.0) * 127.5);
		iColor[2] = RoundToFloor((Cosine(fTime - 2*(2.0 * M_PI / 3.0)) + 1.0) * 127.5);

		Cel_SetColor(iProp, iColor[0], iColor[1], iColor[2], g_iColor[iProp][3]);

		if(Cel_GetEntityType(iProp) == ENTTYPE_EFFECT)
		{
			Cel_SetColor(Cel_GetEffectAttachment(iProp), iColor[0], iColor[1], iColor[2], g_iColor[iProp][3]);
		}*/
		
		float fHue = (GetGameTime() - g_fRainbowTime[iProp]) * (360.0 / PERIOD);
		
		HSVtoRGB(fHue, 1.0, 1.0, iColor);
		
		Cel_SetColor(iProp, iColor[0], iColor[1], iColor[2], g_iColor[iProp][3]);
		
		if(Cel_GetEntityType(iProp) == ENTTYPE_EFFECT)
		{
			Cel_SetColor(Cel_GetEffectAttachment(iProp), iColor[0], iColor[1], iColor[2], g_iColor[iProp][3]);
		}
		
		if(Cel_GetEntityType(iProp) == ENTTYPE_LIGHT)
		{
			Cel_SetColor(Entity_GetEntityAttachment(iProp), iColor[0], iColor[1], iColor[2], g_iColor[iProp][3]);
		}
		
		RequestFrame(Frame_Rainbow, iProp);
	}
}

//Natives:
public int Native_ChangePositionRelativeToOrigin(Handle hPlugin, int iNumParams)
{
	float fAddOrigin[3], fFinalOrigin[3], fOrigin[3];
	
	int iEntity = GetNativeCell(1);
	
	GetNativeArray(2, fAddOrigin, 3);
	
	Cel_GetEntityOrigin(iEntity, fOrigin);
	
	fFinalOrigin[0] = fOrigin[0] += fAddOrigin[0];
	fFinalOrigin[1] = fOrigin[1] += fAddOrigin[1];
	fFinalOrigin[2] = fOrigin[2] += fAddOrigin[2];
	
	TeleportEntity(iEntity, fFinalOrigin, NULL_VECTOR, NULL_VECTOR);
	
	return true;
}

public int Native_CheckColorDB(Handle hPlugin, int iNumParams)
{
	int iMaxLength = GetNativeCell(3);
	
	char sColor[64], sColorLine[32];
	
	GetNativeString(1, sColor, sizeof(sColor));
	
	KeyValues kvColors = new KeyValues("Colors");
	
	kvColors.ImportFromFile(g_sColorDB);
	
	kvColors.JumpToKey("RGB", false);
	
	kvColors.GetString(sColor, sColorLine, iMaxLength, "null");
	
	kvColors.Rewind();
	
	delete kvColors;
	
	SetNativeString(2, sColorLine, iMaxLength);
	
	return (StrEqual(sColorLine, "null")) ? false : true;
}

public int Native_CheckEntityCatagory(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return (Cel_GetEntityCatagory(iEntity) == view_as<EntityCatagory>(GetNativeCell(2))) ? true : false;
}

public int Native_CheckEntityType(Handle hPlugin, int iNumParams)
{
	char sPropCheck[PLATFORM_MAX_PATH];
	
	int iEntity = GetNativeCell(1);
	
	GetNativeString(2, sPropCheck, sizeof(sPropCheck));
	
	return (Cel_GetEntityType(iEntity) == Cel_GetEntityTypeFromName(sPropCheck)) ? true : false;
}

public int Native_CheckOwner(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iEntity = GetNativeCell(2);
	
	return (Cel_GetOwner(iEntity) == iClient && Cel_IsEntity(iEntity)) ? true : false;
}

public int Native_CheckRenderFX(Handle hPlugin, int iNumParams)
{
	char sCheck[PLATFORM_MAX_PATH], sType[PLATFORM_MAX_PATH];
	int iEntity = GetNativeCell(1);
	
	GetNativeString(2, sCheck, sizeof(sCheck));
	
	Cel_GetRenderFXName(Cel_GetRenderFX(iEntity), sType, sizeof(sType));
	
	return (StrContains(sType, sCheck, false) != -1);
}

public int Native_CopyProp(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iEntity = GetNativeCell(2);
	
	int iEntityColor[4];
	
	Entity_GetClassName(iEntity, g_sCopyBuffer[iClient][0], sizeof(g_sCopyBuffer[iClient][]));
	Entity_GetName(iEntity, g_sCopyBuffer[iClient][1], sizeof(g_sCopyBuffer[iClient][]));
	Entity_GetModel(iEntity, g_sCopyBuffer[iClient][2], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(Entity_GetSpawnFlags(iEntity), g_sCopyBuffer[iClient][3], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(Entity_GetSkin(iEntity), g_sCopyBuffer[iClient][4], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(view_as<int>(Cel_GetMotion(iEntity)), g_sCopyBuffer[iClient][5], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(view_as<int>(Cel_IsSolid(iEntity)), g_sCopyBuffer[iClient][6], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(view_as<int>(Cel_IsBreakable(iEntity)), g_sCopyBuffer[iClient][21], sizeof(g_sCopyBuffer[iClient][]));
	
	IntToString(view_as<int>(Cel_GetRenderFX(iEntity)), g_sCopyBuffer[iClient][7], sizeof(g_sCopyBuffer[iClient][]));
	
	Entity_GetRenderColor(iEntity, iEntityColor);
	IntToString(iEntityColor[0], g_sCopyBuffer[iClient][8], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(iEntityColor[1], g_sCopyBuffer[iClient][9], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(iEntityColor[2], g_sCopyBuffer[iClient][10], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(iEntityColor[3], g_sCopyBuffer[iClient][11], sizeof(g_sCopyBuffer[iClient][]));
	
	IntToString(view_as<int>(Cel_IsFading(iEntity)), g_sCopyBuffer[iClient][12], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(view_as<int>(Cel_IsRainbow(iEntity)), g_sCopyBuffer[iClient][13], sizeof(g_sCopyBuffer[iClient][]));
	
	IntToString(g_iFadeColor[iEntity][0], g_sCopyBuffer[iClient][14], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(g_iFadeColor[iEntity][1], g_sCopyBuffer[iClient][15], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(g_iFadeColor[iEntity][2], g_sCopyBuffer[iClient][16], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(g_iFadeColor[iEntity][3], g_sCopyBuffer[iClient][17], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(g_iFadeColor[iEntity][4], g_sCopyBuffer[iClient][18], sizeof(g_sCopyBuffer[iClient][]));
	IntToString(g_iFadeColor[iEntity][5], g_sCopyBuffer[iClient][19], sizeof(g_sCopyBuffer[iClient][]));
	
	Cel_GetPropName(iEntity, g_sCopyBuffer[iClient][20], sizeof(g_sCopyBuffer[iClient][]));
	
	return true;
}

public int Native_DissolveEntity(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	DispatchKeyValue(iEntity, "classname", "deleted");
	
	AcceptEntityInput(g_iEntityDissolve, "dissolve");
	
	return true;
}

public int Native_DropEntityToFloor(Handle hPlugin, int iNumParams)
{
	float fBounds[3], fDropOrigin[3], fEntityOrigin[3];
	int iEntity = GetNativeCell(1);
	
	Cel_GetEntityOrigin(iEntity, fEntityOrigin);
	Entity_GetMinSize(iEntity, fBounds);
	
	Handle hTraceRay = TR_TraceRayFilterEx(fEntityOrigin, g_fDown, (MASK_SHOT_HULL|MASK_SHOT), RayType_Infinite, Cel_FilterPlayer, iEntity);
	
	if (TR_DidHit(hTraceRay))
	{
		TR_GetEndPosition(fDropOrigin, hTraceRay);
		
		CloseHandle(hTraceRay);
	}
	
	fEntityOrigin[2] = fDropOrigin[2] - fBounds[2];
	
	TeleportEntity(iEntity, fEntityOrigin, NULL_VECTOR, NULL_VECTOR);
	
	return true;
}

public int Native_GetColor(Handle hPlugin, int iNumParams)
{
	int iColor[4];
	int iEntity = GetNativeCell(1);
	
	if (g_iColor[iEntity][0] == 0 && g_iColor[iEntity][1] == 0 && g_iColor[iEntity][2] == 0 && g_iColor[iEntity][3] == 0)
	{
		GetEntityRenderColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
		Cel_SetColor(iEntity, iColor[0], iColor[1], iColor[2], iColor[3]);
	}
	
	iColor = g_iColor[iEntity];
	
	SetNativeArray(2, iColor, 4);
	
	return true;
}

public int Native_GetEntityCatagory(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	EntityType etEntityType = Cel_GetEntityType(iEntity);
	
	if (etEntityType == ENTTYPE_AMMO || etEntityType == ENTTYPE_AMMOCRATE || etEntityType == ENTTYPE_BIT || etEntityType == ENTTYPE_CHARGER || etEntityType == ENTTYPE_TRIGGER || etEntityType == ENTTYPE_WEAPONSPWNER)
	{
		return view_as<int>(ENTCATAGORY_BIT);
	}else if (etEntityType == ENTTYPE_DOOR || etEntityType == ENTTYPE_EFFECT || etEntityType == ENTTYPE_INTERNET || etEntityType == ENTTYPE_LADDER || etEntityType == ENTTYPE_LIGHT)
	{
		return view_as<int>(ENTCATAGORY_CEL);
	} else if (etEntityType == ENTTYPE_CYCLER || etEntityType == ENTTYPE_DYNAMIC || etEntityType == ENTTYPE_PHYSICS || etEntityType == ENTTYPE_CLEER)
	{
		return view_as<int>(ENTCATAGORY_PROP);
	} else {
		return view_as<int>(ENTCATAGORY_UNKNOWN);
	}
}

public int Native_GetEntityCatagoryName(Handle hPlugin, int iNumParams)
{
	char sEntityCatagory[PLATFORM_MAX_PATH];
	int iMaxLength = GetNativeCell(3);
	
	switch (view_as<EntityCatagory>(GetNativeCell(1)))
	{
		case ENTCATAGORY_BIT:
		{
			Format(sEntityCatagory, sizeof(sEntityCatagory), "bit entity");
		}
		case ENTCATAGORY_CEL:
		{
			Format(sEntityCatagory, sizeof(sEntityCatagory), "cel entity");
		}
		case ENTCATAGORY_PROP:
		{
			Format(sEntityCatagory, sizeof(sEntityCatagory), "prop entity");
		}
		case ENTCATAGORY_UNKNOWN:
		{
			Format(sEntityCatagory, sizeof(sEntityCatagory), "unknown entity");
		}
	}
	
	SetNativeString(2, sEntityCatagory, iMaxLength);
	
	return true;
}

public int Native_GetEntityType(Handle hPlugin, int iNumParams)
{
	char sClassname[64];
	
	int iEntity = GetNativeCell(1);
	
	GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
	
	if (StrEqual(sClassname, "cel_doll", false))
	{
		return view_as<int>(ENTTYPE_CYCLER);
	} else if (StrEqual(sClassname, "cel_door", false))
	{
		return view_as<int>(ENTTYPE_DOOR);
	} else if (StrEqual(sClassname, "cel_internet", false))
	{
		return view_as<int>(ENTTYPE_INTERNET);
	} else if (StrEqual(sClassname, "cel_ladder", false))
	{
		return view_as<int>(ENTTYPE_LADDER);
	} else if (StrEqual(sClassname, "cel_light", false))
	{
		return view_as<int>(ENTTYPE_LIGHT);
	} else if (StrContains(sClassname, "effect_", false) != -1)
	{
		return view_as<int>(ENTTYPE_EFFECT);
	} else if (StrEqual(sClassname, "cel_cleerbox", false))
	{
		return view_as<int>(ENTTYPE_CLEER);
	} else if (StrEqual(sClassname, "cel_dynamic", false))
	{
		return view_as<int>(ENTTYPE_DYNAMIC);
	} else if (StrEqual(sClassname, "cel_physics", false))
	{
		return view_as<int>(ENTTYPE_PHYSICS);
	} else if (StrContains(sClassname, "bit_ammo_", false) != -1)
	{
		return view_as<int>(ENTTYPE_AMMO);
	} else if (StrEqual(sClassname, "bit_ammocrate", false))
	{
		return view_as<int>(ENTTYPE_AMMOCRATE);
	} else if (StrContains(sClassname, "bit_charger_", false) != -1)
	{
		return view_as<int>(ENTTYPE_CHARGER);
	} else if (StrContains(sClassname, "bit_wep_", false) != -1)
	{
		return view_as<int>(ENTTYPE_WEAPONSPWNER);
	} else if (StrContains(sClassname, "bit_trigger_", false) != -1)
	{
		return view_as<int>(ENTTYPE_TRIGGER);
	} else {
		return view_as<int>(ENTTYPE_UNKNOWN);
	}
}

public int Native_GetEntityTypeFromName(Handle hPlugin, int iNumParams)
{
	char sEntityType[PLATFORM_MAX_PATH];
	
	GetNativeString(1, sEntityType, sizeof(sEntityType));
	
	if (StrEqual(sEntityType, "cleer", false))
	{
		return view_as<int>(ENTTYPE_CLEER);
	} else if (StrEqual(sEntityType, "cycler", false))
	{
		return view_as<int>(ENTTYPE_CYCLER);
	} else if (StrEqual(sEntityType, "door", false))
	{
		return view_as<int>(ENTTYPE_DOOR);
	} else if (StrEqual(sEntityType, "dynamic", false))
	{
		return view_as<int>(ENTTYPE_DYNAMIC);
	} else if (StrEqual(sEntityType, "effect", false))
	{
		return view_as<int>(ENTTYPE_EFFECT);
	} else if (StrEqual(sEntityType, "internet", false))
	{
		return view_as<int>(ENTTYPE_INTERNET);
	} else if (StrEqual(sEntityType, "ladder", false))
	{
		return view_as<int>(ENTTYPE_LADDER);
	} else if (StrEqual(sEntityType, "light", false))
	{
		return view_as<int>(ENTTYPE_LIGHT);
	} else if (StrEqual(sEntityType, "physics", false))
	{
		return view_as<int>(ENTTYPE_PHYSICS);
	} else if (StrEqual(sEntityType, "bit", false))
	{
		return view_as<int>(ENTTYPE_BIT);
	} else if (StrEqual(sEntityType, "ammo", false))
	{
		return view_as<int>(ENTTYPE_AMMO);
	} else if (StrEqual(sEntityType, "ammocrate", false))
	{
		return view_as<int>(ENTTYPE_AMMOCRATE);
	} else if (StrEqual(sEntityType, "charger", false))
	{
		return view_as<int>(ENTTYPE_CHARGER);
	} else if (StrEqual(sEntityType, "weaponspwner", false))
	{
		return view_as<int>(ENTTYPE_WEAPONSPWNER);
	} else if (StrEqual(sEntityType, "trigger", false))
	{
		return view_as<int>(ENTTYPE_TRIGGER);
	} else {
		return view_as<int>(ENTTYPE_UNKNOWN);
	}
}

public int Native_GetEntityTypeName(Handle hPlugin, int iNumParams)
{
	char sEntityType[PLATFORM_MAX_PATH];
	int iMaxLength = GetNativeCell(3);
	
	switch (view_as<EntityType>(GetNativeCell(1)))
	{
		case ENTTYPE_CYCLER:
		{
			Format(sEntityType, sizeof(sEntityType), "cycler prop");
		}
		case ENTTYPE_CLEER:
		{
			Format(sEntityType, sizeof(sEntityType), "cleer deposit box");
		}
		case ENTTYPE_DOOR:
		{
			Format(sEntityType, sizeof(sEntityType), "door cel");
		}
		case ENTTYPE_DYNAMIC:
		{
			Format(sEntityType, sizeof(sEntityType), "dynamic prop");
		}
		case ENTTYPE_EFFECT:
		{
			Format(sEntityType, sizeof(sEntityType), "effect cel");
		}
		case ENTTYPE_INTERNET:
		{
			Format(sEntityType, sizeof(sEntityType), "internet cel");
		}
		case ENTTYPE_LADDER:
		{
			Format(sEntityType, sizeof(sEntityType), "ladder cel");
		}
		case ENTTYPE_LIGHT:
		{
			Format(sEntityType, sizeof(sEntityType), "light cel");
		}
		case ENTTYPE_PHYSICS:
		{
			Format(sEntityType, sizeof(sEntityType), "physics prop");
		}
		case ENTTYPE_BIT:
		{
			Format(sEntityType, sizeof(sEntityType), "bit cel");
		}
		case ENTTYPE_AMMO:
		{
			Format(sEntityType, sizeof(sEntityType), "ammo bit cel");
		}
		case ENTTYPE_AMMOCRATE:
		{
			Format(sEntityType, sizeof(sEntityType), "ammo crate bit cel");
		}
		case ENTTYPE_CHARGER:
		{
			Format(sEntityType, sizeof(sEntityType), "charger bit cel");
		}
		case ENTTYPE_WEAPONSPWNER:
		{
			Format(sEntityType, sizeof(sEntityType), "weapon bit cel");
		}
		case ENTTYPE_TRIGGER:
		{
			Format(sEntityType, sizeof(sEntityType), "trigger bit cel");
		}
		case ENTTYPE_UNKNOWN:
		{
			Format(sEntityType, sizeof(sEntityType), "unknown prop type");
		}
	}
	
	SetNativeString(2, sEntityType, iMaxLength);
	
	return true;
}

public int Native_GetFadeColor(Handle hPlugin, int iNumParams)
{
	int iColor[2][3];
	int iEntity = GetNativeCell(1);
	
	iColor[0][0] = g_iFadeColor[iEntity][0];
	iColor[0][1] = g_iFadeColor[iEntity][1];
	iColor[0][2] = g_iFadeColor[iEntity][2];
	
	iColor[1][0] = g_iFadeColor[iEntity][3];
	iColor[1][1] = g_iFadeColor[iEntity][4];
	iColor[1][2] = g_iFadeColor[iEntity][5];
	
	SetNativeArray(2, iColor[0], 3);
	SetNativeArray(3, iColor[1], 3);
	
	return true;
}

public int Native_GetMotion(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return g_bMotion[iEntity];
}

public int Native_GetOwner(Handle hPlugin, int iNumParams)
{
	char sOwnerString[128];
	int iEntity = GetNativeCell(1);
	
	if(Cel_IsEntity(iEntity))
	{
		Entity_GetGlobalName(iEntity, sOwnerString, sizeof(sOwnerString));
		
		ReplaceString(sOwnerString, sizeof(sOwnerString), "CelMod:", "");
		
		return GetClientFromSerial(StringToInt(sOwnerString));
	}
	
	return -1;
}

public int Native_GetRenderFX(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return view_as<int>(g_rfRenderFX[iEntity]);
}

public int Native_GetRenderFXFromName(Handle hPlugin, int iNumParams)
{
	char sRenderFXName[PLATFORM_MAX_PATH];
	
	GetNativeString(1, sRenderFXName, sizeof(sRenderFXName));
	
	if (StrContains("default", sRenderFXName, false) != -1)
	{
		return view_as<int>(RENDERFX_NONE);
	} else if (StrContains("pulse", sRenderFXName, false) != -1)
	{
		return view_as<int>(RENDERFX_PULSE_FAST);
	} else if (StrContains("fade", sRenderFXName, false) != -1)
	{
		return view_as<int>(RENDERFX_FADE_FAST);
	} else if (StrContains("strobe", sRenderFXName, false) != -1)
	{
		return view_as<int>(RENDERFX_STROBE_FAST);
	} else if (StrContains("flicker", sRenderFXName, false) != -1)
	{
		return view_as<int>(RENDERFX_FLICKER_FAST);
	} else if (StrContains("distort", sRenderFXName, false) != -1)
	{
		return view_as<int>(RENDERFX_DISTORT);
	} else if (StrContains("hologram", sRenderFXName, false) != -1)
	{
		return view_as<int>(RENDERFX_HOLOGRAM);
	} else {
		return view_as<int>(RENDERFX_NONE);
	}
}

public int Native_GetRenderFXName(Handle hPlugin, int iNumParams)
{
	char sRenderFXName[PLATFORM_MAX_PATH];
	RenderFx rfRenderFX = view_as<RenderFx>(GetNativeCell(1));
	int iMaxLength = GetNativeCell(3);
	
	switch (rfRenderFX)
	{
		case RENDERFX_NONE:
		{
			Format(sRenderFXName, sizeof(sRenderFXName), "default");
		}
		case RENDERFX_PULSE_FAST:
		{
			Format(sRenderFXName, sizeof(sRenderFXName), "pulse");
		}
		case RENDERFX_FADE_FAST:
		{
			Format(sRenderFXName, sizeof(sRenderFXName), "fade");
		}
		case RENDERFX_STROBE_FAST:
		{
			Format(sRenderFXName, sizeof(sRenderFXName), "strobe");
		}
		case RENDERFX_FLICKER_FAST:
		{
			Format(sRenderFXName, sizeof(sRenderFXName), "flicker");
		}
		case RENDERFX_DISTORT:
		{
			Format(sRenderFXName, sizeof(sRenderFXName), "distort");
		}
		case RENDERFX_HOLOGRAM:
		{
			Format(sRenderFXName, sizeof(sRenderFXName), "hologram");
		}
	}
	
	SetNativeString(2, sRenderFXName, iMaxLength);
	
	return true;
}

public int Native_GetPropName(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	int iMaxLength = GetNativeCell(3);
	
	SetNativeString(2, g_sPropName[iEntity], iMaxLength);
	
	return true;
}

public int Native_IsBreakable(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return g_bBreakable[iEntity];
}

public int Native_IsEntity(Handle hPlugin, int iNumParams)
{
	char sOwnerString[128];
	int iEntity = GetNativeCell(1);
	
	if(IsValidEntity(iEntity) && iEntity != -1)
	{
		Entity_GetGlobalName(iEntity, sOwnerString, sizeof(sOwnerString));
		
		if(StrContains(sOwnerString, "CelMod:", true) != -1)
		{
			return true;
		}
	}
	
	return false;
}

public int Native_IsFading(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return g_bIsFading[iEntity];
}

public int Native_IsLocked(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	if(g_bLocked[iEntity])
	{
		PrecacheSound("buttons/combine_button_locked.wav");
		
		EmitSoundToAll("buttons/combine_button_locked.wav", iEntity, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	}
	
	return g_bLocked[iEntity];
}

public int Native_IsRainbow(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return g_bRainbow[iEntity];
}

public int Native_IsSolid(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return g_bSolid[iEntity];
}

public int Native_LockEntity(Handle hPlugin, int iNumParams)
{
	bool bLock = view_as<bool>(GetNativeCell(2));
	int iEntity = GetNativeCell(1);
	
	switch(Cel_GetEntityType(iEntity))
	{
		case ENTTYPE_DOOR:
		{
			AcceptEntityInput(iEntity, bLock ? "lock" : "unlock");
		}
	}
	
	g_bLocked[iEntity] = bLock;
	
	return g_bLocked[iEntity];
}

public int Native_PasteProp(Handle hPlugin, int iNumParams)
{
	float fAngles[3], fOrigin[3];
	
	int iClient = GetNativeCell(1);
	
	GetNativeArray(2, fAngles, 3);
	GetNativeArray(3, fOrigin, 3);
	
	int iEntity = Cel_SpawnProp(iClient, g_sCopyBuffer[iClient][20], "prop_physics_override", g_sCopyBuffer[iClient][2], fAngles, fOrigin, StringToInt(g_sCopyBuffer[iClient][8]), StringToInt(g_sCopyBuffer[iClient][9]), StringToInt(g_sCopyBuffer[iClient][10]), StringToInt(g_sCopyBuffer[iClient][11]));
	
	Entity_SetClassName(iEntity, g_sCopyBuffer[iClient][0]);
	Entity_SetName(iEntity, g_sCopyBuffer[iClient][1]);
	Entity_SetSpawnFlags(iEntity, StringToInt(g_sCopyBuffer[iClient][3]));
	Entity_SetSkin(iEntity, StringToInt(g_sCopyBuffer[iClient][4]));
	Cel_SetMotion(iEntity, view_as<bool>(StringToInt(g_sCopyBuffer[iClient][5])));
	Cel_SetSolid(iEntity, view_as<bool>(StringToInt(g_sCopyBuffer[iClient][6])));
	Cel_SetBreakable(iEntity, view_as<bool>(StringToInt(g_sCopyBuffer[iClient][21])));
	
	Cel_SetColorFade(iEntity, view_as<bool>(StringToInt(g_sCopyBuffer[iClient][12])), StringToInt(g_sCopyBuffer[iClient][14]), StringToInt(g_sCopyBuffer[iClient][15]), StringToInt(g_sCopyBuffer[iClient][16]), StringToInt(g_sCopyBuffer[iClient][17]), StringToInt(g_sCopyBuffer[iClient][18]), StringToInt(g_sCopyBuffer[iClient][19]));
	Cel_SetRainbow(iEntity, view_as<bool>(StringToInt(g_sCopyBuffer[iClient][13])));
	
	return iEntity;
}

public int Native_SetBreakable(Handle hPlugin, int iNumParams)
{
	bool bBreakable = view_as<bool>(GetNativeCell(2));
	int iEntity = GetNativeCell(1);
	
	bBreakable ? SetEntProp(iEntity, Prop_Data, "m_takedamage", 2, 1) : SetEntProp(iEntity, Prop_Data, "m_takedamage", 0, 1);
	
	g_bBreakable[iEntity] = bBreakable;
	
	return g_bBreakable[iEntity];
}

public int Native_SetColor(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	int iR = GetNativeCell(2), iG = GetNativeCell(3), iB = GetNativeCell(4), iA = GetNativeCell(5);
	
	SetEntityRenderColor(iEntity, iR == -1 ? g_iColor[iEntity][0] : iR, iG == -1 ? g_iColor[iEntity][1] : iG, iB == -1 ? g_iColor[iEntity][2] : iB, iA == -1 ? g_iColor[iEntity][3] : iA);
	SetEntityRenderMode(iEntity, RENDER_TRANSALPHAADD);
	
	g_iColor[iEntity][0] = iR == -1 ? g_iColor[iEntity][0] : iR, g_iColor[iEntity][1] = iG == -1 ? g_iColor[iEntity][1] : iG, g_iColor[iEntity][2] = iB == -1 ? g_iColor[iEntity][2] : iB, g_iColor[iEntity][3] = iA == -1 ? g_iColor[iEntity][3] : iA;
	
	return true;
}

public int Native_SetColorFade(Handle hPlugin, int iNumParams)
{
	bool bFade = view_as<bool>(GetNativeCell(2));
	int iEntity = GetNativeCell(1);
	
	g_bIsFading[iEntity] = bFade;
	
	if(g_bIsFading[iEntity])
	{
		g_iFadeColor[iEntity][0] = GetNativeCell(3);
		g_iFadeColor[iEntity][1] = GetNativeCell(4);
		g_iFadeColor[iEntity][2] = GetNativeCell(5);
		g_iFadeColor[iEntity][3] = GetNativeCell(6);
		g_iFadeColor[iEntity][4] = GetNativeCell(7);
		g_iFadeColor[iEntity][5] = GetNativeCell(8);
		
		g_fFadeTime[iEntity] = GetGameTime();
		
		g_bRainbow[iEntity] = false;
		
		RequestFrame(Frame_FadeColor, iEntity);
	}else{
		g_iFadeColor[iEntity][0] = 0;
		g_iFadeColor[iEntity][1] = 0;
		g_iFadeColor[iEntity][2] = 0;
		g_iFadeColor[iEntity][3] = 0;
		g_iFadeColor[iEntity][4] = 0;
		g_iFadeColor[iEntity][5] = 0;
		
		g_fFadeTime[iEntity] = 0.0;
	}
	
	return true;
}

public int Native_SetEntity(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	bool bEntity = view_as<bool>(GetNativeCell(2));
	
	if(IsValidEntity(iEntity) && iEntity != -1)
	{
		if(bEntity)
		{
			Entity_SetGlobalName(iEntity, "CelMod:-1");
		}else{
			Entity_SetGlobalName(iEntity, "");
		}
	}
	
	return true;
}

public int Native_SetMotion(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	bool bMotion = view_as<bool>(GetNativeCell(2));
	
	bMotion ? AcceptEntityInput(iEntity, "enablemotion") : AcceptEntityInput(iEntity, "disablemotion");
	
	g_bMotion[iEntity] = bMotion;
	
	return true;
}

public int Native_SetOwner(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iEntity = GetNativeCell(2);
	
	Entity_SetGlobalName(iEntity, "CelMod:%i", GetClientSerial(iClient));
	
	return true;
}

public int Native_SetPropName(Handle hPlugin, int iNumParams)
{
	char sPropName[64];
	
	int iEntity = GetNativeCell(1);
	
	GetNativeString(2, sPropName, sizeof(sPropName));
	
	Format(g_sPropName[iEntity], sizeof(g_sPropName), sPropName);
	
	return true;
}

public int Native_SetRainbow(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	bool bRainbow = view_as<bool>(GetNativeCell(2));
	
	g_bRainbow[iEntity] = bRainbow;
	
	if(g_bRainbow[iEntity])
	{
		g_fRainbowTime[iEntity] = GetGameTime();
		
		g_bIsFading[iEntity] = false;
		
		RequestFrame(Frame_Rainbow, iEntity);
	}
	
	return true;
}

public int Native_SetRenderFX(Handle hPlugin, int iNumParams)
{
	RenderFx rfType = view_as<RenderFx>(GetNativeCell(2));
	int iEntity = GetNativeCell(1);
	
	g_rfRenderFX[iEntity] = rfType;
	
	SetEntityRenderFx(iEntity, rfType);
	
	return true;
}

public int Native_SetSolid(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	bool bSolid = view_as<bool>(GetNativeCell(2));
	
	bSolid ? DispatchKeyValue(iEntity, "solid", "6") : DispatchKeyValue(iEntity, "solid", "4");
	
	g_bSolid[iEntity] = bSolid;
	
	return true;
}

public int Native_TeleportInfrontOfClient(Handle hPlugin, int iNumParams)
{
	float fAddOrigin, fCVector[2][3], fFinalOrigin[3];
	int iClient = GetNativeCell(1), iEntity = GetNativeCell(2);
	
	fAddOrigin = GetNativeCell(3);
	
	GetClientEyeAngles(iClient, fCVector[0]);
	GetClientAbsOrigin(iClient, fCVector[1]);
	
	fFinalOrigin[0] = fCVector[1][0] + (Cosine(DegToRad(fCVector[0][1])) * 50);
	fFinalOrigin[1] = fCVector[1][1] + (Sine(DegToRad(fCVector[0][1])) * 50);
	fFinalOrigin[2] = fCVector[1][2] + fAddOrigin;
	
	TeleportEntity(iEntity, fFinalOrigin, NULL_VECTOR, NULL_VECTOR);
	
	return true;
}
