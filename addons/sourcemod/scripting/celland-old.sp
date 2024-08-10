#pragma semicolon 1

#include <celmod>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma newdecls required

ConVar g_cvMaxLandSize;

float g_fLandCorners[MAXPLAYERS + 1][2][3];
float g_fMaxLandSize;

Handle g_hInLand;
Handle g_hLandDrawing;
Handle g_hPositions;

int g_iLand;
int g_iLandPhase[MAXPLAYERS + 1][3];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_CalculateLandCorners", Native_CalculateLandCorners);
	CreateNative("Cel_CalculateMaxLandSize", Native_CalculateMaxLandSize);
	CreateNative("Cel_GetLandMaterial", Native_GetLandMaterial);
	CreateNative("Cel_GetLandPhase", Native_GetLandPhase);
	CreateNative("Cel_GetLandPosition", Native_GetLandPosition);
	CreateNative("Cel_IsClientInsideLand", Native_IsClientInsideLand);
	CreateNative("Cel_IsCrosshairInsideLand", Native_IsCrosshairInsideLand);
	CreateNative("Cel_IsEntityInsideLand", Native_IsEntityInsideLand);
	CreateNative("Cel_IsOriginInsideArea", Native_IsOriginInsideArea);
	CreateNative("Cel_SetLandPhase", Native_SetLandPhase);
	CreateNative("Cel_SetLandPosition", Native_SetLandPosition);
	
	return APLRes_Success;
}

public Plugin myinfo = 
{
	name = "|CelMod| Land", 
	author = "rockzehh", 
	description = "Creates a personal building area.", 
	version = CEL_VERSION, 
	url = "https://github.com/rockzehh/celmod"
};

public void OnPluginStart()
{
	g_cvMaxLandSize = CreateConVar("cm_max_land_size", "100.0", "The max size lands can be.");
	
	g_cvMaxLandSize.AddChangeHook(CelLand_OnConVarChanged);
	
	g_fMaxLandSize = g_cvMaxLandSize.FloatValue;
	
	RegConsoleCmd("sm_land", Command_Land, "Creates a building zone.");
	
	AutoExecConfig(true, "cel-land", "sourcemod");
}

public void OnMapStart()
{
	g_hInLand = CreateTimer(0.1, Timer_InLand, _, TIMER_REPEAT);
	g_hLandDrawing = CreateTimer(0.1, Timer_LandDrawing, _, TIMER_REPEAT);
	
	g_hPositions = CreateTimer(0.1, Timer_Positions, _, TIMER_REPEAT);
	
	g_iLand = PrecacheModel("materials/sprites/spotlight.vmt", false);
}

public void OnMapEnd()
{
	CloseHandle(g_hInLand);
	CloseHandle(g_hLandDrawing);
	CloseHandle(g_hPositions);
	
	g_iLand = -1;
}

public void CelLand_OnConVarChanged(ConVar cvConVar, const char[] sOldValue, const char[] sNewValue)
{
	if (cvConVar == g_cvMaxLandSize)
	{
		g_fMaxLandSize = g_cvMaxLandSize.FloatValue;
		PrintToServer("King's Sandbox: Max land size updated to %s.", sNewValue);
	}
}

//Commands:
public Action Command_Land(int iClient, int iArgs)
{
	bool bDidHitTop = false;
	float fOrigin[3];
	
	switch (g_iLandPhase[iClient][0])
	{
		case 0:
		{
			if (Cel_IsCrosshairInsideLand(iClient) != -1)
			{
				if (Cel_IsCrosshairInsideLand(iClient) != iClient)
				{
					Cel_ReplyToCommand(iClient, "You cannot start your land inside another land.");
					return Plugin_Handled;
				}
			}
			
			Cel_SetLandPhase(iClient, 0, 1);
			Cel_SetLandPhase(iClient, 1, 1);
			Cel_SetLandPhase(iClient, 2, 0);
			
			Cel_GetCrosshairHitOrigin(iClient, g_fLandCorners[iClient][0]);
			
			fOrigin = g_fLandCorners[iClient][3];
			
			for (int i = 0; i < 33500; i++)
			{
				if (bDidHitTop)
				{
					g_fLandCorners[iClient][5] = fOrigin;
				} else {
					g_fLandCorners[iClient][5][2] += 1;
					
					if (TR_PointOutsideWorld(fOrigin))
					{
						fOrigin[2] -= 2;
						
						bDidHitTop = true;
						
						g_fLandCorners[iClient][5] = fOrigin;
					}
				}
			}
			
			Cel_ReplyToCommand(iClient, "Type {green}[tag]land{default} again to complete the land.");
			
			return Plugin_Handled;
		}
		
		case 1:
		{
			if (Cel_IsCrosshairInsideLand(iClient) != -1)
			{
				if (Cel_IsCrosshairInsideLand(iClient) != iClient)
				{
					Cel_ReplyToCommand(iClient, "You cannot finish your land inside another land.");
					return Plugin_Handled;
				}
			}
			
			Cel_SetLandPhase(iClient, 0, 2);
			Cel_SetLandPhase(iClient, 1, 0);
			
			Cel_ReplyToCommand(iClient, "Land completed.");
		}
		
		case 2:
		{
			Cel_SetLandPhase(iClient, 0, 0);
			Cel_SetLandPhase(iClient, 1, 0);
			Cel_SetLandPhase(iClient, 2, 0);
			
			Cel_SetLandPosition(iClient, 0, Cel_GetZeroVector());
			Cel_SetLandPosition(iClient, 1, Cel_GetZeroVector());
			Cel_SetLandPosition(iClient, 2, Cel_GetZeroVector());
			Cel_SetLandPosition(iClient, 3, Cel_GetZeroVector());
			Cel_SetLandPosition(iClient, 4, Cel_GetZeroVector());
			Cel_SetLandPosition(iClient, 5, Cel_GetZeroVector());
			
			Cel_ReplyToCommand(iClient, "Land cleared.");
		}
	}
	
	return Plugin_Handled;
}

