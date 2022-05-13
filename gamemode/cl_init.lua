GM.Version = "1"
GM.Name = "Rebbelion DarkRP"
GM.Author = "Rebbelion and Darkrp/LiquidRP Creators"

DeriveGamemode("sandbox")
util.PrecacheSound("earthquake.mp3")

REBELLION = REBELLION or {}

REBELLION.DefaultWidth = 2373
REBELLION.DefaultHeight = 1425

function comma_value(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

---============================================================
-- rounds a number to the nearest decimal places
--
function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

function REBELLION.format_num(amount, decimal, prefix, neg_prefix)
  local str_amount,  formatted, famount, remain

  decimal = decimal or 2  -- default 2 decimal places
  neg_prefix = neg_prefix or "-" -- default negative sign

  famount = math.abs(round(amount,decimal))
  famount = math.floor(famount)

  remain = round(math.abs(amount) - famount, decimal)

        -- comma to separate the thousands
  formatted = comma_value(famount)

        -- attach the decimal portion
  if (decimal > 0) then
    remain = string.sub(tostring(remain),3)
    formatted = formatted .. "." .. remain ..
                string.rep("0", decimal - string.len(remain))
  end

        -- attach prefix string e.g '$' 
  formatted = (prefix or "") .. formatted 

        -- if value is negative then format accordingly
  if (amount<0) then
    if (neg_prefix=="()") then
      formatted = "("..formatted ..")"
    else
      formatted = neg_prefix .. formatted 
    end
  end

  return formatted
end

function REBELLION.GetScaledWidth(width)
	return (width / REBELLION.DefaultWidth) * ScrW()
end

function REBELLION.GetScaledHeight(height)
	return (height / REBELLION.DefaultHeight) * ScrH()
end

function REBELLION.numberFormat(amount)
	local formatted = amount

	while true do

		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')

		if (k == 0) then

			break

		end

	end

	return formatted
end

R_F4_MATS = {}

R_F4_MATS.dashboardIcon = Material("r_images/icons/dashboard_icon.png", "noclamp smooth")
R_F4_MATS.jobsIcon = Material("r_images/icons/jobs_icon.png", "noclamp smooth")
R_F4_MATS.storeIcon = Material("r_images/icons/store_icon.png", "noclamp smooth")
R_F4_MATS.inventoryIcon = Material("r_images/icons/inventory_icon.png", "noclamp smooth")
R_F4_MATS.skillsIcon = Material("r_images/icons/skill_icon.png", "noclamp smooth")
R_F4_MATS.craftingIcon = Material("r_images/icons/crafting_icon.png", "noclamp smooth")

-- Sub tabs
R_F4_MATS.bankingIcon = Material("r_images/icons/bank_icon.png", "noclamp smooth")
-- R_F4_MATS.bankVaultIcon = Material("", "noclamp smooth")
-- R_F4_MATS.coinFlipIcon = Material("", "noclamp smooth")

R_CASES_ICONS = {}

R_CASES_ICONS.boosterCaseIcon = Material("r_images/cases/booster_case.png")
R_CASES_ICONS.moneyCaseIcon = Material("r_images/cases/money_case.png")
R_CASES_ICONS.weaponCaseIcon = Material("r_images/cases/weapon_case.png")

R_CASES = {}

R_CASES.moneyCaseItems = {{["type"] = "money", ["item"] = "1000"}, {["type"] = "money", ["item"] = "20000"}, {["type"] = "money", ["item"] = "75000"}, {["type"] = "money", ["item"] = "100000"}, {["type"] = "money", ["item"] = "1000000"}, {["type"] = "money", ["item"] = "4000000"}, {["type"] = "money", ["item"] = "8000000"}}
R_CASES.boosterCaseItems = {{["type"] = "ent", ["item"] = "uranium_printer"}, {["type"] = "ent", ["item"] = "theif_outfit"}, {["type"] = "ent", ["item"] = "tux_outfit"}, {["type"] = "money", ["item"] = "750000"}, {["type"] = "money", ["item"] = "1000000"}, {["type"] = "money", ["item"] = "2500000"}, {["type"] = "money", ["item"] = "5000000"}}
R_CASES.weaponCaseItems = {{["type"] = "weapon", ["item"] = "example_weapon"}}


LDRP_DLC = {}
LDRP_DLC.Find = file.Find(GM.FolderName .. "/gamemode/dlc/*.lua", "LUA")
LDRP_DLC.CL = {}
include("modules/von.lua")

for k,v in pairs(LDRP_DLC.Find) do
	local Ext = string.sub(v,1,3)
	local LoadAfter = (string.find(string.lower(v,"_loadafterdarkrp"),"_loadafterdarkrp") and "after") or "before"
	if Ext == "sh_" or Ext == "cl_" then
		LDRP_DLC.CL["dlc/" .. v] = LoadAfter
	elseif Ext != "sv_" then
		MsgN("One of your DLCs is using an invalid format!")
		MsgN("DLCs must start with either cl_ sv_ or sh_")
	end
end


for k,v in pairs(LDRP_DLC.CL) do
	if v == "before" then
		include(k)
		LDRP_DLC.CL[k] = nil
	end
end

local function MC(num)
	return math.Clamp(num,1,255)
end

local function LDRPColorMod(r,g,b,a)
	local Clrs = LDRP_Theme[LDRP_Theme.CurrentSkin].TradeMenu
	return Color(MC(Clrs.r+r),MC(Clrs.g+g),MC(Clrs.b+b),MC(Clrs.a+a))
end

local function IcoClrMod(r,g,b,a)
	local Clrs = LDRP_Theme[LDRP_Theme.CurrentSkin].IconBG
	return Color(MC(Clrs.r+r),MC(Clrs.g+g),MC(Clrs.b+b),MC(Clrs.a+a))
end

function CreateIcon(panel,model,sizex,sizey,mat,clr,clickfunc,campos,lookat) -- Liquid DarkRP CreateIcon
	local BG = vgui.Create("DPanel")
	if panel then BG:SetParent(panel) end
	BG:SetSize( sizex, sizey )
	local Pressed = false
	BG.Paint = function()
		local Clr = (Pressed and LDRPColorMod(50,50,50,-50)) or LDRPColorMod(30,30,30,-50)
		-- draw.RoundedBox(0,0,0,sizex,sizey,LDRPColorMod(-60,-60,-60,-20))
		draw.RoundedBox(6,0,0,sizex,sizey,Clr)

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawOutlinedRect(0, 0, sizex, sizey, 1)
	end
	
	local icon = vgui.Create( "DModelPanel", BG )
	icon:SetModel(model)

	if mat then

		icon.Entity:SetMaterial(mat)

	end

	if clr then

		icon:SetColor(clr)

	end

	icon:SetSize( sizex-8,sizey-8 )
	icon:SetPos(4,4)

	local iconmove = 0
	local Hovered = false
	function icon:LayoutEntity(Ent)
		if Hovered then
			iconmove = iconmove+1
			Ent:SetAngles( Angle( 0, iconmove,  0) )
		else
			if iconmove != 0 then iconmove = 0 end
			Ent:SetAngles( Angle( 0, 0, 0) )
		end
	end
	icon:SetCamPos( campos or Vector( 12, 12, 12 ) )
	icon:SetLookAt( lookat or Vector( 0, 0, 0 ) )
	
	local iconbutton = vgui.Create( "DButton", icon )
	iconbutton:SetSize(sizex,sizey)
	iconbutton:SetDrawBackground(false)
	iconbutton:SetText("")
	iconbutton.OnCursorEntered = function()
		Hovered = true
	end
	iconbutton.OnCursorExited = function()
		Hovered = false
		Pressed = false
	end
	iconbutton.OnMousePressed = function()
		Pressed = true
	end
	iconbutton.OnMouseReleased = function()
		Pressed = false
		clickfunc()
	end
	
	function BG:SetToolTip(str)
		iconbutton:SetToolTip(str)
	end
	
	return BG
end

include("client/help.lua")
include("liquiddrp/sh_liquiddrp.lua")

include("liquiddrp/cl_dermaskin.lua")
function GM:ForceDermaSkin()
	return "LiquidDRP2"
end

local function LoadLiquidDarkRP()
	include("liquiddrp/cl_trading.lua")
	include("liquiddrp/cl_stores.lua")
	include("liquiddrp/sh_chat.lua")
	include("liquiddrp/cl_hud.lua")
	
	include("liquiddrp/cl_crafting.lua")
	include("liquiddrp/cl_chat.lua")
	
	include("liquiddrp/cl_skills.lua")
end

CUR = "$"

HelpLabels = { }
HelpCategories = { }

/*---------------------------------------------------------------------------
Names
---------------------------------------------------------------------------*/
-- Make sure the client sees the RP name where they expect to see the name
local pmeta = FindMetaTable("Player")

pmeta.SteamName = pmeta.SteamName or pmeta.Name
function pmeta:Name()
	return GAMEMODE.Config.allowrpnames and self.DarkRPVars and self.DarkRPVars.rpname
		or self:SteamName()
end

pmeta.GetName = pmeta.Name
pmeta.Nick = pmeta.Name

function pmeta:getDarkRPVar(var)
	self.DarkRPVars = self.DarkRPVars or {}
	return self.DarkRPVars[var]
end

function pmeta:HasItem(name,am)

	if !LocalPlayer().Inventory then return false end

	local Check = LocalPlayer().Inventory[name] || 0

	return (Check >= (am || 1) && Check)

end

local ENT = FindMetaTable("Entity")
ENT.OldIsVehicle = ENT.IsVehicle

function ENT:IsVehicle()
	if type(self) ~= "Entity" then return false end
	local class = string.lower(self:GetClass())
	return ENT:OldIsVehicle() or string.find(class, "vehicle") 
	-- Ent:IsVehicle() doesn't work correctly clientside:
	--[[
		] lua_run_cl print(LocalPlayer():GetEyeTrace().Entity)
		> 		Entity [128][prop_vehicle_jeep_old]
		] lua_run_cl print(LocalPlayer():GetEyeTrace().Entity:IsVehicle())
		> 		false
	]]
