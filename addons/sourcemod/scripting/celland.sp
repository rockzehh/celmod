#pragma semicolon 1

#include <celmod>
#include <sdkhooks>
#include <sdktools>
#include <smlib>
#include <sourcemod>

#pragma newdecls required

#define LAND_MODEL "models/error.mdl"

bool g_bLate;

ConVar g_cvMaxLandSize;

float g_fMaxLandSize;

Handle g_hGettingTop[MAXPLAYERS+1];
Handle g_hLandTimer[MAXPLAYERS+1];

int g_iBeam = -1;
int g_iHalo = -1;
int g_iLand = -1;
int g_iLaser = -1;
int g_iPhys = -1;

enum struct Land {
	bool bDrawing;
	bool bGettingTop;
	bool bInLand;
	bool bMade;
	float fBottom[3];
	float fBottomTop[3];
	float fMiddle[3];
	float fOriginal[3];
	float fTop[3];
	int iEntity;
	int iOwner;
	int iPosition;
}

Land g_liLand[MAXENTS+1];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_CreateLandEntity", Native_CreateLandEntity);
	CreateNative("Cel_GetLandOwner", Native_GetLandOwner);
	CreateNative("Cel_IsClientInLand", Native_IsClientInLand);
	CreateNative("Cel_IsClientCrosshairInLand", Native_IsClientCrosshairInLand);
	CreateNative("Cel_IsEntityInLand", Native_IsEntityInLand);
	CreateNative("Cel_IsPositionInBox", Native_IsPositionInBox);
	CreateNative("Cel_DrawLand", Native_DrawLand);
	CreateNative("Cel_GetMiddleOfABox", Native_GetMiddleOfBox);
	
	g_bLate = bLate;
	
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "CelMod: Land",
	author = "rockzehh",
	description = "Creates a personal building area.",
	version = CEL_VERSION,
	url = "https://github.com/rockzehh/celmod"
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
	
	g_cvMaxLandSize = CreateConVar("cel_max_land_size", "1495.5", "Maximum land size allowed.");
	
	g_cvMaxLandSize.AddChangeHook(KSLand_OnConVarChanged);
	
	g_fMaxLandSize = g_cvMaxLandSize.FloatValue;
	
	RegConsoleCmd("sm_land", Command_Land, "CelMod: Creates a building zone.");
}

public void OnClientPutInServer(int iClient)
{
	g_liLand[iClient].bDrawing = false;
	g_liLand[iClient].bGettingTop = false;
	g_liLand[iClient].bInLand = false;
	g_liLand[iClient].bMade = false;
	
	g_liLand[iClient].fBottom = g_fZero;
	g_liLand[iClient].fBottomTop = g_fZero;
	g_liLand[iClient].fMiddle = g_fZero;
	g_liLand[iClient].fOriginal = g_fZero;
	g_liLand[iClient].fTop = g_fZero;
	
	g_liLand[iClient].iEntity = -1;
	g_liLand[iClient].iOwner = -1;
	g_liLand[iClient].iPosition = 0;
	
	g_hGettingTop[iClient] = CreateTimer(0.1, Timer_GettingTop, GetClientUserId(iClient), TIMER_REPEAT);
	g_hLandTimer[iClient] = CreateTimer(0.1, Timer_Land, GetClientUserId(iClient), TIMER_REPEAT);
}

public void OnClientDisconnect(int iClient)
{
	g_liLand[iClient].bDrawing = false;
	g_liLand[iClient].bGettingTop = false;
	g_liLand[iClient].bInLand = false;
	g_liLand[iClient].bMade = false;
	
	g_liLand[iClient].fBottom = g_fZero;
	g_liLand[iClient].fBottomTop = g_fZero;
	g_liLand[iClient].fMiddle = g_fZero;
	g_liLand[iClient].fOriginal = g_fZero;
	g_liLand[iClient].fTop = g_fZero;
	
	g_liLand[iClient].iEntity = -1;
	g_liLand[iClient].iOwner = -1;
	g_liLand[iClient].iPosition = 0;
	
	if(g_hGettingTop[iClient] != INVALID_HANDLE)
	{
		CloseHandle(g_hGettingTop[iClient]);
	}
	
	if(g_hLandTimer[iClient] != INVALID_HANDLE)
	{
		CloseHandle(g_hLandTimer[iClient]);
	}
}

