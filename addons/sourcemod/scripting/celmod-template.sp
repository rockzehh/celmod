#pragma semicolon 1

#include <celmod>

#pragma newdecls required

bool g_bLate;

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	return APLRes_Success;
}

public Plugin myinfo = 
{
	name = "|CelMod| ", 
	author = CEL_AUTHOR, 
	description = "", 
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
	
}

public void OnClientDisconnect(int iClient)
{
	
}
