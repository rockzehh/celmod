#pragma semicolon 1

#include <celmod>
#include <sourcemod>

#pragma newdecls required

bool g_bUsingCrowbarMenu[MAXPLAYERS + 1];

int g_iCrowbarEntity[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	return APLRes_Success;
}

public Plugin myinfo = 
{
	name = "|CelMod| Crowbar", 
	author = CEL_AUTHOR, 
	description = "A GUI interface for modifying entities.", 
	version = CEL_VERSION, 
	url = "https://github.com/rockzehh/celmod"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_crowbar", Command_Crowbar, "|CelMod| Enables/disables the GUI interface for entities when using a crowbar/stunstick.");
}

public void OnClientPutInServer(int iClient)
{
	g_bUsingCrowbarMenu[iClient] = false;
}

public void OnClientDisconnect(int iClient)
{
	g_bUsingCrowbarMenu[iClient] = false;
}

public Action OnPlayerRunCmd(int iClient, int &iButtons, int &iImpulse, float fVel[3], float fAngles[3], int &iWeapon, int &iSubtype, int &iCmdnum, int &iTickcount, int &iSeed, int iMouse[2])
{
	char sWeapon[64];
	float fCOrigin[3], fEOrigin[3];
	int iEntity;
	
	GetEntityClassname(iWeapon, sWeapon, sizeof(sWeapon));
	
	if(iButtons & IN_ATTACK)
	{
		if(StrEqual(sWeapon, "weapon_crowbar") || StrEqual(sWeapon, "weapon_stunstick"))
		{
			iEntity = Cel_GetClientAimTarget(iClient);
			
			GetClientAbsOrigin(iClient, fCOrigin);
			Cel_GetEntityOrigin(iEntity, fEOrigin);
			
			if(GetVectorDistance(fCOrigin, fEOrigin, false))
			{
				if(Cel_CheckOwner(iClient, iEntity))
				{
					g_iCrowbarEntity[iClient] = iEntity;
					//Entity Menu Use
				}
			}
		}
	}
}

stock void Cel_ShowEntityMenu(int iClient, int iEntity)
{
	Menu hMenu = new Menu(Menu_CrowbarMain, MENU_ACTIONS_ALL);
		
		hMenu.SetTitle("|CelMod| Crowbar - Entity Interface");
		
		hMenu.AddItem("opt_alpha", "Set Alpha");
		hMenu.AddItem("opt_angles", "Set Angles");
		hMenu.AddItem("opt_color", "Set Color");
		hMenu.AddItem("opt_motion", "Set Motion");
		hMenu.AddItem("opt_origin", "Set Position");
		hMenu.AddItem("opt_renderfx", "Set RenderFX");
		hMenu.AddItem("opt_solid", "Set Solidity");		
		
		hMenu.ExitButton = true;
		
		hMenu.Display(iClient, MENU_TIME_FOREVER);
}
