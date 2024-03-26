#pragma semicolon 1

#include <kingssandbox>
#include <sourcemod>

#pragma newdecls required

char g_sColorListURL[PLATFORM_MAX_PATH];
char g_sCommandListURL[PLATFORM_MAX_PATH];
char g_sEffectListURL[PLATFORM_MAX_PATH];
char g_sPropListURL[PLATFORM_MAX_PATH];

ConVar g_cvColorListURL;
ConVar g_cvCommandListURL;
ConVar g_cvEffectListURL;
ConVar g_cvPropListURL;

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("KS_CheckInputURL", Native_CheckInputURL);
	CreateNative("KS_ExportColorList", Native_ExportColorList);
	CreateNative("KS_ExportCommandList", Native_ExportCommandList);
	CreateNative("KS_ExportPropList", Native_ExportPropList);
	CreateNative("KS_OpenMOTDOnClient", Native_OpenMOTDOnClient);
	
	return APLRes_Success;
}

public Plugin myinfo = 
{
	name = "King's Sandbox: Help", 
	author = "King Nothing", 
	description = "Helpful commands for server owners and players.", 
	version = SANDBOX_VERSION, 
	url = "https://github.com/rockzehh/kingssandbox"
};

public void OnPluginStart()
{
	g_cvColorListURL = CreateConVar("ks_color_list_url", "https://rockzehh.github.io/kingssandbox/1.2.0.0/colorlist_export.html", "URL for the color list command.");
	g_cvCommandListURL = CreateConVar("ks_command_list_url", "https://rockzehh.github.io/kingssandbox/1.2.0.0/commandlist_export.html", "URL for the command list command.");
	g_cvEffectListURL = CreateConVar("ks_effect_list_url", "https://rockzehh.github.io/kingssandbox/1.2.0.0/effects.html", "URL for the effect list command.");
	g_cvPropListURL = CreateConVar("ks_prop_list_url", "https://rockzehh.github.io/kingssandbox/1.2.0.0/proplist_export.html", "URL for the prop list command.");
	
	g_cvColorListURL.AddChangeHook(KSHelp_OnConVarChanged);
	g_cvCommandListURL.AddChangeHook(KSHelp_OnConVarChanged);
	g_cvEffectListURL.AddChangeHook(KSHelp_OnConVarChanged);
	g_cvPropListURL.AddChangeHook(KSHelp_OnConVarChanged);
	
	g_cvColorListURL.GetString(g_sColorListURL, sizeof(g_sColorListURL));
	g_cvCommandListURL.GetString(g_sCommandListURL, sizeof(g_sCommandListURL));
	g_cvEffectListURL.GetString(g_sEffectListURL, sizeof(g_sEffectListURL));
	g_cvPropListURL.GetString(g_sPropListURL, sizeof(g_sPropListURL));
	
	RegConsoleCmd("sm_colorlist", Command_ColorList, "King's Sandbox: Displays the color list.");
	RegConsoleCmd("sm_colors", Command_ColorList, "King's Sandbox: Displays the color list.");
	RegConsoleCmd("sm_cmds", Command_CommandList, "King's Sandbox: Displays the command list.");
	RegConsoleCmd("sm_commandlist", Command_CommandList, "King's Sandbox: Displays the command list.");
	RegConsoleCmd("sm_commands", Command_CommandList, "King's Sandbox: Displays the command list.");
	RegConsoleCmd("sm_effectlist", Command_EffectList, "King's Sandbox: Displays the effect list.");
	RegConsoleCmd("sm_effects", Command_EffectList, "King's Sandbox: Displays the effect list.");
	RegConsoleCmd("sm_proplist", Command_PropList, "King's Sandbox: Displays the prop list.");
	RegConsoleCmd("sm_props", Command_PropList, "King's Sandbox: Displays the prop list.");
	
	RegServerCmd("ks_exportcolorlist", Command_ExportColorList, "King's Sandbox-Server: Exports the color list into a text or html file in 'data/kingssandbox/exports'.");
	RegServerCmd("ks_exportcommandlist", Command_ExportCommandList, "King's Sandbox-Server: Exports the command list into a text or html file in 'data/kingssandbox/exports'.");
	RegServerCmd("ks_exportproplist", Command_ExportPropList, "King's Sandbox-Server: Exports the prop list into a text or html file in 'data/kingssandbox/exports'.");
}

