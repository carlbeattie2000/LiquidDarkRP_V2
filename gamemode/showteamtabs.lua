CreateClientConVar("rp_playermodel", "", true, true)

local LDRP = {}

function LDRP.InitClient()
	timer.Simple(.3, function()
		LocalPlayer().Inventory = {}
		LocalPlayer().Skills = {}
		LocalPlayer().MaxWeight = 0
		LocalPlayer().Bank = {}
		LocalPlayer().MaxBWeight = 0
    LocalPlayer().InterestRate = {}
    LocalPlayer().RobbingBank = false

		print("Client has been initialized.")

		RunConsoleCommand("_initme")
	end)
end
hook.Add("InitPostEntity","Loads inventory and character",LDRP.InitClient)

local function MayorOptns()
	local MayCat = vgui.Create("DCollapsibleCategory")
	function MayCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	MayCat:SetLabel("Mayor options")
		local maypanel = vgui.Create("DListLayout")
		maypanel:SetSize(740,170)
			local SearchWarrant = maypanel:Add("DButton")
			SearchWarrant:SetText(LANGUAGE.searchwarrantbutton)
			SearchWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:getDarkRPVar("warrant") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function()
							Derma_StringRequest("Warrant", "Why would you warrant "..ply:Nick().."?", nil,
								function(a)
									RunConsoleCommand("darkrp", "/warrant", ply:SteamID(), a)
								end,
							function() end )
						end)
					end
				end
				menu:Open()
			end

			local Warrant = maypanel:Add("DButton")
			Warrant:SetText(LANGUAGE.make_wanted)
			Warrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:getDarkRPVar("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() Derma_StringRequest("wanted", "Why would you make "..ply:Nick().." wanted?", nil,
								function(a)
									RunConsoleCommand("darkrp", "/wanted", ply:SteamID(), a)
								end,
							function() end )
						end)
					end
				end
				menu:Open()
			end

			local UnWarrant = maypanel:Add("DButton")
			UnWarrant:SetText(LANGUAGE.make_unwanted)
			UnWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if ply:getDarkRPVar("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("darkrp /unwanted \"" .. ply:SteamID() .. "\"") end)
					end
				end
				menu:Open()
			end

			local Lockdown = maypanel:Add("DButton")
			Lockdown:SetText(LANGUAGE.initiate_lockdown)
			Lockdown.DoClick = function()
				LocalPlayer():ConCommand("darkrp /lockdown")
			end


			local UnLockdown = maypanel:Add("DButton")
			UnLockdown:SetText(LANGUAGE.stop_lockdown)
			UnLockdown.DoClick = function()
				LocalPlayer():ConCommand("darkrp /unlockdown")
			end

			local Lottery = maypanel:Add("DButton")
			Lottery:SetText(LANGUAGE.start_lottery)
			Lottery.DoClick = function()
				LocalPlayer():ConCommand("darkrp /lottery")
			end

			local GiveLicense = maypanel:Add("DButton")
			GiveLicense:SetText(LANGUAGE.give_license_lookingat)
			GiveLicense.DoClick = function()
				LocalPlayer():ConCommand("darkrp /givelicense")
			end

			local PlaceLaws = maypanel:Add("DButton")
			PlaceLaws:SetText("Place a screen containing the laws.")
			PlaceLaws.DoClick = function()
				LocalPlayer():ConCommand("darkrp /placelaws")
			end

			local AddLaws = maypanel:Add("DButton")
			AddLaws:SetText("Add a law.")
			AddLaws.DoClick = function()
				Derma_StringRequest("Add a law", "Type the law you would like to add here.", "", function(law)
					RunConsoleCommand("darkrp", "/addlaw", law)
				end)
			end

			local RemLaws = maypanel:Add("DButton")
			RemLaws:SetText("Remove a law.")
			RemLaws.DoClick = function()
				Derma_StringRequest("Remove a law", "Enter the number of the law you would like to remove here.", "", function(num)
					LocalPlayer():ConCommand("darkrp /removelaw " .. num)
				end)
			end
	MayCat:SetContents(maypanel)
	MayCat:SetSkin("LiquidDRP2")
	return MayCat
end

local function CPOptns()
	local CPCat = vgui.Create("DCollapsibleCategory")
	function CPCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	CPCat:SetLabel("Police options")
		local CPpanel = vgui.Create("DListLayout")
		CPpanel:SetSize(740,170)
			local SearchWarrant = CPpanel:Add("DButton")
			SearchWarrant:SetText(LANGUAGE.request_warrant)
			SearchWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:getDarkRPVar("warrant") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function()
							Derma_StringRequest("Warrant", "Why would you warrant "..ply:Nick().."?", nil,
								function(a)
									RunConsoleCommand("darkrp", "/warrant", ply:SteamID(), a)
								end,
							function() end )
						end)
					end
				end
				menu:Open()
			end

			local Warrant = CPpanel:Add("DButton")
			Warrant:SetText(LANGUAGE.searchwarrantbutton)
			Warrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if not ply:getDarkRPVar("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function()
							Derma_StringRequest("wanted", "Why would you make "..ply:Nick().." wanted?", nil,
								function(a)
									if not IsValid(ply) then return end
									RunConsoleCommand("darkrp", "/wanted", ply:SteamID(), a)
								end,
							function() end )
						end)
					end
				end
				menu:Open()
			end

			local UnWarrant = CPpanel:Add("DButton")
			UnWarrant:SetText(LANGUAGE.unwarrantbutton)
			UnWarrant.DoClick = function()
				local menu = DermaMenu()
				for _,ply in pairs(player.GetAll()) do
					if ply:getDarkRPVar("wanted") and ply ~= LocalPlayer() then
						menu:AddOption(ply:Nick(), function() LocalPlayer():ConCommand("darkrp /unwanted \"" .. ply:SteamID() .. "\"") end)
					end
				end
				menu:Open()
			end

			if LocalPlayer():Team() == TEAM_CHIEF and GAMEMODE.Config.chiefjailpos or LocalPlayer():IsAdmin() then
				local SetJailPos = CPpanel:Add("DButton")
				SetJailPos:SetText(LANGUAGE.set_jailpos)
				SetJailPos.DoClick = function() LocalPlayer():ConCommand("darkrp /jailpos") end

				local AddJailPos = CPpanel:Add("DButton")
				AddJailPos:SetText(LANGUAGE.add_jailpos)
				AddJailPos.DoClick = function() LocalPlayer():ConCommand("darkrp /addjailpos") end
			end

			local ismayor -- Firstly look if there's a mayor
			local ischief -- Then if there's a chief
			for k,v in pairs(player.GetAll()) do
				if v:Team() == TEAM_MAYOR then
					ismayor = true
					break
				end
			end

			if not ismayor then
				for k,v in pairs(player.GetAll()) do
					if v:Team() == TEAM_CHIEF then
						ischief = true
						break
					end
				end
			end

			local Team = LocalPlayer():Team()
			if not ismayor and (Team == TEAM_CHIEF or (not ischief and Team == TEAM_POLICE)) then
				local GiveLicense = CPpanel:Add("DButton")
				GiveLicense:SetText(LANGUAGE.give_license_lookingat)
				GiveLicense.DoClick = function()
					LocalPlayer():ConCommand("darkrp /givelicense")
				end
			end
	CPCat:SetContents(CPpanel)
	CPCat:SetSkin("LiquidDRP2")
	return CPCat
