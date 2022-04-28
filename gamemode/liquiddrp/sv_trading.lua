local LDRP = {}

function LDRP.TradingCMD(ply,cmd,args)
	if args[1] == "start" then
		ply.TradedWith = nil
		local Trade = ply:GetEyeTrace().Entity
		if Trade and Trade:IsValid() and Trade:IsPlayer() and Trade:GetPos():Distance(ply:GetPos()) < 200 then
			ply:LiquidChat("TRADING", Color(0,192,10), "Sent a trade request to " .. Trade:GetName())
			Trade:LiquidChat("TRADING", Color(0,192,10), ply:GetName() .. " has created a trade request. Type '/accept' in chat to accept.")
			
			ply.TradedWith = Trade
			Trade.TradeRequest = ply
		else
			ply:LiquidChat("TRADING", Color(0,192,10), "Get closer to a player to trade with them.")
		end
	elseif args[1] == "item" then
		if ply.Trading and ply.Trading:IsValid() then
			local num = args[3] and tonumber(args[3])
			if !num or num < 0 then return end
			if num == 0 then
				ply.TradeItems[args[2]] = 0
				umsg.Start("SendTradeItem",ply)
					umsg.String(args[2])
					umsg.Float(0)
				umsg.End()
				umsg.Start("SendTradedItem",ply.Trading)
					umsg.String(args[2])
					umsg.Float(0)
				umsg.End()
				return
			end
			
			if LDRP_SH.AllItems[args[2]] and ply:HasItem(args[2],num) then
				if !ply.Trading:CanCarry(args[2],num) then
					umsg.Start("SendTradeChat",ply)
						umsg.String(ply.Trading:GetName() .. " must free inventory space!")
					umsg.End()
					umsg.Start("SendTradeChat",ply.Trading)
						umsg.String("You need to free up inventory space!")
					umsg.End()
					return
				end
				
				ply.TradeItems[args[2]] = num
				umsg.Start("SendTradeItem",ply)
					umsg.String(args[2])
					umsg.Float(num)
				umsg.End()
				umsg.Start("SendTradedItem",ply.Trading)
					umsg.String(args[2])
					umsg.Float(num)
				umsg.End()
			else
				ply:LiquidChat("TRADING", Color(0,192,10), "You don't have enough of this item!")
			end
		end
	elseif args[1] == "money" then
		if ply.Trading and ply.Trading:IsValid() then
			local am = tonumber(args[2])
			
			if am >= 0 and ply:CanAfford(am) then
				ply.TradeItems["cashh"] = am
				umsg.Start("SendTradeItem",ply)
					umsg.String("cashh")
					umsg.Float(am)
				umsg.End()
				umsg.Start("SendTradedItem",ply.Trading)
					umsg.String("cashh")
					umsg.Float(am)
				umsg.End()
			else
				ply:LiquidChat("TRADING", Color(0,192,10), "Can't afford this amount for the trade!")
			end
		end
	elseif args[1] == "accept" then
		if ply.Trading and ply.Trading:IsValid() and !ply.Confirmed then
			ply.Confirmed = true
			if !ply.Trading.Confirmed then	
				umsg.Start("SendTradeChat",ply)
					umsg.String("Waiting for other player to accept...")
				umsg.End()
				umsg.Start("SendTradeChat",ply.Trading)
					umsg.String("Other player has accepted the trade.")
				umsg.End()
				return
			end
			for k,v in pairs(ply.TradeItems) do
				if v < 1 then continue end
				if k == "cashh" then if ply:CanAfford(v) then ply:AddMoney(-v) ply.Trading:AddMoney(v) end continue end
				if ply:HasItem(k,v) then ply:AddItem(k,-v) ply.Trading:AddItem(k,v) end
			end
			for k,v in pairs(ply.Trading.TradeItems) do
				if v < 1 then continue end
				if k == "cashh" then if ply.Trading:CanAfford(v) then ply.Trading:AddMoney(-v) ply:AddMoney(v) end continue end
				if ply.Trading:HasItem(k,v) then ply.Trading:AddItem(k,-v) ply:AddItem(k,v) end
			end
			ply:Freeze(false)
			ply.Trading:Freeze(false)
			ply.Trading:LiquidChat("TRADING", Color(0,192,10), "Trade confirmed, money and items now in inventory/wallet.")
			ply:LiquidChat("TRADING", Color(0,192,10), "Trade confirmed, money and items now in inventory/wallet.")
			umsg.Start("SendTradeCancel",ply.Trading)
			umsg.End()
			umsg.Start("SendTradeCancel",ply)
			umsg.End()
			ply.Confirmed = false
			ply.Trading.TradeItems = nil
			ply.TradeItems = nil
			ply.Trading.Confirmed = false
			ply.Trading.Trading = nil
			ply.Trading = nil
		end
	elseif args[1] == "decline" then
		if ply.Trading and ply.Trading:IsValid() and ply.Confirmed then
			ply.Confirmed = false
		end
	elseif args[1] == "cancel" then
		if ply.Trading and ply.Trading:IsValid() then
			ply:Freeze(false)
			ply.Trading:Freeze(false)
			ply.Trading:LiquidChat("TRADING", Color(0,192,10), "Trade canceled by " .. ply:GetName())
			ply:LiquidChat("TRADING", Color(0,192,10), "Trade canceled by " .. ply:GetName())
			umsg.Start("SendTradeCancel",ply.Trading)
			umsg.End()
			ply.Trading.TradeItems = nil
			ply.TradeItems = nil
			ply.Trading.Trading = nil
			ply.Trading = nil
			ply.Confirmed = false
		end
	elseif args[1] == "chat" then
		if ply.Trading and ply.Trading:IsValid() then
			local Chat = ""
			local HasWrapped
			for k,v in pairs(args) do
				if k == 1 then continue end
				Chat = (Chat == "" and v) or (Chat .. " " .. v)
			end
			umsg.Start("SendTradeChat",ply.Trading)
				umsg.String("PlY" .. Chat)
			umsg.End()
		end
	end
end
concommand.Add("__trd",LDRP.TradingCMD)

function LDRP.AcceptTradeRequest(ply,args)	
	if ply.TradeRequest and ply.TradeRequest:IsValid() and ply.TradeRequest.TradedWith == ply then
		ply.TradeItems = {}
		ply.Trading = ply.TradeRequest
		ply.Trading.Trading = ply
		ply.Trading.TradeItems = {}
		ply.TradeRequest = nil
		ply:Freeze()
		ply.Trading:Freeze()
		ply:LiquidChat("TRADING", Color(0,192,10), "Started a trade with " .. ply.Trading:GetName())
		ply.Trading:LiquidChat("TRADING", Color(0,192,10), "Started a trade with " .. ply:GetName())
		umsg.Start("SendTrade",ply)
			umsg.Entity(ply.Trading)
		umsg.End()
		umsg.Start("SendTrade",ply.Trading)
			umsg.Entity(ply)
		umsg.End()
	else
		ply.TradeRequest = nil
		ply:LiquidChat("TRADING", Color(0,192,10), "There are no trades to accept!")
	end
	
	return ""
end
AddChatCommand("/accept",LDRP.AcceptTradeRequest)

LDRP_SH.Testerz = LDRP.AcceptTradeRequest