public void KSHelp_OnConVarChanged(ConVar cvConVar, const char[] sOldValue, const char[] sNewValue)
{
	if (cvConVar == g_cvColorListURL)
	{
		g_cvColorListURL.GetString(g_sColorListURL, sizeof(g_sColorListURL));
		PrintToServer("King's Sandbox: Color list url updated to %s.", sNewValue);
	} else if (cvConVar == g_cvCommandListURL)
	{
		g_cvCommandListURL.GetString(g_sCommandListURL, sizeof(g_sCommandListURL));
		PrintToServer("King's Sandbox: Command list url updated to %s.", sNewValue);
	} else if (cvConVar == g_cvEffectListURL)
	{
		g_cvEffectListURL.GetString(g_sEffectListURL, sizeof(g_sEffectListURL));
		PrintToServer("King's Sandbox: Effect list url updated to %s.", sNewValue);
	} else if (cvConVar == g_cvPropListURL) {
		g_cvPropListURL.GetString(g_sPropListURL, sizeof(g_sPropListURL));
		PrintToServer("King's Sandbox: Prop list url updated to %s.", sNewValue);
	}
}

//Plugin Commands:
public Action Command_ColorList(int iClient, int iArgs)
{
	char sURL[PLATFORM_MAX_PATH];
	
	KS_CheckInputURL(g_sColorListURL, sURL, sizeof(sURL));
	
	KS_OpenMOTDOnClient(iClient, true, "King's Web Viewer", sURL, MOTDPANEL_TYPE_URL);
	
	KS_ReplyToCommand(iClient, "Displaying color list.");
	
	return Plugin_Handled;
}

public Action Command_CommandList(int iClient, int iArgs)
{
	char sURL[PLATFORM_MAX_PATH];
	
	KS_CheckInputURL(g_sCommandListURL, sURL, sizeof(sURL));
	
	KS_OpenMOTDOnClient(iClient, true, "King's Web Viewer", sURL, MOTDPANEL_TYPE_URL);
	
	KS_ReplyToCommand(iClient, "Displaying command list.");
	
	return Plugin_Handled;
}

public Action Command_EffectList(int iClient, int iArgs)
{
	char sURL[PLATFORM_MAX_PATH];
	
	KS_CheckInputURL(g_sEffectListURL, sURL, sizeof(sURL));
	
	KS_OpenMOTDOnClient(iClient, true, "King's Web Viewer", sURL, MOTDPANEL_TYPE_URL);
	
	KS_ReplyToCommand(iClient, "Displaying effect list.");
	
	return Plugin_Handled;
}

public Action Command_ExportColorList(int iArgs)
{
	char sHTML[PLATFORM_MAX_PATH];
	
	GetCmdArg(1, sHTML, sizeof(sHTML));
	
	KS_ExportColorList(StrContains(sHTML, "html", false) != -1);
	
	return Plugin_Handled;
}

public Action Command_ExportCommandList(int iArgs)
{
	char sHTML[PLATFORM_MAX_PATH];
	
	GetCmdArg(1, sHTML, sizeof(sHTML));
	
	KS_ExportCommandList(StrContains(sHTML, "html", false) != -1);
	
	return Plugin_Handled;
}

public Action Command_ExportPropList(int iArgs)
{
	char sHTML[PLATFORM_MAX_PATH];
	
	GetCmdArg(1, sHTML, sizeof(sHTML));
	
	KS_ExportPropList(StrContains(sHTML, "html", false) != -1);
	
	return Plugin_Handled;
}

public Action Command_PropList(int iClient, int iArgs)
{
	char sURL[PLATFORM_MAX_PATH];
	
	KS_CheckInputURL(g_sPropListURL, sURL, sizeof(sURL));
	
	KS_OpenMOTDOnClient(iClient, true, "King's Web Viewer", sURL, MOTDPANEL_TYPE_URL);
	
	KS_ReplyToCommand(iClient, "Displaying prop list.");
	
	return Plugin_Handled;
}

//Plugin Natives:
public int Native_CheckInputURL(Handle hPlugin, int iNumParams)
{
	char sInput[PLATFORM_MAX_PATH], sOutput[PLATFORM_MAX_PATH];
	int iMaxLength = GetNativeCell(3);
	
	GetNativeString(1, sInput, sizeof(sInput));
	
	if (StrContains(sInput, "http://", false) != -1 || StrContains(sInput, "https://", false) != -1)
	{
		Format(sOutput, iMaxLength, sInput);
	} else {
		Format(sOutput, iMaxLength, "http://%s", sInput);
	}
	
	SetNativeString(2, sOutput, iMaxLength);
}

