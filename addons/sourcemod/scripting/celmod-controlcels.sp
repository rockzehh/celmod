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
		OnMapStart();
		
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
	g_bTouched[iClient] = false;
}

public void OnClientDisconnect(int iClient)
{
	g_bTouched[iClient] = false;
}

public void OnMapStart()
{
	PrecacheSound("buttons/button19.wav", true);
	PrecacheSound("buttons/combine_button1.wav", true);
	PrecacheSound("buttons/combine_button_locked.wav", true);
}

//Commands:
public Action Command_SpawnButton(int iClient, int iArgs)
{
	char sOption[64];
	float fAngles[3], fOrigin[3];
	
	GetCmdArg(1, sOption, sizeof(sOption));
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	if (!Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxCelLimit", Cel_GetCelCount(iClient));
		return Plugin_Handled;
	}
	
	int iBit = Cel_SpawnButton(iClient, fAngles, fOrigin, 255, 255, 255, 255);
	
	Cel_TeleportInfrontOfClient(iClient, iBit, 35.0);
	
	Cel_ReplyToCommand(iClient, "%t", "SpawnButton");
	
	return Plugin_Handled;
}

//Natives:
public int Native_GetTriggerFunction(Handle hPlugin, int iNumParams)
{
	char sClassname[64];
	
	TriggerFunctionType cttType;
	
	int iEntity = GetNativeCell(1);
	
	GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
	
	if(StrEqual(sClassname, "bit_trigger_button"))
	{
		cttType = TRIGGERTYPE_BUTTON;
	}else if(StrEqual(sClassname, "bit_trigger_step"))
	{
		cttType = TRIGGERTYPE_STEP;
	}
	
	return view_as<int>(cttType);
}

public int Native_GetTriggerFunctionName(Handle hPlugin, int iNumParams)
{
	char sName[64];
	
	ControlTriggerType cttType = view_as<ControlTriggerType>(GetNativeCell(1));
	
	int iMaxLength = GetNativeCell(3);
	
	switch(cttType)
	{
		case TRIGGERTYPE_BUTTON:
		{
			Format(sName, sizeof(sName), "button cel");
		}
		case TRIGGERTYPE_STEP:
		{
			Format(sName, sizeof(sName), "trigger cel");
		}
	}
	
	SetNativeString(2, sName, iMaxLength);
}
public int Native_GetTriggerType(Handle hPlugin, int iNumParams)
{
	char sClassname[64];
	
	ControlTriggerType cttType;
	
	int iEntity = GetNativeCell(1);
	
	GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
	
	if(StrEqual(sClassname, "bit_trigger_button"))
	{
		cttType = TRIGGERTYPE_BUTTON;
	}else if(StrEqual(sClassname, "bit_trigger_step"))
	{
		cttType = TRIGGERTYPE_STEP;
	}
	
	return view_as<int>(cttType);
}

public int Native_GetTriggerTypeName(Handle hPlugin, int iNumParams)
{
	char sName[64];
	
	ControlTriggerType cttType = view_as<ControlTriggerType>(GetNativeCell(1));
	
	int iMaxLength = GetNativeCell(3);
	
	switch(cttType)
	{
		case TRIGGERTYPE_BUTTON:
		{
			Format(sName, sizeof(sName), "button cel");
		}
		case TRIGGERTYPE_STEP:
		{
			Format(sName, sizeof(sName), "trigger cel");
		}
	}
	
	SetNativeString(2, sName, iMaxLength);
}

