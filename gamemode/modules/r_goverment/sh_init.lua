R_GOVERNMENT  = R_GOVERNMENT || {}

R_GOVERNMENT.Config = {}

R_GOVERNMENT.Config.mayorsName = "Mayor"

R_GOVERNMENT.Config.chatTag = "R_GOVERNMENT"

R_GOVERNMENT.Config.chatTagColor = Color(213, 100, 100)

R_GOVERNMENT.Config.DefaultTeamID = 1

-- Default job limits and roles city will default too if not enough funds, or players
R_GOVERNMENT.Config.DefaultJobSettings = {

  ["Police Officer"] = {

    ["limit"] = 4,
    ["salary"] = 200

  },
  ["Police Chief"] = {

    ["limit"] = 1,
    ["salary"] = 450

  },
  ["S.W.A.T"] = {

    ["limit"] = 3,
    ["salary"] = 250

  },
  ["S.W.A.T Sniper"] = {

    ["limit"] = 2,
    ["salary"] = 300

  },
  ["S.W.A.T Commander"] = {

    ["limit"] = 1,
    ["salary"] = 450

  }

}

-- Default Funding Settings which the city will default to if not enough players.
R_GOVERNMENT.Config.minMaxTaxes = {

  ["min_player_tax"] = 0.05, -- 5% tax

  ["min_sales_tax"] = 0.1, -- 10% tax

  ["min_trading_tax"] = 0.05, -- 5% tax if player is trading cash

  ["max_player_tax"] = 0.5, -- 50%

  ["max_sales_tax"] = 0.6, -- 60%

  ["max_trading_tax"] = 0.45, -- 45%

}

R_GOVERNMENT.Config.DefaultPlayerTaxes = {

  ["player_tax"] = R_GOVERNMENT.Config.minMaxTaxes["min_player_tax"],

  ["sales_tax"] = R_GOVERNMENT.Config.minMaxTaxes["min_sales_tax"],

  ["trading_tax"] = R_GOVERNMENT.Config.minMaxTaxes["min_trading_tax"]

}

-- The default budget percentage settings to use. Total will have to always equal 100%. NO MORE NO LESS
R_GOVERNMENT.Config.DefaultBudgetSettings = {

  ["police_force_jobs_budget"] = 0.25, -- 25%

  ["police_force_equipment_budget"] = 0.25, -- 25%

  ["national_lottery_funds"] = 0.4, -- 40%

  ["national_deposit"] = 0.07, -- 9%

  ["mayors_salary"] = 0.03 -- 3%

}

-- Basically a "store" from which items can be purchased from the funds budgeted into the equipment section, and will be stored in a locker in the police department. They won't be stored in the players inventory, rather instantly equipped.
-- ENT_NAME = {nicename, price, allowed_job(nil for all)}
R_GOVERNMENT.Config.DefaultPoliceEquipmentCanBuy = {

  ["m9k_g36"] = {

    ["nicename"] = "G36 Assault Rifle",
    ["price"] = 15000,
    ["allowed_job"] = nil
    
  },

  ["m9k_m16a4_acog"] = {

    ["nicename"] = "M16-A4-ACOG Assault Rifle",
    ["price"] = 25000,
    ["allowed_job"] = {"S.W.A.T", "S.W.A.T Commander"}

  },

  ["m9k_barret_m82"] = {

    ["nicename"] = "M82-Barret Sniper Rifle",
    ["price"] = 40000,
    ["allowed_job"] = {"S.W.A.T Sniper"}

  },

  ["m9k_m92beretta"] = {

    ["nicename"] = "M92-Beretta Pistol",
    ["price"] = 12000,
    ["allowed_job"] = nil

  },

  ["m9k_mossberg590"] = {

    ["nicename"] = "Mossberg-590 Shotgun",
    ["price"] = 18000,
    ["allowed_job"] = nil

  }

}

R_GOVERNMENT.Config.VotingSettings = {

  ["min_candidates"] = 1,

  ["max_candidates"] = 5,

  ["entry_cost"] = 20000,

  ["voting_time"] = 30, -- Seconds

}

R_GOVERNMENT.Config.DefaultGovernmentFunds = 50000


-- Setup data
if SERVER then

  R_GOVERNMENT.funds = 0

  R_GOVERNMENT.candidates = {}

  R_GOVERNMENT.playersVoted = {}

  R_GOVERNMENT.electionRunning = false

  R_GOVERNMENT.mayorActive = false

  R_GOVERNMENT.mayor = nil

end

local meta = FindMetaTable("Player")

if CLIENT then

  R_GOVERNMENT.candidates = {}
  
  R_GOVERNMENT.electionRunning = false

  R_GOVERNMENT.mayorActive = false

end

function meta:isCandidate()

  for i, v in ipairs(R_GOVERNMENT.candidates) do

    if R_GOVERNMENT.candidates[i]["steam_id"] == self:SteamID() then

      return true

    end

  end

  return false

end