#pragma semicolon 1

#include <celmod>

#pragma newdecls required

bool g_bEffectActive[MAXENTITIES + 1];

EffectType g_etEffectType[MAXENTITIES + 1];

Handle g_hOnEffectSpawn;

int g_iEffectEntity[MAXENTITIES + 1];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	CreateNative("Cel_CheckEffectType", Native_CheckEffectType);
	CreateNative("Cel_GetEffectAttachment", Native_GetEffectAttachment);
	CreateNative("Cel_GetEffectType", Native_GetEffectType);
	CreateNative("Cel_GetEffectTypeFromName", Native_GetEffectTypeFromName);
	CreateNative("Cel_GetEffectTypeName", Native_GetEffectTypeName);
	CreateNative("Cel_IsEffectActive", Native_IsEffectActive);
	CreateNative("Cel_SetEffectActive", Native_SetEffectActive);
	CreateNative("Cel_SetEffectAttachment", Native_SetEffectAttachment);
	CreateNative("Cel_SetEffectType", Native_SetEffectType);
	CreateNative("Cel_SpawnEffect", Native_SpawnEffect);

	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "|CelMod| Effects",
	author = CEL_AUTHOR,
	description = "Creates a effect emitter.",
	version = CEL_VERSION,
	url = CEL_URL
};

public void OnPluginStart()
{
	LoadTranslations("celmod.phrases");

	g_hOnEffectSpawn = CreateGlobalForward("Cel_OnEffectSpawn", ET_Hook, Param_Cell, Param_Cell, Param_Cell);

	RegConsoleCmd("v_effect", Command_Effect, "|CelMod| Spawns a working effect cel.");
	RegConsoleCmd("v_emitter", Command_Effect, "|CelMod| Spawns a working effect cel.");
}

//Plugin Commands:
public Action Command_Effect(int iClient, int iArgs)
{
	char sEffect[PLATFORM_MAX_PATH], sEffectType[PLATFORM_MAX_PATH];
	float fOrigin[3];

	if (iArgs < 1)
	{
		Cel_ReplyToCommand(iClient, "%t", "CMD_Effect");
		return Plugin_Handled;
	}

	GetCmdArg(1, sEffect, sizeof(sEffect));

	EffectType etEffectType = Cel_GetEffectTypeFromName(sEffect);

	if (etEffectType == EFFECT_UNKNOWN)
	{
		Cel_ReplyToCommand(iClient, "%t", "InvalidEffect");
		return Plugin_Handled;
	}
	
	if (!Cel_CheckCelCount(iClient))
	{
		Cel_ReplyToCommand(iClient, "%t", "MaxCelLimit", Cel_GetCelCount(iClient));
		return Plugin_Handled;
	}

	Cel_GetCrosshairHitOrigin(iClient, fOrigin);

	int iEffect = Cel_SpawnEffect(iClient, fOrigin, etEffectType, true, 255, 255, 255, 255);

	Call_StartForward(g_hOnEffectSpawn);

	Call_PushCell(iEffect);
	Call_PushCell(iClient);
	Call_PushCell(etEffectType);

	Call_Finish();

	Cel_GetEffectTypeName(etEffectType, sEffectType, sizeof(sEffectType));

	Cel_ReplyToCommand(iClient, "%t", "SpawnEffect", sEffectType);

	return Plugin_Handled;
}

//Plugin Natives:
public int Native_CheckEffectType(Handle hPlugin, int iNumParams)
{
	char sCheck[PLATFORM_MAX_PATH], sType[PLATFORM_MAX_PATH];
	int iEffect = GetNativeCell(1);

	GetNativeString(2, sCheck, sizeof(sCheck));

	Cel_GetEffectTypeName(Cel_GetEffectType(iEffect), sType, sizeof(sType));

	return (StrContains(sType, sCheck, false) != -1);
}

public int Native_GetEffectAttachment(Handle hPlugin, int iNumParams)
{
	int iEffect = GetNativeCell(1);

	return g_iEffectEntity[iEffect];
}

public int Native_GetEffectType(Handle hPlugin, int iNumParams)
{
	int iEffect = GetNativeCell(1);

	return view_as<int>(g_etEffectType[iEffect]);
}

