local LDRP = {}
local table = table
local timer = timer
local string = string
local draw = draw

function LDRP.PrinterUpgrade()
	local ent = LocalPlayer():GetEyeTrace().Entity
	if ent and ent:IsValid() and ent:GetClass() == "money_printer" and ent.dt.owning_ent and ent.dt.owning_ent == LocalPlayer() and LocalPlayer():GetPos():Distance(ent:GetPos()) <= 300 then
		local Upgrade = ent:GetNWString("Upgrade")
		if !Upgrade or Upgrade == "" then return end
		local typ = LDRP_SH.PrOrder[Upgrade]+1
		if typ <= LDRP_SH.last then
			local pos = (ent:GetPos()+Vector(0,0,20)):ToScreen()
			local name = table.KeyFromValue(LDRP_SH.PrOrder, typ)
			draw.SimpleTextOutlined( "Type '/upgrade' to upgrade to " .. name .. " ($" .. LDRP_SH.Printers[name].cost .. ")", "Trebuchet20", pos.x, pos.y, Color(0,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.5, Color(0,0,100) )
		end
	end
end
hook.Add("HUDPaint","Shows you can upgrade",LDRP.PrinterUpgrade)

function LDRP.LiquidChat(um)
	local nam = um:ReadString()
	local vcol = um:ReadVector()
	local col = Color(vcol.x,vcol.y,vcol.z)
	local msg = um:ReadString()
	
	chat.AddText(unpack({col,"[" .. nam .. "] ",Color(255,255,255),msg}))
	chat.PlaySound()
end
usermessage.Hook("LiquidChat", LDRP.LiquidChat)

local function MC(a) return math.Clamp(a,0,255) end
local function LDRPColorMod(r,g,b,a)
	local Clrs = LDRP_Theme[LDRP_Theme.CurrentSkin].BGColor
	return Color(MC(Clrs.r+r),MC(Clrs.g+g),MC(Clrs.b+b),MC(Clrs.a+a))
end

function LDRP_SH.OpenNPCWindow(name,mdl,says,sayings)
	local w = 500
	local h = 200
	
	local NPCWindow = vgui.Create("DFrame")
	NPCWindow:SetSize(w,h)
	NPCWindow:SetTitle("")
	NPCWindow:SetPos(ScrW()*.5-(w*.5),ScrH()-h-80)
	NPCWindow:MakePopup()
	NPCWindow.Paint = function()
		draw.RoundedBox(6,0,0,w,h,LDRPColorMod(0,0,0,0))
		draw.RoundedBox(6,0,0,w,h*.16,LDRPColorMod(10,10,10,20))
		draw.RoundedBox(6,w*.01,h*.18,w*.145,h*.36,LDRPColorMod(27,27,27,30))
		
		draw.RoundedBox(6,w*.165,h*.18,w*.825,h*.36,LDRPColorMod(27,27,27,30))
		draw.SimpleTextOutlined(says,"Trebuchet22",w*.5775,h*.36,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
		draw.SimpleTextOutlined(name,"Trebuchet24",w*.5,h*.08,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
	end
	
	local NPCIcon = vgui.Create("SpawnIcon",NPCWindow)
	NPCIcon:SetPos(10,40)
	NPCIcon:SetModel(mdl)

	local SayingList = vgui.Create("DPanelList",NPCWindow)
	SayingList:SetPos(w*.01,h*.56)
	SayingList:SetSize(w*.98,h*.42)
	SayingList.Paint = function()
		draw.RoundedBox(6,0,0,w*.98,h*.42,LDRPColorMod(27,27,27,30))
	end
	SayingList:SetPadding(4)
	SayingList:SetSpacing(4)
	SayingList:EnableVerticalScrollbar(true)
	SayingList:EnableHorizontal(true)
	
	for k,v in pairs(sayings) do
		local SayingButton = vgui.Create("DButton",SayingList)
		SayingButton:SetText("")
		SayingButton.DoClick = function()
			NPCWindow:Close()
			if string.sub(tostring(v),1,8) == "function" then
				v()
			else
				LDRP_SH.OpenNPCWindow(name,mdl,says,v)
			end
		end
		SayingButton:SetSize(w*.97-4,h*.13)
		SayingButton.Paint = function()
			draw.RoundedBox(6,0,0,w*.97-4,h*.13,LDRPColorMod(-27,-27,-27,-10))
			draw.SimpleTextOutlined(k,"Trebuchet20",(w*.97-4)*.5,(h*.13)*.5,Color(200,200,200,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
		end
		
		SayingList:AddItem(SayingButton)
	end

end

-- ACTUAL HUD

local DisplayWhat = {["Cash"] = "money"}
local HideWhat = {["Job"] = "job",["Salary"] = "salary"}
local HideShowAm = 0
local CurHeight = 0

LDRP.Currently = "closed"
function LDRP.MoreInfoToggle()
	local Check = LDRP.Currently
	if Check == "closed" then
		LDRP.Currently = "opening"
	else
		LDRP.Currently = "closing"
	end

	if !timer.Exists("ReSizeInfoWindow") then
		timer.Create("ReSizeInfoWindow", .001, 0, function()
			local ReCheck = LDRP.Currently
			local CheckCount = table.Count(HideWhat)*(ScrH()*.02)
			if CurHeight >= CheckCount and ReCheck == "opening" then
				LDRP.Currently = "opened"
				timer.Remove("ReSizeInfoWindow")
				return
			elseif CurHeight <= 0 and ReCheck == "closing" then
				LDRP.Currently = "closed"
				timer.Remove("ReSizeInfoWindow")
				return
			end
			
			if ReCheck == "closing" then
				CurHeight = CurHeight-ScrH()*.004
			else
				CurHeight = CurHeight+ScrH()*.004
			end
			
		end)
	end
end

LDRP.ToZeroAndBack = {[0] = 1,[1] = 0}
function LDRP.ToggleCMD(cmd)
	RunConsoleCommand(cmd,LDRP.ToZeroAndBack[GetConVarNumber(cmd)])
end

CreateConVar("cl_showhp",1)
CreateConVar("cl_showammo",1)
CreateConVar("cl_playercard",1)
CreateConVar("cl_npcnames",1)

local NiceHP = 0
local OptionsButton
local JustJoined = true

function LDRP.HUDInit()
	timer.Simple(5, function()
		LocalPlayer().OPos = LocalPlayer():GetPos()
		timer.Create("CheckIfMoved", 2, 0, function()
			if LocalPlayer().OPos != LocalPlayer():GetPos() then
				timer.Remove("CheckIfMoved")
				JustJoined = false
				LocalPlayer().OPos = nil
			end
		end)
	end)
end
hook.Add("InitPostEntity","Loads HUD",LDRP.HUDInit)

function LDRP.HUDPaint()
	SKIN = derma.GetDefaultSkin() -- For some reason the SKIN table is not the default skin.
	local LP = LocalPlayer()
	if LP.InTut then return end
	if !LP.DarkRPVars then
		draw.SimpleTextOutlined( "Waiting for DarkRP information...","HUDNumber", ScrW()*.5, ScrH()*.5, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
		return
	end
	
	-- HP/Ammo Bars
	local LH = LP:Health()
	
	local ShowHP = GetConVarNumber("cl_showhp")
	local ShowPC = GetConVarNumber("cl_playercard")
	
	local MeterW = 244.8
	if ShowHP == 1 then
		local Pos1 = 162
		if ShowPC != 1 then
			Pos1 = 4.32
		end
		if NiceHP > LH then
			NiceHP = NiceHP-1
		elseif NiceHP < LH then
			NiceHP = NiceHP+1
		end
		local HPPercent = math.Clamp(NiceHP/100,.03,1)
		draw.RoundedBox(6,Pos1,2.7,252,22.5, SKIN.bg_color_dark)
		draw.RoundedBox(6,Pos1+3.6,4.95,(HPPercent*MeterW),18, HSVToColor( 360 - (125 * -HPPercent), 1, 1 ) ) --Never thought I'd use this function
		draw.SimpleTextOutlined( "Health: " .. LH, "Trebuchet18", Pos1+126, 13.95, SKIN.tooltip, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, SKIN.text_outline )
	end
	
	if GetConVarNumber("cl_showammo") == 1 then
		local Pos1,Pos2,Pos3,Pos4 = 27.9, 30.15, 162, 38.7
		if ShowHP != 1 then
			Pos1,Pos2,Pos4 = 2.7, 4.95, 13.95
		end
		if ShowPC != 1 then
			Pos3 = 4.32
		end
		local Wep = LP:GetActiveWeapon()
		local PrimaryAmmo = (Wep and Wep:IsValid() and Wep:Clip1()) or 0
		local SecondaryAmmo = (Wep and Wep:IsValid() and LP:GetAmmoCount(Wep:GetPrimaryAmmoType())) or 0
		draw.RoundedBox(6,Pos3,Pos1,252,22.5, SKIN.bg_color_dark )
		draw.RoundedBox(6,Pos3+3.6,Pos2,MeterW,18, SKIN.tooltip)
		local AmmoStr = (PrimaryAmmo < 0 and "Unlimited") or (PrimaryAmmo == 0 and SecondaryAmmo == 0 and "Empty") or(PrimaryAmmo .. "/" .. SecondaryAmmo)
		draw.SimpleTextOutlined( "Ammo: " .. AmmoStr, "Trebuchet18", Pos3+126, Pos4, SKIN.tooltip, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, SKIN.text_outline )
	end
	
	if ShowPC == 1 then
		draw.RoundedBox(6,4.32,2.7,155.52,63+CurHeight, SKIN.colPropertySheet )
		draw.RoundedBox(6,10.08,6.3,144,55.8+CurHeight, SKIN.tooltip )
		local name = LP:GetName()
		if string.len(name) > 12 then name = string.sub(name,1,12) end
		
		draw.SimpleTextOutlined( name, "Trebuchet24",  82.08, 16.08, SKIN.tooltip, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, SKIN.text_outline )
		
		draw.RoundedBox(6,10.08,28.8,144,35.1+CurHeight, SKIN.colTab)
		
		local CurY = 40.5
		for k,v in pairs(DisplayWhat) do
			local display = LP:getDarkRPVar( v ) or "Loading"
			
			local MoneyCheck = tonumber(display)
			local Clr = Color(0,255,0,255)
			if MoneyCheck then
				if MoneyCheck >= 1000000 then
					MoneyCheck = math.Round(MoneyCheck/1000000,2) .. "M"
					Clr = Color(255,255,0,255)
				elseif MoneyCheck >= 100000 then
					MoneyCheck = math.Round(MoneyCheck/1000,2) .. "K"
					Clr = Color(255,255,255,255)
				end
				display = "$" .. MoneyCheck
			end
			draw.SimpleTextOutlined( k .. ": " .. display, "Trebuchet22", 79.2, CurY, Clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255) )
			CurY = CurY+18
		end
		

		if LDRP.Currently == "opened" then
			for k,v in pairs(HideWhat) do
				local display = LP.DarkRPVars[v] or "Loading"

				if string.len(display) >= 11 then display = string.sub(display, 1, 11) .. "..." end
				if k == "Salary" and LP:IsVIP() then display = math.Round(display*1.5) end
				
				draw.SimpleTextOutlined( k .. ": " .. display, "Trebuchet20", 79.2, CurY, Clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255) )
				CurY = CurY+18
			end
		end
	end
end
hook.Add("HUDPaint","Liquid DarkRP's HUD",LDRP.HUDPaint)

function LDRP.NPCNames()
	if GetConVarNumber("cl_npcnames") == 1 then
		local LP = LocalPlayer()
		local LPos = LP:GetPos()
		local LPAng = LP:EyeAngles()
		
		for k,v in pairs(ents.FindByClass("shop_base")) do
			local p = v:GetPos()
			if LPos:Distance(p) < 600 then
				cam.Start3D2D( p+Vector(0,0,80), Angle(0, LPAng.y-90, 90), .3 )
					draw.SimpleText( LDRP_SH.ModelToName[v:GetModel()], "Trebuchet24", 0, 0, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				cam.End3D2D()
			end
		end
		local Table = ents.FindByClass("crafting_table")[1]
		local p = Table and Table:GetPos()
		if p and p:Distance(LPos) < 800 then
			cam.Start3D2D( p+Vector(0,0,60), Angle(0, LPAng.y-90, 90), .3 )
				draw.SimpleText( "Crafting Table", "Trebuchet22", 0, 0, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( "(buy a hammer from miner, hit this)", "Trebuchet18", 0, 15, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			cam.End3D2D()
		end
	end
end
hook.Add("PostDrawOpaqueRenderables","Draws NPC Names",LDRP.NPCNames)

LDRP.BlockHUD = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}
hook.Add("HUDShouldDraw", "Hides the old HUD", function(c)
	return !table.HasValue(LDRP.BlockHUD,c)
end)

if LDRP_SH.ReplaceSkybox then
	local mat = {} -- Material shit made by Jackool (never released, was gonna but didn't)
	mat.CurSky = GetConVar("sv_skyname"):GetString()
	mat.SkyNames  = {"lf","ft","rt","bk","dn","up"}
	mat.CurrentMats = {}
	for k,v in pairs(mat.SkyNames) do
		mat.CurrentMats[#mat.CurrentMats+1] = Material("skybox/" .. mat.CurSky .. v)
	end
	 
	function mat.ReplaceSkybox(new)
		for k,v in pairs(mat.SkyNames) do
			local D = Material("skybox/".. new .. v):GetTexture("$basetexture")
			mat.CurrentMats[k]:SetTexture("$basetexture",D)
		end
	end

	mat.ReplaceSkybox(LDRP_SH.SkyMat)
end

LDRP.MeterLength = 350

LDRP.MeterLengthHalf = LDRP.MeterLength/2
LDRP.MeterHeight = LDRP.MeterLength*.17

function LDRP.CreateMeterHUD(text,time)
	local MeterStart = CurTime()
	local function MeterHUDLocal()
		draw.RoundedBox( 8, ScrW()*.5-LDRP.MeterLengthHalf, 10, LDRP.MeterLength, LDRP.MeterHeight, Color( 9, 120, 245, 200 ) )
		draw.RoundedBox( 8, ScrW()*.5-LDRP.MeterLengthHalf+4, 14, (LDRP.MeterLength-8)*math.Clamp(((CurTime()-MeterStart)/time),.04,1), LDRP.MeterHeight-8, Color( 9, 170, 245, 180 ) )
		draw.SimpleTextOutlined( text, "HUDNumber", ScrW()*.5, (LDRP.MeterHeight*.5)+10, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0) )
	end
	hook.Add("HUDPaint","Shows a progress meter",MeterHUDLocal)
	
	timer.Create("MeterHUDRemove",time,1,function()
		hook.Remove("HUDPaint","Shows a progress meter")
	end)
end

function LDRP.SendMeter(um)
	LDRP.CreateMeterHUD(um:ReadString(),um:ReadFloat())
end
usermessage.Hook("SendMeter",LDRP.SendMeter)

function LDRP_SH.CancelMeter()
	if timer.Exists("MeterHUDRemove") then
		hook.Remove("HUDPaint","Shows a progress meter")
		timer.Remove("MeterHUDRemove")
	end
end
usermessage.Hook("CancelMeter",LDRP_SH.CancelMeter)


function LDRP.InputLockReason()
	if LocalPlayer():Team() != TEAM_MAYOR then return end
	
	local LD = {}
	
	LD.BG = vgui.Create("DFrame")
	LD.BG:SetSize(500,100)
	LD.BG:Center()
	LD.BG:SetTitle("")
	LD.BG:MakePopup()
	LD.BG.Paint = function()
		draw.RoundedBox( 8, 0, 0, 500, 100, Color(150,0,0,180) )
		draw.SimpleTextOutlined( "Type a reason for the lockdown below.", "Trebuchet24", 250, 17, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
	end
	
	LD.Entry = vgui.Create("DTextEntry",LD.BG)
	LD.Entry:SetPos(4,30)
	LD.Entry:SetSize(492,40)
	
	LD.Enter = vgui.Create("DButton",LD.BG)
	LD.Enter:SetPos(4,74)
	LD.Enter:SetSize(492,20)
	LD.Enter.Paint = function()
		draw.RoundedBox( 8, 0, 0, 492, 20, Color(70,0,0,210) )
	end
	LD.Enter:SetText("Start Lockdown")
	LD.Enter.DoClick = function()
		RunConsoleCommand("_lckdwn",tostring(LD.Entry:GetValue()))
		LD.BG:Close()
	end
end
concommand.Add("lockreason",LDRP.InputLockReason)

LDRP.Hooked = false
function LDRP.SendLockdown(um)
	local Reason = um:ReadString()
	if Reason == "__StoP" then
		LDRP.Hooked = false
		hook.Remove("HUDPaint","Lockdown HUD")
		return
	end
	if !Reason or Reason == "" then Reason = "No reason!" end
	
	local LockdownBoxSize = 240
	local CurClr = 0
	local CurAdd = 1
	local function LockHUD()
		local WidthMath = LockdownBoxSize+(string.len(Reason)*ScrW()*.007)
		draw.RoundedBox( 8, ScrW()*.5-(WidthMath*.5)-4, ScrH()*.03-4, WidthMath+8, 38, Color(0,60,250,180) )
		draw.RoundedBox( 8, ScrW()*.5-(WidthMath*.5), ScrH()*.03, WidthMath, 30, Color(0,150,200,180) )
		if CurClr <= 0 then CurAdd = 1 elseif CurClr >= 1 then CurAdd = 0 end
		CurClr = (CurAdd == 1 and CurClr+.01) or (CurClr-.01)
			
		local Math = Lerp(CurClr,0,255)
		Clr = Color(255,Math,Math)
		draw.SimpleTextOutlined( "There is a lockdown! Reason: " .. Reason, "Trebuchet22", ScrW()*.5, ScrH()*.03+15, Clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
	end
	hook.Add("HUDPaint","Lockdown HUD",LockHUD)
	
end
usermessage.Hook("SendLockdown",LDRP.SendLockdown)

if !UseFadmin then

	local matBlurScreen = Material( "pp/blurscreen" )
	local blur

	function LDRP.PlayerInfo(who)
		local B = {}
		
		B.BG = vgui.Create("DFrame")
		B.BG:SetSize(296,114)
		B.BG:Center()
		B.BG:MakePopup()
		B.BG:SetTitle("Info on: " .. who:GetName())
		B.BG.OldP = B.BG.Paint
		local SID = who:SteamID()
		B.BG.Paint = function(s, w, h)
			B.BG.OldP(s, w, h)
			
			draw.RoundedBox(0,4,24,84,84,Color(255,255,255,210))
			draw.RoundedBox(6,92,24,200,84,Color(255,255,255,140))
			draw.RoundedBox(6,93,25,198,82,Color(110,110,110,140))
			
			draw.SimpleTextOutlined("SteamID: " .. SID,"Trebuchet18",98,34,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 1, Color(0,0,0,200) )
			draw.SimpleTextOutlined("Cash: $" .. (who.DarkRPVars.money or 0),"Trebuchet18",98,54,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 1, Color(0,0,0,200) )
			draw.SimpleTextOutlined("Props: " .. (who:GetCount("props") or 0),"Trebuchet18",98,74,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 1, Color(0,0,0,200) )
			
		end
		
		B.Avatar = vgui.Create("AvatarImage",B.BG)
		B.Avatar:SetSize(80,80)
		B.Avatar:SetPos(6,26)
		B.Avatar:SetPlayer(who)
		
	end

	function LDRP.Scoreboard()
		local B = {}
		
		function B.CreateBlur(self)
			surface.SetMaterial( matBlurScreen )
			surface.SetDrawColor( 255, 255, 255, 255 )
			
			matBlurScreen:SetFloat( "$blur", 6 )
			render.UpdateScreenEffectTexture()
		end
		
		B.BG = vgui.Create("DFrame")
		B.BG:SetSize(900,600)
		B.BG:Center()
		B.BG:MakePopup()
		B.BG.Paint = function(self)
			draw.RoundedBox(6,0,0,900,600,Color(200,200,200,90))
			B.CreateBlur(self)
			
			draw.RoundedBox(6,4,4,892,50,Color(100,100,100,130))
			draw.RoundedBox(6,6,6,888,46,Color(145,166,200,140))
			draw.SimpleTextOutlined("Liquid DarkRP","HUDNumber",450,25,Color(98,144,217,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 1, Color(0,0,0,200) )
		end
		B.BG:SetTitle("")
		B.BG:ShowCloseButton(false)
		
		B.Players = vgui.Create("DPanelList",B.BG)
		B.Players:SetSize(876,534)
		B.Players:SetPos(12,54)
		B.Players.Paint = function(self)
			draw.RoundedBox(0,0,0,876,534,Color(145,166,200,140))
			draw.RoundedBox(0,2,2,872,530,Color(108,136,180,140))
			
			B.CreateBlur(self)
		end
		B.Players:SetPadding(6)
		B.Players:SetSpacing(6)
		B.Players:EnableVerticalScrollbar(true)
		
		B.Sorting = vgui.Create("DPanel")
		B.Sorting:SetHeight(30)
		B.Sorting.Paint = function(self)
			local W,H = self:GetSize()
			draw.RoundedBox(8,0,0,W,H,Color(30,30,30,210))
			
			draw.SimpleTextOutlined("Player","Trebuchet22",60,15,Color(255,255,255,180),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 1.5, Color(0,0,0,200) )
			draw.SimpleTextOutlined("Job","Trebuchet22",370,15,Color(255,255,255,180),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 1.5, Color(0,0,0,200) )
			draw.SimpleTextOutlined("Rank","Trebuchet22",540,15,Color(255,255,255,180),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 1.5, Color(0,0,0,200) )
			draw.SimpleTextOutlined("Ping","Trebuchet22",W-70,15,Color(255,255,255,180),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER, 1.5, Color(0,0,0,200) )
			draw.SimpleTextOutlined("Info","Trebuchet22",W-10,15,Color(255,255,255,180),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER, 1.5, Color(0,0,0,200) )
			
		end
		B.Players:AddItem(B.Sorting)
		
		for k,v in pairs(player.GetAll()) do
			local Ply=vgui.Create("DPanel")
			Ply:SetHeight(40)
			local Clr = team.GetColor(v:Team())
			Clr = Color(Clr.r,Clr.g,Clr.b,255)
			local Rank = v:GetNWString("usergroup")
			if v:SteamID() == "STEAM_0:1:6133338" then
				Rank = "Creator (Guest)"
			else
				if Rank then
					Rank = string.upper(string.sub(Rank,0,1)) .. string.sub(Rank,2,string.len(Rank))
				else
					Rank = (v:IsSuperAdmin() and "Super Admin") or (v:IsAdmin() and "Admin") or "Guest"
				end
			end
			Ply.Think = function( self )
				if !v:IsValid() then
					Ply:Remove()
					return
				end
				
				--Correct the player info button getting messed up
				self:GetChildren()[2]:SetPos( Ply:GetWide() - 30, 10 )
			end
			
			Ply.Paint = function( self, w, h)
				if !v:IsValid() then return end
				local W,H = self:GetSize()
				draw.RoundedBox(8,0,0,W,H,Color(10,10,10,140))
				
				draw.SimpleTextOutlined(v:GetName(),"Trebuchet24",60,20,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 2, Color(0,0,0,200) )
				draw.SimpleTextOutlined(team.GetName(v:Team()),"Trebuchet22",370,20,Clr,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 1, Color(0,0,0,200) )
				draw.SimpleTextOutlined(Rank,"Trebuchet22",540,20,(v:IsAdmin() and Color(0,255,0,255)) or Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 1, Color(0,0,0,200) )
				draw.SimpleTextOutlined(v:Ping(),"Trebuchet22",W-70,20,Color(255,255,255,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER, 1, Color(0,0,0,200) )
				
			end
			
			local Avatar=vgui.Create("AvatarImage",Ply)
			Avatar:SetPos(8,4)
			Avatar:SetSize(32,32)
			Avatar:SetPlayer(v)
			
			local Info = vgui.Create("DImageButton",Ply)
			Info:SetImage("icon16/page")
			Info:SetPos( Ply:GetWide() - 30, 10 )
			Info:SetSize( 16, 16 )
			Info.DoClick = function()
				LDRP.PlayerInfo(v)
			end
			
			B.Players:AddItem(Ply)
		end
		return B.BG
	end
	
	function GM:ScoreboardShow()
		TheSB = LDRP.Scoreboard()
	end
	
	function GM:ScoreboardHide()
		if TheSB and TheSB:IsValid() then TheSB:Close() end
	end
end


