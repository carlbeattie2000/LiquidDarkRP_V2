function PrintConsoleTaggedMessage(msg)

  MsgC(R_GOVERNMENT.Config.chatTagColor, "["..R_GOVERNMENT.Config.chatTag.."]")
  MsgN(msg)

end

/*---------------------------------------------------------------------------

Default R_GOVERNMENT Settings

---------------------------------------------------------------------------*/

util.AddNetworkString("update_client_candidates")
util.AddNetworkString("request_updated_client_candidates")
util.AddNetworkString("is_mayor_active")
util.AddNetworkString("election_started")
util.AddNetworkString("election_ended")

local meta = FindMetaTable("Player")

-- Load default settings into action
local governmentBudget, governmentTaxes = {}

local voting = R_GOVERNMENT.Config.VotingSettings


-- Reset Government Budget
function resetGovernmentBudget()

  governmentBudget = R_GOVERNMENT.Config.DefaultBudgetSettings

end
resetGovernmentBudget()

-- Reset Government Taxes
function resetGovernmentTaxes()

  governmentTaxes = R_GOVERNMENT.Config.DefaultPlayerTaxes

end
resetGovernmentTaxes()

-- Reset Government Funds
function resetGovernmentFunds()

  R_GOVERNMENT.funds = R_GOVERNMENT.Config.DefaultGovernmentFunds

end
resetGovernmentFunds()

/*---------------------------------------------------------------------------

Mayor Voting + Job Setting

---------------------------------------------------------------------------*/

-- Add custom check to mayors job
function loadMayorCustomCheck()

  for k, job in pairs(RPExtraTeams) do
  
    if ( string.lower(R_GOVERNMENT.Config.mayorsName) == string.lower(job.name) ) then

      R_GOVERNMENT.mayorTeamID = k
      R_GOVERNMENT.mayorTeamTab = job

      job.CustomCheck = function(ply)
      
        if ply:isMayor() then return true end

        job.CustomCheckFailMsg = "Visit the mayor's secretary if you want to join the election!"

        return false

      end

      return true

    end

  end

  return false

end

-- Change Default Job Settings
function loadDefaultJobSettings()

  for i, v in ipairs(RPExtraTeams) do
  
    local jobSettings = R_GOVERNMENT.Config.DefaultJobSettings[v["name"]]

    if jobSettings != nil then

      RPExtraTeams[i]["max"] = jobSettings["limit"]

      RPExtraTeams[i]["salary"] = jobSettings["salary"]

    end
  
  end

end

function meta:addPlayerAsCandidate()

  if (R_GOVERNMENT.mayorActive) then

    self:LiquidChat(R_GOVERNMENT.Config.chatTag, R_GOVERNMENT.Config.chatTagColor, "The mayor is currently active!")

    return

  end

  if (self:isCandidate()) then return end

  local entryCost = voting["entry_cost"]

  if self:IsVIP() then entryCost = entryCost * .5 end

  if !self:CanAfford(entryCost) then 

    self:LiquidChat(R_GOVERNMENT.Config.chatTag, R_GOVERNMENT.Config.chatTagColor, "You can't afford to join this election")

    return

  end

  self:RemoveMoney(entryCost)

  table.insert(R_GOVERNMENT.candidates, {
    ["steam_id"] = self:SteamID(),
    ["votes"] = 0
  })

  updateClientCandidates()

  self:LiquidChat(R_GOVERNMENT.Config.chatTag, R_GOVERNMENT.Config.chatTagColor, "You have joined the election")

  if !R_GOVERNMENT.electionRunning then

    if canStartElection() then

      startElection()

    end

  end

end

function meta:addVote()

  for i, v in ipairs(R_GOVERNMENT.candidates) do

    if v["steam_id"] == self:SteamID() then

      R_GOVERNMENT.candidates[i]["votes"] = R_GOVERNMENT.candidates[i]["votes"] + 1

      updateClientCandidates()

      return

    end

  end

end

function meta:isCandidate()

  for i, v in ipairs(R_GOVERNMENT.candidates) do

    if v["steam_id"] == self:SteamID() then

      return true

    end

  end

  return false

end

function meta:isMayor()

  return R_GOVERNMENT.mayor == self:SteamID()

end

function meta:setMayor()

  R_GOVERNMENT.mayor = self:SteamID()

  R_GOVERNMENT.mayorActive = true

  self:ChangeTeam(R_GOVERNMENT.mayorTeamID, true)

end

function meta:removeMayor(reason)

  R_GOVERNMENT.mayor = nil

  R_GOVERNMENT.mayorActive = false

  local onlinePlayers = player.GetAll()

  for _, v in ipairs(onlinePlayers) do

    print(R_GOVERNMENT.Config.chatTag, R_GOVERNMENT.Config.chatTagColor)

    v:LiquidChat("R_GOVERNMENT", R_GOVERNMENT.Config.chatTagColor, reason)

  end

  self:TeamBan()
  self:ChangeTeam(R_GOVERNMENT.Config.DefaultTeamID, true)

  updateMayorStatus()

