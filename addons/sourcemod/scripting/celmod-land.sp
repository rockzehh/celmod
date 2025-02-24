#pragma semicolon 1

#include <celmod>

#pragma newdecls required

#define LAND_MODEL "models/error.mdl"

bool g_bLate;

ConVar g_cvMaxLandSize;

float g_fMaxLandSize;

Handle g_hGettingTop[MAXPLAYERS+1];
Handle g_hLandTimer[MAXPLAYERS+1];

int g_iBeam = -1;
int g_iCurrentLandEntity[MAXPLAYERS + 1];
int g_iCurrentLandOwner[MAXPLAYERS + 1];
int g_iHalo = -1;
int g_iLand = -1;
int g_iLaser = -1;
int g_iPhys = -1;

enum struct Land {
	bool bGodMode;
	bool bInDeathmatchMode;
	bool bInsideLand;
	bool bLandCreated;
	bool bLandDrawing;
	bool bLandGettingTopPos;
	bool bModeCoop;
	bool bModeDeathmatch;
	bool bModeShop;

	float fLandGravity;
	float fLandPosBottom[3];
	float fLandPosBottomMiddle[3];
	float fLandPosBottomTop[3];
	float fLandPosStarting[3];
	float fLandPosTop[3];

	int iLandEntity;
	int iLandOwner;
	int iLandStage;
}

Land g_liLand[MAXPLAYERS+1];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_ClearLand", Native_ClearLand);
	CreateNative("Cel_CreateLand", Native_CreateLand);
	CreateNative("Cel_DrawLandBorders", Native_DrawLandBorders);
	CreateNative("Cel_GetCurrentLandEntity", Native_GetCurrentLandEntity);
	CreateNative("Cel_GetCurrentLandOwner", Native_GetCurrentLandOwner);
	CreateNative("Cel_GetLandEntity", Native_GetLandEntity);
	CreateNative("Cel_GetLandGravity", Native_GetLandGravity);
	CreateNative("Cel_GetLandOwner", Native_GetLandOwner);
	CreateNative("Cel_GetLandPositions", Native_GetLandPositions);
	CreateNative("Cel_GetMiddleOfABox", Native_GetMiddleOfBox);
	CreateNative("Cel_IsClientCrosshairInLand", Native_IsClientCrosshairInLand);
	CreateNative("Cel_IsClientInLand", Native_IsClientInLand);
	CreateNative("Cel_IsEntityInLand", Native_IsEntityInLand);
	CreateNative("Cel_IsPositionInBox", Native_IsPositionInBox);
	CreateNative("Cel_SetLandGravity", Native_SetLandGravity);
	CreateNative("Cel_SetCurrentLandEntity", Native_SetCurrentLandEntity);
	CreateNative("Cel_SetCurrentLandOwner", Native_SetCurrentLandOwner);

	g_bLate = bLate;

	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "|CelMod| Land",
	author = CEL_AUTHOR,
	description = "Creates a personal building area.",
	version = CEL_VERSION,
	url = CEL_URL
};

public void OnPluginStart()
{
	LoadTranslations("celmod.phrases");

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

	g_cvMaxLandSize = CreateConVar("cm_max_land_size", "1495.5", "Maximum land size allowed.");

	g_cvMaxLandSize.AddChangeHook(CMLand_OnConVarChanged);

	g_fMaxLandSize = g_cvMaxLandSize.FloatValue;

	RegConsoleCmd("sm_land", Command_Land, "|CelMod| Creates a building zone.");
	RegConsoleCmd("sm_landdeathmatch", Command_LandDeathmatch, "|CelMod| Changes the deathmatch setting within the land.");
	RegConsoleCmd("sm_landgravity", Command_LandGravity, "|CelMod| Changes the gravity within the land.");
}

