local LDRP = {}
local function MC(num)
	return math.Clamp(num,1,255)
end

function LDRP.ColorMod(r,g,b,a)
	local Clrs = LDRP_Theme[LDRP_Theme.CurrentSkin].BGColor
	return Color(MC(Clrs.r+r),MC(Clrs.g+g),MC(Clrs.b+b),MC(Clrs.a+a))
end

function LDRP.ConfirmVender(Type,Item,Cost)
	local item = string.lower(Item)
	local ConfirmWindow = vgui.Create("DFrame")
	local w,h = ScrW(),ScrH()
	local ws,hs = 240,150
	ConfirmWindow:SetSize(ws,hs)
	ConfirmWindow:SetPos(-ws,h*.5-(hs*.5))
	ConfirmWindow:MoveTo(w*.5-(ws*.5),h*.5-(hs*.5),.2,.2)
	ConfirmWindow:MakePopup()
	ConfirmWindow:SetTitle("")
	ConfirmWindow:ShowCloseButton(false)
	
	local CantSell = (Type == "sell") and (!LocalPlayer().Inventory[item] or LocalPlayer().Inventory[item] < 1)
	local WindowSize = (CantSell and hs*.5) or hs
	ConfirmWindow.Paint = function()
		draw.RoundedBox(6,0,0,ws,WindowSize,LDRP.ColorMod(0,0,0,0))
		
		if Type == "buy" then
			draw.SimpleTextOutlined( "Are you sure you want to buy", "Trebuchet22", 4, hs*.2, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
			draw.SimpleTextOutlined( "a " .. Item .. " for $" .. Cost, "Trebuchet22", 4, hs*.35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
		elseif Type == "sell" then
			if CantSell then
				draw.SimpleTextOutlined( "You don't have any to sell.", "Trebuchet22", ws*.5, WindowSize*.5, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
				return
			end
			local am = LocalPlayer().Inventory[Item]
			draw.SimpleTextOutlined( "Are you sure you want to sell", "Trebuchet22", 4, hs*.2, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
			draw.SimpleTextOutlined( am .. " " .. Item .. " for $" .. Cost*am, "Trebuchet22", 4, hs*.35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
		end
		
	end
	
	if CantSell then
		ConfirmWindow:SetSize(ws,WindowSize)
		ConfirmWindow:ShowCloseButton(true)
		return
	end
	
	local YesButton = vgui.Create("DButton",ConfirmWindow)
	YesButton:SetPos(4,hs*.5)
	YesButton:SetSize(ws-8,hs*.22)
	YesButton:SetText("Yes")
	YesButton.DoClick = function()
		RunConsoleCommand("__shp",Type,item)
		ConfirmWindow:MoveTo(w,h*.5-(hs*.5),.2,.2)
		timer.Simple(.4,function()
			ConfirmWindow:Close()
		end)
	end

	local NoButton = vgui.Create("DButton",ConfirmWindow)
	NoButton:SetPos(4,hs*.74)
	NoButton:SetSize(ws-8,hs*.22)
	NoButton:SetText("No")
	NoButton.DoClick = function()
		ConfirmWindow:MoveTo(w,h*.5-(hs*.5),.2,.2)
		timer.Simple(.4,function()
			ConfirmWindow:Close()
		end)
	end
end

function LDRP_SH.OpenStoreMenu(name,model,saying,selltable,buytable)
	local Store = {}
	local w,h = 600,600
	
	Store.BG = vgui.Create("DFrame")
	Store.BG:SetSize(600,600)
	Store.BG:Center()
	Store.BG:MakePopup()
	Store.BG:SetTitle("")
	Store.BG.Paint = function()
		draw.RoundedBox(8,0,0,w,h,LDRP.ColorMod(20,20,20,10))
		draw.RoundedBox(6,2,36,w-4,h-528,LDRP.ColorMod(30,30,30,30))
		draw.SimpleTextOutlined( name,"HUDNumber", w*.5, h*.03, Color(170,170,170,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
		draw.SimpleTextOutlined( saying,"Trebuchet24", w*.5+38, h-528, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
		
		draw.RoundedBox(6,2,h*.184,w-4,h-114,LDRP.ColorMod(30,30,30,30))
		
		draw.SimpleTextOutlined( "Selling","HUDNumber", w*.01, h*.23, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
		
		draw.SimpleTextOutlined( "Buying","HUDNumber", w*.01, h*.62, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
		
	end
	
	Store.NPCPic = vgui.Create("SpawnIcon",Store.BG)
	Store.NPCPic:SetPos(6,40)
	Store.NPCPic:SetModel(model)
	
	Store.SellingList = vgui.Create("DPanelList",Store.BG)
	Store.SellingList:SetPos(6,h*.285)
	Store.SellingList:SetSize(w-12,h*.29)
	Store.SellingList:SetSpacing(4)
	Store.SellingList:SetPadding(4)
	Store.SellingList:EnableHorizontal(true)
	Store.SellingList:EnableVerticalScrollbar(true)
	
	
	Store.BuyingList = vgui.Create("DPanelList",Store.BG)
	Store.BuyingList:SetPos(6,h*.67)
	Store.BuyingList:SetSize(w-12,h*.31)
	Store.BuyingList:SetSpacing(4)
	Store.BuyingList:SetPadding(4)
	Store.BuyingList:EnableHorizontal(true)
	Store.BuyingList:EnableVerticalScrollbar(true)
	
	for k,v in pairs(selltable) do
		local Lower = string.lower(k)
		local ItemIcon = CreateIcon(nil,LDRP_SH.AllItems[Lower].mdl,76,76,function() LDRP.ConfirmVender("buy",Lower,v) end)
		ItemIcon:SetToolTip(k .. "\nSell Price: $" .. v)
		Store.SellingList:AddItem(ItemIcon)
	end
	
	for k,v in pairs(buytable) do
		local Lower = string.lower(k)
		local ItemIcon = CreateIcon(nil,LDRP_SH.AllItems[Lower].mdl,76,76,function() LDRP.ConfirmVender("sell",string.lower(Lower),v) end)
		ItemIcon:SetToolTip(k .. "\nBuy Price: $" .. v)
		Store.BuyingList:AddItem(ItemIcon)
	end
end

function LDRP.RulesMenu()
	local Loading = true
	
	local Window = vgui.Create("DFrame")
	local w,h = ScrW()*.8,ScrH()*.8
	Window:SetSize(w,h)
	Window:SetPos(ScrW()*.1,ScrH()*.1)
	Window.Paint = function()
		draw.RoundedBox( 8, 0, 0, w, h, LDRP.ColorMod(-40,-40,-40,60) )
		if Loading then
			draw.SimpleTextOutlined("Loading Webpage", "HUDNumber", w*.5, h*.5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0) )
		end
	end
	Window:SetTitle("Rules")
	Window:MakePopup()
	
	local HTML = vgui.Create("HTML",Window)
	HTML:SetPos(6,22)
	HTML:SetSize(w-8,h-30)
	HTML:OpenURL("http://www.LiquidGaming.org/helprulesdrp.html")
	HTML.FinishedURL = function()
		Loading = false
	end
	HTML.OpeningURL = function()
		Loading = true
	end
	
	return ""
end
concommand.Add("rules",LDRP.RulesMenu)

-- Bank bullshit
function LDRP.SendItemInfo(um)
	LocalPlayer().Bank[tostring(um:ReadString())] = um:ReadFloat()
end
usermessage.Hook("SendBItem",LDRP.SendItemInfo)

function LDRP.SendMaxWeight(um)
	LocalPlayer().MaxBWeight = um:ReadFloat()
end
usermessage.Hook("SendBWeight",LDRP.SendMaxWeight)

function LDRP.OpenItemOptions(item,Type,nicename)
	local TypeTbl = (Type == "bank" and LocalPlayer().Inventory) or LocalPlayer().Bank
	if TypeTbl[item] then
		local WepNames = LDRP_SH.NicerWepNames
		local OptionsMenu = vgui.Create("DFrame")
		OptionsMenu:SetSize(200, 70)
		OptionsMenu:SetPos(-200, ScrH()*.5-80)
		OptionsMenu:MakePopup()
		OptionsMenu:MoveTo(ScrW()*.5-100,ScrH()*.5-80,.3)
		local Tbl = LDRP_SH.AllItems[item]
		
		OptionsMenu.Paint = function()
			draw.RoundedBox(6,0,0,200,70,Color(50,50,50,180))
			local name = WepNames[Tbl.nicename] or Tbl.nicename
			draw.SimpleTextOutlined(name .. " - " .. TypeTbl[item] .. " left","Trebuchet20",100,14,Color(255,255,255,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
		end
		OptionsMenu:SetTitle("")
		OptionsMenu.MakeClose = function()
			OptionsMenu:MoveTo(ScrW(),ScrH()*.5-80,.3)
			timer.Simple(.3,function()
				if OptionsMenu:IsValid() then OptionsMenu:Close() end
			end)
		end
		
		local UseButton = vgui.Create("DButton",OptionsMenu)
		UseButton:SetPos(4,30)
		UseButton:SetSize(192,32)
		UseButton:SetText(nicename)
		UseButton.DoClick = function()
			RunConsoleCommand("_bnk",Type,item)
			OptionsMenu.MakeClose()
		end
		
	end
end

local WepNames = LDRP_SH.NicerWepNames
function LDRP.BankMenu(ply,cmd,args)
	local MainBankBackground = vgui.Create("DFrame")
	local w,l = 600,630
	MainBankBackground:SetWidth(w)
	MainBankBackground:SetHeight(l)
	MainBankBackground:MakePopup()
	MainBankBackground:Center()
	MainBankBackground:SetTitle("")
	MainBankBackground:ShowCloseButton(false)
	function MainBankBackground:Paint()
		draw.RoundedBox(6,0,0,w,l,LDRP.ColorMod(0,0,0,0))
		
		local BankWeight = 0
		for k,v in pairs(LocalPlayer().Bank) do
			if k == "curcash" then continue end
			if v and v >= 1 then
				BankWeight = BankWeight+(LDRP_SH.AllItems[k].weight*v)
			end
		end
	
		draw.SimpleTextOutlined("Bank Weight: " .. BankWeight .. " out of " .. LocalPlayer().MaxBWeight,"Trebuchet22",w*.5,l*.97,Color(255,255,255,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
	end
	
	local BankLabel = vgui.Create("DLabel",MainBankBackground)
	BankLabel:SetText("Bank")
	BankLabel:SetFont("HUDNumber")
	BankLabel:SetColor(Color(255,255,255,255))
	BankLabel:SetPos(MainBankBackground:GetWide()*.45,-4)
	BankLabel:SizeToContents()
	
	local BankItemsList = vgui.Create("DPanelList",MainBankBackground)
	BankItemsList:SetPos(6,30)
	BankItemsList:SetWidth(588)
	BankItemsList:SetHeight(200)
	BankItemsList:SetPadding(4)
	BankItemsList:SetSpacing(4)

	BankItemsList:EnableVerticalScrollbar(true)
	BankItemsList:EnableHorizontal(true)
	
	local CurIcons = {}
	
	function BankItemsList:Think()
		for k,v in pairs(LocalPlayer().Bank) do
			if k == "curcash" then continue end
			
			local Check = CurIcons[k]
			if Check then
				if Check.am != v or v <= 0 then
					local ItemTbl = LDRP_SH.AllItems[k]
					if !ItemTbl then continue end
					if v <= 0 then
						BankItemsList:RemoveItem(Check.vgui)
						CurIcons[k] = nil
					else
						local Namez = WepNames[ItemTbl.nicename] or ItemTbl.nicename
						Check.vgui:SetToolTip(Namez .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight)
						CurIcons[k].am = v
					end
				end
			elseif v > 0 then
				local ItemTbl = LDRP_SH.AllItems[k]
				if !ItemTbl then continue end
				local ItemIcon = CreateIcon(BankItemsList,ItemTbl.mdl,79,79,function() LDRP.OpenItemOptions(k,"takeout","Take Out") end)
				CurIcons[k] = {["vgui"] = ItemIcon,["am"] = v}
				local Namez = WepNames[ItemTbl.nicename] or ItemTbl.nicename
				ItemIcon:SetToolTip(Namez .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight)
				
				BankItemsList:AddItem(ItemIcon)
			end
			timer.Simple(.001,function()
				if !BankItemsList:IsValid() then return end
				BankItemsList:Rebuild()
				BankItemsList:PerformLayout()
			end)
		end
	end
	
	local InvLabel = vgui.Create("DLabel",MainBankBackground)
	InvLabel:SetText("Inventory")
	InvLabel:SetFont("HUDNumber")
	InvLabel:SetColor(Color(255,255,255,255))
	InvLabel:SetPos(MainBankBackground:GetWide()*.39,224)
	InvLabel:SizeToContents()
	
	local InvItemsList = vgui.Create("DPanelList",MainBankBackground)
	InvItemsList:SetPos(6,262)
	InvItemsList:SetWidth(588)
	InvItemsList:SetHeight(200)
	InvItemsList:SetPadding(4)
	InvItemsList:SetSpacing(4)
	InvItemsList:EnableVerticalScrollbar(true)
	InvItemsList:EnableHorizontal(true)
	
	local CurIcons2 = {}
	
	function InvItemsList:Think()
		for k,v in pairs(LocalPlayer().Inventory) do
			local Check = CurIcons2[k]
			if Check then
				if Check.am != v or v <= 0 then
					local ItemTbl = LDRP_SH.AllItems[k]
					if !ItemTbl then continue end
					if v <= 0 then
						InvItemsList:RemoveItem(Check.vgui)
						CurIcons2[k] = nil
					else
						local Namez = WepNames[ItemTbl.nicename] or ItemTbl.nicename
						Check.vgui:SetToolTip(Namez .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight)
						CurIcons2[k].am = v
					end
				end
			elseif v > 0 then
				local ItemTbl = LDRP_SH.AllItems[k]
				if !ItemTbl then continue end
				local ItemIcon = CreateIcon(InvItemsList,ItemTbl.mdl,79,79,function() LDRP.OpenItemOptions(k,"bank","Put in bank") end)
				CurIcons2[k] = {["vgui"] = ItemIcon,["am"] = v}
				local Namez = WepNames[ItemTbl.nicename] or ItemTbl.nicename
				ItemIcon:SetToolTip(Namez .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight)
				
				InvItemsList:AddItem(ItemIcon)
			end
			timer.Simple(.001,function()
				if !InvItemsList:IsValid() then return end
				InvItemsList:Rebuild()
				InvItemsList:PerformLayout()
			end)
		end
	end
	
	local ButtonBackground = vgui.Create("DPanel",MainBankBackground)
	ButtonBackground:SetPos(0,514)
	ButtonBackground:SetWidth(600)
	ButtonBackground:SetHeight(86)
	function ButtonBackground:Paint()
		draw.RoundedBox(6,0,0,self:GetWide(),self:GetTall(),LDRP.ColorMod(30,30,30,40))
	end
	
	function MainBankBackground:NewButton(name,x,y,w,h,click)
		local CloseButton = vgui.Create("DButton",self)
		CloseButton:SetPos(x,y)
		CloseButton:SetWidth(w)
		CloseButton:SetHeight(h)
		CloseButton:SetText(name)
		CloseButton.DoClick = click
	end
	
	local MoneyLabel = vgui.Create("DLabel",MainBankBackground)
	MoneyLabel:SetPos(8,470)
	MoneyLabel:SetText("                                   ")
	MoneyLabel:SetFont("HUDNumber")
	function MoneyLabel:Paint()
		draw.SimpleTextOutlined("Balance: $" .. LocalPlayer().Bank["curcash"], "HUDNumber", 0, ScrH()*.02, Color(0,255,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0,0,0) )
	end
	MoneyLabel:SizeToContents()
	
	local InputCash = vgui.Create("DTextEntry",MainBankBackground)
	InputCash:SetPos(280,470)
	InputCash:SetWidth(314)
	InputCash:SetHeight(35)
	InputCash:SetEnterAllowed(false)
	InputCash:SetText("Input money amount here")
	local HasClicked
	InputCash.OnMousePressed = function()
		if !HasClicked then InputCash:SetText("") HasClicked = true end
	end

	function InputCash:Paint()
		draw.RoundedBox(6,0,0,self:GetWide(),self:GetTall(),LDRP.ColorMod(70,70,70,20))
		self:DrawTextEntryText(Color(255, 255, 255), Color(0, 255, 0), Color(255, 255, 255))
	end
	
	MainBankBackground:NewButton("Deposit Money",4,522,592,20,function() local am = tonumber(InputCash:GetValue()) if am and am > 0 then RunConsoleCommand("_bnk","money",-am) else LocalPlayer():ChatPrint("Please enter a valid number.") end end)
	MainBankBackground:NewButton("Withdraw Money",4,548,592,20,function() local am = tonumber(InputCash:GetValue()) if am and am > 0 then RunConsoleCommand("_bnk","money",am) else LocalPlayer():ChatPrint("Please enter a valid number.") end  end)
	MainBankBackground:NewButton("Close Bank",4,574,592,20,function() MainBankBackground:Close() end)
	
end
usermessage.Hook("SendBankMenu",LDRP.BankMenu)
