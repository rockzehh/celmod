#pragma semicolon 1

#include <celmod>

#pragma newdecls required

bool g_bLate;

StringMap g_smCelCommands;

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_IsCelCommand", Native_IsCelCommand);
	CreateNative("Cel_NotLooking", Native_NotLooking);
	CreateNative("Cel_NotYours", Native_NotYours);
	CreateNative("Cel_PlayChatMessageSound", Native_PlayChatMessageSound);
	CreateNative("Cel_PrintToChat", Native_PrintToChat);
	CreateNative("Cel_PrintToChatAll", Native_PrintToChatAll);
	CreateNative("Cel_ReplyToCommand", Native_ReplyToCommand);
	CreateNative("Cel_ReplyToCommandEntity", Native_ReplyToCommandEntity);
	
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "|CelMod| Chat Handler",
	author = CEL_AUTHOR,
	description = "",
	version = CEL_VERSION,
	url = CEL_URL
};

public void OnPluginStart()
{
	LoadTranslations("celmod.phrases");
	
	if (g_bLate)
	{
		OnMapStart();
	}
	
	AddCommandListener(Handle_Noclip, "noclip");
	AddCommandListener(Handle_Chat, "say");
	AddCommandListener(Handle_Chat, "say_team");
	
	ConCommand_RemoveFlags("noclip", FCVAR_CHEAT);
}

public void OnMapStart()
{
	Cel_PopulateCelCommands();
}

public void OnMapEnd()
{
	delete g_smCelCommands;
}

//Commands:
public Action Handle_Chat(int iClient, char[] sCommand, int iArgs)
{
	char sCommandString[MAX_MESSAGE_LENGTH];
	
	GetCmdArgString(sCommandString, sizeof(sCommandString));
	
	StripQuotes(sCommandString);
	
	if (sCommandString[0] == '!' || sCommandString[0] == '/') {
		ReplaceString(sCommandString, sizeof(sCommandString), (sCommandString[0] == '!') ? "!" : "/", "v_");
		
		if(Cel_IsCelCommand(sCommandString))
		{
			ReplySource rsOldReplySrc = GetCmdReplySource();
			
			SetCmdReplySource(SM_REPLY_TO_CHAT);
			
			FakeClientCommand(iClient, sCommandString);
			
			SetCmdReplySource(rsOldReplySrc);
		}
		
		return Plugin_Handled;
	}else if (IsChatTrigger()) {
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action Handle_Noclip(int iClient, char[] sCommand, int iArgs)
{
	FakeClientCommand(iClient, "v_fly");
	
	return Plugin_Handled;
}

//Natives:
public int Native_IsCelCommand(Handle hPlugin, int iNumParams)
{
	char sCommand[MAX_MESSAGE_LENGTH], sCommandSplit[2][MAX_MESSAGE_LENGTH];
	int iValue;
	
	GetNativeString(1, sCommand, sizeof(sCommand));
	
	ExplodeString(sCommand, " ", sCommandSplit, 2, sizeof(sCommandSplit[]), false);
	
	CStrToLower(sCommandSplit[0]);
	
	return g_smCelCommands.GetValue(sCommandSplit[0], iValue);
}

public int Native_NotLooking(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	Cel_ReplyToCommand(iClient, "%t", "NotLooking");
	
	return true;
}

public int Native_NotYours(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	int iEntity = GetNativeCell(2);
	
	Cel_ReplyToCommandEntity(iClient, iEntity, "%t", "NotYours");
	
	return true;
}

public int Native_PlayChatMessageSound(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1);
	
	ClientCommand(iClient, "play npc/stalker/stalker_footstep_%s1", GetRandomInt(0, 1) ? "left" : "right");
	
	return true;
}

public int Native_PrintToChat(Handle hPlugin, int iNumParams)
{
	char sBuffer[MAX_MESSAGE_LENGTH];
	
	int iPlayer = GetNativeCell(1), iWritten;
	
	FormatNativeString(0, 2, 3, sizeof(sBuffer), iWritten, sBuffer);
	
	CPrintToChat(iPlayer, "{blue}|CelMod|{default} %s", sBuffer);
	
	Cel_PlayChatMessageSound(iPlayer);
	
	return true;
}

public int Native_PrintToChatAll(Handle hPlugin, int iNumParams)
{
	char sBuffer[MAX_MESSAGE_LENGTH];
	
	int iWritten;
	
	FormatNativeString(0, 1, 2, sizeof(sBuffer), iWritten, sBuffer);
	
	CPrintToChatAll("{blue}|CM|{default} %s", sBuffer);
	
	return true;
}

public int Native_ReplyToCommand(Handle hPlugin, int iNumParams)
{
	char sBuffer[MAX_MESSAGE_LENGTH];
	
	int iPlayer = GetNativeCell(1), iWritten;
	
	FormatNativeString(0, 2, 3, sizeof(sBuffer), iWritten, sBuffer);
	
	ReplaceString(sBuffer, sizeof(sBuffer), "[tag]", GetCmdReplySource() == SM_REPLY_TO_CONSOLE ? "v_" : "!", true);
	
	if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		CRemoveTags(sBuffer, sizeof(sBuffer));
		
		PrintToConsole(iPlayer, "|CelMod| %s", sBuffer);
	} else {
		CPrintToChat(iPlayer, "{blue}|CelMod|{default} %s", sBuffer);
		
		Cel_PlayChatMessageSound(iPlayer);
	}
	
	return true;
}

