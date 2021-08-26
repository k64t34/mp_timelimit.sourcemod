//#C:\pro\SourceMod\MySMcompile.exe "$(FULL_CURRENT_PATH)"
// Timers https://hlmod.ru/threads/sourcepawn-urok-6-tajmery.37541/
#define nDEBUG 1
#define PLUGIN_NAME  "mp_timelimit"
#define PLUGIN_VERSION "2.5"
//int gPLUGIN_NAME[]=PLUGIN_NAME;

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
#if defined DEBUG
//***********************************************
public void OnPluginStart(){
//***********************************************
DebugPrint("OnPluginStart");
LogMessage("OnPluginStart");
}
#endif 
//***********************************************
public void OnMapStart(){
//***********************************************	
#if defined DEBUG		
DebugPrint("OnMapStart");
LogMessage("OnMapStart");
#endif
hConVar_mp_timelimit=FindConVar("mp_timelimit");
if (hConVar_mp_timelimit!=INVALID_HANDLE)
	{
	SetConVarInt(hConVar_mp_timelimit, 0);
	#if defined DEBUG		
	PrintToServer("Set timelimit to %i",0);
	#endif		
	int HMS[3];
	GetTimeHMS(HMS);
	int Minute = HMS[1];
	int Second = HMS[2];
	//if (Second!=0) Minute++;
	#if defined DEBUG
	Minute=58;			
	#endif	
	//Minute=58;			
	int LeftSecond=60*(58-Minute)+60-Second;	
	#if defined DEBUG
	PrintToServer("StartCountDown in %i %2i:%2i %i",LeftSecond,Minute,Second,60*Minute+Second);
	LogMessage("StartCountDown in %i %2i:%2i %i",LeftSecond,Minute,Second,60*Minute+Second);	
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
LogMessage("StartCountDown");
PrintToChatAll("\x04Last minute");
ServerCommand("knifeFinal");
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
	LogMessage("FinishCountDown");
	SetConVarInt(hConVar_mp_timelimit, 1);//https://sm.alliedmods.net/new-api/convars/SetConVarInt
	return Plugin_Stop;
	}
else 
	{
	//PrintHintTextToAll("%d ", g_iInterval);// ?? ????????? ?.?. HintText ?? ???????????? ? ??????? ????? ?????? ??????
	PrintCenterTextAll("%d ", g_iInterval);		
	return Plugin_Continue;
	}
}

//***********************************************
public void OnMapEnd(){
//***********************************************	
#if defined DEBUG		
DebugPrint("OnMapEnd");
LogMessage("OnMapEnd");
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


https://forums.alliedmods.net/showthread.php?t=136244&highlight=event+game_over
public OnPluginStart()
{
    HookUserMessage(GetUserMessageId("VGUIMenu"),hook_VGUIMenu,true);
}

public Action:hook_VGUIMenu(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init) 
{
    return Plugin_Handled;
} 