public int Native_GetEffectTypeFromName(Handle hPlugin, int iNumParams)
{
	char sEffectName[PLATFORM_MAX_PATH];

	GetNativeString(1, sEffectName, sizeof(sEffectName));

	if (StrContains("core", sEffectName, false) != -1)
	{
		return view_as<int>(EFFECT_CORE);
		/*} else if (StrContains("explosion", sEffectName, false) != -1)
	{
		return view_as<int>(EFFECT_EXPLOSION);*/
	} else if (StrContains("fire", sEffectName, false) != -1)
	{
		return view_as<int>(EFFECT_FIRE);
	} else if (StrContains("shake", sEffectName, false) != -1)
	{
		return view_as<int>(EFFECT_SHAKE);
	} else if (StrContains("smokestack", sEffectName, false) != -1)
	{
		return view_as<int>(EFFECT_SMOKESTACK);
	} else if (StrContains("spotlight", sEffectName, false) != -1)
	{
		return view_as<int>(EFFECT_SPOTLIGHT);
	} else if (StrContains("steam", sEffectName, false) != -1)
	{
		return view_as<int>(EFFECT_STEAM);
	} else {
		return view_as<int>(EFFECT_UNKNOWN);
	}
}

public int Native_GetEffectTypeName(Handle hPlugin, int iNumParams)
{
	char sEffectName[PLATFORM_MAX_PATH];
	EffectType etEffect = view_as<EffectType>(GetNativeCell(1));
	int iMaxLength = GetNativeCell(3);

	switch (etEffect)
	{
		case EFFECT_CORE:
		{
			Format(sEffectName, sizeof(sEffectName), "core");
		}
		/*case EFFECT_EXPLOSION:
		{
			Format(sEffectName, sizeof(sEffectName), "explosion");
		}*/
		case EFFECT_FIRE:
		{
			Format(sEffectName, sizeof(sEffectName), "fire");
		}
		case EFFECT_SHAKE:
		{
			Format(sEffectName, sizeof(sEffectName), "shake");
		}
		case EFFECT_SMOKESTACK:
		{
			Format(sEffectName, sizeof(sEffectName), "smokestack");
		}
		case EFFECT_SPOTLIGHT:
		{
			Format(sEffectName, sizeof(sEffectName), "spotlight");
		}
		case EFFECT_STEAM:
		{
			Format(sEffectName, sizeof(sEffectName), "steam");
		}
		case EFFECT_UNKNOWN:
		{
			Format(sEffectName, sizeof(sEffectName), "unknown");
		}
	}

	SetNativeString(2, sEffectName, iMaxLength);

	return true;
}

public int Native_IsEffectActive(Handle hPlugin, int iNumParams)
{
	int iEffect = GetNativeCell(1);

	return g_bEffectActive[iEffect];
}

public int Native_SetEffectActive(Handle hPlugin, int iNumParams)
{
	bool bActive = view_as<bool>(GetNativeCell(2));
	int iEffect = GetNativeCell(1);

	g_bEffectActive[iEffect] = bActive;

	return true;
}

public int Native_SetEffectAttachment(Handle hPlugin, int iNumParams)
{
	int iAttachment = GetNativeCell(2), iEffect = GetNativeCell(1);

	g_iEffectEntity[iEffect] = iAttachment;

	return true;
}

public int Native_SetEffectType(Handle hPlugin, int iNumParams)
{
	EffectType etType = view_as<EffectType>(GetNativeCell(2));
	int iEffect = GetNativeCell(1);

	g_etEffectType[iEffect] = etType;

	return true;
}

