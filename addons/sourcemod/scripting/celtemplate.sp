#pragma semicolon 1

#include <celmod>
#include <sourcemod>

#pragma newdecls required

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
	url = "https://github.com/rockzehh/celmod"
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
