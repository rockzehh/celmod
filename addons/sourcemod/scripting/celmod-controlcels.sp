#pragma semicolon 1

#include <celmod>

#pragma newdecls required

bool g_bLate;
bool g_bTouched[MAXPLAYERS + 1];

ControlTriggerType g_cttTriggerType[MAXENTITIES + 1];

ConVar g_cvMaxLinkedBits;

bool g_bCreatingLink[MAXPLAYERS + 1];
bool g_bHasLink[MAXENTITIES + 1];

int g_iControllerEntity[MAXENTITIES + 1];
int g_iLinkingEntity[MAXPLAYERS + 1];
int g_iLinkStage[MAXPLAYERS + 1];
int g_iMaxLinkedBits;

StringMap g_smLinkedBits[MAXENTITIES + 1];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_GetControllerEntity", Native_GetControllerEntity);
	CreateNative("Cel_GetLinkedEntities", Native_GetLinkedEntities);
	CreateNative("Cel_GetLinkedEntity", Native_GetLinkedEntity);
	CreateNative("Cel_GetTriggerFunction", Native_GetTriggerFunction);
	CreateNative("Cel_GetTriggerFunctionName", Native_GetTriggerFunctionName);
	CreateNative("Cel_GetTriggerType", Native_GetTriggerType);
	CreateNative("Cel_GetTriggerTypeName", Native_GetTriggerTypeName);
	CreateNative("Cel_HasLink", Native_HasLink);
	CreateNative("Cel_IsTrigger", Native_IsTrigger);
	CreateNative("Cel_LinkEntity", Native_LinkEntity);
	CreateNative("Cel_RemoveLinkFromEntity", Native_RemoveLinkFromEntity);
	CreateNative("Cel_SetTriggerFunction", Native_SetTriggerFunction);
	CreateNative("Cel_SpawnButton", Native_SpawnButton);
	CreateNative("Cel_SpawnLink", Native_SpawnLink);
	CreateNative("Cel_SpawnTrigger", Native_SpawnTrigger);
	CreateNative("Cel_TriggerEntity", Native_TriggerEntity);
	
	g_bLate = bLate;
	
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "|CelMod| Control Cels",
	author = CEL_AUTHOR,
	description = "Handles all the control cels (buttons/triggers) and their various functions.",
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