end


local function CitOptns()
	local CitCat = vgui.Create("DCollapsibleCategory")
	function CitCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	CitCat:SetLabel("Citizen options")
		local Citpanel = vgui.Create("DListLayout")
		Citpanel:SetSize(740,110)
		
		local joblabel = Citpanel:Add("DLabel")
		joblabel:SetText(LANGUAGE.set_custom_job)
		
		local jobentry = Citpanel:Add("DTextEntry")
		jobentry:SetValue(LocalPlayer().DarkRPVars.job or "")
		
		local debounce = false
		jobentry.OnEnter = function()
			if debounce == true then return end
			debounce = true
			net.Start( "ChangeJob" )
			net.WriteEntity( LocalPlayer() )
			net.WriteString( jobentry:GetValue() )
			net.SendToServer( )
			timer.Simple(3, function()
				debounce = false
			end)
		end
		jobentry.OnLoseFocus = jobentry.OnEnter
		
	CitCat:SetContents(Citpanel)
	CitCat:SetSkin("LiquidDRP2")
	return CitCat
end


local function MobOptns()
	local MobCat = vgui.Create("DCollapsibleCategory")
	function MobCat:Paint()
		self:SetBGColor(team.GetColor(LocalPlayer():Team()))
	end
	MobCat:SetLabel("Mobboss options")
		local Mobpanel = vgui.Create("DPanelList")
		Mobpanel:SetSpacing(5)
		Mobpanel:SetSize(740,110)
		Mobpanel:EnableHorizontal(false)
		Mobpanel:EnableVerticalScrollbar(true)
		
		local agendalabel = vgui.Create("DLabel")
		agendalabel:SetText(LANGUAGE.set_agenda)
		Mobpanel:AddItem(agendalabel)
		
		local agendaentry = vgui.Create("DTextEntry")
		agendaentry:SetValue(LocalPlayer().DarkRPVars.agenda or "")
		agendaentry.OnEnter = function()
			LocalPlayer():ConCommand("say /agenda " .. tostring(agendaentry:GetValue()))
		end
		agendaentry.OnLoseFocus = agendaentry.OnEnter
		Mobpanel:AddItem(agendaentry)
		
	MobCat:SetContents(Mobpanel)
	MobCat:SetSkin("LiquidDRP2")
	return MobCat
end

function MoneyTab()
	local FirstTabPanel = vgui.Create("DPanelList")
	FirstTabPanel:EnableVerticalScrollbar( true )
		function FirstTabPanel:Update()
			self:Clear(true)
			local MoneyCat = vgui.Create("DCollapsibleCategory")
			MoneyCat:SetLabel("Money")
				local MoneyPanel = vgui.Create("DListLayout")
				MoneyPanel:SetSize(740,60)

				--Obsolete due to F1 trading
				--[[local GiveMoneyButton = MoneyPanel:Add("DButton")
				GiveMoneyButton:SetText(LANGUAGE.give_money)
				GiveMoneyButton.DoClick = function()
					Derma_StringRequest("Amount of money", "How much money do you want to give?", "", function(a) LocalPlayer():ConCommand("darkrp /give " .. tostring(a)) end)
				end]]

				local SpawnMoneyButton = MoneyPanel:Add("DButton")
				SpawnMoneyButton:SetText(LANGUAGE.drop_money)
				SpawnMoneyButton.DoClick = function()
					Derma_StringRequest("Amount of money", "How much money do you want to drop?", "", function(a) LocalPlayer():ConCommand("darkrp /dropmoney " .. tostring(a)) end)
				end

				MoneyCat:SetContents(MoneyPanel)
			MoneyCat:SetSkin("LiquidDRP2")
		
		
			local Commands = vgui.Create("DCollapsibleCategory")
			Commands:SetLabel("Actions")
					local ActionsPanel = vgui.Create("DListLayout")
					ActionsPanel:SetSize(740,210)
						local rpnamelabel = ActionsPanel:Add("DLabel")
						rpnamelabel:SetText(LANGUAGE.change_name)
						rpnamelabel:SetBright(true)

						local rpnameTextbox = ActionsPanel:Add("DTextEntry")
						rpnameTextbox:SetText(LocalPlayer():Nick())
						rpnameTextbox.OnEnter = function() LocalPlayer():ConCommand("say /rpname " .. tostring(rpnameTextbox:GetValue())) end
						rpnameTextbox.OnLoseFocus = function() LocalPlayer():ConCommand("say /rpname " .. tostring(rpnameTextbox:GetValue())) end
					
						local sleep = ActionsPanel:Add("DButton")
						sleep:SetText(LANGUAGE.go_to_sleep)
						sleep.DoClick = function()
							LocalPlayer():ConCommand("say /sleep")
						end	
						
						local Drop = ActionsPanel:Add("DButton")
						Drop:SetText(LANGUAGE.drop_weapon)
						Drop.DoClick = function() LocalPlayer():ConCommand("say /drop") end
				
						if LocalPlayer():Team() ~= TEAM_MAYOR then
							local RequestLicense = ActionsPanel:Add("DButton")
							RequestLicense:SetText(LANGUAGE.request_gunlicense)
							RequestLicense.DoClick = function() LocalPlayer():ConCommand("say /requestlicense") end
						end
				
						local Demote = ActionsPanel:Add("DButton")
						Demote:SetText(LANGUAGE.demote_player_menu)
						Demote.DoClick = function()
							local menu = DermaMenu()
							for _,ply in pairs(player.GetAll()) do
								if ply ~= LocalPlayer() then
									menu:AddOption(ply:Nick(), function()
										Derma_StringRequest("Demote reason", "Why would you demote "..ply:Nick().."?", nil,
											function(a)
												LocalPlayer():ConCommand("say /demote ".. tostring(ply:UserID()).." ".. a)
											end, function() end )
									end)
								end
							end
							menu:Open()
						end
				
						local UnOwnAllDoors = ActionsPanel:Add("DButton")
							UnOwnAllDoors:SetText("Sell all of your doors")
							UnOwnAllDoors.DoClick = function() LocalPlayer():ConCommand("say /unownalldoors") end
					Commands:SetContents(ActionsPanel)
		FirstTabPanel:AddItem(MoneyCat)
		Commands:SetSkin("LiquidDRP2")
		FirstTabPanel:AddItem(Commands)
		
		if LocalPlayer():Team() == TEAM_MAYOR then
			FirstTabPanel:AddItem(MayorOptns())
		elseif LocalPlayer():Team() == TEAM_CITIZEN then
			FirstTabPanel:AddItem(CitOptns())
		elseif LocalPlayer():Team() == TEAM_POLICE or LocalPlayer():Team() == TEAM_CHIEF then
			FirstTabPanel:AddItem(CPOptns())
		elseif LocalPlayer():Team() == TEAM_MOB then
			FirstTabPanel:AddItem(MobOptns())
		end
	end
	FirstTabPanel:Update()
	return FirstTabPanel	
