#pragma semicolon 1

#include <celmod>

#pragma newdecls required

const float M_PI = 3.14159265358979323846;
const float PERIOD = 2.5;

bool g_bEntity[MAXENTITIES + 1];
bool g_bMotion[MAXENTITIES + 1];
bool g_bLate;
bool g_bIsFading[MAXENTITIES + 1];
bool g_bRainbow[MAXENTITIES + 1];
bool g_bSolid[MAXENTITIES + 1];

char g_sColorDB[PLATFORM_MAX_PATH];
char g_sPropName[MAXENTITIES + 1][64];

float g_fFadeTime[MAXENTITIES + 1];
float g_fRainbowTime[MAXENTITIES + 1];

int g_iColor[MAXENTITIES + 1][4];
int g_iFadeColor[MAXENTITIES + 1][6];
int g_iEntityDissolve;
int g_iOwner[MAXENTITIES + 1];
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
	CreateNative("Cel_DissolveEntity", Native_DissolveEntity);
	CreateNative("Cel_GetClientAimTarget", Native_GetClientAimTarget);
	CreateNative("Cel_GetColor", Native_GetColor);
	CreateNative("Cel_GetEntityCatagory", Native_GetEntityCatagory);
	CreateNative("Cel_GetEntityCatagoryName", Native_GetEntityCatagoryName);
	CreateNative("Cel_GetEntityType", Native_GetEntityType);
	CreateNative("Cel_GetEntityTypeFromName", Native_GetEntityTypeFromName);
	CreateNative("Cel_GetEntityTypeName", Native_GetEntityTypeName);
	CreateNative("Cel_GetMotion", Native_GetMotion);
	CreateNative("Cel_GetOwner", Native_GetOwner);
	CreateNative("Cel_GetPropName", Native_GetPropName);
	CreateNative("Cel_IsEntity", Native_IsEntity);
	CreateNative("Cel_IsFading", Native_IsFading);
	CreateNative("Cel_IsRainbow", Native_IsRainbow);
	CreateNative("Cel_IsSolid", Native_IsSolid);
	CreateNative("Cel_SetColor", Native_SetColor);
	CreateNative("Cel_SetColorFade", Native_SetColorFade);
	CreateNative("Cel_SetEntity", Native_SetEntity);
	CreateNative("Cel_SetMotion", Native_SetMotion);
	CreateNative("Cel_SetOwner", Native_SetOwner);
	CreateNative("Cel_SetRainbow", Native_SetRainbow);
	CreateNative("Cel_SetSolid", Native_SetSolid);
	CreateNative("Cel_CheckRenderFX", Native_CheckRenderFX);
	CreateNative("Cel_GetRenderFX", Native_GetRenderFX);
	CreateNative("Cel_GetRenderFXFromName", Native_GetRenderFXFromName);
	CreateNative("Cel_GetRenderFXName", Native_GetRenderFXName);
	CreateNative("Cel_SetPropName", Native_SetPropName);
	CreateNative("Cel_SetRenderFX", Native_SetRenderFX);
	
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
	LoadTranslations("celmod.phrases");
	LoadTranslations("common.phrases");
	
	BuildPath(Path_SM, g_sColorDB, sizeof(g_sColorDB), "data/celmod/colors.txt");
	if (!FileExists(g_sColorDB))
	{
		ThrowError("|CelMod| %t", "FileNotFound", g_sColorDB);
	}
	
	RegConsoleCmd("sm_alpha", Command_Alpha, "|CelMod| Changes the transparency on the prop you are looking at.");
	RegConsoleCmd("sm_amt", Command_Alpha, "|CelMod| Changes the transparency on the prop you are looking at.");
	RegConsoleCmd("sm_color", Command_Color, "|CelMod| Colors the prop you are looking at.");
	RegConsoleCmd("sm_fadecolor", Command_FadeColor, "|CelMod| Fades the prop you are looking at between two colors.");
	RegConsoleCmd("sm_freeze", Command_FreezeIt, "|CelMod| Freezes the prop you are looking at.");
	RegConsoleCmd("sm_freezeit", Command_FreezeIt, "|CelMod| Freezes the prop you are looking at.");
	RegConsoleCmd("sm_paint", Command_Color, "|CelMod| Colors the prop you are looking at.");
	RegConsoleCmd("sm_pmove", Command_SMove, "|CelMod| Moves the prop you are looking at on it's origin.");
	RegConsoleCmd("sm_renderfx", Command_RenderFX, "|CelMod| Changes the RenderFX on the prop you are looking at.");
	RegConsoleCmd("sm_rotate", Command_Rotate, "|CelMod| Rotates the prop you are looking at.");
	//RegConsoleCmd("sm_skin", Command_Skin, "|CelMod| Changes the skin on the prop you are looking at.");
	RegConsoleCmd("sm_smove", Command_SMove, "|CelMod| Moves the prop you are looking at on it's origin.");
	RegConsoleCmd("sm_solid", Command_Solid, "|CelMod| Enables/disables solidicity on the prop you are looking at.");
	RegConsoleCmd("sm_stack", Command_Stack, "|CelMod| Stacks props on the x, y and z axis.");
	RegConsoleCmd("sm_stackinfo", Command_StackInfo, "|CelMod| Gets the origin difference between props for help stacking.");
	RegConsoleCmd("sm_stand", Command_Stand, "|CelMod| Resets the angles on the prop you are looking at.");
	RegConsoleCmd("sm_straight", Command_Stand, "|CelMod| Resets the angles on the prop you are looking at.");
	RegConsoleCmd("sm_straighten", Command_Stand, "|CelMod| Resets the angles on the prop you are looking at.");
	RegConsoleCmd("sm_unfreeze", Command_UnfreezeIt, "|CelMod| Unfreezes the prop you are looking at.");
	RegConsoleCmd("sm_unfreezeit", Command_UnfreezeIt, "|CelMod| Unfreezes the prop you are looking at.");
	
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
		
		if(StrContains(sOption, "all", false) !=-1)
		{
			for (int i = 0; i < GetMaxEntities(); i++)
			{
				if (Cel_CheckOwner(iClient, i) && Cel_IsEntity(i) && IsValidEdict(i))
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
		
		
		if(StrContains(sOption, "all", false) !=-1)
		{
			for (int i = 0; i < GetMaxEntities(); i++)
			{
				if (Cel_CheckOwner(iClient, i) && Cel_IsEntity(i) && IsValidEdict(i))
				{
					if(StrEqual(sColor, "rainbow", false))
					{
						Cel_SetRainbow(i, true);
						Cel_SetColorFade(i, false, 0, 0, 0, 0, 0, 0);
					}else if (Cel_CheckColorDB(sColor, sColorString, sizeof(sColorString)))
					{
						ExplodeString(sColorString, "|", sColorBuffer, 3, sizeof(sColorBuffer[]));
						
						Cel_SetRainbow(i, false);
						Cel_SetColorFade(i, false, 0, 0, 0, 0, 0, 0);
						
						Cel_SetColor(i, StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
						
						if(Cel_GetEntityType(i) == ENTTYPE_EFFECT)
						{
							Cel_SetRainbow(Cel_GetEffectAttachment(i), false);
							Cel_SetColorFade(Cel_GetEffectAttachment(i), false, 0, 0, 0, 0, 0, 0);
							
							Cel_SetColor(Cel_GetEffectAttachment(i), StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
						}
					}else {
						Cel_ReplyToCommand(iClient, "%t", "ColorNotFound", sColor);
						return Plugin_Handled;
					}
				}
			}
			Cel_ReplyToCommand(iClient, "%t", "SetAllColor", sColor);
		}else if(StrContains(sOption, "hud", false) !=-1)
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
				Cel_SetColorFade(iProp, false, 0, 0, 0, 0, 0, 0);
				
				Cel_ChangeBeam(iClient, iProp);
				
				Cel_ReplyToCommand(iClient, "%t", "SetColor", sEntityType, "rainbow");
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
					Cel_SetColorFade(Cel_GetEffectAttachment(iProp), false, 0, 0, 0, 0, 0, 0);
					
					Cel_SetColor(Cel_GetEffectAttachment(iProp), StringToInt(sColorBuffer[0]), StringToInt(sColorBuffer[1]), StringToInt(sColorBuffer[2]), -1);
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
		
		if(StrContains(sOption, "all", false) !=-1)
		{
			for (int i = 0; i < GetMaxEntities(); i++)
			{
				if (Cel_CheckOwner(iClient, i) && Cel_IsEntity(i) && IsValidEdict(i))
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
					
					Cel_SetRainbow(i, false);
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
			
			Cel_SetRainbow(iProp, false);
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
		GetCmdArg(i, sTemp, sizeof(sTemp));
		
		fAddAngles[i-1] = StringToFloat(sTemp);
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
		
		if (Cel_CheckEntityType(iProp, "door"))
		{
			DispatchKeyValueVector(iProp, "angles", fAngles);
		} else {
			TeleportEntity(iProp, NULL_VECTOR, fAngles, NULL_VECTOR);
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
		GetCmdArg(i, sTemp, sizeof(sTemp));
		
		fAddOrigin[i-1] = StringToFloat(sTemp);
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

public Action Command_Stack(int iClient, int iArgs)
{
	char sArgs[4][32], sEntity[4][64], sEntityType[32];
	float fAngles[3], fFinalOrigin[3], fOrigin[3];
	int iColor[4], iCount = 0;
	
	if (iArgs < 4)
	{
		Cel_ReplyToCommand(iClient, "Usage: {green}[tag]stack{default} <amount> <x> <y> <z>");
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
			
			Cel_ReplyToCommand(iClient, "Stacked {green}%i{default} %s.", iCount, sEntityType);
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
				
				Cel_ReplyToCommand(iClient, "Selected first prop for stacking info, type {green}!stackinfo{default} on another prop to get the stacking info.");
			}else{
				g_iStackInfoEnt[iClient] = -1;
				
				g_iStackInfoStatus[iClient] = 0;
				
				Cel_ReplyToCommand(iClient, "You cannot stack this prop!");
			}
		}
		
		case 1:
		{
			if(Cel_IsEntity(iEntity) && Cel_IsEntity(g_iStackInfoEnt[iClient]) && Cel_GetEntityCatagory(iEntity) == ENTCATAGORY_PROP)
			{
				if(g_iStackInfoEnt[iClient] == iEntity)
				{
					g_iStackInfoStatus[iClient] = 1;
					
					Cel_ReplyToCommand(iClient, "You cannot stack the same prop!");
				}else{
					g_iStackInfoStatus[iClient] = 0;
					
					Cel_GetEntityOrigin(g_iStackInfoEnt[iClient], fOrigin[0]);
					Cel_GetEntityOrigin(iEntity, fOrigin[1]);
					
					g_iStackInfoEnt[iClient] = -1;
					
					fOrigin[2][0] = fOrigin[1][0] - fOrigin[0][0];
					fOrigin[2][1] = fOrigin[1][1] - fOrigin[0][1];
					fOrigin[2][2] = fOrigin[1][2] - fOrigin[0][2];
					
					Cel_ReplyToCommand(iClient, "Stack Information:\nX = {green}%f{default}\nY = {green}%f{default}\nZ = {green}%f{default}", fOrigin[2][0], fOrigin[2][1], fOrigin[2][2]);
				}
			}else{
				g_iStackInfoEnt[iClient] = -1;
				
				g_iStackInfoStatus[iClient] = 0;
				
				Cel_ReplyToCommand(iClient, "You cannot stack this prop!");
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

//Frames:
public void Frame_FadeColor(any iProp)
{
	int iColor[3];
	
	if (Cel_IsEntity(iProp) && IsValidEdict(iProp) && g_bIsFading[iProp])
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
	}
	
	if(g_bIsFading[iProp])
	RequestFrame(Frame_FadeColor, iProp);
}

public void Frame_Rainbow(any iProp)
{
	int iColor[3];
	
	if (Cel_IsEntity(iProp) && IsValidEdict(iProp) && g_bRainbow[iProp])
	{
		float fTime = (GetGameTime() - g_fRainbowTime[iProp]) * ((2.0 * M_PI) / PERIOD);
		
		iColor[0] = RoundToFloor((Cosine(fTime) + 1.0) * 127.5);
		iColor[1] = RoundToFloor((Cosine(fTime - (2.0 * M_PI / 3.0)) + 1.0) * 127.5);
		iColor[2] = RoundToFloor((Cosine(fTime - 2*(2.0 * M_PI / 3.0)) + 1.0) * 127.5);
		
		Cel_SetColor(iProp, iColor[0], iColor[1], iColor[2], g_iColor[iProp][3]);
		
		if(Cel_GetEntityType(iProp) == ENTTYPE_EFFECT)
		{
			Cel_SetColor(Cel_GetEffectAttachment(iProp), iColor[0], iColor[1], iColor[2], g_iColor[iProp][3]);
		}
	}
	
	if(g_bRainbow[iProp])
	RequestFrame(Frame_Rainbow, iProp);
}

//Natives:
public int Native_ChangePositionRelativeToOrigin(Handle hPlugin, int iNumParams)
{
	float fAddOrigin[3], fFinalOrigin[3], fOrigin[3];
	
	int iEntity = GetNativeCell(1);
	
	GetNativeArray(2, fAddOrigin, 3);
	
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

public int Native_CheckOwner(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iEntity = GetNativeCell(2);
	
	return (Cel_GetOwner(iEntity) == iClient && Cel_IsEntity(iEntity)) ? true : false;
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

public int Native_CheckRenderFX(Handle hPlugin, int iNumParams)
{
	char sCheck[PLATFORM_MAX_PATH], sType[PLATFORM_MAX_PATH];
	int iEntity = GetNativeCell(1);
	
	GetNativeString(2, sCheck, sizeof(sCheck));
	
	Cel_GetRenderFXName(Cel_GetRenderFX(iEntity), sType, sizeof(sType));
	
	return (StrContains(sType, sCheck, false) != -1);
}

public int Native_DissolveEntity(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	DispatchKeyValue(iEntity, "classname", "deleted");
	
	AcceptEntityInput(g_iEntityDissolve, "dissolve");
	
	return true;
}

public int Native_GetClientAimTarget(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	if (GetClientAimTarget(iClient, false) == -1)
	{
		return -1;
	}
	
	int iTarget = GetClientAimTarget(iClient, false);
	
	return (Cel_IsEntity(iTarget)) ? iTarget : -1;
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
	
	if (etEntityType == ENTTYPE_DOOR || etEntityType == ENTTYPE_EFFECT || etEntityType == ENTTYPE_INTERNET || etEntityType == ENTTYPE_LIGHT || etEntityType == ENTTYPE_CLEER)
	{
		return view_as<int>(ENTCATAGORY_CEL);
	} else if (etEntityType == ENTTYPE_CYCLER || etEntityType == ENTTYPE_DYNAMIC || etEntityType == ENTTYPE_PHYSICS)
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
	
	if (StrEqual(sClassname, "cycler", false))
	{
		return view_as<int>(ENTTYPE_CYCLER);
	} else if (StrEqual(sClassname, "cel_door", false))
	{
		return view_as<int>(ENTTYPE_DOOR);
	} else if (StrEqual(sClassname, "cel_internet", false))
	{
		return view_as<int>(ENTTYPE_INTERNET);
	} else if (StrEqual(sClassname, "cel_light", false))
	{
		return view_as<int>(ENTTYPE_LIGHT);
	} else if (StrContains(sClassname, "effect_", false) != -1)
	{
		return view_as<int>(ENTTYPE_EFFECT);
	} else if (StrContains(sClassname, "prop_cleer", false) != -1)
	{
		return view_as<int>(ENTTYPE_CLEER);
	} else if (StrContains(sClassname, "prop_dynamic", false) != -1)
	{
		return view_as<int>(ENTTYPE_DYNAMIC);
	} else if (StrContains(sClassname, "prop_physics", false) != -1)
	{
		return view_as<int>(ENTTYPE_PHYSICS);
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
	} else if (StrEqual(sEntityType, "light", false))
	{
		return view_as<int>(ENTTYPE_LIGHT);
	} else if (StrEqual(sEntityType, "physics", false))
	{
		return view_as<int>(ENTTYPE_PHYSICS);
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
		case ENTTYPE_LIGHT:
		{
			Format(sEntityType, sizeof(sEntityType), "light cel");
		}
		case ENTTYPE_PHYSICS:
		{
			Format(sEntityType, sizeof(sEntityType), "physics prop");
		}
		case ENTTYPE_UNKNOWN:
		{
			Format(sEntityType, sizeof(sEntityType), "unknown prop type");
		}
	}
	
	SetNativeString(2, sEntityType, iMaxLength);
	
	return true;
}

public int Native_GetMotion(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return g_bMotion[iEntity];
}

public int Native_GetOwner(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return GetClientFromSerial(g_iOwner[iEntity]);
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

public int Native_IsEntity(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	if(IsValidEntity(iEntity) && iEntity != -1)
	{
		return g_bEntity[iEntity];
	}
	
	return false;
}

public int Native_IsFading(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return g_bIsFading[iEntity];
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
	
	if(bFade)
	{
		g_iFadeColor[iEntity][0] = GetNativeCell(3);
		g_iFadeColor[iEntity][1] = GetNativeCell(4);
		g_iFadeColor[iEntity][2] = GetNativeCell(5);
		g_iFadeColor[iEntity][3] = GetNativeCell(6);
		g_iFadeColor[iEntity][4] = GetNativeCell(7);
		g_iFadeColor[iEntity][5] = GetNativeCell(8);
		
		g_bIsFading[iEntity] = true;
		
		g_fFadeTime[iEntity] = GetGameTime();
		
		RequestFrame(Frame_FadeColor, iEntity);
	}else{
		g_iFadeColor[iEntity][0] = 0;
		g_iFadeColor[iEntity][1] = 0;
		g_iFadeColor[iEntity][2] = 0;
		g_iFadeColor[iEntity][3] = 0;
		g_iFadeColor[iEntity][4] = 0;
		g_iFadeColor[iEntity][5] = 0;
		
		g_bIsFading[iEntity] = false;
		
		g_fFadeTime[iEntity] = 0.0;
	}
	
	return true;
}

public int Native_SetEntity(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	bool bEntity = view_as<bool>(GetNativeCell(2));
	
	g_bEntity[iEntity] = bEntity;
	
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
	
	g_iOwner[iEntity] = GetClientSerial(iClient);
	
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
	}
	
	RequestFrame(Frame_Rainbow, iEntity);
	
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
