util.AddNetworkString("open_r_warn")

local aloudGroups = {
  ["superadmin"] = {"*"},
  ["admin"] = {"warn", "remove_warn"},
  ["moderator"] = {"warn"}
}

function checkPlayerCanOpen(ply)

  local aloud = false

  for k, v in pairs(aloudGroups) do

    if ply:IsUserGroup(k) then

      aloud = true
    
    end
  
  end

  return aloud

end

function sendHWarnMenuOpenMessage(ply)

  if !checkPlayerCanOpen(ply) then return end

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