public void OnClientPutInServer(int iClient)
{
	g_liLand[iClient].bModeCoop = false;
	g_liLand[iClient].bModeShop = false;
	g_liLand[iClient].bModeDeathmatch = false;
	g_liLand[iClient].bLandDrawing = false;
	g_liLand[iClient].bLandGettingTopPos = false;
	g_liLand[iClient].bInDeathmatchMode = false;
	g_liLand[iClient].bInsideLand = false;
	g_liLand[iClient].bLandCreated = false;

	g_liLand[iClient].fLandPosBottom = g_fZero;
	g_liLand[iClient].fLandPosBottomTop = g_fZero;
	g_liLand[iClient].fLandGravity = 1.0;
	g_liLand[iClient].fLandPosBottomMiddle = g_fZero;
	g_liLand[iClient].fLandPosStarting = g_fZero;
	g_liLand[iClient].fLandPosTop = g_fZero;

	g_liLand[iClient].iLandEntity = -1;
	g_liLand[iClient].iLandOwner = -1;
	g_liLand[iClient].iLandStage = 0;

	g_iCurrentLandEntity[iClient] = -1;
	g_iCurrentLandOwner[iClient] = -1;

	g_hGettingTop[iClient] = CreateTimer(0.1, Timer_GettingTop, GetClientUserId(iClient), TIMER_REPEAT);
	g_hLandTimer[iClient] = CreateTimer(0.1, Timer_Land, GetClientUserId(iClient), TIMER_REPEAT);
}

public void OnClientDisconnect(int iClient)
{
	g_liLand[iClient].bModeCoop = false;
	g_liLand[iClient].bModeShop = false;
	g_liLand[iClient].bModeDeathmatch = false;
	g_liLand[iClient].bLandDrawing = false;
	g_liLand[iClient].bLandGettingTopPos = false;
	g_liLand[iClient].bInDeathmatchMode = false;
	g_liLand[iClient].bInsideLand = false;
	g_liLand[iClient].bLandCreated = false;

	g_liLand[iClient].fLandPosBottom = g_fZero;
	g_liLand[iClient].fLandPosBottomTop = g_fZero;
	g_liLand[iClient].fLandGravity = 1.0;
	g_liLand[iClient].fLandPosBottomMiddle = g_fZero;
	g_liLand[iClient].fLandPosStarting = g_fZero;
	g_liLand[iClient].fLandPosTop = g_fZero;

	g_liLand[iClient].iLandEntity = -1;
	g_liLand[iClient].iLandOwner = -1;
	g_liLand[iClient].iLandStage = 0;

	g_iCurrentLandEntity[iClient] = -1;
	g_iCurrentLandOwner[iClient] = -1;

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

public void CMLand_OnConVarChanged(ConVar cvConVar, const char[] sOldValue, const char[] sNewValue)
{
	if (cvConVar == g_cvMaxLandSize)
	{
		g_fMaxLandSize = g_cvMaxLandSize.FloatValue;
		PrintToServer("|CelMod| Max land size updated to %s.", sNewValue);
	}
}

//Commands:
public Action Command_Land(int iClient, int iArgs)
{
	switch(g_liLand[iClient].iLandStage)
	{
		case 0:
		{
			Cel_GetCrosshairHitOrigin(iClient, g_liLand[iClient].fLandPosBottom);
			Cel_GetCrosshairHitOrigin(iClient, g_liLand[iClient].fLandPosStarting);

			g_liLand[iClient].bLandDrawing = true;
			g_liLand[iClient].bLandGettingTopPos = true;

			Cel_ReplyToCommand(iClient, "%t", "LandStarted");

			g_liLand[iClient].iLandStage = 1;
		}

		case 1:
		{
			g_liLand[iClient].bLandGettingTopPos = false;
			g_liLand[iClient].bLandCreated = true;

			Cel_GetMiddleOfABox(g_liLand[iClient].fLandPosBottom, g_liLand[iClient].fLandPosTop, g_liLand[iClient].fLandPosBottomMiddle);

			g_liLand[iClient].fLandPosBottomMiddle[2] = g_liLand[iClient].fLandPosBottom[2];

			Cel_CreateLand(iClient, g_liLand[iClient].fLandPosBottom, g_liLand[iClient].fLandPosTop);

			g_liLand[iClient].iLandStage = 2;

			Cel_ReplyToCommand(iClient, "%t", "LandFinished");

			TE_SetupSparks(g_liLand[iClient].fLandPosBottomMiddle, NULL_VECTOR, 150, 25);
		}

		case 2:
		{
			Cel_ClearLand(iClient);

			Cel_ReplyToCommand(iClient, "%t", "LandCleared");
		}
	}

	return Plugin_Handled;
}

public Action Command_LandDeathmatch(int iClient, int iArgs)
{
	g_liLand[iClient].bModeDeathmatch = !g_liLand[iClient].bModeDeathmatch;

	Cel_ReplyToCommand(iClient, "%t", g_liLand[iClient].bModeDeathmatch ? "DeathmatchOn" : "DeathmatchOff");

	return Plugin_Handled;
}

public Action Command_LandGravity(int iClient, int iArgs)
{
	char sGravity[64];

	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_LandGravity");
		return Plugin_Handled;
	}

	GetCmdArg(1, sGravity, sizeof(sGravity));

	Cel_SetLandGravity(iClient, StringToFloat(sGravity));

	return Plugin_Handled;
}

