AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	local b = LDRP_SH.Rocks[self.RockType]
	if !b then self:Remove() return end
	
	self:SetModel(b.mdl);
	self:SetColor(b.clr)
	self:SetMaterial(b.mat)
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self.Picks = 0
	
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then phys:EnableMotion(false) phys:Wake() end
end

function ENT:OnRemove()
	local p = self:GetPos()
	if table.HasValue(LDRP_SH.SpawnedRockPositions, p) then
		table.remove(LDRP_SH.SpawnedRockPositions, table.KeyFromValue(LDRP_SH.SpawnedRockPositions, p))
	end
end