local LDRP = {}
local matBlurScreen = Material( "pp/blurscreen" )
local blur

local Opened
function LDRP.OpenItemOptions(item,Type,nicename)
	local TypeTbl = (Type == "addtrade" and LocalPlayer().Inventory) or LocalPlayer().Trading
	if TypeTbl then
		local WepNames = LDRP_SH.NicerWepNames
		local OptionsMenu = vgui.Create("DFrame")
		if Opened and Opened:IsValid() then Opened:Close() end
		Opened = OptionsMenu
		OptionsMenu:SetSize(200, 102)
		OptionsMenu:SetPos(-200, ScrH()*.5-80)
		OptionsMenu:MakePopup()
		OptionsMenu:MoveTo(ScrW()*.5-100,ScrH()*.5-80,.3)
		local Tbl = LDRP_SH.AllItems[item]
		
		OptionsMenu.Paint = function()
			draw.RoundedBox(6,0,0,200,102,Color(50,50,50,180))
			draw.SimpleTextOutlined((Type == "cash" and ("$" .. LocalPlayer().DarkRPVars.money)) or ((WepNames[Tbl.nicename] or Tbl.nicename) .. " - " .. TypeTbl[item] .. " left"),"Trebuchet20",100,14,Color(255,255,255,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
		end
		OptionsMenu:SetTitle("")
		OptionsMenu.MakeClose = function()
			OptionsMenu:MoveTo(ScrW(),ScrH()*.5-80,.3)
			timer.Simple(.3,function()
				if OptionsMenu:IsValid() then OptionsMenu:Close() end
			end)
		end
		
		local Counter = vgui.Create("DNumSlider",OptionsMenu)
		Counter:SetPos(4,32)
		Counter:SetWidth(192)
		Counter:SizeToContents()
		Counter:SetText("Trade how " .. ((Type == "cash" and "much cash?") or "many?"))
		Counter:SetMax((Type == "cash" and LocalPlayer().DarkRPVars.money) or LocalPlayer().Inventory[item])
		Counter:SetMin(0)
		Counter:SetDecimals(0)
		local UseButton = vgui.Create("DButton",OptionsMenu)
		UseButton:SetPos(4,76)
		UseButton:SetSize(192,20)
		UseButton:SetText("Confirm")
		UseButton.DoClick = function()
			if Type == "cash" then
				RunConsoleCommand("__trd","money",tonumber(Counter:GetValue()))
			else
				RunConsoleCommand("__trd","item",item,tonumber(Counter:GetValue()))
			end
			OptionsMenu.MakeClose()
		end
		
	end
end

local function MC(num)
	return math.Clamp(num,1,255)
end

function LDRP.ColorMod(r,g,b,a)
	local Clrs = LDRP_Theme[LDRP_Theme.CurrentSkin].TradeMenu
	local newColor = Color( MC(Clrs.r+r), MC(Clrs.g+g), MC(Clrs.b+b), MC(Clrs.a+a) )
	return newColor
end

function LDRP.TradingMenu(tradingwith)
	local WepNames = LDRP_SH.NicerWepNames
	local TM = {}
	LocalPlayer().Trading = {}
	LocalPlayer().BeingTraded = {}
	
	TM.Window = vgui.Create("DFrame")
	TradeMenu = TM.Window
	TM.Window:SetSize(700,580)
	TM.Window:Center()
	TM.Window:MakePopup()
	TM.Window:SetTitle("")
	TM.Window:ShowCloseButton(false)
	TM.Window.Think = function()
		if !tradingwith or !tradingwith:IsValid() then TM.Window:Close() end
	end
	local PNT =	LDRP_Theme[LDRP_Theme.CurrentSkin].TradeMenu
	TM.Window.Paint = function()
		
		surface.SetDrawColor( PNT.r,PNT.g,PNT.b,PNT.a )
		surface.DrawOutlinedRect( 0, 0, TM.Window:GetWide(), TM.Window:GetTall() )
		
		surface.SetDrawColor( 110, 110, 110, 255 )
		surface.DrawLine( 2, 2, TM.Window:GetWide() - 2, 2 )
		
		surface.SetMaterial( matBlurScreen )
		surface.SetDrawColor( 255, 255, 255, 255 )
		
		matBlurScreen:SetFloat( "$blur", 5 )
		render.UpdateScreenEffectTexture()
		
		surface.SetDrawColor( LDRP.ColorMod( 25, 25, 25, -145 ) ) --Drawing background of main GUI
		surface.DrawRect( 2, 2, TM.Window:GetWide() - 4, TM.Window:GetTall() - 4 )
		draw.SimpleTextOutlined( "Trading with " .. tradingwith:GetName(), "Trebuchet22", 14, 26, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0,0,0,255) )

	end
	
	TM.Inventory = vgui.Create("DPanelList",TM.Window)
	TM.Inventory:SetPos(18,32)
	TM.Inventory:SetSize(TM.Window:GetWide()*.5-24,300)
	TM.Inventory.Paint = function()
		draw.RoundedBox(6,0,0,TM.Inventory:GetWide(),TM.Inventory:GetTall(),LDRP.ColorMod(-30,-30,-30,-40))
	end
	TM.Inventory:SetPadding(4)
	TM.Inventory:EnableHorizontal(true)
	TM.Inventory:SetSpacing(4)
	local CurIcons = {}
	
	local MoneyIcon = CreateIcon(TM.Inventory,"models/props/cs_assault/money.mdl",76,76,function() LDRP.OpenItemOptions("cash","cash") end)
	MoneyIcon:SetToolTip("Your money (click for menu) $" .. LocalPlayer().DarkRPVars.money)
	TM.Inventory:AddItem(MoneyIcon)
	
	function TM.Inventory:Think() -- This is probably a horrible way to do this, but look at half of the DarkRP code and see how much shittier that is instead of complaining about my code
		for k,v in pairs(LocalPlayer().Inventory) do
			local Check = CurIcons[k]
			if Check then
				if Check.am != v or v <= 0 then
					local ItemTbl = LDRP_SH.AllItems[k]
					if !ItemTbl then continue end
					if v <= 0 then
						TM.Inventory:RemoveItem(Check.vgui)
						CurIcons[k] = nil
					else
						Check.vgui:SetToolTip(ItemTbl.nicename .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight)
						CurIcons[k].am = v
					end
				end
			elseif v > 0 then
				local ItemTbl = LDRP_SH.AllItems[k]
				if !ItemTbl then continue end
				local ItemIcon = CreateIcon(TM.Inventory,ItemTbl.mdl,76,76,function() LDRP.OpenItemOptions(k,"addtrade") end)
				CurIcons[k] = {["vgui"] = ItemIcon,["am"] = v}
				local Namez = WepNames[ItemTbl.nicename] or ItemTbl.nicename
				ItemIcon:SetToolTip(Namez .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight)
		
				TM.Inventory:AddItem(ItemIcon)
			end
			timer.Simple(.00001,function()
				if TM.Inventory:IsValid() then TM.Inventory:Rebuild() end
			end)
		end
	end
	

	TM.ChatBox = vgui.Create("DPanelList",TM.Window)
	TM.ChatBox:SetPos(18,TM.Inventory:GetTall()+44)
	TM.ChatBox:SetSize(TM.Window:GetWide()*.5-24,112)
	TM.ChatBox.Paint = function()
		draw.RoundedBox(6,0,0,TM.ChatBox:GetWide(),TM.ChatBox:GetTall(),LDRP.ColorMod(-30,-30,-30,-40))
	end
	TM.ChatBox:SetPadding(6)
	TM.ChatBox:SetSpacing(0)
	TM.ChatBox:EnableVerticalScrollbar(true)
	ChatBox = TM.ChatBox
	function TM.ChatBox:AddChat(text,color,ByTrader)
		local ChatTxt = vgui.Create("DLabel")
		local Txt = (ByTrader and (tradingwith:GetName() .. ": " .. text)) or text
		ChatTxt:SetText(Txt)
		ChatTxt:SetFont("ChatFont")
		ChatTxt:SetColor(color or Color(255,255,255))
		TM.ChatBox:AddItem(ChatTxt)
		chat.PlaySound()
		timer.Simple(.001,function()
			TM.ChatBox.VBar:AddScroll(TM.ChatBox.VBar.BarSize)
		end)
	end
	TM.ChatBox:AddChat("Chat to the player you're trading here.", LDRP.ColorMod( 75, 75, 75, 255 ) )
	
	
	TM.MyTrade = vgui.Create("DPanelList",TM.Window)
	TM.MyTrade:SetPos(TM.Window:GetWide()*.5+12,32)
	TM.MyTrade:SetSize(TM.Window:GetWide()*.5-24,TM.Window:GetTall()*.5-50)
	TM.MyTrade.Paint = function( self, w, h )
		draw.RoundedBox(6,0,0, w, h, LDRP.ColorMod(-30,-30,-30,-40))
		draw.SimpleTextOutlined( "Your Trading", "Trebuchet22", (w*.5), 0, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0,255) )
	end
	TM.MyTrade:SetPadding(4)
	TM.MyTrade:EnableHorizontal(true)
	TM.MyTrade:SetSpacing(4)
	
	local FreshCash
	local MoneyIconTrade

	local CurIcons2 = {}
	function TM.MyTrade:Think()
		local Chk = (!MoneyIconTrade or !MoneyIconTrade:IsValid())
		if !FreshCash and LocalPlayer().Trading["cashh"] and LocalPlayer().Trading["cashh"] >= 1 then FreshCash = LocalPlayer().Trading["cashh"] end
		if FreshCash and LocalPlayer().Trading["cashh"] and FreshCash != LocalPlayer().Trading["cashh"] then
			FreshCash = LocalPlayer().Trading["cashh"]
			if !Chk then
				if FreshCash > 0 then
					MoneyIconTrade:SetToolTip(LocalPlayer():Name() .. " is trading $" .. FreshCash)
					TM.ChatBox:AddChat(LocalPlayer():Name() .. " is now trading $" .. FreshCash,Color(200,0,0,255))
				end
				TM.ConfirmTrade:SetDisabled(true)
				RunConsoleCommand("__trd","decline")
			end
		end
		
		if Chk and LocalPlayer().Trading["cashh"] and LocalPlayer().Trading["cashh"] >= 1 then
			MoneyIconTrade = CreateIcon(TM.MyTrade,"models/props/cs_assault/money.mdl",76,76,function() LDRP.OpenItemOptions("cash","cash") end)
			MoneyIconTrade:SetToolTip(LocalPlayer():Name() .. " is trading $" .. FreshCash)
			TM.ChatBox:AddChat(LocalPlayer():Name() .. " is now trading $" .. FreshCash,Color(200,0,0,255))
			TM.MyTrade:AddItem(MoneyIconTrade)
			TM.ConfirmTrade:SetDisabled(true)
			RunConsoleCommand("__trd","decline")
		elseif !Chk and (!LocalPlayer().Trading["cashh"] or LocalPlayer().Trading["cashh"] <= 0) then
			MoneyIconTrade:Remove()
			TM.ConfirmTrade:SetDisabled(true)
			RunConsoleCommand("__trd","decline")
			TM.ChatBox:AddChat(LocalPlayer():Name() .. " is now not trading any money.",Color(200,0,0,255))
		end
		
		for k,v in pairs(LocalPlayer().Trading) do
			if k == "cashh" then continue end
			local Check = CurIcons2[k]
			if Check then
				if Check.am != v or v <= 0 then
					local ItemTbl = LDRP_SH.AllItems[k]
					if !ItemTbl then continue end
					if v <= 0 then
						TM.ConfirmTrade:SetDisabled(true)
						RunConsoleCommand("__trd","decline")
						TM.ChatBox:AddChat(LocalPlayer():Name() .. " removed an item",Color(200,0,0,255))
						TM.MyTrade:RemoveItem(Check.vgui)
						CurIcons2[k] = nil
					else
						Check.vgui:SetToolTip(ItemTbl.nicename .. "\n" .. ItemTbl.descr .. "\nTrading amount: " .. v .. "\nTotal Weight: " .. (ItemTbl.weight*v))
						TM.ChatBox:AddChat(LocalPlayer():Name() .. " is now trading " .. v .. " " .. k,Color(200,0,0,255))
						CurIcons2[k].am = v
						TM.ConfirmTrade:SetDisabled(true)
						RunConsoleCommand("__trd","decline")
					end
				end
			elseif v > 0 then
				local ItemTbl = LDRP_SH.AllItems[k]
				if !ItemTbl then continue end
				local ItemIcon = CreateIcon(TM.MyTrade,ItemTbl.mdl,76,76,function() LDRP.OpenItemOptions(k,"removetrade") end)
				CurIcons2[k] = {["vgui"] = ItemIcon,["am"] = v}
				local Namez = WepNames[ItemTbl.nicename] or ItemTbl.nicename
				ItemIcon:SetToolTip(Namez .. "\n" .. ItemTbl.descr .. "\nTrading amount: " .. v .. "\nTotal Weight: " .. (ItemTbl.weight*v))
				TM.ChatBox:AddChat(LocalPlayer():Name() .. " is now trading " .. v .. " " .. k,Color(200,0,0,255))
				TM.ConfirmTrade:SetDisabled(true)
				RunConsoleCommand("__trd","decline")
				TM.MyTrade:AddItem(ItemIcon)
			end
			timer.Simple(.00001,function()
				if TM.MyTrade:IsValid() then TM.MyTrade:Rebuild() end
			end)
		end
	end
	
	TM.TheirTrade = vgui.Create("DPanelList",TM.Window)
	TM.TheirTrade:SetPos(TM.Window:GetWide()*.5+12,TM.MyTrade:GetTall()+74)
	TM.TheirTrade:SetSize(TM.MyTrade:GetWide(),TM.MyTrade:GetTall())
	TM.TheirTrade.Paint = function( self, w, h )
		draw.RoundedBox(6,0,0, w, h, LDRP.ColorMod( -10, -10, -10, -105 ))
		draw.SimpleTextOutlined( tradingwith:GetName() .. "'s Trading", "Trebuchet22", w*.5, 0, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0,255) )
	end
	TM.TheirTrade:SetPadding(4)
	TM.TheirTrade:EnableHorizontal(true)
	TM.TheirTrade:SetSpacing(4)

	local CurIcons3 = {}
	local FreshCash2
	local MoneyIconTheir
	function TM.TheirTrade:Think()
	
		local Chk = (!MoneyIconTheir or !MoneyIconTheir:IsValid())
		
		if !FreshCash2 and LocalPlayer().BeingTraded["cashh"] and LocalPlayer().BeingTraded["cashh"] >= 1 then FreshCash2 = LocalPlayer().BeingTraded["cashh"] end
		if FreshCash2 and FreshCash2 != LocalPlayer().BeingTraded["cashh"] then
			FreshCash2 = LocalPlayer().BeingTraded["cashh"]
			if !Chk then
				if FreshCash2 > 0 then
					MoneyIconTheir:SetToolTip(tradingwith:GetName() .. " is trading $" .. FreshCash2)
					TM.ChatBox:AddChat(tradingwith:Name() .. " is now trading $" .. FreshCash2,Color(200,0,0,255))
				end
				TM.ConfirmTrade:SetDisabled(true)
				RunConsoleCommand("__trd","decline")
			end
		end
		
		if Chk and FreshCash2 and FreshCash2 >= 1 then
			MoneyIconTheir = CreateIcon(TM.TheirTrade,"models/props/cs_assault/money.mdl",76,76,function() end)
			MoneyIconTheir:SetToolTip(tradingwith:GetName() .. " is trading $" .. FreshCash2)
			TM.ChatBox:AddChat(tradingwith:Name() .. " is now trading $" .. FreshCash2,Color(200,0,0,255))
			TM.TheirTrade:AddItem(MoneyIconTheir)
			TM.ConfirmTrade:SetDisabled(true)
			RunConsoleCommand("__trd","decline")
		elseif !Chk and (!FreshCash2 or FreshCash2 <= 0) then
			MoneyIconTheir:Remove()
			TM.ConfirmTrade:SetDisabled(true)
			RunConsoleCommand("__trd","decline")
			TM.ChatBox:AddChat(tradingwith:Name() .. " is now not trading money.",Color(200,0,0,255))
		end
		
		for k,v in pairs(LocalPlayer().BeingTraded) do
			if k == "cashh" then continue end
			local Check = CurIcons3[k]
			if Check then
				if Check.am != v or v <= 0 then
					local ItemTbl = LDRP_SH.AllItems[k]
					if !ItemTbl then continue end
					if v <= 0 then
						TM.ConfirmTrade:SetDisabled(true)
						RunConsoleCommand("__trd","decline")
						TM.TheirTrade:RemoveItem(Check.vgui)
						TM.ChatBox:AddChat(tradingwith:Name() .. " removed an item",Color(200,0,0,255))
						CurIcons3[k] = nil
					else
						TM.ConfirmTrade:SetDisabled(true)
						RunConsoleCommand("__trd","decline")
						Check.vgui:SetToolTip(ItemTbl.nicename .. "\n" .. ItemTbl.descr .. "\nTrading amount: " .. v .. "\nTotal Weight: " .. (ItemTbl.weight*v))
						TM.ChatBox:AddChat(tradingwith:Name() .. " is now trading " .. v .. " " .. k,Color(200,0,0,255))
						CurIcons3[k].am = v
					end
				end
			elseif v > 0 then
				TM.ConfirmTrade:SetDisabled(true)
				RunConsoleCommand("__trd","decline")
				local ItemTbl = LDRP_SH.AllItems[k]
				if !ItemTbl then continue end
				local ItemIcon = CreateIcon(TM.TheirTrade,ItemTbl.mdl,76,76,function() end)
				CurIcons3[k] = {["vgui"] = ItemIcon,["am"] = v}
				local Namez = WepNames[ItemTbl.nicename] or ItemTbl.nicename
				ItemIcon:SetToolTip(Namez .. "\n" .. ItemTbl.descr .. "\nTrading amount: " .. v .. "\nTotal Weight: " .. (ItemTbl.weight*v))
				TM.ChatBox:AddChat(tradingwith:Name() .. " is now trading " .. v .. " " .. k,Color(200,0,0,255))
				
				TM.TheirTrade:AddItem(ItemIcon)
			end
			timer.Simple(.00001,function()
				if TM.TheirTrade:IsValid() then TM.TheirTrade:Rebuild() end
			end)
		end
	end
	
	
	TM.ChatEntry = vgui.Create("DTextEntry",TM.Window)
	TM.ChatEntry:SetPos(22,TM.Inventory:GetTall()+160)
	TM.ChatEntry:SetSize(TM.ChatBox:GetWide()-8,20)
	function TM.ChatEntry:OnEnter()
		if TM.ChatEntry:GetValue() == "" then return end
		TM.ChatBox:AddChat(LocalPlayer():GetName() .. ": " .. TM.ChatEntry:GetValue())
		RunConsoleCommand("__trd","chat",TM.ChatEntry:GetValue())
		self:SetText("")
		self:RequestFocus()
		timer.Simple(0,function()
			TM.ChatBox.VBar:AddScroll(TM.ChatBox.VBar.BarSize)
		end)
	end
	
	TM.AcceptTrade = vgui.Create("DButton",TM.Window)
	TM.AcceptTrade:SetPos(18,TM.Inventory:GetTall()+185)
	TM.AcceptTrade:SetSize(TM.Inventory:GetWide(),20)
	TM.AcceptTrade:SetText("Accept Trade")
	TM.AcceptTrade.DoClick = function()
		TM.ConfirmTrade:SetDisabled(false)
	end
	
	TM.ConfirmTrade = vgui.Create("DButton",TM.Window)
	TM.ConfirmTrade:SetPos(18,TM.Inventory:GetTall()+209)
	TM.ConfirmTrade:SetSize(TM.Inventory:GetWide(),20)
	TM.ConfirmTrade:SetText("Confirm Trade")
	TM.ConfirmTrade:SetDisabled(true)
	TM.ConfirmTrade.DoClick = function()
		RunConsoleCommand("__trd","accept")
	end

	TM.CancelTrade = vgui.Create("DButton",TM.Window)
	TM.CancelTrade:SetPos(18,TM.Inventory:GetTall()+233)
	TM.CancelTrade:SetSize(TM.Inventory:GetWide(),20)
	TM.CancelTrade:SetText("Cancel Trade")
	TM.CancelTrade.DoClick = function()
		TM.Window:Close()
		TradeMenu = nil
		RunConsoleCommand("__trd","cancel")
	end
