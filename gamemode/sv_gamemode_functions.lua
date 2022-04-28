util.AddNetworkString("DarkRP_DoorData")
util.AddNetworkString( "DarkRP_InitializeVars" )

/*---------------------------------------------------------------------------
DarkRP hooks
---------------------------------------------------------------------------*/

function GM:CanDropWeapon(ply, weapon)
	if not IsValid(weapon) then return false end
	local class = string.lower(weapon:GetClass())
	if self.Config.DisallowDrop[class] then return false end

	if not GAMEMODE.Config.restrictdrop then return true end

	for k,v in pairs(CustomShipments) do
		if v.entity ~= class then continue end

		return true
	end

	return false
end

function GM:DatabaseInitialized()
	FPP.Init()
	DarkRP.initDatabase()
end

/*---------------------------------------------------------
 Gamemode functions
 ---------------------------------------------------------*/
-- Grammar corrections by Eusion
function GM:Initialize()
	self.BaseClass:Initialize()
end

function GM:PlayerSpawnProp(ply, model)
	if not self.BaseClass:PlayerSpawnProp(ply, model) then return false end
	if (ply:GetCount("Props") > 30 and !ply:IsVIP()) then
		return Notify(ply, 0, 5, "Prop limit reached. Become VIP for more props!")
	elseif (ply:GetCount("Props") > 70) then
		return Notify(ply, 0, 5, "Prop limit reached (70 props for donating!)")
	end
	
	-- If prop spawning is enabled or the user has admin or prop privileges
	local allowed = ((GAMEMODE.Config.propspawning or (FAdmin and FAdmin.Access.PlayerHasPrivilege(ply, "rp_prop")) or ply:IsAdmin()) and true) or false

	if RPArrestedPlayers[ply:SteamID()] then return false end
	model = string.gsub(tostring(model), "\\", "/")
	if string.find(model,  "//") then Notify(ply, 1, 4, "You can't spawn this prop as it contains an invalid path. " ..model) 
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") tried to spawn prop with an invalid path "..model) return false end

	if allowed then
		if !ply:IsVIP() then
			if GAMEMODE.Config.proppaying then
				if ply:CanAfford(GAMEMODE.Config.propcost) then
					Notify(ply, 0, 4, "Deducted " .. CUR .. GAMEMODE.Config.propcost)
					ply:AddMoney(-GAMEMODE.Config.propcost)
					return true
				else
					Notify(ply, 1, 4, "Need " .. CUR .. GAMEMODE.Config.propcost)
					return false
				end
			else
				return true --Allow regular players to spawn props
			end
		else
			Notify(ply, 0, 4, "Free prop! (VIP)")
			return true
		end
	end
	return false
end

local function canSpawnWeapon(ply, class)
	if (not GAMEMODE.Config.adminweapons == 0 and ply:IsAdmin()) or
		(GAMEMODE.Config.adminweapons == 1 and ply:IsSuperAdmin()) then
		return true
	end
	GAMEMODE:Notify(ply, 1, 4, "You can't spawn weapons")

	return false
end

