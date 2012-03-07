#pragma semicolon 1

#include <sourcemod>

#define AUTOLOAD_EXTENSIONS
#define REQUIRE_EXTENSIONS
#if defined _steamtools_included
#endinput
#endif
#define _steamtools_included

native bool:Steam_RequestGroupStatus(client, groupAccountID);
native Steam_RequestGameplayStats();
native Steam_RequestServerReputation();
native Steam_ForceHeartbeat();
native bool:Steam_IsVACEnabled();
native bool:Steam_IsConnected();
native Steam_GetPublicIP(octets[4]);
forward Action:Steam_GroupStatusResult(client, groupAccountID, bool:groupMember, bool:groupOfficer);
forward Action:Steam_GameplayStats(rank, totalConnects, totalMinutesPlayed);
forward Action:Steam_Reputation(reputationScore, bool:banned, bannedIP, bannedPort, bannedGameID, banExpires);
forward Action:Steam_RestartRequested();
forward Action:Steam_SteamServersConnected();
forward Action:Steam_SteamServersDisconnected();

native Steam_RequestStats(client);
native Steam_GetStat(client, String:statName[]);
native Float:Steam_GetStatFloat(client, String:statName[]);
native bool:Steam_IsAchieved(client, String:achievementName[]);
forward Action:Steam_StatsReceived(client);
forward Action:Steam_StatsUnloaded(client);

public Extension:__ext_SteamTools =
{
  name = "SteamTools",
  file = "steamtools.ext",
#if defined AUTOLOAD_EXTENSIONS
  autoload = 1,
#else
  autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
  required = 1,
#else
  required = 0,
#endif
}

#define PLUGIN_VERSION "0.1.0"

public Plugin:myinfo = {
  name        = "GroupLock",
  author      = "Asher Baker (asherkin)",
  description = "",
  version     = PLUGIN_VERSION,
  url         = "http://limetech.org/"
};

new Handle:enabled = INVALID_HANDLE;
new Handle:groupID = INVALID_HANDLE;
new Handle:pubbyList = INVALID_HANDLE;

public OnPluginStart()
{
  LoadTranslations("common.phrases");
  pubbyList = CreateArray();
  enabled = CreateConVar("sm_grouplock_enabled", "1", "", FCVAR_NONE, true, 0.0, true, 1.0);
  groupID = CreateConVar("sm_steamgroup", "116359");
  RegAdminCmd("sm_kickpubby", KickPubby, ADMFLAG_KICK);
  RegServerCmd("sm_kickpubby", ServerKickPubby);
  RegConsoleCmd("whois", ShowPubbies);
}

public Action:ShowPubbies(client, args) {
  // Loop through clients and display their pubby status
  for (new i; i <= MaxClients; i++) {
    if (i != 0 && IsClientInGame(i) && !IsClientReplay(i))
    {
      new String:name[MAX_NAME_LENGTH];
      new String:pubby_status[32];
      GetClientName(i, name, sizeof(name));
      if (Steam_RequestGroupStatus(i, GetConVarInt(groupID)))
      {
        pubby_status = "not a pubby";
      } else {
        pubby_status = "PUBBY";
      }
      PrintToConsole(client, "%s: %s", name, pubby_status);
    }
  }
}

public Action:KickPubby(client, args)
{
  if (!DoKickPubby())
  {
    ReplyToCommand(client, "No pubbies to kick.");
  }

  return Plugin_Handled;
}

public Action:ServerKickPubby(args) {
  DoKickPubby();
  return Plugin_Handled;
}

public DoKickPubby() {
  if (GetConVarBool(enabled) || GetConVarInt(groupID) != 0)
  {
    // Loop through clients and and build a list of pubbies
    for (new i; i <= MaxClients; i++)
    {
      if (i != 0 && IsClientInGame(i) && !IsClientReplay(i))
      {
        Steam_RequestGroupStatus(i, GetConVarInt(groupID));
      }
    }

    new totalPubbies = GetArraySize(pubbyList);
    if (totalPubbies > 0)
    {
      new unluckyPubbyIdx = GetArrayCell(pubbyList, GetRandomInt(0, totalPubbies - 1));
      KickClientEx(unluckyPubbyIdx, "%s", "Kicked by Kick-a-Pubby (Sorry)");
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

public Action:Steam_GroupStatusResult(client, groupAccountID, bool:groupMember, bool:groupOfficer)
{
  if (groupAccountID == GetConVarInt(groupID) && !groupMember)
  {
    PushArrayCell(pubbyList, client);
  }
  return Plugin_Continue;

}
