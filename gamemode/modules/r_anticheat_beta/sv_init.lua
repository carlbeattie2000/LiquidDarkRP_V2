-- This is horrible and only for me testing ATM.

meta = FindMetaTable("Player")

local function PrintConsoleTaggedMessage(msg)

  MsgC(R_ANTICHEAT.chatTagColor, "["..R_ANTICHEAT.chatTag.."]")
  MsgN(msg)

end

function meta:ban(t, r)

  ULib.ban(self, t, r)

end

/*---------------------------------------------------------------------------

Net message spamming prevention (Kinda, not too sure if this works how i'm thinking it does)

---------------------------------------------------------------------------*/

function onmsg()

  local users = {}

  hook.Add( "PlayerInitialSpawn", "FullLoadSetup", function( ply )

    users[ply:SteamID()] = users[ply:SteamID()] or {
      ["recent_calls"] = 0,
      ["recent_calls_timestamp"] = CurTime(),
      ["session_spam_kicks"] = 0,
      ["kicked"] = false,
      ["banned"] = false
    }
  
    users[ply:SteamID()]["kicked"] = false
  
  end )

  function net.Incoming( len, client )

    if !client:IsValid() then return end
  
    local clientSteamID = client:SteamID()
    local clientNetHistory = users[clientSteamID]
    local timeNow = CurTime()
  
    if clientNetHistory["kicked"] or clientNetHistory["banned"] then return end
  
    if timeNow > clientNetHistory["recent_calls_timestamp"] + 10 then
  
      users[clientSteamID]["recent_calls"] = 0
      users[clientSteamID]["recent_calls_timestamp"] = CurTime()
  
    end
  
    if clientNetHistory["session_spam_kicks"] > R_ANTICHEAT.Config.Net.kicksBeforeBan && !clientNetHistory["banned"] then 
      
      if client:IsValid() then
  
        client:ban(0, R_ANTICHEAT.Config.Net.banMessage)
  
        clientNetHistory["banned"] = true
  
      end
  
      return 
  
    end
  
    if clientNetHistory["recent_calls"] > R_ANTICHEAT.Config.Net.callsBeforeKick && !clientNetHistory["kicked"] then 
      
      if client:IsValid() then
  
        client:Kick(R_ANTICHEAT.Config.Net.kickMessage)
  
        clientNetHistory["session_spam_kicks"] = clientNetHistory["session_spam_kicks"] + 1
  
        clientNetHistory["kicked"] = true
  
      end
  
      return 
  
    end
  
    users[clientSteamID]["recent_calls"] = users[clientSteamID]["recent_calls"] + 1
  
    local i = net.ReadHeader()
    local strName = util.NetworkIDToString( i )
  
    if ( !strName ) then return end
  
    local func = net.Receivers[ strName:lower() ]
    if ( !func ) then return end
  
    --
    -- len includes the 16 bit int which told us the message name
    --
    len = len - 16
  
    func( len, client )
  
  end

end

/*---------------------------------------------------------------------------

Convar checking

---------------------------------------------------------------------------*/
function cvmInit()

  local string = ""

  local charBrackets = {
    {47, 57},
    {65, 90},
    {97, 122}
  }

  for i = 1, R_ANTICHEAT.Config.ConVars.consoleCommandLength do

    local charBracketSelected = charBrackets[math.random(1, #charBrackets)]

    string = string .. string.char(math.random(charBracketSelected[1], charBracketSelected[2]))

  end

  concommand.Add(string, function(ply)


    ply:ban(R_ANTICHEAT.Config.ConVars.banLength, R_ANTICHEAT.Config.ConVars.banMessage)

  end)

  -- (Console Variable Manipulation)
  local function cvm()

    local onlinePlayers = player.GetAll()

    for __, v in pairs(onlinePlayers) do

      for _, c in pairs(R_ANTICHEAT.Config.ConVars.blacklisted) do

        v:SendLua(
          "local GetConVar = GetConVar"..
          "local var = GetConVar('".._.."')"..
          "if var:GetInt() != "..c.." then ".. 
          "LocalPlayer():ConCommand('"..string.."') "..
          "end"
        )

      end

    end

  end

  timer.Create("timer-cvm", R_ANTICHEAT.Config.ConVars.checkTime, 0, cvm)

end

/*---------------------------------------------------------------------------

Check known illegal console commands

---------------------------------------------------------------------------*/
function cCInit()

  for _, v in ipairs(R_ANTICHEAT.Config.illegalCommands) do

    concommand.Add(v, function(ply)

      ply:ban(0, "Cheating")

    end)

  end

end

function rAntiCheatInit()

  onmsg()

  cvmInit()

  cCInit()

  PrintConsoleTaggedMessage(" Finished Loading")
  
end

-- Can be disabled in config

if R_ANTICHEAT.Config.enabled then

  hook.Add("Initialize", "rAntiCheatInit", rAntiCheatInit)

end