function GM:PlayerSpawnSENT(ply, model)
	return self.BaseClass:PlayerSpawnSENT(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnSWEP(ply, model)
	return canSpawnWeapon(ply, class) and self.BaseClass:PlayerSpawnSWEP(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerGiveSWEP(ply, class, model)
	return canSpawnWeapon(ply, class) and self.BaseClass:PlayerGiveSWEP(ply, class, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnEffect(ply, model)
	return self.BaseClass:PlayerSpawnEffect(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnVehicle(ply, model)
	return self.BaseClass:PlayerSpawnVehicle(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnNPC(ply, model)
	if GAMEMODE.Config.adminnpcs and not ply:IsAdmin() then return false end
	return self.BaseClass:PlayerSpawnNPC(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnRagdoll(ply, model)
	return self.BaseClass:PlayerSpawnRagdoll(ply, model) and not RPArrestedPlayers[ply:SteamID()]
end

function GM:PlayerSpawnedProp(ply, model, ent)
	self.BaseClass:PlayerSpawnedProp(ply, model, ent)
	ent.SID = ply.SID
	ent.Owner = ply
end

function GM:PlayerSpawnedRagdoll(ply, model, ent)
	self.BaseClass:PlayerSpawnedRagdoll(ply, model, ent)
	ent.SID = ply.SID
end

function GM:EntityRemoved(ent)
	self.BaseClass:EntityRemoved(ent)
	if ent:IsVehicle() then
		local found = ent.Owner
		if IsValid(found) then
			found.Vehicles = found.Vehicles or 1
			found.Vehicles = found.Vehicles - 1
		end
	end
	
	for k,v in pairs(DarkRPEntities or {}) do
		if IsValid(ent) and ent:GetClass() == v.ent and ent.dt and IsValid(ent.dt.owning_ent) and not ent.IsRemoved then
			local ply = ent.dt.owning_ent
			local cmdname = string.gsub(v.ent, " ", "_")
			if not ply["max"..cmdname] then
				ply["max"..cmdname] = 1
			end
			ply["max"..cmdname] = ply["max"..cmdname] - 1
			ent.IsRemoved = true
		end
	end
end

function GM:ShowSpare1(ply)
	umsg.Start("ToggleClicker", ply)
	umsg.End()
end

function GM:ShowSpare2(ply)
	umsg.Start("ChangeJobVGUI", ply)
	umsg.End()
end

function GM:OnNPCKilled(victim, ent, weapon)
	-- If something killed the npc
	if ent then
		if ent:IsVehicle() and ent:GetDriver():IsPlayer() then ent = ent:GetDriver() end

		-- If it wasn't a player directly, find out who owns the prop that did the killing
		if not ent:IsPlayer() and ent.SID then
			ent = Player(ent.SID)
		end

		-- If we know by now who killed the NPC, pay them. (NPCs kill each other apparently)
		if IsValid(ent) and ent:IsPlayer() and GAMEMODE.Config.npckillpay > 0 then
			ent:AddMoney(GAMEMODE.Config.npckillpay)
			Notify(ent, 0, 4, string.format(LANGUAGE.npc_killpay, CUR .. GAMEMODE.Config.npckillpay))
		end
	end
end

function GM:KeyPress(ply, code)
	self.BaseClass:KeyPress(ply, code)
end


local function IsInRoom(listener, talker) -- IsInRoom function to see if the player is in the same room.
	local tracedata = {}
	tracedata.start = talker:GetShootPos()
	tracedata.endpos = listener:GetShootPos()
	local trace = util.TraceLine( tracedata )
	
	return not trace.HitWorld
end

local threed = GM.Config.voice3D
local vrad = GM.Config.voiceradius
local dynv = GM.Config.dynamicvoice
function GM:PlayerCanHearPlayersVoice(listener, talker, other)
	if vrad and listener:GetShootPos():Distance(talker:GetShootPos()) < 550 then
		if dynv then
			if IsInRoom(listener, talker) then
				return true, threed
				else
				return false, threed
			end
		end
		return true, threed
		elseif vrad then
			return false, threed
	end
	return true, threed
end

function GM:CanTool(ply, trace, mode)
	local ent = trace.Entity

	if table.HasValue(LDRP_Protector.Restrict.Tools, string.lower(mode)) then Notify(ply, 1, 5, "This tool is restricted!") return false end
	if ent and ent:IsValid() then
		local Class = ent:GetClass()
		if table.HasValue(LDRP_Protector.NoPhysgun, string.lower(Class)) then return false end
	end
	
	if not self.BaseClass:CanTool(ply, trace, mode) then return false end

	if IsValid(trace.Entity) then
		if trace.Entity.onlyremover then
			if mode == "remover" then
				return (ply:IsAdmin() or ply:IsSuperAdmin())
			else
				return false
			end
		end

		if trace.Entity.nodupe and (mode == "weld" or
					mode == "weld_ez" or
					mode == "spawner" or
					mode == "duplicator" or
					mode == "adv_duplicator") then
			return false
		end

		if trace.Entity:IsVehicle() and mode == "nocollide" and not GAMEMODE.Config.allowvnocollide then
			return false
		end
	end
	return true
end

function GM:CanPlayerSuicide(ply)
	if ply.IsSleeping then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "suicide", ""))
		return false
	end
	if RPArrestedPlayers[ply:SteamID()] then
		Notify(ply, 1, 4, string.format(LANGUAGE.unable, "suicide", ""))
		return false
	end
	return true
end

function GM:CanDrive(ply, ent)
	GAMEMODE:Notify(ply, 1, 4, "Drive disabled for now.")
	return false -- Disabled until people can't minge with it anymore
end

local allowedProperty = {
	remover = true,
	ignite = false,
	extinguish = true,
	keepupright = true,
	gravity = true,
	collision = true,
	skin = true,
	bodygroups = true
}
function GM:CanProperty(ply, property, ent)
	if allowedProperty[property] and ent:CPPICanTool(ply, "remover") then
		return true
	end

	if property == "persist" and ply:IsSuperAdmin() then
		return true
	end
	GAMEMODE:Notify(ply, 1, 4, "Property disabled for now.")
	return false -- Disabled until antiminge measure is found
end

function GM:PlayerShouldTaunt(ply, actid)
	return false
end

local CacheNames = LDRP_SH.NicerWepNames
local CacheModels = LDRP_SH.AllItems
local FilterWeps = {"weapon_real_cs_grenade","weapon_real_cs_smoke","weapon_real_cs_flash"}

function GM:DoPlayerDeath(ply, attacker, dmginfo, ...)
	if GAMEMODE.Config.dropweapondeath and ply:Team() != TEAM_POLICE and ply:Team() != TEAM_CHIEF then
		for k,v in pairs(ply:GetWeapons()) do
			local c = v:GetClass()
			if table.HasValue(FilterWeps,c) then continue end
			if CacheNames[c] then
				local weapon = ents.Create("spawned_weapon")
				weapon.ShareGravgun = true
				weapon:SetPos(ply:GetPos()+Vector(0,0,5))
				weapon:SetModel(CacheModels[c].mdl)
				weapon.weaponclass = c
				weapon.nodupe = true
				weapon.ammohacked = true
				weapon:Spawn()
			end
		end
	end
	ply:CreateRagdoll()
	ply:AddDeaths( 1 )
	if IsValid(attacker) and attacker:IsPlayer() then
		if attacker == ply then
			attacker:AddFrags(-1)
		else
			attacker:AddFrags(1)
		end
	end
end

function GM:PlayerDeath(ply, weapon, killer)
	if GAMEMODE.Config.deathblack then
		local RP = RecipientFilter()
		RP:RemoveAllPlayers()
		RP:AddPlayer(ply)
		umsg.Start("DarkRPEffects", RP)
			umsg.String("colormod")
			umsg.String("1")
		umsg.End()
		RP:AddAllPlayers()
	end
	if GAMEMODE.Config.deathpov then
		SendUserMessage("DarkRPEffects", ply, "deathPOV", "1")
	end
	UnDrugPlayer(ply)

	if weapon:IsVehicle() and weapon:GetDriver():IsPlayer() then killer = weapon:GetDriver() end
	

	if GAMEMODE.Config.showdeaths then
		self.BaseClass:PlayerDeath(ply, weapon, killer)
	elseif killer:IsPlayer() then
		for k,v in pairs(player.GetAll()) do
			if v:IsAdmin() or v:IsUserGroup("Moderator") then
				v:PrintMessage(HUD_PRINTCONSOLE, ply:Nick().." was killed by "..killer:Name().." with "..weapon:GetClass())
			end
		end
	end

	ply:Extinguish()

	if ply:InVehicle() then ply:ExitVehicle() end

	if RPArrestedPlayers[ply:SteamID()] and not GAMEMODE.Config.respawninjail  then
		-- If the player died in jail, make sure they can't respawn until their jail sentance is over
		ply.NextSpawnTime = CurTime() + math.ceil(GAMEMODE.Config.jailtimer - (CurTime() - ply.LastJailed)) + 1
		for a, b in pairs(player.GetAll()) do
			b:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.died_in_jail, ply:Nick()))
		end 
		Notify(ply, 4, 4, LANGUAGE.dead_in_jail)
	else
		-- Normal death, respawning.
		ply.NextSpawnTime = CurTime() + GAMEMODE.Config.respawntime
	end
	ply.DeathPos = ply:GetPos()
	
	if GAMEMODE.Config.dropmoneyondeath then
		local amount = GAMEMODE.Config.deathfee
		if not ply:CanAfford(GAMEMODE.Config.deathfee) then
			amount = ply.DarkRPVars.money
		end
		
		if amount > 0 then
			ply:AddMoney(-amount)
			DarkRPCreateMoneyBag(ply:GetPos(), amount)
		end
	end

	if GAMEMODE.Config.dmautokick and killer and killer:IsPlayer() and killer ~= ply then
		if not killer.kills or killer.kills == 0 then
			killer.kills = 1
			timer.Simple(GAMEMODE.Config.dmgracetime, killer.ResetDMCounter, killer)
		else
			-- If this player is going over their limit, kick their ass
			if killer.kills + 1 > GAMEMODE.Config.dmmaxkills then
				game.ConsoleCommand("kickid " .. killer:UserID() .. " Auto-kicked. Excessive Deathmatching.\n")
			else
				-- Killed another player
				killer.kills = killer.kills + 1
			end
		end
	end

	if IsValid(ply) and (ply ~= killer or ply.Slayed) and not RPArrestedPlayers[ply:SteamID()] then
		ply:SetDarkRPVar("wanted", false)
		ply.DeathPos = nil
		ply.Slayed = false
	end
	
	ply:GetTable().ConfisquatedWeapons = nil

	if weapon:IsPlayer() then weapon = weapon:GetActiveWeapon() killer = killer:SteamName() if ( !weapon || weapon == NULL ) then weapon = killer else weapon = weapon:GetClass() end end
	if killer == ply then killer = "Himself" weapon = "suicide trick" end
	DB.Log(ply:SteamName() .. " was killed by "..tostring(killer) .. " with a "..tostring(weapon))
end

function GM:PlayerCanPickupWeapon(ply, weapon)
	if weapon.IsUsing and weapon.IsUsing != ply then return false end
	if RPArrestedPlayers[ply:SteamID()] then return false end
	if ply:IsAdmin() and GAMEMODE.Config.AdminsCopWeapons then return true end
	
	if GAMEMODE.Config.license and not ply.DarkRPVars.HasGunlicense and not ply:GetTable().RPLicenseSpawn then
		if GAMEMODE.NoLicense[string.lower(weapon:GetClass())] or not weapon:IsWeapon() then
			return true
		end
		return false
	end
	return true
end

local function removelicense(ply) 
	if not IsValid(ply) then return end 
	ply:GetTable().RPLicenseSpawn = false 
end

local function SetPlayerModel(ply, cmd, args)
	if not args[1] then return end
	ply.rpChosenModel = args[1]
end
concommand.Add("_rp_ChosenModel", SetPlayerModel)

function GM:PlayerSetModel(ply)
	local EndModel = ""
	if GAMEMODE.Config.enforceplayermodel then
		local TEAM = RPExtraTeams[ply:Team()]
		
		if type(TEAM.model) == "table" then
			local ChosenModel = ply.rpChosenModel or ply:GetInfo("rp_playermodel")
			ChosenModel = string.lower(ChosenModel)
			
			local found
			for _,Models in pairs(TEAM.model) do
				if ChosenModel == string.lower(Models) then
					EndModel = Models
					found = true
					break
				end
			end
			
			if not found then
				EndModel = TEAM.model[math.random(#TEAM.model)]
			end
		else
			EndModel = TEAM.model
		end

		ply:SetModel(EndModel)
	else
		local cl_playermodel = ply:GetInfo( "cl_playermodel" )
        local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
        ply:SetModel( modelname )
	end
end

function GM:PlayerInitialSpawn(ply)
	self.BaseClass:PlayerInitialSpawn(ply)
	
	DB.Log(ply:Nick().." ("..ply:SteamID()..") has joined the game")
	ply.bannedfrom = {}
	ply.DarkRPVars = ply.DarkRPVars or {}
	ply:NewData()
	ply.SID = ply:UserID()
	
	for k,v in pairs(ents.GetAll()) do
		if IsValid(v) and v.deleteSteamID == ply:SteamID() and v.dt then
			v.SID = ply.SID
			if v.Setowning_ent then
				v:Setowning_ent(ply)
			end
			v.deleteSteamID = nil
			timer.Destroy("Remove"..v:EntIndex())
			ply["max"..v:GetClass()] = (ply["max"..v:GetClass()] or 0) + 1
			if v.dt and v.Setowning_ent then v:Setowning_ent(ply) end
		end
	end
end

local function formatDarkRPValue(value)
	if value == nil then return "nil" end

	if isentity(value) and not IsValid(value) then return "NULL" end
	if isentity(value) and value:IsPlayer() then return string.format("Entity [%s][Player]", value:EntIndex()) end

	return tostring(value)
end

local meta = FindMetaTable("Player")
function meta:SetDarkRPVar(var, value, target)
	if not IsValid(self) then return end
	target = target or RecipientFilter():AddAllPlayers()

	hook.Call("DarkRPVarChanged", nil, self, var, (self.DarkRPVars and self.DarkRPVars[var]) or nil, value)

	self.DarkRPVars = self.DarkRPVars or {}
	self.DarkRPVars[var] = value

	value = formatDarkRPValue(value)

	umsg.Start("DarkRP_PlayerVar", target)
		-- The index because the player handle might not exist clientside yet
		umsg.Short(self:EntIndex())
		umsg.String(var)
		umsg.String(value)
	umsg.End()
end

function meta:SetSelfDarkRPVar(var, value)
	self.privateDRPVars = self.privateDRPVars or {}
	self.privateDRPVars[var] = true

	self:SetDarkRPVar(var, value, self)
end

function meta:getDarkRPVar(var)
	self.DarkRPVars = self.DarkRPVars or {}
	return self.DarkRPVars[var]
end

local function SendDarkRPVars(ply)
	if ply.DarkRPVarsSent and ply.DarkRPVarsSent > (CurTime() - 1) then return end --prevent spammers
	ply.DarkRPVarsSent = CurTime()

	local sendtable = {}
	for k,v in pairs(player.GetAll()) do
		sendtable[v] = {}
		for a,b in pairs(v.DarkRPVars or {}) do
			if not (v.privateDRPVars or {})[a] or ply == v then
				sendtable[v][a] = b
			end
		end
	end

	net.Start("DarkRP_InitializeVars")
		net.WriteTable(sendtable)
	net.Send(ply)
end
concommand.Add("_sendDarkRPvars", SendDarkRPVars)

function GM:PlayerSelectSpawn(ply)
	local POS = self.BaseClass:PlayerSelectSpawn(ply)
	if POS.GetPos then 
		POS = POS:GetPos()
	else
		POS = ply:GetPos()
	end 
	
	
	local CustomSpawnPos = DB.RetrieveTeamSpawnPos(ply)
	if GAMEMODE.Config.customspawns and not RPArrestedPlayers[ply:SteamID()] and CustomSpawnPos then
		POS = CustomSpawnPos[math.random(1, #CustomSpawnPos)]
	end
	
	-- Spawn where died in certain cases
	if GAMEMODE.Config.strictsuicide and ply:GetTable().DeathPos then
		POS = ply:GetTable().DeathPos
	end
	
	if RPArrestedPlayers[ply:SteamID()] then
		POS = DB.RetrieveJailPos() or ply:GetTable().DeathPos -- If we can't find a jail pos then we'll use where they died as a last resort
	end
	
	if not GAMEMODE:IsEmpty(POS) then
		local found = false
		for i = 40, 300, 15 do
			if GAMEMODE:IsEmpty(POS + Vector(i, 0, 0)) then
				POS = POS + Vector(i, 0, 0)
				-- Yeah I found a nice position to put the player in!
				found = true
				break
			end
		end
		if not found then
			for i = 40, 300, 15 do
				if GAMEMODE:IsEmpty(POS + Vector(0, i, 0)) then
					POS = POS + Vector(0, i, 0)
					found = true
					break
				end
			end
		end
		if not found then
			for i = 40, 300, 15 do
				if GAMEMODE:IsEmpty(POS + Vector(0, -i, 0)) then
					POS = POS + Vector(0, -i, 0)
					found = true
					break
				end
			end
		end
		if not found then
			for i = 40, 300, 15 do
				if GAMEMODE:IsEmpty(POS + Vector(-i, 0, 0)) then
					POS = POS + Vector(-i, 0, 0)
					-- Yeah I found a nice position to put the player in!
					found = true
					break
				end
			end
		end
		-- If you STILL can't find it, you'll just put him on top of the other player lol
		if not found then
			POS = POS + Vector(0,0,70)
		end
	end
	return self.BaseClass:PlayerSelectSpawn(ply), POS
end

function GM:PlayerSpawn(ply)
	self.BaseClass:PlayerSpawn(ply)
	
	player_manager.SetPlayerClass( ply, "player_LiquidDRP" )
	
	ply:CrosshairEnable()
	ply:UnSpectate()
	ply:SetHealth(tonumber(GAMEMODE.Config.startinghealth) or 100)

	if not GAMEMODE.Config.showcrosshairs then
		ply:CrosshairDisable()
	end
	
	SendUserMessage("DarkRPEffects", ply, "deathPOV", "0") -- No checks to prevent bugs
	
	-- Kill any colormod
	local RP = RecipientFilter()
	RP:RemoveAllPlayers()
	RP:AddPlayer(ply)
	umsg.Start("DarkRPEffects", RP)
		umsg.String("colormod")
		umsg.String("0")
	umsg.End()
	RP:AddAllPlayers()

	if GAMEMODE.Config.babygod and not ply.IsSleeping then
		ply.Babygod = true
		ply:GodEnable()
		local r,g,b,a = ply:GetColor()
		ply:SetColor(r, g, b, 100)
		ply:SetCollisionGroup(  COLLISION_GROUP_WORLD )
		timer.Simple(GAMEMODE.Config.babygodtime, function()
			if not IsValid(ply) then return end
			ply.Babygod = false
			ply:SetColor(r, g, b, a)
			ply:GodDisable()
			ply:SetCollisionGroup( COLLISION_GROUP_PLAYER )
		end)
	end
	ply.IsSleeping = false
	
	GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeed)
	if ply:Team() == TEAM_CHIEF or ply:Team() == TEAM_POLICE then
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeed + 10)
	end
	
	if RPArrestedPlayers[ply:SteamID()] then
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.arrestspeed, GAMEMODE.Config.arrestspeed)
	end

	ply:Extinguish()
	if ply:GetActiveWeapon() and IsValid(ply:GetActiveWeapon()) then
		ply:GetActiveWeapon():Extinguish()
	end
	
	for k,v in pairs(ents.FindByClass("predicted_viewmodel")) do -- Money printer ignite fix
		v:Extinguish()
	end

	if ply.demotedWhileDead then
		ply.demotedWhileDead = nil
		ply:ChangeTeam(TEAM_CITIZEN)
	end
	
	ply:GetTable().StartHealth = ply:Health()
	gamemode.Call("PlayerSetModel", ply)
	gamemode.Call("PlayerLoadout", ply)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") spawned")
	
	local _, pos = self:PlayerSelectSpawn(ply)
	ply:SetPos(pos)
end

local function selectDefaultWeapon(ply)
	-- Switch to prefered weapon if they have it
	local cl_defaultweapon = ply:GetInfo("cl_defaultweapon")

	if ply:HasWeapon(cl_defaultweapon) then
		ply:SelectWeapon(cl_defaultweapon)
	end
end

function GM:PlayerLoadout(ply)
	if ply:isArrested() then return end

	player_manager.RunClass(ply, "Spawn")

	ply:GetTable().RPLicenseSpawn = true
	timer.Simple(1, function() removelicense(ply) end)

	local Team = ply:Team() or 1

	if not RPExtraTeams[Team] then return end
	for k,v in pairs(RPExtraTeams[Team].weapons or {}) do
		ply:Give(v)
	end

	if RPExtraTeams[ply:Team()].PlayerLoadout then
		local val = RPExtraTeams[ply:Team()].PlayerLoadout(ply)
		if val == true then
			selectDefaultWeapon(ply)
			return
		end
	end

	for k, v in pairs(self.Config.DefaultWeapons) do
		ply:Give(v)
	end

	if (FAdmin and FAdmin.Access.PlayerHasPrivilege(ply, "rp_tool")) or ply:IsAdmin()  then
		ply:Give("gmod_tool")
	end

	if ply:HasPriv("rp_commands") and GAMEMODE.Config.AdminsCopWeapons then
		ply:Give("door_ram")
		ply:Give("arrest_stick")
		ply:Give("unarrest_stick")
		ply:Give("stunstick")
		ply:Give("weaponchecker")
	end

	selectDefaultWeapon(ply)
end

local RemoveOnDisco = {"money_printer","gunlab","letter","drug_lab","drug"}
function GM:PlayerDisconnected(ply)
	self.BaseClass:PlayerDisconnected(ply)
	timer.Destroy(ply:SteamID() .. "jobtimer")
	timer.Destroy(ply:SteamID() .. "propertytax")
	
	for k, v in pairs( ents.GetAll() ) do
		if table.HasValue(RemoveOnDisco,v:GetClass()) and v.dt.owning_ent == ply then v:Remove() end
	end
	
	--Put the player's weapons in their inventory so it will save
	for _, v in ipairs( ply:GetWeapons() ) do
		local wepType = v:GetClass()
		if ply:CanCarry( wepType ) then
			ply:AddItem( wepType, 1 )
		end
	end
	
	ply:SavePlayer()
	GAMEMODE.vote.DestroyVotesWithEnt(ply)
	
	if ply:Team() == TEAM_MAYOR and tobool(GetConVarNumber("DarkRP_LockDown")) then -- Stop the lockdown
		UnLockdown(ply)
	end
	
	if ply.SleepRagdoll and IsValid(ply.SleepRagdoll) then
		ply.SleepRagdoll:Remove()
	end
	
	ply:UnownAll()
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") disconnected")
end

local function PlayerDoorCheck()
	for k, ply in pairs(player.GetAll()) do
		local trace = ply:GetEyeTrace()
		if IsValid(trace.Entity) and (trace.Entity:IsDoor() or trace.Entity:IsVehicle()) and ply.LookingAtDoor ~= trace.Entity and trace.HitPos:Distance(ply:GetShootPos()) < 410 then
			ply.LookingAtDoor = trace.Entity -- Variable that prevents streaming to clients every frame
			
			trace.Entity.DoorData = trace.Entity.DoorData or {}
			
			local DoorString = "Data:\n"
			for key, v in pairs(trace.Entity.DoorData) do
				DoorString = DoorString .. key.."\t\t".. tostring(v) .. "\n"
			end
			
			if not ply.DRP_DoorMemory or not ply.DRP_DoorMemory[trace.Entity] then
				net.Start("DarkRP_DoorData")
				net.WriteEntity(trace.Entity)
				net.WriteTable(trace.Entity.DoorData)
				net.Send(ply)
				
				ply.DRP_DoorMemory = ply.DRP_DoorMemory or {}
				ply.DRP_DoorMemory[trace.Entity] = table.Copy(trace.Entity.DoorData)
			else
				for key, v in pairs(trace.Entity.DoorData) do
					if not ply.DRP_DoorMemory[trace.Entity][key] or ply.DRP_DoorMemory[trace.Entity][key] ~= v then
						ply.DRP_DoorMemory[trace.Entity][key] = v
						umsg.Start("DRP_UpdateDoorData", ply)
							umsg.Entity(trace.Entity)
							umsg.String(key)
							umsg.String(tostring(v))
						umsg.End()
					end
				end
				
				for key, v in pairs(ply.DRP_DoorMemory[trace.Entity]) do
					if not trace.Entity.DoorData[key] then
						ply.DRP_DoorMemory[trace.Entity][key] = nil
						umsg.Start("DRP_UpdateDoorData", ply)
							umsg.Entity(trace.Entity)
							umsg.String(key)
							umsg.String("nil")
						umsg.End()
					end
				end
			end
		elseif ply.LookingAtDoor ~= trace.Entity then
			ply.LookingAtDoor = nil
		end
	end
end
timer.Create("RP_DoorCheck", 0.1, 0, PlayerDoorCheck)

function GM:GetFallDamage( ply, flFallSpeed )
	if GetConVarNumber("mp_falldamage") == 1 then
		return flFallSpeed / 15
	end
	return 10
end