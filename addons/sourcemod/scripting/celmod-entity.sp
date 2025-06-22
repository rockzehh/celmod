#pragma semicolon 1

#include <celmod>

#pragma newdecls required

const float M_PI = 3.14159265358979323846;
const float PERIOD = 3.4;

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
char g_sCopyBuffer[MAXPLAYERS + 1][21][128];
char g_sPropName[MAXENTITIES + 1][64];

float g_fCopyOrigin[MAXPLAYERS + 1][3];
float g_fCopyMoveOrigin[MAXPLAYERS + 1][3];
float g_fFadeTime[MAXENTITIES + 1];
float g_fRainbowTime[MAXENTITIES + 1];

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
	CreateNative("Cel_CheckRenderFX", Native_CheckRenderFX);
	CreateNative("Cel_CopyProp", Native_CopyProp);
	CreateNative("Cel_DissolveEntity", Native_DissolveEntity);
	CreateNative("Cel_GetColor", Native_GetColor);
	CreateNative("Cel_GetFadeColor", Native_GetFadeColor);
	CreateNative("Cel_GetMotion", Native_GetMotion);
	CreateNative("Cel_GetPropName", Native_GetPropName);
	CreateNative("Cel_GetRenderFX", Native_GetRenderFX);
	CreateNative("Cel_GetRenderFXFromName", Native_GetRenderFXFromName);
	CreateNative("Cel_GetRenderFXName", Native_GetRenderFXName);
	CreateNative("Cel_IsFading", Native_IsFading);
	CreateNative("Cel_IsLocked", Native_IsLocked);
	CreateNative("Cel_IsRainbow", Native_IsRainbow);
	CreateNative("Cel_IsSolid", Native_IsSolid);
	CreateNative("Cel_LockEntity", Native_LockEntity);
	CreateNative("Cel_PasteProp", Native_PasteProp);
	CreateNative("Cel_SetColor", Native_SetColor);
	CreateNative("Cel_SetColorFade", Native_SetColorFade);
	CreateNative("Cel_SetMotion", Native_SetMotion);
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
	
	RegConsoleCmd("+copy", Command_StartCopy, "|CelMod| Starts copying and moving the prop you are looking at.");
	RegConsoleCmd("+move", Command_StartGrab, "|CelMod| Starts moving the prop you are looking at.");
	RegConsoleCmd("-copy", Command_StopCopy, "|CelMod| Stops copying and moving the prop you are looking at.");
	RegConsoleCmd("-move", Command_StopGrab, "|CelMod| Stops moving the prop you are looking at.");
	RegConsoleCmd("v_alpha", Command_Alpha, "|CelMod| Changes the transparency on the prop you are looking at.");
	RegConsoleCmd("v_amt", Command_Alpha, "|CelMod| Changes the transparency on the prop you are looking at.");
	RegConsoleCmd("v_color", Command_Color, "|CelMod| Colors the prop you are looking at.");
	RegConsoleCmd("v_copy", Command_CopyProp, "|CelMod| Copies the prop you are looking at into your copy buffer.");
	RegConsoleCmd("v_drop", Command_Drop, "|CelMod| Teleports the entity you are looking at to the floor.");
	RegConsoleCmd("v_fadecolor", Command_FadeColor, "|CelMod| Fades the prop you are looking at between two colors.");
	RegConsoleCmd("v_flip", Command_HookFlip, "|CelMod| Flips the prop you are looking at.");
	RegConsoleCmd("v_freeze", Command_FreezeIt, "|CelMod| Freezes the prop you are looking at.");
	RegConsoleCmd("v_freezeit", Command_FreezeIt, "|CelMod| Freezes the prop you are looking at.");
	RegConsoleCmd("v_lock", Command_Lock, "|CelMod| Locks the cel you are looking at.");
	RegConsoleCmd("v_paint", Command_Color, "|CelMod| Colors the prop you are looking at.");
	RegConsoleCmd("v_paste", Command_PasteProp, "|CelMod| Pastes the prop in your copy buffer where you are looking at.");
	RegConsoleCmd("v_pmove", Command_SMove, "|CelMod| Moves the prop you are looking at on it's origin.");
	RegConsoleCmd("v_renderfx", Command_RenderFX, "|CelMod| Changes the RenderFX on the prop you are looking at.");
	RegConsoleCmd("v_r", Command_HookRotate, "|CelMod| Rotates the prop you are looking at.");
	RegConsoleCmd("v_replace", Command_Replace, "|CelMod| Replaces the model on the entity you are looking at.");
	RegConsoleCmd("v_roll", Command_HookRoll, "|CelMod| Rolls the prop you are looking at.");
	RegConsoleCmd("v_rotate", Command_Rotate, "|CelMod| Flips, rotates and rolls the prop you are looking at.");
	RegConsoleCmd("v_skin", Command_Skin, "|CelMod| Changes the skin on the prop you are looking at.");
	RegConsoleCmd("v_smove", Command_SMove, "|CelMod| Moves the prop you are looking at on it's origin.");
	RegConsoleCmd("v_solid", Command_Solid, "|CelMod| Enables/disables solidicity on the prop you are looking at.");
	RegConsoleCmd("v_stack", Command_Stack, "|CelMod| Stacks props on the x, y and z axis.");
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
	
	DispatchKeyValue(g_iEntityDissolve, "classname", "celmod_entity_dissolver");
}

