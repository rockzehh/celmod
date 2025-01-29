// MOAR COLORS
// By Dr. McKay, Updated by RockZehh.
// Inspired by: https://forums.alliedmods.net/showthread.php?t=96831

#if defined _colors_included
#endinput
#endif
#define _colors_included

#include <regex>

#define MORE_COLORS_VERSION		"1.9.1-NEWSYNTAX"
#define MAX_MESSAGE_LENGTH		256
#define MAX_BUFFER_LENGTH		(MAX_MESSAGE_LENGTH * 4)

#define COLOR_RED				0xFF4040
#define COLOR_BLUE				0x99CCFF
#define COLOR_GRAY				0xCCCCCC
#define COLOR_GREEN				0x3EFF3E

#define GAME_DODS				0

bool CSkipList[MAXPLAYERS + 1];
Handle CTrie;
int CTeamColors[][] = {{0xCCCCCC, 0x4D7942, 0xFF4040}}; // Multi-dimensional array for games that don't support SayText2. First index is the game index (as defined by the GAME_ defines), second index is team. 0 = spectator, 1 = team1, 2 = team2

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags.
 *
 * @param client		Client index.
 * @param message		Message (formatting rules).
 * @noreturn
 *
 * On error/Errors:		If the client is not connected an error will be thrown.
 */
stock void CPrintToChat(int iClient, const char[] sMessage, any ...)
{
	CCheckTrie();
	
	if(iClient <= 0 || iClient > MaxClients)
	{
		ThrowError("Invalid client index %i", iClient);
	}
	
	if(!IsClientInGame(iClient))
	{
		ThrowError("Client %i is not in game", iClient);
	}
	
	char sBuffer[MAX_BUFFER_LENGTH], sBuffer2[MAX_BUFFER_LENGTH];
	
	SetGlobalTransTarget(iClient);
	
	Format(sBuffer, sizeof(sBuffer), "\x01%s", sMessage);
	VFormat(sBuffer2, sizeof(sBuffer2), sBuffer, 3);
	
	CReplaceColorCodes(sBuffer2);
	CSendMessage(iClient, sBuffer2);
}

/**
 * Prints a message to all clients in the chat area.
 * Supports color tags.
 *
 * @param client		Client index.
 * @param message		Message (formatting rules).
 * @noreturn
 */
stock void CPrintToChatAll(const char[] sMessage, any ...)
{
	CCheckTrie();
	
	char sBuffer[MAX_BUFFER_LENGTH], sBuffer2[MAX_BUFFER_LENGTH];
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || CSkipList[i])
		{
			CSkipList[i] = false;
			continue;
		}
		
		SetGlobalTransTarget(i);
		
		Format(sBuffer, sizeof(sBuffer), "\x01%s", sMessage);
		VFormat(sBuffer2, sizeof(sBuffer2), sBuffer, 2);
		
		CReplaceColorCodes(sBuffer2);
		CSendMessage(i, sBuffer2);
	}
}

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags and teamcolor tag.
 *
 * @param client		Client index.
 * @param author		Author index whose color will be used for teamcolor tag.
 * @param message		Message (formatting rules).
 * @noreturn
 *
 * On error/Errors:		If the client or author are not connected an error will be thrown
 */
stock void CPrintToChatEx(int iClient, int iAuthor, const char[] sMessage, any ...)
{
	CCheckTrie();
	
	if(iClient <= 0 || iClient > MaxClients)
	{
		ThrowError("Invalid client index %i", iClient);
	}
	
	if(!IsClientInGame(iClient))
	{
		ThrowError("Client %i is not in game", iClient);
	}
	
	if(iAuthor <= 0 || iAuthor > MaxClients)
	{
		ThrowError("Invalid client index %i", iAuthor);
	}
	
	if(!IsClientInGame(iAuthor))
	{
		ThrowError("Client %i is not in game", iAuthor);
	}
	
	char sBuffer[MAX_BUFFER_LENGTH], sBuffer2[MAX_BUFFER_LENGTH];
	
	SetGlobalTransTarget(iClient);
	
	Format(sBuffer, sizeof(sBuffer), "\x01%s", sMessage);
	VFormat(sBuffer2, sizeof(sBuffer2), sBuffer, 4);
	
	CReplaceColorCodes(sBuffer2, iAuthor);
	CSendMessage(iClient, sBuffer2, iAuthor);
}

