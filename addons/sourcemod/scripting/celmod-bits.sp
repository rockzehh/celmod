#pragma semicolon 1

#include <celmod>

#pragma newdecls required

bool g_bLate;
bool g_bTouched[MAXPLAYERS + 1];

AmmoBitType g_abtAmmoType[MAXENTITIES + 1];
AmmoCrateType g_actAmmoCrateType[MAXENTITIES + 1];
ChargerType g_ctChargerType[MAXENTITIES + 1];
WeaponBitType g_wbtWeaponType[MAXENTITIES + 1];

ControlTriggerType g_cttTriggerType[MAXENTITIES + 1];

bool g_bCreatingLink[MAXPLAYERS + 1];
bool g_bHasLink[MAXENTITIES + 1];

int g_iLinkedEntity[MAXENTITIES + 1];
int g_iLinkingEntity[MAXPLAYERS + 1];
int g_iLinkStage[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_GetAmmoType", Native_GetAmmoType);
	CreateNative("Cel_GetAmmoTypeFromName", Native_GetAmmoTypeFromName);
	CreateNative("Cel_GetAmmoTypeName", Native_GetAmmoTypeName);
	CreateNative("Cel_GetAmmoCrateType", Native_GetAmmoCrateType);
	CreateNative("Cel_GetAmmoCrateTypeFromName", Native_GetAmmoCrateTypeFromName);
	CreateNative("Cel_GetAmmoCrateTypeName", Native_GetAmmoCrateTypeName);
	CreateNative("Cel_GetChargerType", Native_GetChargerType);
	CreateNative("Cel_GetChargerTypeFromName", Native_GetChargerTypeFromName);
	CreateNative("Cel_GetChargerTypeName", Native_GetChargerTypeName);
	CreateNative("Cel_GetTriggerType", Native_GetTriggerType);
	CreateNative("Cel_GetWeaponType", Native_GetWeaponType);
	CreateNative("Cel_GetWeaponTypeFromName", Native_GetWeaponTypeFromName);
	CreateNative("Cel_GetWeaponTypeName", Native_GetWeaponTypeName);
	CreateNative("Cel_IsTrigger", Native_IsTrigger);
	CreateNative("Cel_SpawnAmmoBit", Native_SpawnAmmoBit);
	CreateNative("Cel_SpawnAmmoCrate", Native_SpawnAmmoCrate);
	CreateNative("Cel_SpawnButton", Native_SpawnButton);
	CreateNative("Cel_SpawnCharger", Native_SpawnCharger);
	//CreateNative("Cel_SpawnTrigger", Native_SpawnTrigger);
	CreateNative("Cel_SpawnWeaponBit", Native_SpawnWeaponBit);
	CreateNative("Cel_TriggerEntity", Native_TriggerEntity);
	
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "|CelMod| Bits",
	author = CEL_AUTHOR,
	description = "Handles all the bit cels. (Triggers, Teleporters, Guns, Ammo crates, Buttons, etc.)",
	version = CEL_VERSION,
	url = CEL_URL
};

public void OnPluginStart()
{
	LoadTranslations("celmod.phrases");
	
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
	
	RegConsoleCmd("v_ammo", Command_SpawnAmmoBit, "|CelMod| Creates a ammo bit that will give ammo when the player touches it.");
	RegConsoleCmd("v_ammocrate", Command_SpawnAmmoCrateBit, "|CelMod| Creates a ammo crate bit that will give ammo to the player.");
	RegConsoleCmd("v_button", Command_SpawnButton, "|CelMod| Spawns a button trigger bit.");
	RegConsoleCmd("v_charger", Command_SpawnChargerBit, "|CelMod| Creates a health/suit charger bit that will give health/suit to the player.");
	RegConsoleCmd("v_link", Command_Link, "|CelMod| Creates a link between a trigger bit and an entity.");
	RegConsoleCmd("v_wep", Command_SpawnWeaponBit, "|CelMod| Creates a weapon bit that will give a weapon when the player touches it.");
}

public void OnClientPutInServer(int iClient)
{
	g_bTouched[iClient] = false;
}

public void OnClientDisconnect(int iClient)
{
	g_bTouched[iClient] = false;
}

