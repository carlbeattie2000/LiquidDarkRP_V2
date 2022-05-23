-- Load default settings into action
local governmentFunds, governmentBudget, governmentTaxes = {}

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

  governmentFunds = R_GOVERNMENT.Config.DefaultGovernmentFunds

end
resetGovernmentFunds()

/*---------------------------------------------------------------------------

Mayor Voting + Job Setting

---------------------------------------------------------------------------*/