/**
 * Prints a message to all clients in the chat area.
 * Supports color tags and teamcolor tag.
 *
 * @param author	  Author index whose color will be used for teamcolor tag.
 * @param message   Message (formatting rules).
 * @noreturn
 *
 * On error/Errors:   If the author is not connected an error will be thrown.
 */
stock void CPrintToChatAllEx(int iAuthor, const char[] sMessage, any ...)
{
	CCheckTrie();
	
	if(iAuthor <= 0 || iAuthor > MaxClients)
	{
		ThrowError("Invalid client index %i", iAuthor);
	}
	
	if(!IsClientInGame(iAuthor))
	{
		ThrowError("Client %i is not in game", iAuthor);
	}
	
	char sBuffer[MAX_BUFFER_LENGTH], sBuffer2[MAX_BUFFER_LENGTH];
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || CSkipList[i])
		{
			CSkipList[i] = false;
			continue;
		}
		
		SetGlobalTransTarget(i);
		
		Format(sBuffer, sizeof(sBuffer), "\x01%s", sMessage);
		VFormat(sBuffer2, sizeof(sBuffer2), sBuffer, 3);
		
		CReplaceColorCodes(sBuffer2, iAuthor);
		CSendMessage(i, sBuffer2, iAuthor);
	}
}

/**
 * Sends a SayText2 usermessage
 *
 * @param client	Client to send usermessage to
 * @param message	Message to send
 * @noreturn
 */
stock void CSendMessage(int iClient, const char[] sMessage, int iAuthor=0)
{
	if(iAuthor == 0)
	{
		iAuthor = iClient;
	}
	
	char sBuffer[MAX_MESSAGE_LENGTH], sGame[16];
	
	GetGameFolderName(sGame, sizeof(sGame));
	
	strcopy(sBuffer, sizeof(sBuffer), sMessage);
	
	UserMsg umIndex = GetUserMessageId("SayText2");
	
	if(umIndex == INVALID_MESSAGE_ID)
	{
		if(StrEqual(sGame, "dod"))
		{
			int iTeam = GetClientTeam(iAuthor);
			
			if(iTeam == 0)
			{
				ReplaceString(sBuffer, sizeof(sBuffer), "\x03", "\x04", false); // Unassigned gets green
			} else {
				char sTemp[16];
				
				Format(sTemp, sizeof(sTemp), "\x07%06X", CTeamColors[GAME_DODS][iTeam - 1]);
				ReplaceString(sBuffer, sizeof(sBuffer), "\x03", sTemp, false);
			}
		}
		
		PrintToChat(iClient, "%s", sBuffer);
		return;
	}
	
	Handle hBuf = StartMessageOne("SayText2", iClient, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
	
	if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf)
	{
		PbSetInt(hBuf, "ent_idx", iAuthor);
		PbSetBool(hBuf, "chat", true);
		PbSetString(hBuf, "msg_name", sBuffer);
		PbAddString(hBuf, "params", "");
		PbAddString(hBuf, "params", "");
		PbAddString(hBuf, "params", "");
		PbAddString(hBuf, "params", "");
	} else {
		BfWriteByte(hBuf, iAuthor); // Message author
		BfWriteByte(hBuf, true); // Chat message
		BfWriteString(hBuf, sBuffer); // Message text
	}
	
	EndMessage();
}

/**
 * This function should only be used right in front of
 * CPrintToChatAll or CPrintToChatAllEx. It causes those functions
 * to skip the specified client when printing the message.
 * After printing the message, the client will no longer be skipped.
 *
 * @param client   Client index
 * @noreturn
 */
stock void CSkipNextClient(int iClient)
{
	if(iClient <= 0 || iClient > MaxClients)
	{
		ThrowError("Invalid client index %i", iClient);
	}
	
	CSkipList[iClient] = true;
}

/**
 * Checks if the colors trie is initialized and initializes it if it's not (used internally)
 *
 * @return			No return
 */
stock void CCheckTrie()
{
	if(CTrie == INVALID_HANDLE)
	{
		CTrie = InitColorTrie();
	}
}

