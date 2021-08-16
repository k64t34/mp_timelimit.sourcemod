//#C:\pro\SourceMod\MySMcompile.exe "$(FULL_CURRENT_PATH)"
// Timers https://hlmod.ru/threads/sourcepawn-urok-6-tajmery.37541/
#define noDEBUG 1
#define PLUGIN_NAME  "mp_timelimit"
#define PLUGIN_VERSION "2.0"
int gPLUGIN_NAME[]=PLUGIN_NAME;

#include "k64t"//#include <sourcemod> 
int g_iInterval;
//Handle handleTimerCountdown=INVALID_HANDLE;
Handle hConVar_mp_timelimit=INVALID_HANDLE;
public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = "Kom64t",
    description = "Finishes the game exactly at the end of the hour",
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
//32bit timestamp (number of seconds since unix epoch).00:00:00 UTC) 1 ÿםגאנÿ //1970 דמהא 
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
if (hConVar_mp_timelimit!=INVALID_HANDLE)
	{
	SetConVarInt(hConVar_mp_timelimit, 0);
	#if defined DEBUG		
	PrintToServer("Set timelimit to %i",0);
	#endif	
	char strMinute[3];
	char strSecond[3];
	FormatTime(strMinute, 3, "%M",GetTime());
	FormatTime(strSecond, 3, "%S",GetTime());
	int Minute = StringToInt(strMinute);
	int Second = StringToInt(strSecond);
	//if (Second!=0) Minute++;
	#if defined DEBUG
	Minute=58;			
	#endif	
	int LeftSecond=60*(58-Minute)+60-Second;	
	#if defined DEBUG
	PrintToServer("StartCountDown in %i %2i:%2i %i",LeftSecond,Minute,Second,60*Minute+Second);
	#endif
	
	CreateTimer(float(LeftSecond), StartCountDown,_,TIMER_FLAG_NO_MAPCHANGE);
	}
#if defined DEBUG
else PrintToServer("Error. Cvar mp_timelimit not found");
#endif
	
}
//***********************************************
public Action StartCountDown(Handle timer){
//***********************************************	
#if defined DEBUG	
DebugPrint("StartCountDown");

int timeleft;
if (GetMapTimeLeft(timeleft))
	DebugPrint("timeleft %i",timeleft);
	else
	DebugPrint("timeleft not suppoted");	
#endif 	
g_iInterval=61;
#if defined DEBUG		
PrintToServer("Set timelimit to %i",1);
if (GetMapTimeLeft(timeleft))
	DebugPrint("timeleft %i",timeleft);
	else
	DebugPrint("timeleft not suppoted");
#endif
CreateTimer(1.0, Timer_Countdown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}
//***********************************************
public Action Timer_Countdown(Handle timer){
//***********************************************	
g_iInterval--;
#if defined DEBUG	
DebugPrint("Timer_Countdown %i",g_iInterval);
#endif 	
if (g_iInterval <= 0)
	{
	SetConVarInt(hConVar_mp_timelimit, 1);//https://sm.alliedmods.net/new-api/convars/SetConVarInt
	return Plugin_Stop;
	}
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




https://forums.alliedmods.net/showthread.php?t=136244&highlight=event+game_over
public OnPluginStart()
{
    HookUserMessage(GetUserMessageId("VGUIMenu"),hook_VGUIMenu,true);
}

public Action:hook_VGUIMenu(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init) 
{
    return Plugin_Handled;
} 