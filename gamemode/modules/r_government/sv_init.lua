local function PrintConsoleTaggedMessage(msg)

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
util.AddNetworkString("open_mayor_menu")
util.AddNetworkString("update_client_gov_details")
util.AddNetworkString("request_client_gov_details")

local meta = FindMetaTable("Player")

local serverDataLastUpdated = {}
local clientDataLastUpdated = {}

function serverDataUpdated(groupName)

  serverDataLastUpdated[groupName] = CurTime()

end

function playerDataUpdated(ply, groupName)

  clientDataLastUpdated[ply:SteamID()][groupName] = CurTime()

end

function meta:isDataSynced(groupName)

  return serverDataLastUpdated[groupName] < clientDataLastUpdated[self:SteamID()][groupName]

end

-- Load default settings into action
local voting = R_GOVERNMENT.Config.VotingSettings


-- Reset Government Budget
function resetGovernmentBudget()

  R_GOVERNMENT.budget = {

    ["police_force_jobs_budget"] = 0.25, -- 25%

    ["police_force_equipment_budget"] = 0.25, -- 25%

    ["national_lottery_funds"] = 0.4, -- 40%

    ["national_deposit"] = 0.07, -- 9%

    ["mayors_salary"] = 0.03 -- 3%

  }

  serverDataUpdated("government_values")

end

-- Reset Government Taxes
function resetGovernmentTaxes()

  R_GOVERNMENT.playerTaxes["player_tax"]["tax"] = R_GOVERNMENT.playerTaxes["player_tax"]["min"]
  R_GOVERNMENT.playerTaxes["sales_tax"]["tax"] = R_GOVERNMENT.playerTaxes["sales_tax"]["min"]
  R_GOVERNMENT.playerTaxes["trading_tax"]["tax"] = R_GOVERNMENT.playerTaxes["trading_tax"]["min"]

  serverDataUpdated("government_values")

end

-- Reset Government Funds
function resetGovernmentFunds()

  R_GOVERNMENT.funds = R_GOVERNMENT.Config.DefaultGovernmentFunds || 0

  serverDataUpdated("government_values")

end

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
  
  R_GOVERNMENT.candidates[self:SteamID()] = {
    ["steam_id"] = self:SteamID(),
    ["votes"] = 0
  }

  self:LiquidChat(R_GOVERNMENT.Config.chatTag, R_GOVERNMENT.Config.chatTagColor, "You have joined the election!")

  if !R_GOVERNMENT.electionRunning then

    if canStartElection() then

      startElection()

    end

  end

  serverDataUpdated("government_voting")

  updateClientCandidates()

end

function meta:addVote()

  R_GOVERNMENT.candidates[self:SteamID()]["votes"] = R_GOVERNMENT.candidates[self:SteamID()]["votes"] + 1

  serverDataUpdated("government_voting")

  updateClientCandidates()

end

function meta:isCandidate()

  return R_GOVERNMENT.candidates[self:SteamID()] != nil

end

function meta:isMayor()

  return R_GOVERNMENT.mayor == self:SteamID()

end

function meta:setMayor()

  R_GOVERNMENT.mayor = self:SteamID()

  R_GOVERNMENT.mayorActive = true

  self:ChangeTeam(R_GOVERNMENT.mayorTeamID, true)

  serverDataUpdated("government_voting")

end

function getMayor()

  return R_GOVERNMENT.mayor

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

  serverDataUpdated("government_voting")

  updateMayorStatus()

end

function notifyMayor(msg)

  local mayor = getMayor()
  
  if mayor != nil then

    mayor:LiquidChat(R_GOVERNMENT.Config.chatTag, R_GOVERNMENT.Config.chatTagColor, msg)

  end
  
end

function canStartElection()

  return tablelength(R_GOVERNMENT.candidates) >= R_GOVERNMENT.Config.VotingSettings["min_candidates"] && !R_GOVERNMENT.mayorActive

end

function startElection()

  R_GOVERNMENT.electionRunning = true

  net.Start("election_started")
  net.Broadcast()

  serverDataUpdated("government_voting")

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

  serverDataUpdated("government_voting")

  updateClientCandidates()

end

function findWinner()

  local highestVotes = 0
  local plySteamID = nil

  for _, v in pairs(R_GOVERNMENT.candidates) do

    if v["votes"] == 0 && highestVotes == 0 then

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

  if plySteamID == nil then return nil end

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

function handleMayorMenuRequest(ply, _, args)

  if ply:isMayor() then

    net.Start("open_mayor_menu")
    net.Send(ply)

    return ""

  end

  ply:LiquidChat(R_GOVERNMENT.Config.chatTag, R_GOVERNMENT.Config.chatTagColor, "Only the mayor can access this menu!")

  return ""

