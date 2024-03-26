#pragma semicolon 1

#include <kingssandbox>
#include <sourcemod>

#pragma newdecls required

char g_sDownloadURL[PLATFORM_MAX_PATH];
char g_sHostname[PLATFORM_MAX_PATH];

ConVar g_cvDownloadURL;
ConVar g_cvGravity;
ConVar g_cvHostname;
ConVar g_cvTimelimit;

int g_iGravity;
int g_iTimelimit;

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("KS_ReloadServerConVars", Native_ReloadServerConVars);
	
	return APLRes_Success;
}

public Plugin myinfo = 
{
	name = "King's Sandbox: Custom Server ConVars", 
	author = "King Nothing", 
	description = "Custom settings for server convars.", 
	version = SANDBOX_VERSION, 
	url = "https://github.com/rockzehh/kingssandbox"
};

public void OnPluginStart()
{
	AutoExecConfig(true, "kings-server-convars", "sourcemod");
	
	g_cvDownloadURL = CreateConVar("ks_server_downloadurl", "", "The download url for content for the server.");
	g_cvGravity = CreateConVar("ks_server_gravity", "450", "The gravity for the server.");
	g_cvHostname = CreateConVar("ks_server_hostname", "King's Sandbox", "The custom hostname for the server.");
	g_cvTimelimit = CreateConVar("ks_server_timelimit", "60", "The timelimit for the server.");
	
	g_cvDownloadURL.AddChangeHook(KSConfig_OnConVarChanged);
	g_cvGravity.AddChangeHook(KSConfig_OnConVarChanged);
	g_cvHostname.AddChangeHook(KSConfig_OnConVarChanged);
	g_cvTimelimit.AddChangeHook(KSConfig_OnConVarChanged);
	
	g_cvDownloadURL.GetString(g_sDownloadURL, sizeof(g_sDownloadURL));
	g_iGravity = g_cvGravity.IntValue;
	g_cvHostname.GetString(g_sHostname, sizeof(g_sHostname));
	g_iTimelimit = g_cvTimelimit.IntValue;
	
	KS_ReloadServerConVars();
	
	RegServerCmd("ks_reloadserverconvars", Command_ReloadServerConVars, "King's Sandbox-Server: Reloads the custom convar settings for the server.");
}

public void OnMapStart()
{
	KS_ReloadServerConVars();
}

public void KSConfig_OnConVarChanged(ConVar cvConVar, const char[] sOldValue, const char[] sNewValue)
{
	if (cvConVar == g_cvDownloadURL)
	{
		g_cvDownloadURL.GetString(g_sDownloadURL, sizeof(g_sDownloadURL));
		PrintToServer("King's Sandbox: Download URL updated to %s.", g_sDownloadURL);
		
		KS_ReloadServerConVars();
	} else if (cvConVar == g_cvGravity)
	{
		g_iGravity = g_cvGravity.IntValue;
		PrintToServer("King's Sandbox: Gravity updated to %i.", g_iGravity);
		
		KS_ReloadServerConVars();
	} else if (cvConVar == g_cvHostname)
	{
		g_cvHostname.GetString(g_sHostname, sizeof(g_sHostname));
		PrintToServer("King's Sandbox: Hostname updated to %s.", g_sHostname);
		
		KS_ReloadServerConVars();
	} else if (cvConVar == g_cvTimelimit)
	{
		g_iTimelimit = g_cvTimelimit.IntValue;
		PrintToServer("King's Sandbox: Timelimit updated to %i.", g_iTimelimit);
		
		KS_ReloadServerConVars();
	}
}

//Commands:
public Action Command_ReloadServerConVars(int iArgs)
{
	KS_ReloadServerConVars();
	
	return Plugin_Handled;
}

