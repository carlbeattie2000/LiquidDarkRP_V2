AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/paper01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self.Entity:GetPhysicsObject()

	if phys and phys:IsValid() then phys:Wake() end
	local ply = self.Entity.dt.owning_ent
end

function ENT:OnRemove()
	local ply = self.Entity.dt.owning_ent
	if not IsValid(ply) then return end
	if not ply.maxletters then
		ply.maxletters = 0
	end
	ply.maxletters = ply.maxletters - 1
end

function ENT:Use(ply)
	if not ply:KeyDown(IN_ATTACK) then
		umsg.Start("ShowLetter", ply)
			umsg.Entity(self)
			umsg.Short(self.type)
			umsg.Vector(self:GetPos())
			local numParts = self.numPts
			umsg.Short(numParts)
			for a,b in pairs(self.Parts) do umsg.String(b) end
		umsg.End()
	else
		umsg.Start("KillLetter", ply)
		umsg.End()
	end
end


function ENT:SignLetter(ply)
	self.dt.signed = ply
end

concommand.Add("_DarkRP_SignLetter", function(ply, cmd, args)
	if not args[1] then return end
	local letter = ents.GetByIndex(tonumber(args[1]))
	
	letter:SignLetter(ply)
end)