end

concommand.Add("mayor_menu", handleMayorMenuRequest)
AddChatCommand("!mayor", handleMayorMenuRequest)

net.Receive("request_updated_client_candidates", updateClientCandidates)

net.Receive("is_mayor_active", updateMayorStatus)

-- Remove player from election when they disconnect
hook.Add("PlayerDisconnected", "playerVoteLeave", function(ply)
  
  if ply:isCandidate() then

    local playerIndex = nil

    for k, v in pairs(R_GOVERNMENT.candidates) do

      if v["steam_id"] == ply:SteamID() then

        table.remove(R_GOVERNMENT.candidates, i)

        updateClientCandidates()

        return

      end

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

Core R_GOVERNMENT functionally

---------------------------------------------------------------------------*/
function addGovernmentFunds(a)

  R_GOVERNMENT.funds = R_GOVERNMENT.funds + a

  serverDataUpdated("government_values")

end

function clientUpdateGovernmentDetails(ply)

  net.Start("update_client_gov_details")

    -- Taxes 
    net.WriteFloat(R_GOVERNMENT.playerTaxes["player_tax"]["tax"])
    net.WriteFloat(R_GOVERNMENT.playerTaxes["sales_tax"]["tax"])
    net.WriteFloat(R_GOVERNMENT.playerTaxes["trading_tax"]["tax"])

    -- Budget
    net.WriteFloat(R_GOVERNMENT.budget["police_force_jobs_budget"])
    net.WriteFloat(R_GOVERNMENT.budget["police_force_equipment_budget"])
    net.WriteFloat(R_GOVERNMENT.budget["national_lottery_funds"])
    net.WriteFloat(R_GOVERNMENT.budget["national_deposit"])
    net.WriteFloat(R_GOVERNMENT.budget["mayors_salary"])

    -- Funds
    net.WriteDouble(R_GOVERNMENT.funds)

  net.Send(ply)

  playerDataUpdated(ply, "government_values")

end

function requestUpdatedGovernmentDetails(_, ply)

  -- If the player requesting the update is already synced, we can just assume they are spamming
  if ply:isDataSynced("government_values") then return end

  local onlinePlayers = player.GetAll()

  for _, v in ipairs(onlinePlayers) do

    if v:isDataSynced("government_values") then

      continue

    end
    
    clientUpdateGovernmentDetails(v)

  end

end

net.Receive("request_client_gov_details", requestUpdatedGovernmentDetails)

--/ SALARY TAX \--
function handlePlayerSalaryPay(ply, salary)

  local tax =  R_GOVERNMENT.playerTaxes["player_tax"]["tax"]

  local taxedAmount = math.floor(salary * tax)

  local playerTaxedSalary = math.floor(salary - taxedAmount)

  local paycheckMsg = string.format("You have received a paycheck of $%s and was taxed $%s. It is now in your wallet", REBELLION.format_num(playerTaxedSalary), REBELLION.format_num(taxedAmount))

  ply:LiquidChat(R_GOVERNMENT.Config.chatTag, R_GOVERNMENT.Config.chatTagColor, paycheckMsg)

  ply:AddMoney(playerTaxedSalary)
  
  addGovernmentFunds(taxedAmount)

end

--/ F4 MENU SALES \--
function handleItemSale(ply, itemName, itemPrice)

  local tax =  R_GOVERNMENT.playerTaxes["sales_tax"]["tax"]

  local taxedAmount = math.floor(itemPrice * tax)

  local itemTaxedAmount = math.floor(itemPrice - taxedAmount)

  local saleMessage = string.format("You have purchased a %s for $%s and was taxed $%s", itemName, REBELLION.format_num(itemTaxedAmount), REBELLION.format_num(taxedAmount))

  ply:LiquidChat(R_GOVERNMENT.Config.chatTag, R_GOVERNMENT.Config.chatTagColor, saleMessage)

  ply:AddMoney(-itemPrice)

  addGovernmentFunds(taxedAmount)

end

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

  hook.Add("PlayerInitialSpawn", "setupNetTablesPly", function(ply)

    clientDataLastUpdated[ply:SteamID()] = {
      ["government_values"] = 0,
      ["government_voting"] = 0
    }
  
  end)

  resetGovernmentBudget()

  resetGovernmentTaxes()

  resetGovernmentFunds()

  timer.Simple(1, function()

    if !loadMayorCustomCheck() then

      status = false

    end

    loadDefaultJobSettings()

    hook.Add("r_government_payday", "rGovernmentSalary", handlePlayerSalaryPay)
    hook.Add("r_government_item_sale", "rGovernmentSale", handleItemSale)

    InitFinished(status)

  end)

end

hook.Add("Initialize", "rGovernmentInit", rGovernmentInit)