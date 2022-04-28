AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_wasteland/controlroom_desk001a.mdl");
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then phys:EnableMotion(false) phys:Wake() end
	
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
end