//Natives:
public int Native_CalculateLandCorners(Handle hPlugin, int iNumParams)
{
	float fFrom[3], fTo[3];
	int iClient = GetNativeCell(1);
	
	GetNativeArray(2, fFrom, 3);
	GetNativeArray(3, fTo, 3);
	
	//Left Top Front
	g_fLandCorners[iClient][0][0] = fFrom[0];
	g_fLandCorners[iClient][0][1] = fFrom[1];
	g_fLandCorners[iClient][0][2] = fFrom[2] + 3;
	
	
	//Right Top Front
	g_fLandCorners[iClient][1][0] = fTo[0];
	g_fLandCorners[iClient][1][1] = fFrom[1];
	g_fLandCorners[iClient][1][2] = fFrom[2] + 3;
	
	
	//Left Top Back
	g_fLandCorners[iClient][2][0] = fFrom[0];
	g_fLandCorners[iClient][2][1] = fTo[1];
	g_fLandCorners[iClient][2][2] = fFrom[2] + 3;
	
	
	//Right Top Back
	g_fLandCorners[iClient][3][0] = fTo[0];
	g_fLandCorners[iClient][3][1] = fTo[1];
	g_fLandCorners[iClient][3][2] = fFrom[2] + 3;
	
	return true;
}

public int Native_CalculateMaxLandSize(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	for (int x = 0; x < 2; x++) {
		if (g_fLandCorners[iClient][2][x] > g_fLandCorners[iClient][0][x] + g_fMaxLandSize) {
			g_fLandCorners[iClient][2][x] = g_fLandCorners[iClient][0][x] + g_fMaxLandSize;
		}
		if (g_fLandCorners[iClient][3][x] > g_fLandCorners[iClient][0][x] + g_fMaxLandSize) {
			g_fLandCorners[iClient][3][x] = g_fLandCorners[iClient][0][x] + g_fMaxLandSize;
		}
		
		if (g_fLandCorners[iClient][2][x] < g_fLandCorners[iClient][0][x] - g_fMaxLandSize) {
			g_fLandCorners[iClient][2][x] = g_fLandCorners[iClient][0][x] - g_fMaxLandSize;
		}
		if (g_fLandCorners[iClient][3][x] < g_fLandCorners[iClient][0][x] - g_fMaxLandSize) {
			g_fLandCorners[iClient][3][x] = g_fLandCorners[iClient][0][x] - g_fMaxLandSize;
		}
	}
	
	return true;
}

public int Native_GetLandMaterial(Handle hPlugin, int iNumParams)
{
	return g_iLand;
}

public int Native_GetLandPhase(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1), iPhase = GetNativeCell(2);
	
	return g_iLandPhase[iClient][iPhase];
}

public int Native_GetLandPosition(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1), iCorner = GetNativeCell(2);
	
	SetNativeArray(3, g_fLandCorners[iClient][iCorner], 3);
	
	return true;
}

public int Native_IsClientInsideLand(Handle hPlugin, int iNumParams)
{
	float fOrigin[3];
	int iClient = GetNativeCell(1);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (g_iLandPhase[i][2] == 0)continue;
		
		if (iClient != 0)
		{
			GetClientAbsOrigin(iClient, fOrigin);
			
			if (Cel_IsOriginInsideArea(fOrigin, g_fLandCorners[i][0], g_fLandCorners[i][1]))return i;
		}
	}
	
	return -1;
}

public int Native_IsCrosshairInsideLand(Handle hPlugin, int iNumParams)
{
	float fOrigin[3];
	int iClient = GetNativeCell(1);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (g_iLandPhase[i][2] == 0)continue;
		
		if (iClient != 0)
		{
			Cel_GetCrosshairHitOrigin(iClient, fOrigin);
			
			if (Cel_IsOriginInsideArea(fOrigin, g_fLandCorners[i][0], g_fLandCorners[i][1]))return i;
		}
	}
	
	return -1;
}