public void OnMapEnd()
{
	g_iEntityDissolve = -1;
}

public Action Command_Alpha(int iClient, int iArgs)
{
	char sAlpha[16], sEntityType[32], sOption[32];
	
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
			Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
			
			Cel_SetColor(iProp, -1, -1, -1, iAlpha);
			
			if(Cel_GetEntityType(iProp) == ENTTYPE_EFFECT)
			Cel_SetColor(Cel_GetEffectAttachment(iProp), -1, -1, -1, iAlpha);
			
			Cel_ChangeBeam(iClient, iProp);
			
			Cel_ReplyToCommand(iClient, "%t", "SetTransparency", sEntityType, iAlpha);
		} else {
			Cel_NotYours(iClient, iProp);
			return Plugin_Handled;
		}
	}
	
	return Plugin_Handled;
}

public Action Command_Color(int iClient, int iArgs)
{
	char sColor[64], sColorBuffer[3][6], sColorString[16], sEntityType[32], sOption[32];
	
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
				Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
				
				Cel_SetRainbow(iProp, true);
				
				Cel_ChangeBeam(iClient, iProp);
				
				Cel_ReplyToCommand(iClient, "%t", "SetColor", sEntityType, "rainbow");
			}else if(StrEqual(sColor, "error", false))
			{
				Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
				
				Cel_SetColorFade(iProp, true, 255, 32, 0, 0, 0, 0);
				
				Cel_ChangeBeam(iClient, iProp);
				
				Cel_ReplyToCommand(iClient, "%t", "SetColor", sEntityType, "error");
			}else if (Cel_CheckColorDB(sColor, sColorString, sizeof(sColorString)))
			{
				ExplodeString(sColorString, "|", sColorBuffer, 3, sizeof(sColorBuffer[]));
				
				Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
				
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
				
				Cel_ReplyToCommand(iClient, "%t", "SetColor", sEntityType, sColor);
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
	char sEntityType[64];
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
		
		if(Cel_CheckEntityType(iProp, "physics") || Cel_CheckEntityType(iProp, "dynamic"))
		{
			Cel_CopyProp(iClient, iProp);
			
			g_bHasCopyEntity[iClient] = true;
			
			Cel_ChangeBeam(iClient, iProp);
			
			Cel_ReplyToCommand(iClient, "%t", "AddedToCopyQueue", sEntityType);
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

//Thanks instakill for the direction.
public Action Command_Drop(int iClient, int iArgs)
{
	float fBounds[3], fDropOrigin[3], fEntityOrigin[3];
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityOrigin(iProp, fEntityOrigin);
		Entity_GetMinSize(iProp, fBounds);
		
		Handle hTraceRay = TR_TraceRayFilterEx(fEntityOrigin, g_fDown, (MASK_SHOT_HULL|MASK_SHOT), RayType_Infinite, Cel_FilterPlayer, iProp);
		
		if (TR_DidHit(hTraceRay))
		{
			TR_GetEndPosition(fDropOrigin, hTraceRay);
			
			CloseHandle(hTraceRay);
		}
		
		fEntityOrigin[2] = fDropOrigin[2] - fBounds[2];
		
		TeleportEntity(iProp, fEntityOrigin, NULL_VECTOR, NULL_VECTOR);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_FadeColor(int iClient, int iArgs)
{
	char sColor[2][64], sColorBuffer[3][6], sColorString[16], sEntityType[32], sOption[32];
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
			Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
			
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
			
			Cel_ReplyToCommand(iClient, "%t", "SetFadingColors", sEntityType, sColor[0], sColor[1]);
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
	char sEntityType[32];
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
		
		if (Cel_CheckEntityType(iProp, "door"))
		{
			Cel_ReplyToCommand(iClient, "%t", "DoorLock");
			
			AcceptEntityInput(iProp, "lock");
		} else {
			Cel_ReplyToCommand(iClient, "%t", "DisableMotion", sEntityType);
			
			Cel_SetMotion(iProp, false);
		}
		
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
	char sEntityType[32];
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
		
		if(Cel_CheckEntityType(iProp, "cycler") || Cel_CheckEntityType(iProp, "dynamic") || Cel_CheckEntityType(iProp, "ladder") || 
			Cel_CheckEntityType(iProp, "physics") || Cel_CheckEntityType(iProp, "cleer") || Cel_CheckEntityType(iProp, "bit") || Cel_CheckEntityType(iProp, "unknown"))
		{
			Cel_ReplyToCommand(iClient, "%t", "CannotLock");
			return Plugin_Handled;
		}
		
		Cel_LockEntity(iProp, true);
		
		Cel_ReplyToCommand(iClient, "%t", "Locked", sEntityType);
		
		Cel_ChangeBeam(iClient, iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_PasteProp(int iClient, int iArgs)
{
	char sEntityType[64];
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
	
	Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
	
	Cel_ChangeBeam(iClient, iProp);
	
	Cel_ReplyToCommand(iClient, "%t", "PastedFromCopyQueue", sEntityType);
	
	return Plugin_Handled;
}

public Action Command_Replace(int iClient, int iArgs)
{
	char sAlias[64], sEntityType[64], sSpawnBuffer[2][128], sSpawnString[256];
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
		Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
		
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
			
			Cel_ReplyToCommand(iClient, "%t", "ReplacedModel", sAlias, sEntityType);
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
	char sEntityType[64], sSkin[16];
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
		Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
		
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
		
		Cel_ReplyToCommand(iClient, "%t", "SetSkin", sEntityType, iSkin);
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
	char sEntityType[128];
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
		
		if (Cel_CheckEntityType(iProp, "cycler"))
		{
			Cel_ReplyToCommand(iClient, "%t", "CantUseCommand-Prop");
			return Plugin_Handled;
		}
		
		Cel_SetSolid(iProp, !Cel_IsSolid(iProp));
		
		Cel_ReplyToCommand(iClient, "%t", "SetSolidicity", Cel_IsSolid(iProp) ? "on" : "off", sEntityType);
		
		Cel_ChangeBeam(iClient, iProp);
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

public Action Command_Stack(int iClient, int iArgs)
{
	char sArgs[4][32], sEntity[4][64], sEntityType[32];
	float fAngles[3], fFinalOrigin[3], fOrigin[3];
	int iColor[4], iCount = 0;
	
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
	GetCmdArg(4, sArgs[3], sizeof(sArgs[]));
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
		
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
			
			Cel_ReplyToCommand(iClient, "%t", "StackedProps", iCount, sEntityType);
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
	char sEntityType[32];
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
		
		if (Cel_CheckEntityType(iProp, "door"))
		{
			Cel_ReplyToCommand(iClient, "%t", "DoorUnlock");
			
			AcceptEntityInput(iProp, "unlock");
		} else {
			Cel_ReplyToCommand(iClient, "%t", "EnableMotion", sEntityType);
			
			Cel_SetMotion(iProp, true);
		}
		
		Cel_ChangeBeam(iClient, iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_Unlock(int iClient, int iArgs)
{
	char sEntityType[32];
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iProp = Cel_GetClientAimTarget(iClient);
	
	if (Cel_CheckOwner(iClient, iProp))
	{
		Cel_GetEntityTypeName(Cel_GetEntityType(iProp), sEntityType, sizeof(sEntityType));
		
		if(Cel_CheckEntityType(iProp, "cycler") || Cel_CheckEntityType(iProp, "dynamic") || Cel_CheckEntityType(iProp, "ladder") || 
			Cel_CheckEntityType(iProp, "physics") || Cel_CheckEntityType(iProp, "cleer") || Cel_CheckEntityType(iProp, "bit") || Cel_CheckEntityType(iProp, "unknown"))
		{
			Cel_ReplyToCommand(iClient, "%t", "CannotUnlock", sEntityType);
			return Plugin_Handled;
		}
		
		Cel_LockEntity(iProp, false);
		
		Cel_ReplyToCommand(iClient, "%t", "Unlocked", sEntityType);
		
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
	
	Cel_SetColorFade(iEntity, view_as<bool>(StringToInt(g_sCopyBuffer[iClient][12])), StringToInt(g_sCopyBuffer[iClient][14]), StringToInt(g_sCopyBuffer[iClient][15]), StringToInt(g_sCopyBuffer[iClient][16]), StringToInt(g_sCopyBuffer[iClient][17]), StringToInt(g_sCopyBuffer[iClient][18]), StringToInt(g_sCopyBuffer[iClient][19]));
	Cel_SetRainbow(iEntity, view_as<bool>(StringToInt(g_sCopyBuffer[iClient][13])));
	
	return iEntity;
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

public int Native_SetMotion(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	bool bMotion = view_as<bool>(GetNativeCell(2));
	
	bMotion ? AcceptEntityInput(iEntity, "enablemotion") : AcceptEntityInput(iEntity, "disablemotion");
	
	g_bMotion[iEntity] = bMotion;
	
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
