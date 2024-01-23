--[[---------------------------------------------------------------------------

Is the user using a VPN

---------------------------------------------------------------------------]]
if not R_ANTICHEAT.Config.enabled or not R_ANTICHEAT.Config.vpnChecking then return; end
function GM:playerUsingVPN(ply)
end

function GM:playerVPNCheckingFailed(ply)
end

function vpnPunishment(ply)
  if not R_ANTICHEAT.Config.Vpn.punishment then
    print("[R_ANTICHEAT] Punishment disabled for VPN checking");
    return;
  end

  ULib.ban(ply, R_ANTICHEAT.Config.punishmentLength, R_ANTICHEAT.Config.Vpn.punishmentMessage or "Disable VPN");
end

function vpnCheck(ply)
  local _IPSplit = string.Split(ply:IPAddress(), ":");
  if _IPSplit[1] == "loopback" or _IPSplit[1] == nil then print("[R_ANTICHEAT] VPN check failed. (local or P2P Server running)"); end
  http.Fetch("http://check.getipintel.net/check.php?ip=" .. _IPSplit[1] .. "&contact=12beattiecastp@gmail.com", function(body, len, headers, code)
    if body == "1" then
      vpnPunishment(ply);
      hook.Call("playerUsingVPN", GAMEMODE, ply);
    end
  end, function(error)
    print("[R_ANTICHEAT] VPN Checking failed on player " .. ply:SteamID());
    hook.Call("playerVPNCheckingFailed", GAMEMODE, ply);
  end);
end

hook.Add("PlayerInitialSpawn", "LoadRAntiCheatVPNChecking", vpnCheck);