public void OnMapStart()
{
	g_iBeam = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHalo = PrecacheModel("materials/sprites/halo01.vmt");
	g_iLand = PrecacheModel("materials/sprites/spotlight.vmt");
	g_iLaser = PrecacheModel("materials/sprites/laser.vmt");
	g_iPhys = PrecacheModel("materials/sprites/physbeam.vmt");
}

public void OnMapEnd()
{
	g_iBeam = -1;
	g_iHalo = -1;
	g_iLand = -1;
	g_iLaser = -1;
	g_iPhys = -1;
}

public void KSLand_OnConVarChanged(ConVar cvConVar, const char[] sOldValue, const char[] sNewValue)
{
	if (cvConVar == g_cvMaxLandSize)
	{
		g_fMaxLandSize = g_cvMaxLandSize.FloatValue;
		PrintToServer("CelMod: Max land size updated to %s.", sNewValue);
	}
}

//Commands:
public Action Command_Land(int iClient, int iArgs)
{
	switch(g_liLand[iClient].iPosition)
	{
		case 0:
		{
			Cel_GetCrosshairHitOrigin(iClient, g_liLand[iClient].fBottom);
			Cel_GetCrosshairHitOrigin(iClient, g_liLand[iClient].fOriginal);
			
			g_liLand[iClient].bDrawing = true;
			g_liLand[iClient].bGettingTop = true;
			
			Cel_ReplyToCommand(iClient, "Started drawing land.");
			
			g_liLand[iClient].iPosition = 1;
		}
		
		case 1:
		{
			g_liLand[iClient].bGettingTop = false;
			g_liLand[iClient].bMade = true;
			
			Cel_GetMiddleOfABox(g_liLand[iClient].fBottom, g_liLand[iClient].fTop, g_liLand[iClient].fMiddle);
			
			Cel_CreateLandEntity(GetClientUserId(iClient), g_liLand[iClient].fBottom, g_liLand[iClient].fTop);
			
			g_liLand[iClient].iPosition = 2;
		}
		
		case 2:
		{
			g_liLand[iClient].bDrawing = false;
			g_liLand[iClient].bGettingTop = false;
			g_liLand[iClient].bInLand = false;
			g_liLand[iClient].bMade = false;
			
			g_liLand[iClient].fBottom = g_fZero;
			g_liLand[iClient].fBottomTop = g_fZero;
			g_liLand[iClient].fMiddle = g_fZero;
			g_liLand[iClient].fOriginal = g_fZero;
			g_liLand[iClient].fTop = g_fZero;
			
			AcceptEntityInput(g_liLand[iClient].iEntity, "kill");
			
			g_liLand[iClient].iOwner = -1;
			
			g_liLand[iClient].iPosition = 0;
		}
	}
	
	return Plugin_Handled;
}

//Natives:
public int Native_CreateLandEntity(Handle hPlugin, int iNumParams)
{
	char sOwner[64];
	float fMax[3], fMiddle[3], fMin[3];
	int iEnt, iUserID;
	
	iUserID = GetNativeCell(1);
	
	GetNativeArray(2, fMin, 3);
	GetNativeArray(3, fMax, 3);
	
	iEnt = CreateEntityByName("trigger_multiple");
	
	DispatchKeyValue(iEnt, "spawnflags", "64");
	Format(sOwner, sizeof(sOwner), "%i", iUserID);
	DispatchKeyValue(iEnt, "targetname", sOwner);
	DispatchKeyValue(iEnt, "wait", "0");
	
	DispatchSpawn(iEnt);
	ActivateEntity(iEnt);
	
	Cel_GetMiddleOfABox(fMin, fMax, fMiddle);
	
	TeleportEntity(iEnt, fMiddle, NULL_VECTOR, NULL_VECTOR);
	
	PrecacheModel(LAND_MODEL);
	SetEntityModel(iEnt, LAND_MODEL);
	
	fMin[0] = fMin[0] - fMiddle[0];
	if (fMin[0] > 0.0)
	fMin[0] *= -1.0;
	
	fMin[1] = fMin[1] - fMiddle[1];
	if (fMin[1] > 0.0)
	fMin[1] *= -1.0;
	
	fMin[2] = fMin[2] - fMiddle[2];
	if (fMin[2] > 0.0)
	fMin[2] *= -1.0;
	
	fMax[0] = fMax[0] - fMiddle[0];
	if (fMax[0] < 0.0)
	fMax[0] *= -1.0;
	
	fMax[1] = fMax[1] - fMiddle[1];
	if (fMax[1] < 0.0)
	fMax[1] *= -1.0;
	
	fMax[2] = fMax[2] - fMiddle[2];
	if (fMax[2] < 0.0)
	fMax[2] *= -1.0;
	
	SetEntPropVector(iEnt, Prop_Send, "m_vecMins", fMin);
	SetEntPropVector(iEnt, Prop_Send, "m_vecMaxs", fMax);
	
	SetEntProp(iEnt, Prop_Send, "m_nSolidType", 2);
	
	int iEffects = GetEntProp(iEnt, Prop_Send, "m_fEffects");
	iEffects |= 32;
	SetEntProp(iEnt, Prop_Send, "m_fEffects", iEffects);
	
	HookSingleEntityOutput(iEnt, "OnStartTouch", EntOut_LandOnStartTouch);
	HookSingleEntityOutput(iEnt, "OnEndTouch", EntOut_LandOnEndTouch);
	
	g_liLand[GetClientOfUserId(iUserID)].iEntity = iEnt;
	
	return g_liLand[GetClientOfUserId(iUserID)].iEntity;
}

