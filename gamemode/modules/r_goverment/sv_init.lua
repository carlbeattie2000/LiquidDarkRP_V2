util.AddNetworkString("update_client_candidates")

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
function runMayorVote()
end

function meta:addPlayerAsCandidate()

  if (self:isCandidate()) then return end

  local entryCost = voting["entry_cost"]

  if self:IsVIP() then entryCost = entryCost * .5 end

  if !self:CanAfford(entryCost) then 

    self:LiquidChat("MAYOR-ELECTIONS", Color(213, 100, 100), "You can't afford to join this election")

  end

  self:RemoveMoney(entryCost)

  table.insert(R_GOVERNMENT.candidates, {
    ["steam_id"] = self:SteamID(),
    ["votes"] = 0
  })

  updateClientCandidates()

  self:LiquidChat("MAYOR-ELECTIONS", Color(213, 100, 100), "You have joined the election")

end

function meta:isCandidate()

  for i, v in ipairs(R_GOVERNMENT.candidates) do

    if v["steam_id"] == self:SteamID() then

      return true

    end

  end

  return false

end

function meta:setMayor()
end

-- Mayor Election NPC is handled inside sh_liquiddrp.lua

concommand.Add("r_g_join_election", function(ply, cmd, args)

  ply:addPlayerAsCandidate()

end)

-- Function to update client candidates
function updateClientCandidates()

  for i, v in ipairs(player.GetAll()) do

    net.Start("update_client_candidates")

      net.WriteTable(R_GOVERNMENT.candidates)

    net.Send(v)

  end

end
