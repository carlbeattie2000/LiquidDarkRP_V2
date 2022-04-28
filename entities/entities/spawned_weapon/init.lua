AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	local phys = self.Entity:GetPhysicsObject()

	if phys and phys:IsValid() then phys:Wake() end
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) 
end

function ENT:DecreaseAmount()
	local amount = self.dt.amount

	self.dt.amount = amount - 1

	if self.dt.amount <= 0 then
		self:Remove()
	end
end

function ENT:Use(ply,caller)
	local class = self.Entity.weaponclass
	local ammohax = self.Entity.ammohacked
	local cancarry = ply:CanCarry(class,1)
	local item = LDRP_SH.ItemTable( class )
	
	if item and item.cuse then --Actually "use" the item before picking it up.
		item.use( ply )
		self:Remove()
		ply:LiquidChat("GAME", Color(0,200,200), "Equipped a weapon.")
		return
	end
	
	if cancarry then
		self:Remove()
		ply:LiquidChat("GAME", Color(0,200,200), "Picked up a weapon.")
		ply:AddItem(class,1)
	elseif cancarry == nil then --Player attempted to pick up an item not in LDRP's item database, try DarkRP's weapon pickup code
		if type(self.PlayerUse) == "function" then
			local val = self:PlayerUse(ply, caller)
			if val ~= nil then return val end
			elseif self.PlayerUse ~= nil then
			return self.PlayerUse
		end

		local class = self.weaponclass
		local weapon = ents.Create(class)

		if not weapon:IsValid() then return false end

		if not weapon:IsWeapon() then
			weapon:SetPos(self:GetPos())
			weapon:SetAngles(self:GetAngles())
			weapon:Spawn()
			weapon:Activate()
			self:DecreaseAmount()
			return
		end

		local CanPickup = hook.Call("PlayerCanPickupWeapon", GAMEMODE, ply, weapon)
		if not CanPickup then return end
		weapon:Remove()

		ply:Give(class)
		weapon = ply:GetWeapon(class)

		if self.clip1 then
			weapon:SetClip1(self.clip1)
			weapon:SetClip2(self.clip2 or -1)
		end

		ply:GiveAmmo(self.ammoadd or 0, weapon:GetPrimaryAmmoType())

		self:DecreaseAmount()
	else
		ply:LiquidChat("GAME", Color(0,200,200), "You need to free up inventory space to pick this up.")
	end
end
