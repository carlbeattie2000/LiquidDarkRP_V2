/*---------------------------------------------------------------------------
HUD ConVars
---------------------------------------------------------------------------*/
local ConVars = {}
local HUDWidth
local HUDHeight
local draw = draw
local cvars = cvars
local surface = surface

local function ReloadConVars()
	ConVars = {
		background = {0,0,0,100},
		Healthbackground = {0,0,0,200},
		Healthforeground = {0,200,220,180},
		HealthText = {255,255,255,200},
		Job1 = {0,0,150,200},
		Job2 = {0,0,0,255},
		salary1 = {0,150,0,200},
		salary2 = {0,0,0,255}
	}

	for name, Colour in pairs(ConVars) do
		ConVars[name] = {}
		for num, rgb in SortedPairs(Colour) do
			local CVar = GetConVar(name..num) or CreateClientConVar(name..num, rgb, true, false)
			table.insert(ConVars[name], CVar:GetInt())

			if not cvars.GetConVarCallbacks(name..num, false) then
				cvars.AddChangeCallback(name..num, function() timer.Simple(0,ReloadConVars) end)
			end
		end
		ConVars[name] = Color(unpack(ConVars[name]))
	end


	HUDWidth = (GetConVar("HudW") or  CreateClientConVar("HudW", 240, true, false)):GetInt()
	HUDHeight = (GetConVar("HudH") or CreateClientConVar("HudH", 115, true, false)):GetInt()

	if not cvars.GetConVarCallbacks("HudW", false) and not cvars.GetConVarCallbacks("HudH", false) then
		cvars.AddChangeCallback("HudW", function() timer.Simple(0,ReloadConVars) end)
		cvars.AddChangeCallback("HudH", function() timer.Simple(0,ReloadConVars) end)
	end
end
ReloadConVars()


local Scrw, Scrh, RelativeX, RelativeY
/*---------------------------------------------------------------------------
HUD Seperate Elements
---------------------------------------------------------------------------*/


local function GunLicense()
	local Check = LocalPlayer().DarkRPVars
	if Check and Check.HasGunlicense then
		local QuadTable = {}  
		
		QuadTable.texture 	= surface.GetTextureID( "icon16/page.png" ) 
		QuadTable.color		= Color( 255, 255, 255, 100 )  
		
		QuadTable.x = RelativeX + HUDWidth + 31
		QuadTable.y = ScrH() - 32
		QuadTable.w = 32
		QuadTable.h = 32
		draw.TexturedQuad(QuadTable)
	end
end

local function Agenda()
	local DrawAgenda, AgendaManager = DarkRPAgendas[LocalPlayer():Team()], LocalPlayer():Team()
	if not DrawAgenda then
		for k,v in pairs(DarkRPAgendas) do
			if table.HasValue(v.Listeners, LocalPlayer():Team()) then
				DrawAgenda, AgendaManager = DarkRPAgendas[k], k
				break
			end
		end
	end
	if DrawAgenda then
		draw.RoundedBox(10, ScrW()-464, 10, 460, 110, Color(67, 202, 211, 140))
		draw.RoundedBox(10, ScrW()-460, 12, 456, 106, Color(67, 140, 211, 100))
		draw.RoundedBox(10, ScrW()-460, 12, 456, 20, Color(67, 100, 211, 100))
		
		draw.DrawText(DrawAgenda.Title, "ScoreboardText", ScrW()-430, 12, Color(255,0,0,255),0)
		
		local AgendaText = ""
		for k,v in pairs(team.GetPlayers(AgendaManager)) do
			AgendaText = AgendaText .. (v.DarkRPVars.agenda or "")
		end
		draw.DrawText(string.gsub(string.gsub(AgendaText, "//", "\n"), "\\n", "\n"), "ScoreboardText", ScrW()-430, 35, Color(255,255,255,255),0)
	end
end

local VoiceChatTexture = surface.GetTextureID("voice/icntlk_pl")
local function DrawVoiceChat()
	if LocalPlayer().DRPIsTalking then
		local chbxX, chboxY = chat.GetChatBoxPos()

		local Rotating = math.sin(CurTime()*3)
		local backwards = 0
		if Rotating < 0 then
			Rotating = 1-(1+Rotating)
			backwards = 180
		end
		surface.SetTexture(VoiceChatTexture)
		surface.SetDrawColor(ConVars.Healthforeground)
		surface.DrawTexturedRectRotated(ScrW() - 100, chboxY, Rotating*96, 96, backwards)
	end
end

local function LockDown()
	if util.tobool(GetConVarNumber("DarkRP_LockDown")) then
		local cin = (math.sin(CurTime()) + 1) / 2
		draw.DrawText(LANGUAGE.lockdown_started, "ScoreboardSubtitle", ScrW()*.01, ScrH()*.97, Color(cin * 255, 0, 255 - (cin * 255), 255), TEXT_ALIGN_LEFT)
	end
end

local Arrested = function() end

