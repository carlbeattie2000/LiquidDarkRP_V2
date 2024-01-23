--[[---------------------------------------------------------------------------

Is the user using a family shared account

---------------------------------------------------------------------------]]
if not R_ANTICHEAT.Config.enabled or not R_ANTICHEAT.Config.familyShareChecking then return; end
function GM:playerFamilySharing(ply)
end

function familySharePunishment(ply, len, reason)
  if not R_ANTICHEAT.Config.FamilyShare.punishment then
    print("[R_ANTICHEAT] Punishment disabled for FamilyShare checking");
    return;
  end

  ULib.ban(ply, len, reason or "Using family shared account");
  hook.Call("playerFamilySharing", GAMEMODE, ply);
end

function familyShareCheck(ply)
  if string.len(R_ANTICHEAT.Config.steamAPIKey) <= 1 then print("[R_ANTICHEAT] Error:: No steam API key set!"); end
  local _HttpUrl = string.format("https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/?key=%s&format=json&steamid=%s&appids_filter=4000", R_ANTICHEAT.Config.steamAPIKey, ply:SteamID64());
  http.Fetch(_HttpUrl, function(body, _, _, code)
    if not body or code ~= 200 then return; end
    local bodyTable = util.JSONToTable(body);
    if not bodyTable or not bodyTable["response"] then return; end
    if not bodyTable["response"]["games"] then familySharePunishment(ply, 10, "Please un-private you're profile before rejoining."); end
    local gameTable = bodyTable["response"]["games"];
    for _, v in ipairs(gameTable) do
      if v["appid"] ~= 4000 then continue; end
      return;
    end

    familySharePunishment(ply, R_ANTICHEAT.Config.FamilyShare.punishmentLength, R_ANTICHEAT.Config.FamilyShare.punishmentMessage);
  end);
end

hook.Add("PlayerInitialSpawn", "LoadRAntiCheatFamilyChecking", familyShareCheck);