end

function GM:DrawDeathNotice(x, y)
	if not GAMEMODE.Config.showdeaths then return end
	self.BaseClass:DrawDeathNotice(x, y)
end

local function DisplayNotify(msg)
	local txt = msg:ReadString()
	GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
	surface.PlaySound("buttons/lightswitch2.wav")

	-- Log to client console
	print(txt)
end
usermessage.Hook("_Notify", DisplayNotify)

local function LoadModules()
	local root = GM.FolderName.."/gamemode/modules/"

	local _, folders = file.Find(root.."*", "LUA")

	for _, folder in SortedPairs(folders, true) do
		if GM.Config.DisabledModules[folder] then continue end

		for _, File in SortedPairs(file.Find(root .. folder .."/sh_*.lua", "LUA"), true) do
			if File == "sh_interface.lua" then continue end
			include(root.. folder .. "/" ..File)
		end
		for _, File in SortedPairs(file.Find(root .. folder .."/cl_*.lua", "LUA"), true) do
			if File == "cl_interface.lua" then continue end
			include(root.. folder .. "/" ..File)
		end
	end
end

LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}

for k,v in pairs(player.GetAll()) do

	v.DarkRPVars = v.DarkRPVars or {}

end

GM.Config = {} -- config table

include("config.lua")
include("sh_interfaceloader.lua")
include("client/help.lua")

