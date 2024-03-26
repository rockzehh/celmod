#pragma semicolon 1

#include <kingssandbox>
#include <sourcemod>

#pragma newdecls required

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	return APLRes_Success;
}

public Plugin myinfo = 
{
	name = "King's Sandbox: ", 
	author = "King Nothing", 
	description = "", 
	version = SANDBOX_VERSION, 
	url = "https://github.com/rockzehh/kingssandbox"
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