public Action Command_Link(int iClient, int iArgs)
{
	char sOption[64];
	float fLinkOrigin[2][3];
	
	GetCmdArg(1, sOption, sizeof(sOption));
	
	if (Cel_GetClientAimTarget(iClient) == -1)
	{
		Cel_NotLooking(iClient);
		return Plugin_Handled;
	}
	
	int iEntity = Cel_GetClientAimTarget(iClient);
	
	switch(g_iLinkStage[iClient])
	{
		case 0:
		{
			if(!(Cel_GetEntityType(iEntity) == ENTTYPE_TRIGGER))
			{
				//You cannot make a link on a non-trigger bit.
				Cel_ReplyToCommand(iClient, "%t", "NotTriggerBit");
				return Plugin_Handled;
			}
			
			g_bCreatingLink[iClient] = true;
			g_iLinkingEntity[iClient] = iEntity;
			
			g_iLinkStage[iClient] = 1;
			
			//Started creating link. Type !link on another entity to complete the link.
			Cel_ReplyToCommand(iClient, "%t", "CreatingLink");
			return Plugin_Handled;
		}
		case 1:
		{
			if(Cel_CheckEntityType(iEntity, "door") || Cel_CheckEntityType(iEntity, "effect") || Cel_CheckEntityType(iEntity, "light"))
			{
				g_iLinkedEntity[g_iLinkingEntity[iClient]] = iEntity;
				g_bHasLink[g_iLinkingEntity[iClient]] = true;
				
				g_bCreatingLink[iClient] = false;
				g_iLinkStage[iClient] = 0;
				
				Cel_GetEntityOrigin(g_iLinkingEntity[iClient], fLinkOrigin[0]);
				Cel_GetEntityOrigin(iEntity, fLinkOrigin[1]);
				
				TE_SetupBeamPoints(fLinkOrigin[0], fLinkOrigin[1], Cel_GetBeamMaterial(), Cel_GetHaloMaterial(), 0, 15, 0.60, 1.0, 1.0, 1, 0.0, g_iOrange, 10); TE_SendToAll();
				
				PrecacheSound("buttons/button19.wav");
				EmitSoundToAll("buttons/button19.wav", g_iLinkingEntity[iClient], 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				EmitSoundToAll("buttons/button19.wav", iEntity, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				
				//Created trigger link.
				Cel_ReplyToCommand(iClient, "%t", "CreatedLink");
				return Plugin_Handled;
			}else{
				//You cannot make a link on a physics prop.
				Cel_ReplyToCommandEntity(iClient, iEntity, "%t", "CantLinkEntity");
				return Plugin_Handled;
			}
		}
	}
	
	return Plugin_Handled;
}

public Action Command_SpawnAmmoBit(int iClient, int iArgs)
{
	char sOption[64];
	float fAngles[3], fOrigin[3];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_BitAmmo");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sOption, sizeof(sOption));
	
	AmmoBitType abtType = Cel_GetAmmoTypeFromName(sOption);
	
	if (abtType == AMMOBIT_UNKNOWN)
	{
		Cel_ReplyToCommand(iClient, "%t", "InvalidBitAmmo");
		return Plugin_Handled;
	}
	
	if (!Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxCelLimit", Cel_GetCelCount(iClient));
		return Plugin_Handled;
	}
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	int iBit = Cel_SpawnAmmoBit(iClient, abtType, fAngles, fOrigin, 255, 255, 255, 255);
	
	Cel_TeleportInfrontOfClient(iClient, iBit, 20.0);
	
	Cel_ReplyToCommandEntity(iClient, iBit, "%t", "SpawnBitAmmo");
	
	return Plugin_Handled;
}

public Action Command_SpawnAmmoCrateBit(int iClient, int iArgs)
{
	char sOption[64];
	float fAngles[3], fOrigin[3];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_BitAmmoCrate");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sOption, sizeof(sOption));
	
	AmmoCrateType actType = Cel_GetAmmoCrateTypeFromName(sOption);
	
	if (actType == AMMOCRATEBIT_UNKNOWN)
	{
		Cel_ReplyToCommand(iClient, "%t", "InvalidBitAmmoCrate");
		return Plugin_Handled;
	}
	
	if (!Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxCelLimit", Cel_GetCelCount(iClient));
		return Plugin_Handled;
	}
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	int iBit = Cel_SpawnAmmoCrate(iClient, actType, fAngles, fOrigin, 255, 255, 255, 255);
	
	Cel_TeleportInfrontOfClient(iClient, iBit, 12.5);
	
	Cel_ReplyToCommandEntity(iClient, iBit, "%t", "SpawnBitAmmoCrate");
	
	return Plugin_Handled;
}

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

public Action Command_SpawnChargerBit(int iClient, int iArgs)
{
	char sOption[64];
	float fAngles[3], fOrigin[3];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_BitCharger");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sOption, sizeof(sOption));
	
	ChargerType ctType = Cel_GetChargerTypeFromName(sOption);
	
	if (ctType == CHARGERBIT_UNKNOWN)
	{
		Cel_ReplyToCommand(iClient, "%t", "InvalidBitCharger");
		return Plugin_Handled;
	}
	
	if (!Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxCelLimit", Cel_GetCelCount(iClient));
		return Plugin_Handled;
	}
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	int iBit = Cel_SpawnCharger(iClient, ctType, fAngles, fOrigin, 255, 255, 255, 255);
	
	Cel_TeleportInfrontOfClient(iClient, iBit, 45.0);
	
	Cel_ReplyToCommandEntity(iClient, iBit, "%t", "SpawnBitCharger");
	
	return Plugin_Handled;
}

public Action Command_SpawnWeaponBit(int iClient, int iArgs)
{
	char sOption[64];
	float fAngles[3], fOrigin[3];
	
	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_BitWeapon");
		return Plugin_Handled;
	}
	
	GetCmdArg(1, sOption, sizeof(sOption));
	
	WeaponBitType wbtType = Cel_GetWeaponTypeFromName(sOption);
	
	if (wbtType == WEPBIT_UNKNOWN)
	{
		Cel_ReplyToCommand(iClient, "%t", "InvalidBitWeapon");
		return Plugin_Handled;
	}
	
	if (!Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxCelLimit", Cel_GetCelCount(iClient));
		return Plugin_Handled;
	}
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	int iBit = Cel_SpawnWeaponBit(iClient, wbtType, fAngles, fOrigin, 255, 255, 255, 255);
	
	Cel_TeleportInfrontOfClient(iClient, iBit, 20.0);
	
	Cel_ReplyToCommandEntity(iClient, iBit, "%t", "SpawnBitWeapon");
	
	return Plugin_Handled;
}

//Natives:
public int Native_GetAmmoType(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return view_as<AmmoBitType>(g_abtAmmoType[iEntity]);
}

public int Native_GetAmmoTypeFromName(Handle hPlugin, int iNumParams)
{
	char sAmmo[64];
	
	GetNativeString(1, sAmmo, sizeof(sAmmo));
	
	if(StrContains(sAmmo, "pistol", false) != -1)
	{
		return view_as<int>(AMMOBIT_PISTOL);
	}else if(StrContains(sAmmo, "magnum", false) != -1)
	{
		return view_as<int>(AMMOBIT_MAGNUM);
	}else if(StrContains(sAmmo, "smg", false) != -1)
	{
		return view_as<int>(AMMOBIT_SMG);
	}else if(StrContains(sAmmo, "ar2", false) != -1)
	{
		return view_as<int>(AMMOBIT_AR2);
	}else if(StrContains(sAmmo, "shotgun", false) != -1)
	{
		return view_as<int>(AMMOBIT_SHOTGUN);
	}else if(StrContains(sAmmo, "crossbow", false) != -1)
	{
		return view_as<int>(AMMOBIT_CROSSBOW);
	}else if(StrContains(sAmmo, "rpg", false) != -1)
	{
		return view_as<int>(AMMOBIT_RPG);
	}else{
		return view_as<int>(AMMOBIT_UNKNOWN);
	}
}

public int Native_GetAmmoTypeName(Handle hPlugin, int iNumParams)
{
	AmmoBitType abtType = view_as<AmmoBitType>(GetNativeCell(1));
	char sName[64];
	int iMaxLength = GetNativeCell(3);
	
	switch(abtType)
	{
		case AMMOBIT_PISTOL:
		{
			Format(sName, sizeof(sName), "pistol");
		}
		case AMMOBIT_MAGNUM:
		{
			Format(sName, sizeof(sName), "magnum");
		}
		case AMMOBIT_SMG:
		{
			Format(sName, sizeof(sName), "smg");
		}
		case AMMOBIT_AR2:
		{
			Format(sName, sizeof(sName), "ar2");
		}
		case AMMOBIT_SHOTGUN:
		{
			Format(sName, sizeof(sName), "shotgun");
		}
		case AMMOBIT_CROSSBOW:
		{
			Format(sName, sizeof(sName), "crossbow");
		}
		case AMMOBIT_RPG:
		{
			Format(sName, sizeof(sName), "rpg");
		}
		case AMMOBIT_UNKNOWN:
		{
			Format(sName, sizeof(sName), "unknown");
		}
	}
	
	SetNativeString(2, sName, iMaxLength);
	
	return true;
}

public int Native_GetAmmoCrateType(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return view_as<AmmoCrateType>(g_actAmmoCrateType[iEntity]);
}

public int Native_GetAmmoCrateTypeFromName(Handle hPlugin, int iNumParams)
{
	char sAmmoCrate[64];
	
	GetNativeString(1, sAmmoCrate, sizeof(sAmmoCrate));
	
	if(StrContains(sAmmoCrate, "smg", false) != -1)
	{
		return view_as<int>(AMMOCRATEBIT_SMG);
	}else if(StrContains(sAmmoCrate, "ar2", false) != -1)
	{
		return view_as<int>(AMMOCRATEBIT_AR2);
	}else if(StrContains(sAmmoCrate, "rpg", false) != -1)
	{
		return view_as<int>(AMMOCRATEBIT_RPG);
	}else if(StrContains(sAmmoCrate, "cball", false) != -1)
	{
		return view_as<int>(AMMOCRATEBIT_CBALL);
	}else if(StrContains(sAmmoCrate, "grenade", false) != -1)
	{
		return view_as<int>(AMMOCRATEBIT_GRENADE);
	}else{
		return view_as<int>(AMMOCRATEBIT_UNKNOWN);
	}
}

public int Native_GetAmmoCrateTypeName(Handle hPlugin, int iNumParams)
{
	AmmoCrateType actType = view_as<AmmoCrateType>(GetNativeCell(1));
	char sName[64];
	int iMaxLength = GetNativeCell(3);
	
	switch(actType)
	{
		case AMMOCRATEBIT_SMG:
		{
			Format(sName, sizeof(sName), "smg");
		}
		case AMMOCRATEBIT_AR2:
		{
			Format(sName, sizeof(sName), "ar2");
		}
		case AMMOCRATEBIT_RPG:
		{
			Format(sName, sizeof(sName), "rpg");
		}
		case AMMOCRATEBIT_CBALL:
		{
			Format(sName, sizeof(sName), "combine");
		}
		case AMMOCRATEBIT_GRENADE:
		{
			Format(sName, sizeof(sName), "grenade");
		}
		case AMMOCRATEBIT_UNKNOWN:
		{
			Format(sName, sizeof(sName), "unknown");
		}
	}
	
	SetNativeString(2, sName, iMaxLength);
	
	return true;
}

public int Native_GetChargerType(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return view_as<ChargerType>(g_ctChargerType[iEntity]);
}

public int Native_GetChargerTypeFromName(Handle hPlugin, int iNumParams)
{
	char sCharger[64];
	
	GetNativeString(1, sCharger, sizeof(sCharger));
	
	if(StrContains(sCharger, "health", false) != -1)
	{
		return view_as<int>(CHARGERBIT_HEALTH);
	}else if(StrContains(sCharger, "suit", false) != -1)
	{
		return view_as<int>(CHARGERBIT_SUIT);
	}else{
		return view_as<int>(CHARGERBIT_UNKNOWN);
	}
}

public int Native_GetChargerTypeName(Handle hPlugin, int iNumParams)
{
	ChargerType ctType = view_as<ChargerType>(GetNativeCell(1));
	char sName[64];
	int iMaxLength = GetNativeCell(3);
	
	switch(ctType)
	{
		case CHARGERBIT_HEALTH:
		{
			Format(sName, sizeof(sName), "health");
		}
		case CHARGERBIT_SUIT:
		{
			Format(sName, sizeof(sName), "suit");
		}
		case CHARGERBIT_UNKNOWN:
		{
			Format(sName, sizeof(sName), "unknown");
		}
	}
	
	SetNativeString(2, sName, iMaxLength);
	
	return true;
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

public int Native_GetWeaponType(Handle hPlugin, int iNumParams)
{
	int iEntity = GetNativeCell(1);
	
	return view_as<WeaponBitType>(g_wbtWeaponType[iEntity]);
}

public int Native_GetWeaponTypeFromName(Handle hPlugin, int iNumParams)
{
	char sWeapon[64];
	
	GetNativeString(1, sWeapon, sizeof(sWeapon));
	
	if(StrContains(sWeapon, "gravgun", false) != -1)
	{
		return view_as<int>(WEPBIT_GRAVGUN);
	}else if(StrContains(sWeapon, "stunstick", false) != -1)
	{
		return view_as<int>(WEPBIT_STUNSTICK);
	}else if(StrContains(sWeapon, "crowbar", false) != -1)
	{
		return view_as<int>(WEPBIT_CROWBAR);
	}else if(StrContains(sWeapon, "pistol", false) != -1)
	{
		return view_as<int>(WEPBIT_PISTOL);
	}else if(StrContains(sWeapon, "magnum", false) != -1)
	{
		return view_as<int>(WEPBIT_MAGNUM);
	}else if(StrContains(sWeapon, "smg", false) != -1)
	{
		return view_as<int>(WEPBIT_SMG);
	}else if(StrContains(sWeapon, "ar2", false) != -1)
	{
		return view_as<int>(WEPBIT_AR2);
	}else if(StrContains(sWeapon, "shotgun", false) != -1)
	{
		return view_as<int>(WEPBIT_SHOTGUN);
	}else if(StrContains(sWeapon, "crossbow", false) != -1)
	{
		return view_as<int>(WEPBIT_CROSSBOW);
	}else if(StrContains(sWeapon, "grenade", false) != -1)
	{
		return view_as<int>(WEPBIT_GRENADE);
	}else if(StrContains(sWeapon, "rpg", false) != -1)
	{
		return view_as<int>(WEPBIT_RPG);
	}else if(StrContains(sWeapon, "slam", false) != -1)
	{
		return view_as<int>(WEPBIT_SLAM);
	}else {
		return view_as<int>(WEPBIT_UNKNOWN);
	}
}

public int Native_GetWeaponTypeName(Handle hPlugin, int iNumParams)
{
	WeaponBitType wbtType = view_as<WeaponBitType>(GetNativeCell(1));
	char sName[64];
	int iMaxLength = GetNativeCell(3);
	
	switch(wbtType)
	{
		case WEPBIT_GRAVGUN:
		{
			Format(sName, sizeof(sName), "gravity gun");
		}
		case WEPBIT_STUNSTICK:
		{
			Format(sName, sizeof(sName), "stunstick");
		}
		case WEPBIT_CROWBAR:
		{
			Format(sName, sizeof(sName), "crowbar");
		}
		case WEPBIT_PISTOL:
		{
			Format(sName, sizeof(sName), "pistol");
		}
		case WEPBIT_MAGNUM:
		{
			Format(sName, sizeof(sName), "magnum");
		}
		case WEPBIT_SMG:
		{
			Format(sName, sizeof(sName), "smg");
		}
		case WEPBIT_AR2:
		{
			Format(sName, sizeof(sName), "ar2");
		}
		case WEPBIT_SHOTGUN:
		{
			Format(sName, sizeof(sName), "shotgun");
		}
		case WEPBIT_CROSSBOW:
		{
			Format(sName, sizeof(sName), "crossbow");
		}
		case WEPBIT_GRENADE:
		{
			Format(sName, sizeof(sName), "grenade");
		}
		case WEPBIT_RPG:
		{
			Format(sName, sizeof(sName), "rpg");
		}
		case WEPBIT_SLAM:
		{
			Format(sName, sizeof(sName), "slam");
		}
		case WEPBIT_UNKNOWN:
		{
			Format(sName, sizeof(sName), "unknown");
		}
	}
	
	SetNativeString(2, sName, iMaxLength);
	
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

public int Native_SpawnAmmoBit(Handle hPlugin, int iNumParams)
{
	AmmoBitType abtType = view_as<AmmoBitType>(GetNativeCell(2));
	char sModel[64];
	float fAngles[3], fOrigin[3];
	int iBase = CreateEntityByName("prop_physics_override"), iClient = GetNativeCell(1), iColor[4];
	
	GetNativeArray(3, fAngles, 3);
	GetNativeArray(4, fOrigin, 3);
	iColor[0] = GetNativeCell(5);
	iColor[1] = GetNativeCell(6);
	iColor[2] = GetNativeCell(7);
	iColor[3] = GetNativeCell(8);
	
	switch(abtType)
	{
		case AMMOBIT_PISTOL:
		{
			Format(sModel, sizeof(sModel), "models/items/boxmrounds.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_ammo_pistol");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case AMMOBIT_MAGNUM:
		{
			Format(sModel, sizeof(sModel), "models/items/357ammo.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_ammo_magnum");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case AMMOBIT_SMG:
		{
			Format(sModel, sizeof(sModel), "models/items/boxsrounds.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_ammo_smg");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case AMMOBIT_AR2:
		{
			Format(sModel, sizeof(sModel), "models/items/combine_rifle_cartridge01.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_ammo_ar2");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case AMMOBIT_SHOTGUN:
		{
			Format(sModel, sizeof(sModel), "models/items/boxbuckshot.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_ammo_shotgun");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case AMMOBIT_CROSSBOW:
		{
			Format(sModel, sizeof(sModel), "models/items/crossbowrounds.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_ammo_crossbow");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case AMMOBIT_RPG:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_missile_closed.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_ammo_rpg");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case AMMOBIT_UNKNOWN:
		{
			Format(sModel, sizeof(sModel), "models/items/boxmrounds.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_ammo_pistol");
			DispatchKeyValue(iBase, "model", sModel);
			
			abtType = AMMOBIT_UNKNOWN;
		}
	}
	
	DispatchSpawn(iBase);
	
	TeleportEntity(iBase, fOrigin, fAngles, NULL_VECTOR);
	
	Cel_AddToCelCount(iClient);
	Cel_SetColor(iBase, iColor[0], iColor[1], iColor[2], iColor[3]);
	Cel_SetRainbow(iBase, false);
	Cel_SetEntity(iBase, true);
	Cel_SetMotion(iBase, false);
	Cel_SetOwner(iClient, iBase);
	Cel_SetSolid(iBase, true);
	Cel_LockEntity(iBase, false);
	Cel_SetRenderFX(iBase, RENDERFX_NONE);
	
	g_abtAmmoType[iBase] = abtType;
	
	SDKHook(iBase, SDKHook_StartTouchPost, Hook_AmmoBitTouch);
	SDKHook(iBase, SDKHook_EndTouchPost, Hook_StopTouch);
	
	return iBase;
}

public int Native_SpawnAmmoCrate(Handle hPlugin, int iNumParams)
{
	AmmoCrateType actType = view_as<AmmoCrateType>(GetNativeCell(2));
	char sAmmoCrateType[16];
	float fAngles[3], fOrigin[3];
	int iBase = CreateEntityByName("item_ammo_crate"), iClient = GetNativeCell(1), iColor[4];
	
	GetNativeArray(3, fAngles, 3);
	GetNativeArray(4, fOrigin, 3);
	iColor[0] = GetNativeCell(5);
	iColor[1] = GetNativeCell(6);
	iColor[2] = GetNativeCell(7);
	iColor[3] = GetNativeCell(8);
	
	switch(actType)
	{
		case AMMOCRATEBIT_UNKNOWN:
		{
			actType = AMMOCRATEBIT_SMG;
		}
	}
	
	IntToString(view_as<int>(actType), sAmmoCrateType, sizeof(sAmmoCrateType));
	
	DispatchKeyValue(iBase, "AmmoType", sAmmoCrateType);
	DispatchKeyValue(iBase, "classname", "bit_ammocrate");
	
	DispatchSpawn(iBase);
	
	fAngles[1] += 180;
	
	TeleportEntity(iBase, fOrigin, fAngles, NULL_VECTOR);
	
	Cel_AddToCelCount(iClient);
	Cel_SetColor(iBase, iColor[0], iColor[1], iColor[2], iColor[3]);
	Cel_SetRainbow(iBase, false);
	Cel_SetEntity(iBase, true);
	Cel_SetMotion(iBase, false);
	Cel_SetOwner(iClient, iBase);
	Cel_SetSolid(iBase, true);
	Cel_LockEntity(iBase, false);
	Cel_SetRenderFX(iBase, RENDERFX_NONE);
	
	g_actAmmoCrateType[iBase] = actType;
	
	return iBase;
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
	
	TeleportEntity(iBase, fOrigin, fAngles, NULL_VECTOR);
	
	g_bHasLink[iBase] = false;
	g_iLinkedEntity[iBase] = -1;
	
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

public int Native_SpawnCharger(Handle hPlugin, int iNumParams)
{
	ChargerType ctType = view_as<ChargerType>(GetNativeCell(2));
	float fAngles[3], fOrigin[3];
	int iBase, iClient = GetNativeCell(1), iColor[4];
	
	GetNativeArray(3, fAngles, 3);
	GetNativeArray(4, fOrigin, 3);
	iColor[0] = GetNativeCell(5);
	iColor[1] = GetNativeCell(6);
	iColor[2] = GetNativeCell(7);
	iColor[3] = GetNativeCell(8);
	
	switch(ctType)
	{
		case CHARGERBIT_HEALTH:
		{
			iBase = CreateEntityByName("item_healthcharger");
			
			DispatchKeyValue(iBase, "classname", "bit_charger_health");
		}
		case CHARGERBIT_SUIT:
		{
			iBase = CreateEntityByName("item_suitcharger");
			
			DispatchKeyValue(iBase, "classname", "bit_charger_suit");
		}
		case CHARGERBIT_UNKNOWN:
		{
			iBase = CreateEntityByName("item_healthcharger");
			
			DispatchKeyValue(iBase, "classname", "bit_charger_health");
		}
	}
	
	DispatchSpawn(iBase);
	
	fAngles[1] += 180;
	
	TeleportEntity(iBase, fOrigin, fAngles, NULL_VECTOR);
	
	Cel_AddToCelCount(iClient);
	Cel_SetColor(iBase, iColor[0], iColor[1], iColor[2], iColor[3]);
	Cel_SetRainbow(iBase, false);
	Cel_SetEntity(iBase, true);
	Cel_SetMotion(iBase, false);
	Cel_SetOwner(iClient, iBase);
	Cel_SetSolid(iBase, true);
	Cel_LockEntity(iBase, false);
	Cel_SetRenderFX(iBase, RENDERFX_NONE);
	
	g_ctChargerType[iBase] = ctType;
	
	return iBase;
}

public int Native_SpawnWeaponBit(Handle hPlugin, int iNumParams)
{
	WeaponBitType wbtType = view_as<WeaponBitType>(GetNativeCell(2));
	char sModel[64];
	float fAngles[3], fOrigin[3];
	int iBase = CreateEntityByName("prop_physics_override"), iClient = GetNativeCell(1), iColor[4];
	
	GetNativeArray(3, fAngles, 3);
	GetNativeArray(4, fOrigin, 3);
	iColor[0] = GetNativeCell(5);
	iColor[1] = GetNativeCell(6);
	iColor[2] = GetNativeCell(7);
	iColor[3] = GetNativeCell(8);
	
	switch(wbtType)
	{
		case WEPBIT_GRAVGUN:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_physics.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_wep_gravgun");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case WEPBIT_STUNSTICK:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_stunbaton.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_wep_stunstick");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case WEPBIT_CROWBAR:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_crowbar.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_wep_crowbar");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case WEPBIT_PISTOL:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_pistol.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_wep_pistol");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case WEPBIT_MAGNUM:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_357.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_wep_magnum");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case WEPBIT_SMG:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_smg1.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_wep_smg");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case WEPBIT_AR2:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_irifle.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_wep_ar2");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case WEPBIT_SHOTGUN:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_shotgun.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_wep_shotgun");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case WEPBIT_CROSSBOW:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_crossbow.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_wep_crossbow");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case WEPBIT_GRENADE:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_grenade.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_wep_grenade");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case WEPBIT_RPG:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_rocket_launcher.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_wep_rpg");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case WEPBIT_SLAM:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_slam.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_wep_slam");
			DispatchKeyValue(iBase, "model", sModel);
		}
		case WEPBIT_UNKNOWN:
		{
			Format(sModel, sizeof(sModel), "models/weapons/w_smg1.mdl");
			
			PrecacheModel(sModel);
			
			DispatchKeyValue(iBase, "classname", "bit_wep_smg");
			DispatchKeyValue(iBase, "model", sModel);
			
			wbtType = WEPBIT_SMG;
		}
	}
	
	DispatchSpawn(iBase);
	
	fAngles[1] += 90;
	
	TeleportEntity(iBase, fOrigin, fAngles, NULL_VECTOR);
	
	Cel_AddToCelCount(iClient);
	Cel_SetColor(iBase, iColor[0], iColor[1], iColor[2], iColor[3]);
	Cel_SetRainbow(iBase, false);
	Cel_SetEntity(iBase, true);
	Cel_SetMotion(iBase, false);
	Cel_SetOwner(iClient, iBase);
	Cel_SetSolid(iBase, true);
	Cel_LockEntity(iBase, false);
	Cel_SetRenderFX(iBase, RENDERFX_NONE);
	
	g_wbtWeaponType[iBase] = wbtType;
	
	SDKHook(iBase, SDKHook_StartTouchPost, Hook_WeaponBitTouch);
	SDKHook(iBase, SDKHook_EndTouchPost, Hook_StopTouch);
	
	return iBase;
}

public int Native_TriggerEntity(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1), iEntity = GetNativeCell(2);
	
	if(Cel_IsEntity(g_iLinkedEntity[iEntity]))
	{
		switch(Cel_GetEntityType(g_iLinkedEntity[iEntity]))
		{
			case ENTTYPE_DOOR:
			{
				AcceptEntityInput(g_iLinkedEntity[iEntity], "Toggle", iClient);
			}
			
			case ENTTYPE_LIGHT:
			{
				AcceptEntityInput(Entity_GetEntityAttachment(g_iLinkedEntity[iEntity]), "Toggle", iClient);
				
			}
			
			case ENTTYPE_EFFECT:
			{
				Cel_ActivateEffect(g_iLinkedEntity[iEntity]);
			}
		}
	}
	
	return true;
}

//Hooks:
public void Hook_AmmoBitTouch(int iEntity, int iClient)
{
	if(!Cel_IsLocked(iEntity))
	{
		if(!g_bTouched[iClient])
		{
			switch(Cel_GetAmmoType(iEntity))
			{
				case AMMOBIT_PISTOL:
				{
					if(Client_HasWeapon(iClient, "weapon_pistol"))
					{
						Client_GiveWeaponAndAmmo(iClient, "weapon_pistol", false);
					}
				}
				case AMMOBIT_MAGNUM:
				{
					if(Client_HasWeapon(iClient, "weapon_357"))
					{
						Client_GiveWeaponAndAmmo(iClient, "weapon_357", false);
					}
				}
				case AMMOBIT_SMG:
				{
					if(Client_HasWeapon(iClient, "weapon_smg1"))
					{
						Client_GiveWeaponAndAmmo(iClient, "weapon_smg1", false, 45, 3, 45, 3);
					}
				}
				case AMMOBIT_AR2:
				{
					if(Client_HasWeapon(iClient, "weapon_ar2"))
					{
						Client_GiveWeaponAndAmmo(iClient, "weapon_ar2", false);
					}
				}
				case AMMOBIT_SHOTGUN:
				{
					if(Client_HasWeapon(iClient, "weapon_shotgun"))
					{
						Client_GiveWeaponAndAmmo(iClient, "weapon_shotgun", false);
					}
				}
				case AMMOBIT_CROSSBOW:
				{
					if(Client_HasWeapon(iClient, "weapon_crossbow"))
					{
						Client_GiveWeaponAndAmmo(iClient, "weapon_crossbow", false);
					}
				}
				case AMMOBIT_RPG:
				{
					if(Client_HasWeapon(iClient, "weapon_rpg"))
					{
						Client_GiveWeaponAndAmmo(iClient, "weapon_rpg", false);
					}
				}
				case AMMOBIT_UNKNOWN:
				{
					if(Client_HasWeapon(iClient, "weapon_pistol"))
					{
						Client_GiveWeaponAndAmmo(iClient, "weapon_pistol", false);
					}
				}
			}
			
			g_bTouched[iClient] = true;
		}
	}
}

public void Hook_ButtonUse(int iEntity, int iActivator, int iCaller, UseType utType, float fValue)
{
	if(!Cel_IsLocked(iEntity))
	{
		if(g_bHasLink[iEntity])
		{
			Cel_TriggerEntity(iActivator, iEntity);
			
			PrecacheSound("buttons/combine_button1.wav");
			
			EmitSoundToAll("buttons/combine_button1.wav", iEntity, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}else{
			PrecacheSound("buttons/combine_button_locked.wav");
			
			EmitSoundToAll("buttons/combine_button_locked.wav", iEntity, 2, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}
	}
}

public void Hook_StopTouch(int iEntity, int iClient)
{
	g_bTouched[iClient] = false;
}

public void Hook_WeaponBitTouch(int iEntity, int iClient)
{
	if(!Cel_IsLocked(iEntity))
	{
		if(!g_bTouched[iClient])
		{
			switch(Cel_GetWeaponType(iEntity))
			{
				case WEPBIT_GRAVGUN:
				{
					Client_GiveWeapon(iClient, "weapon_physcannon", false);
				}
				case WEPBIT_STUNSTICK:
				{
					Client_GiveWeapon(iClient, "weapon_stunstick", false);
				}
				case WEPBIT_CROWBAR:
				{
					Client_GiveWeapon(iClient, "weapon_crowbar", false);
				}
				case WEPBIT_PISTOL:
				{
					Client_GiveWeapon(iClient, "weapon_pistol", false);
				}
				case WEPBIT_MAGNUM:
				{
					Client_GiveWeapon(iClient, "weapon_357", false);
				}
				case WEPBIT_SMG:
				{
					Client_GiveWeapon(iClient, "weapon_smg1", false);
				}
				case WEPBIT_AR2:
				{
					Client_GiveWeapon(iClient, "weapon_ar2", false);
				}
				case WEPBIT_SHOTGUN:
				{
					Client_GiveWeapon(iClient, "weapon_shotgun", false);
				}
				case WEPBIT_CROSSBOW:
				{
					Client_GiveWeapon(iClient, "weapon_crossbow", false);
				}
				case WEPBIT_GRENADE:
				{
					Client_GiveWeapon(iClient, "weapon_frag", false);
				}
				case WEPBIT_RPG:
				{
					Client_GiveWeapon(iClient, "weapon_rpg", false);
				}
				case WEPBIT_SLAM:
				{
					Client_GiveWeapon(iClient, "weapon_slam", false);
				}
				case WEPBIT_UNKNOWN:
				{
					Client_GiveWeapon(iClient, "weapon_smg1", false);
				}
			}
			
			g_bTouched[iClient] = true;
		}
	}
}
