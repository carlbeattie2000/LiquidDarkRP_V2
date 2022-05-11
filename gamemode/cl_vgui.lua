include("showteamtabs.lua")
include("menu_content_tabs.lua")

AddCSLuaFile("showteamtabs.lua")
AddCSLuaFile("menu_content_tabs.lua")

local VoteVGUI = {}
local QuestionVGUI = {}
local PanelNum = 0
local LetterWritePanel

local function MsgDoVote(msg)
	local _, chatY = chat.GetChatBoxPos()

	local question = msg:ReadString()
	local voteid = msg:ReadShort()
	local timeleft = msg:ReadFloat()

	if timeleft == 0 then
		timeleft = 100
	end
	local OldTime = CurTime()
	if not IsValid(LocalPlayer()) then return end -- Sent right before player initialisation

	LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)
	local panel = vgui.Create("DFrame")
	panel:SetPos(3 + PanelNum, chatY - 145)
	panel:SetTitle("Vote")
	panel:SetSize(140, 140)
	panel:SetSizable(false)
	panel.btnClose:SetVisible(false)
	panel:SetDraggable(false)
	
	function panel:Close()
		PanelNum = PanelNum - 140
		VoteVGUI[voteid .. "vote"] = nil

		local num = 0
		for k,v in SortedPairs(VoteVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 140
		end

		for k,v in SortedPairs(QuestionVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 300
		end
		self:Remove()
	end

	function panel:Think()
		self:SetTitle("Time: ".. tostring(math.Clamp(math.ceil(timeleft - (CurTime() - OldTime)), 0, 9999)))
		if timeleft - (CurTime() - OldTime) <= 0 then
			panel:Close()
		end
	end

	panel:SetKeyboardInputEnabled(false)
	panel:SetMouseInputEnabled(true)
	panel:SetVisible(true)

	for i = 22, string.len(question), 22 do
		if not string.find(string.sub(question, i - 20, i), "\n", 1, true) then
			question = string.sub(question, 1, i) .. "\n".. string.sub(question, i + 1, string.len(question))
		end
	end

	local label = vgui.Create("DLabel")
	label:SetParent(panel)
	label:SetPos(5, 25)
	label:SetText(question)
	label:SizeToContents()
	label:SetVisible(true)

	local nextHeight = label:GetTall() > 78 and label:GetTall() - 78 or 0 // make panel taller for divider and buttons
	panel:SetTall(panel:GetTall() + nextHeight)

	local divider = vgui.Create("Divider")
	divider:SetParent(panel)
	divider:SetPos(2, panel:GetTall() - 30)
	divider:SetSize(180, 2)
	divider:SetVisible(true)

	local ybutton = vgui.Create("Button")
	ybutton:SetParent(panel)
	ybutton:SetPos(25, panel:GetTall() - 25)
	ybutton:SetSize(40, 20)
	ybutton:SetCommand("!")
	ybutton:SetText("Yes")
	ybutton:SetVisible(true)
	ybutton.DoClick = function()
		LocalPlayer():ConCommand("vote " .. voteid .. " yea\n")
		panel:Close()
	end

	local nbutton = vgui.Create("Button")
	nbutton:SetParent(panel)
	nbutton:SetPos(70, panel:GetTall() - 25)
	nbutton:SetSize(40, 20)
	nbutton:SetCommand("!")
	nbutton:SetText("No")
	nbutton:SetVisible(true)
	nbutton.DoClick = function()
		LocalPlayer():ConCommand("vote " .. voteid .. " nay\n")
		panel:Close()
	end

	PanelNum = PanelNum + 140
	VoteVGUI[voteid .. "vote"] = panel
	panel:SetSkin("LiquidDRP2")
end
usermessage.Hook("DoVote", MsgDoVote)

local function KillVoteVGUI(msg)
	print("Killing vote.")
	local id = msg:ReadString()
	
	if VoteVGUI[id .. "vote"] and VoteVGUI[id .. "vote"]:IsValid() then
		VoteVGUI[id.."vote"]:Close()

	end
end
usermessage.Hook("KillVoteVGUI", KillVoteVGUI)

local function MsgDoQuestion(msg)
	local question = msg:ReadString()
	local quesid = msg:ReadString()
	local timeleft = msg:ReadFloat()
	if timeleft == 0 then
		timeleft = 100
	end
	local OldTime = CurTime()
	LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)
	local panel = vgui.Create("DFrame")
	panel:SetPos(3 + PanelNum, ScrH() / 2 - 50)--Times 140 because if the quesion is the second screen, the first screen is always a vote screen.
	panel:SetSize(300, 140)
	panel:SetSizable(false)
	panel.btnClose:SetVisible(false)
	panel:SetKeyboardInputEnabled(false)
	panel:SetMouseInputEnabled(true)
	panel:SetVisible(true)
	
	function panel:Close()
		PanelNum = PanelNum - 300
		QuestionVGUI[quesid .. "ques"] = nil
		local num = 0
		for k,v in SortedPairs(VoteVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 140
		end
		
		for k,v in SortedPairs(QuestionVGUI) do
			v:SetPos(num, ScrH() / 2 - 50)
			num = num + 300
		end
		
		self:Remove()
	end
	
	function panel:Think()
		self:SetTitle("Time: ".. tostring(math.Clamp(math.ceil(timeleft - (CurTime() - OldTime)), 0, 9999)))
		if timeleft - (CurTime() - OldTime) <= 0 then 
			panel:Close()
		end
	end

	local label = vgui.Create("DLabel")
	label:SetParent(panel)
	label:SetPos(5, 30)
	label:SetSize(380, 40)
	label:SetText(question)
	label:SetVisible(true)

	local divider = vgui.Create("Divider")
	divider:SetParent(panel)
	divider:SetPos(2, 80)
	divider:SetSize(380, 2)
	divider:SetVisible(true)

	local ybutton = vgui.Create("DButton")
	ybutton:SetParent(panel)
	ybutton:SetPos(/*147*/105, 100)
	ybutton:SetSize(40, 20)
	ybutton:SetText("Yes")
	ybutton:SetVisible(true)
	ybutton.DoClick = function()
		LocalPlayer():ConCommand("ans " .. quesid .. " 1\n")
		panel:Close()
	end
	
	local nbutton = vgui.Create("DButton")
	nbutton:SetParent(panel)
	nbutton:SetPos(155, 100)
	nbutton:SetSize(40, 20)
	nbutton:SetText("No")
	nbutton:SetVisible(true)
	nbutton.DoClick = function()
		LocalPlayer():ConCommand("ans " .. quesid .. " 2\n")
		panel:Close()
	end

	PanelNum = PanelNum + 300
	QuestionVGUI[quesid .. "ques"] = panel
	
	panel:SetSkin("LiquidDRP2")
end
usermessage.Hook("DoQuestion", MsgDoQuestion)

local function KillQuestionVGUI(msg)
	local id = msg:ReadString()

	if QuestionVGUI[id .. "ques"] and QuestionVGUI[id .. "ques"]:IsValid() then
		QuestionVGUI[id .. "ques"]:Close()
	end
end
usermessage.Hook("KillQuestionVGUI", KillQuestionVGUI)

local function DoVoteAnswerQuestion(ply, cmd, args)
	if not args[1] then return end
	
	local vote = 2
	if tonumber(args[1]) == 1 or string.lower(args[1]) == "yes" or string.lower(args[1]) == "true" then vote = 1 end
	
	for k,v in pairs(VoteVGUI) do
		if ValidPanel(v) then
			local ID = string.sub(k, 1, -5)
			VoteVGUI[k]:Close()
			RunConsoleCommand("vote", ID, vote)
			return
		end
	end
	
	for k,v in pairs(QuestionVGUI) do
		if ValidPanel(v) then
			local ID = string.sub(k, 1, -5)
			QuestionVGUI[k]:Close()
			RunConsoleCommand("ans", ID, vote)
			return
		end
	end
end
concommand.Add("rp_vote", DoVoteAnswerQuestion)

local function DoLetter(msg)
	LetterWritePanel = vgui.Create("Frame")
	LetterWritePanel:SetPos(ScrW() / 2 - 75, ScrH() / 2 - 100)
	LetterWritePanel:SetSize(150, 200)
	LetterWritePanel:SetMouseInputEnabled(true)
	LetterWritePanel:SetKeyboardInputEnabled(true)
	LetterWritePanel:SetVisible(true)
end
usermessage.Hook("DoLetter", DoLetter)

MENU_CONFIG = MENU_CONFIG || {}

MENU_CONFIG.height = ScrH()*0.75

MENU_CONFIG.width = ScrW()*0.8

MENU_CONFIG.primaryColor = Color(213, 100, 100, 255)

MENU_CONFIG.tabButtons = {
	[1] = {
		["name"] = "Dashboard",
		["descritpion"] = "Player actions and info",
		["loadtab"] = TabsDashboard
	},
	[2] = {
		["name"] = "Jobs",
		["descritpion"] = "Choose your carrer",
		["loadtab"] = TabsJobs
	},
	[3] = {
		["name"] = "Store",
		["descritpion"] = "Buy items",
		["loadtab"] = TabsStore
	},
	[4] = {
		["name"] = "Inventory",
		["descritpion"] = "Keep your items secure",
		["loadtab"] = TabsInventory
	},
	[5] = {
		["name"] = "Skills",
		["descritpion"] = "Level up",
		["loadtab"] = TabsSkills
	},
	[6] = {
		["name"] = "Crafting",
		["descritpion"] = "Craft new items",
		["loadtab"] = TabsCrafting
	}		
}

MENU_CONFIG.mainWindowContent = {
	[1] = {
		["name"] = "Bank",
		["loadtab"] = F4Bank
	},
	[2] = {
		["name"] = "BankVault",
		["loadtab"] = F4BankVault
	},
	[3] = {
		["name"] = "OreProcessing",
		["loadtab"] = F4OreProcessing
	},
	[4] = {
		["name"] = "Achievements",
		["loadtab"] = F4Achivements
	},
	[5] = {
		["name"] = "CharacterBoosters",
		["loadtab"] = F4CharacterBoosters
	},
	[6] = {
		["name"] = "ViewCases",
		["loadtab"] = F4ViewCases,
	},
	[7] = {
		["name"] = "PlayerStores",
		["loadtab"] = F4PlayerStores
	},
	[8] = {
		["name"] = "Rewards",
		["loadtab"] = F4PlayerRewards
	},
	[9] = {
		["name"] = "UpgradeSkills",
		["loadtab"] = TabsSkills,
		["isTab"] = true,
		["tabIndex"] = 5
	},
	[10] = {
		["name"] = "StockMarket",
		["loadtab"] = F4StockMarket
	}
}

function createBtn(target, x, y, w, h, text, onclick, paint)
	local button = vgui.Create("DButton", target)

	button:SetPos(x, y)

	button:SetSize(w, h)

	button:SetText(text)

	if onclick then

		button.DoClick = onclick

	end

	if paint then

		paint(button)

	end
end

function maxStringLength(str, max)

	local length = 0

	local newString = ""

	for i = 1, #str do

		if length > max then break end

		length = length + 1

		newString = newString .. str[i]

	end

	return newString

end

function tableLength(table)

	local i = 0

	for k in pairs(table) do i = i + 1 end

	return i

end

function findByValue(table, key, value)

	for i = 1, tableLength(table) do

		if table[i][key] == value then

			return table[i]

		end

	end

end

net.Receive("OpenF4Menu", function()

  local menu = vgui.Create("DFrame")

	menu:SetSize(MENU_CONFIG.width, MENU_CONFIG.height)

	menu:Center()

	menu:MakePopup()

	menu:SetTitle("")

	menu:SetDraggable(false)

	menu:ShowCloseButton(false)

	function menu:Paint()

		draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color( 44, 44, 44, 255 ))

		draw.SimpleTextOutlined("Rebellion RP", "HUDNumber", 110, 25, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, MENU_CONFIG.primaryColor)

	end

	-- Menu close button

	createBtn(menu, MENU_CONFIG.width-50, 10, 30, 30, "", function() menu:Close() end, function (btn)

		function btn:Paint()

			-- draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), MENU_CONFIG.primaryColor)
			draw.SimpleText("X", "Trebuchet24", self:GetWide()/2, self:GetTall()/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

	end)

	-- Tab selection buttons panel

	local tabSelectionPanel = vgui.Create("DPanel", menu)

	tabSelectionPanel:SetPos(10, 50)

	tabSelectionPanel:SetSize(MENU_CONFIG.width*.25, MENU_CONFIG.height-60)

	function tabSelectionPanel:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color( 66, 66, 66, 255 ))

	end

	local tabSelectionPanelWidth = tabSelectionPanel:GetWide()

	local tabSelectionPanelHeight = tabSelectionPanel:GetTall()

	-- Main window panel

	local mainWindowPanel = vgui.Create("DPanel", menu)

	mainWindowPanel:SetPos((MENU_CONFIG.width*.25) + 20, 50)

	mainWindowPanel:SetSize(MENU_CONFIG.width*.75-40, MENU_CONFIG.height-60)

	function mainWindowPanel:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(33, 33, 33, 255))

	end

	-- Shitty method to handle main page content
	-- If the console command method was called, reterive the string sent
	local InitContentRequested = net.ReadString()

	local selectedTab
	local selectedTabIndex

	if InitContentRequested && InitContentRequested ~= "" then

		-- Here we load a sub tab straight into the main window

		local foundResult = findByValue(MENU_CONFIG.mainWindowContent, "name", InitContentRequested)

		selectedTab = foundResult["loadtab"](mainWindowPanel) || MENU_CONFIG.tabButtons[1]["loadtab"](mainWindowPanel)

		selectedTabIndex = -1

	else
		-- F4 key was pressed, so we open onto home tab

		selectedTab = MENU_CONFIG.tabButtons[1]["loadtab"](mainWindowPanel)

		selectedTabIndex = 1

	end

	-- When a button from within the F4 menu is clicked, to chaneg the sub tab

	net.Receive("F4MainContentChange", function()
	
		local F4ContentName = net.ReadString()

		local foundResult = findByValue(MENU_CONFIG.mainWindowContent, "name", F4ContentName)

		selectedTab:Remove()

		selectedTab = foundResult["loadtab"](mainWindowPanel)

		if foundResult["isTab"] then

			selectedTabIndex = foundResult["tabIndex"]

		else

			selectedTabIndex = -1

		end


	end)

	-- Render tab selection buttons

	---- User Profile Information

	local userProfileDetails = vgui.Create("DPanel", tabSelectionPanel)

	userProfileDetails:SetPos(5, 10)

	userProfileDetails:SetSize(tabSelectionPanelWidth-10, tabSelectionPanelHeight*0.13)

	-- EXAMPLE VARS -- REPLACE WITH DARKRP VARS
	local expJob = team.GetName(LocalPlayer():Team())

	local expCash = CUR .. REBELLION.format_num(LocalPlayer():getDarkRPVar("money"))
	-- EXAMPLE VARS -- REPLACE WITH DARKRP VARS

	function userProfileDetails:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), MENU_CONFIG.primaryColor)

		draw.SimpleText(maxStringLength(LocalPlayer():Nick(), 20), "Trebuchet24", 80, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		draw.SimpleText(maxStringLength(expJob, 20), "Trebuchet20", 80, 40, Color( 100, 255, 100, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		draw.SimpleText(expCash, "Trebuchet18", 80, 60, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	end

	------ Avatar

	local playerAvatar = vgui.Create("AvatarImage", userProfileDetails)

	playerAvatar:SetPos(4, (userProfileDetails:GetTall() / 2) - (64/2))

	playerAvatar:SetSize(64, 64)

	playerAvatar:SetPlayer(LocalPlayer(), 64)

	-- Split profile from buttons

	local profileDetailsSpliter = vgui.Create("DPanel", tabSelectionPanel)

	profileDetailsSpliter:SetPos(5, 15 + userProfileDetails:GetTall())

	profileDetailsSpliter:SetSize(tabSelectionPanelWidth - 10, 2)

	function profileDetailsSpliter:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), MENU_CONFIG.primaryColor)

	end

	local tabSelectionPanelButtonsList = vgui.Create("DGrid", tabSelectionPanel)

	tabSelectionPanelButtonsList:SetPos(0, 25 + userProfileDetails:GetTall())

	tabSelectionPanelButtonsList:SetSize(tabSelectionPanelWidth, tabSelectionPanelHeight*0.83)

	tabSelectionPanelButtonsList:SetCols(1)

	tabSelectionPanelButtonsList:SetColWide(tabSelectionPanelWidth)

	tabSelectionPanelButtonsList:SetRowHeight(tabSelectionPanelHeight*0.13)

	for i = 1, tableLength(MENU_CONFIG.tabButtons) do

		local v = MENU_CONFIG.tabButtons[i]

		local but = vgui.Create("DButton")

		but:SetText( "" )

		but:SetSize( tabSelectionPanelButtonsList:GetWide(), tabSelectionPanelButtonsList:GetRowHeight() )

		but.DoClick = function()

			selectedTab:Remove()

			selectedTab = v["loadtab"](mainWindowPanel)

			selectedTabIndex = i

		end

		function but:Think()

			function but:Paint()

				if self:IsHovered() or selectedTabIndex == i then

					draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color( 213, 100, 100, 200 ))
					draw.SimpleText(v["descritpion"], "Trebuchet18", 10, self:GetTall()/2+15, Color( 200, 200, 200, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else

					draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color( 0, 0, 0, 0 ))
					draw.SimpleText(v["descritpion"], "Trebuchet18", 10, self:GetTall()/2+15, Color( 140, 140, 140, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				end

				draw.SimpleText(v["name"], "Trebuchet24", 10, self:GetTall()/2-10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			end

		end

		tabSelectionPanelButtonsList:AddItem(but)

	end

end)

local KeyFrameVisible = false
local function KeysMenu(um)
	local Vehicle = um:ReadBool()
	if KeyFrameVisible then return end
	local trace = LocalPlayer():GetEyeTrace()
	local Frame = vgui.Create("DFrame")
	KeyFrameVisible = true
	Frame:SetSize(200, 470)
	Frame:Center()
	Frame:SetVisible(true)
	Frame:MakePopup()
	
	function Frame:Think()
		local ent = LocalPlayer():GetEyeTrace().Entity
		if not IsValid(ent) or (not ent:IsDoor() and not string.find(ent:GetClass(), "vehicle")) or ent:GetPos():Distance(LocalPlayer():GetPos()) > 200 then
			self:Close()
		end
		if (!self.Dragging) then return end  
		local x = gui.MouseX() - self.Dragging[1] 
		local y = gui.MouseY() - self.Dragging[2] 
		x = math.Clamp( x, 0, ScrW() - self:GetWide() ) 
		y = math.Clamp( y, 0, ScrH() - self:GetTall() ) 
		self:SetPos( x, y ) 
	end
	local Entiteh = "door"
	if Vehicle then
		Entiteh = "vehicle"
	end
	Frame:SetTitle(Entiteh .. " options")
	
	function Frame:Close()
		KeyFrameVisible = false
		self:SetVisible( false )
		self:Remove()
	end
	
	if trace.Entity:OwnedBy(LocalPlayer()) then
		if not trace.Entity.DoorData then return end -- Don't open the menu when the door settings are not loaded yet
		local Owndoor = vgui.Create("DButton", Frame)
		Owndoor:SetPos(10, 30)
		Owndoor:SetSize(180, 100)
		Owndoor:SetText("Sell " .. Entiteh)
		Owndoor.DoClick = function() RunConsoleCommand("say", "/toggleown") Frame:Close() end
		
		local AddOwner = vgui.Create("DButton", Frame)
		AddOwner:SetPos(10, 140)
		AddOwner:SetSize(180, 100)
		AddOwner:SetText("Add owner")			
		AddOwner.DoClick = function()
			local menu = DermaMenu()
			for k,v in pairs(player.GetAll()) do
				if not trace.Entity:OwnedBy(v) and not trace.Entity:AllowedToOwn(v) then
					menu:AddOption(v:Nick(), function() LocalPlayer():ConCommand("say /ao ".. v:UserID()) end)
				end
			end
			if menu.Panels and #menu.Panels == 0 then
				menu:AddOption("Noone available", function() end)
			end
			menu:Open()
		end
		
		local RemoveOwner = vgui.Create("DButton", Frame)
		RemoveOwner:SetPos(10, 250)
		RemoveOwner:SetSize(180, 100)
		RemoveOwner:SetText("Remove owner")			
		RemoveOwner.DoClick = function()
			local menu = DermaMenu()
			for k,v in pairs(player.GetAll()) do
				if (trace.Entity:OwnedBy(v) and not trace.Entity:IsMasterOwner(v)) or trace.Entity:AllowedToOwn(v) then
					menu:AddOption(v:Nick(), function() LocalPlayer():ConCommand("say /ro ".. v:UserID()) end)
				end
			end
			if menu.Panels and #menu.Panels == 0 then
				menu:AddOption("Noone available", function() end)
			end
			menu:Open()
		end
		
		local DoorTitle = vgui.Create("DButton", Frame)
		DoorTitle:SetPos(10, 360)
		DoorTitle:SetSize(180, 100)
		DoorTitle:SetText("Set "..Entiteh.." title")
		if not trace.Entity:IsMasterOwner(LocalPlayer()) then
			RemoveOwner.m_bDisabled = true
		end
		DoorTitle.DoClick = function()
			Derma_StringRequest("Set door title", "Set the title of the "..Entiteh.." you're looking at", "", function(text) LocalPlayer():ConCommand("say /title ".. text) Frame:Close() end, function() end, "OK!", "CANCEL!")
		end
		
		if LocalPlayer():IsSuperAdmin() and not Vehicle then
			Frame:SetSize(200, Frame:GetTall() + 110)
			local SetCopsOnly = vgui.Create("DButton", Frame)
			SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
			SetCopsOnly:SetSize(180, 100)
			SetCopsOnly:SetText("(Re)set door group")
			SetCopsOnly.DoClick = function() 
				local menu = DermaMenu()
				menu:AddOption("No group", function() RunConsoleCommand("say", "/togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					menu:AddOption(k, function() RunConsoleCommand("say", "/togglegroupownable "..k) Frame:Close() end)
				end
				menu:Open()
			end
		end	
	elseif not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:IsOwnable() and not trace.Entity:IsOwned() and not trace.Entity.DoorData.NonOwnable then
		if not trace.Entity.DoorData.GroupOwn then
			Frame:SetSize(200, 140)
			local Owndoor = vgui.Create("DButton", Frame)
			Owndoor:SetPos(10, 30)
			Owndoor:SetSize(180, 100)
			Owndoor:SetText("Buy " .. Entiteh)
			Owndoor.DoClick = function() RunConsoleCommand("say", "/toggleown") Frame:Close() end
		elseif not LocalPlayer():IsSuperAdmin() then
			Frame:Close()
		end
		if LocalPlayer():IsSuperAdmin() then
			if trace.Entity.DoorData.GroupOwn then
				Frame:SetSize(200, 250)
			else
				Frame:SetSize(200, 360)
			end
			local DisableOwnage = vgui.Create("DButton", Frame)
			DisableOwnage:SetPos(10, Frame:GetTall() - 220)
			DisableOwnage:SetSize(180, 100)
			DisableOwnage:SetText("Disallow ownership")
			DisableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("say", "/toggleownable") end
			
			local SetCopsOnly = vgui.Create("DButton", Frame)
			SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
			SetCopsOnly:SetSize(180, 100)
			SetCopsOnly:SetText("(Re)set door group")
			SetCopsOnly.DoClick = function() 
				local menu = DermaMenu()
				menu:AddOption("No group", function() RunConsoleCommand("say", "/togglegroupownable") if ValidPanel(Frame) then Frame:Close()  end end)
				for k,v in pairs(RPExtraTeamDoors) do
					menu:AddOption(k, function() RunConsoleCommand("say", "/togglegroupownable "..k) if ValidPanel(Frame) then Frame:Close()  end end)
				end
				menu:Open()
			end
		elseif not trace.Entity.DoorData.GroupOwn then
			RunConsoleCommand("say", "/toggleown")
			Frame:Close()
			KeyFrameVisible = true
			timer.Simple(0.3, function() KeyFrameVisible = false end)
		end
	elseif not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:AllowedToOwn(LocalPlayer()) then
		Frame:SetSize(200, 140)
		local Owndoor = vgui.Create("DButton", Frame)
		Owndoor:SetPos(10, 30)
		Owndoor:SetSize(180, 100)
		Owndoor:SetText("Co-own " .. Entiteh)
		Owndoor.DoClick = function() RunConsoleCommand("say", "/toggleown") Frame:Close() end
		
		if LocalPlayer():IsSuperAdmin() then
			Frame:SetSize(200, Frame:GetTall() + 110)
			local SetCopsOnly = vgui.Create("DButton", Frame)
			SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
			SetCopsOnly:SetSize(180, 100)
			SetCopsOnly:SetText("(Re)set door group")
			SetCopsOnly.DoClick = function() 
				local menu = DermaMenu()
				menu:AddOption("No group", function() RunConsoleCommand("say", "/togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					menu:AddOption(k, function() RunConsoleCommand("say", "/togglegroupownable "..k) Frame:Close() end)
				end
				menu:Open() 
			end
		else
			RunConsoleCommand("say", "/toggleown")
			Frame:Close()
			KeyFrameVisible = true
			timer.Simple(0.3, function() KeyFrameVisible = false end)
		end	
	elseif LocalPlayer():IsSuperAdmin() and trace.Entity.DoorData.NonOwnable then
		Frame:SetSize(200, 250)
		local EnableOwnage = vgui.Create("DButton", Frame)
		EnableOwnage:SetPos(10, 30)
		EnableOwnage:SetSize(180, 100)
		EnableOwnage:SetText("Allow ownership")
		EnableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("say", "/toggleownable") end
		
		local DoorTitle = vgui.Create("DButton", Frame)
		DoorTitle:SetPos(10, Frame:GetTall() - 110)
		DoorTitle:SetSize(180, 100)
		DoorTitle:SetText("Set "..Entiteh.." title")
		DoorTitle.DoClick = function()
			Derma_StringRequest("Set door title", "Set the title of the "..Entiteh.." you're looking at", "", function(text) LocalPlayer():ConCommand("say /title ".. text) Frame:Close() end, function() end, "OK!", "CANCEL!")
		end
	elseif LocalPlayer():IsSuperAdmin() and not trace.Entity:OwnedBy(LocalPlayer()) and trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(LocalPlayer()) then
		Frame:SetSize(200, 250)
		local DisableOwnage = vgui.Create("DButton", Frame)
		DisableOwnage:SetPos(10, 30)
		DisableOwnage:SetSize(180, 100)
		DisableOwnage:SetText("Disallow ownership")
		DisableOwnage.DoClick = function() Frame:Close() RunConsoleCommand("say", "/toggleownable") end
		
		local SetCopsOnly = vgui.Create("DButton", Frame)
		SetCopsOnly:SetPos(10, Frame:GetTall() - 110)
		SetCopsOnly:SetSize(180, 100)
		SetCopsOnly:SetText("(Re)set door group")
			SetCopsOnly.DoClick = function() 
				local menu = DermaMenu()
				menu:AddOption("No group", function() RunConsoleCommand("say", "/togglegroupownable") Frame:Close() end)
				for k,v in pairs(RPExtraTeamDoors) do
					menu:AddOption(k, function() RunConsoleCommand("say", "/togglegroupownable "..k) Frame:Close() end)
				end
				menu:Open()
			end
	else
		Frame:Close()
	end
	
	Frame:SetSkin("LiquidDRP2")
end
usermessage.Hook("KeysMenu", KeysMenu)
