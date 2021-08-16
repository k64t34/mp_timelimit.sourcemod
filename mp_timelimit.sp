//#C:\pro\SourceMod\MySMcompile.exe "$(FULL_CURRENT_PATH)"
// Timers https://hlmod.ru/threads/sourcepawn-urok-6-tajmery.37541/
#define DEBUG 1
#define PLUGIN_NAME  "mp_timelimit"
#define PLUGIN_VERSION "1.0"
int gPLUGIN_NAME[]=PLUGIN_NAME;

#include "k64t"//#include <sourcemod> 
int g_iInterval;
//Handle handleTimerCountdown=INVALID_HANDLE;
Handle hConVar_mp_timelimit=INVALID_HANDLE;
public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = "Kom64t",
    description = "Set mp_timelimit up to end of hour.",
    version = PLUGIN_VERSION,
    url = "https://github.com/k64t34/mp_timelimit.sourcemod"
};
//***********************************************
public void OnPluginStart(){
//***********************************************	
#if defined DEBUG	
DebugPrint("OnPluginStart");
#endif 
}
//***********************************************
public Action StartCountDown(Handle timer){
//***********************************************	
#if defined DEBUG	
DebugPrint("StartCountDown");
#endif 	
g_iInterval=61;
//handleTimerCountdown=
CreateTimer(1.0, Timer_Countdown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
//#if defined DEBUG	
//if (handleTimerCountdown==INVALID_HANDLE)
//	DebugPrint("StartCountDown. Error create  timer");
//#endif 	
}
//***********************************************
public Action Timer_Countdown(Handle timer){
//***********************************************	
g_iInterval--;
#if defined DEBUG	
DebugPrint("Timer_Countdown %i",g_iInterval);
#endif 	
//if (g_iInterval <= 0)
//{
//	//handleTimerCountdown=INVALID_HANDLE;
//	return Plugin_Stop;
//}

if (g_iInterval <= 0)return Plugin_Stop;
else 
	{
	PrintHintTextToAll("%d ", g_iInterval);		
	return Plugin_Continue;
	}
}

//***********************************************
public void OnMapEnd(){
//***********************************************	
#if defined DEBUG		
DebugPrint("OnMapEnd");
#endif
g_iInterval=0;
//if (handleTimerCountdown!=INVALID_HANDLE)	
}
//***********************************************
public void OnMapStart(){
//***********************************************	
#if defined DEBUG		
DebugPrint("OnMapStart");
#endif
//https://sm.alliedmods.net/new-api/sourcemod/GetTime
//int GetTime(int bigStamp[2])
//Parameters
//int[2] bigStamp
//Optional array to store the 64bit timestamp in.
//Return Value
//32bit timestamp (number of seconds since unix epoch).00:00:00 UTC) 1 января //1970 года 
/*
FormatTime
%a abbreviated weekday name (Sun) 
%A full weekday name (Sunday) 
%b abbreviated month name (Dec) 
%B full month name (December) 
%c date and time (Dec 2 06:55:15 1979) 
%d day of the month (02) 
%H hour of the 24-hour day (06) 
%I hour of the 12-hour day (06) 
%j day of the year, from 001 (335) 
%m month of the year, from 01 (12) 
%M minutes after the hour (55) 
%p AM/PM indicator (AM) 
%S seconds after the minute (15) 
%U Sunday week of the year, from 00 (48) 
%w day of the week, from 0 for Sunday (6) 
%W Monday week of the year, from 00 (47) 
%x date (Dec 2 1979) 
%X time (06:55:15) 
%y year of the century, from 00 (79) 
%Y year (1979) 
*/
hConVar_mp_timelimit=FindConVar("mp_timelimit");
if (hConVar_mp_timelimit!=INVALID_HANDLE){
char strMinute[3];
char strSecond[3];
FormatTime(strMinute, 3, "%M",GetTime());
FormatTime(strSecond, 3, "%S",GetTime());
int Minute = StringToInt(strMinute);
int Second = StringToInt(strSecond);
if (Second!=0) Minute++;
#if defined DEBUG
Minute=2;
#else
Minute=60-Minute;
#endif
//handleTimerCountdown=
CreateTimer(60.0*(Minute-1)-2/*+(60.0-Second)*/, StartCountDown,_,TIMER_FLAG_NO_MAPCHANGE);
//ServerCommand("mp_timelimit %i",Minute);
SetConVarInt(hConVar_mp_timelimit, Minute);//, bool replicate, bool notify)
#if defined DEBUG		
PrintToServer("Set timelimit to %i",Minute);
#endif
}
}
//***********************************************
//public void Event_MapStart(Event event, const char[] name, bool dontBroadcast){
//#if defined DEBUG
//DebugPrint("Event_MapStart");
//#endif 
//PrintToServer("Event_MapStart");
//AutoExecConfig(true, gPLUGIN_NAME);
//}


#endinput

#include "k64t"
// ConVar
Handle cvarMinHealth = INVALID_HANDLE;
Handle cvarMaxHealth = INVALID_HANDLE;
Handle cvarUsageMySelf = INVALID_HANDLE;
//new gUsageMySelf;
Handle cvarUsageTM = INVALID_HANDLE;
//new gUsageTM;
// Global Var
int gPLUGIN_NAME[]=PLUGIN_NAME;
int  MedicUsed[MAX_PLAYERS+1][2];
int  HealProcess[MAX_PLAYERS+1][MAX_PLAYERS+1];
#define MYSELF 0
#define TM 1
Handle HealProcessTimer[MAX_PLAYERS+1] = INVALID_HANDLE;

public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = "k64t@ya.ru",
    description = "Plugin allows to heal yourself and teammate",
    version = PLUGIN_VERSION,
    url = ""
};
//***********************************************
void OnPluginStart(){
//***********************************************
#if defined DEBUG
DebugPrint("OnPluginStart");
#endif 
//LoadTranslations("dod_medicaid.phrases");

cvarMinHealth = CreateConVar( "medicaid_MinHealth", "33");
cvarMaxHealth = CreateConVar( "medicaid_MaxHealth", "50");
cvarUsageMySelf = CreateConVar( "medicaid_UsageMySelf", "1");
cvarUsageTM = CreateConVar( "medicaid_UsageTeammate", "2");


//HookEvents
HookEvent("player_death", EventPlayerDeath);
HookEvent("player_spawn", Event_PlayerSpawn );

RegConsoleCmd("healmyself", HealMySelf,"");
RegConsoleCmd("healyou", healyou,"");

cvarMinHealth = CreateConVar( "medicaid_minhealth", "33" );

}
//***********************************************
void OnMapStart(){
//***********************************************
AutoExecConfig(true, gPLUGIN_NAME);
}
//***********************************************
void EventPlayerDeath(Handle:event,const String:name[],bool:dontBroadcast){}
//*****************************************************************************
public  Action:HealMySelf(client, args){
//*****************************************************************************
if( !IsPlayerAlive( client ) )
	{		
	PrintToChat( client, "[%s] You can't receive medicaid while you are dead!",gPLUGIN_NAME );		
	return Plugin_Handled;
	}
new tmpInt;
tmpInt=GetConVarInt(cvarUsageMySelf);
if (MedicUsed[client][MYSELF]>=tmpInt)
	{
	PrintToChat( client, "[%s] You can receive medicaid оnly %d time(s)", gPLUGIN_NAME,tmpInt);
	return Plugin_Handled;
	}	
tmpInt = GetConVarInt( cvarMinHealth );	
if( GetClientHealth( client ) >= tmpInt )
	{
	PrintToChat( client, "[%s] Your health must be lower than '%d' to use medicaid!",gPLUGIN_NAME,tmpInt );		
	return Plugin_Handled;	
	}
MedicUsed[client][MYSELF]++;
PrintToChat( client, "[%s] Successfully use medicaid.",gPLUGIN_NAME );
SetClientHealth( client, GetConVarInt( cvarMaxHealth ) );
SetClientScreenFade( client, 255, 0, 0, 60, 1 );
	
return Plugin_Continue;
}
//*****************************************************************************
public  Action:healyou(client, args){
//*****************************************************************************
MedicUsed[client][TM]++;
return Plugin_Handled;
}


//*****************************************************************************
public Action:Event_PlayerSpawn( Handle:event, const String:name[], bool:dontBroadcast ){
//*****************************************************************************
//new id = GetClientOfUserId( GetEventInt( event, "userid" ) );
MedicUsed[GetClientOfUserId( GetEventInt( event, "userid" ) )][MYSELF] = 0;
MedicUsed[GetClientOfUserId( GetEventInt( event, "userid" ) )][TM] = 0;
}

#endinput