//Natives:
public int Native_CreateLand(Handle hPlugin, int iNumParams)
{
	float fMax[3], fLandPosMiddle[3], fMin[3];
	int iClient, iEnt;

	iClient = GetNativeCell(1);

	GetNativeArray(2, fMin, 3);
	GetNativeArray(3, fMax, 3);

	iEnt = CreateEntityByName("trigger_multiple");

	DispatchKeyValue(iEnt, "spawnflags", "64");
	DispatchKeyValue(iEnt, "wait", "0");

	DispatchSpawn(iEnt);
	ActivateEntity(iEnt);

	Cel_GetMiddleOfABox(fMin, fMax, fLandPosMiddle);

	TeleportEntity(iEnt, fLandPosMiddle, NULL_VECTOR, NULL_VECTOR);

	PrecacheModel(LAND_MODEL);
	SetEntityModel(iEnt, LAND_MODEL);

	fMin[0] = fMin[0] - fLandPosMiddle[0];
	if (fMin[0] > 0.0)
	fMin[0] *= -1.0;

	fMin[1] = fMin[1] - fLandPosMiddle[1];
	if (fMin[1] > 0.0)
	fMin[1] *= -1.0;

	fMin[2] = fMin[2] - fLandPosMiddle[2];
	if (fMin[2] > 0.0)
	fMin[2] *= -1.0;

	fMax[0] = fMax[0] - fLandPosMiddle[0];
	if (fMax[0] < 0.0)
	fMax[0] *= -1.0;

	fMax[1] = fMax[1] - fLandPosMiddle[1];
	if (fMax[1] < 0.0)
	fMax[1] *= -1.0;

	fMax[2] = fMax[2] - fLandPosMiddle[2];
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

	g_liLand[iClient].iLandEntity = iEnt;
	g_liLand[iClient].iLandOwner = iClient;

	return g_liLand[iClient].iLandEntity;
}

public int Native_ClearLand(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	g_liLand[iClient].bModeCoop = false;
	g_liLand[iClient].bModeShop = false;
	g_liLand[iClient].bModeDeathmatch = false;
	g_liLand[iClient].bLandDrawing = false;
	g_liLand[iClient].bLandGettingTopPos = false;
	g_liLand[iClient].bInDeathmatchMode = false;
	g_liLand[iClient].bInsideLand = false;
	g_liLand[iClient].bLandCreated = false;

	g_liLand[iClient].fLandPosBottom = g_fZero;
	g_liLand[iClient].fLandPosBottomTop = g_fZero;
	g_liLand[iClient].fLandGravity = 1.0;
	g_liLand[iClient].fLandPosBottomMiddle = g_fZero;
	g_liLand[iClient].fLandPosStarting = g_fZero;
	g_liLand[iClient].fLandPosTop = g_fZero;

	g_liLand[iClient].iLandEntity = -1;
	g_liLand[iClient].iLandOwner = -1;
	g_liLand[iClient].iLandStage = 0;

	AcceptEntityInput(g_liLand[iClient].iLandEntity, "kill");

	return true;
}

public int Native_DrawLandBorders(Handle hPlugin, int iNumParams)
{
	bool bFlat = view_as<bool>(GetNativeCell(5));
	float fFrom[3], fLife, fTo[3];
	int iColor[4];

	GetNativeArray(1, fFrom, 3);
	GetNativeArray(2, fTo, 3);
	fLife = view_as<float>(GetNativeCell(3));

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

public int Native_GetLandEntity(Handle hPlugin, int iNumParams)
{
	float fLandPosBottom[3], fLandPosTop[3];

	GetNativeArray(1, fLandPosBottom, 3);
	GetNativeArray(2, fLandPosTop, 3);

	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientAuthorized(i))
		{
			if(g_liLand[i].fLandPosBottom[0] == fLandPosBottom[0] && g_liLand[i].fLandPosBottom[1] == fLandPosBottom[1] && g_liLand[i].fLandPosBottom[2] == fLandPosBottom[2] && g_liLand[i].fLandPosTop[0] == fLandPosTop[0] && g_liLand[i].fLandPosTop[1] == fLandPosTop[1] && g_liLand[i].fLandPosTop[2] == fLandPosTop[2])
			{
				return g_liLand[i].iLandEntity;
			}
		}
	}

	return -1;
}

