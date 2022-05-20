util.AddNetworkString("open_r_warn")
util.AddNetworkString("r_chat_warn")
util.AddNetworkString("r_player_warns_table")

local meta = FindMetaTable("Player")

local R_WARN_CONFIG = {
  ["warns_before_kick"] = 3,
  ["warns_before_ban"] = 5,
  ["warns_before_longer_ban"] = 7,
  ["warns_decay_seconds"] = 5000,
  ["warns_notify_global"] = true,
  ["warns_notify_player"] = true,
  ["warn_kick_message"] = "You have been kicked for receiving too many warns 3/5.",
  ["warn_ban_message"] = "You have been banned fir receiving to many warns 5/5.",
  ["warn_ban_time_minutes"] = 120,
  ["warn_long_ban_time_minutes"] = 720
}

local aloudGroups = {
  ["superadmin"] = {"*"},
  ["admin"] = {"warn", "remove_warn"},
  ["moderator"] = {"warn"}
}

function meta:playerHasPerms()

  local aloud = false

  for k, v in pairs(aloudGroups) do

    if self:IsUserGroup(k) then

      aloud = true
    
    end
  
  end

  return aloud

end

function meta:warnsPunishment()

  local playerWarns = findPlayersWarnsSQL(self:SteamID()) || {}

  if #playerWarns >= R_WARN_CONFIG["warns_before_longer_ban"] then

    ULib.ban(self, R_WARN_CONFIG["warn_long_ban_time_minutes"], R_WARN_CONFIG["warn_ban_message"])

  elseif #playerWarns >= R_WARN_CONFIG["warns_before_ban"] then

    ULib.ban(self, R_WARN_CONFIG["warn_ban_time_minutes"], R_WARN_CONFIG["warn_ban_message"])
  
  elseif #playerWarns >= R_WARN_CONFIG["warns_before_kick"] then

    self:Kick(R_WARN_CONFIG["warn_kick_message"])

  end

end

function sendHWarnMenuOpenMessage(ply)

  if !ply:playerHasPerms() then return end

  net.Start("open_r_warn")
  
  net.Send(ply)

end

function setupSqlTable()

  sql.Query("CREATE TABLE IF NOT EXISTS r_warns (id INTEGER PRIMARY KEY AUTOINCREMENT, steam_id TEXT, reason TEXT, warn_time INTEGER, active INTEGER, warner_steam_id TEXT, warner_nick TEXT)")

end
setupSqlTable()

function newWarnSQL(warner, steam_id, reason)

  print(warner)

  local currentTimeMilliseconds = os.time()

  sql.Query("INSERT INTO r_warns (steam_id, reason, warn_time, active, warner_steam_id, warner_nick) VALUES (" 
  .. sql.SQLStr(steam_id) .. "," 
  .. sql.SQLStr(reason) .. "," 
  .. sql.SQLStr(currentTimeMilliseconds) .. "," 
  .. sql.SQLStr(1) .. ","
  .. sql.SQLStr(warner:SteamID()) .. ","
  .. sql.SQLStr(warner:Nick()) .. ")")

end

function editWarnSQL(warnID, newReason)

  local warnFound = sql.Query("SELECT id FROM r_warns WHERE id = " .. sql.SQLStr(warnID) .. ";")

  if warnFound then

    sql.Query("UPDATE r_warns SET reason = " .. sql.SQLStr(newReason) .. " WHERE id = " .. sql.SQLStr(warnID) .. ";")

    return true
  
  end

  return false

end

function findPlayersWarnsSQL(steam_id)

  local warnsFound = sql.Query("SELECT * FROM r_warns WHERE steam_id = " .. sql.SQLStr(steam_id) .. ";")

  if warnsFound then return warnsFound end

  return false

end

function removeWarnSQL(warnID)

  local warnFound = sql.Query("SELECT id FROM r_warns WHERE id = " .. sql.SQLStr(warnID) .. ";")

  if warnFound then

    sql.Query("DELETE FROM r_warns WHERE id = " .. sql.SQLStr(warnID) .. ";")

    return true

  end

  return false

end

function clearPlayersWarnsSQL(steam_id)

  local warnsFound = sql.Query("SELECT id FROM r_warns WHERE steam_id = " .. sql.SQLStr(steam_id) .. ";")

  if warnsFound then

    sql.Query("DELETE FROM r_warns WHERE steam_id = " .. sql.SQLStr(steam_id) .. ";")

    return true

  end

  return false

end

function warnExpiredSQL(warnID)

  local warnFound = sql.Query("SELECT id FROM r_warns WHERE id = " .. sql.SQLStr(warnID) .. ";")

  if warnFound then

    sql.Query("UPDATE r_warns SET active = " .. sql.SQLStr(0) .. " WHERE id = " .. sql.SQLStr(warnID) .. ";")

    return true

  end

  return false
  
end

function warnPlayer(warner, ply, reason)

  local formattedChatString = string.format("Warned %s for %s", ply:Nick(), reason)

  local playerWarnedChatString = string.format("You have been warned for %s", reason)

  local playersOnline = player.GetAll()

  for i, v in ipairs(playersOnline) do

    local message = formattedChatString

    if v:Nick() == ply:Nick() then

      message = playerWarnedChatString
      
    end
    
    net.Start("r_chat_warn")

      net.WriteString(message)

    net.Send(v)
  
  end

  newWarnSQL(warner, ply:SteamID(), reason)

end

-- Warn Player Chat Command
function warnPlayerChatCommand(ply, args)

  if !ply:playerHasPerms() then return end

  if #args < 1 then

    sendHWarnMenuOpenMessage(ply)

    return ""

  end

  local expl = string.Explode(" ", args or "")
  local target = GAMEMODE:FindPlayer(expl[1])
	local reason = table.concat(expl, " ", 2)

  if !target || !reason then

    ply:ChatPrint("!warn <player_name> <reason>")

    return ""

  end

  warnPlayer(ply, target, reason)

  target:warnsPunishment()

  return ""

end
AddChatCommand("!warn", warnPlayerChatCommand)

-- warn console command
function warnPlayerConsoleCommand(ply, cmd, args)

  if !ply:playerHasPerms() then return end

  if !args[1] || !args[2] then
  
    ply:PrintMessage(HUD_PRINTCONSOLE, "warn <player_name> <reason>")

    return
  
  end

  local warnTarget = GAMEMODE:FindPlayer(args[1])

  warnPlayer(ply, warnTarget, args[2])

  warnTarget:warnsPunishment()

end
concommand.Add("warn", warnPlayerConsoleCommand)

-- Chat command to remove warn by id
function removePlayerWarnCommand(ply, args)

  if !ply:playerHasPerms() then return end

  local expl = string.Explode(" ", args || "")
  
  if !expl[1] then 

    ply:ChatPrint("!warnremove <warn_id>")

    return ""

  end

  removeWarnSQL(expl[1])

  ply:ChatPrint("Players warn has been removed if it exists.")

  return ""
  
end
AddChatCommand("!warnremove", removePlayerWarnCommand)

-- Load player warns command
function getPlayerWarnsCommands(ply, cmd, args)

  if !ply:playerHasPerms() then return end

  if #args < 1 then return end

  local target = GAMEMODE:FindPlayer(args[1])

  local playersWarns = findPlayersWarnsSQL(target:SteamID())

  net.Start("r_player_warns_table")

    net.WriteTable(playersWarns || {})

  net.Send(ply)

end
concommand.Add("load_player_warns", getPlayerWarnsCommands)