end
	
function JobsTab()
	local hordiv = vgui.Create("DHorizontalDivider")
	hordiv:SetLeftWidth(370)
	function hordiv.m_DragBar:OnMousePressed() end
	hordiv.m_DragBar:SetCursor("none")
	local Panel
	local Information
	function hordiv:Update()
		if Panel and Panel:IsValid() then
			Panel:Remove()
		end
		Panel = vgui.Create( "DPanelList")
		Panel:SetSize(370, 540)
		Panel:SetSpacing(1)
		Panel:EnableHorizontal( true )
		Panel:EnableVerticalScrollbar( true )
		Panel:SetSkin("LiquidDRP2")
		
		
		local Info = {}
		local model
		local modelpanel
		local function UpdateInfo(a)
			if Information and Information:IsValid() then
				Information:Remove()
			end
			Information = vgui.Create( "DPanelList" )
			Information:SetPos(378,0)
			Information:SetSize(370, 540)
			Information:SetSpacing(10)
			Information:EnableHorizontal( false )
			Information:EnableVerticalScrollbar( true )
			Information:SetSkin("LiquidDRP2")
			function Information:Rebuild() -- YES IM OVERRIDING IT AND CHANGING ONLY ONE LINE BUT I HAVE A FUCKING GOOD REASON TO DO IT!
				local Offset = 0
				if ( self.Horizontal ) then
					local x, y = self.Padding, self.Padding;
					for k, panel in pairs( self.Items ) do
						local w = panel:GetWide()
						local h = panel:GetTall()
						if ( x + w  > self:GetWide() ) then
							x = self.Padding
							y = y + h + self.Spacing
						end
						panel:SetPos( x, y )
						x = x + w + self.Spacing
						Offset = y + h + self.Spacing
					end
				else
					for k, panel in pairs( self.Items ) do
						if not panel:IsValid() then return end
						panel:SetSize( self:GetCanvas():GetWide() - self.Padding * 2, panel:GetTall() )
						panel:SetPos( self.Padding, self.Padding + Offset )
						panel:InvalidateLayout( true )
						Offset = Offset + panel:GetTall() + self.Spacing
					end
					Offset = Offset + self.Padding	
				end
				self:GetCanvas():SetTall( Offset + (self.Padding) - self.Spacing ) 
			end
			
			if type(Info) == "table" and #Info > 0 then
				for k,v in ipairs(Info) do
					local label = vgui.Create("DLabel")
					label:SetText(v)
					label:SizeToContents()
					if label:IsValid() then
						Information:AddItem(label)
					end
				end
			end

			if model and type(model) == "string" and a ~= false then
				modelpanel = vgui.Create("DModelPanel")
				modelpanel:SetModel(model)
				modelpanel:SetSize(90,230)
				modelpanel:SetAnimated(true)
				modelpanel:SetFOV(90)
				modelpanel:SetAnimSpeed(1)
				if modelpanel:IsValid() then
					Information:AddItem(modelpanel)
				end
			end
			hordiv:SetLeft(Panel)
			hordiv:SetRight(Information)
		end
		UpdateInfo()
		
		local function AddIcon(Model, name, description, Weapons, command, special, specialcommand)
			local icon = vgui.Create("SpawnIcon")
			local IconModel = Model
			if type(Model) == "table" then
				IconModel = Model[math.random(#Model)]
			end
			icon:SetModel(IconModel)
			
			--icon:SetIconSize(120)
			icon:SetSize(120, 120)
			icon:SetToolTip()
			icon.OnCursorEntered = function()
				icon.PaintOverOld = icon.PaintOver 
				icon.PaintOver = icon.PaintOverHovered
				Info[1] = LANGUAGE.job_name .. name 
				Info[2] = LANGUAGE.job_description .. description
				Info[3] = LANGUAGE.job_weapons .. Weapons
				model = IconModel
				UpdateInfo()
			end
			icon.OnCursorExited = function()
				if ( icon.PaintOver == icon.PaintOverHovered ) then 
					icon.PaintOver = icon.PaintOverOld 
				end
				Info = {}
				if modelpanel and modelpanel:IsValid() and icon:IsValid() then
					modelpanel:Remove()
					UpdateInfo(false)
				end
			end
			
			icon.DoClick = function()
				local function DoChatCommand(frame)
					if special then
						local menu = DermaMenu()
						menu:AddOption("Vote", function() LocalPlayer():ConCommand("say "..command) frame:Close() end)
						menu:AddOption("Do not vote", function() LocalPlayer():ConCommand("say " .. specialcommand) frame:Close() end)
						menu:Open()
					else
						LocalPlayer():ConCommand("say " .. command)
						frame:Close()
					end
				end
				
				if type(Model) == "table" and #Model > 0 then
					hordiv:GetParent():GetParent():Close()
					local frame = vgui.Create( "DFrame" )
					frame:SetTitle( "Choose model" )
					frame:SetVisible(true)
					frame:MakePopup()
					
					local levels = 1
					local IconsPerLevel = math.floor(ScrW()/64)
					
					while #Model * (64/levels) > ScrW() do
						levels = levels + 1
					end
					frame:SetSize(math.Min(#Model * 64, IconsPerLevel*64), math.Min(90+(64*(levels-1)), ScrH()))
					frame:Center()
					
					local CurLevel = 1
					for k,v in pairs(Model) do
						local icon = vgui.Create("SpawnIcon", frame)
						if (k-IconsPerLevel*(CurLevel-1)) > IconsPerLevel then
							CurLevel = CurLevel + 1
						end
						icon:SetPos((k-1-(CurLevel-1)*IconsPerLevel) * 64, 25+(64*(CurLevel-1)))
						icon:SetModel(v)
						icon:SetSize(64, 64)
						icon:SetToolTip()
						icon.DoClick = function()
							RunConsoleCommand("rp_playermodel", v)
							RunConsoleCommand("_rp_ChosenModel", v)
							DoChatCommand(frame)
						end
					end
				else
					DoChatCommand(hordiv:GetParent():GetParent())
				end
			end
			
			if icon:IsValid() then
				Panel:AddItem(icon)
			end
		end
		
		for k,v in ipairs(RPExtraTeams) do
			if LocalPlayer():Team() ~= k and GAMEMODE:CustomObjFitsMap(v) then
				local nodude = true
				if v.admin == 1 and not LocalPlayer():IsAdmin() then
					nodude = false
				end
				if v.admin > 1 and not LocalPlayer():IsSuperAdmin() then
					nodude = false
				end
				if v.customCheck and not v.customCheck(LocalPlayer()) then
					nodude = false
				end

				if (type(v.NeedToChangeFrom) == "number" and LocalPlayer():Team() ~= v.NeedToChangeFrom) or (type(v.NeedToChangeFrom) == "table" and not table.HasValue(v.NeedToChangeFrom, LocalPlayer():Team())) then
					nodude = false
				end

				if nodude then
					local weps = "no extra weapons"
					if #v.weapons > 0 then
						weps = table.concat(v.weapons, "\n")
					end
					if (not v.RequiresVote and v.vote) or (v.RequiresVote and v.RequiresVote(LocalPlayer(), k)) then
						local condition = ((v.admin == 0 and LocalPlayer():IsAdmin()) or (v.admin == 1 and LocalPlayer():IsSuperAdmin()) or LocalPlayer().DarkRPVars["Priv"..v.command])
						if not v.model or not v.name or not v.description or not v.command then chat.AddText(Color(255,0,0,255), "Incorrect team! Fix your shared.lua!") return end
						AddIcon(v.model, v.name, v.description, weps, "/vote"..v.command, condition, "/"..v.command)
					else
						if not v.model or not v.name or not v.description or not v.command then chat.AddText(Color(255,0,0,255), "Incorrect team! Fix your shared.lua!") return end
						AddIcon(v.model, v.name, v.description, weps, "/"..v.command)
					end
				end
			end
		end
	end
	hordiv:Update()
	return hordiv
end

function EntitiesTab()
	local EntitiesPanel = vgui.Create("DPanelList")
	EntitiesPanel:EnableVerticalScrollbar( true )
		function EntitiesPanel:Update()
			self:Clear(true)
			local WepCat = vgui.Create("DCollapsibleCategory")
			WepCat:SetLabel("Weapons")
				local WepPanel = vgui.Create("DPanelList")
				WepPanel:SetSize(470, 100)
				WepPanel:SetAutoSize(true)
				WepPanel:SetSpacing(1)
				WepPanel:EnableHorizontal(true)
				WepPanel:EnableVerticalScrollbar(true)
					local function AddIcon(Model, description, command)
						local icon
						icon = CreateIcon(nil,Model,78,78,function() LocalPlayer():ConCommand("say "..command) end)
						icon:SetToolTip(description)
						WepPanel:AddItem(icon)
					end
					
					for k,v in pairs(CustomShipments) do
						if v.seperate and (not GAMEMODE.Config.restrictbuypistol or 
						(GAMEMODE.Config.restrictbuypistol and (not v.allowed[1] or table.HasValue(v.allowed, LocalPlayer():Team())))) then
							AddIcon(v.model, string.format(LANGUAGE.buy_a, "a "..v.name, CUR..v.pricesep), "/buy "..v.name)
						end
					end
					
					for k,v in pairs(GAMEMODE.AmmoTypes) do
						if not v.customCheck or v.customCheck(LocalPlayer()) then
							AddIcon(v.model, string.format(LANGUAGE.buy_a, v.name, GAMEMODE.Config.currency .. v.price), "/buyammo " .. v.ammoType)
						end
					end
			WepCat:SetContents(WepPanel)
			WepCat:SetSkin("LiquidDRP2")
			self:AddItem(WepCat)
			
			local EntCat = vgui.Create("DCollapsibleCategory")
			EntCat:SetLabel("Entities")
				local EntPanel = vgui.Create("DPanelList")
				EntPanel:SetSize(470, 200)
				EntPanel:SetAutoSize(true)
				EntPanel:SetSpacing(1)
				EntPanel:EnableHorizontal(true)
				EntPanel:EnableVerticalScrollbar(true)
					local function AddEntIcon(Model, description, command)
						local icon
						if command == "/buymoneyprinter" or command == "/buypot" then
							icon =	CreateIcon(nil,Model,78,78,function() LocalPlayer():ConCommand("say "..command) end,Vector(20,20,20))
						else
							icon = CreateIcon(nil,Model,78,78,function() LocalPlayer():ConCommand("say "..command) end)
						end
						icon:SetToolTip(description)
						EntPanel:AddItem(icon)
					end
					
					for k,v in pairs(DarkRPEntities) do
						if not v.allowed or (type(v.allowed) == "table" and table.HasValue(v.allowed, LocalPlayer():Team())) then
							local cmdname = string.gsub(v.ent, " ", "_")
							
							if not tobool(GetConVarNumber("disable"..cmdname)) then
								local price = GetConVarNumber(cmdname.."_price")
								if price == 0 then 
									price = v.price
								end
								AddEntIcon(v.model, "Buy a " .. v.name .." " .. CUR .. price, v.cmd)
							end
						end
					end
					
					for k,v in pairs(CustomShipments) do
						if not v.noship and table.HasValue(v.allowed, LocalPlayer():Team()) then
							AddEntIcon(v.model, string.format(LANGUAGE.buy_a, "a "..v.name .." shipment", CUR .. tostring(v.price)), "/buyshipment "..v.name)
						end
					end
			EntCat:SetContents(EntPanel)
			EntCat:SetSkin("LiquidDRP2")
			self:AddItem(EntCat)
			
			
			if #CustomVehicles <= 0 then return end
			local VehicleCat = vgui.Create("DCollapsibleCategory")
			VehicleCat:SetLabel("Vehicles")
				local VehiclePanel = vgui.Create("DPanelList")
				VehiclePanel:SetSize(470, 200)
				VehiclePanel:SetAutoSize(true)
				VehiclePanel:SetSpacing(1)
				VehiclePanel:EnableHorizontal(true)
				VehiclePanel:EnableVerticalScrollbar(true)
				local function AddVehicleIcon(Model, skin, description, command)
					local icon = vgui.Create("SpawnIcon")
					icon:InvalidateLayout( true ) 
					icon:SetModel(Model)
					icon:SetSkin(skin)
					icon:SetSize( 64, 64 )
					icon:SetToolTip(description)
					icon.DoClick = function() LocalPlayer():ConCommand("say "..command) end
					VehiclePanel:AddItem(icon)
				end
				
				local founds = 0
				for k,v in pairs(CustomVehicles) do
					if not v.allowed or table.HasValue(v.allowed, LocalPlayer():Team()) then
						local Skin = (list.Get("Vehicles")[v.name] and list.Get("Vehicles")[v.name].KeyValues and list.Get("Vehicles")[v.name].KeyValues.Skin) or "0"
						AddVehicleIcon(v.model or "models/buggy.mdl", Skin, "Buy a "..v.name.." for "..CUR..v.price, "/buyvehicle "..v.name)
						founds = founds + 1
					end
				end
			if founds ~= 0 then
				VehicleCat:SetContents(VehiclePanel)
				VehicleCat:SetSkin("LiquidDRP2")
				self:AddItem(VehicleCat)
			else
				VehiclePanel:Remove()
				VehicleCat:Remove()
			end
		end
	EntitiesPanel:SetSkin("LiquidDRP2")
	EntitiesPanel:Update()	
	return EntitiesPanel
end

-- Function copied from cl_stores.lua l:174

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

function BankTab()

	local MainBankBackground = vgui.Create("DPanel")

	local w = 740

	local h = 500

	function MainBankBackground:Paint()
		draw.RoundedBox(6, 0, 10, w, h, Color(0, 0, 0, 200))

		local BankWeight = 0

		for k, v in pairs(LocalPlayer().Bank) do
			if k == "curcash" then continue end

			if v && v >= 1 then
				
				BankWeight = BankWeight+(LDRP_SH.AllItems[k].weight*v)

			end

		end

		draw.SimpleTextOutlined("Bank Weight: " .. BankWeight .. " out of " .. LocalPlayer().MaxBWeight, "Trebuchet22", w*.5, h*.97, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(213, 100, 100, 255))
	end

	-- Window title

	local BankLabel = vgui.Create("DLabel", MainBankBackground)

	BankLabel:SetText("Bank")

	BankLabel:SetFont("HUDNumber")

	BankLabel:SetColor(Color(213, 100, 100, 255))

	BankLabel:SetPos(w*.45, h*.03)

	BankLabel:SizeToContents()

	-- Bank Items List

	local BankItemsListWide = 700

	local BankItemsScroll = vgui.Create("DScrollPanel", MainBankBackground)

	BankItemsScroll:SetPos((w*.5)-(BankItemsListWide/2), h*0.12)

	BankItemsScroll:SetSize(700, 100)

	local BankItemsList = vgui.Create("DPanelList", BankItemsScroll)

	-- BankItemsList:SetPos((w*.5)-(BankItemsListWide/2), h*0.12)
	BankItemsList:SetPos(0, 0)

	BankItemsList:SetWidth(BankItemsListWide)

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

	-- Inventory Items

	local InvItemsListWide = 700

	local InvItemsScroll = vgui.Create("DScrollPanel", MainBankBackground)

	InvItemsScroll:SetPos((w*.5)-(BankItemsListWide/2), h*0.40)

	InvItemsScroll:SetSize(700, 100)

	local InvLabel = vgui.Create("DLabel", MainBankBackground)

	InvLabel:SetText("Inventory")

	InvLabel:SetFont("HUDNumber")

	InvLabel:SetColor( Color(213, 100, 100, 255) )

	InvLabel:SetPos(w*.40, h*.32)

	InvLabel:SizeToContents()

	local InvItemsList = vgui.Create("DPanelList", InvItemsScroll)

	InvItemsList:SetPos(0, 0)

	InvItemsList:SetWidth(BankItemsListWide)

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

	-- Bank Balance

	local ButtonBackground = vgui.Create("DPanel", MainBankBackground)

	ButtonBackground:SetPos(0, h*0.60)

	ButtonBackground:SetWidth(600)

	ButtonBackground:SetHeight(86)

	function ButtonBackground:Paint()

		draw.RoundedBox(6, 0, 0, self:GetWide(), self:GetTall(), Color(30, 30, 30, 40))

	end

	local BalanceLabel = vgui.Create("DLabel", MainBankBackground)

	BalanceLabel:SetPos(20, h*.62)

	BalanceLabel:SetFont("HUDNumber")

	BalanceLabel:SetText("                                         ")

	function BalanceLabel:Paint()

		draw.SimpleTextOutlined("Balance $" .. REBELLION.numberFormat(LocalPlayer().Bank["curcash"] or ""), "HUDNumber", 0, ScrH()*.02, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color( 213, 100, 100, 255 ))

	end

	BalanceLabel:SizeToContents()

	-- Deposit

	local DepositInput = vgui.Create("DNumberWang", MainBankBackground)

	DepositInput:SetPos(20, (h*0.62)+40)

	DepositInput:SetSize(314, 35)

	DepositInput:SetEnterAllowed(false)

	DepositInput:SetText("1000")

	local HasClicked

	DepositInput.OnMousePressed = function()
		if !HasClicked then DepositInput:SetText("") HasClicked = true end
	end

	function DepositInput:Paint()
		draw.RoundedBox(6, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))
		self:DrawTextEntryText(Color(255, 255, 255), Color(0, 255, 0), Color(255, 255, 255))
	end

	local DepositButton = vgui.Create("DButton", MainBankBackground)

	DepositButton:SetPos(340, (h*.62)+40)

	DepositButton:SetSize(100, 35)

	DepositButton:SetText("")

	function DepositButton:Paint()
		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))
		draw.SimpleText("Deposit", "Default", self:GetWide() / 2, self:GetTall() / 2, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	function DepositButton:Think()


		if (!self:IsDown()) then
			function self:Paint()
				draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))
				draw.SimpleText("Deposit", "Default", self:GetWide() / 2, self:GetTall() / 2, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		else
			function self:Paint()
				draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 255))
				draw.SimpleText("Deposit", "Default", self:GetWide() / 2, self:GetTall() / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

	end

	DepositButton.DoClick = function()
		local amount = tonumber(DepositInput:GetValue())

		if amount and amount > 0 then

			RunConsoleCommand("_bnk", "money", -amount)

		else

			LocalPlayer():LiquidChat("BANK", Color(0,192,10), "Please enter a valid number!")

		end

	end

	-- Withdraw

	local WithdrawInput = vgui.Create("DNumberWang", MainBankBackground)

	WithdrawInput:SetPos(20, (h*0.70)+40)

	WithdrawInput:SetSize(314, 35)

	WithdrawInput:SetEnterAllowed(false)

	WithdrawInput:SetText("1000")

	local HasClicked2

	WithdrawInput.OnMousePressed = function()
		if !HasClicked2 then WithdrawInput:SetText("") HasClicked2 = true end
	end

	function WithdrawInput:Paint()
		draw.RoundedBox(6, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))
		self:DrawTextEntryText(Color(255, 255, 255), Color(0, 255, 0), Color(255, 255, 255))
	end

	local WithdrawButton = vgui.Create("DButton", MainBankBackground)

	WithdrawButton:SetPos(340, (h*.70)+40)

	WithdrawButton:SetSize(100, 35)

	WithdrawButton:SetText("")

	function WithdrawButton:Think()


		if (!self:IsDown()) then

			function self:Paint()

				draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))

				draw.SimpleText("Withdraw", "Default", self:GetWide() / 2, self:GetTall() / 2, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			end

		else
			function self:Paint()

				draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 255))

				draw.SimpleText("Withdraw", "Default", self:GetWide() / 2, self:GetTall() / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			end
		end

	end

	WithdrawButton.DoClick = function()
	
		local amount = tonumber(WithdrawInput:GetValue())

		if amount and amount > 0 then

			RunConsoleCommand("_bnk", "money", amount)
      RunConsoleCommand("_bnkupgrade", "balanceChanged", selectedOption)

		else

			LocalPlayer():LiquidChat("BANK", Color(0,192,10), "Please enter a valid number!")

		end

	end

	-- Upgrade account
	local AccountUpgradeOptionValues = {
		["Basic"] = "$50,000+",
		["Bronze"] = "$500,000+",
		["Silver"] = "$1,000,000+",
		["Gold"] = "$5,000,000+",
		["Platinum"] = "$10,000,000+",
		["Diamond"] = "$50,000,000+",
		["Nuclear"] =  "$100,000,000"
	}

	local AccountUpgradeOptions = vgui.Create( "DComboBox", MainBankBackground )

	AccountUpgradeOptions:SetPos(20, (h*.70)+80)

	AccountUpgradeOptions:SetSize(314, 30)

	AccountUpgradeOptions:SetValue("Upgrade Account")

	AccountUpgradeOptions:SetTextColor(Color(255, 255, 255, 255))

	for k,v in pairs(AccountUpgradeOptionValues) do
		AccountUpgradeOptions:AddChoice( k .. " " .. v )
	end

  AccountUpgradeOptions:SetSortItems(false)

	function AccountUpgradeOptions:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))

	end

	local AccountUpgradeButton = vgui.Create( "DButton", MainBankBackground )

	AccountUpgradeButton:SetPos(340, (h*.70)+80)

	AccountUpgradeButton:SetSize(100, 30)

	AccountUpgradeButton:SetText("")

	function AccountUpgradeButton:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color(213, 100, 100, 255))

		draw.SimpleText("Upgrade", "Default", self:GetWide() / 2, self:GetTall() / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	end

	AccountUpgradeButton.DoClick = function()
	
		local selectedOption = AccountUpgradeOptions:GetValue()

		RunConsoleCommand("_bnkupgrade", "upgrade", selectedOption)

	end

	local InterestRateAmount = vgui.Create("DPanel", MainBankBackground)

	InterestRateAmount:SetPos(450, (h*.62)+40)

	InterestRateAmount:SetSize(150, 35)

  PrintTable(LocalPlayer().InterestRate)

	function InterestRateAmount:Paint()

		draw.RoundedBox(5, 0, 0, self:GetWide(), self:GetTall(), Color( 213, 100, 100, 255 ))

		draw.SimpleText("10" .. "%", "DermaDefault", 20, 20, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	end



	return MainBankBackground
end

function LDRP.SendItemInfo(um)
	LocalPlayer().Inventory[tostring(um:ReadString())] = um:ReadFloat()
end
usermessage.Hook("SendItem",LDRP.SendItemInfo)

function LDRP.SendMaxWeight(um)
	LocalPlayer().MaxWeight = um:ReadFloat()
end
usermessage.Hook("SendWeight",LDRP.SendMaxWeight)

function LDRP.ReceiveSkill(um)
	local Skill = um:ReadString()
	LocalPlayer().Skills[Skill] = {}
	LocalPlayer().Skills[Skill].exp = um:ReadFloat()
	LocalPlayer().Skills[Skill].lvl = um:ReadFloat()
end
usermessage.Hook("SendSkill",LDRP.ReceiveSkill)

function LDRP.ReceiveEXP( len )
	local skill = net.ReadString()
	local exp = net.ReadFloat()
	LocalPlayer().Skills[skill].exp = exp
end
net.Receive( "SendEXP", LDRP.ReceiveEXP )

function LDRP.OpenItemOptions(item)
	if LocalPlayer().Inventory[item] then
		local WepNames = LDRP_SH.NicerWepNames
		local OptionsMenu = vgui.Create("DFrame")
		OptionsMenu:SetSize(200, 140)
		OptionsMenu:SetPos(-200, ScrH()*.5-80)
		OptionsMenu:MakePopup()
		OptionsMenu:MoveTo(ScrW()*.5-100,ScrH()*.5-80,.3)
		local Tbl = LDRP_SH.AllItems[item]
		
		OptionsMenu.Paint = function()
			draw.RoundedBox(6,0,0,200,140,Color(50,50,50,180))
			local name = WepNames[Tbl.nicename] or Tbl.nicename
			draw.SimpleTextOutlined(name .. " - " .. LocalPlayer().Inventory[item] .. " left","Trebuchet20",100,14,Color(255,255,255,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
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
		UseButton:SetText(Tbl.usename or "Use")
		if Tbl.cuse then
			UseButton.DoClick = function()
				RunConsoleCommand("_inven","use",item)
				OptionsMenu.MakeClose()
			end
		else
			UseButton:SetDisabled(true)
		end
		
		local DropButton = vgui.Create("DButton",OptionsMenu)
		DropButton:SetPos(4,66)
		DropButton:SetSize(192,32)
		DropButton:SetText("Drop")
		DropButton.DoClick = function()
			RunConsoleCommand("_inven","drop",item)
			OptionsMenu.MakeClose()
		end

		local RemoveButton = vgui.Create("DButton",OptionsMenu)
		RemoveButton:SetPos(4,102)
		RemoveButton:SetSize(192,32)
		RemoveButton:SetText("Remove")
		RemoveButton.DoClick = function()
			RunConsoleCommand("_inven","delete",item)
			OptionsMenu.MakeClose()
		end
		
	end
end

function InventoryTab()
	local Inv = {}
	local WepNames = LDRP_SH.NicerWepNames
	
	local w = 752
	local l = 518
	
	Inv.BackGround = vgui.Create("DPanel",F4Menu)
	Inv.BackGround:SetPos(4,4)
	Inv.BackGround:SetSize(l,w)
	Inv.BackGround.Paint = function()
		local InvWeight = 0
		for k,v in pairs(LocalPlayer().Inventory) do
			if v >= 1 then
				InvWeight = InvWeight+(LDRP_SH.AllItems[k].weight*v)
			end
		end
		
		draw.RoundedBox(6,0,0,w,l,Color(0,150,200,80))
		draw.RoundedBox(0,0,l*.01,w,l*.085,Color(250,250,250,220))
		draw.SimpleTextOutlined("Inventory","HUDNumber",w*.5,l*.0425,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
		draw.SimpleTextOutlined("Weight: " .. InvWeight .. " out of " .. LocalPlayer().MaxWeight,"Trebuchet22",w*.5,l*.97,Color(255,255,255,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
	end

	Inv.ItemList = vgui.Create("DPanelList",Inv.BackGround)
	Inv.ItemList:SetPos(4,56)
	Inv.ItemList:SetSize(742,436)
	Inv.ItemList:SetPadding(4)
	Inv.ItemList:SetSpacing(4)
	Inv.ItemList:EnableVerticalScrollbar(true)
	Inv.ItemList:EnableHorizontal(true)
	Inv.ItemList.Paint = function()
		draw.RoundedBox(6,0,0,742,436,Color(250,250,250,220))
	end
	local CurIcons = {}
	
	function Inv.BackGround.Update() -- This is probably a horrible way to do this, but look at half of the DarkRP code and see how much shittier that is instead of complaining about my code
		for k,v in pairs(LocalPlayer().Inventory) do
			local Check = CurIcons[k]
			if Check then
				if Check.am != v or v <= 0 then
					local ItemTbl = LDRP_SH.AllItems[k]
					if !ItemTbl then continue end
					if v <= 0 then
						Inv.ItemList:RemoveItem(Check.vgui)
						CurIcons[k] = nil
					else
						Check.vgui:SetToolTip(ItemTbl.nicename .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight)
						CurIcons[k].am = v
					end
				end
			elseif v > 0 then
				local ItemTbl = LDRP_SH.AllItems[k]
				if !ItemTbl then continue end
				local ItemIcon = CreateIcon(Inv.ItemList,ItemTbl.mdl,78,78,function() LDRP.OpenItemOptions(k) end)
				CurIcons[k] = {["vgui"] = ItemIcon,["am"] = v}
				local Namez = WepNames[ItemTbl.nicename] or ItemTbl.nicename
				ItemIcon:SetToolTip(Namez .. "\n" .. ItemTbl.descr .. "\nAmount: " .. v .. "\nWeight: " .. ItemTbl.weight)
		
				
				Inv.ItemList:AddItem(ItemIcon)
			end
			timer.Simple(.00001,function()
				Inv.ItemList:Rebuild()
			end)
		end
	end
	
	
	Inv.ItemList.Think = function()
		Inv.BackGround:Update()
	end
	return Inv.BackGround
end

function SkinsTab()
	local w,l = 752,518
	local B = {}
	
	B.BG = vgui.Create("DPanelList")
	B.BG:SetSize(w,l)
	B.BG:SetPadding(4)
	B.BG:SetSpacing(4)
	B.BG:EnableVerticalScrollbar(true)
	local Disabled
	
	for k,v in pairs(LDRP_Theme) do
		if k != "CurrentSkin" then
			local Skin = vgui.Create("DPanel")
			Skin:SetHeight(40)
			local OldP = Skin.Paint
			Skin.Paint = function(s)
				local TW,TH = s:GetSize()
				OldP(s)
				draw.SimpleTextOutlined(v.Name,"Trebuchet24",40,TH*.5,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
			end
			local Icon = vgui.Create("DImage",Skin)
			Icon:SetPos(7,12)
			Icon:SetSize(16,16)
			Icon:SetImage(v.Icon)
			
			timer.Simple(.1,function()
				local Reset = vgui.Create("DButton",Skin)
				Reset:SetSize(32,32)
				Reset:SetText("Set")
				Reset.DoClick = function(self)
					LDRP_Theme.CurrentSkin = k
					RefreshSkin()
					B.BG:SetSkin("LiquidDRP")
					file.Write("ldrp_savetheme.txt",k)
					if Disabled then
						Disabled:SetDisabled(false)
						Disabled:SetText("Set")
					end
					Reset:SetDisabled(true)
					Reset:SetText("Selected")
					Disabled = Reset
				end
				Reset.Think = function() Reset:SetPos(Skin:GetWide()-36,4) end
				if LDRP_Theme.CurrentSkin == k then
					Disabled = Reset
					Reset:SetDisabled(true)
					Reset:SetText("Selected")
				end
			end)
			
			B.BG:AddItem(Skin)
		end
	end
	return B.BG
end

function SkillsTab()
	
	local ST = {}
	
	local w = 744
	local l = 518
	
	ST.BackGround = vgui.Create("DPanel",F4Menu)
	ST.BackGround:SetSize(l,w)
	ST.BackGround.Paint = function()
		draw.RoundedBox(6,0,0,w,l,Color(0,200,0,80))
		draw.RoundedBox(0,0,l*.01,w,l*.085,Color(250,250,250,220))
		draw.SimpleTextOutlined("Skills","HUDNumber",w*.5,l*.0425,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
	end
	
	ST.SkillList = vgui.Create("DScrollPanel", ST.BackGround)
	ST.SkillList:SetPos(0,54)
	ST.SkillList:SetSize( w, 456 )
	ST.SkillList.Paint = function( self, w, h )
		draw.RoundedBox(6,0,0, w, h, Color(250,250,250,220))
	end
		
	for k,v in SortedPairs( LocalPlayer().Skills ) do
		local sk = LDRP_SH.AllSkills[k]
		local SkillItem = vgui.Create("DPanel")
		SkillItem:SetSize(734,80)
		SkillItem.Paint = function()
			local cure = LocalPlayer().Skills[k]
			draw.RoundedBox(6,0,0,734,80,Color(50,50,50,120))
			draw.RoundedBox(6,90,6,100,30,Color(230,230,230,255)) -- Title background
			draw.RoundedBox(6,90,43,528,30,Color(230,230,230,255)) -- Description background
			local need = LDRP_SH.AllSkills[k].exptbl[cure.lvl]
			draw.RoundedBox(6,198,6,528,30,Color(230,230,230,255))  -- EXP Background
			draw.RoundedBox(6,200,8,524*math.Clamp(cure.exp/need,.02,1),26,Color(0,220,0,170))
			draw.SimpleTextOutlined(cure.exp .. " / " .. need .. " until level " .. cure.lvl+1,"Trebuchet24",464,21,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
			local Txt = "Trebuchet24"
			if string.len(k) > 8 then Txt = "Trebuchet22" end
			draw.SimpleTextOutlined(k,Txt,100,20,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
			draw.SimpleTextOutlined(sk.descrpt,"Trebuchet24",100,57,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
		end
		
		local SkillIcon = vgui.Create("SpawnIcon", SkillItem)
		SkillIcon:SetPos(8,4)
		SkillIcon:SetSize(70, 70)
		SkillIcon:SetModel(sk.mdl)
		SkillIcon:SetToolTip()
		
		function SkillIcon:PaintOver() return end
		
		local SkillBuy = vgui.Create("DButton",SkillItem)
		SkillBuy:SetPos(624,43)
		SkillBuy:SetSize(100,30)
		SkillBuy:SetText("")
		SkillBuy.Paint = function()
			local cure = LocalPlayer().Skills[k]
			draw.RoundedBox(6,0,0,100,30,Color(230,230,230,255))
			draw.SimpleTextOutlined("Buy Next Level","Trebuchet18",50,15,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
			local need = LDRP_SH.AllSkills[k].exptbl[cure.lvl]
			if cure.exp < need then
				draw.RoundedBox(6,0,0,100,30,Color(100,100,100,240))
			end
		end
		if sk.pricetbl[v.lvl+1] then
			SkillBuy:SetToolTip("Buy level " .. v.lvl+1 .. " for $" .. sk.pricetbl[v.lvl+1])
		else
			SkillBuy:SetToolTip("Your level is maxxed out!")
		end
		local OldEnter = SkillBuy.OnCursorEntered
		SkillBuy.OnCursorEntered = function(s)
			local mylvl = LocalPlayer().Skills[k].lvl
			if sk.pricetbl[mylvl+1] then
				SkillBuy:SetToolTip("Buy level " .. mylvl+1 .. " for $" .. sk.pricetbl[mylvl+1])
			else
				SkillBuy:SetToolTip("Your level is maxxed out!")
			end
			return OldEnter(s)
		end
		SkillBuy.DoClick = function()
			local currentExp = LocalPlayer().Skills[k].exp

			if currentExp < sk.exptbl[v.lvl] then --v.exp contains old information, have to get it fresh from the skills table.
				LocalPlayer():ChatPrint("You need more experience!")
				chat.PlaySound()
			else
				RunConsoleCommand("_buysk",k)
			end
		end
		ST.SkillList:AddItem(SkillItem)
		SkillItem:Dock( TOP )
		SkillItem:DockMargin( 4, 0, 0, 4 )
	end
	
	return ST.BackGround
end

function RPAdminTab()
	local AdminPanel = vgui.Create("DPanelList", F4Menu)
	AdminPanel:SetSpacing(1)
	AdminPanel:EnableHorizontal( false	)
	AdminPanel:EnableVerticalScrollbar( true )
		function AdminPanel:Update()
			//self:Clear(true)
			local ToggleCat = vgui.Create("DCollapsibleCategory", self)
			ToggleCat:SetLabel("Toggle commands")
				local TogglePanel = vgui.Create("DPanelList", ToggleCat)
				TogglePanel:SetSize(470, 230)
				TogglePanel:SetSpacing(1)
				TogglePanel:EnableHorizontal(false)
				TogglePanel:EnableVerticalScrollbar(true)
				
				local ValueCat = vgui.Create("DCollapsibleCategory", self)
				ValueCat:SetLabel("Value commands")
				local ValuePanel = vgui.Create("DPanelList", ValueCat)
				ValuePanel:SetSize(470, 230)
				ValuePanel:SetSpacing(1)
				ValuePanel:EnableHorizontal(false)
				ValuePanel:EnableVerticalScrollbar(true)
				
			ToggleCat:SetContents(TogglePanel)
			ToggleCat:SetSkin("LiquidDRP2")
			self:AddItem(ToggleCat)
			function ToggleCat:Toggle()
				self:SetExpanded( !self:GetExpanded() ) 
				self.animSlide:Start( self:GetAnimTime(), { From = self:GetTall() } ) 
				if not self:GetExpanded() and ValueCat:GetExpanded() then
					ValuePanel:SetTall(470)
				elseif self:GetExpanded() and ValueCat:GetExpanded() then
					ValuePanel:SetTall(230)
					TogglePanel:SetTall(230)
				elseif self:GetExpanded() and not ValueCat:GetExpanded() then
					TogglePanel:SetTall(470)
				end 
				self:InvalidateLayout( true ) 
				self:GetParent():InvalidateLayout() 
				self:GetParent():GetParent():InvalidateLayout() 
				local cookie = '1' 
				if ( !self:GetExpanded() ) then cookie = '0' end 
				self:SetCookie( "Open", cookie )
			end  
			
			function ValueCat:Toggle()
				self:SetExpanded( !self:GetExpanded() ) 
				self.animSlide:Start( self:GetAnimTime(), { From = self:GetTall() } ) 

				if not self:GetExpanded() and ToggleCat:GetExpanded() then
					TogglePanel:SetTall(470)
				elseif self:GetExpanded() and ToggleCat:GetExpanded() then
					TogglePanel:SetTall(230)
					ValuePanel:SetTall(230)
				elseif self:GetExpanded() and not ToggleCat:GetExpanded() then
					ValuePanel:SetTall(470)
				end 
				self:InvalidateLayout( true ) 
				self:GetParent():InvalidateLayout() 
				self:GetParent():GetParent():InvalidateLayout()
				local cookie = '1' 
				if ( !self:GetExpanded() ) then cookie = '0' end 
				self:SetCookie( "Open", cookie )
			end  

			ValueCat:SetContents(ValuePanel)
			ValueCat:SetSkin("LiquidDRP2")
			self:AddItem(ValueCat)
		end
		AdminPanel:Update()
	AdminPanel:SetSkin("LiquidDRP2")
	return AdminPanel
end
