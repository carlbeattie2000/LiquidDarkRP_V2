if GM.Config.DisabledModules[R_GOVERNMENT.Config.moduleName] then return; end
local R_GOVERNMENT_CL = R_GOVERNMENT_CL or {};
function R_GOVERNMENT_CL.requestUpdatedCandidateTable()
  net.Start("request_updated_client_candidates");
  net.SendToServer();
end

function R_GOVERNMENT.requestUpdatedIsMayorActivate()
  net.Start("is_mayor_active");
  net.SendToServer();
end

--[[------------------------------------------------------------------------------
/                                                                              /
/              Join Election Menu                                             /
/                                                                            /
---------------------------------------------------------------------------]]
function R_GOVERNMENT_CL.OpenElectionMenu()
  if IsValid(R_GOVERNMENT_CL.electionMenu) then R_GOVERNMENT_CL.electionMenu:Remove(); end
  local joinElectionFee = REBELLION.numberFormat(R_GOVERNMENT.Config.VotingSettings["entry_cost"]);
  local primaryColor = Color(40, 40, 40, 245);
  local secondaryColor = Color(200, 60, 60, 245);
  local headerColor = Color(255, 255, 255, 245);
  local btnColor = Color(255, 40, 40, 245);
  local candidateNameBgColor = Color(119, 119, 119, 245);
  local scrw, scrh = ScrW(), ScrH();
  local menuw, menuh = ScrW() * .4, ScrH() * .4;
  R_GOVERNMENT_CL.electionMenu = vgui.Create("DFrame");
  R_GOVERNMENT_CL.electionMenu:SetSize(menuw, menuh);
  R_GOVERNMENT_CL.electionMenu:Center();
  R_GOVERNMENT_CL.electionMenu:MakePopup();
  R_GOVERNMENT_CL.electionMenu:ShowCloseButton(false);
  R_GOVERNMENT_CL.electionMenu:SetTitle("Mayor Elections");
  R_GOVERNMENT_CL.electionMenu:SetSizable(false);
  R_GOVERNMENT_CL.electionMenu:SetDraggable(false);
  function R_GOVERNMENT_CL.electionMenu:Paint(w, h)
    surface.SetDrawColor(primaryColor);
    surface.DrawRect(0, 0, w, h);
  end

  local electionMenuHeader = R_GOVERNMENT_CL.electionMenu:Add("DPanel");
  electionMenuHeader:SetSize(menuw, menuh * .05);
  electionMenuHeader:Dock(BOTTOM);
  function electionMenuHeader:Paint(w, h)
    surface.SetDrawColor(headerColor);
    surface.DrawRect(0, 0, w, h);
  end

  local electionMenuHeaderCloseBtn = electionMenuHeader:Add("DButton");
  electionMenuHeaderCloseBtn:SetText("");
  electionMenuHeaderCloseBtn:SetSize(menuw, electionMenuHeader:GetTall());
  function electionMenuHeaderCloseBtn:Paint(w, h)
    surface.SetDrawColor(btnColor);
    surface.DrawRect(0, 0, w, h);
    draw.SimpleText("Close", "HudSelectionText", w * .5, h * .5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  end

  electionMenuHeaderCloseBtn.DoClick = function() R_GOVERNMENT_CL.electionMenu:Remove(); end;
  --[[---------------------------------------------------------------------------

                        Is the mayor alive/active

  ---------------------------------------------------------------------------]]
  local mayorActiveDisplay = R_GOVERNMENT_CL.electionMenu:Add("DPanel");
  mayorActiveDisplay:SetSize(menuw, menuh * .1);
  mayorActiveDisplay:Dock(TOP);
  function mayorActiveDisplay:Paint(w, h)
    surface.SetDrawColor(secondaryColor);
    surface.DrawRect(0, 0, w, h);
    if R_GOVERNMENT.mayorActive then
      draw.SimpleText("Mayor is currently alive, can't start election.", "HudSelectionText", w * .5, h * .5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
    else
      draw.SimpleText("Join the election.", "HudSelectionText", w * .5, h * .5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
    end
  end

  --[[---------------------------------------------------------------------------

                        Current Candidates

  ---------------------------------------------------------------------------]]
  R_GOVERNMENT_CL.electionMenuCandidatesContainer = R_GOVERNMENT_CL.electionMenu:Add("DPanel");
  R_GOVERNMENT_CL.electionMenuCandidatesContainer:Dock(TOP);
  R_GOVERNMENT_CL.electionMenuCandidatesContainer:DockMargin(0, 5, 0, 5);
  R_GOVERNMENT_CL.electionMenuCandidatesContainer:SetSize(menuw, menuh * .3);
  local cols = 5;
  local colsSpacing = 30;
  local totalRowColSpacing = colsSpacing * cols;
  local colWidth = (menuw / cols) - colsSpacing;
  function R_GOVERNMENT_CL.electionMenuCandidatesContainer:RefreshCandidates()
    if IsValid(self) then self:Clear(); end
    local mayorCandidates = self:Add("DGrid");
    mayorCandidates:SetSize(menuw, menuh * .3);
    mayorCandidates:SetCols(cols);
    mayorCandidates:SetColWide(colWidth);
    mayorCandidates:SetPos((menuw / 2) - (menuw - totalRowColSpacing) / 2, 0);
    mayorCandidates:SetRowHeight(50);
    if tablelength(R_GOVERNMENT.candidates) == 0 then
      local noPlayersPanel = vgui.Create("DPanel");
      noPlayersPanel:SetSize(colWidth, 50);
      function noPlayersPanel:Paint(w, h)
        draw.SimpleText("No Candidates", "HudSelectionText", w * .5, h * .5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
      end

      mayorCandidates:AddItem(noPlayersPanel);
    end

    for k, v in pairs(R_GOVERNMENT.candidates) do
      local playerNamePanel = vgui.Create("DPanel");
      playerNamePanel:SetSize(colWidth, 50);
      local playerName = player.GetBySteamID(v["steam_id"]):Nick();
      function playerNamePanel:Paint(w, h)
        surface.SetDrawColor(candidateNameBgColor);
        surface.DrawRect(5, 5, w - 10, h - 10);
        draw.SimpleText(playerName, "HudSelectionText", w * .5, h * .5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
      end

      mayorCandidates:AddItem(playerNamePanel);
    end
  end

  R_GOVERNMENT_CL.electionMenuCandidatesContainer:RefreshCandidates();
  --[[---------------------------------------------------------------------------

                        Join Election

  ---------------------------------------------------------------------------]]
  R_GOVERNMENT.requestUpdatedIsMayorActivate();
  net.Receive("is_mayor_active", function() R_GOVERNMENT.mayorActive = net.ReadBool(); end);
  local joinElectionButton = R_GOVERNMENT_CL.electionMenu:Add("DButton");
  joinElectionButton:SetSize(menuw, menuh * .1);
  joinElectionButton:SetText("");
  joinElectionButton:Dock(BOTTOM);
  joinElectionButton:DockMargin(0, 10, 0, 10);
  function joinElectionButton:Paint(w, h)
    local bgColor = btnColor;
    local joinElectionText = string.format("Join election for $%s", REBELLION.numberFormat(R_GOVERNMENT.Config.VotingSettings["entry_cost"]));
    if LocalPlayer():isCandidate() then
      bgColor = Color(50, 50, 50, 245);
      joinElectionText = "You are already in this election!";
    elseif tablelength(R_GOVERNMENT.candidates) > R_GOVERNMENT.Config.VotingSettings["max_candidates"] then
      bgColor = Color(50, 50, 50, 245);
      joinElectionText = "The election list is full!";
    elseif R_GOVERNMENT.mayorActive then
      bgColor = Color(50, 50, 50, 245);
      joinElectionText = "We currently already have a mayor!";
    end

    surface.SetDrawColor(bgColor);
    surface.DrawRect(0, 0, w, h);
    draw.SimpleText(joinElectionText, "HudSelectionText", w * .5, h * .5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  end

  if LocalPlayer():isCandidate() or tablelength(R_GOVERNMENT.candidates) > R_GOVERNMENT.Config.VotingSettings["max_candidates"] or R_GOVERNMENT.mayorActive then joinElectionButton:SetEnabled(false); end
  joinElectionButton.DoClick = function() RunConsoleCommand("r_g_join_election"); end;
  R_GOVERNMENT_CL.requestUpdatedCandidateTable();
end

usermessage.Hook("SendMayorElectionMenu", R_GOVERNMENT_CL.OpenElectionMenu);
--[[------------------------------------------------------------------------------
/                                                                              /
/              Vote Window                                                    /
/                                                                            /
---------------------------------------------------------------------------]]
surface.CreateFont("vote_font", {
  font = "HudSelectionText",
  size = 20,
  weight = 600,
});

function R_GOVERNMENT_CL.OpenVoteMenu()
  if IsValid(R_GOVERNMENT_CL.voteMenu) then R_GOVERNMENT_CL.voteMenu:Remove(); end
  local voteBackground = Color(213, 100, 100, 200);
  local scrw, scrh = ScrW(), ScrH();
  local menuw, menuh = scrw, scrh * .2;
  R_GOVERNMENT_CL.voteMenu = vgui.Create("DFrame");
  R_GOVERNMENT_CL.voteMenu:SetSize(menuw, menuh);
  R_GOVERNMENT_CL.voteMenu:SetTitle("");
  R_GOVERNMENT_CL.voteMenu:SetSizable(false);
  R_GOVERNMENT_CL.voteMenu:SetDraggable(false);
  R_GOVERNMENT_CL.voteMenu:ShowCloseButton(false);
  local timer = R_GOVERNMENT.Config.VotingSettings["voting_time"];
  local prevTick = CurTime();
  function R_GOVERNMENT_CL.voteMenu:Paint(w, h)
    surface.SetDrawColor(voteBackground);
    surface.DrawRect(0, 0, w, h);
    draw.SimpleText("Mayor Election", "vote_font", w / 2, 14, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
    draw.SimpleText(timer, "vote_font", w / 2, h - 14, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  end

  function R_GOVERNMENT_CL.voteMenu:Think()
    if CurTime() > prevTick + 1 then
      timer = timer - 1;
      prevTick = CurTime();
    end
  end

  ----------------------------------
  -- Draw the players in the vote --
  ----------------------------------
  R_GOVERNMENT_CL.voteMenuCandidatesPanel = R_GOVERNMENT_CL.voteMenu:Add("DPanel");
  R_GOVERNMENT_CL.voteMenuCandidatesPanel:SetSize(menuw, menuh);
  function R_GOVERNMENT_CL.voteMenuCandidatesPanel:RefreshCandidates()
    if IsValid(self) then self:Clear(); end
    local candidatesGrid = self:Add("DGrid");
    local cols, colWidth, colPadding = 5, self:GetWide() / 5, 50;
    candidatesGrid:SetCols(cols);
    candidatesGrid:SetColWide(colWidth);
    candidatesGrid:SetRowHeight(menuh - colPadding);
    candidatesGrid:SetSize(menuw, menuh - colPadding);
    candidatesGrid:SetPos(5, (menuh / 2) - ((menuh - colPadding) / 2));
    for _, v in pairs(R_GOVERNMENT.candidates) do
      local ply = player.GetBySteamID(v["steam_id"]);
      local playerModel = ply:GetModel();
      local playerName = ply:Nick();
      local playerVotes = v["votes"];
      local playerFrame = vgui.Create("DPanel");
      playerFrame:SetSize(colWidth, menuh - colPadding);
      playerFrame:SetCursor("hand");
      function playerFrame:OnMousePressed()
        RunConsoleCommand("r_g_vote", v["steam_id"]);
      end

      function playerFrame:Paint(w, h)
        surface.SetDrawColor(255, 255, 255, 150);
        surface.DrawRect(0, 0, w, h);
        draw.SimpleText(playerName, "vote_font", w / 2, 20, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
        draw.SimpleText(string.format("Votes: %s", playerVotes), "vote_font", w / 2, h - 20, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
      end

      local playerModelIcon = playerFrame:Add("SpawnIcon");
      playerModelIcon:SetModel(playerModel);
      playerModelIcon:SetSize(64, 64);
      playerModelIcon:SetPos((colWidth / 2) - (playerModelIcon:GetWide() / 2), 30);
      function playerModelIcon:Think()
        return;
      end

      function playerModelIcon:PaintOver()
        return;
      end

      candidatesGrid:AddItem(playerFrame);
    end
  end

  R_GOVERNMENT_CL.voteMenuCandidatesPanel:RefreshCandidates();
end

function R_GOVERNMENT_CL.CloseVoteMenu()
  if IsValid(R_GOVERNMENT_CL.voteMenu) then R_GOVERNMENT_CL.voteMenu:Remove(); end
end

net.Receive("election_started", function()
  R_GOVERNMENT.electionRunning = true;
  R_GOVERNMENT_CL.OpenVoteMenu();
end);

net.Receive("election_ended", function()
  R_GOVERNMENT_CL.CloseVoteMenu();
  R_GOVERNMENT.electionRunning = false;
end);

--[[------------------------------------------------------------------------------
/                                                                              /
/              Refresh Candidates                                             /
/                                                                            /
---------------------------------------------------------------------------]]
net.Receive("update_client_candidates", function()
  local newCandidatesTable = net.ReadTable();
  R_GOVERNMENT.candidates = newCandidatesTable;
  if IsValid(R_GOVERNMENT_CL.electionMenuCandidatesContainer) then R_GOVERNMENT_CL.electionMenuCandidatesContainer:RefreshCandidates(); end
  if IsValid(R_GOVERNMENT_CL.voteMenu) then R_GOVERNMENT_CL.voteMenuCandidatesPanel:RefreshCandidates(); end
end);

--[[------------------------------------------------------------------------------
/                                                                              /
/              Mayor Menu                                                     /
/                                                                            /
---------------------------------------------------------------------------]]
surface.CreateFont("mayor_font", {
  font = "HudSelectionText",
  size = 22,
  weight = 600,
});

surface.CreateFont("mayor_font_small", {
  font = "HudSelectionText",
  size = 17,
  weight = 600,
});

surface.CreateFont("mayor_font_large", {
  font = "HudSelectionText",
  size = 30,
  weight = 600,
});

function getUpdatedGovernmentData()
  net.Start("request_client_gov_details");
  net.SendToServer();
end

function R_GOVERNMENT_CL.OpenMayorMenu()
  if IsValid(R_GOVERNMENT_CL.mayorMenu) then R_GOVERNMENT_CL.mayorMenu:Remove(); end
  getUpdatedGovernmentData();
  local scrw, scrh = ScrW(), ScrH();
  local menuw, menuh = scrw * .7, scrh * .7;
  local primaryColor = Color(40, 40, 40);
  local secondaryColor = Color(105, 105, 105);
  local contentBtnColor = Color(213, 100, 100);
  R_GOVERNMENT_CL.mayorMenu = cUtils.funcs.createMenu(0, 0, menuw, menuh, "", true, primaryColor);
  local closeBtn = R_GOVERNMENT_CL.mayorMenu:Add("DButton");
  closeBtn:SetText("");
  closeBtn:Dock(BOTTOM);
  closeBtn.DoClick = function() R_GOVERNMENT_CL.mayorMenu:Remove(); end;
  function closeBtn:Paint(w, h)
    surface.SetDrawColor(secondaryColor);
    surface.DrawRect(0, 0, w, h);
    draw.SimpleText("Close", "mayor_font", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  end

  local mayorMenuTitle = R_GOVERNMENT_CL.mayorMenu:Add("DPanel");
  mayorMenuTitle:Dock(TOP);
  mayorMenuTitle:SetSize(menuw, menuh * .1);
  function mayorMenuTitle:Paint(w, h)
    draw.SimpleText("Mayor Menu", "mayor_font_large", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  end

  local mayorMenuContent = R_GOVERNMENT_CL.mayorMenu:Add("DScrollPanel");
  mayorMenuContent:Dock(FILL);
  cUtils.funcs.EditScrollBarStyle(mayorMenuContent, Color(10, 10, 10, 255));
  function mayorMenuContent:RefreshContent()
    if IsValid(self) then self:Clear(); end
    local governmentFunds = self:Add("DPanel");
    governmentFunds:SetSize(menuw, menuh * .1);
    governmentFunds:Dock(TOP);
    function governmentFunds:Paint(w, h)
      draw.SimpleText("City Funds: $" .. REBELLION.numberFormat(R_GOVERNMENT.funds), "mayor_font", 0, 0, color_white, TEXT_ALIGN_LEFT);
    end

    local sectionHeader = self:Add("DPanel");
    sectionHeader:SetSize(menuw, menuh * .05);
    sectionHeader:Dock(TOP);
    sectionHeader:DockMargin(0, 3, 0, 3);
    function sectionHeader:Paint(w, h)
      draw.SimpleText("Taxes", "mayor_font", 0, 0, color_white, TEXT_ALIGN_LEFT);
    end

    for k, v in pairs(R_GOVERNMENT.playerTaxes) do
      local taxPanel = self:Add("DGrid");
      taxPanel:SetCols(3);
      taxPanel:SetColWide(menuw * .3);
      taxPanel:SetRowHeight(menuh * .05);
      taxPanel:Dock(TOP);
      taxPanel:DockMargin(0, 2, 0, 2);
      local taxName = vgui.Create("DPanel");
      taxName:SetSize((menuw * .3) * .8, menuh * .05);
      function taxName:Paint(w, h)
        draw.SimpleText(v["nicename"] .. ": " .. (v["tax"] * 100) .. "%", "mayor_font_small", 0, 0, color_white, TEXT_ALIGN_LEFT);
      end

      taxPanel:AddItem(taxName);
      local newTaxAmount = vgui.Create("DNumberWang");
      newTaxAmount:SetSize((menuw * .3) * .8, menuh * .05);
      newTaxAmount:SetMin(1);
      newTaxAmount:SetMax(100);
      newTaxAmount:SetValue(v["tax"] * 100);
      function newTaxAmount:Paint(w, h)
        surface.SetDrawColor(secondaryColor);
        surface.DrawRect(0, 0, w, h);
        draw.SimpleText(self:GetValue(), "mayor_font_small", 5, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
      end

      taxPanel:AddItem(newTaxAmount);
      local changeTax = vgui.Create("DButton");
      changeTax:SetText("");
      changeTax:SetSize((menuw * .3) * .8, menuh * .05);
      function changeTax:Paint(w, h)
        surface.SetDrawColor(secondaryColor);
        surface.DrawRect(0, 0, w, h);
        draw.SimpleText("Change tax", "mayor_font_small", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
      end

      changeTax.DoClick = function() RunConsoleCommand("update_tax", k, newTaxAmount:GetValue()); end;
      taxPanel:AddItem(changeTax);
    end

    local taxIncomeView = self:Add("DButton");
    taxIncomeView:SetText("");
    taxIncomeView:Dock(TOP);
    taxIncomeView:DockMargin(0, 10, 0, 10);
    taxIncomeView.DoClick = function() R_GOVERNMENT_CL.OpenTaxIncomeView(); end;
    function taxIncomeView:Paint(w, h)
      surface.SetDrawColor(contentBtnColor);
      surface.DrawRect(0, 0, w, h);
      draw.SimpleText("View tax income", "mayor_font", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
    end
  end

  --[[------------------------------------------------------------------------------
/                                                                              /
/ Update Government Data                                                      /
/                                                                            /
---------------------------------------------------------------------------]]
  net.Receive("update_client_gov_details", function()
    R_GOVERNMENT.playerTaxes["player_tax"]["tax"] = math.Round(net.ReadFloat(), 2);
    R_GOVERNMENT.playerTaxes["sales_tax"]["tax"] = math.Round(net.ReadFloat(), 2);
    R_GOVERNMENT.playerTaxes["trading_tax"]["tax"] = math.Round(net.ReadFloat(), 2);
    R_GOVERNMENT.funds = net.ReadDouble();
    mayorMenuContent:RefreshContent();
  end);

  mayorMenuContent:RefreshContent();
end

--[[------------------------------------------------------------------------------
/                                                                              /
/             Tax View                                                        /
/                                                                            /
---------------------------------------------------------------------------]]
function R_GOVERNMENT_CL.OpenTaxIncomeView()
  if IsValid(R_GOVERNMENT_CL.taxIncomeView) then R_GOVERNMENT_CL.taxIncomeView:Remove(); end
  local scrw, scrh = ScrW(), ScrH();
  local menuw, menuh = scrw * .15, scrh * .2;
  local primaryColor = Color(50, 50, 50);
  local secondaryColor = Color(213, 100, 100);
  R_GOVERNMENT_CL.taxIncomeView = cUtils.funcs.createMenu(0, 0, menuw, menuh, "", true, primaryColor);
  local closeBtn = R_GOVERNMENT_CL.taxIncomeView:Add("DButton");
  closeBtn:SetText("");
  closeBtn:SetSize(menuw, menuh * .1);
  function closeBtn:Paint(w, h)
    surface.SetDrawColor(secondaryColor);
    surface.DrawRect(0, 0, w, h);
    draw.SimpleText("Close", "HudSelectionText", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  end

  closeBtn.DoClick = function() R_GOVERNMENT_CL.taxIncomeView:Remove(); end;
  local playerTaxIncome = 0;
  local playersOnline = 0;
  local averageIncome = 0;
  local totalIncome = 0;
  local onlinePlayers = player.GetAll();
  for _, v in ipairs(onlinePlayers) do
    local plyJob = RPExtraTeams[v:Team()];
    local playerWage = plyJob["salary"];
    local playerTax = math.floor(playerWage * R_GOVERNMENT.playerTaxes["player_tax"]["tax"]);
    playerTaxIncome = playerTaxIncome + playerTax;
    playersOnline = playersOnline + 1;
    totalIncome = totalIncome + playerWage;
  end

  averageIncome = math.floor(totalIncome / playersOnline);
  local taxIncome = R_GOVERNMENT_CL.taxIncomeView:Add("DPanel");
  taxIncome:Dock(TOP);
  function taxIncome:Paint(w, h)
    draw.SimpleText("Wage Tax Income $" .. REBELLION.numberFormat(playerTaxIncome), "HudSelectionText", 0, 0, color_white, TEXT_ALIGN_LEFT);
  end

  local playersOnlinePanel = R_GOVERNMENT_CL.taxIncomeView:Add("DPanel");
  playersOnlinePanel:Dock(TOP);
  function playersOnlinePanel:Paint(w, h)
    draw.SimpleText("Players Online: " .. playersOnline, "HudSelectionText", 0, 0, color_white, TEXT_ALIGN_LEFT);
  end

  local averagePlayersWagePanel = R_GOVERNMENT_CL.taxIncomeView:Add("DPanel");
  averagePlayersWagePanel:Dock(TOP);
  function averagePlayersWagePanel:Paint(w, h)
    draw.SimpleText("Average Player Wage $" .. REBELLION.numberFormat(averageIncome), "HudSelectionText", 0, 0, color_white, TEXT_ALIGN_LEFT);
  end
end

net.Receive("open_mayor_menu", R_GOVERNMENT_CL.OpenMayorMenu);