end

function canStartElection()

  return #R_GOVERNMENT.candidates >= R_GOVERNMENT.Config.VotingSettings["min_candidates"] && !R_GOVERNMENT.mayorActive

end

function startElection()

  R_GOVERNMENT.electionRunning = true

  net.Start("election_started")
  net.Broadcast()

  timer.Simple(R_GOVERNMENT.Config.VotingSettings["voting_time"], function()

    net.Start("election_ended")
    net.Broadcast()

    endElection()

  end)

end

function endElection()

  handleWinningPlayer(findWinner())

  R_GOVERNMENT.electionRunning = false

  R_GOVERNMENT.candidates = {}

  R_GOVERNMENT.playersVoted = {}

  updateClientCandidates()

end

function findWinner()

  local highestVotes = 0
  local plySteamID = nil

  for _, v in ipairs(R_GOVERNMENT.candidates) do

    if v["votes"] == 0 && highestVotes == 0 then

      highestVotes = 0

      plySteamID = nil

      continue

    end

    if v["votes"] == highestVotes then

      local rnd = math.random(0, 1)

      if rnd == 1 then

        highestVotes = v["votes"]

        plySteamID = v["steam_id"]

      end

      continue

    end

    if v["votes"] > highestVotes then

      highestVotes = v["votes"]

      plySteamID = v["steam_id"]

    end

  end

  if plySteamID == nil then

    return nil

  end

  return player.GetBySteamID(plySteamID)

end

function handleWinningPlayer(ply)

  local onlinePlayers = player.GetAll()

  if ply == nil then

    for _, v in ipairs(onlinePlayers) do

      v:LiquidChat(R_GOVERNMENT.Config.chatTag, R_GOVERNMENT.Config.chatTagColor, "Not enough votes!")
  
    end

    return

  end

  for _, v in ipairs(onlinePlayers) do

    v:LiquidChat(R_GOVERNMENT.Config.chatTag, R_GOVERNMENT.Config.chatTagColor, string.format("%s won the election!", ply:Nick()))

  end

  ply:setMayor()

end

-- Mayor Election NPC is handled inside sh_liquiddrp.lua

concommand.Add("r_g_join_election", function(ply, cmd, args)

  ply:addPlayerAsCandidate()

end)

concommand.Add("r_g_vote", function(ply, cmd, args)

  if table.HasValue(R_GOVERNMENT.playersVoted, ply:SteamID()) then return end

  table.insert(R_GOVERNMENT.playersVoted, ply:SteamID())

  local targetPly = player.GetBySteamID(args[1])

  if !targetPly || !targetPly:isCandidate() then return end

  targetPly:addVote()
  
end)

-- Function to update client candidates
function updateClientCandidates()

  net.Start("update_client_candidates")

    net.WriteTable(R_GOVERNMENT.candidates)

  net.Broadcast()

end

function updateMayorStatus()

  net.Start("is_mayor_active")

    net.WriteBool(R_GOVERNMENT.mayorActive)

  net.Broadcast()

end

net.Receive("request_updated_client_candidates", updateClientCandidates)

net.Receive("is_mayor_active", updateMayorStatus)

-- Remove player from election when they disconnect
hook.Add("PlayerDisconnected", "playerVoteLeave", function(ply)
  
  if ply:isCandidate() then

    local playerIndex = nil

    for i, v in ipairs(R_GOVERNMENT.candidates) do

      if v["steam_id"] == ply:SteamID() then

        playerIndex = i

      end

    end

    if playerIndex != nil then

      table.remove(R_GOVERNMENT.candidates, playerIndex)

      updateClientCandidates()

    end

  end

  if ply:isMayor() then

    local removeReason = string.format("The Mayor(%s) has disconnected, a new election can now start.", ply:Nick())

    ply:removeMayor(removeReason)

  end

end)

hook.Add("PlayerDeath", "r_demote_mayor", function(vic, _, atkr)

  if vic:isMayor() then

    local demoteMessage = string.format("The Mayor(%s) was killed, a new election can now start.", vic:Nick())

    vic:removeMayor(demoteMessage)

  end

end)

/*---------------------------------------------------------------------------

R_GOVERNMENT Init

---------------------------------------------------------------------------*/

function InitFinished(status)

  if status then

    PrintConsoleTaggedMessage("Finished Loading R_GOVERNMENT")

  else

    PrintConsoleTaggedMessage("Failed Loading R_GOVERNMENT")

  end

end

function rGovernmentInit()

  local status = true

  timer.Simple(1, function()

    if !loadMayorCustomCheck() then

      status = false

    end

    loadDefaultJobSettings()

    InitFinished(status)

  end)

end

hook.Add("Initialize", "rGovernmentInit", rGovernmentInit)