public int Native_SpawnEffect(Handle hPlugin, int iNumParams)
{
	bool bActivate;
	char sClassname[PLATFORM_MAX_PATH], sEffect[PLATFORM_MAX_PATH];
	EffectType etEffect;
	float fAngles[3], fFinalOrigin[3], fOrigin[3];
	int iBase = CreateEntityByName("prop_physics_override"), iClient = GetNativeCell(1), iColor[4], iEffect;

	GetNativeArray(2, fOrigin, 3);
	etEffect = view_as<EffectType>(GetNativeCell(3));
	bActivate = view_as<bool>(GetNativeCell(4));
	iColor[0] = GetNativeCell(5);
	iColor[1] = GetNativeCell(6);
	iColor[2] = GetNativeCell(7);
	iColor[3] = GetNativeCell(8);

	Cel_GetEffectTypeName(etEffect, sEffect, sizeof(sEffect));

	Format(sClassname, sizeof(sClassname), "effect_%s", sEffect);

	PrecacheModel("models/props_lab/tpplug.mdl");

	DispatchKeyValue(iBase, "classname", sClassname);
	DispatchKeyValue(iBase, "model", "models/props_lab/tpplug.mdl");
	DispatchKeyValue(iBase, "spawnflags", "256");

	DispatchSpawn(iBase);

	fAngles[0] = -90.0, fAngles[1] = 0.0, fAngles[2] = 0.0;
	fFinalOrigin = fOrigin;

	TeleportEntity(iBase, fFinalOrigin, fAngles, NULL_VECTOR);

	Cel_AddToCelCount(iClient);
	Cel_SetColor(iBase, iColor[0], iColor[1], iColor[2], iColor[3]);
	Cel_SetRainbow(iBase, false);
	Cel_SetEntity(iBase, true);
	Cel_SetMotion(iBase, false);
	Cel_SetOwner(iClient, iBase);
	Cel_SetSolid(iBase, true);
	Cel_SetRenderFX(iBase, RENDERFX_NONE);

	SDKHook(iBase, SDKHook_UsePost, Hook_EffectUse);

	switch (etEffect)
	{
		case EFFECT_CORE:
		{
			iEffect = CreateEntityByName("env_citadel_energy_core");

			fAngles[0] = 0.0, fAngles[1] = 0.0, fAngles[2] = 0.0;

			fFinalOrigin = fOrigin;
			fFinalOrigin[2] += 8.0;

			DispatchKeyValue(iEffect, "scale", "2");
			DispatchKeyValue(iEffect, "spawnflags", "0");

			DispatchSpawn(iEffect);

			TeleportEntity(iEffect, fFinalOrigin, fAngles, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(iEffect, "SetParent", iBase);

			Cel_SetEffectAttachment(iBase, iEffect);

			Cel_SetEffectActive(iBase, bActivate);

			Cel_SetEffectType(iBase, etEffect);

			SetVariantFloat(0.0);
			AcceptEntityInput(Cel_GetEffectAttachment(iBase), Cel_IsEffectActive(iBase) ? "StartDischarge" : "StartCharge");

			return iBase;
		}
		/*case EFFECT_EXPLOSION:
		{
			iEffect = CreateEntityByName("env_explosion");

			fAngles[0] = 0.0, fAngles[1] = 0.0, fAngles[2] = 0.0;

			fFinalOrigin = fOrigin;
			fFinalOrigin[2] += 8.0;

			DispatchKeyValue(iEffect, "fireballsprite", "sprites/zerogxplode.spr");
			DispatchKeyValue(iEffect, "iMagnitude", "25");
			DispatchKeyValue(iEffect, "rendermode", "5");
			DispatchKeyValue(iEffect, "spawnflags", "16386");

			DispatchSpawn(iEffect);

			TeleportEntity(iEffect, fFinalOrigin, fAngles, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(iEffect, "SetParent", iBase);

			Cel_SetEffectAttachment(iBase, iEffect);

			Cel_SetEffectType(iBase, etEffect);

			return iBase;
		}*/
		case EFFECT_FIRE:
		{
			iEffect = CreateEntityByName("env_fire");

			fAngles[0] = 0.0, fAngles[1] = 0.0, fAngles[2] = 0.0;

			fFinalOrigin = fOrigin;
			fFinalOrigin[2] += 8.0;

			DispatchKeyValue(iEffect, "damagescale", "1.0");
			DispatchKeyValue(iEffect, "fireattack", "4");
			DispatchKeyValue(iEffect, "firesize", "64");
			DispatchKeyValue(iEffect, "firetype", "0");
			DispatchKeyValue(iEffect, "health", "30");
			DispatchKeyValue(iEffect, "ignitionpoint", "32");
			DispatchKeyValue(iEffect, "spawnflags", "257");

			DispatchSpawn(iEffect);

			TeleportEntity(iEffect, fFinalOrigin, fAngles, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(iEffect, "SetParent", iBase);

			Cel_SetEffectAttachment(iBase, iEffect);

			Cel_SetEffectActive(iBase, bActivate);

			Cel_SetEffectType(iBase, etEffect);

			SetVariantFloat(0.0);
			AcceptEntityInput(Cel_GetEffectAttachment(iBase), Cel_IsEffectActive(iBase) ? "ExtinguishTemporary" : "StartFire");

			return iBase;
		}
		case EFFECT_SHAKE:
		{
			iEffect = CreateEntityByName("env_shake");

			fAngles[0] = 0.0, fAngles[1] = 0.0, fAngles[2] = 0.0;

			fFinalOrigin = fOrigin;
			fFinalOrigin[2] += 8.0;

			DispatchKeyValue(iEffect, "amplitude", "4");
			DispatchKeyValue(iEffect, "duration", "5");
			DispatchKeyValue(iEffect, "frequency", "5");
			DispatchKeyValue(iEffect, "radius", "100");

			DispatchSpawn(iEffect);

			TeleportEntity(iEffect, fFinalOrigin, fAngles, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(iEffect, "SetParent", iBase);

			Cel_SetEffectAttachment(iBase, iEffect);

			Cel_SetEffectType(iBase, etEffect);

			return iBase;
		}
		case EFFECT_SMOKESTACK:
		{
			iEffect = CreateEntityByName("env_smokestack");

			fAngles[0] = 0.0, fAngles[1] = 0.0, fAngles[2] = 0.0;

			fFinalOrigin = fOrigin;
			fFinalOrigin[2] += 8.0;

			DispatchKeyValue(iEffect, "BaseSpread", "5");
			DispatchKeyValue(iEffect, "EndSize", "10");
			DispatchKeyValue(iEffect, "JetLength", "180");
			DispatchKeyValue(iEffect, "Rate", "200");
			DispatchKeyValue(iEffect, "roll", "65");
			DispatchKeyValue(iEffect, "SmokeMaterial", "particle/SmokeStack.vmt");
			DispatchKeyValue(iEffect, "Speed", "150");
			DispatchKeyValue(iEffect, "SpreadSpeed", "15");
			DispatchKeyValue(iEffect, "StartSize", "5");

			DispatchSpawn(iEffect);

			TeleportEntity(iEffect, fFinalOrigin, fAngles, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(iEffect, "SetParent", iBase);

			Cel_SetEffectAttachment(iBase, iEffect);

			Cel_SetColor(Cel_GetEffectAttachment(iBase), iColor[0], iColor[1], iColor[2], iColor[3]);

			Cel_SetRainbow(Cel_GetEffectAttachment(iBase), false);

			Cel_SetEffectActive(iBase, bActivate);

			Cel_SetEffectType(iBase, etEffect);

			AcceptEntityInput(Cel_GetEffectAttachment(iBase), Cel_IsEffectActive(iBase) ? "TurnOff" : "TurnOn");

			return iBase;
		}
		case EFFECT_SPOTLIGHT:
		{
			iEffect = CreateEntityByName("point_spotlight");

			fAngles[0] = -90.0, fAngles[1] = 0.0, fAngles[2] = 0.0;

			fFinalOrigin = fOrigin;
			fFinalOrigin[2] += 12.0;

			DispatchKeyValue(iEffect, "disablereceiveshadows", "1");
			DispatchKeyValue(iEffect, "HDRColorScale", "1.0");
			DispatchKeyValue(iEffect, "spawnflags", "2");
			DispatchKeyValue(iEffect, "spotlightlength", "50");
			DispatchKeyValue(iEffect, "spotlightwidth", "10");

			DispatchSpawn(iEffect);

			TeleportEntity(iEffect, fFinalOrigin, fAngles, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(iEffect, "SetParent", iBase);

			Cel_SetEffectAttachment(iBase, iEffect);

			Cel_SetColor(Cel_GetEffectAttachment(iBase), iColor[0], iColor[1], iColor[2], iColor[3]);

			Cel_SetRainbow(Cel_GetEffectAttachment(iBase), false);

			Cel_SetEffectActive(iBase, bActivate);

			Cel_SetEffectType(iBase, etEffect);

			AcceptEntityInput(Cel_GetEffectAttachment(iBase), Cel_IsEffectActive(iBase) ? "LightOff" : "LightOn");

			return iBase;
		}
		case EFFECT_STEAM:
		{
			iEffect = CreateEntityByName("env_steam");

			fAngles[0] = -90.0, fAngles[1] = 0.0, fAngles[2] = 0.0;

			fFinalOrigin = fOrigin;
			fFinalOrigin[2] += 12.0;

			DispatchKeyValue(iEffect, "EndSize", "15");
			DispatchKeyValue(iEffect, "JetLength", "80");
			DispatchKeyValue(iEffect, "Rate", "75");
			DispatchKeyValue(iEffect, "rollspeed", "8");
			DispatchKeyValue(iEffect, "spawnflags", "0");
			DispatchKeyValue(iEffect, "Speed", "150");
			DispatchKeyValue(iEffect, "SpreadSpeed", "25");
			DispatchKeyValue(iEffect, "StartSize", "5");

			DispatchSpawn(iEffect);

			TeleportEntity(iEffect, fFinalOrigin, fAngles, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(iEffect, "SetParent", iBase);

			Cel_SetEffectAttachment(iBase, iEffect);

			Cel_SetEffectActive(iBase, bActivate);

			Cel_SetEffectType(iBase, etEffect);

			AcceptEntityInput(Cel_GetEffectAttachment(iBase), Cel_IsEffectActive(iBase) ? "TurnOff" : "TurnOn");

			return iBase;
		}
	}

	return -1;
}
