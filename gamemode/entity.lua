/*---------------------------------------------------------
 Shared part
 ---------------------------------------------------------*/
local meta = FindMetaTable("Entity")

function meta:IsOwnable()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	if (class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating") or
		(GAMEMODE.Config.allowvehicleowning and self:IsVehicle()) then
			return true
		end
	return false
end

function meta:IsDoor()
	if not IsValid(self) then return false end
	local class = self:GetClass()

	if class == "func_door" or
		class == "func_door_rotating" or
		class == "prop_door_rotating" or
		class == "prop_dynamic" then
		return true
	end
	return false
end

function meta:DoorIndex()
	return self:EntIndex() - game.MaxPlayers()
end

function GM:DoorToEntIndex(num)
	return num + game.MaxPlayers()
end

function meta:IsOwned()
	self.DoorData = self.DoorData or {}

	if IsValid(self.DoorData.Owner) then return true end

	return false
end

function meta:GetDoorOwner()
	if not IsValid(self) then return end
	self.DoorData = self.DoorData or {}
	return self.DoorData.Owner
end

function meta:IsMasterOwner(ply)
	if ply == self:GetDoorOwner() then
		return true
	end

	return false
end

function meta:OwnedBy(ply)
	if ply == self:GetDoorOwner() then return true end
	self.DoorData = self.DoorData or {}
	
	if self.DoorData.ExtraOwners then
		local People = string.Explode(";", self.DoorData.ExtraOwners)
		for k,v in pairs(People) do
			if tonumber(v) == ply:UserID() then return true end
		end
	end

	return false
end

function meta:AllowedToOwn(ply)
	self.DoorData = self.DoorData or {}
	if not self.DoorData then return false end
	if self.DoorData.AllowedToOwn and string.find(self.DoorData.AllowedToOwn, ply:UserID()) then
		return true
	end
	return false
end

/*---------------------------------------------------------
 Serverside part
 ---------------------------------------------------------*/
if CLIENT then 
	function meta:DrawOwnableInfo()
		local pos = {x = ScrW()/2, y = ScrH() / 2}
		
		local ownerstr = ""

		if IsValid(self:GetDoorOwner()) and self:GetDoorOwner().Nick then
			ownerstr = self:GetDoorOwner():Nick() .. "\n"
		end

		for k,v in pairs(player.GetAll()) do
			if self:OwnedBy(v) and v ~= self:GetDoorOwner() then
				ownerstr = ownerstr .. v:Nick() .. "\n"
			end
		end
		
		if type(self.DoorData.AllowedToOwn) == "string" and self.DoorData.AllowedToOwn ~= "" and self.DoorData.AllowedToOwn ~= ";" then
			local names = {}
			for a,b in pairs(string.Explode(";", self.DoorData.AllowedToOwn)) do
				if IsValid(Player(b)) then
					table.insert(names, Player(b):Nick())
				end
			end
			ownerstr = ownerstr .. string.format(LANGUAGE.keys_other_allowed).. table.concat(names, "\n").."\n"
		elseif type(self.DoorData.AllowedToOwn) == "number" and IsValid(Player(self.DoorData.AllowedToOwn)) then
			ownerstr = ownerstr .. string.format(LANGUAGE.keys_other_allowed)..Player(self.DoorData.AllowedToOwn):Nick().."\n"
		end

		if not LocalPlayer():InVehicle() then
			local blocked = self.DoorData.NonOwnable
			local st = nil
			local whiteText = false -- false for red, true for white text
			
			self.DoorData.title = self.DoorData.title or ""
			
			if self:IsOwned() then
				whiteText = true
				if superAdmin then
					if blocked then
						st = self.DoorData.title .. "\n"..LANGUAGE.keys_allow_ownership
					else
						if ownerstr == "" then
							st = self.DoorData.title .. "\n"..LANGUAGE.keys_disallow_ownership .. "\n"
						else
							if self:OwnedBy(LocalPlayer()) and not self.DoorData.GroupOwn then
								st = self.DoorData.title .. "\n".. LANGUAGE.keys_owned_by .."\n" .. ownerstr
							elseif not self.DoorData.GroupOwn then
								st = self.DoorData.title .. "\n".. LANGUAGE.keys_owned_by .."\n" .. ownerstr .. LANGUAGE.keys_disallow_ownership .. "\n"
							elseif not self:IsVehicle() then
								st = self.DoorData.title .. "\n" .. self.DoorData.GroupOwn .. "\n" .. LANGUAGE.keys_disallow_ownership .. "\n"
							end
						end
						if self.DoorData.GroupOwn and not self:IsVehicle() then
							st = st .. LANGUAGE.keys_everyone
						elseif not self:IsVehicle() and self.DoorData.GroupOwn then
							st = st .. self.DoorData.GroupOwn
						end
					end
				else
					if blocked then
						st = self.DoorData.title
					else
						if ownerstr == "" then
							st = self.DoorData.title
						else
							if self.DoorData.GroupOwn then
								whiteText = true
								st = self.DoorData.title .. "\n".. LANGUAGE.keys_owned_by .."\n" .. self.DoorData.GroupOwn
							else
								st = self.DoorData.title .. "\n".. LANGUAGE.keys_owned_by .."\n" .. ownerstr
							end
						end
					end
				end
			else
				if superAdmin then
					if blocked then
						whiteText = true
						st = self.DoorData.title .. "\n".. LANGUAGE.keys_allow_ownership
					else
						if self.DoorData.GroupOwn then
							whiteText = true
							st = self.DoorData.title .. "\n".. LANGUAGE.keys_owned_by .."\n" .. self.DoorData.GroupOwn
							if not self:IsVehicle() then
								st = st .. "\n".. LANGUAGE.keys_everyone
							end
						else
							st = LANGUAGE.keys_unowned.."\n".. LANGUAGE.keys_disallow_ownership
							if not self:IsVehicle() then
								st = st .. "\n"..LANGUAGE.keys_cops
							end
						end
					end
				else
					if blocked then
						whiteText = true
						st = self.DoorData.title
					else
						if self.DoorData.GroupOwn then
							whiteText = true
							st = self.DoorData.title .. "\n".. LANGUAGE.keys_owned_by .."\n" .. self.DoorData.GroupOwn
						else
							st = LANGUAGE.keys_unowned
						end
					end
				end
			end

			st = string.Replace(st,"\n\n","\n")
			local strs = string.Explode("\n",st)
			
			for k,v in pairs(strs) do
				draw.SimpleTextOutlined( v, "Trebuchet22", ScrW()*.5, ScrH()*.5-(#strs*9)+((k > 1 and (k-1)*18.9) or 0), (whiteText and Color(255, 255, 255, 255)) or Color(40, 170, 225, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
			end
			
			
		end
	end

	return 
end

local time = false
local function SetDoorOwnable(ply)
	if time then return "" end
	time = true
	timer.Simple(0.1, function()  time = false end)
	local trace = ply:GetEyeTrace()
	if not IsValid(trace.Entity) then return "" end
	local ent = trace.Entity
	if ply:IsSuperAdmin() and (ent:IsDoor() or ent:IsVehicle()) and ply:GetPos():Distance(ent:GetPos()) < 115 then
		ent.DoorData = ent.DoorData or {}
		ent.DoorData.NonOwnable = not ent.DoorData.NonOwnable 
		-- Save it for future map loads
		DB.StoreDoorOwnability(ent)
	end
	ent:UnOwn()
	ply.LookingAtDoor = nil -- Send the new data to the client who is looking at the door :D
	return ""
end
AddChatCommand("/toggleownable", SetDoorOwnable)

local time3 = false
local function SetDoorGroupOwnable(ply, arg)
	if time3 then return "" end
	time3 = true
	timer.Simple(0.1, function() time3 = false end)

	local trace = ply:GetEyeTrace()
	if not IsValid(trace.Entity) then return "" end

	if not ply:HasPriv("rp_doorManipulation") then
		GAMEMODE:Notify(ply, 1, 4, "You need the rp_doorManipulation privilege")
		return ""
	end

	local ent = trace.Entity

	if (not ent:IsDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 115 then return end

	if not RPExtraTeamDoors[arg] and arg ~= "" then Notify(ply, 1, 10, "Door group does not exist!") return "" end

	trace.Entity:UnOwn()


	ent.DoorData = ent.DoorData or {}
	ent.DoorData.TeamOwn = nil
	ent.DoorData.GroupOwn = arg

	if arg == "" then
		ent.DoorData.GroupOwn = nil
		ent.DoorData.TeamOwn = nil
	end

	-- Save it for future map loads
	DB.SetDoorGroup(ent, arg)
	DB.StoreTeamDoorOwnability(ent)

	ply.LookingAtDoor = nil

	GAMEMODE:Notify(ply, 0, 8, "Door group set successfully")
	return ""
end
AddChatCommand("/togglegroupownable", SetDoorGroupOwnable)

local time2 = false
local function OwnDoor(ply)
	if time2 then return "" end
	time2 = true
	timer.Simple(0.1, function()  time2 = false end)
	
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 200 then
		trace.Entity.DoorData = trace.Entity.DoorData or {}
		if RPArrestedPlayers[ply:SteamID()] then
			Notify(ply, 1, 5, LANGUAGE.door_unown_arrested)
			return ""
		end

		if trace.Entity.DoorData.NonOwnable or (trace.Entity.DoorData.GroupOwn and not table.HasValue(RPExtraTeamDoors[trace.Entity.DoorData.GroupOwn], ply:Team())) then
			Notify(ply, 1, 5, LANGUAGE.door_unownable)
			return ""
		end

		if trace.Entity:OwnedBy(ply) then
			
			trace.Entity:Fire("unlock", "", 0)
			trace.Entity:UnOwn(ply)
			ply:GetTable().Ownedz[trace.Entity:EntIndex()] = nil
			ply:GetTable().OwnedNumz = math.abs(ply:GetTable().OwnedNumz - 1)
			local GiveMoneyBack = (((trace.Entity:IsVehicle() and GAMEMODE.Config.vehiclecost) or GAMEMODE.Config.doorcost) * 0.666) + 0.5
			ply:AddMoney(math.floor(GiveMoneyBack))
			Notify(ply, 0, 4, string.format(LANGUAGE.door_sold,  CUR .. math.floor(math.floor(GiveMoneyBack))))
			ply.LookingAtDoor = nil
		else
			if trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(ply) then
				Notify(ply, 1, 4, LANGUAGE.door_already_owned)
				return ""
			end
			if trace.Entity:IsVehicle() then
				if not ply:CanAfford(GAMEMODE.Config.vehiclecost) then
					Notify(ply, 1, 4, LANGUAGE.vehicle_cannot_afford)
					return ""
				end
			else
				if not ply:CanAfford(GAMEMODE.Config.doorcost) then
					Notify(ply, 1, 4, LANGUAGE.door_cannot_afford)
					return ""
				end
			end

			if trace.Entity:IsVehicle() then
				ply:AddMoney(-GAMEMODE.Config.vehiclecost)
				Notify(ply, 0, 4, string.format(LANGUAGE.vehicle_bought, CUR .. math.floor(GAMEMODE.Config.vehiclecost)))
			else
				ply:AddMoney(-GAMEMODE.Config.doorcost)
				Notify(ply, 0, 4, string.format(LANGUAGE.door_bought, CUR .. math.floor(GAMEMODE.Config.doorcost)))
			end
			trace.Entity:Own(ply)

			if ply:GetTable().OwnedNumz == 0 then
				timer.Create(ply:SteamID() .. "propertytax", 270, 0, ply.DoPropertyTax, ply)
			end

			ply:GetTable().OwnedNumz = ply:GetTable().OwnedNumz + 1

			ply:GetTable().Ownedz[trace.Entity:EntIndex()] = trace.Entity
		end
		ply.LookingAtDoor = nil
		return ""
	end
	Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "vehicle/door"))
	return ""
end
AddChatCommand("/toggleown", OwnDoor)

local function UnOwnAll(ply, cmd, args)
	local amount = 0
	for k,v in pairs(ents.GetAll()) do
		if v:OwnedBy(ply) then
			amount = amount + 1
			v:Fire("unlock", "", 0)
			v:UnOwn(ply)
			ply:AddMoney(math.floor(((GAMEMODE.Config.doorcost * 0.66666666666666)+0.5)))
			ply:GetTable().Ownedz[v:EntIndex()] = nil
		end
	end
	ply:GetTable().OwnedNumz = 0
	Notify(ply, 2, 4, string.format("You have sold "..amount.." doors for " .. CUR .. amount * math.floor(((GAMEMODE.Config.doorcost * 0.66666666666666)+0.5)) .. "!"))
	return ""
end
AddChatCommand("/unownalldoors", UnOwnAll)

function meta:UnOwn(ply)
	self.DoorData = self.DoorData or {}
	if not ply then
		ply = self:GetDoorOwner()

		if not IsValid(ply) then return end
	end

	if self:IsMasterOwner(ply) then
		self.DoorData.Owner = nil
	else
		self:RemoveOwner(ply)
	end

	local num = 0

	self:RemoveOwner(ply)
	ply.LookingAtDoor = nil
end

function meta:AddAllowed(ply)
	self.DoorData = self.DoorData or {}
	self.DoorData.AllowedToOwn = self.DoorData.AllowedToOwn and self.DoorData.AllowedToOwn .. ";" .. tostring(ply:UserID()) or tostring(ply:UserID())
end

function meta:RemoveAllowed(ply)
	self.DoorData = self.DoorData or {}
	if self.DoorData.AllowedToOwn then self.DoorData.AllowedToOwn = string.gsub(self.DoorData.AllowedToOwn, tostring(ply:UserID())..".?", "") end
	if string.sub(self.DoorData.AllowedToOwn, -1) == ";" then self.DoorData.AllowedToOwn = string.sub(self.DoorData.AllowedToOwn, 1, -2) end
end

function meta:AddOwner(ply)
	if not IsValid(self) then return end
	self.DoorData = self.DoorData or {}
	self.DoorData.ExtraOwners = self.DoorData.ExtraOwners and self.DoorData.ExtraOwners .. ";" .. tostring(ply:UserID()) or tostring(ply:UserID())
	self:RemoveAllowed(ply)
end

function meta:RemoveOwner(ply)
	if not IsValid(self) then return end
	self.DoorData = self.DoorData or {}
	if self.DoorData.ExtraOwners then self.DoorData.ExtraOwners = string.gsub(self.DoorData.ExtraOwners, tostring(ply:UserID())..".?", "") end
	if string.sub(self.DoorData.ExtraOwners or "", -1) == ";" then self.DoorData.ExtraOwners = string.sub(self.DoorData.ExtraOwners, 1, -2) end
end

function meta:Own(ply)
	self.DoorData = self.DoorData or {}
	if self:AllowedToOwn(ply) then
		self:AddOwner(ply)
		return
	end

	if not self:IsOwned() and not self:OwnedBy(ply) then
		self.DoorData.Owner = ply
	end
end


local function SetDoorTitle(ply, args)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		trace.Entity.DoorData = trace.Entity.DoorData or {}
		if ply:IsSuperAdmin() then
			if trace.Entity.DoorData.NonOwnable or trace.Entity.DoorData.GroupOwn or trace.Entity.DoorData.TeamOwn then
				DB.StoreDoorTitle(trace.Entity, args)
				ply.LookingAtDoor = nil
				return ""
			end
		elseif trace.Entity.DoorData.NonOwnable then
			GAMEMODE:Notify(ply, 1, 6, string.format(LANGUAGE.need_admin, "/title"))
		end

		if trace.Entity:OwnedBy(ply) then
			trace.Entity.DoorData.title = args
		else
			GAMEMODE:Notify(ply, 1, 6, string.format(LANGUAGE.door_need_to_own, "/title"))
		end
	end

	ply.LookingAtDoor = nil
	return ""
end
AddChatCommand("/title", SetDoorTitle)

local function RemoveDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		trace.Entity.DoorData = trace.Entity.DoorData or {}
		target = GAMEMODE:FindPlayer(args)

		if trace.Entity.DoorData.NonOwnable then
			Notify(ply, 1, 4, LANGUAGE.door_rem_owners_unownable)
		end

		if target then
			if trace.Entity:OwnedBy(ply) then
				if trace.Entity:AllowedToOwn(target) then
					trace.Entity:RemoveAllowed(target)
				end

				if trace.Entity:OwnedBy(target) then
					trace.Entity:RemoveOwner(target)
				end
			else
				Notify(ply, 1, 4, LANGUAGE.do_not_own_ent)
			end
		else
			Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		end
	end
	
	ply.LookingAtDoor = nil
	return ""
end
AddChatCommand("/removeowner", RemoveDoorOwner)
AddChatCommand("/ro", RemoveDoorOwner)

local function AddDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		trace.Entity.DoorData = trace.Entity.DoorData or {}
		target = GAMEMODE:FindPlayer(args)
		if target then
			if trace.Entity.DoorData.NonOwnable then
				Notify(ply, 1, 4, LANGUAGE.door_add_owners_unownable)
				return ""
			end

			if trace.Entity:OwnedBy(ply) then
				if not trace.Entity:OwnedBy(target) and not trace.Entity:AllowedToOwn(target) then
					trace.Entity:AddAllowed(target)
				else
					Notify(ply, 1, 4, string.format(LANGUAGE.rp_addowner_already_owns_door, ply:Nick()))
				end
			else
				Notify(ply, 1, 4, LANGUAGE.do_not_own_ent)
			end
		else
			Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		end
	end
	
	ply.LookingAtDoor = nil
	return ""
end
AddChatCommand("/addowner", AddDoorOwner)
AddChatCommand("/ao", AddDoorOwner)