util.AddNetworkString("open_h_warn")

function sendHWarnMenuOpenMessage(ply)

  net.Start("open_h_warn")
  
  net.Send(ply)

end

hook.Add( "PlayerSay" , "!warn", sendHWarnMenuOpenMessage)

concommand.Add("h_warn", sendHWarnMenuOpenMessage)