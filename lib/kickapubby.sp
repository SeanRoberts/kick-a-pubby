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
  name        = "Kick a Pubby",
  author      = "Sean Roberts",
  description = "",
  version     = PLUGIN_VERSION,
  url         = "http://github.com/SeanRoberts"
};

new Handle:enabled = INVALID_HANDLE;
new Handle:groupID = INVALID_HANDLE;
new Handle:pubbyList = INVALID_HANDLE;
new bool:kick = false;
new bool:kicked = false;

new ReplySource:Async_GroupStatus_Reply;
new Async_GroupStatus_Client;


public OnPluginStart()
{
  LoadTranslations("common.phrases");
  pubbyList = CreateArray();
  enabled = CreateConVar("sm_grouplock_enabled", "1", "", FCVAR_NONE, true, 0.0, true, 1.0);
  groupID = CreateConVar("sm_steamgroup", "116359");
  RegAdminCmd("sm_kickpubby", KickPubby, ADMFLAG_KICK);
  RegConsoleCmd("whois", ListPubbies);
}

public Action:KickPubby(client, args)
{
  kick = true;
  kicked = false;

  // Loop through clients and and build a list of pubbies
  for (new i; i <= MaxClients; i++)
  {
    if (i != 0 && IsClientInGame(i) && !IsClientReplay(i))
    {
      Steam_RequestGroupStatus(i, GetConVarInt(groupID));
    }
  }

  Async_GroupStatus_Client = client;
  Async_GroupStatus_Reply = GetCmdReplySource();
  return Plugin_Handled;
}


public Action:ListPubbies(client, args) {
  kick = false;


  // Loop through clients and and build a list of pubbies
  for (new i; i <= MaxClients; i++)
  {
    if (i != 0 && IsClientInGame(i) && !IsClientReplay(i))
    {
      Steam_RequestGroupStatus(i, GetConVarInt(groupID));
    }
  }

  Async_GroupStatus_Client = client;
  Async_GroupStatus_Reply = GetCmdReplySource();
  return Plugin_Handled;
}

public Action:Steam_GroupStatusResult(client, groupAccountID, bool:groupMember, bool:groupOfficer)
{
  if (groupAccountID == GetConVarInt(groupID) && !groupMember)
  {
    LogMessage("%N is listed as a pubby.", client);

    // Kick a pubby
    if (kick && !kicked) {
      kicked = true;
      SetCmdReplySource(Async_GroupStatus_Reply);
      ReplyToCommand(Async_GroupStatus_Client, "[LCs] Kicking %N", client);
      KickClientEx(client, "%s", "Making room for a Lost Continents member, sorry!");
      Async_GroupStatus_Reply = SM_REPLY_TO_CONSOLE;

    // List a pubby
    } else if (!kick) {
      SetCmdReplySource(Async_GroupStatus_Reply);
      ReplyToCommand(Async_GroupStatus_Client, "[LCs] PUBBY: %N", client);
      Async_GroupStatus_Reply = SM_REPLY_TO_CONSOLE;
    }
  } else {
    LogMessage("%N is no pubby!", client);

    // Note that there are, in fact, no pubbies (UNTESTED)
    if (kick && !kicked && client == (GetClientCount()-1)) {
      ReplyToCommand(Async_GroupStatus_Client, "[LCs] No pubbies to kick.");

    // List a goon
    } else if (!kick) {
      SetCmdReplySource(Async_GroupStatus_Reply);
      ReplyToCommand(Async_GroupStatus_Client, "[LCs] Goon: %N", client);
      Async_GroupStatus_Reply = SM_REPLY_TO_CONSOLE;
    }
  }

  return;
}

