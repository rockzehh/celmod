#pragma semicolon 1

#include <kingssandbox>
#include <sourcemod>

#pragma newdecls required

bool g_bHudEnable;

ConVar g_cvHudEnable;

Handle g_hHudTimer;

int g_iClientColor[MAXPLAYERS + 1][4];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("KS_ChooseHudColor", Native_ChooseHudColor);
	CreateNative("KS_GetHudColor", Native_GetHudColor);
	CreateNative("KS_SendHudMessage", Native_SendHudMessage);
	CreateNative("KS_SetHudColor", Native_SetHudColor);
	
	return APLRes_Success;
}

public Plugin myinfo = 
{
	name = "King's Sandbox: Player HUD", 
	author = "King Nothing", 
	description = "Creates and controls the custom player hud.", 
	version = SANDBOX_VERSION, 
	url = "https://github.com/rockzehh/kingssandbox"
};

public void OnPluginStart()
{
	g_cvHudEnable = CreateConVar("ks_show_hud", "1", "Shows/hides the hud for all players.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	g_cvHudEnable.AddChangeHook(KSHud_OnConVarChanged);
	
	g_bHudEnable = view_as<bool>(g_cvHudEnable.IntValue);
}

public void OnMapStart()
{
	g_hHudTimer = CreateTimer(0.1, Timer_HUD, _, TIMER_REPEAT);
}

public void OnMapEnd()
{
	CloseHandle(g_hHudTimer);
}

public void KSHud_OnConVarChanged(ConVar cvConVar, const char[] sOldValue, const char[] sNewValue)
{
	if (cvConVar == g_cvHudEnable)
	{
		g_bHudEnable = view_as<bool>(g_cvHudEnable.IntValue);
	}
}

//Natives:
public int Native_ChooseHudColor(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	switch (GetRandomInt(0, 6))
	{
		case 0:
		{
			KS_SetHudColor(iClient, 255, 0, 0, 255);
		}
		case 1:
		{
			KS_SetHudColor(iClient, 255, 128, 0, 255);
		}
		case 2:
		{
			KS_SetHudColor(iClient, 255, 255, 0, 255);
		}
		case 3:
		{
			KS_SetHudColor(iClient, 0, 255, 0, 255);
		}
		case 4:
		{
			KS_SetHudColor(iClient, 0, 0, 255, 255);
		}
		case 5:
		{
			KS_SetHudColor(iClient, 255, 0, 255, 255);
		}
		case 6:
		{
			KS_SetHudColor(iClient, 128, 0, 255, 255);
		}
	}
}

public int Native_GetHudColor(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	SetNativeArray(2, g_iClientColor[iClient], 4);
}

public int Native_SendHudMessage(Handle hPlugin, int iNumParams)
{
	char sMessage[MAX_MESSAGE_LENGTH];
	float fFadeIn = view_as<float>(GetNativeCell(10)), fFadeOut = view_as<float>(GetNativeCell(11)), fFxTime = view_as<float>(GetNativeCell(13)), 
	fHoldTime = view_as<float>(GetNativeCell(12)), fX = view_as<float>(GetNativeCell(3)), fY = view_as<float>(GetNativeCell(4));
	int iA = GetNativeCell(8), iB = GetNativeCell(7), iChannel = GetNativeCell(2), iClient = GetNativeCell(1), 
	iEffect = GetNativeCell(9), iG = GetNativeCell(6), iR = GetNativeCell(5);
	
	GetNativeString(14, sMessage, sizeof(sMessage));
	
	Handle hHudMessage = (iClient != -1) ? StartMessageOne("HudMsg", iClient) : StartMessageAll("HudMsg");
	
	if (hHudMessage != INVALID_HANDLE)
	{
		BfWriteByte(hHudMessage, iChannel);
		
		BfWriteFloat(hHudMessage, fX);
		BfWriteFloat(hHudMessage, fY);
		
		BfWriteByte(hHudMessage, iR);
		BfWriteByte(hHudMessage, iG);
		BfWriteByte(hHudMessage, iB);
		BfWriteByte(hHudMessage, iA);
		BfWriteByte(hHudMessage, iR);
		BfWriteByte(hHudMessage, iG);
		BfWriteByte(hHudMessage, iB);
		BfWriteByte(hHudMessage, iA);
		BfWriteByte(hHudMessage, iEffect);
		
		BfWriteFloat(hHudMessage, fFadeIn);
		BfWriteFloat(hHudMessage, fFadeOut);
		BfWriteFloat(hHudMessage, fHoldTime);
		BfWriteFloat(hHudMessage, fFxTime);
		
		BfWriteString(hHudMessage, sMessage);
		
		EndMessage();
	}
}

public int Native_SetHudColor(Handle hPlugin, int iNumParams)
{
	int iA = GetNativeCell(5), iB = GetNativeCell(4), iClient = GetNativeCell(1), iG = GetNativeCell(3), iR = GetNativeCell(2);
	
	g_iClientColor[iClient][0] = iR;
	g_iClientColor[iClient][1] = iG;
	g_iClientColor[iClient][2] = iB;
	g_iClientColor[iClient][3] = iA;
}

//Timers:
public Action Timer_HUD(Handle hTimer)
{
	char sBuffer[128], sBufferArray[2][128], sMessage[MAX_MESSAGE_LENGTH], sPropname[128];
	int iColor[4], iLand;
	
	if (g_bHudEnable)
	{
		for (int i = 1; i < MaxClients; i++)
		{
			if (KS_IsPlayer(i))
			{
				int iEntity = KS_GetClientAimTarget(i);
				
				if (iEntity != -1)
				{
					if(KS_IsClientCrosshairInLand(i, iLand)){
						Format(sMessage, sizeof(sMessage), "Land: %N", iLand);
						
						KS_GetHudColor(iLand, iColor);
					} else if (KS_CheckEntityCatagory(iEntity, ENTCATAGORY_PROP))
					{
						KS_GetPropName(iEntity, sPropname, sizeof(sPropname));
						
						if (KS_CheckOwner(i, iEntity))
						{
							Format(sMessage, sizeof(sMessage), "Prop: %s", sPropname);
							
							KS_GetHudColor(i, iColor);
						} else {
							Format(sMessage, sizeof(sMessage), "Owner: %N\nProp: %s", KS_GetOwner(iEntity), sPropname);
							
							KS_GetHudColor(KS_GetOwner(iEntity), iColor);
						}
					} else if (KS_CheckEntityCatagory(iEntity, ENTCATAGORY_CEL)) {
						if (KS_GetEntityType(iEntity) == ENTTYPE_EFFECT)
						{
							KS_GetEffectTypeName(KS_GetEffectType(iEntity), sPropname, sizeof(sPropname));
							
							if (KS_CheckOwner(i, iEntity))
							{
								Format(sMessage, sizeof(sMessage), "Effect: %s", sPropname);
								
								KS_GetHudColor(i, iColor);
							} else {
								Format(sMessage, sizeof(sMessage), "Owner: %N\nEffect: %s", KS_GetOwner(iEntity), sPropname);
								
								KS_GetHudColor(KS_GetOwner(iEntity), iColor);
							}
						} else {
							KS_GetEntityTypeName(KS_GetEntityType(iEntity), sBuffer, sizeof(sBuffer));
							
							ExplodeString(sBuffer, " ", sBufferArray, 2, 128, true);
							
							strcopy(sPropname, sizeof(sPropname), sBufferArray[0]);
							
							if (KS_CheckOwner(i, iEntity))
							{
								Format(sMessage, sizeof(sMessage), "Cel: %s", sPropname);
								
								KS_GetHudColor(i, iColor);
							} else {
								Format(sMessage, sizeof(sMessage), "Owner: %N\nCel: %s", KS_GetOwner(iEntity), sPropname);
								
								KS_GetHudColor(KS_GetOwner(iEntity), iColor);
							}
						}
						
					} else if (KS_CheckEntityCatagory(iEntity, ENTCATAGORY_UNKNOWN)) {
						if (KS_CheckOwner(i, iEntity))
						{
							Format(sMessage, sizeof(sMessage), "Entity: Unknown");
							
							KS_GetHudColor(i, iColor);
						} else {
							Format(sMessage, sizeof(sMessage), "Owner: %N\nEntity: Unknown", KS_GetOwner(iEntity));
							
							KS_GetHudColor(KS_GetOwner(iEntity), iColor);
						}
					} else if (KS_IsPlayer(iEntity)) {
						Format(sMessage, sizeof(sMessage), "Props Spawned: %d\nCels Spawned: %d", KS_GetPropCount(iEntity), KS_GetCelCount(iEntity));
						
						KS_GetHudColor(iEntity, iColor);
					} else {
						Format(sMessage, sizeof(sMessage), "Props Spawned: %d\nCels Spawned: %d", KS_GetPropCount(i), KS_GetCelCount(i));
						
						KS_GetHudColor(i, iColor);
					}
				} else {
					Format(sMessage, sizeof(sMessage), "Props Spawned: %d\nCels Spawned: %d", KS_GetPropCount(i), KS_GetCelCount(i));
					
					KS_GetHudColor(i, iColor);
				}
				
				KS_SendHudMessage(i, 1, 2.010, -0.110, iColor[0], iColor[1], iColor[2], iColor[3], 0, 0.6, 0.01, 0.2, 0.01, sMessage);
			}
		}
	}
}