public int Native_GetLandOwner(Handle hPlugin, int iNumParams)
{
	float fBottom[3], fTop[3];
	
	GetNativeArray(1, fBottom, 3);
	GetNativeArray(2, fTop, 3);
	
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientAuthorized(i))
		{
			if(g_liLand[i].fBottom[0] == fBottom[0] && g_liLand[i].fBottom[1] == fBottom[1] && g_liLand[i].fBottom[2] == fBottom[2] && g_liLand[i].fTop[0] == fTop[0] && g_liLand[i].fTop[1] == fTop[1] && g_liLand[i].fTop[2] == fTop[2])
			{
				return i;
			}
		}
	}
	
	return -1;
}

public int Native_IsClientInLand(Handle hPlugin, int iNumParams)
{
	float fOrigin[3];
	int iClient = GetNativeCell(1);
	
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientAuthorized(i))
		{
			GetClientAbsOrigin(iClient, fOrigin);
			
			if(Cel_IsPositionInBox(fOrigin, g_liLand[i].fBottom, g_liLand[i].fTop, iClient))
			{
				SetNativeCellRef(2, GetClientUserId(g_liLand[i].iOwner));
				
				return true;
			}else{
				SetNativeCellRef(2, -1);
				
				return false;
			}
		}
	}
	
	return false;
}

public int Native_IsClientCrosshairInLand(Handle hPlugin, int iNumParams)
{
	char sTargetName[64];
	float fOrigin[3];
	int iClient = GetNativeCell(1);
	
	SetNativeCellRef(2, -1);
	
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientAuthorized(i))
		{
			Cel_GetCrosshairHitOrigin(iClient, fOrigin);
			
			if(Cel_IsPositionInBox(fOrigin, g_liLand[i].fBottom, g_liLand[i].fBottomTop, 0))
			{
				GetEntPropString(g_liLand[i].iEntity, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));
				
				PrintToChatAll("iEntity: %i", g_liLand[i].iEntity);
	
				int iOwner = GetClientOfUserId(StringToInt(sTargetName));
	
				SetNativeCellRef(2, iOwner);
				
				return true;
			}else{
				//SetNativeCellRef(2, -1);
				
				return false;
			}
		}else{
			//SetNativeCellRef(2, -1);
			
			return false;
		}
	}
	
	return false;
}

public int Native_IsEntityInLand(Handle hPlugin, int iNumParams)
{
	float fOrigin[3];
	int iEntity = GetNativeCell(1);
	
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientAuthorized(i))
		{
			Entity_GetAbsOrigin(iEntity, fOrigin);
			
			if(Cel_IsPositionInBox(fOrigin, g_liLand[i].fBottom, g_liLand[i].fTop, 0))
			{
				SetNativeCellRef(2, GetClientUserId(g_liLand[i].iOwner));
				
				return true;
			}else{
				SetNativeCellRef(2, -1);
				
				return false;
			}
		}else{
			SetNativeCellRef(2, -1);
			
			return false;
		}
	}
	
	return false;
}