public int Native_GetLandOwner(Handle hPlugin, int iNumParams)
{
	float fLandPosBottom[3], fLandPosTop[3];

	GetNativeArray(1, fLandPosBottom, 3);
	GetNativeArray(2, fLandPosTop, 3);

	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientAuthorized(i))
		{
			if(g_liLand[i].fLandPosBottom[0] == fLandPosBottom[0] && g_liLand[i].fLandPosBottom[1] == fLandPosBottom[1] && g_liLand[i].fLandPosBottom[2] == fLandPosBottom[2] && g_liLand[i].fLandPosTop[0] == fLandPosTop[0] && g_liLand[i].fLandPosTop[1] == fLandPosTop[1] && g_liLand[i].fLandPosTop[2] == fLandPosTop[2])
			{
				return g_liLand[i].iLandOwner;
			}
		}
	}

	return -1;
}

public void Native_GetLandPositions(Handle hPlugin, int iNumParams)
{
	float fPosition[3];
	int iClient = GetNativeCell(1), iPosition = GetNativeCell(2);

	switch(iPosition)
	{
		case 1:
		{
			fPosition = g_liLand[iClient].fLandPosStarting;
		}
		case 2:
		{
			fPosition = g_liLand[iClient].fLandPosBottom;
		}
		case 3:
		{
			fPosition = g_liLand[iClient].fLandPosTop;
		}
		case 4:
		{
			fPosition = g_liLand[iClient].fLandPosBottomTop;
		}
		case 5:
		{
			fPosition = g_liLand[iClient].fLandPosBottomMiddle;
		}
	}

	SetNativeArray(3, fPosition, 3);
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

public int Native_IsClientInLand(Handle hPlugin, int iNumParams)
{
	float fOrigin[3];
	int iClient = GetNativeCell(1);

	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientAuthorized(i))
		{
			GetClientAbsOrigin(iClient, fOrigin);

			if(Cel_IsPositionInBox(fOrigin, g_liLand[i].fLandPosBottom, g_liLand[i].fLandPosTop))
			{
				SetNativeCellRef(2, g_liLand[i].iLandOwner);

				return true;
			}
		}
	}

	return false;
}