/**
 * Replaces color tags in a string with color codes (used internally by CPrintToChat, CPrintToChatAll, CPrintToChatEx, and CPrintToChatAllEx
 *
 * @param sBuffer		String.
 * @param author		Optional client index to use for {teamcolor} tags, or 0 for none
 * @param removeTags	Optional boolean value to determine whether we're replacing tags with colors, or just removing tags, used by CRemoveTags
 * @param maxlen		Optional value for max sBuffer length, used by CRemoveTags
 * @noreturn
 *
 * On error/Errors:		If the client index passed for author is invalid or not in game.
 */
stock void CReplaceColorCodes(char[] sBuffer, int iAuthor=0, bool bRemoveTags=false, int iMaxlen=MAX_BUFFER_LENGTH)
{
	CCheckTrie();
	
	if(!bRemoveTags)
	{
		ReplaceString(sBuffer, iMaxlen, "{default}", "\x01", false);
	} else {
		ReplaceString(sBuffer, iMaxlen, "{default}", "", false);
		ReplaceString(sBuffer, iMaxlen, "{teamcolor}", "", false);
	}
	
	if(iAuthor != 0 && !bRemoveTags)
	{
		if(iAuthor < 0 || iAuthor > MaxClients)
		{
			ThrowError("Invalid client index %i", iAuthor);
		}
		
		if(!IsClientInGame(iAuthor))
		{
			ThrowError("Client %i is not in game", iAuthor);
		}
		
		ReplaceString(sBuffer, iMaxlen, "{teamcolor}", "\x03", false);
	}
	
	char sBuff[32], sTag[32];
	char sOutput[MAX_BUFFER_LENGTH];
	int iCursor = 0;
	int iValue;
	
	strcopy(sOutput, iMaxlen, sBuffer);
	
 		// Since the string's size is going to be changing, output will hold the replaced string and we'll search sBuffer
	Handle hRegex = CompileRegex("{[a-zA-Z0-9]+}");
	
	for(int i = 0; i < 1000; i++)
	{ // The RegEx extension is quite flaky, so we have to loop here :/. This loop is supposed to be infinite and broken by return, but conditions have been added to be safe.
		if(MatchRegex(hRegex, sBuffer[iCursor]) < 1)
		{
			CloseHandle(hRegex);
			
			strcopy(sBuffer, iMaxlen, sOutput);
			
			return;
		}
		
		GetRegexSubString(hRegex, 0, sTag, sizeof(sTag));
		
		CStrToLower(sTag);
		
		iCursor = StrContains(sBuffer[iCursor], sTag, false) + iCursor + 1;
		
		strcopy(sBuff, sizeof(sBuff), sTag);
		
		ReplaceString(sBuff, sizeof(sBuff), "{", "");
		ReplaceString(sBuff, sizeof(sBuff), "}", "");
		
		if(!GetTrieValue(CTrie, sBuff, iValue))
		{
			continue;
		}
		
		if(bRemoveTags)
		{
			ReplaceString(sOutput, iMaxlen, sTag, "", false);
		} else {
			Format(sBuff, sizeof(sBuff), "\x07%06X", iValue);
			
			ReplaceString(sOutput, iMaxlen, sTag, sBuff, false);
		}
	}
	
	LogError("[MORE COLORS] Infinite loop broken.");
}

/**
 * Gets a part of a string
 *
 * @param input			String to get the part from
 * @param output		Buffer to write to
 * @param maxlen		Max length of output sBuffer
 * @param start			Position to start at
 * @param numChars		Number of characters to return, or 0 for the end of the string
 * @noreturn
 */
stock void CSubString(const char[] sInput, char[] sOutput, int iMaxlen, int iStart, int iNumChars=0)
{
	int i = 0;
	
	for(;;)
	{
		if(i == iMaxlen - 1 || i >= iNumChars || sInput[iStart + i] == '\0')
		{
			sOutput[i] = '\0';
			return;
		}
		
		sOutput[i] = sInput[iStart + i];
		i++;
	}
}

/**
 * Converts a string to lowercase
 *
 * @param sBuffer		String to convert
 * @noreturn
 */
stock void CStrToLower(char[] sBuffer)
{
	int iLen = strlen(sBuffer);
	
	for(int i = 0; i < iLen; i++)
	{
		sBuffer[i] = CharToLower(sBuffer[i]);
	}
}

