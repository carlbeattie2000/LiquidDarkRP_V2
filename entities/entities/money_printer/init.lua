AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	local z = LDRP_SH.Printers[LDRP_SH.First]
	
	self:SetNWString("Upgrade",LDRP_SH.First)
	self:SetModel(z.mdl)
	self:SetMaterial(z.mat)
	self:SetColor(z.clr)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end
	self.sparking = false
	self.damage = 100
	self.IsMoneyPrinter = true
	timer.Simple(27, function() if IsValid( self ) then self:PrintMore() end end)
end

function ENT:OnTakeDamage( dmg )
	if self.burningup then return end

	self.damage = (self.damage or 100) - dmg:GetDamage()
	if self.damage <= 0 then
		local rnd = math.random(1, 10)
		if rnd < 3 then
			self:BurstIntoFlames()
		else
			self:Destruct()
			self:Remove()
		end
	end
end

--local physColData = nil

local speedFloor = 225 --The minimum speed to consider damaging the printer. This seems to be about a 4 foot drop.
local multiplier = 4 --When the damage is calculated, how much should it be scaled relative to the speed over the speed floor?
local collSounds = {
	"physics/metal/metal_box_break1.wav",
	"physics/metal/metal_box_break2.wav",
	"physics/metal/metal_barrel_impact_hard1.wav",
	"physics/metal/metal_sheet_impact_hard6.wav"
}

function ENT:PhysicsCollide( colData )

	--DeltaTime always seems to cap at 1 if the entity hasn't been damaged recently (recently being within a few moments)
	if colData.DeltaTime == 1 and colData.Speed >= speedFloor then
		local soundChoice = math.random( 1, #collSounds )
		self:EmitSound( collSounds[ soundChoice ], 75, 100 )
		self:TakeDamage( (colData.Speed * multiplier) / speedFloor, colData.HitEntity, nil )
	end
end

function ENT:Destruct()
	self:Ignite( 0, 0 )
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
	Notify(self.dt.owning_ent, 1, 4, "Your money printer has exploded!")
end

function ENT:BurstIntoFlames()
	if self.HasCooler then
		self.CoolerUses = self.CoolerUses-1
		if self.CoolerUses <= 0 then
			Notify(self.dt.owning_ent, 0, 4, "Your money printer was saved by a cooler, but your cooler exploded!")
			if self.HasCooler:IsValid() then self.HasCooler:Remove() end
			self.HasCooler = nil
			self.HadCooler = true
		else
			Notify(self.dt.owning_ent, 0, 4, "Your money printer was saved by a cooler (" .. self.CoolerUses .. " uses left)")
		end
		return
	end
	Notify(self.dt.owning_ent, 0, 4, "Your money printer is overheating!")
	self.burningup = true
	local burntime = math.random(8, 18)
	self:Ignite(burntime, 0)
	timer.Simple(burntime, function( ) self:Fireball() end )
end

function ENT:Fireball()
	if not self:IsOnFire() then self.burningup = false return end
	local dist = math.random(20, 280) -- Explosion radius
	self:Destruct()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), dist)) do
		if not v:IsPlayer() and not v.IsMoneyPrinter then v:Ignite(math.random(5, 22), 0) end
	end
	self:Remove()
end

function ENT:PrintMore()
	if IsValid(self) then
		self.sparking = true
		timer.Simple(3, function() if IsValid( self ) then self:CreateMoneybag() end end)
	end
end

function ENT:CreateMoneybag()
	if not IsValid(self) then return end
	if self:IsOnFire() then return end

	if math.random(1, 22) == 3 then self:BurstIntoFlames() end
	
	local amount = 0
	if LDRP_SH.Printers[self:GetNWString("Upgrade")].prnt then
		amount = LDRP_SH.Printers[self:GetNWString("Upgrade")].prnt
	end
	
	self.dt.holding = math.Clamp(self.dt.holding+amount,0,1500)
	self.sparking = false

	timer.Simple(math.random(200, 350), function( ) if IsValid( self ) then self:PrintMore() end end)
end

function ENT:Use(ply,call)
	local EID = self:EntIndex()
	if ply:Team() == TEAM_POLICE or ply:Team() == TEAM_CHIEF then
		Notify(ply, 0, 4, "Gained $" .. LDRP_SH.ConfiscateCash .. " from confiscated printer.")
		ply:AddMoney(LDRP_SH.ConfiscateCash)
		self:Remove()
		return
	end
	
	if timer.Exists("StealPrinter_" .. EID) then return end
	
	if self.dt.owning_ent != ply then
		umsg.Start("SendMeter",ply)
			umsg.String("Stealing...")
			umsg.Float(30)
		umsg.End()
		
		local sec = 0
		timer.Create("StealPrinter_" .. EID,1,0,function()
			if !ply or !ply:IsValid() then timer.Remove("StealPrinter_" .. EID) return end
			if !self or !self:IsValid() or !ply:GetEyeTrace().Entity or !ply:GetEyeTrace().Entity:IsValid() or ply:GetEyeTrace().Entity != self.Entity then
				umsg.Start("CancelMeter",ply) umsg.End()
				timer.Remove("StealPrinter_" .. EID)
				return
			end
			self:EmitSound("ambient/alarms/klaxon1.wav",60,120)
			sec = sec+1
			if sec > 29 then
				self.dt.owning_ent = ply
				Notify(ply, 0, 4, "You have succesfully stolen a printer.")
				timer.Remove("StealPrinter_" .. EID)
			end
		end)
	
		return
	end
	
	if self.dt.holding > 0 then
		local Gain = self.dt.holding
		self.dt.holding = 0
		ply:AddMoney(Gain)
		Notify(ply, 0, 4, "Gained $" .. Gain .. " from looting money printer.")
	end
end

function ENT:Think()
	if not self.sparking then return end

	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetMagnitude(1)
	effectdata:SetScale(1)
	effectdata:SetRadius(2)
	util.Effect("Sparks", effectdata)
end