include("language_sh.lua")
include("MakeThings.lua")
include("cl_vgui.lua")
include("showteamtabs.lua")
include("menu_content_tabs.lua")
include("entity.lua")
include("sh_animations.lua")
include("cl_hud.lua")
include("Workarounds.lua")
include("shared/player_class.lua")
if UseFPP then
	include("FPP/sh_settings.lua")
	include("FPP/client/FPP_Menu.lua")
	include("FPP/client/FPP_HUD.lua")
	include("FPP/client/FPP_Buddies.lua")
	include("FPP/sh_CPPI.lua")
end
include("libraries/fn.lua")
LoadModules()

LoadLiquidDarkRP()

-- Copy from FESP(made by FPtje Falco)

-- This is no stealing since I made FESP myself.

local vector = FindMetaTable("Vector")

function vector:RPIsInSight(v, ply)

	ply = ply or LocalPlayer()

	local trace = {}

	trace.start = ply:EyePos()

	trace.endpos = self	

	trace.filter = v

	trace.mask = -1

	local TheTrace = util.TraceLine(trace)

	if TheTrace.Hit then

		return false, TheTrace.HitPos

	else

		return true, TheTrace.HitPos

	end
end

local DontDraw = {}

DontDraw["CHudHealth"] = true

DontDraw["CHudBattery"] = true

DontDraw["CHudSuitPower"] = true

function GM:HUDShouldDraw(name)
	
	if DontDraw[name] then return false
	
	else

		return true

	end


end

function GM:HUDDrawTargetID()

    return false

end

function FindPlayer(info)

	local pls = player.GetAll()

	-- Find by Index Number (status in console)

	for k, v in pairs(pls) do

		if tonumber(info) == v:UserID() then

			return v

		end

	end

	-- Find by RP Name

	for k, v in pairs(pls) do

		if string.find(string.lower(v.DarkRPVars.rpname or ""), string.lower(tostring(info))) ~= nil then
			
			return v

		end

	end

	-- Find by Partial Nick

	for k, v in pairs(pls) do

		if string.find(string.lower(v:Name()), string.lower(tostring(info))) ~= nil then
			
			return v

		
		end
	end

	return nil

end

local GUIToggled = false
local HelpToggled = false

local function ToggleClicker()
	RunConsoleCommand("-menu_context")
	GUIToggled = not GUIToggled
	gui.EnableScreenClicker(GUIToggled)
end
usermessage.Hook("ToggleClicker", ToggleClicker)
	
include("sh_commands.lua")

include("shared.lua")

include("addentities.lua")

include("ammotypes.lua")

