#pragma semicolon 1

#include <celmod>
#include <sourcemod>

#pragma newdecls required

bool g_bDoingAnimation[MAXPLAYERS + 1];

int g_iAnimEntity[MAXPLAYERS + 1];
int g_iAnimFrame[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	return APLRes_Success;
}

public Plugin myinfo = 
{
	name = "|CelMod| Animations", 
	author = "rockzehh", 
	description = "Allows to create animations using entities.", 
	version = CEL_VERSION, 
	url = "https://github.com/rockzehh/celmod"
};

public void OnPluginStart()
{
	LoadTranslations("celanimation.phrases");
	
	RegConsoleCmd("sm_anim", Command_Animation, "Creates a animation on a selected entity.");
	RegConsoleCmd("sm_animation", Command_Animation, "Creates a animation on a selected entity.");
}

public void OnClientPutInServer(int iClient)
{
	char sAuthID[64], sPath[PLATFORM_MAX_PATH];
	
	Cel_GetAuthID(iClient, sAuthID, sizeof(sAuthID));
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/users/%s/animations", sAuthID);
	if (!DirExists(sPath))
	{
		CreateDirectory(sPath, 511);
	}
	
	g_bDoingAnimation[iClient] = false;
	
	g_iAnimEntity[iClient] = -1;
	g_iAnimFrame[iClient] = 0;
}

public void OnClientDisconnect(int iClient)
{
	g_bDoingAnimation[iClient] = false;
	
	g_iAnimEntity[iClient] = -1;
	g_iAnimFrame[iClient] = 0;
}

public Action OnPlayerRunCmd(int iClient, int &iButtons, int &iImpulse, float fVel[3], float fAngles[3], int &iWeapon, int &iSubtype, int &iCmdnum, int &iTickcount, int &iSeed, int iMouse[2])
{
	
}

//Plugin Commands:
public Action Command_Animation(int iClient, int iArgs)
{
	char sAuthID[64], sName[128], sPath[PLATFORM_MAX_PATH];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Animation");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sName, sizeof(sName));
	
	Cel_GetAuthID(iClient, sAuthID, sizeof(sAuthID));
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/users/%s/animations/%s.txt", sAuthID, sName);
	if(FileExists(sPath))
	{
		DeleteFile(sPath);
	}
	
	g_bDoingAnimation
}