public int Native_LinkBit(Handle hPlugin, int iNumParams)
{
	char sBit[32];
	float fLinkOrigin[2][3];
	int iEntity = GetNativeCell(2), iLink = GetNativeCell(1);
	
	g_bHasLink[iLink] = true;
				
	Format(sBit, sizeof(sBit), "link:%i", g_smLinkedBits[iLink].Size + 1);
				
	g_smLinkedBits[iLink].SetValue(sBit, EntIndexToEntRef(iEntity), false);
				
	g_iControllerEntity[iEntity] = iLink;
				
	Cel_GetEntityOrigin(iLink, fLinkOrigin[0]);
	Cel_GetEntityOrigin(iEntity, fLinkOrigin[1]);
				
	TE_SetupBeamPoints(fLinkOrigin[0], fLinkOrigin[1], Cel_GetBeamMaterial(), Cel_GetHaloMaterial(), 0, 15, 0.60, 1.0, 1.0, 1, 0.0, g_iOrange, 10); TE_SendToAll();
				
	EmitSoundToAll("buttons/button19.wav", iLink, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	EmitSoundToAll("buttons/button19.wav", iEntity, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	
	return true;
}

public int Native_IsTrigger(Handle hPlugin, int iNumParams)
{
	char sClassname[64];
	
	int iEntity = GetNativeCell(1);
	
	GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
	
	if(StrContains(sClassname, "bit_trigger_") != -1)
	{
		return true;
	}else{
		return false;
	}
}

public int Native_SpawnButton(Handle hPlugin, int iNumParams)
{
	float fAngles[3], fOrigin[3];
	int iBase, iClient = GetNativeCell(1), iColor[4];
	
	GetNativeArray(2, fAngles, 3);
	GetNativeArray(3, fOrigin, 3);
	iColor[0] = GetNativeCell(4);
	iColor[1] = GetNativeCell(5);
	iColor[2] = GetNativeCell(6);
	iColor[3] = GetNativeCell(7);
	
	iBase = CreateEntityByName("prop_physics_override");
	
	PrecacheModel("models/props_combine/combinebutton.mdl");
	
	DispatchKeyValue(iBase, "model", "models/props_combine/combinebutton.mdl");
	DispatchKeyValue(iBase, "classname", "bit_trigger_button");
	DispatchKeyValue(iBase, "spawnflags", "256");
	
	DispatchSpawn(iBase);
	
	fAngles[1] += 180;
	
	TeleportEntity(iBase, fOrigin, fAngles, NULL_VECTOR);
	
	g_bHasLink[iBase] = false;
	
	g_smLinkedBits[iBase] = new StringMap();
	
	Cel_AddToCelCount(iClient);
	Cel_SetColor(iBase, iColor[0], iColor[1], iColor[2], iColor[3]);
	Cel_SetRainbow(iBase, false);
	Cel_SetEntity(iBase, true);
	Cel_SetMotion(iBase, false);
	Cel_SetOwner(iClient, iBase);
	Cel_SetSolid(iBase, true);
	Cel_LockEntity(iBase, false);
	Cel_SetRenderFX(iBase, RENDERFX_NONE);
	
	SDKHook(iBase, SDKHook_UsePost, Hook_ButtonUse);
	
	return iBase;
}

public int Native_TriggerEntity(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1), iEntity = GetNativeCell(2);
	
	if(Cel_IsEntity(iEntity))
	{
		switch(Cel_GetEntityType(iEntity))
		{
			case ENTTYPE_DOOR:
			{
				AcceptEntityInput(iEntity, "Toggle", iClient);
			}
			
			case ENTTYPE_LIGHT:
			{
				AcceptEntityInput(Entity_GetEntityAttachment(iEntity), "Toggle", iClient);
				
			}
			
			case ENTTYPE_EFFECT:
			{
				Cel_ActivateEffect(iEntity);
			}
			
			case ENTTYPE_MUSIC:
			{
				AcceptEntityInput(iEntity, "Use", iClient);
			}
			
			case ENTTYPE_SOUND:
			{
				AcceptEntityInput(iEntity, "Use", iClient);
			}
		}
	}
	
	return true;
}

//Hooks:
public void Hook_ButtonUse(int iEntity, int iActivator, int iCaller, UseType utType, float fValue)
{
	if(!Cel_IsLocked(iEntity))
	{
		if(g_bHasLink[iEntity])
		{
			StringMapSnapshot smsSnapshot = g_smLinkedBits[iEntity].Snapshot();
			
			int iKeyCount = smsSnapshot.Length, iLinkedEntity;
			
			char sKey[32];
			
			for (int i = 0; i < iKeyCount; i++)
			{
				smsSnapshot.GetKey(i, sKey, sizeof(sKey));
				
				if(g_smLinkedBits[iEntity].GetValue(sKey, iLinkedEntity))
				{
					Cel_TriggerEntity(iActivator, EntRefToEntIndex(iLinkedEntity));
				}
			}
			
			delete smsSnapshot;
			
			EmitSoundToAll("buttons/combine_button1.wav", iEntity, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}else{
			if(Cel_CheckOwner(iActivator, iEntity))
			{
				ReplySource rpSource = GetCmdReplySource();
				SetCmdReplySource(SM_REPLY_TO_CHAT);
				//This button isn't linked to any bits yet. Type {green}[tag]link{default} on the button to get started!
				Cel_ReplyToCommandEntity(iActivator, iEntity, "%t", "NotLinked-Button");
				SetCmdReplySource(rpSource);
			}
			
			EmitSoundToAll("buttons/combine_button_locked.wav", iEntity, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}
	}
}