usermessage.Hook("GotArrested", function(msg)

	local StartArrested = CurTime()

	local ArrestedUntil = msg:ReadFloat()

	
	Arrested = function()

		if CurTime() - StartArrested <= ArrestedUntil and LocalPlayer().DarkRPVars.Arrested then

      local hudTimeLeft = string.format(LANGUAGE.youre_arrested, math.ceil(ArrestedUntil - (CurTime() - StartArrested)))

      local bWidth = ScrW() * .3
      local bHeight = 70

      local x = (ScrW() / 2) - (bWidth / 2)
      local y = ScrH() - 100

      draw.RoundedBox(5, x, y, bWidth, bHeight, Color(255, 50, 50, 200))

      draw.SimpleTextOutlined(hudTimeLeft, "Trebuchet24", x + (bWidth/2), y + (bHeight / 2), Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2,Color(0,0,0,255))

		elseif not LocalPlayer().DarkRPVars.Arrested then 
			Arrested = function() end
		end

	end

end)

local AdminTell = function() end

usermessage.Hook("AdminTell", function(msg)
	local Message = msg:ReadString()

	AdminTell = function() 
		draw.RoundedBox(4, 10, 10, ScrW() - 20, 100, Color(0, 0, 0, 255))
		draw.DrawText(LANGUAGE.listen_up, "GModToolName", ScrW() / 2 + 10, 10, Color(255, 255, 255, 255), 1)
		draw.DrawText(Message, "ChatFont", ScrW() / 2 + 10, 65, Color(200, 30, 30, 255), 1)
	end

	timer.Simple(10, function() 
		AdminTell = function() end
	end)
end)

/*---------------------------------------------------------------------------
Drawing the HUD elements such as Health etc.
---------------------------------------------------------------------------*/
local function DrawHUD()
	if !LocalPlayer().DarkRPVars or LocalPlayer().InTut then return end
	Scrw, Scrh = ScrW(), ScrH()
	RelativeX, RelativeY = 0, Scrh

	GunLicense()
	Agenda()
	DrawVoiceChat()
	LockDown()

	Arrested()
	AdminTell()
end

/*---------------------------------------------------------------------------
Entity HUDPaint things
---------------------------------------------------------------------------*/

local function HealthHUD(ply)
	local hp = ply:Health()
	local Math = (1-(hp/100))*255
	local Clr = Color(Math,255-Math,0,255)
	local Str = (hp < 20 and "Dieing") or (hp < 50 and "Damaged") or (hp < 80 and "Hurt") or "Healthy"

	return Str,Clr
end

local function LDRP_PlayerInfo(ply)
	if not GAMEMODE.Config.globalshow then return end
	local pos = (ply:GetPos()+Vector(0,0,80)):ToScreen()
	local name = ply:GetName()
	local Team = team.GetName(ply:Team())
	local x,y = pos.x,pos.y
	local Str,Clr = HealthHUD(ply)
	local long = {name,Team,Str}
	local longest = 0
	for _,a in pairs(long) do local c = string.len(a) if c > longest then longest = c end end
	
	long = longest*11.52
	draw.RoundedBox(6,x-(long*.5),y,long,65,Color(50,50,50,180))
	draw.SimpleTextOutlined(name,"Trebuchet24",x,y,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP, 2, Color(0,0,0,255) )
	
	if GAMEMODE.Config.showjob then
		draw.SimpleTextOutlined(Team,"Trebuchet22",x,y+20,team.GetColor(ply:Team()),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP, 1, Color(0,0,0,255) )
	end
	 
	draw.SimpleTextOutlined(Str,"Trebuchet22",x,y+40,Clr,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP, 1, Color(0,0,0,255) )
end

local function DrawWantedInfo(ply)
	if not ply:Alive() then return end

	local pos = ply:EyePos()
	if not pos:RPIsInSight({LocalPlayer(), ply}) then return end

	pos.z = pos.z + 14
	pos = pos:ToScreen()

	if GAMEMODE.Config.showname then
		draw.DrawText(ply:Nick(), "Trebuchet22", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "Trebuchet22", pos.x, pos.y, team.GetColor(ply:Team()), 1)
	end

	draw.DrawText(LANGUAGE.wanted.."\nReason: "..tostring(ply.DarkRPVars["wantedReason"]), "Trebuchet22", pos.x, pos.y - 40, Color(255, 255, 255, 200), 1)
	draw.DrawText(LANGUAGE.wanted.."\nReason: "..tostring(ply.DarkRPVars["wantedReason"]), "Trebuchet22", pos.x + 1, pos.y - 41, Color(255, 0, 0, 255), 1)
end

/*---------------------------------------------------------------------------
The Entity display: draw HUD information about entities
---------------------------------------------------------------------------*/
local function DrawEntityDisplay()
	local tr = LocalPlayer():GetEyeTrace()
	local e = tr.Entity
	if e and e.IsValid and e:IsValid() and e:GetPos():Distance(LocalPlayer():GetPos()) < 400 then
		if tr.Entity:IsPlayer() then
			LDRP_PlayerInfo(tr.Entity)
		end
		if tr.Entity:IsOwnable() then
			tr.Entity:DrawOwnableInfo()
		end
	end
end

/*---------------------------------------------------------------------------
Actual HUDPaint hook
---------------------------------------------------------------------------*/
function GM:HUDPaint()
	if !LocalPlayer().DarkRPVars or LocalPlayer().InTut then return end
	DrawHUD()
	DrawEntityDisplay()

	self.BaseClass:HUDPaint()
end