util.AddNetworkString("update_client_candidates")
util.AddNetworkString("request_updated_client_candidates")
util.AddNetworkString("election_started")
util.AddNetworkString("election_ended")

local meta = FindMetaTable("Player")

-- Load default settings into action
local governmentBudget, governmentTaxes = {}

local voting = R_GOVERNMENT.Config.VotingSettings

-- Change Default Job Settings
function loadDefaultJobSettings()

  for i, v in ipairs(RPExtraTeams) do
  
    local jobSettings = R_GOVERNMENT.Config.DefaultJobSettings[v["name"]]

    if jobSettings != nil then

      RPExtraTeams[i]["max"] = jobSettings["limit"]

      RPExtraTeams[i]["salary"] = jobSettings["salary"]

    end

    if string.lower(RPExtraTeams[i]["name"]) == "mayor" then

      RPExtraTeams[i].customCheck = function(ply)

        print(ply:isMayor())

        if ply:isMayor() then return true end

        ply:LiquidChat("MAYOR-ELECTIONS", Color(213, 100, 100), "You must start / join an election to become this job!")

        return false

      end

    end
  
  end

end
loadDefaultJobSettings()

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
function meta:addPlayerAsCandidate()

  if (R_GOVERNMENT.mayorActive) then

    self:LiquidChat("MAYOR-ELECTIONS", Color(213, 100, 100), "The mayor is currently active!")

    return

  end

  if (self:isCandidate()) then return end

  local entryCost = voting["entry_cost"]

  if self:IsVIP() then entryCost = entryCost * .5 end

  if !self:CanAfford(entryCost) then 

    self:LiquidChat("MAYOR-ELECTIONS", Color(213, 100, 100), "You can't afford to join this election")

    return

  end

  self:RemoveMoney(entryCost)

  table.insert(R_GOVERNMENT.candidates, {
    ["steam_id"] = self:SteamID(),
    ["votes"] = 0
  })

  updateClientCandidates()

  self:LiquidChat("MAYOR-ELECTIONS", Color(213, 100, 100), "You have joined the election")

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

end

function canStartElection()

  return #R_GOVERNMENT.candidates >= R_GOVERNMENT.Config.VotingSettings["min_candidates"]

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

    if v["votes"] > highestVotes then

      highestVotes = v["votes"]

      plySteamID = v["steam_id"]

    end

  end

  return player.GetBySteamID(plySteamID)

end

function handleWinningPlayer(ply)

  local onlinePlayers = player.GetAll()

  for _, v in ipairs(onlinePlayers) do

    v:LiquidChat("MAYOR-ELECTIONS", Color(213, 100, 100), string.format("%s won the election!", ply:Nick()))

  end

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

net.Receive("request_updated_client_candidates", function()

  updateClientCandidates()

end)

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

end)
