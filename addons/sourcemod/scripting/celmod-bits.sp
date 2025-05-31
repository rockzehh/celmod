#pragma semicolon 1

#include <celmod>

#pragma newdecls required

bool g_bLate;
bool g_bTouched[MAXPLAYERS + 1];

AmmoBitType g_abtAmmoType[MAXENTITIES + 1];
AmmoCrateType g_actAmmoCrateType[MAXENTITIES + 1];
ChargerType g_ctChargerType[MAXENTITIES + 1];
WeaponBitType g_wbtWeaponType[MAXENTITIES + 1];

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
	CreateNative("Cel_GetWeaponType", Native_GetWeaponType);
	CreateNative("Cel_GetWeaponTypeFromName", Native_GetWeaponTypeFromName);
	CreateNative("Cel_GetWeaponTypeName", Native_GetWeaponTypeName);
	CreateNative("Cel_SpawnAmmoBit", Native_SpawnAmmoBit);
	CreateNative("Cel_SpawnAmmoCrate", Native_SpawnAmmoCrate);
	CreateNative("Cel_SpawnCharger", Native_SpawnCharger);
	CreateNative("Cel_SpawnWeaponBit", Native_SpawnWeaponBit);
	
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
	RegConsoleCmd("v_charger", Command_SpawnChargerBit, "|CelMod| Creates a health/suit charger bit that will give health/suit to the player.");
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

public Action Command_SpawnAmmoBit(int iClient, int iArgs)
{
	char sOption[64], sType[64];
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
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	int iBit = Cel_SpawnAmmoBit(iClient, abtType, fAngles, fOrigin, 255, 255, 255, 255);
	
	Cel_TeleportInfrontOfClient(iClient, iBit, 20.0);
	
	Cel_GetAmmoTypeName(abtType, sType, sizeof(sType));
	
	Cel_ReplyToCommand(iClient, "%t", "SpawnBitAmmo", sType);
	
	return Plugin_Handled;
}

public Action Command_SpawnAmmoCrateBit(int iClient, int iArgs)
{
	char sOption[64], sType[64];
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
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	int iBit = Cel_SpawnAmmoCrate(iClient, actType, fAngles, fOrigin, 255, 255, 255, 255);
	
	Cel_TeleportInfrontOfClient(iClient, iBit, 12.5);
	
	Cel_GetAmmoCrateTypeName(actType, sType, sizeof(sType));
	
	Cel_ReplyToCommand(iClient, "%t", "SpawnBitAmmoCrate", sType);
	
	return Plugin_Handled;
}

public Action Command_SpawnChargerBit(int iClient, int iArgs)
{
	char sOption[64], sType[64];
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
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	int iBit = Cel_SpawnCharger(iClient, ctType, fAngles, fOrigin, 255, 255, 255, 255);
	
	Cel_TeleportInfrontOfClient(iClient, iBit, 45.0);
	
	Cel_GetChargerTypeName(ctType, sType, sizeof(sType));
	
	Cel_ReplyToCommand(iClient, "%t", "SpawnBitCharger", sType);
	
	return Plugin_Handled;
}

public Action Command_SpawnWeaponBit(int iClient, int iArgs)
{
	char sOption[64], sType[64];
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
	
	GetClientAbsAngles(iClient, fAngles);
	Cel_GetCrosshairHitOrigin(iClient, fOrigin);
	
	int iBit = Cel_SpawnWeaponBit(iClient, wbtType, fAngles, fOrigin, 255, 255, 255, 255);
	
	Cel_TeleportInfrontOfClient(iClient, iBit, 20.0);
	
	Cel_GetWeaponTypeName(wbtType, sType, sizeof(sType));
	
	Cel_ReplyToCommand(iClient, "%t", "SpawnBitWeapon", sType);
	
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
	Cel_SetRenderFX(iBase, RENDERFX_NONE);
	
	g_actAmmoCrateType[iBase] = actType;
	
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
		}
		case CHARGERBIT_SUIT:
		{
			iBase = CreateEntityByName("item_suitcharger");
		}
		case CHARGERBIT_UNKNOWN:
		{
			iBase = CreateEntityByName("item_healthcharger");
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
	Cel_SetRenderFX(iBase, RENDERFX_NONE);
	
	g_wbtWeaponType[iBase] = wbtType;
	
	SDKHook(iBase, SDKHook_StartTouchPost, Hook_WeaponBitTouch);
	SDKHook(iBase, SDKHook_EndTouchPost, Hook_StopTouch);
	
	return iBase;
}

//Hooks:
public void Hook_AmmoBitTouch(int iEntity, int iClient)
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

public void Hook_StopTouch(int iEntity, int iClient)
{
	g_bTouched[iClient] = false;
}

public void Hook_WeaponBitTouch(int iEntity, int iClient)
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
