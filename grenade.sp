#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

int naded[128];
bool isWaiting[128];
ConVar sm_grenade_delay;


public Plugin myinfo = 
{
	name = "grenade",
	author = "Vamp",
	description = "Player throws grenades",
	version = "0.1",
	url = ""
}

public void OnPluginStart()
{
	RegConsoleCmd("nade", nade, "Throw a grenade.");
	sm_grenade_delay = CreateConVar("sm_grenade_delay", "3.0", "SM Grenades Delay");
	PrintToServer("[SM] Vamp grenade plugin loaded ");
	PrintToServer("[[Use 'sm_grenade_delay' to change the waiting time.]]");
}

public Action nade(int client, int args)
{
	if (client == 0) return Plugin_Handled;
	int iFrags = GetEntProp(client, Prop_Send, "m_iAmmo", _, 12);
	if ((isWaiting[client]) || (iFrags < 1))
	{
	   // PrintToChat(client,"[SM] You must wait.");
	   EmitSoundToClient(client,"player/suit_denydevice.wav"); 
	   return Plugin_Handled;
	}
	
	float Location[3];
	float eyeang[3];
	float vel[3];
	float pvel[3];

	GetClientEyePosition(client, Location);
	GetClientEyeAngles(client,eyeang);

	naded[client] = CreateEntityByName("npc_grenade_frag");
	
		
	if (IsValidEntity(naded[client]) && DispatchSpawn(naded[client]))
	{
		//PrintToChat(client,"Ent nade created");
		
		SetEntProp(client, Prop_Data, "m_iAmmo", iFrags-1, _, 12);

		GetAngleVectors(eyeang, vel, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vel, 600.0);
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", pvel);
		AddVectors( vel, pvel, vel);
		
		DispatchKeyValue(naded[client],"model","models/weapons/w_grenade.mdl");
  
		DispatchKeyValue(naded[client],"solid","1");
	
		SetEntPropEnt(naded[client], Prop_Data, "m_hThrower", client);

		SetEntPropEnt(naded[client], Prop_Data, "m_hOwnerEntity", client);
		SetEntProp(naded[client],Prop_Data,"m_iTeamNum",GetClientTeam(client));
		SetEntProp(naded[client],Prop_Send,"m_bIsLive", true, 1);

		ActivateEntity(naded[client]);
		
		
		//char name[PLATFORM_MAX_PATH];
		//char buff[PLATFORM_MAX_PATH];
		//GetClientName(client, name, sizeof(name));
		//Format(buff,sizeof(buff),"%s's grenade",name)
		SetVariantFloat(3.0);
		AcceptEntityInput(naded[client], "SetTimer");
		
		
		TeleportEntity(naded[client], Location, eyeang, vel);

		//ReplyToCommand(client,"%s thown.",buff);

		isWaiting[client] = true;
		CreateTimer(sm_grenade_delay.FloatValue,finishWait,client,TIMER_FLAG_NO_MAPCHANGE);
	}
	else 
	{
		PrintToChat(client,"Ent nade not created.");
	}
	
	
	return Plugin_Handled;
}

public Action finishWait(Handle t, int client)
{
	isWaiting[client] = false;
}