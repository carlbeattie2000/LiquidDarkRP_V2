local WARN_MENU = WARN_MENU or {};
WARN_MENU.baseWidth = function() return ScrW() * .6; end;
WARN_MENU.baseHeight = function() return ScrH() * .6; end;
-- Warn popup, for editing or creating a new warn
function WARN_MENU.openWarnPopup(ply, wType)
  local typeName;
  local typeButtonName;
  if wType == "edit" then
    typeName = string.format("Edit %s's warn", ply:Nick());
    typeButtonName = "Edit Warn";
    -- Will load warn here
  else
    typeName = string.format("Warning player: %s", ply:Nick());
    typeButtonName = "Warn";
  end

  if not IsValid(ply) then return; end
  if IsValid(WARN_MENU.warnPopupMenu) then
    WARN_MENU.warnPopupMenu:Close();
    return;
  end

  local selectedReason = nil;
  local customReason = nil;
  -- Warn Popup Config
  local menu_w, menu_h = ScrW() * .25, ScrH() * .25;
  WARN_MENU.warnPopupMenu = vgui.Create("DFrame");
  WARN_MENU.warnPopupMenu:SetSize(menu_w, menu_h);
  WARN_MENU.warnPopupMenu:MakePopup();
  WARN_MENU.warnPopupMenu:Center();
  WARN_MENU.warnPopupMenu:SetSizable(false);
  WARN_MENU.warnPopupMenu:SetDraggable(false);
  WARN_MENU.warnPopupMenu:SetTitle("");
  WARN_MENU.warnPopupMenu:ShowCloseButton(false);
  function WARN_MENU.warnPopupMenu:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 10, 255));
  end

  local header_w, header_h = menu_w, menu_h * .1;
  -- Warn Menu Header (close, title)
  local warnMenuHeader = vgui.Create("DPanel", WARN_MENU.warnPopupMenu);
  warnMenuHeader:SetSize(header_w, header_h);
  function warnMenuHeader:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 255));
  end

  -- Warn Menu Header Close Button
  local warnMenuHeaderCloseBtn = vgui.Create("DButton", warnMenuHeader);
  warnMenuHeaderCloseBtn:SetText("");
  warnMenuHeaderCloseBtn:SetSize(header_w * .15, header_h);
  warnMenuHeaderCloseBtn:SetPos(header_w - warnMenuHeaderCloseBtn:GetWide(), 0);
  function warnMenuHeaderCloseBtn:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(213, 100, 100, 255));
    draw.SimpleText("X", "Trebuchet18", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  end

  warnMenuHeaderCloseBtn.DoClick = function() WARN_MENU.warnPopupMenu:Close(); end;
  -- Main Warn Popup Content (playername, warn message, warn)
  local warnPopupContent = vgui.Create("DPanel", WARN_MENU.warnPopupMenu);
  warnPopupContent:SetSize(menu_w, menu_h - header_h);
  warnPopupContent:SetPos(0, menu_h * .12);
  local playersName = vgui.Create("DLabel", warnPopupContent);
  playersName:SetSize(menu_w, menu_h * .09);
  playersName:SetText("");
  playersName:Dock(TOP);
  playersName:DockMargin(2, 0, 0, 2);
  local playersNameText = string.format(typeName, ply:Nick());
  function playersName:Paint(w, h)
    draw.SimpleText(playersNameText, "Trebuchet18", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP);
  end

  local reason = vgui.Create("DLabel", warnPopupContent);
  reason:SetSize(menu_w, menu_h * .09);
  reason:SetText("");
  reason:Dock(TOP);
  reason:DockMargin(2, 0, 0, 2);
  function reason:Paint()
    draw.SimpleText("Reason", "Trebuchet18", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP);
  end

  local reasonListBColor = Color(213, 100, 100, 255);
  local reasonListFColor = Color(255, 255, 255, 255);
  local reasonsList = cUtils.funcs.PrettyComboBox(warnPopupContent, 0, 0, warnPopupContent:GetWide(), menu_h * .2, "Select a reason (Optional)", WARN_REASONS, "Trebuchet18", reasonListBColor, reasonListFColor, reasonListBColor, reasonListFColor, Color(100, 213, 100, 255), Color(255, 255, 255, 255), function(value) selectedReason = value; end, TOP, 2);
  local reasonEntry = cUtils.funcs.PrettyTextBox(warnPopupContent, "", 0, 0, warnPopupContent:GetWide(), menu_h * .2, "Trebuchet18", Color(213, 100, 100), Color(255, 255, 255), function(value) selectedReason = value; end, TOP, 2);
  local warnButton = vgui.Create("DButton", warnPopupContent);
  warnButton:SetSize(menu_w, menu_h * .15);
  warnButton:Dock(BOTTOM);
  warnButton:DockMargin(2, 2, 2, 2);
  warnButton:SetText("");
  function warnButton:Paint(w, h)
    local fColor = Color(255, 255, 255);
    draw.RoundedBox(0, 0, 0, w, h - 5, Color(213, 100, 100));
    draw.SimpleText(typeButtonName, "Trebuchet18", w / 2, (h - 5) / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  end

  warnButton.DoClick = function()
    if selectedReason == "" or selectedReason == nil then return; end
    if wType == "edit" then
      -- Send SQL Update
      local reason = reasonEntry:GetText() or reason:GetSelected();
    else
      -- Send New SQL Entry
      RunConsoleCommand("warn", ply:Nick(), selectedReason);
    end

    RunConsoleCommand("load_player_warns", ply:Nick());
  end;
end

function WARN_MENU.openMenu()
  if IsValid(WARN_MENU.mainFrame) then
    WARN_MENU.mainFrame:Close();
    return;
  end

  local selectedPlayer = nil;
  local scrw, scrh = ScrW(), ScrH();
  local menu_w, menu_h = WARN_MENU.baseWidth(), WARN_MENU.baseHeight();
  -- Main frame config
  WARN_MENU.mainFrame = vgui.Create("DFrame");
  WARN_MENU.mainFrame:SetSize(menu_w, menu_h);
  WARN_MENU.mainFrame:Center();
  WARN_MENU.mainFrame:MakePopup();
  WARN_MENU.mainFrame:SetTitle("");
  WARN_MENU.mainFrame:ShowCloseButton(false);
  WARN_MENU.mainFrame:SetSizable(false);
  WARN_MENU.mainFrame:SetDraggable(false);
  -- Setting menu_w & menu_h to frame vaules
  menu_w, menu_h = WARN_MENU.mainFrame:GetWide(), WARN_MENU.mainFrame:GetTall();
  function WARN_MENU.mainFrame:Paint(w, h)
    local menuTopBarHeight = REBELLION.GetScaledHeight(40);
    draw.RoundedBox(2, 0, 0, w, menuTopBarHeight, Color(213, 100, 100));
    draw.SimpleText("Rebellion Warns", "Trebuchet24", w / 2, menuTopBarHeight / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
    draw.RoundedBox(0, 0, menuTopBarHeight, w, h - menuTopBarHeight, Color(100, 100, 100));
  end

  -- frame close button
  local mainFrameCloseBtn = vgui.Create("DButton", WARN_MENU.mainFrame);
  mainFrameCloseBtn:SetSize(REBELLION.GetScaledWidth(50), REBELLION.GetScaledHeight(40));
  mainFrameCloseBtn:SetPos(menu_w - REBELLION.GetScaledWidth(50), 0);
  mainFrameCloseBtn:SetText("");
  function mainFrameCloseBtn:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(255, 70, 50));
    draw.SimpleText("X", "DermaDefault", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  end

  mainFrameCloseBtn.DoClick = function() WARN_MENU.mainFrame:Close(); end;
  -- Online Players list scroll section
  WARN_MENU.playerSideBarList = vgui.Create("DScrollPanel", WARN_MENU.mainFrame);
  WARN_MENU.playerSideBarList:SetPos(0, REBELLION.GetScaledHeight(40));
  WARN_MENU.playerSideBarList:SetSize(menu_w * .3, menu_h - REBELLION.GetScaledHeight(100));
  cUtils.funcs.EditScrollBarStyle(WARN_MENU.playerSideBarList, Color(213, 100, 100, 255));
  function WARN_MENU.playerSideBarList:Paint(w, h)
    surface.SetDrawColor(255, 255, 255, 255);
    surface.DrawLine(w - 1, 0, w - 1, h);
  end

  -- >> Populate the players list
  function WARN_MENU.playerSideBarList:PopulatePlayers()
    local playersList = player.GetAll();
    selectedPlayer = playersList[1];
    for i, v in ipairs(playersList) do
      local playerNameBtn = WARN_MENU.playerSideBarList:Add("DButton");
      playerNameBtn:SetSize(WARN_MENU.playerSideBarList:GetWide(), REBELLION.GetScaledHeight(40));
      playerNameBtn:SetText("");
      playerNameBtn:Dock(TOP);
      function playerNameBtn:Paint(w, h)
        draw.RoundedBox(2, 0, 5, w - 1, h - 5, Color(60, 60, 60, 200));
        draw.SimpleText(v:Nick(), "Trebuchet18", w / 2, (h / 2) + 2.5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
      end

      playerNameBtn.DoClick = function()
        selectedPlayer = v;
        RunConsoleCommand("load_player_warns", v:Nick());
        if IsValid(WARN_MENU.warnPopupMenu) then
          WARN_MENU.warnPopupMenu:Close();
          return;
        end
      end;
    end
  end

  WARN_MENU.playerSideBarList:PopulatePlayers();
  -- Warn button for current selected player
  WARN_MENU.warnPlayerButton = vgui.Create("DButton", WARN_MENU.mainFrame);
  WARN_MENU.warnPlayerButton:SetSize(menu_w * .3 - 10, REBELLION.GetScaledHeight(50));
  WARN_MENU.warnPlayerButton:SetPos(5, menu_h - REBELLION.GetScaledHeight(55));
  WARN_MENU.warnPlayerButton:SetText("");
  function WARN_MENU.warnPlayerButton:Paint(w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(213, 100, 100, 255));
    draw.SimpleText("Warn Player", "Trebuchet24", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  end

  WARN_MENU.warnPlayerButton.DoClick = function() WARN_MENU.openWarnPopup(selectedPlayer); end;
  -- Player Information Panel
  WARN_MENU.playerWarnInformation = vgui.Create("DPanel", WARN_MENU.mainFrame);
  WARN_MENU.playerWarnInformation:SetSize(menu_w - (menu_w * .3), menu_h - REBELLION.GetScaledHeight(40));
  WARN_MENU.playerWarnInformation:SetPos(menu_w * .3, REBELLION.GetScaledHeight(40));
  function WARN_MENU.playerWarnInformation:UpdatePlayerInformation(ply, warns)
    local playerWarns = warns or {};
    local activeWarns, totalWarns, lastWarnString, lastWarnSeconds = 0, 0, "", 0;
    for k, v in pairs(warns) do
      if v["active"] then activeWarns = activeWarns + 1; end
      if tonumber(v["warn_time"]) > lastWarnSeconds then lastWarnSeconds = tonumber(v["warn_time"]); end
      totalWarns = totalWarns + 1;
    end

    lastWarnString = formatTimeFromSeconds(getTimeDifferenceFromPastDateToCurrent(lastWarnSeconds));
    if IsValid(self) then self:Clear(); end
    -- Player Information Scroll Panel
    local playerInformationScroll = vgui.Create("DScrollPanel", self);
    local pInfoW = self:GetWide() - 10;
    local pInfoH = self:GetTall() - 10;
    playerInformationScroll:SetSize(pInfoW, pInfoH);
    playerInformationScroll:SetPos(5, 5);
    function playerInformationScroll:Paint(w, h)
      draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0));
    end

    -- Set player data loaded form SQL variable
    cUtils.funcs.EditScrollBarStyle(playerInformationScroll);
    -- Selected Players Name
    local selectedPlayersName = playerInformationScroll:Add("DPanel");
    selectedPlayersName:SetSize(pInfoW, 30);
    selectedPlayersName:Dock(TOP);
    function selectedPlayersName:Paint(w, h)
      draw.SimpleText(ply:Nick(), "Trebuchet24", 0, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
    end

    -- Selected players last warn
    local selectedPlayersLastWarn = playerInformationScroll:Add("DPanel");
    selectedPlayersLastWarn:SetSize(pInfoW, 30);
    selectedPlayersLastWarn:Dock(TOP);
    function selectedPlayersLastWarn:Paint(w, h)
      draw.SimpleText(string.format("Last Warn: %s", lastWarnString), "Trebuchet24", 0, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
    end

    -- Selected players total and current warns
    local selectedPlayersTotalAnCurrentWarns = playerInformationScroll:Add("DPanel");
    selectedPlayersTotalAnCurrentWarns:SetSize(pInfoW, 30);
    selectedPlayersTotalAnCurrentWarns:Dock(TOP);
    function selectedPlayersTotalAnCurrentWarns:Paint(w, h)
      local formattedText = markup.Parse(string.format("<font=Trebuchet24>Active: <color=213,100,100,255>%s</color> Total: %s</font>", activeWarns, totalWarns));
      formattedText:Draw(0, h / 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 255);
    end

    local playerWarnsGrid = playerInformationScroll:Add("DListView");
    playerWarnsGrid:Dock(TOP);
    playerWarnsGrid:DockMargin(2, 2, 2, 2);
    playerWarnsGrid:SetSize(pInfoW, pInfoH * .75);
    playerWarnsGrid:SetSortable(false);
    playerWarnsGrid:AddColumn("Warn ID");
    playerWarnsGrid:AddColumn("Warn Reason");
    playerWarnsGrid:AddColumn("Warn Date");
    playerWarnsGrid:AddColumn("Warn Active");
    playerWarnsGrid:AddColumn("Warner");
    function playerWarnsGrid:Paint(w, h)
      draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0));
    end

    for k, v in pairs(warns) do
      local active = false;
      if v["active"] then active = true; end
      playerWarnsGrid:AddLine(v["id"], v["reason"], v["warn_time"], active, v["warner_nick"]);
    end

    for i, v in ipairs(playerWarnsGrid.Columns) do
      function v.Header:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(213, 100, 100));
        draw.SimpleText(v.Header:GetText(), "Trebuchet18", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
        return true;
      end
    end

    for i, v in ipairs(playerWarnsGrid.Lines) do
      function v:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255));
      end

      for _, v1 in ipairs(v.Columns) do
        function v1:Paint(w, h)
          draw.SimpleText(v1:GetText(), "Trebuchet18", 5, h / 2, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
          surface.SetDrawColor(0, 0, 0, 255);
          surface.DrawLine(w - 1, 0, w - 1, h);
          return true;
        end
      end
    end
  end

  -- Load first player, so player information panel is not empty
  local defaultPlayer = player.GetAll()[1];
  RunConsoleCommand("load_player_warns", defaultPlayer:Nick());
  net.Receive("r_player_warns_table", function() WARN_MENU.playerWarnInformation:UpdatePlayerInformation(defaultPlayer, net.ReadTable()); end);
end

net.Receive("open_r_warn", function() WARN_MENU.openMenu(); end);
-- Warned Chat
net.Receive("r_chat_warn", function()
  local formattedChatWarnString = net.ReadString();
  chat.AddText(Color(213, 100, 100), "[REBELLION]", Color(255, 255, 255), " " .. formattedChatWarnString);
end);
