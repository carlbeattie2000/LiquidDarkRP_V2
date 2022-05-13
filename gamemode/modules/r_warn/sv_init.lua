util.AddNetworkString("open_h_warn")

hook.Add( "PlayerSay" , "!warn", function(ply)

  net.Start("open_h_warn")
  
  net.Send(ply)

end)