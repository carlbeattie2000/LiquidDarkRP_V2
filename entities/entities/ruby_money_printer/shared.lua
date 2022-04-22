ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "carlbeattie2000"

ENT.PrintName = "RubyPrinter"

ENT.Spawnable = false

function ENT:initVars()
  self.printAmount = 8
  self.printTime = 6
  self.model = ""
  self.DisplayName = "Ruby Printer"
  self.damage = 160
  self.upgradeLevelLimit = 12
  self.upgradeCostIncreasePercentage = 0.70
  self.basePrintingSpeedUpgradeCost = 1200
  self.baseAmountUpgradeCost = 1400
end

function ENT:SetupDataTables()
  self:NetworkVar("Int", 8, "PrinterDamage")
  self:NetworkVar("Int", 7, "MoneyPrintedAmount")

  self:NetworkVar("Float", 3, "PrintingSpeedCostMultiplier")
  self:NetworkVar("Float", 2, "PrintingAmountCostMultiplier")

  self:NetworkVar("Int", 3, "PrintingSpeedLevel")
  self:NetworkVar("Int", 2, "PrintingAmountLevel")

  self:NetworkVar("Entity", 0, "owning_ent")

end