if UseFadmin then
	-- DarkRP plugin for FAdmin. It's this simple to make a plugin. If FAdmin isn't installed, this code won't bother anyone
	include("fadmin_darkrp.lua")
	
	hook.Add("PostGamemodeLoaded", "FAdmin_DarkRP", function()

		if not FAdmin or not FAdmin.StartHooks then return end

		FAdmin.StartHooks["DarkRP"] = function()

			-- DarkRP information:

			FAdmin.ScoreBoard.Player:AddInformation("Steam name", function(ply) return ply:SteamName() end, true)
			
			FAdmin.ScoreBoard.Player:AddInformation("Money", function(ply) if LocalPlayer():IsAdmin() and ply.DarkRPVars and ply.DarkRPVars.money then return "$"..ply.DarkRPVars.money end end)
			
			FAdmin.ScoreBoard.Player:AddInformation("Wanted", function(ply) if ply.DarkRPVars and ply.DarkRPVars.wanted then return tostring(ply.DarkRPVars["wantedReason"] or "N/A") end end)
			
			FAdmin.ScoreBoard.Player:AddInformation("Community link", function(ply) return FAdmin.SteamToProfile(ply:SteamID()) end)

			-- Warrant

			FAdmin.ScoreBoard.Player:AddActionButton("Warrant", "FAdmin/icons/Message",	Color(0, 0, 200, 255),
				
				function(ply) local t = LocalPlayer():Team() return t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF end,
				
				function(ply, button)
					
					Derma_StringRequest("Warrant reason", "Enter the reason for the warrant", "", function(Reason)
						
						LocalPlayer():ConCommand("darkrp /warrant ".. ply:UserID().." ".. Reason)
					
					end)
				
				end)

			--wanted
			
			FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
					
					return ((ply.DarkRPVars.wanted and "Unw") or "W") .. "anted"
				
				end,
				
				function(ply) return "FAdmin/icons/jail", ply.DarkRPVars.wanted and "FAdmin/icons/disable" end,
				
				Color(0, 0, 200, 255),
				
				function(ply) local t = LocalPlayer():Team() return t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF end,
				
				function(ply, button)
				
					if not ply.DarkRPVars.wanted  then
				
						Derma_StringRequest("wanted reason", "Enter the reason to arrest this player", "", function(Reason)
				
							LocalPlayer():ConCommand("darkrp /wanted ".. ply:UserID().." ".. Reason)
				
						end)
				
					else
				
						LocalPlayer():ConCommand("darkrp /unwanted ".. ply:UserID())
				
					end
				
				end)

			--Teamban
			
			local function teamban(ply, button)

				local menu = DermaMenu()
				
				local Title = vgui.Create("DLabel")
				
				Title:SetText("  Jobs:\n")
				
				Title:SetFont("UiBold")
				
				Title:SizeToContents()
				
				Title:SetTextColor(color_black)
				
				local command = (button.TextLabel:GetText() == "Unban from job") and "rp_teamunban" or "rp_teamban"

				menu:AddPanel(Title)
				
				for k,v in SortedPairsByMemberValue(RPExtraTeams, "name") do
				
					menu:AddOption(v.name, function() RunConsoleCommand(command, ply:UserID(), k) end)
				
				end
				
				menu:Open()
			
			end
			
			FAdmin.ScoreBoard.Player:AddActionButton("Ban from job", "FAdmin/icons/changeteam", Color(200, 0, 0, 255),
			
			function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_commands", ply) end, teamban)

			FAdmin.ScoreBoard.Player:AddActionButton("Unban from job", function() return "FAdmin/icons/changeteam", "FAdmin/icons/disable" end, Color(200, 0, 0, 255),
			
			function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_commands", ply) end, teamban)
		
		end
	
	end)

end

local function DoSpecialEffects(Type)

	local thetype = string.lower(Type:ReadString())
	
	local toggle = tobool(Type:ReadString())
	
	if toggle then
		
		if thetype == "motionblur" then
			
			hook.Add("RenderScreenspaceEffects", thetype, function()
				
				DrawMotionBlur(0.05, 1.00, 0.035)
			
			end)
		
		elseif thetype == "dof" then
			
			DOF_SPACING = 8
			
			DOF_OFFSET = 9
			
			DOF_Start()
		
		elseif thetype == "colormod" then
			
			hook.Add("RenderScreenspaceEffects", thetype, function()
				
				local settings = {}
				
				settings[ "$pp_colour_addr" ] = 0
			 	
			 	settings[ "$pp_colour_addg" ] = 0 
			 	
			 	settings[ "$pp_colour_addb" ] = 0 
			 	
			 	settings[ "$pp_colour_brightness" ] = -1
			 	
			 	settings[ "$pp_colour_contrast" ] = 0
			 	
			 	settings[ "$pp_colour_colour" ] =0
			 	
			 	settings[ "$pp_colour_mulr" ] = 0
			 	
			 	settings[ "$pp_colour_mulg" ] = 0
			 	
			 	settings[ "$pp_colour_mulb" ] = 0
				
				DrawColorModify(settings)
			
			end)
		
		elseif thetype == "drugged" then
			
			hook.Add("RenderScreenspaceEffects", thetype, function()
				
				DrawSharpen(-1, 2)
				
				DrawMaterialOverlay("models/props_lab/Tank_Glass001", 0)
				
				DrawMotionBlur(0.13, 1, 0.00)
			
			end)
		
		elseif thetype == "deathpov" then
			
			hook.Add("CalcView", "rp_deathPOV", function(ply, origin, angles, fov)
				
				local Ragdoll = ply:GetRagdollEntity()
				
				if not IsValid(Ragdoll) then return end
				
				local head = Ragdoll:LookupAttachment("eyes")
				
				head = Ragdoll:GetAttachment(head)
				
				if not head or not head.Pos then return end

				local view = {}
				
				view.origin = head.Pos
				
				view.angles = head.Ang
				
				view.fov = fov
				
				return view
			
			end)
		
		end
	
	elseif toggle == false then
	
		if thetype == "dof" then
	
			DOF_Kill()
	
			return
	
		elseif thetype == "deathpov" then
	
			if hook.GetTable().CalcView and hook.GetTable().CalcView.rp_deathPOV then 
	
				hook.Remove("CalcView", "rp_deathPOV")
	
			end
	
			return
	
		end
	
		hook.Remove("RenderScreenspaceEffects", thetype)
	
	end

end

usermessage.Hook("DarkRPEffects", DoSpecialEffects)

-- Chat

local Messagemode = false

local playercolors = {}

local HearMode = "talk"

local isSpeaking = false

local function RPStopMessageMode()
	
	Messagemode = false
	
	hook.Remove("Think", "RPGetRecipients")
	
	hook.Remove("HUDPaint", "RPinstructionsOnSayColors")
	
	playercolors = {}

end

local function CL_IsInRoom(listener) -- IsInRoom function to see if the player is in the same room.
	
	local tracedata = {}
	
	tracedata.start = LocalPlayer():GetShootPos()
	
	tracedata.endpos = listener:GetShootPos()
	
	local trace = util.TraceLine( tracedata )
		
	return not trace.HitWorld

end

local PlayerColorsOn = CreateClientConVar("rp_showchatcolors", 1, true, false)

local function RPSelectwhohearit()
	
	if PlayerColorsOn:GetInt() == 0 then return end
	
	Messagemode = true
	
	hook.Add("HUDPaint", "RPinstructionsOnSayColors", function()
	
		local w, l = ScrW()/80, ScrH() /1.75
	
		local h = l - (#playercolors * 20) - 20
	
		local AllTalk = GAMEMODE.Config.alltalk
	
		if #playercolors <= 0 and ((HearMode ~= "talk through OOC" and HearMode ~= "advert" and not AllTalk) or (AllTalk and HearMode ~= "talk" and HearMode ~= "me") or HearMode == "speak" ) then
	
			draw.WordBox(2, w, h, string.format(LANGUAGE.hear_noone, HearMode), "ScoreboardText", Color(0,0,0,120), Color(255,0,0,255))
	
		elseif HearMode == "talk through OOC" or HearMode == "advert" then
	
			draw.WordBox(2, w, h, LANGUAGE.hear_everyone, "ScoreboardText", Color(0,0,0,120), Color(0,255,0,255))
	
		elseif not AllTalk or (AllTalk and HearMode ~= "talk" and HearMode ~= "me") then
	
			draw.WordBox(2, w, h, string.format(LANGUAGE.hear_certain_persons, HearMode), "ScoreboardText", Color(0,0,0,120), Color(0,255,0,255))
	
		end
		
		for k,v in pairs(playercolors) do
	
			if v.Nick then
	
				draw.WordBox(2, w, h + k*20, v:Nick(), "ScoreboardText", Color(0,0,0,120), Color(255,255,255,255))
	
			end
	
		end
	
	end)
	
	hook.Add("Think", "RPGetRecipients", function() 
	
		if not Messagemode then RPStopMessageMode() hook.Remove("Think", "RPGetRecipients") return end 
	
		if HearMode ~= "whisper" and HearMode ~= "yell" and HearMode ~= "talk" and HearMode ~= "speak" and HearMode ~= "me" then return end
	
		playercolors = {}
	
		for k,v in pairs(player.GetAll()) do
	
			if v ~= LocalPlayer() then
	
				local distance = LocalPlayer():GetPos():Distance(v:GetPos())
	
				if HearMode == "whisper" and distance < 90 and not table.HasValue(playercolors, v) then
	
					table.insert(playercolors, v)
	
				elseif HearMode == "yell" and distance < 550 and not table.HasValue(playercolors, v) then
	
					table.insert(playercolors, v)
	
				elseif HearMode == "speak" and distance < 550 and not table.HasValue(playercolors, v) then
	
					if GAMEMODE.Config.dynamicvoice then
	
						if CL_IsInRoom( v ) then
	
							table.insert(playercolors, v)
	
						end
	
					else
	
						table.insert(playercolors, v)
	
					end
	
				elseif HearMode == "talk" and not GAMEMODE.Config.alltalk and distance < 250 and not table.HasValue(playercolors, v) then
	
					table.insert(playercolors, v)
	
				elseif HearMode == "me" and not GAMEMODE.Config.alltalk and distance < 250 and not table.HasValue(playercolors, v) then
	
					table.insert(playercolors, v)
	
				end
	
			end
	
		end
	
	end)

end

hook.Add("StartChat", "RPDoSomethingWithChat", RPSelectwhohearit)

hook.Add("FinishChat", "RPCloseRadiusDetection", function() 

	if not isSpeaking then 

		Messagemode = false

		RPStopMessageMode() 

	else

		HearMode = "speak" 

	end

end)

function GM:ChatTextChanged(text)
	
	if PlayerColorsOn:GetInt() == 0 then return end
	
	if not Messagemode or HearMode == "speak" then return end
	
	local old = HearMode
	
	HearMode = "talk"
	
	if not GAMEMODE.Config.alltalk then
	
		if string.sub(text, 1, 2) == "//" or string.sub(string.lower(text), 1, 4) == "/ooc" or string.sub(string.lower(text), 1, 4) == "/a" then
	
			HearMode = "talk through OOC"
	
		elseif string.sub(string.lower(text), 1, 7) == "/advert" then
	
			HearMode = "advert"
	
		end
	
	end
	
	if string.sub(string.lower(text), 1, 3) == "/pm" then
	
		local plyname = string.sub(text, 5)
	
		if string.find(plyname, " ") then
	
			plyname = string.sub(plyname, 1, string.find(plyname, " ") - 1)
	

		end
	
		HearMode = "pm"
	
		playercolors = {}
	

		if plyname ~= "" and FindPlayer(plyname) then
	
			playercolors = {FindPlayer(plyname)}
	
		end
	
	elseif string.sub(string.lower(text), 1, 3) == "/g " then
	
		HearMode = "group chat"
	
		local t = LocalPlayer():Team()
	
		playercolors = {}
	
		if t == TEAM_POLICE or t == TEAM_CHIEF or t == TEAM_MAYOR then
	
			for k, v in pairs(player.GetAll()) do
	
				if v ~= LocalPlayer() then
	
					local vt = v:Team()
	
					if vt == TEAM_POLICE or vt == TEAM_CHIEF or vt == TEAM_MAYOR then table.insert(playercolors, v) end
	
				end
	
			end
	
		elseif t == TEAM_MOB or t == TEAM_GANG then
	
			for k, v in pairs(player.GetAll()) do
	
				if v ~= LocalPlayer() then
	
					local vt = v:Team()
	
					if vt == TEAM_MOB or vt == TEAM_GANG then table.insert(playercolors, v) end
	
				end
	
			end
	
		end
	
	elseif string.sub(string.lower(text), 1, 3) == "/w " then
	
		HearMode = "whisper"
	
	elseif string.sub(string.lower(text), 1, 2) == "/y" then
	
		HearMode = "yell"
	
	elseif string.sub(string.lower(text), 1, 3) == "/me" then
	
		HearMode = "me"
	
	end
	
	if old ~= HearMode then
	
		playercolors = {}
	
	end

end

function GM:PlayerStartVoice(ply)
	
	if ply == LocalPlayer() and LocalPlayer().DarkRPVars and IsValid(LocalPlayer().DarkRPVars.phone) then
	
		return
	
	end
	
	isSpeaking = true
	
	LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
	
	if ply == LocalPlayer() and LocalPlayer().DarkRPVars and not GAMEMODE.Config.sv_alltalk and GAMEMODE.Config.voiceradius and not IsValid(LocalPlayer().DarkRPVars.phone) then
	
		HearMode = "speak"
	
		RPSelectwhohearit()
	
	end
	

	
	if ply == LocalPlayer() then
	
		ply.DRPIsTalking = true
	
		return -- Not the original rectangle for yourself! ugh!
	
	end
	
	self.BaseClass:PlayerStartVoice(ply)

end

function GM:PlayerEndVoice(ply) //voice/icntlk_pl.vtf

	if LocalPlayer().DarkRPVars and IsValid(LocalPlayer().DarkRPVars.phone) then

		ply.DRPIsTalking = false

		timer.Simple(0.2, function() 

			if IsValid(LocalPlayer().DarkRPVars.phone) then

				LocalPlayer():ConCommand("+voicerecord") 

			end

		end)

		self.BaseClass:PlayerEndVoice(ply)

		return

	end

	isSpeaking = false

	if ply == LocalPlayer() and not GAMEMODE.Config.sv_alltalk and GAMEMODE.Config.voiceradius then

		HearMode = "talk"

		hook.Remove("Think", "RPGetRecipients")

		hook.Remove("HUDPaint", "RPinstructionsOnSayColors")

		Messagemode = false

		playercolors = {}

	end

	if ply == LocalPlayer() then

		ply.DRPIsTalking = false

		return

	end	

	self.BaseClass:PlayerEndVoice(ply)

end

--[[function GM:PlayerBindPress(ply,bind,pressed)
	self.BaseClass:PlayerBindPress(ply, bind, pressed)
	if ply == LocalPlayer() and IsValid(ply:GetActiveWeapon()) and string.find(string.lower(bind), "attack2") and ply:GetActiveWeapon():GetClass() == "weapon_bugbait" then
		LocalPlayer():ConCommand("_hobo_emitsound")
	end
	return
end]]

local function RetrieveDoorData(length)

	--First: Entity you were looking at
	--Second: Table of that door
	
	local targetEnt = net.ReadEntity()
	
	local doorTable = net.ReadTable()
	
	if not targetEnt or not targetEnt.IsValid or not IsValid(targetEnt) then return end
	
	targetEnt.DoorData = doorTable
	
	local DoorString = "Data:\n"
	
	for k,v in pairs(doorTable) do
	
		DoorString = DoorString .. k.."\t\t".. tostring(v) .. "\n"
	

	end
end

net.Receive("DarkRP_DoorData", RetrieveDoorData)

local function UpdateDoorData(um)
	
	local door = um:ReadEntity()
	
	if not IsValid(door) then return end
	
	local var, value = um:ReadString(), um:ReadString()
	
	value = tonumber(value) or value
	
	if string.match(tostring(value), "Entity .([0-9]*)") then
	
		value = Entity(string.match(value, "Entity .([0-9]*)"))
	
	end
	
	if string.match(tostring(value), "Player .([0-9]*)") then
	
		value = Entity(string.match(value, "Player .([0-9]*)"))
	
	end
	
	if value == "true" or value == "false" then value = tobool(value) end
	
	if value == "nil" then value = nil end
	
	door.DoorData[var] = value

end

usermessage.Hook("DRP_UpdateDoorData", UpdateDoorData)

local function RetrievePlayerVar(entIndex, var, value, tries)
	
	local ply = Entity(entIndex)

	-- Usermessages _can_ arrive before the player is valid.
	
	-- In this case, chances are huge that this player will become valid.
	
	if not IsValid(ply) then
	
		if tries >= 5 then return end

		timer.Simple(0.5, function() RetrievePlayerVar(entIndex, var, value, tries + 1) end)
	
		return
	
	end

	ply.DarkRPVars = ply.DarkRPVars or {}

	local stringvalue = value
	
	value = tonumber(value) or value

	if string.match(stringvalue, "Entity .([0-9]*)") then
	
		value = Entity(string.match(stringvalue, "Entity .([0-9]*)"))
	
	end

	if string.match(stringvalue, "^Player .([0-9]+).") then
	
		value = player.GetAll()[tonumber(string.match(stringvalue, "^Player .([0-9]+)."))]
	
	end

	if stringvalue == "NULL" then
	
		value = NULL
	
	end

	if string.match(stringvalue, [[(-?[0-9]+.[0-9]+) (-?[0-9]+.[0-9]+) (-?[0-9]+.[0-9]+)]]) then
	
		local x,y,z = string.match(value, [[(-?[0-9]+.[0-9]+) (-?[0-9]+.[0-9]+) (-?[0-9]+.[0-9]+)]])
	
		value = Vector(x,y,z)
	
	end

	if stringvalue == "true" or stringvalue == "false" then value = tobool(value) end

	if stringvalue == "nil" then value = nil end

	hook.Call("DarkRPVarChanged", nil, ply, var, ply.DarkRPVars[var], value)
	
	ply.DarkRPVars[var] = value

end

/*---------------------------------------------------------------------------
Retrieve a player var.
Read the usermessage and attempt to set the DarkRP var
---------------------------------------------------------------------------*/

local function doRetrieve(um)

	local entIndex = um:ReadShort()

	local var, value = um:ReadString(), um:ReadString()

	RetrievePlayerVar(entIndex, var, value, 0)

end

usermessage.Hook("DarkRP_PlayerVar", doRetrieve)

local function InitializeDarkRPVars(len)

	local vars = net.ReadTable()

	if not vars then return end

	for k,v in pairs(vars) do

		if not IsValid(k) then continue end

		k.DarkRPVars = k.DarkRPVars or {}

		-- Merge the tables

		for a, b in pairs(v) do

			k.DarkRPVars[a] = b

		end

	end

end

net.Receive("DarkRP_InitializeVars", InitializeDarkRPVars)
	
function GM:InitPostEntity()
	g_VoicePanelList = vgui.Create( "DPanel" )

    g_VoicePanelList:ParentToHUD()

    g_VoicePanelList:SetPos( ScrW() - 275, 25 )

    g_VoicePanelList:SetSize( 250, ScrH() - 200 )

    g_VoicePanelList:SetDrawBackground( false )

	g_VoicePanelList:SetName("VoicePanelList")
	
	function VoiceNotify:Init()

		self.LabelName = vgui.Create( "DLabel", self )

		self.LabelName:SetFont( LDRP_Theme[LDRP_Theme.CurrentSkin].FontFrame )

		self.LabelName:SetTextColor( LDRP_Theme[LDRP_Theme.CurrentSkin].Txt )

		self.LabelName:SetContentAlignment( 5 )

		self.LabelName:Dock( FILL )

		self.LabelName:DockMargin( 8, 0, 0, 0 )
		
		function self.LabelName:Paint( w, h )

			draw.RoundedBoxEx( 2, 0, 0, w, h, LDRP_Theme[LDRP_Theme.CurrentSkin].BGColor, false, true, true, true )

		end
		
		self.Avatar = vgui.Create( "SpawnIcon", self )

		self.Avatar:SetSize(32, 32)

		self.Avatar:Dock( LEFT );

		

		self:SetSize( 250, 32 + 8 )

		self:DockPadding( 4, 4, 4, 4 )

		self:DockMargin( 2, 2, 2, 2 )

		self:Dock( TOP )

	end
	
	function VoiceNotify:Setup(ply)

		self.ply = ply

		self.LabelName:SetText( ply:Nick() )

		self.Avatar:SetModel( ply:GetModel() )

		self.Color = team.GetColor( ply:Team() )
		
		self:InvalidateLayout()

	end
	
	function VoiceNotify:Paint( w, h )

		if ( !IsValid( self.ply ) ) then return end

		local dcolor = team.GetColor( self.ply:Team() )

		dcolor.a = (self.ply:VoiceVolume() * 155) + 100 --Have a floor of 100

		draw.RoundedBox( 4, 0, 0, w, h, dcolor )

	end
	
	RunConsoleCommand("_sendDarkRPvars")

	timer.Create("DarkRPCheckifitcamethrough", 15, 0, function()

		for k,v in pairs(player.GetAll()) do

			if v.DarkRPVars and v:getDarkRPVar("rpname") then continue end
			

			RunConsoleCommand("_sendDarkRPvars")

			return

		end

	end)

end

local LDRP = {}

function LDRP.InitClient()

	timer.Simple(1, function() 
		
		LocalPlayer().Inventory = {}

		LocalPlayer().NewItemsLog = {}

		LocalPlayer().Skills = {}

		LocalPlayer().Bank = {}

		LocalPlayer().InterestRate = {}

		print("Client has initialized")

		RunConsoleCommand("_initme")

	end)
end

hook.Add("InitPostEntity", "LoadCharacter", LDRP.InitClient)

function loadInterstData()

  LocalPlayer().InterestRate = net.ReadTable()
  
end

net.Receive("sendBankInterestRateInfo", loadInterstData)

function REBELLION.CalculateMaxInventoryWeight()

	if LocalPlayer().Skills and LocalPlayer().Skills["Stamina"] then

		maxweight = math.Clamp((tonumber(LocalPlayer().Skills["Stamina"].lvl or 1) * 5) + 20, 25, 70)

	else

		maxweight = 25

	end

	if LocalPlayer():HasItem("inventory weight upgrade") then maxweight = (maxweight + LDRP_SH.InventoryWeightUpgradeAmount) end

	if LocalPlayer().DarkRPVars.Boosters then maxweight = (maxweight + (5 * (LocalPlayer().DarkRPVars.Boosters or 0))) end

	return maxweight

end

function GM:FindPlayer(info)

	if not info or info == "" then return nil end

	local pls = player.GetAll() -- Get every player connected

	for k = 1, #pls do

		local v = pls[k]

		if tonumber(info) == v:UserID() then

			return v

		end

		if info == v:SteamID() then

			return v

		end

		if string.find(string.lower(v:SteamName()), string.lower(tostring(info)), 1, true) ~= nil then

			return v

		end

	end

	return nil

end

local ConnectMessages = {
	"%s just joined the server",

	"%s just joined. Everyone hide!",

	"Welcome, %s. Good luck, your need it.",

	"Guess who's here!! Yep you guess it, %s arrived!",

	"Welcome, %s. You know what we do here right?",

	"Welcome, %s. Ready to obliterate everyone?"
}

local WelcomeBackMessages = {
	"%s where have you been? We've missed you.",

	"Welcome back, %s. You look stronger... oh no.",

	"Oh look who decided to return....%s everyone.",

	"Snap, %s's back. You got that money you owe me?"
}

CreateClientConVar( "rebbelion_joinmessages", "1", true, true )
CreateClientConVar( "rebbelion_joinmessages2", "2", true, true )

local lastKnownName

gameevent.Listen( "player_connect_client" )

hook.Add("player_connect_client", "AnnouceJoin", function( data )

	local name = data.name or "New Player"

	print(name, lastKnownName)

	if lastKnownName && (name == lastKnownName) then 

		if GetConVar("rebbelion_joinmessages2") and GetConVar("rebbelion_joinmessages2"):GetBool() then
		
			chat.AddText(unpack({Color(51, 255, 102), "Player joined ", Color(255, 255, 255), string.format(table.Random(WelcomeBackMessages), name)}))

		end

		return

	end

	lastKnownName = name

	if GetConVar("rebbelion_joinmessages") and GetConVar("rebbelion_joinmessages"):GetBool() then
		
		chat.AddText(unpack({Color(51, 255, 102), "Player joined ", Color(255, 255, 255), string.format(table.Random(ConnectMessages), name)}))

	end

end)

local function TimeToString(time)

	local d = math.floor(time/86400)

	local days = (d < 10 and '0' or '')..d



	local h = math.floor((time-d*86400)/3600)

	local hours = (h < 10 and '0' or '')..h



	local m = math.floor((time-(d*86400+h*3600))/60)

	local mins = (m < 10 and '0' or '')..m



	local s = time-(d*86400+h*3600+m*60)

	local seconds = (s < 10 and '0' or '')..s



	local time_str = days..':'..hours..':'..mins..':'..seconds



	return time_str

end

for k,v in pairs(LDRP_DLC.CL) do

	include(k)

end