AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:Initialize()

	self:SetModel("models/props_c17/consolebox05a.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then

		phys:Wake()

	end

	self.printerTimer = CurTime()
	self.printTime = 5
	self.moneyAdd = 1000
end


function ENT:Use( activator, caller )
	
	if self:Getmoney() > 0 then

		activator:AddMoney(self:Getmoney())

		self:Setmoney(0)

	end

end

function ENT:Think()
	
	if CurTime() > self.printerTimer + self.printTime then

		self:Setmoney(self:Getmoney() + self.moneyAdd)

		self.printerTimer = CurTime()

	end

end