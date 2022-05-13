local WARN_MENU = WARN_MENU || {}

WARN_MENU.baseWidth = function() return ScrW() * .6 end
WARN_MENU.baseHeight = function() return ScrH() * .6 end

function WARN_MENU.openMenu()
  
  if IsValid(WARN_MENU.mainFrame) then WARN_MENU.mainFrame:Close() return end

  local menu_w, menu_h = WARN_MENU.baseWidth(), WARN_MENU.baseHeight()

  WARN_MENU.mainFrame = vgui.Create("DFrame")

  WARN_MENU.mainFrame:SetSize(menu_w, menu_h)
  WARN_MENU.mainFrame:Center()
  WARN_MENU.mainFrame:MakePopup()
  WARN_MENU.mainFrame:SetTitle("")
  WARN_MENU.mainFrame:ShowCloseButton(false)
  WARN_MENU.mainFrame:SetSizable(false)
  WARN_MENU.mainFrame:SetDraggable(false)

  -- Setting menu_w & menu_h to frame vaules
  menu_w, menu_h = WARN_MENU.mainFrame:GetWide(), WARN_MENU.mainFrame:GetTall()

  function WARN_MENU.mainFrame:Paint(w, h)

    local menuTopBarHeight = REBELLION.GetScaledHeight(40)

    draw.RoundedBox(2, 0, 0, w, menuTopBarHeight, Color(213, 100, 100))

    draw.SimpleText("Rebellion Warns", "Trebuchet24", w/2, menuTopBarHeight/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.RoundedBox(0, 0, menuTopBarHeight, w, h-menuTopBarHeight, Color(100, 100, 100))
  
  end

  -- frame close button
  local mainFrameCloseBtn = vgui.Create("DButton", WARN_MENU.mainFrame)

  mainFrameCloseBtn:SetSize(REBELLION.GetScaledWidth(50), REBELLION.GetScaledHeight(40))
  mainFrameCloseBtn:SetPos(menu_w - REBELLION.GetScaledWidth(50), 0)
  mainFrameCloseBtn:SetText("")

  function mainFrameCloseBtn:Paint(w, h)
  
    draw.RoundedBox(0, 0, 0, w, h, Color(255, 70, 50))

    draw.SimpleText("X", "DermaDefault", w/2, h/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  
  end

  mainFrameCloseBtn.DoClick = function()

    WARN_MENU.mainFrame:Close()
  
  end

  -- Players list scroll section

  WARN_MENU.playerSideBarList = vgui.Create("DScrollPanel", WARN_MENU.mainFrame)

  WARN_MENU.playerSideBarList:SetPos(0, REBELLION.GetScaledHeight(40))
  WARN_MENU.playerSideBarList:SetSize(menu_w * .3, menu_h - REBELLION.GetScaledHeight(40))

  function WARN_MENU.playerSideBarList:Paint(w, h)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawLine(w-1, 0, w-1, h)
  
  end

  function WARN_MENU.playerSideBarList:PopulatePlayers()

    local playersList = player.GetAll()

    for i, v in ipairs(playersList) do

     local playerNameBtn = WARN_MENU.playerSideBarList:Add("DButton")

     playerNameBtn:SetSize(WARN_MENU.playerSideBarList:GetWide(), REBELLION.GetScaledHeight(40))
     playerNameBtn:SetText("")
     playerNameBtn:Dock(TOP)

     function playerNameBtn:Paint(w, h)

        draw.RoundedBox(2, 0, 5, w-1, h-5, Color(60, 60, 60, 200))

        draw.SimpleText(v:Nick(), "Trebuchet18", w/2, (h/2)+2.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

     end

     playerNameBtn.DoClick = function()
     
      WARN_MENU.playerWarnInformation:UpdatePlayerInformation(v)
     
     end

    end

  end

  WARN_MENU.playerSideBarList:PopulatePlayers()

  WARN_MENU.playerWarnInformation = vgui.Create("DScrollPanel", WARN_MENU.mainFrame)

  WARN_MENU.playerWarnInformation:SetSize(menu_w - (menu_w * .3), menu_h - REBELLION.GetScaledHeight(40))
  WARN_MENU.playerWarnInformation:SetPos(menu_w * .3, REBELLION.GetScaledHeight(40))

  function WARN_MENU.playerWarnInformation:UpdatePlayerInformation(ply)

    if (IsValid(self)) then self:Clear() end

    local playerInformationFrame = vgui.Create("DPanel", self)

    playerInformationFrame:SetSize(self:GetWide() - 10, self:GetTall() - 10)
    playerInformationFrame:SetPos(5, 5) 

    local playerNickDisplay = vgui.Create("DPanel", playerInformationFrame)

    playerNickDisplay:SetSize(self:GetWide(), 50)

    function playerNickDisplay:Paint(w, h)

      draw.SimpleText(ply:Nick(), "Trebuchet24", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    
    end
    
  end

end

net.Receive("open_r_warn", function()

  WARN_MENU.openMenu()

end)