AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_junk/garbage_takeoutcarton001a.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()

	if phys and phys:IsValid() then phys:Wake() end

	self.damage = 10
end

function ENT:OnTakeDamage(dmg)
	self.damage = self.damage - dmg:GetDamage()

	if (self.damage <= 0) then
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetMagnitude(2)
		effectdata:SetScale(2)
		effectdata:SetRadius(3)
		util.Effect("Sparks", effectdata)
		self.Entity:Remove()
	end
end

function ENT:Use(activator,caller)
	if PooPee then PooPee.AteFood(caller, "models/props_junk/garbage_takeoutcarton001a.mdl") end
	if GetConVarNumber("hungermod") == 0 then		
		caller:SetHealth(caller:Health() + (100 - caller:Health()))		
	else		
		caller:SetDarkRPVar("Energy", math.Clamp(caller.DarkRPVars.Energy + 100, 0, 100))		
		umsg.Start("AteFoodIcon", caller)		
		umsg.End()		
	end	
	self.Entity:Remove()
end

function ENT:OnRemove()
	local ply = self.Entity.dt.owning_ent
	ply.maxFoods = ply.maxFoods and ply.maxFoods - 1 or 0
end