public int Native_ExportColorList(Handle hPlugin, int iNumParams)
{
	bool bHTML = view_as<bool>(GetNativeCell(1));
	char sColor[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/colors.txt");
	
	KeyValues kvColors = new KeyValues("Colors");
	
	kvColors.ImportFromFile(sPath);
	
	if (!kvColors.JumpToKey("RGB", false))
	{
		delete kvColors;
		
		PrintToServer("King's Sandbox: Cannot print color list. (Cannot jump to key)");
		
		return false;
	}
	
	if (!kvColors.GotoFirstSubKey(false))
	{
		delete kvColors;
		
		PrintToServer("King's Sandbox: Cannot print color list. (Cannot goto first sub key)");
		
		return false;
	}
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/exports");
	if (!DirExists(sPath))
		CreateDirectory(sPath, 511);
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/exports/colorlist_export.txt");
	
	if (FileExists(sPath))
		DeleteFile(sPath);
	
	File fColorList = OpenFile(sPath, "a+");
	
	do
	{
		kvColors.GetSectionName(sColor, sizeof(sColor));
		
		fColorList.WriteLine(sColor);
	} while (kvColors.GotoNextKey(false));
	
	fColorList.Close();
	
	delete kvColors;
	
	PrintToServer("King's Sandbox: Exported color list to 'data/kingssandbox/export/colorlist_export.txt'.");
	
	if (bHTML)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/colors.txt");
		
		KeyValues kvColorsHTML = new KeyValues("Colors");
		
		kvColorsHTML.ImportFromFile(sPath);
		
		if (!kvColorsHTML.JumpToKey("RGB", false))
		{
			delete kvColorsHTML;
			
			PrintToServer("King's Sandbox: Cannot print color list. (Cannot jump to key)");
			
			return false;
		}
		
		if (!kvColorsHTML.GotoFirstSubKey(false))
		{
			delete kvColorsHTML;
			
			PrintToServer("King's Sandbox: Cannot print color list. (Cannot goto first sub key)");
			
			return false;
		}
		
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/exports");
		if (!DirExists(sPath))
			CreateDirectory(sPath, 511);
		
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/exports/colorlist_export.html");
		
		if (FileExists(sPath))
			DeleteFile(sPath);
		
		File fColorListHTML = OpenFile(sPath, "a+");
		
		fColorListHTML.WriteLine("<title>King's Sandbox: Color List</title>");
		
		fColorListHTML.WriteLine("<b>King's Sandbox</b>: Color List:");
		
		fColorListHTML.WriteLine("<br>");
		
		do
		{
			kvColorsHTML.GetSectionName(sColor, sizeof(sColor));
			
			Format(sColor, sizeof(sColor), "<br>%s", sColor);
			
			fColorListHTML.WriteLine(sColor);
		} while (kvColorsHTML.GotoNextKey(false));
		
		fColorListHTML.Close();
		
		delete kvColorsHTML;
		
		PrintToServer("King's Sandbox: Exported color list to 'data/kingssandbox/export/colorlist_export.html'.");
	}
	
	return true;
}

public int Native_ExportCommandList(Handle hPlugin, int iNumParams)
{
	bool bHTML = view_as<bool>(GetNativeCell(1));
	char sCommand[PLATFORM_MAX_PATH], sDescription[PLATFORM_MAX_PATH], sName[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH], sPathHTML[PLATFORM_MAX_PATH];
	File fCommandList, fCommandListHTML;
	Handle hCommandIter = GetCommandIterator();
	int iFlags;
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/exports");
	if (!DirExists(sPath))
		CreateDirectory(sPath, 511);
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/exports/commandlist_export.txt");
	
	if (FileExists(sPath))
		DeleteFile(sPath);
	
	BuildPath(Path_SM, sPathHTML, sizeof(sPathHTML), "data/kingssandbox/exports/commandlist_export.html");
	
	if (FileExists(sPathHTML))
		DeleteFile(sPathHTML);
	
	fCommandList = OpenFile(sPath, "a+");
	if (bHTML)
		fCommandListHTML = OpenFile(sPathHTML, "a+");
	
	if (bHTML)
	{
		fCommandListHTML.WriteLine("<title>King's Sandbox: Command List</title>");
		
		fCommandListHTML.WriteLine("<b>King's Sandbox</b>: Command List:");
		
		fCommandListHTML.WriteLine("<br>");
	}
	
	while (ReadCommandIterator(hCommandIter, sName, sizeof(sName), iFlags, sDescription, sizeof(sDescription)))
	{
		if (StrContains(sDescription, "King's Sandbox:", true) != -1)
		{
			ReplaceString(sDescription, sizeof(sDescription), "King's Sandbox: ", "", true);
			
			Format(sCommand, sizeof(sCommand), "%s - %s - %s", sName, (iFlags == 0) ? "Client" : "Admin", sDescription);
			
			fCommandList.WriteLine(sCommand);
			
			if (bHTML)
			{
				Format(sCommand, sizeof(sCommand), "<br>%s - %s - %s", sName, (iFlags == 0) ? "Client" : "Admin", sDescription);
				
				fCommandListHTML.WriteLine(sCommand);
			}
		} else if (StrContains(sDescription, "King's Sandbox-Server:", true) != -1)
		{
			ReplaceString(sDescription, sizeof(sDescription), "King's Sandbox-Server: ", "", true);
			
			Format(sCommand, sizeof(sCommand), "%s - Server - %s", sName, sDescription);
			
			fCommandList.WriteLine(sCommand);
			
			if (bHTML)
			{
				Format(sCommand, sizeof(sCommand), "<br>%s - Server - %s", sName, sDescription);
				
				fCommandListHTML.WriteLine(sCommand);
			}
		}
	}
	
	CloseHandle(hCommandIter);
	
	PrintToServer("King's Sandbox: Exported command list to 'data/kingssandbox/export/commandlist_export.txt'.");
	if (bHTML)
		PrintToServer("King's Sandbox: Exported command list to 'data/kingssandbox/export/commandlist_export.html'.");
	
	fCommandList.Close();
	if (bHTML)
		fCommandListHTML.Close();
}

