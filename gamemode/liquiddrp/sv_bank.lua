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
		["rate"] = 5
	},
	["Bronze"] = {
		["min"] = 500000,
		["rate"] = 0.35
	},
	["Silver"] = {
		["min"] = 1000000,
		["rate"] = 0.04
	},
	["Gold"] = {
		["min"] = 5000000,
		["rate"] = 0.05
	},
	["Platinum"] = {
		["min"] = 10000000,
		["rate"] = 0.065
	},
	["Diamond"] = {
		["min"] = 50000000,
		["rate"] = 0.07
	},
	["Nuclear"] =  {
		["min"] = 100000000,
		["rate"] = 0.075
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


	if !Type or !Item or (Type != "money" and Type != "upgrade" and !LDRP_SH.AllItems[Item]) or Item == "curcash" then return end
	
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

	elseif Type == "upgrade" then

		if Item == "Upgrade Account" then

			ply:LiquidChat("BANK", Color(0,192,10), "Select a option to upgrade!")

			return

		end

		local selectedOption

		selectedOption = LDRP.AccountUpgradeOptionValues[Item:gsub("[^A-za-z]", "")]

		local playerBalance = ply:GetBMoney()

		if playerBalance > selectedOption["min"] then
			ply:LiquidChat("BANK", Color(0,192,10), "Account upgraded! $" .. numberFormat(playerBalance*selectedOption["rate"]) .. " per day" )

			ply:SetIntrestRate(selectedOption["rate"])
		end

		
	end
end
concommand.Add("_bnk",LDRP.BankCMD)