/**
 * Adds a color to the colors trie
 *
 * @param name			Color name, without braces
 * @param color			Hexadecimal representation of the color (0xRRGGBB)
 * @return				True if color was added successfully, false if a color already exists with that name
 */
stock bool CAddColor(const char[] sName, int iColor)
{
	CCheckTrie();
	
	int iValue;
	
	if(GetTrieValue(CTrie, sName, iValue))
	{
		return false;
	}
	
	char sIntName[64];
	
	strcopy(sIntName, sizeof(sIntName), sName);
	
	CStrToLower(sIntName);
	
	SetTrieValue(CTrie, sIntName, iColor);
	
	return true;
}

/**
 * Removes color tags from a message
 *
 * @param message		Message to remove tags from
 * @param maxlen		Maximum sBuffer length
 * @noreturn
 */
stock void CRemoveTags(char[] sMessage, int iMaxlen)
{
	CReplaceColorCodes(sMessage, 0, true, iMaxlen);
}

/**
 * Replies to a command with colors
 *
 * @param client		Client to reply to
 * @param message		Message (formatting rules)
 * @noreturn
 */
stock void CReplyToCommand(int iClient, const char[] sMessage, any ...)
{
	char sBuffer[MAX_BUFFER_LENGTH];
	
	
	SetGlobalTransTarget(iClient);
	
	VFormat(sBuffer, sizeof(sBuffer), sMessage, 3);
	
	if(GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		CRemoveTags(sBuffer, sizeof(sBuffer));
		
		PrintToConsole(iClient, "%s", sBuffer);
	} else {
		CPrintToChat(iClient, "%s", sBuffer);
	}
}

/**
 * Replies to a command with colors
 *
 * @param client		Client to reply to
 * @param author		Client to use for {teamcolor}
 * @param message		Message (formatting rules)
 * @noreturn
 */
stock void CReplyToCommandEx(int iClient, int iAuthor, const char[] sMessage, any ...)
{
	char sBuffer[MAX_BUFFER_LENGTH];
	
	SetGlobalTransTarget(iClient);
	
	VFormat(sBuffer, sizeof(sBuffer), sMessage, 4);
	
	if(GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		CRemoveTags(sBuffer, sizeof(sBuffer));
		
		PrintToConsole(iClient, "%s", sBuffer);
	} else {
		CPrintToChatEx(iClient, iAuthor, "%s", sBuffer);
	}
}

/**
 * Shows admin activity with colors
 *
 * @param client		Client performing an action
 * @param message		Message (formatting rules)
 * @noreturn
 */
stock void CShowActivity(int iClient, const char[] sMessage, any ...)
{
	CCheckTrie();
	
	if(iClient < 0 || iClient > MaxClients)
	{
		ThrowError("Invalid client index %d", iClient);
	}
	
	if(iClient != 0 && !IsClientInGame(iClient))
	{
		ThrowError("Client %d is not in game", iClient);
	}
	
	char sBuffer[MAX_BUFFER_LENGTH], sBuffer2[MAX_BUFFER_LENGTH];
	
	Format(sBuffer, sizeof(sBuffer), "\x01%s", sMessage);
	VFormat(sBuffer2, sizeof(sBuffer2), sBuffer, 3);
	
	CReplaceColorCodes(sBuffer2);
	
	ShowActivity(iClient, "%s", sBuffer2);
}

/**
 * Shows admin activity with colors
 *
 * @param client		Client performing an action
 * @param tag			Tag to prepend to the message (color tags supported)
 * @param message		Message (formatting rules)
 * @noreturn
 */
stock void CShowActivityEx(int iClient, const char[] sTag, const char[] sMessage, any ...)
{
	CCheckTrie();
	
	if(iClient < 0 || iClient > MaxClients)
	{
		ThrowError("Invalid client index %d", iClient);
	}
	
	if(iClient != 0 && !IsClientInGame(iClient))
	{
		ThrowError("Client %d is not in game", iClient);
	}
	
	char sBuffer[MAX_BUFFER_LENGTH], sBuffer2[MAX_BUFFER_LENGTH];
	
	Format(sBuffer, sizeof(sBuffer), "\x01%s", sMessage);
	VFormat(sBuffer2, sizeof(sBuffer2), sBuffer, 4);
	
	CReplaceColorCodes(sBuffer2);
	
	strcopy(sBuffer, sizeof(sBuffer), sTag);
	CReplaceColorCodes(sBuffer);
	
	ShowActivityEx(iClient, sTag, "%s", sBuffer2);
}