public int Native_ExportPropList(Handle hPlugin, int iNumParams)
{
	bool bHTML = view_as<bool>(GetNativeCell(1));
	char sPropname[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/spawns.txt");
	
	KeyValues kvProps = new KeyValues("Props");
	
	kvProps.ImportFromFile(sPath);
	
	kvProps.JumpToKey("Default", false);
	
	if (!kvProps.GotoFirstSubKey(false))
	{
		delete kvProps;
		
		PrintToServer("King's Sandbox: Cannot print prop list.");
		
		return false;
	}
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/exports");
	if (!DirExists(sPath))
		CreateDirectory(sPath, 511);
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/exports/proplist_export.txt");
	
	if (FileExists(sPath))
		DeleteFile(sPath);
	
	File fPropList = OpenFile(sPath, "a+");
	
	do
	{
		kvProps.GetSectionName(sPropname, sizeof(sPropname));
		
		fPropList.WriteLine(sPropname);
	} while (kvProps.GotoNextKey(false));
	
	fPropList.Close();
	
	PrintToServer("King's Sandbox: Exported prop list to 'data/kingssandbox/export/proplist_export.txt'.");
	
	if (bHTML)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/spawns.txt");
		
		KeyValues kvPropsHTML = new KeyValues("Props");
		
		kvPropsHTML.ImportFromFile(sPath);
		
		kvPropsHTML.JumpToKey("Default", false);
		
		if (!kvPropsHTML.GotoFirstSubKey(false))
		{
			delete kvPropsHTML;
			
			PrintToServer("King's Sandbox: Cannot print prop list.");
			
			return false;
		}
		
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/exports");
		if (!DirExists(sPath))
			CreateDirectory(sPath, 511);
		
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/kingssandbox/exports/proplist_export.html");
		
		if (FileExists(sPath))
			DeleteFile(sPath);
		
		File fPropListHTML = OpenFile(sPath, "a+");
		
		fPropListHTML.WriteLine("<title>King's Sandbox: Prop List</title>");
		
		fPropListHTML.WriteLine("<b>King's Sandbox</b>: Prop List:");
		
		fPropListHTML.WriteLine("<br>");
		
		do
		{
			kvPropsHTML.GetSectionName(sPropname, sizeof(sPropname));
			
			Format(sPropname, sizeof(sPropname), "<br>%s", sPropname);
			
			fPropListHTML.WriteLine(sPropname);
		} while (kvPropsHTML.GotoNextKey(false));
		
		fPropListHTML.Close();
		
		PrintToServer("King's Sandbox: Exported prop list to 'data/kingssandbox/export/proplist_export.html'.");
	}
	
	delete kvProps;
	
	return true;
}

public int Native_OpenMOTDOnClient(Handle hPlugin, int iNumParams)
{
	char sMOTDDestination[PLATFORM_MAX_PATH], sMOTDTitle[128];
	
	int iPlayer = GetNativeCell(1);
	bool bVisible = view_as<bool>(GetNativeCell(2));
	GetNativeString(3, sMOTDTitle, sizeof(sMOTDTitle));
	GetNativeString(4, sMOTDDestination, sizeof(sMOTDDestination));
	int iMOTDType = GetNativeCell(5);
	
	KeyValues kvMOTD = new KeyValues("data");
	
	kvMOTD.SetString("title", sMOTDTitle);
	kvMOTD.SetNum("type", iMOTDType);
	kvMOTD.SetString("msg", sMOTDDestination);
	
	ShowVGUIPanel(iPlayer, "info", kvMOTD, bVisible);
	
	delete kvMOTD;
}
