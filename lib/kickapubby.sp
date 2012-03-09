#pragma semicolon 1

#include <sourcemod>

#define AUTOLOAD_EXTENSIONS
#define REQUIRE_EXTENSIONS
#include <steamtools>

#define PLUGIN_VERSION "0.1.0"

public Plugin:myinfo = {
  name        = "Kick a Pubby",
  author      = "Sean Roberts",
  description = "",
  version     = PLUGIN_VERSION,
  url         = "http://github.com/SeanRoberts"
};



new Handle:groupID  = INVALID_HANDLE;
new Handle:goons    = INVALID_HANDLE;
new Handle:pubbies  = INVALID_HANDLE;



public OnPluginStart()
{
  LogMessage("Starting Kick-a-Pubby");
  LoadTranslations("common.phrases");
  groupID = CreateConVar("sm_steamgroup", "116359");
  pubbies = CreateArray();
  goons   = CreateArray();

  RegAdminCmd("sm_kickpubby", DoKick, ADMFLAG_KICK);
  RegConsoleCmd("whois", DoList);
}

public OnClientPostAdminCheck(client)
{
  if (client != 0 && IsClientInGame(client) && !IsClientReplay(client)) {
    if(!Steam_RequestGroupStatus(client, GetConVarInt(groupID))) {
      WarnAdmins(client);
    }
  }
}

public OnClientDisconnect(client)
{
  new i = FindValueInArray(pubbies, client);
  if (i != -1) {
    RemoveFromArray(pubbies, i);
  }

  i = FindValueInArray(goons, client);
  if (i != -1)
  {
    RemoveFromArray(goons, i);
  }
}

public Action:DoList(client, args) {
  if (GetArraySize(goons) > 0) {
    for (new i; i < GetArraySize(goons); i++) {
      if(IsClientInGame(GetArrayCell(goons, i))) {
        ReplyToCommand(client, "[LCs] Goon: %N", GetArrayCell(goons, i));
      }
    }
  }

  if (GetArraySize(pubbies) > 0) {
    for (new i; i < GetArraySize(pubbies); i++) {
      if(IsClientInGame(GetArrayCell(goons, i))) {
        ReplyToCommand(client, "[LCs] PUBBY: %N", GetArrayCell(pubbies, i));
      }
    }
  }
  return Plugin_Handled;
}

public Action:DoKick(client, args) {
  if (GetArraySize(pubbies) > 0 && IsClientInGame(GetArrayCell(pubbies, 0))) {
    ReplyToCommand(client, "[LCs] Kicking %N", GetArrayCell(pubbies, 0));
    KickClientEx(client, "Making room for a Lost Continents member, sorry");
  } else {
    ReplyToCommand(client, "[LCs] No pubbies to kick.");
  }
  return Plugin_Handled;
}

public WarnAdmins(client)
{
  for (new i; i <= MaxClients; i++)
  {
    if (!IsClientInGame(i) || !GetAdminFlag(GetUserAdmin(client), Admin_Ban))
    {
      continue;
    }

    PrintToChat(i, "[LCs] Player %N bypassed Group check. Server disconnected from Steam?", client);
  }
}

public Steam_GroupStatusResult(client, groupAccountID, bool:groupMember, bool:groupOfficer)
{
  if (groupAccountID == GetConVarInt(groupID) && !groupMember)
  {
    PushArrayCell(pubbies, client);
  } else {
    PushArrayCell(goons, client);
  }
}