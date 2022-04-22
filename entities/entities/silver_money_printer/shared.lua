ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "carlbeattie2000"

ENT.PrintName = "SilverPrinter"

ENT.Spawnable = false

function ENT:initVars()
  self.printAmount = 4
  self.printTime = 7
  self.model = ""
  self.DisplayName = "Silver Printer"
  self.damage = 120
  self.upgradeLevelLimit = 12
  self.upgradeCostIncreasePercentage = 0.50
  self.basePrintingSpeedUpgradeCost = 850
  self.baseAmountUpgradeCost = 1150
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