public int Native_ReplyToCommandEntity(Handle hPlugin, int iNumParams)
{
	char sBuffer[MAX_MESSAGE_LENGTH];
	
	int iEntity = GetNativeCell(2), iPlayer = GetNativeCell(1), iWritten;
	
	FormatNativeString(0, 3, 4, sizeof(sBuffer), iWritten, sBuffer);
	
	ReplaceString(sBuffer, sizeof(sBuffer), "[tag]", GetCmdReplySource() == SM_REPLY_TO_CONSOLE ? "v_" : "!", true);
	
	Cel_UpdateEntityMessageTags(iEntity, sBuffer, sizeof(sBuffer));
	
	if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		CRemoveTags(sBuffer, sizeof(sBuffer));
		
		PrintToConsole(iPlayer, "|CelMod| %s", sBuffer);
	} else {
		CPrintToChat(iPlayer, "{blue}|CelMod|{default} %s", sBuffer);
		
		Cel_PlayChatMessageSound(iPlayer);
	}
	
	return true;
}

//Stocks:
stock void Cel_PopulateCelCommands()
{
	char sCMD[2][MAX_MESSAGE_LENGTH];
	Handle hCommandIter = GetCommandIterator();
	int iFlags;
	
	g_smCelCommands = new StringMap();
	
	while (ReadCommandIterator(hCommandIter, sCMD[0], sizeof(sCMD[]), iFlags, sCMD[1], sizeof(sCMD[])))
	{
		if (StrContains(sCMD[1], "|CelMod|", true) != -1)
		{
			g_smCelCommands.SetValue(sCMD[0], 1);
		}
	}
	
	CloseHandle(hCommandIter);
}

stock void Cel_UpdateEntityMessageTags(int iEntity, char[] sBuffer, int iMaxLength)
{
	char sName[128];
	
	if(Cel_CheckEntityType(iEntity, "ammo"))
	{
		Cel_GetAmmoTypeName(Cel_GetAmmoType(iEntity), sName, sizeof(sName));
		ReplaceString(sBuffer, iMaxLength, "[ammo]", sName, false);
	}
	if(Cel_CheckEntityType(iEntity, "ammocrate"))
	{
		Cel_GetAmmoCrateTypeName(Cel_GetAmmoCrateType(iEntity), sName, sizeof(sName));
		ReplaceString(sBuffer, iMaxLength, "[ammocrate]", sName, false);
	}
	if(Cel_CheckEntityType(iEntity, "charger"))
	{
		Cel_GetChargerTypeName(Cel_GetChargerType(iEntity), sName, sizeof(sName));
		ReplaceString(sBuffer, iMaxLength, "[charger]", sName, false);
	}
	if(Cel_CheckEntityType(iEntity, "weaponspwner"))
	{
		Cel_GetWeaponTypeName(Cel_GetWeaponType(iEntity), sName, sizeof(sName));
		ReplaceString(sBuffer, iMaxLength, "[weapon]", sName, false);
	}
	if(Cel_CheckEntityType(iEntity, "physics") || Cel_CheckEntityType(iEntity, "dynamic") || Cel_CheckEntityType(iEntity, "doll"))
	{
		Cel_GetPropName(iEntity, sName, sizeof(sName));
		ReplaceString(sBuffer, iMaxLength, "[propname]", sName, false);
	}
	if(Cel_CheckEntityType(iEntity, "internet"))
	{
		Cel_GetWeaponTypeName(Cel_GetWeaponType(iEntity), sName, sizeof(sName));
		ReplaceString(sBuffer, iMaxLength, "[url]", sName, false);
	}
	
	Cel_GetEntityCatagoryName(iEntity, sName, sizeof(sName));
	ReplaceString(sBuffer, iMaxLength, "[catagory]", sName, false);
	
	Cel_GetEntityTypeName(Cel_GetEntityType(iEntity), sName, sizeof(sName));
	ReplaceString(sBuffer, iMaxLength, "[type]", sName, false);
	
	GetClientName(Cel_GetOwner(iEntity), sName, sizeof(sName));
	ReplaceString(sBuffer, iMaxLength, "[owner]", sName, false);
}
