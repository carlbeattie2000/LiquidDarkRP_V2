util.AddNetworkString("open_r_warn")

function sendHWarnMenuOpenMessage(ply)

  net.Start("open_r_warn")
  
  net.Send(ply)

end

hook.Add( "PlayerSay" , "!warn", sendHWarnMenuOpenMessage)

concommand.Add("r_warn", sendHWarnMenuOpenMessage)