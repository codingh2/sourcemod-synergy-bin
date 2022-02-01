#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

int snaded[128];
bool isWaiting[128];
ConVar sm_sticky_delay;
float s_newpos[128][3];
int par[128];

public Plugin myinfo = 
{
	name = "stickynade",
	author = "Vamp",
	description = "Player throws sticky grenades",
	version = "0.1",
	url = ""
}

public void OnPluginStart()
{
	RegConsoleCmd("sticky", sticky, "Throw a sticky grenade.");
	sm_sticky_delay = CreateConVar("sm_sticky_delay", "3.0", "SM sticky Grenades Delay");
	PrintToServer("[SM] Vamp sticky grenade plugin loaded ");
	PrintToServer("[[Use 'sm_sticky_delay' to change the waiting time.]]");

		
}



public Action sticky(int client, int args)
{
	if (client == 0) return Plugin_Handled;
	int iFrags = GetEntProp(client, Prop_Send, "m_iAmmo", _, 12);
	//Delete iFrags = 99; when compiling for public.
	//iFrags = 99;
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

	snaded[client] = CreateEntityByName("npc_grenade_frag");
	//bugbait - frag
		
	if (IsValidEntity(snaded[client]) && DispatchSpawn(snaded[client]))
	{
		//PrintToChat(client,"Ent nade created");
		//Uncomment when implementing to public use.
		SetEntProp(client, Prop_Data, "m_iAmmo", iFrags-1, _, 12);
		//
		GetAngleVectors(eyeang, vel, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vel, 600.0);
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", pvel);
		AddVectors( vel, pvel, vel);
		
		
  
		DispatchKeyValue(snaded[client],"solid","1");
	
		SetEntPropEnt(snaded[client], Prop_Data, "m_hThrower", client);

		SetEntPropEnt(snaded[client], Prop_Data, "m_hOwnerEntity", client);
		SetEntProp(snaded[client],Prop_Data,"m_iTeamNum",GetClientTeam(client));
		SetEntProp(snaded[client],Prop_Send,"m_bIsLive", true, 1);

		ActivateEntity(snaded[client]);
		SetEntityModel(snaded[client],"models/weapons/w_grenade.mdl");
		SetEntityRenderColor(snaded[client],112,130,56,255); //army green

		//SetVariantFloat(3.0);
		//AcceptEntityInput(snaded[client], "SetTimer");
		
		
		TeleportEntity(snaded[client], Location, eyeang, vel);
		
		//ReplyToCommand(client,"%s thown.",buff);
		
		
		CreateTimer(0.1,Splash,client,TIMER_REPEAT);
		
		
		//SDKHook(client,SDKHook_Think, Splash);
	
		isWaiting[client] = true;
		CreateTimer(sm_sticky_delay.FloatValue,finishWait,client,TIMER_FLAG_NO_MAPCHANGE);
		
		
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



public Action Splash(Handle t, int client)
{
	//PrintToChatAll("Splash called.");
	int tn;
	int id;
	float v[3];
	float tpos[3];
	Handle hpos = INVALID_HANDLE;

	if (IsValidEntity(snaded[client]) )
	{
		
		GetEntPropVector(snaded[client],Prop_Send,"m_vecOrigin",s_newpos[client]);
		//PrintToChatAll("P> %.2f %.2f %.2f",s_newpos[client][0],s_newpos[client][1],s_newpos[client][2]);
		int ent = snaded[client];
		for(new k; k< 360; k+=10)
		{
			v[0] = float(k);

			hpos = TR_TraceRayFilterEx (s_newpos[client],v,MASK_SOLID,RayType_Infinite, TraceRayDontHitSelf);
			if (TR_DidHit(hpos))
			{
				id = TR_GetEntityIndex(hpos);
				TR_GetEndPosition(tpos,hpos);
				if (GetVectorDistance(s_newpos[client],tpos) < 10)
				{
					//PrintToChatAll("Wall %d",id);
					//if (id == 0) {
					//	SetEntityMoveType(ent,MOVETYPE_NONE);

					par[client] = id;
					CloseHandle(hpos);
					AcceptEntityInput(ent,"Kill");
					break;
					//}
				}
			}
		}
		for(new k; k< 360; k+=10)
		{
			v[1] = float(k);

			hpos = TR_TraceRayFilterEx (s_newpos[client],v,MASK_SOLID,RayType_Infinite, TraceRayDontHitSelf);
			if (TR_DidHit(hpos))
			{
				id = TR_GetEntityIndex(hpos);
				TR_GetEndPosition(tpos,hpos);
				if (GetVectorDistance(s_newpos[client],tpos) < 10)
				{
					//PrintToChatAll("Wall %d",id);
					//if (id == 0) {
					//	SetEntityMoveType(ent,MOVETYPE_NONE);

					par[client] = id;
					CloseHandle(hpos);
					AcceptEntityInput(ent,"Kill");
					break;
					//}
				}
			}
		}
		for(new k; k< 360; k+=10)
		{
			v[2] = float(k);

			hpos = TR_TraceRayFilterEx (s_newpos[client],v,MASK_SOLID,RayType_Infinite, TraceRayDontHitSelf);
			if (TR_DidHit(hpos))
			{
				id = TR_GetEntityIndex(hpos);
				TR_GetEndPosition(tpos,hpos);
				if (GetVectorDistance(s_newpos[client],tpos) < 10)
				{
					//PrintToChatAll("Wall %d",id);
					//if (id == 0) {
					//	SetEntityMoveType(ent,MOVETYPE_NONE);

					par[client] = id;
					CloseHandle(hpos);
					AcceptEntityInput(ent,"Kill");
					break;
					//}
				}
			}
		}
	}
	else
	{
		//PrintToChat(client,"Woosh");
		tn = CreateEntityByName("npc_grenade_frag");
		DispatchSpawn(tn)
		DispatchKeyValue(tn,"solid","1");
		
		//SetEntProp(tn,Prop_Data,"m_nSolidType",1);
	
		SetEntPropEnt(tn, Prop_Data, "m_hThrower", client);

		SetEntPropEnt(tn, Prop_Data, "m_hOwnerEntity", client);
		SetEntProp(tn,Prop_Data,"m_iTeamNum",GetClientTeam(client));
		SetEntProp(tn,Prop_Send,"m_bIsLive", true, 1);

		ActivateEntity(tn);
		SetEntityModel(tn,"models/weapons/w_grenade.mdl");
		SetEntityRenderColor(tn,112,130,56,255); //army green
		SetEntityMoveType(tn,MOVETYPE_NONE);
		SetVariantFloat(3.0);
		AcceptEntityInput(tn, "SetTimer");
		TeleportEntity(tn,s_newpos[client],NULL_VECTOR,NULL_VECTOR);
		if (par[client] != 0 && IsValidEntity(par[client]))
		{
			SetParent(par[client],tn);
		}
	
		return Plugin_Stop ;
	} 
	
	
	
	return Plugin_Handled;
}

public bool TraceRayDontHitSelf(int entity, int mask, any data)
{
    return entity != data && !(0 < entity <= MaxClients);
}  

stock SetParentEx(iParent, iChild)
{
	SetVariantString("!activator");
	AcceptEntityInput(iChild, "SetParent", iParent, iChild);
}

// player "eyes" "righteye" "lefteye" "partyhat" "head" "flag"
// weapon "muzzle" "eject_brass"
stock SetParent(iParent, iChild, const String:szAttachment[] = "", Float:vOffsets[3] = {0.0,0.0,0.0})
{
	SetVariantString("!activator");
	AcceptEntityInput(iChild, "SetParent", iParent, iChild);

	if (szAttachment[0] != '\0') // Use at least a 0.01 second delay between SetParent and SetParentAttachment inputs.
	{
		SetVariantString(szAttachment); // "head"

		if (!AreVectorsEqual(vOffsets, Float:{0.0,0.0,0.0})) // NULL_VECTOR
		{
			decl Float:vPos[3];
			GetEntPropVector(iParent, Prop_Send, "m_vecOrigin", vPos);
			AddVectors(vPos, vOffsets, vPos);
			TeleportEntity(iChild, vPos, NULL_VECTOR, NULL_VECTOR);
			AcceptEntityInput(iChild, "SetParentAttachmentMaintainOffset", iParent, iChild);
		}
		else
		{
			AcceptEntityInput(iChild, "SetParentAttachment", iParent, iChild);
		}
	}
}

stock bool:AreVectorsEqual(Float:vVec1[3], Float:vVec2[3])
{
	return (vVec1[0] == vVec2[0] && vVec1[1] == vVec2[1] && vVec1[2] == vVec2[2]);
}
