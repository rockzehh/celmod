#pragma semicolon 1

#include <celmod>

#pragma newdecls required

bool g_bLate;

enum Economy
{
	bool bInTrade;
	char sCleersTranslation;
	int iBalance;
}

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
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

}

public void OnClientPutInServer(int iClient)
{

}

public void OnClientDisconnect(int iClient)
{

}
