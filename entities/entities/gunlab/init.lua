AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/TrapPropeller_Engine.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()

	self.Entity.dt.price = 200
	if phys and phys:IsValid() then phys:Wake() end

	self.sparking = false
	self.damage = 100
end

function ENT:OnTakeDamage(dmg)
	self.damage = self.damage - dmg:GetDamage()
	if (self.damage <= 0) then
		self.Entity:Destruct()
		self.Entity:Remove()
	end
end

function ENT:Destruct()
	local vPoint = self.Entity:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
end

function ENT:SalePrice(activator)
	local owner = self.Entity.dt.owning_ent
	local discounted = math.ceil(185 * 0.88)

	if activator == owner then
		if activator:Team() == TEAM_GUN then
			return discounted
		else
			return 185
		end
	else
		return self.dt.price
	end
end

ENT.Once = false
function ENT:Use(activator)
	local owner = self.Entity.dt.owning_ent
	local discounted = math.ceil(185 * 0.88)
	local cash = self:SalePrice(activator)
	
	if not activator:CanAfford(self:SalePrice(activator)) then
		Notify(activator, 1, 3, "You do not have enough money to purchase this gun.")
		return ""
	end
	local diff = (self:SalePrice(activator) - self:SalePrice(owner))
	if diff < 0 and not owner:CanAfford(math.abs(diff)) then
		Notify(activator, 2, 3, "Gun Lab owner is too poor to subsidize this sale!")
		return ""
	end
	self.sparking = true
	
	if not self.Once then
		self.Once = true
		activator:AddMoney(cash * -1)
		Notify(activator, 0, 3, "You purchased a P228 for " .. CUR .. tostring(cash) .. "!")
		
		if activator ~= owner then
			local gain = 0
			if owner:Team() == TEAM_GUN then
				gain = math.floor(self.dt.price - discounted)
			else
				gain = math.floor(self.dt.price - 185)
			end
			if gain == 0 then
				Notify(owner, 3, 3, "You sold a P228 but made no profit!")
			else
				owner:AddMoney(gain)
				local word = "profit"
				if gain < 0 then word = "loss" end
				Notify(owner, 0, 3, "You made a " .. word .. " of " .. CUR .. tostring(math.abs(gain)) .. " by selling a P228 from a Gun Lab!")
			end
		end
	end
	timer.Create(self.Entity:EntIndex() .. "spawned_weapon", 1, 1, function() self:createGun() end)
end

function ENT:createGun()
	self.Once = false
	local gun = ents.Create("spawned_weapon")
	gun = ents.Create("spawned_weapon")
	gun:SetModel("models/weapons/w_pist_p228.mdl")
	gun.weaponclass = "weapon_real_cs_p228"
	local gunPos = self.Entity:GetPos()
	gun:SetPos(Vector(gunPos.x, gunPos.y, gunPos.z + 27))
	gun.ShareGravgun = true
	gun.nodupe = true
	gun:Spawn()
	self.sparking = false
end

function ENT:Think()
	if self.sparking then
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetRadius(2)
		util.Effect("Sparks", effectdata)
	end
end

function ENT:OnRemove()
	if not IsValid(self) then return end
	timer.Destroy(self:EntIndex() .. "spawned_weapon")
end