public int Native_IsPositionInBox(Handle hPlugin, int iNumParams)
{
	float fCorner1[3], fCorner2[3], fPos[3];
	int iClient = GetNativeCell(4);
	
	GetNativeArray(1, fPos, 3);
	GetNativeArray(2, fCorner1, 3);
	GetNativeArray(3, fCorner2, 3);
	
	float fEntity[3];
	float fField1[2];
	float fField2[2];
	float fField3[2];
	
	if (!iClient)
	{
		fEntity = fPos;
	}else
	{
		GetClientAbsOrigin(iClient, fEntity);
	}
	
	//fEntity[2] += 25.0;
	
	if (FloatCompare(fCorner1[0], fCorner2[0]) == -1)
	{
		fField1[0] = fCorner1[0];
		fField1[1] = fCorner2[0];
	}
	else
	{
		fField1[0] = fCorner2[0];
		fField1[1] = fCorner1[0];
	}
	if (FloatCompare(fCorner1[1], fCorner2[1]) == -1)
	{
		fField2[0] = fCorner1[1];
		fField2[1] = fCorner2[1];
	}
	else
	{
		fField2[0] = fCorner2[1];
		fField2[1] = fCorner1[1];
	}
	if (FloatCompare(fCorner1[2], fCorner2[2]) == -1)
	{
		fField3[0] = fCorner1[2];
		fField3[1] = fCorner2[2];
	}
	else
	{
		fField3[0] = fCorner2[2];
		fField3[1] = fCorner1[2];
	}
	
	// Check the Vectors ...
	
	if (fEntity[0] < fField1[0] || fEntity[0] > fField1[1])
	{
		return false;
	}
	if (fEntity[1] < fField2[0] || fEntity[1] > fField2[1])
	{
		return false;
	}
	if (fEntity[2] < fField3[0] || fEntity[2] > fField3[1])
	{
		return false;
	}
	
	return true;
}

