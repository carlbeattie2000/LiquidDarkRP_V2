include("shared.lua")

function ENT:Initialize()
  self:initVars()
  if not self.DisplayName or self.DisplayName == "" then
      self.DisplayName = DarkRP.getPhrase("money_printer")
  end
  if not self.basePrintingSpeedUpgradeCost or self.basePrintingSpeedUpgradeCost == 0 then
    self.basePrintingSpeedUpgradeCost = 1000
  end
  if not self.baseAmountUpgradeCost or self.baseAmountUpgradeCost == 0 then
    self.baseAmountUpgradeCost = 1500
  end
end

local camStart3D2D = cam.Start3D2D
local camEnd3D2D = cam.End3D2D
local drawWordBox = draw.WordBox
local IsValid = IsValid

local color_red = Color(140,0,0,100)
local color_black = Color(0, 0, 0, 255)
local color_white = color_white

function getMaxUpgradeCost(upgradeCostIncreasePercentage, currentLevel, multiplier, cost, maxLevel)

  local totalCost = 0

  for i=currentLevel, maxLevel-1 do
    totalCost = math.floor(totalCost + cost * multiplier)
    multiplier = multiplier + upgradeCostIncreasePercentage
  end

  return totalCost

end

-- Key positions
KeyPos = {
  {-7.6480612754822, -9.1568565368652, 2.4226548671722, 8.7944097518921}, -- speed single upgrade
  {-5.528715133667, -7.0363802909851, 2.4226548671722,8.7944097518921}, -- speed multi upgrade
  {-2.1360957622528, -3.7002625465393, 2.4226548671722, 8.7944097518921}, -- amount single upgrade,
  {0.19977407157421, -1.3419948816299, 2.4226548671722, 8.7944097518921}, -- amount multiple upgrade
}

