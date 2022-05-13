-- May remove this module. Will test run it for a little bit, should save some moderation work in the long run.

local warnLimit = 10
local warnClearTimeInDays = 1 
local dayInSeconds = 86400

local TEST_TIME = 32400

function hasPlayerExceededWarnLimit(ply, warns)
  
  -- Could just count the amount of kicks and then ban after threshold, but i think this will be annoying enough,

  if warns >= warnLimit then

    ply:Kick("You exceeded your warn limit for attempted Mass RDM")

  end

end

function savePlayerWarns(ply)

  sql.Query("CREATE TABLE IF NOT EXISTS nokillzones_warns( steam_id TEXT , warns NUMBER, lastWarn NUMBER )" )

  local playerWarnsFound = sql.Query("SELECT * FROM nokillzones_warns WHERE steam_id ="..SQLStr(ply:SteamID()))

  local timeNow = os.time()

  if playerWarnsFound then

    local updatedWarns = tonumber(playerWarnsFound[1]["warns"]) + 1

    -- Check if x amount of time has passed since last warn, and if so reset warn count.

    local lastWarnTime = tonumber(playerWarnsFound[1]["lastWarn"])

    if timeNow > lastWarnTime + TEST_TIME then

      updatedWarns = 1

    end

    sql.Query("UPDATE nokillzones_warns SET warns = "..SQLStr(updatedWarns)..", lastWarn = "..SQLStr(timeNow).."WHERE steam_id = "..SQLStr(ply:SteamID()))

    hasPlayerExceededWarnLimit(ply, updatedWarns)

    return updatedWarns

  else

    sql.Query("INSERT INTO nokillzones_warns(steam_id, warns, lastWarn) VALUES("..SQLStr(ply:SteamID())..", 1, "..SQLStr(timeNow)..")")

    return 1

  end

end


function GM:PlayerShouldTakeDamage(victim, p1)
  
  local ply = victim

  local playerHealth = ply:Health()

  local mineShaftCornerStart = Vector(3227.393799, 1734.808350, -383.706390)
  local mineShaftCornerEnd = Vector(4356.834473, 620.909241, -606.532654)

  if team.GetName(ply:Team()) == "Miner" then

    local playerPos = ply:GetPos()

    if playerPos:WithinAABox(mineShaftCornerStart, mineShaftCornerEnd) then 
    
      ply:SetHealth(playerHealth)

      local returnedPlayerWarns = savePlayerWarns(p1)

      p1:LiquidChat("ANTI-RDM", Color(0,200,200), "You are not aloud to attack miners working!, you will be kicked! "..tostring(returnedPlayerWarns) .. "/"..warnLimit.." warns")

      return false

    end
  
  end

  return true

end