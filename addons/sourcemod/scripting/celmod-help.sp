#pragma semicolon 1

#include <celmod>

#pragma newdecls required

char g_sColorListURL[PLATFORM_MAX_PATH];
char g_sCommandListURL[PLATFORM_MAX_PATH];
char g_sEffectListURL[PLATFORM_MAX_PATH];
char g_sPropListURL[PLATFORM_MAX_PATH];
char g_sUpdateListURL[PLATFORM_MAX_PATH];

ConVar g_cvColorListURL;
ConVar g_cvCommandListURL;
ConVar g_cvEffectListURL;
ConVar g_cvPropListURL;
ConVar g_cvUpdateListURL;

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_CheckInputURL", Native_CheckInputURL);
	CreateNative("Cel_ExportColorList", Native_ExportColorList);
	CreateNative("Cel_ExportCommandList", Native_ExportCommandList);
	CreateNative("Cel_ExportPropList", Native_ExportPropList);
	CreateNative("Cel_OpenMOTDOnClient", Native_OpenMOTDOnClient);
	
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "|CelMod| Help",
	author = CEL_AUTHOR,
	description = "Helpful commands for server owners and players.",
	version = CEL_VERSION,
	url = CEL_URL
};

public void OnPluginStart()
{
	LoadTranslations("celmod.phrases");
	
	g_cvColorListURL = CreateConVar("cm_color_list_url", "https://celmod.rockzehh.net/colors.html", "URL for the color list command.");
	g_cvCommandListURL = CreateConVar("cm_command_list_url", "https://celmod.rockzehh.net/cmds.html", "URL for the command list command.");
	g_cvEffectListURL = CreateConVar("cm_effect_list_url", "https://celmod.rockzehh.net/effects.html", "URL for the effect list command.");
	g_cvPropListURL = CreateConVar("cm_prop_list_url", "https://celmod.rockzehh.net/props.html", "URL for the prop list command.");
	g_cvUpdateListURL = CreateConVar("cm_update_list_url", "https://celmod.rockzehh.net/updates.html", "URL for the update list command.");
	
	g_cvColorListURL.AddChangeHook(CMHelp_OnConVarChanged);
	g_cvCommandListURL.AddChangeHook(CMHelp_OnConVarChanged);
	g_cvEffectListURL.AddChangeHook(CMHelp_OnConVarChanged);
	g_cvPropListURL.AddChangeHook(CMHelp_OnConVarChanged);
	g_cvUpdateListURL.AddChangeHook(CMHelp_OnConVarChanged);
	
	g_cvColorListURL.GetString(g_sColorListURL, sizeof(g_sColorListURL));
	g_cvCommandListURL.GetString(g_sCommandListURL, sizeof(g_sCommandListURL));
	g_cvEffectListURL.GetString(g_sEffectListURL, sizeof(g_sEffectListURL));
	g_cvPropListURL.GetString(g_sPropListURL, sizeof(g_sPropListURL));
	g_cvUpdateListURL.GetString(g_sUpdateListURL, sizeof(g_sUpdateListURL));
	
	AutoExecConfig(true, "celmod.help");
	
	RegConsoleCmd("v_colorlist", Command_ColorList, "|CelMod| Displays the color list.");
	RegConsoleCmd("v_colors", Command_ColorList, "|CelMod| Displays the color list.");
	RegConsoleCmd("v_cmds", Command_CommandList, "|CelMod| Displays the command list.");
	RegConsoleCmd("v_commandlist", Command_CommandList, "|CelMod| Displays the command list.");
	RegConsoleCmd("v_commands", Command_CommandList, "|CelMod| Displays the command list.");
	RegConsoleCmd("v_effectlist", Command_EffectList, "|CelMod| Displays the effect list.");
	RegConsoleCmd("v_effects", Command_EffectList, "|CelMod| Displays the effect list.");
	RegConsoleCmd("v_proplist", Command_PropList, "|CelMod| Displays the prop list.");
	RegConsoleCmd("v_props", Command_PropList, "|CelMod| Displays the prop list.");
	RegConsoleCmd("v_updatelist", Command_UpdateList, "|CelMod| Displays the update list.");
	RegConsoleCmd("v_updates", Command_UpdateList, "|CelMod| Displays the update list.");
	
	RegServerCmd("cm_exportcolorlist", Command_ExportColorList, "CelMod-Server: Exports the color list into a text or html file in 'data/celmod/exports'.");
	RegServerCmd("cm_exportcommandlist", Command_ExportCommandList, "CelMod-Server: Exports the command list into a text or html file in 'data/celmod/exports'.");
	RegServerCmd("cm_exportproplist", Command_ExportPropList, "CelMod-Server: Exports the prop list into a text or html file in 'data/celmod/exports'.");
}