function ENT:Draw()
  self:DrawModel()

  local distance = self:GetPos():Distance( LocalPlayer():GetPos() )
  
  if (distance > 300) then
    return
  end

  local Pos = self:GetPos()
  local Ang = self:GetAngles()

  local owner = self:Getowning_ent()
  owner = (IsValid(owner) and owner:Nick()) or DarkRP.getPhrase("unknown")

  -- Printer variables
  local moneyPrinted = self:GetMoneyPrintedAmount() or 0

  local printingSpeedLevel = self:GetPrintingSpeedLevel()
  local printingAmountLevel = self:GetPrintingAmountLevel()

  local maxPrintingSpeedCost = getMaxUpgradeCost(self.upgradeCostIncreasePercentage, printingSpeedLevel, self:GetPrintingSpeedCostMultiplier(), self.basePrintingSpeedUpgradeCost, self.upgradeLevelLimit)
  local maxPrintingAmountCost = getMaxUpgradeCost(self.upgradeCostIncreasePercentage, printingAmountLevel, self:GetPrintingAmountCostMultiplier(), self.baseAmountUpgradeCost, self.upgradeLevelLimit)

  local upgradeLevelLimit = self.upgradeLevelLimit

  surface.SetFont("HUDNumber5")

  local textBox1 = self.DisplayName .. "\n\n" .. owner
  local textBox1Width = surface.GetTextSize(textBox1)

  local text = self.DisplayName
  -- local TextWidth = surface.GetTextSize(text)
  -- local TextWidth2 = surface.GetTextSize(owner)
  local TextWidth3 = surface.GetTextSize(moneyPrinted)

  Ang:RotateAroundAxis(Ang:Up(), 90)

  camStart3D2D(Pos + Ang:Up() * 6, Ang, 0.08)
    local DrawButtons = distance < 150
    local tr =  LocalPlayer():GetEyeTrace()
    local pos = self.Entity:WorldToLocal(tr.HitPos)
    
    local key=0

    if (pos.z>0 and pos.z<10 and DrawButtons) then
      for i=1, #KeyPos do
        if pos.x < KeyPos[i][1] and pos.x > KeyPos[i][2] and pos.y > KeyPos[i][3] and pos.y < KeyPos[i][4] then
          key = i
          break
        end
      end
    end

    hook.Add( "Tick", tostring(self:EntIndex()), function()
      if Entity( 1 ):KeyPressed( IN_USE ) then
        if (key == 1) then
          -- Printing Speed Single Upgrade
          if (self and IsValid(self.Entity)) then
            RunConsoleCommand("moneyprinter_supgrade", self:EntIndex(), "false")
          end
        end
        if (key == 2) then
          -- Printing Speed Multiple Upgrade
          if (self and IsValid(self.Entity)) then
            RunConsoleCommand("moneyprinter_supgrade", self:EntIndex(), "true")
          end
        end
        if (key == 3) then
          -- Amount Single Upgrade
          if (self and IsValid(self.Entity)) then
            RunConsoleCommand("moneyprinter_aupgrade", self:EntIndex(), "false")
          end
        end
        if (key == 4) then
          -- Amount Multiple Upgrade
          if (self and IsValid(self.Entity)) then
            RunConsoleCommand("moneyprinter_aupgrade", self:EntIndex(), "true")
          end
        end
      end
    end )

    surface.SetDrawColor( Color(33, 33, 33, 170) )
    surface.DrawRect(-115, -200, 230, 70)
    surface.DrawRect(-115, -120, 230, 60)
    surface.DrawRect(-115, -50, 230, 60)
    -- Printer name, owner name
    draw.DrawText( self.DisplayName, "ScoreboardDefault", -110, -200, Color(255, 255, 255, 255)  )
    draw.DrawText( owner, "ScoreboardDefault", -110, -170, Color(255, 255, 255, 255)  )
    -- Upgrade actions -- SPEED
    draw.DrawText( "Speed: ", "ScoreboardDefault", -110, -110, Color(255, 255, 255, 255)  )
    draw.DrawText( printingSpeedLevel, "Default", -80, -80, Color(255, 255, 255, 255)  )
    if (printingSpeedLevel < self.upgradeLevelLimit) then
      -- Draw upgrade button
      surface.SetDrawColor( Color(34, 95, 236, 255) )
      surface.DrawRect(30, -115, 80, 20)
      draw.DrawText( "$" .. (math.floor(self.basePrintingSpeedUpgradeCost * self:GetPrintingSpeedCostMultiplier())), "ScoreboardDefault", 30, -115, Color(255, 255, 255, 255)  )
      surface.SetDrawColor( Color(247, 0, 255, 255) )
      surface.DrawRect(30, -85, 80, 20)
      draw.DrawText( "$" .. maxPrintingSpeedCost, "ScoreboardDefault", 30, -85, Color(255, 255, 255, 255)  )
    end

     -- Upgrade actions -- Printing Amount
     draw.DrawText( "Amount: ", "ScoreboardDefault", -110, -40, Color(255, 255, 255, 255)  )
     draw.DrawText( printingAmountLevel, "Default", -80, -10, Color(255, 255, 255, 255)  )
     if (printingAmountLevel < self.upgradeLevelLimit) then
        -- Draw upgrade button
      surface.SetDrawColor( Color(34, 95, 236, 255) )
      surface.DrawRect(30, -45, 80, 20)
      draw.DrawText( "$" .. (math.floor(self.baseAmountUpgradeCost * self:GetPrintingAmountCostMultiplier())), "ScoreboardDefault", 30, -45, Color(255, 255, 255, 255)  )
      surface.SetDrawColor( Color(247, 0, 255, 255) )
      surface.DrawRect(30, -15, 80, 20)
      draw.DrawText( "$" .. maxPrintingAmountCost, "ScoreboardDefault", 30, -15, Color(255, 255, 255, 255)  )
     end
  camEnd3D2D()

  Ang:RotateAroundAxis(Ang:Forward(), 70)

  camStart3D2D(Pos + Ang:Up() * 13.5 - Ang:Right() * -2 - Ang:Forward() * 0, Ang, 0.11)
      -- drawWordBox(4, -TextWidth3 * 0.5, -30, moneyPrinted, "HUDNumber5", color_black, color_white)
      surface.SetDrawColor( Color(33, 33, 33, 235) )
      surface.DrawRect(-100, -40, 200, 50)
      draw.DrawText( "$" .. moneyPrinted, "ScoreboardDefault", -90, -25, Color(255, 255, 255, 255)  )
  camEnd3D2D()
end

function ENT:Think()
end

