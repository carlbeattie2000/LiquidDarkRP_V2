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

  -- Setting menu_w & menu_h to frame vaules
  menu_w, menu_h = WARN_MENU.mainFrame:GetWide(), WARN_MENU.mainFrame:GetTall()

end

net.Receive("open_h_warn", function()

  WARN_MENU.openMenu()

end)