public void CMHelp_OnConVarChanged(ConVar cvConVar, const char[] sOldValue, const char[] sNewValue)
{
	if (cvConVar == g_cvColorListURL)
	{
		g_cvColorListURL.GetString(g_sColorListURL, sizeof(g_sColorListURL));
		PrintToServer("|CelMod| Color list url updated to %s.", sNewValue);
	} else if (cvConVar == g_cvCommandListURL)
	{
		g_cvCommandListURL.GetString(g_sCommandListURL, sizeof(g_sCommandListURL));
		PrintToServer("|CelMod| Command list url updated to %s.", sNewValue);
	} else if (cvConVar == g_cvEffectListURL)
	{
		g_cvEffectListURL.GetString(g_sEffectListURL, sizeof(g_sEffectListURL));
		PrintToServer("|CelMod| Effect list url updated to %s.", sNewValue);
	} else if (cvConVar == g_cvPropListURL) {
		g_cvPropListURL.GetString(g_sPropListURL, sizeof(g_sPropListURL));
		PrintToServer("|CelMod| Prop list url updated to %s.", sNewValue);
	} else if (cvConVar == g_cvUpdateListURL) {
		g_cvPropListURL.GetString(g_sUpdateListURL, sizeof(g_sUpdateListURL));
		PrintToServer("|CelMod| Update list url updated to %s.", sNewValue);
	}
}

//Plugin Commands:
public Action Command_ColorList(int iClient, int iArgs)
{
	char sURL[PLATFORM_MAX_PATH];
	
	Cel_CheckInputURL(g_sColorListURL, sURL, sizeof(sURL));
	
	Cel_OpenMOTDOnClient(iClient, true, "Cel's Web Viewer", sURL, MOTDPANEL_TYPE_URL);
	
	Cel_ReplyToCommand(iClient, "%t", "DisplayColorList");
	
	return Plugin_Handled;
}

public Action Command_CommandList(int iClient, int iArgs)
{
	char sURL[PLATFORM_MAX_PATH];
	
	Cel_CheckInputURL(g_sCommandListURL, sURL, sizeof(sURL));
	
	Cel_OpenMOTDOnClient(iClient, true, "Cel's Web Viewer", sURL, MOTDPANEL_TYPE_URL);
	
	Cel_ReplyToCommand(iClient, "%t", "DisplayCommandList");
	
	return Plugin_Handled;
}

public Action Command_EffectList(int iClient, int iArgs)
{
	char sURL[PLATFORM_MAX_PATH];
	
	Cel_CheckInputURL(g_sEffectListURL, sURL, sizeof(sURL));
	
	Cel_OpenMOTDOnClient(iClient, true, "Cel's Web Viewer", sURL, MOTDPANEL_TYPE_URL);
	
	Cel_ReplyToCommand(iClient, "%t", "DisplayEffectList");
	
	return Plugin_Handled;
}

public Action Command_ExportColorList(int iArgs)
{
	char sHTML[PLATFORM_MAX_PATH];
	
	GetCmdArg(1, sHTML, sizeof(sHTML));
	
	Cel_ExportColorList(StrContains(sHTML, "html", false) != -1);
	
	return Plugin_Handled;
}

public Action Command_ExportCommandList(int iArgs)
{
	char sHTML[PLATFORM_MAX_PATH];
	
	GetCmdArg(1, sHTML, sizeof(sHTML));
	
	Cel_ExportCommandList(StrContains(sHTML, "html", false) != -1);
	
	return Plugin_Handled;
}

public Action Command_ExportPropList(int iArgs)
{
	char sHTML[PLATFORM_MAX_PATH];
	
	GetCmdArg(1, sHTML, sizeof(sHTML));
	
	Cel_ExportPropList(StrContains(sHTML, "html", false) != -1);
	
	return Plugin_Handled;
}