/**
 * Shows admin activity with colors
 *
 * @param client		Client performing an action
 * @param tag			Tag to prepend to the message (color tags supported)
 * @param message		Message (formatting rules)
 * @noreturn
 */
stock void CShowActivity2(int iClient, const char[] sTag, const char[] sMessage, any ...)
{
	CCheckTrie();
	
	if(iClient < 0 || iClient > MaxClients)
	{
		ThrowError("Invalid client index %d", iClient);
	}
	
	if(iClient != 0 && !IsClientInGame(iClient))
	{
		ThrowError("Client %d is not in game", iClient);
	}
	
	char sBuffer[MAX_BUFFER_LENGTH], sBuffer2[MAX_BUFFER_LENGTH];
	
	Format(sBuffer, sizeof(sBuffer), "\x01%s", sMessage);
	VFormat(sBuffer2, sizeof(sBuffer2), sBuffer, 4);
	
	CReplaceColorCodes(sBuffer2);
	
	strcopy(sBuffer, sizeof(sBuffer), sTag);
	CReplaceColorCodes(sBuffer);
	
	ShowActivity2(iClient, sBuffer, "%s", sBuffer2);
}

/**
 * Determines whether a color name exists
 *
 * @param color			The color name to check
 * @return				True if the color exists, false otherwise
 */
stock bool CColorExists(const char[] sColor)
{
	CCheckTrie();
	
	int iTemp;
	
	return GetTrieValue(CTrie, sColor, iTemp);
}

/**
 * Returns the hexadecimal representation of a client's team color (will NOT initialize the trie)
 *
 * @param client		Client to get the team color for
 * @return				Client's team color in hexadecimal, or green if unknown
 * On error/Errors:		If the client index passed is invalid or not in game.
 */
stock int CGetTeamColor(int iClient)
{
	if(iClient <= 0 || iClient > MaxClients)
	{
		ThrowError("Invalid client index %i", iClient);
	}
	
	if(!IsClientInGame(iClient))
	{
		ThrowError("Client %i is not in game", iClient);
	}
	
	int iValue;
	
	switch(GetClientTeam(iClient))
	{
		case 1: {
			iValue = COLOR_GRAY;
		}
		case 2: {
			iValue = COLOR_RED;
		}
		case 3: {
			iValue = COLOR_BLUE;
		}
		default: {
			iValue = COLOR_GREEN;
		}
	}
	
	return iValue;
}

