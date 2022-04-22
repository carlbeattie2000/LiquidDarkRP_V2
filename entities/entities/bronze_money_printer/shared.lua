ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "carlbeattie2000"

ENT.PrintName = "BronzePrinter"

ENT.Spawnable = false

function ENT:initVars()
  self.printAmount = 2
  self.printTime = 7
  self.model = ""
  self.DisplayName = "Bronze Printer"
  self.damage = 100
  self.upgradeLevelLimit = 12
  self.upgradeCostIncreasePercentage = 0.40
  self.basePrintingSpeedUpgradeCost = 600
  self.baseAmountUpgradeCost = 1000
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