#pragma semicolon 1

#include <celmod>

#pragma newdecls required

bool g_bLate;

char g_sClientPurchases[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
char g_sClientSettings[MAXPLAYERS + 1][PLATFORM_MAX_PATH];

KeyValues g_kvClientPurchases[MAXPLAYERS + 1];
KeyValues g_kvClientSettings[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_CheckClientPurchase", Native_CheckClientPurchase);
	CreateNative("Cel_CreateClientPurchases", Native_CreateClientPurchases);
	CreateNative("Cel_CreateClientSettings", Native_CreateClientSettings);
	CreateNative("Cel_GetClientSettingFloat", Native_GetClientSettingFloat);
	CreateNative("Cel_GetClientSettingInt", Native_GetClientSettingInt);
	CreateNative("Cel_GetClientSettingString", Native_GetClientSettingString);
	CreateNative("Cel_RemoveClientPurchase", Native_RemoveClientPurchase);
	CreateNative("Cel_SaveClientPurchase", Native_SaveClientPurchase);
	CreateNative("Cel_SetClientSettingFloat", Native_SetClientSettingFloat);
	CreateNative("Cel_SetClientSettingInt", Native_SetClientSettingInt);
	CreateNative("Cel_SetClientSettingString", Native_SetClientSettingString);

	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "|CelMod| Client Storage",
	author = CEL_AUTHOR,
	description = "Handles all client storage, excluding save/loading.",
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
}

public void OnClientPutInServer(int iClient)
{
	char sAuthID[64];
	
	g_kvClientPurchases[iClient] = new KeyValues("Vault");
	g_kvClientSettings[iClient] = new KeyValues("Vault");

	Cel_GetAuthID(iClient, sAuthID, sizeof(sAuthID));

	BuildPath(Path_SM, g_sClientPurchases[iClient], sizeof(g_sClientPurchases[]), "data/celmod/users/%s/purchases.txt", sAuthID);
	if (!FileExists(g_sClientPurchases[iClient]))
	{
		Cel_CreateClientPurchases(iClient);
	}

	BuildPath(Path_SM, g_sClientSettings[iClient], sizeof(g_sClientSettings[]), "data/celmod/users/%s/settings.txt", sAuthID);
	if (!FileExists(g_sClientSettings[iClient]))
	{
		Cel_CreateClientSettings(iClient);
	}
}

public void OnClientDisconnect(int iClient)
{
	g_kvClientPurchases[iClient].Close();
	g_kvClientSettings[iClient].Close();
}

//Natives:
public any Native_CheckClientPurchase(Handle hPlugin, int iNumParams)
{
	char sPurchase[64];
	int iClient = GetNativeCell(1);

	GetNativeString(2, sPurchase, sizeof(sPurchase));

	g_kvClientPurchases[iClient].ImportFromFile(g_sClientPurchases[iClient]);

	g_kvClientPurchases[iClient].JumpToKey("Purchases");

	bool bHasPurchase = view_as<bool>(g_kvClientPurchases[iClient].GetNum(sPurchase, 0));

	g_kvClientPurchases[iClient].Rewind();

	return bHasPurchase;
}

public void Native_CreateClientPurchases(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	g_kvClientPurchases[iClient].ImportFromFile(g_sClientPurchases[iClient]);

	g_kvClientPurchases[iClient].JumpToKey("Purchases", true);

	g_kvClientPurchases[iClient].Rewind();

	g_kvClientPurchases[iClient].ExportToFile(g_sClientPurchases[iClient]);
}

public void Native_CreateClientSettings(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);

	g_kvClientSettings[iClient].ImportFromFile(g_sClientSettings[iClient]);

	g_kvClientSettings[iClient].JumpToKey("Settings", true);

	g_kvClientSettings[iClient].Rewind();

	g_kvClientSettings[iClient].ExportToFile(g_sClientSettings[iClient]);
}

public any Native_GetClientSettingFloat(Handle hPlugin, int iNumParams)
{
	char sSetting[64];
	int iClient = GetNativeCell(1);

	GetNativeString(2, sSetting, sizeof(sSetting));

	g_kvClientSettings[iClient].ImportFromFile(g_sClientSettings[iClient]);

	g_kvClientSettings[iClient].JumpToKey("Settings", true);

	float fValue = g_kvClientSettings[iClient].GetFloat(sSetting, 0.0);

	g_kvClientSettings[iClient].Rewind();

	return fValue;
}

