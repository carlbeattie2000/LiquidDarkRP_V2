util.AddNetworkString("open_r_warn")
util.AddNetworkString("r_chat_warn")

local meta = FindMetaTable("Player")

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

function sendHWarnMenuOpenMessage(ply)

  if !ply:playerHasPerms() then return end

  net.Start("open_r_warn")
  
  net.Send(ply)

end

function setupSqlTable()

  sql.Query("CREATE TABLE IF NOT EXISTS r_warns (id INTEGER PRIMARY KEY AUTOINCREMENT, steam_id TEXT, reason TEXT, warn_time INTEGER, active INTEGER)")

end
setupSqlTable()

function newWarnSQL(steam_id, reason)

  local currentTimeMilliseconds = os.time() * 1000

  sql.Query("INSERT INTO r_warns (steam_id, reason, warn_time, active) VALUES (" 
  .. sql.SQLStr(steam_id) .. "," 
  .. sql.SQLStr(reason) .. "," 
  .. sql.SQLStr(currentTimeMilliseconds) .. "," 
  .. sql.SQLStr(1) 
  .. ")")

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

function warnPlayer(ply, reason)

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

  newWarnSQL(ply:SteamID(), reason)

end

function warnPlayerCommand(ply, args)

  if !ply:playerHasPerms() then return end

  if #args < 1 then

    sendHWarnMenuOpenMessage(ply)

    return

  end

  local expl = string.Explode(" ", args or "")
  local target = GAMEMODE:FindPlayer(expl[1])
	local reason = table.concat(expl, " ", 2)

  if !target || !reason then

    return ply:ChatPrint("!warn <player_name> <reason>")

  end

  warnPlayer(target, reason)

  return ""

end

AddChatCommand("!warn", warnPlayerCommand)