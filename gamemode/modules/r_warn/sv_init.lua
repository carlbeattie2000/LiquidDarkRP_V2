util.AddNetworkString("open_r_warn")

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

hook.Add( "PlayerSay" , "warn", function(ply, text)

  if (string.lower( text ) == "!warn") then

    sendHWarnMenuOpenMessage(ply)

    return ""
  
  end

end)

concommand.Add("r_warn", sendHWarnMenuOpenMessage)

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

  local warnFound = local warnFound = sql.Query("SELECT id FROM r_warns WHERE id = " .. sql.SQLStr(warnID) .. ";")

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

  local warnFound = local warnFound = sql.Query("SELECT id FROM r_warns WHERE id = " .. sql.SQLStr(warnID) .. ";")

  if warnFound then

    sql.Query("UPDATE r_warns SET active = " .. sql.SQLStr(0) .. " WHERE id = " .. sql.SQLStr(warnID) .. ";")

    return true

  end

  return false
  
end