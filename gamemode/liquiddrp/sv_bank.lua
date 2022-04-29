local LDRP = {}

function numberFormat(amount)
	local formatted = amount

	while true do

		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')

		if (k == 0) then

			break

		end

	end

	return formatted
end

LDRP.AccountUpgradeOptionValues = {
	["Basic"] = {
		["min"] = 50000,
		["rate"] = 0.015
	},
	["Bronze"] = {
		["min"] = 500000,
		["rate"] = 0.02
	},
	["Silver"] = {
		["min"] = 1000000,
		["rate"] = 0.035
	},
	["Gold"] = {
		["min"] = 5000000,
		["rate"] = 0.045
	},
	["Platinum"] = {
		["min"] = 10000000,
		["rate"] = 0.05
	},
	["Diamond"] = {
		["min"] = 50000000,
		["rate"] = 0.06
	},
	["Nuclear"] =  {
		["min"] = 100000000,
		["rate"] = 0.065
	}
}

function LDRP.GetPaycheck(ply,cmd,args)
	if !LDRP_SH.UsePaycheckLady then ply:ChatPrint("Paycheck lady is not used but in the map.") return end
	
	if LDRP_SH.ShopPoses["Paycheck Lady"] and ply:GetPos():Distance(LDRP_SH.ShopPoses["Paycheck Lady"]) < 300 then
		if ply.CurCheck and ply.CurCheck > 0 then
			ply:LiquidChat("PAYCHECK", Color(0,192,10), "Earned a paycheck of $" .. ply.CurCheck)
			ply:AddMoney(ply.CurCheck)
			ply.CurCheck = nil
		else
			ply:LiquidChat("PAYCHECK", Color(0,192,10), "Your paycheck is not available!")
		end
	end
end
concommand.Add("_pcg",LDRP.GetPaycheck)

function LDRP.BankCMD(ply,cmd,args)
	if LDRP_SH.ShopPoses["Bank"] and ply:GetPos():Distance(LDRP_SH.ShopPoses["Bank"]) > 300 then return end
	local Type = args[1]
	local Item = args[2]


	if !Type or !Item or (Type != "money" and !LDRP_SH.AllItems[Item]) or Item == "curcash" then return end
	
	if Type == "bank" then
		if ply:HasItem(Item) and ply:CanBCarry(Item) then
			ply:AddItem(Item,-1)
			ply:AddBItem(Item,1)
			ply:LiquidChat("BANK", Color(0,192,10), "Banked one " .. (LDRP_SH.NicerWepNames[Item] or LDRP_SH.AllItems[Item].nicename or Item))
		else
			ply:LiquidChat("BANK", Color(0,192,10), "You need to free inventory space up before banking this.")
		end
	elseif Type == "takeout" then
		if ply:HasBItem(Item) and ply:CanCarry(Item) then
			ply:AddItem(Item,1)
			ply:AddBItem(Item,-1)
			local Name = (LDRP_SH.AllItems[Item].nicename or Item)
			ply:LiquidChat("BANK", Color(0,192,10), "Took out one " .. (LDRP_SH.NicerWepNames[Name] or Name))
		else
			ply:LiquidChat("BANK", Color(0,192,10), "You need to free inventory space up before taking this out.")
		end
	elseif Type == "money" then
		local Cash = tonumber(Item)
		if !Cash then ply:LiquidChat("BANK", Color(0,192,10), "Specify a number to deposit or withdraw.") return end
		
		if Cash < 0 then
			local Am = math.abs(Cash)
			if ply:CanAfford(Am) then
				ply:LiquidChat("BANK", Color(0,192,10), "Deposited $" .. Am .. " into your bank.")
				ply:AddMoney(Cash)
				ply:AddBMoney(Am)
			else
				ply:LiquidChat("BANK", Color(0,192,10), "You don't have enough in your wallet.")
			end
		elseif Cash > 0 then
			local Chk = ply:HasBItem("curcash")
			if Chk and Chk >= Cash then
				ply:LiquidChat("BANK", Color(0,192,10), "Withdrew $" .. Cash .. " from your bank.")
				ply:AddMoney(Cash)
				ply:AddBMoney(-Cash)
			else
				ply:LiquidChat("BANK", Color(0,192,10), "You don't have enough in your bank.")
			end
		else
			ply:LiquidChat("BANK", Color(0,192,10), "Input an amount!")
		end
	end
end
concommand.Add("_bnk",LDRP.BankCMD)

function LDRP.BankUpgrade(ply, cmd, args)

  local upgradeType = args[1]
  local newLevel = args[2]

  local playerBalance = ply:GetBMoney()

  if upgradeType == "balanceChanged" then

    local rateType = ply:GetInterestRateType()
    
    if playerBalance < LDRP.AccountUpgradeOptionValues[rateType]["min"] then
    
      local newSelectedType
      local newInterestRate

      for k, v in pairs(LDRP.AccountUpgradeOptionValues) do

        if playerBalance > v["min"] then

          newSelectedType = k

          newInterestRate = v["rate"]

        end
        
      end

      print(newSelectedType)

      if !newSelectedType || !newInterestRate then

        ply:SetInterestRate("None", 0)

        ply:LiquidChat("BANK", Color(0,192,10), "Account Upgrade Status has been removed!" )

        return

      end

      ply:SetInterestRate(newSelectedType, newInterestRate)

      ply:LiquidChat("BANK", Color(0,192,10), "Account down-graded! $" .. numberFormat(playerBalance*newInterestRate) .. " per day" )

    end

    return
  end
  
  if newLevel == "Upgrade Account" then ply:LiquidChat("BANK", Color(0,192,10), "Select a option to upgrade!") return end

  local selectedOptionName = newLevel:gsub("[^A-za-z]", "")

  local selectedOption = LDRP.AccountUpgradeOptionValues[selectedOptionName]

  if playerBalance >= selectedOption["min"] then
    ply:LiquidChat("BANK", Color(0,192,10), "Account upgraded! $" .. numberFormat(math.Round(playerBalance*selectedOption["rate"])) .. " per day" )

		ply:SetInterestRate(selectedOptionName, selectedOption["rate"])
  end

end

concommand.Add("_bnkupgrade", LDRP.BankUpgrade)

function LDRP.CollectInterest(ply, cmd, args)

  -- Compare the time last collected, to the time the player is attempting to collect.

  local nextTimeAloudToCollect = ply:GetTimeLastCollectedInterest() + LDRP_SH.InterestCollectionDelay

  if os.time() > nextTimeAloudToCollect then

    local upgradeType = ply:GetInterestRateType()
    
    local validInterestRate = LDRP.AccountUpgradeOptionValues[upgradeType]["rate"]

    local amountToCollect = ply:GetBMoney() *  validInterestRate

    ply:AddBMoney(amountToCollect)

    ply:LiquidChat( "BANK", Color(0,192,10), "You collected your interest of $" .. numberFormat(math.Round(amountToCollect)) )

    ply:SetTimeLastCollectedInterest(os.time())

  else

    ply:LiquidChat( "BANK", Color(0,192,10), "You can collect your interest again tommrow" )

  end



end

concommand.Add("_collectInterest", LDRP.CollectInterest)