public int Native_IsClientCrosshairInLand(Handle hPlugin, int iNumParams)
{
	float fOrigin[3];
	int iClient = GetNativeCell(1);

	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientAuthorized(i))
		{
			Cel_GetCrosshairHitOrigin(iClient, fOrigin);

			fOrigin[2] += 1.0;

			if(Cel_IsPositionInBox(fOrigin, g_liLand[i].fLandPosBottom, g_liLand[i].fLandPosTop))
			{
				SetNativeCellRef(2, g_liLand[i].iLandOwner);

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

public int Native_IsEntityInLand(Handle hPlugin, int iNumParams)
{
	float fOrigin[3];
	int iEntity = GetNativeCell(1);

	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientAuthorized(i))
		{
			Entity_GetAbsOrigin(iEntity, fOrigin);

			if(Cel_IsPositionInBox(fOrigin, g_liLand[i].fLandPosBottom, g_liLand[i].fLandPosTop))
			{
				SetNativeCellRef(2, g_liLand[i].iLandOwner);

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

	GetNativeArray(1, fPos, 3);
	GetNativeArray(2, fCorner1, 3);
	GetNativeArray(3, fCorner2, 3);

	float fEntity[3];
	float fField1[2];
	float fField2[2];
	float fField3[2];

	fEntity = fPos;

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

public void Native_SetLandGravity(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	g_liLand[iClient].fLandGravity = GetNativeCell(2);
}

public any Native_GetLandGravity(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	return g_liLand[iClient].fLandGravity;
}

public int Native_GetCurrentLandEntity(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	return g_iCurrentLandEntity[iClient];
}

public int Native_GetCurrentLandOwner(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	return g_iCurrentLandOwner[iClient];
}

public void Native_SetCurrentLandEntity(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	g_iCurrentLandEntity[iClient] = GetNativeCell(2);
}

public void Native_SetCurrentLandOwner(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	g_iCurrentLandOwner[iClient] = GetNativeCell(2);
}

//Outputs:
public void EntOut_LandOnStartTouch(const char[] sOutput, int iCaller, int iActivator, float fDelay)
{
	if (iActivator < 1 || iActivator > MaxClients || !IsClientInGame(iActivator) || !IsPlayerAlive(iActivator))
	return;

	int iOwner = g_liLand[iCaller].iLandOwner;

	if(!g_liLand[iActivator].bInsideLand)
	{
		Cel_PrintToChat(iActivator, "You have entered {green}%N{default}'s land.", iOwner);
	}

	g_liLand[iActivator].bInsideLand = true;

	Cel_SetCurrentLandEntity(iActivator, g_liLand[iOwner].iLandEntity);
	Cel_SetCurrentLandOwner(iActivator, g_liLand[iOwner].iLandOwner);

	SetEntityGravity(iActivator, Cel_GetLandGravity(iOwner));

	if(g_liLand[iOwner].bModeDeathmatch)
	{
		SetEntProp(iActivator, Prop_Data, "m_takedamage", 2, 1);

		g_liLand[iActivator].bInDeathmatchMode = true;

		Cel_PrintToChat(iActivator, "This land has {red}deathmatch{default} mode enabled!");
	}
}

public void EntOut_LandOnEndTouch(const char[] sOutput, int iCaller, int iActivator, float fDelay)
{
	if (iActivator < 1 || iActivator > MaxClients || !IsClientInGame(iActivator) || !IsPlayerAlive(iActivator))
	return;

	g_liLand[iActivator].bInsideLand = false;

	Cel_SetCurrentLandEntity(iActivator, -1);
	Cel_SetCurrentLandOwner(iActivator, -1);

	SetEntityGravity(iActivator, 1.0);

	if(g_liLand[iActivator].bInDeathmatchMode)
	{
		Cel_SetNoKill(iActivator, Cel_GetNoKill(iActivator));

		g_liLand[iActivator].bInDeathmatchMode = false;
	}
}

//Timers:
public Action Timer_GettingTop(Handle hTimer, any iPlayer)
{
	int iClient = GetClientOfUserId(iPlayer);

	if(g_liLand[iClient].bLandGettingTopPos)
	{
		Cel_GetCrosshairHitOrigin(iClient, g_liLand[iClient].fLandPosBottomTop);

		Handle hTraceRay = TR_TraceRayEx(g_liLand[iClient].fLandPosBottomTop, g_fUp, MASK_ALL, RayType_Infinite);

		if (TR_DidHit(hTraceRay))
		{
			TR_GetEndPosition(g_liLand[iClient].fLandPosTop, hTraceRay);

			CloseHandle(hTraceRay);
		}

		//Thank you Instakill.
		for(int x = 0; x < 2; x++)
		{
			if(g_liLand[iClient].fLandPosBottomTop[x] > g_liLand[iClient].fLandPosBottom[x] + g_fMaxLandSize) {
				g_liLand[iClient].fLandPosBottomTop[x] = g_liLand[iClient].fLandPosBottom[x] + g_fMaxLandSize;
			}
			if(g_liLand[iClient].fLandPosTop[x] > g_liLand[iClient].fLandPosBottom[x] + g_fMaxLandSize) {
				g_liLand[iClient].fLandPosTop[x] = g_liLand[iClient].fLandPosBottom[x] + g_fMaxLandSize;
			}

			if(g_liLand[iClient].fLandPosBottomTop[x] < g_liLand[iClient].fLandPosBottom[x] - g_fMaxLandSize) {
				g_liLand[iClient].fLandPosBottomTop[x] = g_liLand[iClient].fLandPosBottom[x] - g_fMaxLandSize;
			}
			if(g_liLand[iClient].fLandPosTop[x] < g_liLand[iClient].fLandPosBottom[x] - g_fMaxLandSize) {
				g_liLand[iClient].fLandPosTop[x] = g_liLand[iClient].fLandPosBottom[x] - g_fMaxLandSize;
			}
		}
	}

	return Plugin_Continue;
}

public Action Timer_Land(Handle hTimer, any iPlayer)
{
	int iClient = GetClientOfUserId(iPlayer), iColor[4];

	Cel_GetHudColor(iClient, iColor);

	if(g_liLand[iClient].bLandDrawing)
	{
		Cel_DrawLandBorders(g_liLand[iClient].fLandPosStarting, g_liLand[iClient].fLandPosTop, 0.1, iColor, true);
	}

	return Plugin_Continue;
}
