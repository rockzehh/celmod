#pragma semicolon 1

#include <celmod>

#pragma newdecls required

ArrayList g_alCommands;

bool g_bHudEnable;
bool g_bHudLeft[MAXPLAYERS + 1];

ConVar g_cvHudEnable;

Handle g_hCommandTimer;
Handle g_hHudTimer;

int g_iClientColor[MAXPLAYERS + 1][4];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_ChooseHudColor", Native_ChooseHudColor);
	CreateNative("Cel_GetHudColor", Native_GetHudColor);
	CreateNative("Cel_SendHudMessage", Native_SendHudMessage);
	CreateNative("Cel_SetHudColor", Native_SetHudColor);

	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "|CelMod| Player HUD",
	author = CEL_AUTHOR,
	description = "Creates and controls the custom player hud.",
	version = CEL_VERSION,
	url = CEL_URL
};

public void OnPluginStart()
{
	LoadTranslations("celmod.phrases");

	g_cvHudEnable = CreateConVar("cm_show_hud", "1", "Shows/hides the hud for all players.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_cvHudEnable.AddChangeHook(CMHud_OnConVarChanged);

	g_bHudEnable = view_as<bool>(g_cvHudEnable.IntValue);

	AutoExecConfig(true, "celmod.hud");

	AddCommandListener(Handle_Chat, "say");
	AddCommandListener(Handle_Chat, "say_team");

	RegConsoleCmd("v_switch", Command_Switch, "|CelMod| Switches the side the hud is on the screen.");
}

public void OnMapStart()
{
	g_hCommandTimer = CreateTimer(0.1, Timer_CommandHUD, _, TIMER_REPEAT);
	g_hHudTimer = CreateTimer(0.1, Timer_HUD, _, TIMER_REPEAT);

	g_alCommands = new ArrayList(6);
}

public void OnMapEnd()
{
	CloseHandle(g_hCommandTimer);
	CloseHandle(g_hHudTimer);

	g_alCommands.Clear();

	g_alCommands.Close();
}

public void OnClientPutInServer(int iClient)
{
	if(Cel_GetClientSettingInt(iClient, "hud-pos-left") != -1)
	{
		g_bHudLeft[iClient] = view_as<bool>(Cel_GetClientSettingInt(iClient, "hud-pos-left"));
	}else{
		Cel_SetClientSettingInt(iClient, "hud-pos-left", 0);
	}
}

public void OnClientDisconnect(int iClient)
{
	Cel_SetClientSettingInt(iClient, "hud-pos-left", view_as<int>(g_bHudLeft[iClient]));
}

public void CMHud_OnConVarChanged(ConVar cvConVar, const char[] sOldValue, const char[] sNewValue)
{
	if (cvConVar == g_cvHudEnable)
	{
		g_bHudEnable = view_as<bool>(g_cvHudEnable.IntValue);
	}
}

public Action Handle_Chat(int iClient, char[] sCommand, int iArgs)
{
	char sRealCommand[MAX_MESSAGE_LENGTH];

	GetCmdArgString(sRealCommand, sizeof(sRealCommand));

	StripQuotes(sRealCommand);

	if (sRealCommand[0] == '!')
	{
		g_alCommands.PushString(sRealCommand);

		if(g_alCommands.Length >= 6)
		{
			g_alCommands.Erase(0);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action Command_Switch(int iClient, int iArgs)
{
	g_bHudLeft[iClient] = !g_bHudLeft[iClient];

	Cel_SetClientSettingInt(iClient, "hud-pos-left", view_as<int>(g_bHudLeft[iClient]));

	Cel_ReplyToCommand(iClient, "%t", "SwitchedHUD", g_bHudLeft[iClient] ? "left" : "right");

	return Plugin_Handled;
}

//Natives:
public int Native_ChooseHudColor(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	switch (GetRandomInt(0, 6))
	{
		case 0:
		{
			Cel_SetHudColor(iClient, 255, 0, 0, 255);
		}
		case 1:
		{
			Cel_SetHudColor(iClient, 255, 128, 0, 255);
		}
		case 2:
		{
			Cel_SetHudColor(iClient, 255, 255, 0, 255);
		}
		case 3:
		{
			Cel_SetHudColor(iClient, 0, 255, 0, 255);
		}
		case 4:
		{
			Cel_SetHudColor(iClient, 0, 0, 255, 255);
		}
		case 5:
		{
			Cel_SetHudColor(iClient, 255, 0, 255, 255);
		}
		case 6:
		{
			Cel_SetHudColor(iClient, 128, 0, 255, 255);
		}
	}

	return true;
}

public int Native_GetHudColor(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	SetNativeArray(2, g_iClientColor[iClient], 4);

	return true;
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

	return true;
}

public int Native_SetHudColor(Handle hPlugin, int iNumParams)
{
	int iA = GetNativeCell(5), iB = GetNativeCell(4), iClient = GetNativeCell(1), iG = GetNativeCell(3), iR = GetNativeCell(2);

	g_iClientColor[iClient][0] = iR;
	g_iClientColor[iClient][1] = iG;
	g_iClientColor[iClient][2] = iB;
	g_iClientColor[iClient][3] = iA;

	return true;
}

//Timers:
public Action Timer_CommandHUD(Handle hTimer)
{
	char sCommands[5][MAX_MESSAGE_LENGTH], sMessage[MAX_MESSAGE_LENGTH];

	if (g_bHudEnable)
	{
		for (int i = 1; i < MaxClients; i++)
		{
			if (Cel_IsPlayer(i))
			{
				if(g_alCommands.Length >= 1) g_alCommands.GetString(0, sCommands[0], sizeof(sCommands[]));
				if(g_alCommands.Length >= 2) g_alCommands.GetString(1, sCommands[1], sizeof(sCommands[]));
				if(g_alCommands.Length >= 3) g_alCommands.GetString(2, sCommands[2], sizeof(sCommands[]));
				if(g_alCommands.Length >= 4) g_alCommands.GetString(3, sCommands[3], sizeof(sCommands[]));
				if(g_alCommands.Length >= 5) g_alCommands.GetString(4, sCommands[4], sizeof(sCommands[]));

				Format(sMessage, sizeof(sMessage), "%s\n%s\n%s\n%s\n%s", sCommands[0], sCommands[1], sCommands[2], sCommands[3], sCommands[4]);

				Cel_SendHudMessage(i, 3, 3.010, 0.0, 255, 128, 0, 255, 0, 0.6, 0.01, 0.2, 0.01, sMessage);
			}
		}
	}

	return Plugin_Continue;
}

/*public Action Timer_HUD(Handle hTimer)
{
	char sBalance[64], sBuffer[128], sBufferArray[2][128], sMessage[MAX_MESSAGE_LENGTH], sPropname[128];
	float fOrigin[3];
	int iColor[4], iLand;

	if (g_bHudEnable)
	{
		for (int i = 1; i < MaxClients; i++)
		{
			if (Cel_IsPlayer(i))
			{
				int iEntity = Cel_GetClientAimTarget(i);

				if (iEntity != -1)
				{
					if(Cel_IsEntityForSale(iEntity))
					{
						if (Cel_CheckEntityCatagory(iEntity, ENTCATAGORY_PROP))
						{
							Cel_GetPropName(iEntity, sPropname, sizeof(sPropname));

							if (Cel_CheckOwner(i, iEntity))
							{
								Format(sMessage, sizeof(sMessage), "Prop: %s\nPrice: %i", sPropname, Cel_GetEntityPrice(iEntity));

								Cel_GetHudColor(i, iColor);
							} else {
								Format(sMessage, sizeof(sMessage), "Owner: %N\nProp: %s\nPrice: %i", Cel_GetOwner(iEntity), sPropname, Cel_GetEntityPrice(iEntity));

								Cel_GetHudColor(Cel_GetOwner(iEntity), iColor);
							}
						} else if (Cel_CheckEntityCatagory(iEntity, ENTCATAGORY_CEL)) {
							if (Cel_GetEntityType(iEntity) == ENTTYPE_EFFECT)
							{
								Cel_GetEffectTypeName(Cel_GetEffectType(iEntity), sPropname, sizeof(sPropname));

								if (Cel_CheckOwner(i, iEntity))
								{
									Format(sMessage, sizeof(sMessage), "Effect: %s\nPrice: %i", sPropname, Cel_GetEntityPrice(iEntity));

									Cel_GetHudColor(i, iColor);
								} else {
									Format(sMessage, sizeof(sMessage), "Owner: %N\nEffect: %s\nPrice: %i", Cel_GetOwner(iEntity), sPropname, Cel_GetEntityPrice(iEntity));

									Cel_GetHudColor(Cel_GetOwner(iEntity), iColor);
								}
							} else {
								Cel_GetEntityTypeName(Cel_GetEntityType(iEntity), sBuffer, sizeof(sBuffer));

								ExplodeString(sBuffer, " ", sBufferArray, 2, 128, true);

								strcopy(sPropname, sizeof(sPropname), sBufferArray[0]);

								if (Cel_CheckOwner(i, iEntity))
								{
									Format(sMessage, sizeof(sMessage), "Cel: %s\nPrice: %i", sPropname, Cel_GetEntityPrice(iEntity));

									Cel_GetHudColor(i, iColor);
								} else {
									Format(sMessage, sizeof(sMessage), "Owner: %N\nCel: %s\nPrice: %i", Cel_GetOwner(iEntity), sPropname, Cel_GetEntityPrice(iEntity));

									Cel_GetHudColor(Cel_GetOwner(iEntity), iColor);
								}
							}

						} else if (Cel_CheckEntityCatagory(iEntity, ENTCATAGORY_UNKNOWN)) {
							if (Cel_CheckOwner(i, iEntity))
							{
								Format(sMessage, sizeof(sMessage), "Cel: ???\nPrice: %i", Cel_GetEntityPrice(iEntity));

								Cel_GetHudColor(i, iColor);
							} else {
								Format(sMessage, sizeof(sMessage), "Owner: %N\nCel: ???\nPrice: %i", Cel_GetOwner(iEntity), Cel_GetEntityPrice(iEntity));

								Cel_GetHudColor(Cel_GetOwner(iEntity), iColor);
							}
						}
					}else{
						if (Cel_CheckEntityCatagory(iEntity, ENTCATAGORY_PROP))
						{
							Cel_GetPropName(iEntity, sPropname, sizeof(sPropname));

							if (Cel_CheckOwner(i, iEntity))
							{
								Format(sMessage, sizeof(sMessage), "Prop: %s", sPropname);

								Cel_GetHudColor(i, iColor);
							} else {
								Format(sMessage, sizeof(sMessage), "Owner: %N\nProp: %s", Cel_GetOwner(iEntity), sPropname);

								Cel_GetHudColor(Cel_GetOwner(iEntity), iColor);
							}
						} else if (Cel_CheckEntityCatagory(iEntity, ENTCATAGORY_CEL)) {
							if (Cel_GetEntityType(iEntity) == ENTTYPE_EFFECT)
							{
								Cel_GetEffectTypeName(Cel_GetEffectType(iEntity), sPropname, sizeof(sPropname));

								if (Cel_CheckOwner(i, iEntity))
								{
									Format(sMessage, sizeof(sMessage), "Effect: %s", sPropname);

									Cel_GetHudColor(i, iColor);
								} else {
									Format(sMessage, sizeof(sMessage), "Owner: %N\nEffect: %s", Cel_GetOwner(iEntity), sPropname);

									Cel_GetHudColor(Cel_GetOwner(iEntity), iColor);
								}
							} else {
								Cel_GetEntityTypeName(Cel_GetEntityType(iEntity), sBuffer, sizeof(sBuffer));

								ExplodeString(sBuffer, " ", sBufferArray, 2, 128, true);

								strcopy(sPropname, sizeof(sPropname), sBufferArray[0]);

								if (Cel_CheckOwner(i, iEntity))
								{
									Format(sMessage, sizeof(sMessage), "Cel: %s", sPropname);

									Cel_GetHudColor(i, iColor);
								} else {
									Format(sMessage, sizeof(sMessage), "Owner: %N\nCel: %s", Cel_GetOwner(iEntity), sPropname);

									Cel_GetHudColor(Cel_GetOwner(iEntity), iColor);
								}
							}

						} else if (Cel_CheckEntityCatagory(iEntity, ENTCATAGORY_UNKNOWN)) {
							if (Cel_CheckOwner(i, iEntity))
							{
								Format(sMessage, sizeof(sMessage), "Entity: Unknown");

								Cel_GetHudColor(i, iColor);
							} else {
								Format(sMessage, sizeof(sMessage), "Owner: %N\nCel: ???", Cel_GetOwner(iEntity));

								Cel_GetHudColor(Cel_GetOwner(iEntity), iColor);
							}
						}
					}
					if (Cel_IsPlayer(iEntity)) {
						Cel_GetClientBalanceTranslated(iEntity, sBalance, sizeof(sBalance));

						Format(sMessage, sizeof(sMessage), "%N\nBalance: %s | Spawned: %d", iEntity, sBalance, Cel_GetCombinedCount(iEntity));

						Cel_GetHudColor(iEntity, iColor);
					} else {
						Cel_GetClientBalanceTranslated(i, sBalance, sizeof(sBalance));

						Format(sMessage, sizeof(sMessage), "Balance: %s\nSpawned: %d", sBalance, Cel_GetCombinedCount(i));

						Cel_GetHudColor(i, iColor);
					}
				} else if(Cel_IsClientCrosshairInLand(i)){
				}else {
					Cel_GetCrosshairHitOrigin(i, fOrigin);

					iLand = Cel_GetLandOwnerFromPosition(fOrigin);

					if(iLand != -1)
					{
						Format(sMessage, sizeof(sMessage), "Land: %N", iLand);

						Cel_GetHudColor(iLand, iColor);
					}else{
						Cel_GetClientBalanceTranslated(i, sBalance, sizeof(sBalance));

						Format(sMessage, sizeof(sMessage), "Balance: %s\nSpawned: %d", sBalance, Cel_GetCombinedCount(i));

						Cel_GetHudColor(i, iColor);
					}
				}

				Cel_SendHudMessage(i, 1, 2.010, -0.110, iColor[0], iColor[1], iColor[2], iColor[3], 0, 0.6, 0.01, 0.2, 0.01, sMessage);
			}
		}
	}

	return Plugin_Continue;
}*/

public Action Timer_HUD(Handle hTimer)
{
	char sBalance[32], sCelBuffer[64], sCelBufferArray[2][64], sHUDMessage[MAX_MESSAGE_LENGTH], sPropName[64];
	float fCrosshairOrigin[3];
	int iEntity, iHUDColor[4], iLandOwner;

	if (g_bHudEnable)
	{
		for (int i = 1; i < MaxClients; i++)
		{
			if (Cel_IsPlayer(i))
			{
				iEntity = Cel_GetClientAimTarget(i);

				if (iEntity != -1)
				{
					if (Cel_CheckEntityCatagory(iEntity, ENTCATAGORY_PROP))
					{
						Cel_GetPropName(iEntity, sPropName, sizeof(sPropName));

						if (Cel_CheckOwner(i, iEntity))
						{
							Format(sHUDMessage, sizeof(sHUDMessage), "Prop: %s", sPropName);

							Cel_GetHudColor(i, iHUDColor);
						} else {
							Format(sHUDMessage, sizeof(sHUDMessage), "Owner: %N\nProp: %s", Cel_GetOwner(iEntity), sPropName);

							Cel_GetHudColor(Cel_GetOwner(iEntity), iHUDColor);
						}
					} else if (Cel_CheckEntityCatagory(iEntity, ENTCATAGORY_CEL)) {
						if (Cel_GetEntityType(iEntity) == ENTTYPE_EFFECT)
						{
							Cel_GetEffectTypeName(Cel_GetEffectType(iEntity), sPropName, sizeof(sPropName));

							if (Cel_CheckOwner(i, iEntity))
							{
								Format(sHUDMessage, sizeof(sHUDMessage), "Effect: %s", sPropName);

								Cel_GetHudColor(i, iHUDColor);
							} else {
								Format(sHUDMessage, sizeof(sHUDMessage), "Owner: %N\nEffect: %s", Cel_GetOwner(iEntity), sPropName);

								Cel_GetHudColor(Cel_GetOwner(iEntity), iHUDColor);
							}
						} else {
							Cel_GetEntityTypeName(Cel_GetEntityType(iEntity), sCelBuffer, sizeof(sCelBuffer));

							ExplodeString(sCelBuffer, " ", sCelBufferArray, 2, 128, true);

							strcopy(sPropName, sizeof(sPropName), sCelBufferArray[0]);

							if (Cel_CheckOwner(i, iEntity))
							{
								Format(sHUDMessage, sizeof(sHUDMessage), "Cel: %s", sPropName);

								Cel_GetHudColor(i, iHUDColor);
							} else {
								Format(sHUDMessage, sizeof(sHUDMessage), "Owner: %N\nCel: %s", Cel_GetOwner(iEntity), sPropName);

								Cel_GetHudColor(Cel_GetOwner(iEntity), iHUDColor);
							}
						}

					} else if (Cel_CheckEntityCatagory(iEntity, ENTCATAGORY_UNKNOWN)) {
						if (Cel_CheckOwner(i, iEntity))
						{
							Format(sHUDMessage, sizeof(sHUDMessage), "Cel: %s", "???");

							Cel_GetHudColor(i, iHUDColor);
						} else {
							Format(sHUDMessage, sizeof(sHUDMessage), "Owner: %N\nCel: %s", Cel_GetOwner(iEntity), "???");

							Cel_GetHudColor(Cel_GetOwner(iEntity), iHUDColor);
						}
					}else if (Cel_IsPlayer(iEntity)) {
						Cel_GetClientBalanceTranslated(iEntity, sBalance, sizeof(sBalance));

						Format(sHUDMessage, sizeof(sHUDMessage), "%N\nBalance: %s | Spawned: %d", iEntity, sBalance, Cel_GetCombinedCount(iEntity));

						Cel_GetHudColor(iEntity, iHUDColor);
					}
				} else if(Cel_IsClientCrosshairInLand(i)){
					Cel_GetCrosshairHitOrigin(i, fCrosshairOrigin);

					iLandOwner = Cel_GetLandOwnerFromPosition(fCrosshairOrigin);

					if(iLandOwner != -1 && iLandOwner != i)
					{
						Format(sHUDMessage, sizeof(sHUDMessage), "Land: %N", iLandOwner);

						Cel_GetHudColor(iLandOwner, iHUDColor);
					}else{
						Cel_GetClientBalanceTranslated(i, sBalance, sizeof(sBalance));

						Format(sHUDMessage, sizeof(sHUDMessage), "Balance: %s\nSpawned: %d", sBalance, Cel_GetCombinedCount(i));

						Cel_GetHudColor(i, iHUDColor);
					}
				}else{
					Cel_GetClientBalanceTranslated(i, sBalance, sizeof(sBalance));

					Format(sHUDMessage, sizeof(sHUDMessage), "Balance: %s\nSpawned: %d", sBalance, Cel_GetCombinedCount(i));

					Cel_GetHudColor(i, iHUDColor);
				}

				Cel_SendHudMessage(i, 1, g_bHudLeft[i] ? -2.010 : 2.010, -0.110, iHUDColor[0], iHUDColor[1], iHUDColor[2], iHUDColor[3], 0, 0.6, 0.01, 0.2, 0.01, sHUDMessage);
			}
		}
	}

	return Plugin_Continue;
}
