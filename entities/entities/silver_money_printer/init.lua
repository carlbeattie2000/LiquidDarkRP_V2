AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.SpawnOffset = Vector(15, 0, 15)

function ENT:Initialize()

  self:initVars()

  self:SetModel("models/props_c17/consolebox05a.mdl")
  self:SetMaterial("models/shiny")
  self:SetColor( Color(192, 192, 192, 255) )

  DarkRP.ValidatedPhysicsInit(self, SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)

  local phys = self:GetPhysicsObject()

  self.timer = CurTime()

  if phys:IsValid() then
      phys:Wake()
  end

  self:SetPrinterDamage(100)

  -- Set printer upgrade network vars
  self:SetPrintingSpeedCostMultiplier(1)
  self:SetPrintingAmountCostMultiplier(1)

  self:SetPrintingSpeedLevel(1)
  self:SetPrintingAmountLevel(1)
  -- Assume the max level is 12
  -- And that the multiplier increases by 0.25

end

-- DarkRP Functions
function canAfford(ply, amount)
  local PLAYER = FindMetaTable("Player")
	if type(PLAYER.CanAfford) == "function" then
		return ply:CanAfford(amount)
	else
		return ply:canAfford(amount)
	end
end

function calculateUpgradeMaxCost(upgradeIncreasePercentage, levelsToUpgrade, multiplier, baseUpgradeCost)
  local totalCost = 0

  for i=0, levelsToUpgrade do
   totalCost = totalCost + baseUpgradeCost * multiplier
   multiplier = multiplier + upgradeIncreasePercentage
  end

  return totalCost
end

function ENT:Think()
  self:initVars()

  local currentTime = CurTime()
  local secondsPassed = self.timer + (self.printTime / self:GetPrintingSpeedLevel())

  if currentTime > secondsPassed then

    self.timer = CurTime()
  
    self:SetMoneyPrintedAmount(self:GetMoneyPrintedAmount() + (self.printAmount * self:GetPrintingAmountLevel()))

  end

end

function ENT:Use(act, call)
  if (self:GetMoneyPrintedAmount() == 0 ) then
    return
  end

  local money = self:GetMoneyPrintedAmount()
  self:SetMoneyPrintedAmount(0)

  call:addMoney(money)

  DarkRP.notify(call, 3, 5, "$" .. money .. " collected from printer")

end

function ENT:SUpgrade(ply, max)
  self:initVars()

  if (self:GetPrintingSpeedLevel() >= self.upgradeLevelLimit) then
    DarkRP.notify(ply, 5, 5, "Printer already at max level!")
    return
  end

  local totalCost = math.floor(self.basePrintingSpeedUpgradeCost * self:GetPrintingSpeedCostMultiplier())
  local levelsToUpgrade = 1

  if (max) then
    levelsToUpgrade = self.upgradeLevelLimit - self:GetPrintingSpeedLevel()

    totalCost = math.floor(calculateUpgradeMaxCost(self.upgradeCostIncreasePercentage, levelsToUpgrade, self:GetPrintingSpeedCostMultiplier(), self.basePrintingSpeedUpgradeCost))
  end

  if (not canAfford(ply, totalCost)) then
    DarkRP.notify(ply, 5, 5, "Cannot afford upgrade")
    return
  end

  self:SetPrintingSpeedCostMultiplier(self:GetPrintingSpeedCostMultiplier() + self.upgradeCostIncreasePercentage)
  self:SetPrintingSpeedLevel(self:GetPrintingSpeedLevel() + levelsToUpgrade)
  ply:addMoney(-totalCost)

end

function ENT:AUpgrade(ply, max)
  self:initVars()

  if (self:GetPrintingAmountLevel() >= self.upgradeLevelLimit) then
    DarkRP.notify(ply, 5, 5, "Printer already at max level!")
    return
  end

  local totalCost = math.floor(self.baseAmountUpgradeCost * self:GetPrintingAmountCostMultiplier())
  local levelsToUpgrade = 1

  if (max) then
    levelsToUpgrade = self.upgradeLevelLimit - self:GetPrintingAmountLevel()

    totalCost = math.floor(calculateUpgradeMaxCost(self.upgradeCostIncreasePercentage, levelsToUpgrade, self:GetPrintingAmountCostMultiplier(), self.baseAmountUpgradeCost))
  end

  if (not canAfford(ply, totalCost)) then
    DarkRP.notify(ply, 5, 5, "Cannot afford upgrade")
    return
  end

  self:SetPrintingAmountCostMultiplier(self:GetPrintingAmountCostMultiplier() + self.upgradeCostIncreasePercentage)
  self:SetPrintingAmountLevel(self:GetPrintingAmountLevel() + levelsToUpgrade)
  ply:addMoney(-totalCost)

end

function ENT:OnTakeDamage(dmg)
  self:TakePhysicsDamage(dmg)

  self:SetPrinterDamage(self:GetPrinterDamage() - dmg:GetDamage())

  if self:GetPrinterDamage() <= 0 then
    self:Destruct()
    self:Remove()
  end

end

function ENT:Destruct()

  local vPoint = self:GetPos()
  local effectdata = EffectData()

  effectdata:SetStart(vPoint)
  effectdata:SetOrigin(vPoint)
  effectdata:SetScale(1)

  util.Effect("Explosion", effectdata)

  if IsValid(self:Getowning_ent()) then DarkRP.notify(self:Getowning_ent(), 1, 4, DarkRP.getPhrase("money_printer_exploded")) end

end

concommand.Add("moneyprinter_supgrade", function(ply, cmd, args)
  upgradeToMax = false

  if (args[2] == "true") then
    upgradeToMax = true
  end

  local ent = Entity(tonumber(args[1]))

  if(ent:GetPos():Distance( ply:GetPos() ) < 160) then
    ent:SUpgrade(ply, upgradeToMax)
  end
end )

concommand.Add("moneyprinter_aupgrade", function(ply, cmd, args)
  upgradeToMax = false

  if (args[2] == "true") then
    upgradeToMax = true
  end

  local ent = Entity( tonumber(args[1]) )

  if (ent:GetPos():Distance( ply:GetPos() ) < 160) then
    ent:AUpgrade(ply, upgradeToMax)
  end
end )