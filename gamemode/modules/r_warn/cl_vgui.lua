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

end

net.Receive("open_h_warn", function()

  WARN_MENU.openMenu()

end)