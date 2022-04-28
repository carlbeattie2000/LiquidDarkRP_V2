AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props/cs_office/microwave.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	local phys = self.Entity:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
	self.sparking = false
	self.damage = 100
	self.Entity.dt.price = math.Clamp((GetConVarNumber("pricemin") ~= 0 and GetConVarNumber("pricemin")) or 30, (GetConVarNumber("pricecap") ~= 0 and GetConVarNumber("pricecap")) or 30)
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
	local discounted = math.ceil(GetConVarNumber("microwavefoodcost") * 0.82)

	if activator == owner then
		-- If they are still a cook, sell them the food at the discounted rate
		if activator:Team() == TEAM_COOK then
			return discounted
		else -- Otherwise, sell it to them at full price
			return math.floor(GetConVarNumber("microwavefoodcost"))
		end
	else
		return self.dt.price
	end
end

ENT.Once = false
function ENT:Use(activator,caller)
	local owner = self.Entity.dt.owning_ent
	self.user = activator
	if not activator:CanAfford(self:SalePrice(activator)) then
		Notify(activator, 1, 3, "You do not have enough money to purchase food!")
		return ""
	end
	local diff = (self:SalePrice(activator) - self:SalePrice(owner))
	if diff < 0 and not owner:CanAfford(math.abs(diff)) then
		Notify(activator, 2, 3, "Microwave owner is too poor to subsidize this sale!")
		return ""
	end
	if activator.maxFoods and activator.maxFoods >= GetConVarNumber("maxfoods") then
		Notify(activator, 1, 3, "You have reached the food limit.")
	elseif not self.Once then
		self.Once = true
		self.sparking = true
		
		local discounted = math.ceil(GetConVarNumber("microwavefoodcost") * 0.82)
		local cash = self:SalePrice(activator)

		activator:AddMoney(cash * -1)
		Notify(activator, 0, 3, "You have purchased food for " .. CUR .. tostring(cash) .. "!")

		if activator ~= owner then
			local gain = 0
			if owner:Team() == TEAM_COOK then
				gain = math.floor(self.dt.price - discounted)
			else
				gain = math.floor(self.dt.price - GetConVarNumber("microwavefoodcost"))
			end
			if gain == 0 then
				Notify(owner, 2, 3, "You sold some food but made no profit!")
			else
				owner:AddMoney(gain)
				local word = "profit"
				if gain < 0 then word = "loss" end
				Notify(owner, 0, 3, "You made a " .. word .. " of " .. CUR .. tostring(math.abs(gain)) .. " by selling food!")
			end
		end
		timer.Create(self.Entity:EntIndex() .. "food", 1, 1, self.createFood, self)
	end
end

function ENT:createFood()
	activator = self.user
	self.Once = false
	local foodPos = self.Entity:GetPos()
	food = ents.Create("food")
	food:SetPos(Vector(foodPos.x,foodPos.y,foodPos.z + 23))
	food.dt.owning_ent = activator
	food.ShareGravgun = true
	food.nodupe = true
	food:Spawn()
	if not activator.maxFoods then
		activator.maxFoods = 0
	end
	activator.maxFoods = activator.maxFoods + 1
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
	timer.Destroy(self.Entity:EntIndex())
	local ply = self.Entity.dt.owning_ent
	if not IsValid(ply) then return end
end