public int Native_GetClientSettingInt(Handle hPlugin, int iNumParams)
{
	char sSetting[64];
	int iClient = GetNativeCell(1);

	GetNativeString(2, sSetting, sizeof(sSetting));

	g_kvClientSettings[iClient].ImportFromFile(g_sClientSettings[iClient]);

	g_kvClientSettings[iClient].JumpToKey("Settings", true);

	int iValue = g_kvClientSettings[iClient].GetNum(sSetting, 0);

	g_kvClientSettings[iClient].Rewind();

	return iValue;
}

public void Native_GetClientSettingString(Handle hPlugin, int iNumParams)
{
	char sSetting[64], sValue[128];
	int iClient = GetNativeCell(1), iMaxLength = GetNativeCell(4);

	GetNativeString(2, sSetting, sizeof(sSetting));

	g_kvClientSettings[iClient].ImportFromFile(g_sClientSettings[iClient]);

	g_kvClientSettings[iClient].JumpToKey("Settings", true);

	g_kvClientSettings[iClient].GetString(sSetting, sValue, iMaxLength, "none");

	g_kvClientSettings[iClient].Rewind();

	SetNativeString(3, sValue, iMaxLength);
}

public void Native_RemoveClientPurchase(Handle hPlugin, int iNumParams)
{
	char sPurchase[64];
	int iClient = GetNativeCell(1);

	GetNativeString(2, sPurchase, sizeof(sPurchase));

	g_kvClientPurchases[iClient].ImportFromFile(g_sClientPurchases[iClient]);

	g_kvClientPurchases[iClient].JumpToKey("Purchases");

	g_kvClientPurchases[iClient].SetNum(sPurchase, 0);

	g_kvClientPurchases[iClient].Rewind();

	g_kvClientPurchases[iClient].ExportToFile(g_sClientPurchases[iClient]);
}

public void Native_SaveClientPurchase(Handle hPlugin, int iNumParams)
{
	char sPurchase[64];
	int iClient = GetNativeCell(1);

	g_kvClientPurchases[iClient].ImportFromFile(g_sClientPurchases[iClient]);

	g_kvClientPurchases[iClient].JumpToKey("Purchases", true);

	g_kvClientPurchases[iClient].SetNum(sPurchase, view_as<int>(GetNativeCell(3)));

	g_kvClientPurchases[iClient].Rewind();

	g_kvClientPurchases[iClient].ExportToFile(g_sClientPurchases[iClient]);
}

public void Native_SetClientSettingFloat(Handle hPlugin, int iNumParams)
{
	char sSetting[64];
	int iClient = GetNativeCell(1);

	GetNativeString(2, sSetting, sizeof(sSetting));

	g_kvClientSettings[iClient].ImportFromFile(g_sClientSettings[iClient]);

	g_kvClientSettings[iClient].JumpToKey("Settings", true);

	g_kvClientSettings[iClient].SetFloat(sSetting, GetNativeCell(3));

	g_kvClientSettings[iClient].Rewind();

	g_kvClientSettings[iClient].ExportToFile(g_sClientSettings[iClient]);
}

public void Native_SetClientSettingInt(Handle hPlugin, int iNumParams)
{
	char sSetting[64];
	int iClient = GetNativeCell(1);

	GetNativeString(2, sSetting, sizeof(sSetting));

	g_kvClientSettings[iClient].ImportFromFile(g_sClientSettings[iClient]);

	g_kvClientSettings[iClient].JumpToKey("Settings", true);

	g_kvClientSettings[iClient].SetNum(sSetting, GetNativeCell(3));

	g_kvClientSettings[iClient].Rewind();

	g_kvClientSettings[iClient].ExportToFile(g_sClientSettings[iClient]);
}

public void Native_SetClientSettingString(Handle hPlugin, int iNumParams)
{
	char sSetting[64], sValue[128];
	int iClient = GetNativeCell(1);

	GetNativeString(2, sSetting, sizeof(sSetting));

	g_kvClientSettings[iClient].ImportFromFile(g_sClientSettings[iClient]);

	g_kvClientSettings[iClient].JumpToKey("Settings", true);

	g_kvClientSettings[iClient].SetString(sSetting, sValue);

	g_kvClientSettings[iClient].Rewind();

	g_kvClientSettings[iClient].ExportToFile(g_sClientSettings[iClient]);
}