end

function LDRP.ReceiveChat(um)
	if ChatBox and ChatBox:IsValid() then
		local Txt = um:ReadString()
		local s = false
		if string.sub(Txt,1,3) == "PlY" then s = true Txt = string.sub(Txt,4,string.len(Txt)) end
		ChatBox:AddChat(Txt,(s and Color(0,200,0,200)) or Color(200,0,0),s)
	end
end
usermessage.Hook("SendTradeChat",LDRP.ReceiveChat)

function LDRP.ReceiveTrade(um)
	LDRP.TradingMenu(um:ReadEntity())
end
usermessage.Hook("SendTrade",LDRP.ReceiveTrade)

function LDRP.ReceiveTradeC(um)
	if TradeMenu then TradeMenu:Close() TradeMenu = nil end
end
usermessage.Hook("SendTradeCancel",LDRP.ReceiveTradeC)

function LDRP.ReceiveTradeItem(um)
	LocalPlayer().Trading[um:ReadString()] = um:ReadFloat()
end
usermessage.Hook("SendTradeItem",LDRP.ReceiveTradeItem)

function LDRP.ReceiveTradedItem(um)
	LocalPlayer().BeingTraded[um:ReadString()] = um:ReadFloat()
end
usermessage.Hook("SendTradedItem",LDRP.ReceiveTradedItem)