stock Handle InitColorTrie()
{
	Handle hTrie = CreateTrie();
	
	SetTrieValue(hTrie, "aliceblue", 0xF0F8FF);
	SetTrieValue(hTrie, "allies", 0x4D7942); // same as Allies team in DoD:S
	SetTrieValue(hTrie, "ancient", 0xEB4B4B); // same as Ancient item rarity in Dota 2
	SetTrieValue(hTrie, "antiquewhite", 0xFAEBD7);
	SetTrieValue(hTrie, "aqua", 0x00FFFF);
	SetTrieValue(hTrie, "aquamarine", 0x7FFFD4);
	SetTrieValue(hTrie, "arcana", 0xADE55C); // same as Arcana item rarity in Dota 2
	SetTrieValue(hTrie, "axis", 0xFF4040); // same as Axis team in DoD:S
	SetTrieValue(hTrie, "azure", 0x007FFF);
	SetTrieValue(hTrie, "beige", 0xF5F5DC);
	SetTrieValue(hTrie, "bisque", 0xFFE4C4);
	SetTrieValue(hTrie, "black", 0x000000);
	SetTrieValue(hTrie, "blanchedalmond", 0xFFEBCD);
	SetTrieValue(hTrie, "blue", 0x99CCFF); // same as BLU/Counter-Terrorist team color
	SetTrieValue(hTrie, "blueviolet", 0x8A2BE2);
	SetTrieValue(hTrie, "brown", 0xA52A2A);
	SetTrieValue(hTrie, "burlywood", 0xDEB887);
	SetTrieValue(hTrie, "cadetblue", 0x5F9EA0);
	SetTrieValue(hTrie, "chartreuse", 0x7FFF00);
	SetTrieValue(hTrie, "chocolate", 0xD2691E);
	SetTrieValue(hTrie, "collectors", 0xAA0000); // same as Collector's item quality in TF2
	SetTrieValue(hTrie, "common", 0xB0C3D9); // same as Common item rarity in Dota 2
	SetTrieValue(hTrie, "community", 0x70B04A); // same as Community item quality in TF2
	SetTrieValue(hTrie, "coral", 0xFF7F50);
	SetTrieValue(hTrie, "cornflowerblue", 0x6495ED);
	SetTrieValue(hTrie, "cornsilk", 0xFFF8DC);
	SetTrieValue(hTrie, "corrupted", 0xA32C2E); // same as Corrupted item quality in Dota 2
	SetTrieValue(hTrie, "crimson", 0xDC143C);
	SetTrieValue(hTrie, "cyan", 0x00FFFF);
	SetTrieValue(hTrie, "darkblue", 0x00008B);
	SetTrieValue(hTrie, "darkcyan", 0x008B8B);
	SetTrieValue(hTrie, "darkgoldenrod", 0xB8860B);
	SetTrieValue(hTrie, "darkgray", 0xA9A9A9);
	SetTrieValue(hTrie, "darkgrey", 0xA9A9A9);
	SetTrieValue(hTrie, "darkgreen", 0x006400);
	SetTrieValue(hTrie, "darkkhaki", 0xBDB76B);
	SetTrieValue(hTrie, "darkmagenta", 0x8B008B);
	SetTrieValue(hTrie, "darkolivegreen", 0x556B2F);
	SetTrieValue(hTrie, "darkorange", 0xFF8C00);
	SetTrieValue(hTrie, "darkorchid", 0x9932CC);
	SetTrieValue(hTrie, "darkred", 0x8B0000);
	SetTrieValue(hTrie, "darksalmon", 0xE9967A);
	SetTrieValue(hTrie, "darkseagreen", 0x8FBC8F);
	SetTrieValue(hTrie, "darkslateblue", 0x483D8B);
	SetTrieValue(hTrie, "darkslategray", 0x2F4F4F);
	SetTrieValue(hTrie, "darkslategrey", 0x2F4F4F);
	SetTrieValue(hTrie, "darkturquoise", 0x00CED1);
	SetTrieValue(hTrie, "darkviolet", 0x9400D3);
	SetTrieValue(hTrie, "deeppink", 0xFF1493);
	SetTrieValue(hTrie, "deepskyblue", 0x00BFFF);
	SetTrieValue(hTrie, "dimgray", 0x696969);
	SetTrieValue(hTrie, "dimgrey", 0x696969);
	SetTrieValue(hTrie, "dodgerblue", 0x1E90FF);
	SetTrieValue(hTrie, "exalted", 0xCCCCCD); // same as Exalted item quality in Dota 2
	SetTrieValue(hTrie, "firebrick", 0xB22222);
	SetTrieValue(hTrie, "floralwhite", 0xFFFAF0);
	SetTrieValue(hTrie, "forestgreen", 0x228B22);
	SetTrieValue(hTrie, "frozen", 0x4983B3); // same as Frozen item quality in Dota 2
	SetTrieValue(hTrie, "fuchsia", 0xFF00FF);
	SetTrieValue(hTrie, "fullblue", 0x0000FF);
	SetTrieValue(hTrie, "fullred", 0xFF0000);
	SetTrieValue(hTrie, "gainsboro", 0xDCDCDC);
	SetTrieValue(hTrie, "genuine", 0x4D7455); // same as Genuine item quality in TF2
	SetTrieValue(hTrie, "ghostwhite", 0xF8F8FF);
	SetTrieValue(hTrie, "gold", 0xFFD700);
	SetTrieValue(hTrie, "goldenrod", 0xDAA520);
	SetTrieValue(hTrie, "gray", 0xCCCCCC); // same as spectator team color
	SetTrieValue(hTrie, "grey", 0xCCCCCC);
	SetTrieValue(hTrie, "green", 0x3EFF3E);
	SetTrieValue(hTrie, "greenyellow", 0xADFF2F);
	SetTrieValue(hTrie, "haunted", 0x38F3AB); // same as Haunted item quality in TF2
	SetTrieValue(hTrie, "honeydew", 0xF0FFF0);
	SetTrieValue(hTrie, "hotpink", 0xFF69B4);
	SetTrieValue(hTrie, "immortal", 0xE4AE33); // same as Immortal item rarity in Dota 2
	SetTrieValue(hTrie, "indianred", 0xCD5C5C);
	SetTrieValue(hTrie, "indigo", 0x4B0082);
	SetTrieValue(hTrie, "ivory", 0xFFFFF0);
	SetTrieValue(hTrie, "khaki", 0xF0E68C);
	SetTrieValue(hTrie, "lavender", 0xE6E6FA);
	SetTrieValue(hTrie, "lavenderblush", 0xFFF0F5);
	SetTrieValue(hTrie, "lawngreen", 0x7CFC00);
	SetTrieValue(hTrie, "legendary", 0xD32CE6); // same as Legendary item rarity in Dota 2
	SetTrieValue(hTrie, "lemonchiffon", 0xFFFACD);
	SetTrieValue(hTrie, "lightblue", 0xADD8E6);
	SetTrieValue(hTrie, "lightcoral", 0xF08080);
	SetTrieValue(hTrie, "lightcyan", 0xE0FFFF);
	SetTrieValue(hTrie, "lightgoldenrodyellow", 0xFAFAD2);
	SetTrieValue(hTrie, "lightgray", 0xD3D3D3);
	SetTrieValue(hTrie, "lightgrey", 0xD3D3D3);
	SetTrieValue(hTrie, "lightgreen", 0x99FF99);
	SetTrieValue(hTrie, "lightpink", 0xFFB6C1);
	SetTrieValue(hTrie, "lightsalmon", 0xFFA07A);
	SetTrieValue(hTrie, "lightseagreen", 0x20B2AA);
	SetTrieValue(hTrie, "lightskyblue", 0x87CEFA);
	SetTrieValue(hTrie, "lightslategray", 0x778899);
	SetTrieValue(hTrie, "lightslategrey", 0x778899);
	SetTrieValue(hTrie, "lightsteelblue", 0xB0C4DE);
	SetTrieValue(hTrie, "lightyellow", 0xFFFFE0);
	SetTrieValue(hTrie, "lime", 0x00FF00);
	SetTrieValue(hTrie, "limegreen", 0x32CD32);
	SetTrieValue(hTrie, "linen", 0xFAF0E6);
	SetTrieValue(hTrie, "magenta", 0xFF00FF);
	SetTrieValue(hTrie, "maroon", 0x800000);
	SetTrieValue(hTrie, "mediumaquamarine", 0x66CDAA);
	SetTrieValue(hTrie, "mediumblue", 0x0000CD);
	SetTrieValue(hTrie, "mediumorchid", 0xBA55D3);
	SetTrieValue(hTrie, "mediumpurple", 0x9370D8);
	SetTrieValue(hTrie, "mediumseagreen", 0x3CB371);
	SetTrieValue(hTrie, "mediumslateblue", 0x7B68EE);
	SetTrieValue(hTrie, "mediumspringgreen", 0x00FA9A);
	SetTrieValue(hTrie, "mediumturquoise", 0x48D1CC);
	SetTrieValue(hTrie, "mediumvioletred", 0xC71585);
	SetTrieValue(hTrie, "midnightblue", 0x191970);
	SetTrieValue(hTrie, "mintcream", 0xF5FFFA);
	SetTrieValue(hTrie, "mistyrose", 0xFFE4E1);
	SetTrieValue(hTrie, "moccasin", 0xFFE4B5);
	SetTrieValue(hTrie, "mythical", 0x8847FF); // same as Mythical item rarity in Dota 2
	SetTrieValue(hTrie, "navajowhite", 0xFFDEAD);
	SetTrieValue(hTrie, "navy", 0x000080);
	SetTrieValue(hTrie, "normal", 0xB2B2B2); // same as Normal item quality in TF2
	SetTrieValue(hTrie, "oldlace", 0xFDF5E6);
	SetTrieValue(hTrie, "olive", 0x9EC34F);
	SetTrieValue(hTrie, "olivedrab", 0x6B8E23);
	SetTrieValue(hTrie, "orange", 0xFFA500);
	SetTrieValue(hTrie, "orangered", 0xFF4500);
	SetTrieValue(hTrie, "orchid", 0xDA70D6);
	SetTrieValue(hTrie, "palegoldenrod", 0xEEE8AA);
	SetTrieValue(hTrie, "palegreen", 0x98FB98);
	SetTrieValue(hTrie, "paleturquoise", 0xAFEEEE);
	SetTrieValue(hTrie, "palevioletred", 0xD87093);
	SetTrieValue(hTrie, "papayawhip", 0xFFEFD5);
	SetTrieValue(hTrie, "peachpuff", 0xFFDAB9);
	SetTrieValue(hTrie, "peru", 0xCD853F);
	SetTrieValue(hTrie, "pink", 0xFFC0CB);
	SetTrieValue(hTrie, "plum", 0xDDA0DD);
	SetTrieValue(hTrie, "powderblue", 0xB0E0E6);
	SetTrieValue(hTrie, "purple", 0x800080);
	SetTrieValue(hTrie, "rare", 0x4B69FF); // same as Rare item rarity in Dota 2
	SetTrieValue(hTrie, "red", 0xFF4040); // same as RED/Terrorist team color
	SetTrieValue(hTrie, "rosybrown", 0xBC8F8F);
	SetTrieValue(hTrie, "royalblue", 0x4169E1);
	SetTrieValue(hTrie, "saddlebrown", 0x8B4513);
	SetTrieValue(hTrie, "salmon", 0xFA8072);
	SetTrieValue(hTrie, "sandybrown", 0xF4A460);
	SetTrieValue(hTrie, "seagreen", 0x2E8B57);
	SetTrieValue(hTrie, "seashell", 0xFFF5EE);
	SetTrieValue(hTrie, "selfmade", 0x70B04A); // same as Self-Made item quality in TF2
	SetTrieValue(hTrie, "sienna", 0xA0522D);
	SetTrieValue(hTrie, "silver", 0xC0C0C0);
	SetTrieValue(hTrie, "skyblue", 0x87CEEB);
	SetTrieValue(hTrie, "slateblue", 0x6A5ACD);
	SetTrieValue(hTrie, "slategray", 0x708090);
	SetTrieValue(hTrie, "slategrey", 0x708090);
	SetTrieValue(hTrie, "snow", 0xFFFAFA);
	SetTrieValue(hTrie, "springgreen", 0x00FF7F);
	SetTrieValue(hTrie, "steelblue", 0x4682B4);
	SetTrieValue(hTrie, "strange", 0xCF6A32); // same as Strange item quality in TF2
	SetTrieValue(hTrie, "tan", 0xD2B48C);
	SetTrieValue(hTrie, "teal", 0x008080);
	SetTrieValue(hTrie, "thistle", 0xD8BFD8);
	SetTrieValue(hTrie, "tomato", 0xFF6347);
	SetTrieValue(hTrie, "turquoise", 0x40E0D0);
	SetTrieValue(hTrie, "uncommon", 0xB0C3D9); // same as Uncommon item rarity in Dota 2
	SetTrieValue(hTrie, "unique", 0xFFD700); // same as Unique item quality in TF2
	SetTrieValue(hTrie, "unusual", 0x8650AC); // same as Unusual item quality in TF2
	SetTrieValue(hTrie, "valve", 0xA50F79); // same as Valve item quality in TF2
	SetTrieValue(hTrie, "vintage", 0x476291); // same as Vintage item quality in TF2
	SetTrieValue(hTrie, "violet", 0xEE82EE);
	SetTrieValue(hTrie, "wheat", 0xF5DEB3);
	SetTrieValue(hTrie, "white", 0xFFFFFF);
	SetTrieValue(hTrie, "whitesmoke", 0xF5F5F5);
	SetTrieValue(hTrie, "yellow", 0xFFFF00);
	SetTrieValue(hTrie, "yellowgreen", 0x9ACD32);
	
	return hTrie;
}