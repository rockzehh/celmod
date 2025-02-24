#pragma semicolon 1

#include <celmod>

#pragma newdecls required

bool g_bForSale[MAXENTITIES + 1];
bool g_bLate;

char g_sCleerModel[64];

ConVar g_cvCleerModel;

Economy g_eEconomy[MAXPLAYERS + 1];

enum Economy
{
	bool bInTrade;
	char sCleersTranslation;
	int iBalance;
}

int g_iCleerAmount[MAXENTITIES + 1];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_AddToClientBalance", Native_AddToClientBalance);
	CreateNative("Cel_BuyCommand", Native_BuyCommand);
	CreateNative("Cel_BuyObject", Native_BuyObject);
	CreateNative("Cel_CancelSale", Native_CanelSale);
	CreateNative("Cel_GetClientPurchaseStatus", Native_GetClientPurchaseStatus);
	CreateNative("Cel_CreateCleerBox", Native_CreateCleerBox);
	CreateNative("Cel_GetCleerBoxAmount", Native_GetCleerBoxAmount);
	CreateNative("Cel_GetClientBalance", Native_GetClientBalance);
	CreateNative("Cel_GetClientBalanceTranslated", Native_GetClientBalanceTranslated);
	CreateNative("Cel_IsEntityForSale", Native_IsEntityForSale);
	CreateNative("Cel_SetClientBalance", Native_SetClientBalance);
	CreateNative("Cel_SubFromClientBalance", Native_SubFromClientBalance);
	
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "|CelMod| Economy",
	author = CEL_AUTHOR,
	description = "Controls the econonmy aspects of CelMod.",
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
	
	g_cvCleerModel = CreateConVar("cm_cleer_box_model", "", "Model path for the cleers box.");
	
	g_cvCleerModel.AddChangeHook(CMEconomy_OnConVarChanged);

	g_cvCleerModel.GetString(g_sCleerModel, sizeof(g_sCleerModel));
	
	RegAdminCmd("sm_setbalance", Command_SetBalance, ADMFLAG_SLAY, "|CelMod| Sets the balance of the client you are specifing.");
	RegConsoleCmd("sm_balance", Command_Balance, "|CelMod| Gets the players current balance.");
	RegConsoleCmd("sm_buy", Command_Buy, "|CelMod| Purchases the current entity you are looking at or command you specified.");
	RegConsoleCmd("sm_give", Command_Give, "|CelMod| Gives the entity you are looking at to another client.");
	RegConsoleCmd("sm_sell", Command_Sell, "|CelMod| Sells the entity you are looking at.");
	RegConsoleCmd("sm_cl", Command_CleerBox, "|CelMod| Creates a box containing cleers that you can deposit/withdraw from.");
}

public void OnClientPutInServer(int iClient)
{
	Cel_SetClientBalance(iClient, Cel_GetClientSettingInt(iClient, "balance"));
}

public void OnClientDisconnect(int iClient)
{
	
}

public void CMHelp_OnConVarChanged(ConVar cvConVar, const char[] sOldValue, const char[] sNewValue)
{
	if (cvConVar == g_cvCleerModel)
	{
		g_cvCleerModel.GetString(g_sCleerModel, sizeof(g_sCleerModel));
		PrintToServer("|CelMod| Cleer model updated to %s.", sNewValue);
	}
}

public Action Command_SetBalance(int iClient, int iArgs)
{
	char sBalance[32], sNames[2][PLATFORM_MAX_PATH], sTarget[PLATFORM_MAX_PATH];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_SetBalance");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sBalance, sizeof(sBalance));
	GetCmdArg(2, sTarget, sizeof(sTarget));

	GetClientName(iClient, sNames[0], sizeof(sNames[]));

	if (StrEqual(sTarget, ""))
	{
		Cel_SetClientBalance(iClient, StringToInt(sBalance));
		
		Cel_ReplyToCommand(iClient, "%t", "SetBalanceClient", sNames[0], g_eEconomy[iClient].sCleerTranslation);

		return Plugin_Handled;
	}

	int iTarget = FindTarget(iClient, sTarget, true, false);

	if (iTarget == -1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CantFindTarget");
		return Plugin_Handled;
	}

	GetClientName(iTarget, sNames[1], sizeof(sNames[]));

	Cel_SetClientBalance(iTarget, StringToInt(sBalance));

	Cel_ReplyToCommand(iClient, "%t", "SetBalanceClient", sNames[1], g_eEconomy[iTarget].sCleerTranslation);

	return Plugin_Handled;
}

public Action Command_Balance(int iClient, int iArgs)
{
	Cel_ReplyToCommand(iClient, "%t", "GetBalance", g_eEconomy[iClient].sCleerTranslation);
	
	return Plugin_Handled;
}

public Action Command_Buy(int iClient, int iArgs)
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

		

		Cel_ChangeBeam(iClient, iProp);
	} else {
		Cel_NotYours(iClient, iProp);
		return Plugin_Handled;
	}

	return Plugin_Handled;
}
