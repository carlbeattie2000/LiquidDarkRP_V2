util.AddNetworkString("open_r_warn")

local aloudGroups = {
  "admin"
}

function sendHWarnMenuOpenMessage(ply)

  print(ply:IsUserGroup("superadmin"))

  net.Start("open_r_warn")
  
  net.Send(ply)

end

hook.Add( "PlayerSay" , "warn", function(ply, text)

  if (string.lower( text ) == "!warn") then

    sendHWarnMenuOpenMessage(ply)
  
  end

end)

concommand.Add("r_warn", sendHWarnMenuOpenMessage)