public int Native_IsEntityInsideLand(Handle hPlugin, int iNumParams)
{
	float fOrigin[3];
	int iEntity = GetNativeCell(1);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))continue;
		
		if (g_iLandPhase[i][2] == 0)continue;
		
		if (Cel_IsEntity(iEntity))
		{
			Cel_GetEntityOrigin(iEntity, fOrigin);
			
			if (Cel_IsOriginInsideArea(fOrigin, g_fLandCorners[i][0], g_fLandCorners[i][1]))return i;
		}
	}
	
	return -1;
}

public int Native_IsOriginInsideArea(Handle hPlugin, int iNumParams)
{
	bool bX = false, bY = false, bZ = false;
	float fCorner[2][3], fOrigin[3];
	
	GetNativeArray(1, fOrigin, 3);
	GetNativeArray(2, fCorner[0], 3);
	GetNativeArray(3, fCorner[1], 3);
	
	if (fCorner[0][0] > fCorner[1][0] && fOrigin[0] <= fCorner[0][0] && fOrigin[0] >= fCorner[1][0])
	{
		bX = true;
	}
	else if (fCorner[0][0] < fCorner[1][0] && fOrigin[0] >= fCorner[0][0] && fOrigin[0] <= fCorner[1][0])
	{
		bX = true;
	}
	
	if (fCorner[0][1] > fCorner[1][1] && fOrigin[1] <= fCorner[0][1] && fOrigin[1] >= fCorner[1][1])
	{
		bY = true;
	}
	else if (fCorner[0][1] < fCorner[1][1] && fOrigin[1] >= fCorner[0][1] && fOrigin[1] <= fCorner[1][1])
	{
		bY = true;
	}
	
	if (fCorner[0][2] > fCorner[1][2] && fOrigin[2] <= fCorner[0][2] && fOrigin[2] >= fCorner[1][2])
	{
		bZ = true;
	}
	else if (fCorner[0][2] < fCorner[1][2] && fOrigin[2] >= fCorner[0][2] && fOrigin[2] <= fCorner[1][2])
	{
		bZ = true;
	}
	
	if (bX && bY && bZ)
	{
		return true;
	}
	
	return false;
}


//0 = , 1 = , 2 = In Land
public int Native_SetLandPhase(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1), iPhase = GetNativeCell(2), iPhaseNumber = GetNativeCell(3);
	
	g_iLandPhase[iClient][iPhase] = iPhaseNumber;
	
	return true;
}

public int Native_SetLandPosition(Handle hPlugin, int iNumParams)
{
	float fPosition[3];
	int iClient = GetNativeCell(1), iCorner = GetNativeCell(2);
	
	GetNativeArray(3, fPosition, 3);
	
	g_fLandCorners[iClient][iCorner] = fPosition;
	
	return true;
}

//Timers:
public Action Timer_LandDrawing(Handle hTimer)
{
	int iColor[4];
	
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientConnected(i) && Cel_IsPlayer(i) /*&& g_iLandPhase[i][2] == 1*/)
		{
			Cel_GetHudColor(i, iColor);
			
			TE_SetupBeamPoints(g_fLandCorners[i][0], g_fLandCorners[i][1], g_iLand, 0, 0, 0, 0.1, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
			TE_SetupBeamPoints(g_fLandCorners[i][0], g_fLandCorners[i][2], g_iLand, 0, 0, 0, 0.1, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
			TE_SetupBeamPoints(g_fLandCorners[i][1], g_fLandCorners[i][2], g_iLand, 0, 0, 0, 0.1, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
			TE_SetupBeamPoints(g_fLandCorners[i][3], g_fLandCorners[i][1], g_iLand, 0, 0, 0, 0.1, 3.0, 3.0, 10, 0.0, iColor, 0); TE_SendToAll(0.0);
		}
	}
	
	return Plugin_Continue;
}

public Action Timer_InLand(Handle hTimer)
{
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientConnected(i) && Cel_IsPlayer(i))
		{
			int iLand = Cel_IsClientInsideLand(i);
			
			if (iLand != -1)
			{
				if (g_iLandPhase[i][2] == 0)
				{
					Cel_PrintToChat(i, "You have entered {green}%N{default}'s land.", iLand);
					g_iLandPhase[i][2] = 1;
				}
			} else {
				g_iLandPhase[i][2] = 0;
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Timer_Positions(Handle hTimer)
{
	float fOrigin[3];
	
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientConnected(i) && Cel_IsPlayer(i) && g_iLandPhase[i][1] == 1)
		{
			Cel_GetCrosshairHitOrigin(i, fOrigin);
			
			Cel_CalculateLandCorners(i, g_fLandCorners[i][4], fOrigin);
			Cel_CalculateMaxLandSize(i);
		}
	}
	
	return Plugin_Continue;
}