public Action Command_PropList(int iClient, int iArgs)
{
	char sURL[PLATFORM_MAX_PATH];
	
	Cel_CheckInputURL(g_sPropListURL, sURL, sizeof(sURL));
	
	Cel_OpenMOTDOnClient(iClient, true, "Cel's Web Viewer", sURL, MOTDPANEL_TYPE_URL);
	
	Cel_ReplyToCommand(iClient, "%t", "DisplayPropList");
	
	return Plugin_Handled;
}

public Action Command_UpdateList(int iClient, int iArgs)
{
	char sURL[PLATFORM_MAX_PATH];
	
	Cel_CheckInputURL(g_sUpdateListURL, sURL, sizeof(sURL));
	
	Cel_OpenMOTDOnClient(iClient, true, "Cel's Web Viewer", sURL, MOTDPANEL_TYPE_URL);
	
	Cel_ReplyToCommand(iClient, "%t", "DisplayUpdateList");
	
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
	
	return true;
}

public int Native_ExportColorList(Handle hPlugin, int iNumParams)
{
	bool bHTML = view_as<bool>(GetNativeCell(1));
	char sColor[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/colors.txt");
	
	KeyValues kvColors = new KeyValues("Colors");
	
	kvColors.ImportFromFile(sPath);
	
	if (!kvColors.JumpToKey("RGB", false))
	{
		delete kvColors;
		
		PrintToServer("|CelMod| Cannot print color list. (Cannot jump to key)");
		
		return false;
	}
	
	if (!kvColors.GotoFirstSubKey(false))
	{
		delete kvColors;
		
		PrintToServer("|CelMod| Cannot print color list. (Cannot goto first sub key)");
		
		return false;
	}
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/exports");
	if (!DirExists(sPath))
	CreateDirectory(sPath, 511);
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/exports/colorlist_export.txt");
	
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
	
	PrintToServer("|CelMod| Exported color list to 'data/celmod/export/colorlist_export.txt'.");
	
	if (bHTML)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/colors.txt");
		
		KeyValues kvColorsHTML = new KeyValues("Colors");
		
		kvColorsHTML.ImportFromFile(sPath);
		
		if (!kvColorsHTML.JumpToKey("RGB", false))
		{
			delete kvColorsHTML;
			
			PrintToServer("|CelMod| Cannot print color list. (Cannot jump to key)");
			
			return false;
		}
		
		if (!kvColorsHTML.GotoFirstSubKey(false))
		{
			delete kvColorsHTML;
			
			PrintToServer("|CelMod| Cannot print color list. (Cannot goto first sub key)");
			
			return false;
		}
		
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/exports");
		if (!DirExists(sPath))
		CreateDirectory(sPath, 511);
		
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/exports/colorlist_export.html");
		
		if (FileExists(sPath))
		DeleteFile(sPath);
		
		File fColorListHTML = OpenFile(sPath, "a+");
		
		fColorListHTML.WriteLine("<title>|CelMod| Color List</title>");
		
		fColorListHTML.WriteLine("<b>|CelMod|</b> Color List:");
		
		fColorListHTML.WriteLine("<br>");
		
		do
		{
			kvColorsHTML.GetSectionName(sColor, sizeof(sColor));
			
			Format(sColor, sizeof(sColor), "<br>%s", sColor);
			
			fColorListHTML.WriteLine(sColor);
		} while (kvColorsHTML.GotoNextKey(false));
		
		fColorListHTML.Close();
		
		delete kvColorsHTML;
		
		PrintToServer("|CelMod| Exported color list to 'data/celmod/export/colorlist_export.html'.");
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
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/exports");
	if (!DirExists(sPath))
	CreateDirectory(sPath, 511);
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/exports/commandlist_export.txt");
	
	if (FileExists(sPath))
	DeleteFile(sPath);
	
	BuildPath(Path_SM, sPathHTML, sizeof(sPathHTML), "data/celmod/exports/commandlist_export.html");
	
	if (FileExists(sPathHTML))
	DeleteFile(sPathHTML);
	
	fCommandList = OpenFile(sPath, "a+");
	if (bHTML)
	fCommandListHTML = OpenFile(sPathHTML, "a+");
	
	if (bHTML)
	{
		fCommandListHTML.WriteLine("<title>|CelMod| Command List</title>");
		
		fCommandListHTML.WriteLine("<b>|CelMod|</b> Command List:");
		
		fCommandListHTML.WriteLine("<br>");
	}
	
	while (ReadCommandIterator(hCommandIter, sName, sizeof(sName), iFlags, sDescription, sizeof(sDescription)))
	{
		if (StrContains(sDescription, "|CelMod|", true) != -1)
		{
			ReplaceString(sDescription, sizeof(sDescription), "|CelMod| ", "", true);
			
			Format(sCommand, sizeof(sCommand), "%s - %s - %s", sName, (iFlags == 0) ? "Client" : "Admin", sDescription);
			
			fCommandList.WriteLine(sCommand);
			
			if (bHTML)
			{
				Format(sCommand, sizeof(sCommand), "<br>%s - %s - %s", sName, (iFlags == 0) ? "Client" : "Admin", sDescription);
				
				fCommandListHTML.WriteLine(sCommand);
			}
		} else if (StrContains(sDescription, "CelMod-Server:", true) != -1)
		{
			ReplaceString(sDescription, sizeof(sDescription), "CelMod-Server: ", "", true);
			
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
	
	PrintToServer("|CelMod| Exported command list to 'data/celmod/export/commandlist_export.txt'.");
	if (bHTML)
	PrintToServer("|CelMod| Exported command list to 'data/celmod/export/commandlist_export.html'.");
	
	fCommandList.Close();
	if (bHTML)
	fCommandListHTML.Close();
	
	return true;
}

public int Native_ExportPropList(Handle hPlugin, int iNumParams)
{
	bool bHTML = view_as<bool>(GetNativeCell(1));
	char sPropname[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/spawns.txt");
	
	KeyValues kvProps = new KeyValues("Props");
	
	kvProps.ImportFromFile(sPath);
	
	kvProps.JumpToKey("Models", false);
	
	if (!kvProps.GotoFirstSubKey(false))
	{
		delete kvProps;
		
		PrintToServer("|CelMod| Cannot print prop list.");
		
		return false;
	}
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/exports");
	if (!DirExists(sPath))
	CreateDirectory(sPath, 511);
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/exports/proplist_export.txt");
	
	if (FileExists(sPath))
	DeleteFile(sPath);
	
	File fPropList = OpenFile(sPath, "a+");
	
	do
	{
		kvProps.GetSectionName(sPropname, sizeof(sPropname));
		
		if(!Cel_CheckBlacklistDB(sPropname))
		{
			fPropList.WriteLine(sPropname);
		}
	} while (kvProps.GotoNextKey(false));
	
	fPropList.Close();
	
	PrintToServer("|CelMod| Exported prop list to 'data/celmod/export/proplist_export.txt'.");
	
	if (bHTML)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/spawns.txt");
		
		KeyValues kvPropsHTML = new KeyValues("Props");
		
		kvPropsHTML.ImportFromFile(sPath);
		
		kvPropsHTML.JumpToKey("Default", false);
		
		if (!kvPropsHTML.GotoFirstSubKey(false))
		{
			delete kvPropsHTML;
			
			PrintToServer("|CelMod| Cannot print prop list.");
			
			return false;
		}
		
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/exports");
		if (!DirExists(sPath))
		CreateDirectory(sPath, 511);
		
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/celmod/exports/proplist_export.html");
		
		if (FileExists(sPath))
		DeleteFile(sPath);
		
		File fPropListHTML = OpenFile(sPath, "a+");
		
		fPropListHTML.WriteLine("<title>|CelMod| Prop List</title>");
		
		fPropListHTML.WriteLine("<b>|CelMod|</b> Prop List:");
		
		fPropListHTML.WriteLine("<br>");
		
		do
		{
			kvPropsHTML.GetSectionName(sPropname, sizeof(sPropname));
			
			Format(sPropname, sizeof(sPropname), "<br>%s", sPropname);
			
			fPropListHTML.WriteLine(sPropname);
		} while (kvPropsHTML.GotoNextKey(false));
		
		fPropListHTML.Close();
		
		PrintToServer("|CelMod| Exported prop list to 'data/celmod/export/proplist_export.html'.");
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
	
	return true;
}
