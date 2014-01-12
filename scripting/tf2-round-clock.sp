#include <sourcemod>
#include <sdktools>
#include <tf2>

new Handle:g_RoundTimeLimitCvar = INVALID_HANDLE;
new g_DefaultMaxLength;
new g_RoundTimer;

public Plugin:myinfo =
{
	name = "TF2 Round Clock",
	author = "Forward Command Post",
	description = "A plugin to adjust round timer length.",
	version = "0.1",
	url = "http://fwdcp.net/"
};

public OnPluginStart()
{
	g_RoundTimeLimitCvar = CreateConVar("mp_roundtimelimit", "10", "number of minutes to set the round time limit to", FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_PLUGIN, true, 1.0);
	HookConVarChange(g_RoundTimeLimitCvar, RoundTimeLimitChanged);
}

public OnMapStart()
{
	new entity = -1;
	
	while ((entity = FindEntityByClassname(entity, "team_round_timer")) != -1)
	{
		decl String:name[50];
		GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
		
		if (GetEntProp(entity, Prop_Send, "m_bShowInHUD") && !GetEntProp(entity, Prop_Send, "m_bStopWatchTimer") && !StrEqual(name, "zz_red_koth_timer") && !StrEqual(name, "zz_blue_koth_timer") && !StrEqual(name, "zz_teamplay_timelimit_timer") && !StrEqual(name, "zz_stopwatch_timer"))
		{
			g_RoundTimer = entity;
			g_DefaultMaxLength = GetEntProp(entity, Prop_Send, "m_nTimerMaxLength");
			
			SetRoundClock();
		}
	}
}

public RoundTimeLimitChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	SetRoundClock();
}

SetRoundClock()
{
	SetVariantInt(GetConVarInt(g_RoundTimeLimitCvar));
	AcceptEntityInput(g_RoundTimer, "SetMaxTime");
}