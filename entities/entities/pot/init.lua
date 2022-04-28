AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/nater/weedplant_pot_dirt.mdl");
	self.Entity:SetUseType( SIMPLE_USE )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.CanUse = true
	
	local phys = self.Entity:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
end

function ENT:MakeUpRight()
	self:SetAngles(Angle(0,0,0))
	self:SetPos(self:GetPos()+Vector(0,0,2))
	self:GetPhysicsObject():Wake()
end

local function TimerCheck(plant)
	local E = plant:EntIndex()
	if timer.Exists("PotGrowth_" .. E) then timer.Remove("PotGrowth_" .. E) end
	if timer.Exists("PotGrowth2_" .. E) then timer.Remove("PotGrowth2_" .. E) end
	if timer.Exists("MovePlant_" .. E) then timer.Remove("MovePlant_" .. E) end
	if timer.Exists("KillPlant_" .. E) then timer.Remove("KillPlant_" .. E) end
end

function ENT:Use(ply, caller)
	local Check = (self.DrugType and LDRP_SH.AllGrowableItems[self.DrugType])
	
	if Check and Check.name and (ply:Team() == TEAM_POLICE or ply:Team() == TEAM_CHIEF) and self.DrugType and Check.illegal then
		ply:AddMoney(Check.confiscated)
		ply:LiquidChat("GAME", Color(0,200,200), "Earned $" .. Check.confiscated .. " for confiscated illegal item: " .. Check.name)
		self:Remove()
		return false
	end
	if !self.CanUse then return end
	local cropped = "Picked up"
	local pickedup = "a pot"
	
	if !ply:CanCarry("pot",1) then
		ply:LiquidChat("GAME", Color(0,200,200), "You need to free up inventory space before picking this up.")
		return
	end
	local atend = "."
	if Check then
		crop = Check.crop
		crops = Check.cropam
		if !ply:CanCarry(crop,crops) then
			ply:LiquidChat("GAME", Color(0,200,200), "You need to free up inventory space before cropping this.")
			return
		end
		
		if !self.Complete then
			atend = " (unfinished plant)"
			crops = math.Round(crops*.5)
		elseif self.Dead then
			atend = " (dead plant)"
			crops = math.Round(crops*.35)
		elseif math.random(1,10) <= Check.seedchance and ply:CanCarry(self.DrugType,1) then
			atend = " and 1 seed."
			ply:AddItem(self.DrugType,1)
		end
		TimerCheck(self)
		cropped = "Cropped"
		if self.RealPlant and self.RealPlant:IsValid() then
			self.RealPlant:Remove()
		end
		
		pickedup = crops .. " " .. crop .. "s"
		
		ply:AddItem(crop,crops)
		
		local Owner = (self.dt and self.dt.owning_ent) or self.Owner
	
		if Owner and Owner:IsValid() then
			Owner.Growing[self.DrugType] = Owner.Growing[self.DrugType]-1
			if ply == Owner then
				Owner:GiveEXP("Growing",Check.exp,true)
			end
		end
		
	end
	self.Dead = nil
	self.DrugType = nil
	self.Complete = nil

	if pickedup == "a pot" then
		ply:AddItem("pot",1)
		self.Entity:Remove()
	else
		self:MakeUpRight()
	end
	
	ply:LiquidChat("GAME", Color(0,200,200), cropped .. " " .. pickedup .. atend)
end

local function PlantNameID(Type)
	if tonumber(Type) then
		return LDRP_SH.PlantIDs[Type]
	else
		return table.KeyFromValue(LDRP_SH.PlantIDs, Type)
	end
end

function ENT:StartTouch(entity)
	local b = entity.ItemType
	local Tbl = LDRP_SH.AllGrowableItems[b]
	local ply = (self.dt and self.dt.owning_ent) or self.Entity.Owner
	if self.DrugType or !b or !Tbl or !ply or !ply:IsValid() then return end
	entity:SetNotSolid(true)
	if ply.Growing and ply.Growing[b] and ply.Growing[b] >= Tbl.max then ply:LiquidChat("GAME", Color(0,200,200), "You can only grow " .. Tbl.max .. " " .. Tbl.name .. "s at a time.") entity:SetNotSolid(false) return false end

	if ply.Character.Skills.Growing.lvl < Tbl.reqlvl then ply:LiquidChat("GAME", Color(0,200,200), "You must have atleast " .. Tbl.reqlvl .. " growing to grow a " .. Tbl.name) entity:SetNotSolid(false) return false end
	if Tbl.illegal and table.HasValue(Tbl.illegal, ply:Team()) then ply:LiquidChat("GAME", Color(0,200,200), "This item is illegal for you!") entity:SetNotSolid(false) return false end
	if Tbl.reqteams and !table.HasValue(Tbl.reqteams, ply:Team()) then ply:LiquidChat("GAME", Color(0,200,200), "You can not grow this as your current job!") entity:SetNotSolid(false) return false end

	entity:Remove()
	self.DrugType = b
	
	self.CanUse = false

	local ActualPlant = ents.Create("plants")
	ActualPlant:SetNotSolid(true)
	ActualPlant:SetMoveType(MOVETYPE_NONE)
	ActualPlant:SetParent(self)
	self:MakeUpRight()
	ActualPlant:SetPos(self:GetPos() + Tbl.plantpos)
	ActualPlant:SetModel(Tbl.plantmdl)
	ActualPlant:SetAngles(self:GetAngles())
	ActualPlant:Spawn()
	
	ActualPlant.dt.plantnum = PlantNameID(b)
	
	self.RealPlant = ActualPlant
	
	local EID = self.Entity:EntIndex()
	if b == "weed seed" then
		timer.Create("MovePlant_" .. EID, math.Round(Tbl.time*.2)*60, 5, function()
			if !ActualPlant or !ActualPlant:IsValid() then timer.Remove("MovePlant_" .. EID) return end
			if self and self:IsValid() then
				self:MakeUpRight()
				ActualPlant:SetPos(ActualPlant:GetPos()+Vector(0,0,2.5))
			else
				timer.Remove("MovePlant_" .. EID)
			end
		end)
	end
	
	timer.Create("PotGrowth_" .. EID, math.Round(Tbl.time*.8)*60, 1, function()
		if self and self:IsValid() then
			self.CanUse = true
			timer.Create("PotGrowth2_" .. EID, math.Round(Tbl.time*.2)*60, 1, function()
				if self and self:IsValid() then
					self.Complete = true
					timer.Create("KillPlant_" .. EID, math.Round(Tbl.time*.35)*60, 1, function()
						if self and self:IsValid() then
							self.Dead = true
						end
					end)
				end
			end)
		end
	end)
	ply.Growing[b] = (ply.Growing[b] and ply.Growing[b]+1) or 1
	
end

function ENT:OnRemove()
	if self.RealPlant and self.RealPlant:IsValid() then self.RealPlant:Remove() end
	TimerCheck(self)
	local b = self.DrugType
	local o = self.Entity.dt.owning_ent
	if b and o and o:IsValid() and o.Growing then
		o.Growing[b] = o.Growing[b]-1
	end
end