//Natives:
public int Native_ReloadServerConVars(Handle hPlugin, int iNumParams)
{
	ConVar cvConVar;
	
	cvConVar = FindConVar("deathmatch");
	if (cvConVar == null)
	{
		PrintToServer("King's Sandbox: ConVar 'deathmatch' not found.");
	} else {
		cvConVar.SetInt(1);
		
		PrintToServer("King's Sandbox: ConVar 'deathmatch' set to '1'.");
	}
	
	cvConVar = FindConVar("hostname");
	if (cvConVar == null)
	{
		PrintToServer("King's Sandbox: ConVar 'hostname' not found.");
	} else {
		cvConVar.SetString(g_sHostname);
		
		PrintToServer("King's Sandbox: ConVar 'hostname' set to '%s'.", g_sHostname);
	}
	
	cvConVar = FindConVar("mp_fraglimit");
	if (cvConVar == null)
	{
		PrintToServer("King's Sandbox: ConVar 'mp_fraglimit' not found.");
	} else {
		cvConVar.SetInt(0);
		
		PrintToServer("King's Sandbox: ConVar 'mp_fraglimit' set to '0'.");
	}
	
	cvConVar = FindConVar("mp_friendlyfire");
	if (cvConVar == null)
	{
		PrintToServer("King's Sandbox: ConVar 'mp_friendlyfire' not found.");
	} else {
		cvConVar.SetInt(1);
		
		PrintToServer("King's Sandbox: ConVar 'mp_friendlyfire' set to '1'.");
	}
	
	cvConVar = FindConVar("mp_teamplay");
	if (cvConVar == null)
	{
		PrintToServer("King's Sandbox: ConVar 'mp_teamplay' not found.");
	} else {
		cvConVar.SetInt(1);
		
		PrintToServer("King's Sandbox: ConVar 'mp_teamplay' set to '1'.");
	}
	
	cvConVar = FindConVar("mp_timelimit");
	if (cvConVar == null)
	{
		PrintToServer("King's Sandbox: ConVar 'mp_timelimit' not found.");
	} else {
		cvConVar.SetInt(g_iTimelimit);
		
		PrintToServer("King's Sandbox: ConVar 'mp_timelimit' set to '%i'.", g_iTimelimit);
	}
	
	cvConVar = FindConVar("mp_weaponstay");
	if (cvConVar == null)
	{
		PrintToServer("King's Sandbox: ConVar 'mp_weaponstay' not found.");
	} else {
		cvConVar.SetInt(1);
		
		PrintToServer("King's Sandbox: ConVar 'mp_weaponstay' set to '1'.");
	}
	
	cvConVar = FindConVar("sv_allowdownload");
	if (cvConVar == null)
	{
		PrintToServer("King's Sandbox: ConVar 'sv_allowdownload' not found.");
	} else {
		cvConVar.SetInt(1);
		
		PrintToServer("King's Sandbox: ConVar 'sv_allowdownload' set to '1'.");
	}
	
	cvConVar = FindConVar("sv_allowupload");
	if (cvConVar == null)
	{
		PrintToServer("King's Sandbox: ConVar 'sv_allowupload' not found.");
	} else {
		cvConVar.SetInt(1);
		
		PrintToServer("King's Sandbox: ConVar 'sv_allowupload' set to '1'.");
	}
	
	cvConVar = FindConVar("sv_downloadurl");
	if (cvConVar == null)
	{
		PrintToServer("King's Sandbox: ConVar 'sv_downloadurl' not found.");
	} else {
		cvConVar.SetString(g_sDownloadURL);
		
		PrintToServer("King's Sandbox: ConVar 'sv_downloadurl' set to '%s'.", g_sDownloadURL);
	}
	
	cvConVar = FindConVar("sv_gravity");
	if (cvConVar == null)
	{
		PrintToServer("King's Sandbox: ConVar 'sv_gravity' not found.");
	} else {
		cvConVar.SetInt(g_iGravity);
		
		PrintToServer("King's Sandbox: ConVar 'sv_gravity' set to '%i'.", g_iGravity);
	}
}
