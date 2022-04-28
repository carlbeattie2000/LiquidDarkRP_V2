-- ========================
-- =          Crate SENT by Mahalis
-- ========================

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity.Destructed = false
	self.Entity:SetModel("models/Items/item_item_crate.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.locked = false
	self.damage = 100
	self.Entity.ShareGravgun = true
	local phys = self.Entity:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
end

function ENT:OnTakeDamage(dmg)
	self.damage = self.damage - dmg:GetDamage()
	if self.damage <= 0 then
		self.Entity:Destruct()
	end
end

function ENT:SetContents(s, c, w)
	self.Entity.dt.contents = s
	self.Entity.dt.count = c
end

function ENT:Use()
	if not self.locked then
		self.locked = true -- One activation per second
		self.sparking = true
		timer.Create(self.Entity:EntIndex() .. "crate", 1, 1, function() self:SpawnItem() end)
	end
end

function ENT:SpawnItem()
	if not IsValid(self.Entity) then return end
	timer.Destroy(self.Entity:EntIndex() .. "crate")
	self.sparking = false
	local count = self.Entity.dt.count
	local pos = self:GetPos()
	if count <= 1 then self.Entity:Remove() end
	local contents = self.Entity.dt.contents
	local weapon = ents.Create("spawned_weapon")
	
	local found = false
	for k,v in pairs(CustomShipments) do
		if k == contents then
			found = true
			weapon.weaponclass = v.entity
			weapon:SetModel(v.model)
			break
		end
	end
	if not found then weapon:Remove() end

	weapon.ShareGravgun = true
	weapon:SetPos(pos + Vector(0,0,35))
	weapon.nodupe = true
	weapon:Spawn()
	count = count - 1
	self.Entity.dt.count = count
	self.locked = false
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


function ENT:Destruct()
	if self.Entity.Destructed then return end
	self.Entity.Destructed = true
	local vPoint = self.Entity:GetPos()
	local contents = self.Entity.dt.contents
	local count = self.Entity.dt.count
	local class = nil
	local model = nil

	local Check = CustomShipments[contents]
	if Check then
		class = Check.entity
		model = Check.model
	else
		self.Entity:Remove()
		return
	end
	
	for i=1, count, 1 do
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel(model)
		weapon.weaponclass = class
		weapon.ShareGravgun = true
		weapon:SetPos(Vector(vPoint.x, vPoint.y, vPoint.z + (i*5)))
		weapon.nodupe = true
		weapon:Spawn()
	end
	self.Entity:Remove()
end
