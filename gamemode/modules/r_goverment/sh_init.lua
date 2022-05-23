R_GOVERNMENT  = R_GOVERNMENT || {}

R_GOVERNMENT.Config = {}

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
R_GOVERNMENT.Config.DefaultTaxSettings = {

  ["min_player_tax"] = 0.05, -- 5% tax

  ["min_sales_tax"] = 0.1, -- 10% tax

  ["min_trading_tax"] = 0.05, -- 5% tax if player is trading cash

  ["max_player_tax"] = 0.5, -- 50%

  ["max_sales_tax"] = 0.6, -- 60%

  ["max_trading_tax"] = 0.45, -- 45%

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
R_GOVERNMENT.Config.DefaultPoliceEquipmentCanBuy = {

}