public int Native_DrawLand(Handle hPlugin, int iNumParams)
{
	bool bFlat = view_as<bool>(GetNativeCell(5));
	float fFrom[3], fLife, fTo[3];
	int iColor[4];
	
	GetNativeArray(1, fFrom, 3);
	GetNativeArray(2, fTo, 3);
	fLife = view_as<float>(GetNativeCell(3));
	//iColor[0] = GetNativeCell(4);
	GetNativeArray(4, iColor, 4);
	
	float fLeftBottomFront[3];
	
	fLeftBottomFront[0] = fFrom[0];
	fLeftBottomFront[1] = fFrom[1];
	
	if (bFlat)
	{
		fLeftBottomFront[2] = fTo[2] - 2;
	} else {
		fLeftBottomFront[2] = fTo[2];
	}
	
	float fRightBottomFront[3];
	
	fRightBottomFront[0] = fTo[0];
	fRightBottomFront[1] = fFrom[1];
	
	if (bFlat)
	{
		fRightBottomFront[2] = fTo[2] - 2;
	} else {
		fRightBottomFront[2] = fTo[2];
	}
	
	float fLeftBottomBack[3];
	
	fLeftBottomBack[0] = fFrom[0];
	fLeftBottomBack[1] = fTo[1];
	
	if (bFlat)
	{
		fLeftBottomBack[2] = fTo[2] - 2;
	} else {
		fLeftBottomBack[2] = fTo[2];
	}
	
	float fRightBottomBack[3];
	
	fRightBottomBack[0] = fTo[0];
	fRightBottomBack[1] = fTo[1];
	
	if (bFlat)
	{
		fRightBottomBack[2] = fTo[2] - 2;
	} else {
		fRightBottomBack[2] = fTo[2];
	}
	
	float fLeftTopFront[3];
	
	fLeftTopFront[0] = fFrom[0];
	fLeftTopFront[1] = fFrom[1];
	
	if (bFlat)
	{
		fLeftTopFront[2] = fFrom[2] + 3;
	} else {
		fLeftTopFront[2] = fFrom[2] + 100;
	}
	
	float fRightTopFront[3];
	
	fRightTopFront[0] = fTo[0];
	fRightTopFront[1] = fFrom[1];
	
	if (bFlat)
	{
		fRightTopFront[2] = fFrom[2] + 3;
	} else {
		fRightTopFront[2] = fFrom[2] + 100;
	}
	
	float fLeftTopBack[3];
	
	fLeftTopBack[0] = fFrom[0];
	fLeftTopBack[1] = fTo[1];
	
	if (bFlat)
	{
		fLeftTopBack[2] = fFrom[2] + 3;
	} else {
		fLeftTopBack[2] = fFrom[2] + 100;
	}
	
	float fRightTopBack[3];
	
	fRightTopBack[0] = fTo[0];
	fRightTopBack[1] = fTo[1];
	
	if (bFlat)
	{
		fRightTopBack[2] = fFrom[2] + 3;
	} else {
		fRightTopBack[2] = fFrom[2] + 100;
	}
	
	TE_SetupBeamPoints(fLeftTopFront, fRightTopFront, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
	TE_SetupBeamPoints(fLeftTopFront, fLeftTopBack, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
	TE_SetupBeamPoints(fRightTopBack, fLeftTopBack, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
	TE_SetupBeamPoints(fRightTopBack, fRightTopFront, g_iLand, 0, 0, 0, fLife, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
	
	return true;
}

public int Native_GetMiddleOfBox(Handle hPlugin, int iNumParams)
{
	float fBuffer[3], fMax[3], fMin[3];
	
	GetNativeArray(1, fMin, 3);
	GetNativeArray(2, fMax, 3);
	
	float fMid[3];
	
	MakeVectorFromPoints(fMin, fMax, fMid);
	
	fMid[0] = fMid[0] / 2.0;
	fMid[1] = fMid[1] / 2.0;
	fMid[2] = fMid[2] / 2.0;
	
	AddVectors(fMin, fMid, fBuffer);
	
	SetNativeArray(3, fBuffer, 3);
	
	return true;
}

//Outputs:
public void EntOut_LandOnStartTouch(const char[] sOutput, int iCaller, int iActivator, float fDelay)
{
	if (iActivator < 1 || iActivator > MaxClients || !IsClientInGame(iActivator) || !IsPlayerAlive(iActivator))
	return;
	
	char sTargetName[64];
	GetEntPropString(iCaller, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));
	
	int iOwner = GetClientOfUserId(StringToInt(sTargetName));
	
	if(!g_liLand[iActivator].bInLand)
	{
		Cel_PrintToChat(iActivator, "You have entered {green}%N{default}'s land.", iOwner);
	}
	
	g_liLand[iActivator].bInLand = true;
	g_liLand[iActivator].iOwner = iOwner;
}

public void EntOut_LandOnEndTouch(const char[] sOutput, int iCaller, int iActivator, float fDelay)
{
	if (iActivator < 1 || iActivator > MaxClients || !IsClientInGame(iActivator) || !IsPlayerAlive(iActivator))
	return;
	
	g_liLand[iActivator].bInLand = false;
	g_liLand[iActivator].iOwner = -1;
}

//Timers:
public Action Timer_GettingTop(Handle hTimer, any iPlayer)
{
	int iClient = GetClientOfUserId(iPlayer);
	
	if(g_liLand[iClient].bGettingTop)
	{
		Cel_GetCrosshairHitOrigin(iClient, g_liLand[iClient].fBottomTop);
		
		Handle hTraceRay = TR_TraceRayEx(g_liLand[iClient].fBottomTop, g_fUp, MASK_ALL, RayType_Infinite);
		
		if (TR_DidHit(hTraceRay))
		{
			TR_GetEndPosition(g_liLand[iClient].fTop, hTraceRay);
			
			CloseHandle(hTraceRay);
		}
		
		for(int x = 0; x < 2; x++)
		{
			if(g_liLand[iClient].fBottomTop[x] > g_liLand[iClient].fBottom[x] + g_fMaxLandSize) {
				g_liLand[iClient].fBottomTop[x] = g_liLand[iClient].fBottom[x] + g_fMaxLandSize;
			}
			if(g_liLand[iClient].fTop[x] > g_liLand[iClient].fBottom[x] + g_fMaxLandSize) {
				g_liLand[iClient].fTop[x] = g_liLand[iClient].fBottom[x] + g_fMaxLandSize;
			}
			
			if(g_liLand[iClient].fBottomTop[x] < g_liLand[iClient].fBottom[x] - g_fMaxLandSize) {
				g_liLand[iClient].fBottomTop[x] = g_liLand[iClient].fBottom[x] - g_fMaxLandSize;
			}
			if(g_liLand[iClient].fTop[x] < g_liLand[iClient].fBottom[x] - g_fMaxLandSize) {
				g_liLand[iClient].fTop[x] = g_liLand[iClient].fBottom[x] - g_fMaxLandSize;
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Timer_Land(Handle hTimer, any iPlayer)
{
	int iClient = GetClientOfUserId(iPlayer), iColor[4];
	
	Cel_GetHudColor(iClient, iColor);
	
	if(g_liLand[iClient].bDrawing)
	{
		Cel_DrawLand(g_liLand[iClient].fOriginal, g_liLand[iClient].fBottomTop, 0.1, iColor, true);
	}
	
	return Plugin_Continue;
}
