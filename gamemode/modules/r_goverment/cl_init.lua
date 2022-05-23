local R_GOVERNMENT_CL = R_GOVERNMENT_CL || {}

function R_GOVERNMENT_CL.OpenElectionMenu()

  if IsValid(R_GOVERNMENT_CL.electionMenu) then

    R_GOVERNMENT_CL.electionMenu:Remove()
    
  end

  local joinElectionFee = REBELLION.numberFormat(R_GOVERNMENT.Config.VotingSettings["entry_cost"])

  local primaryColor = Color(40, 40, 40, 245)
  local secondaryColor = Color(200, 60, 60, 245)
  local headerColor = Color(255, 255, 255, 245)
  local btnColor = Color(255, 40, 40, 245)
  local candidateNameBgColor = Color(213, 100, 100, 245)

  local scrw, scrh = ScrW(), ScrH()
  local menuw, menuh = ScrW()*.4, ScrH()*.4

  R_GOVERNMENT_CL.electionMenu = vgui.Create("DFrame")

  R_GOVERNMENT_CL.electionMenu:SetSize(menuw, menuh)
  R_GOVERNMENT_CL.electionMenu:Center()
  R_GOVERNMENT_CL.electionMenu:MakePopup()
  R_GOVERNMENT_CL.electionMenu:ShowCloseButton(false)
  R_GOVERNMENT_CL.electionMenu:SetTitle("Mayor Elections")
  R_GOVERNMENT_CL.electionMenu:SetSizable(false)
  R_GOVERNMENT_CL.electionMenu:SetDraggable(false)

  function R_GOVERNMENT_CL.electionMenu:Paint(w, h)
  
    surface.SetDrawColor(primaryColor)
    surface.DrawRect(0, 0, w, h)
    
  end

  local electionMenuHeader = R_GOVERNMENT_CL.electionMenu:Add("DPanel")

  electionMenuHeader:SetSize(menuw, menuh*.05)
  electionMenuHeader:Dock(BOTTOM)

  function electionMenuHeader:Paint(w, h)
  
    surface.SetDrawColor(headerColor)
    surface.DrawRect(0, 0, w, h)

  end

  local electionMenuHeaderCloseBtn = electionMenuHeader:Add("DButton")

  electionMenuHeaderCloseBtn:SetText("")
  electionMenuHeaderCloseBtn:SetSize(menuw, electionMenuHeader:GetTall())

  function electionMenuHeaderCloseBtn:Paint(w, h)

    surface.SetDrawColor(btnColor)
    surface.DrawRect(0, 0, w, h)

    draw.SimpleText("Close", "HudSelectionText", w*.5, h*.5, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
  end
  
  electionMenuHeaderCloseBtn.DoClick = function()
  
    R_GOVERNMENT_CL.electionMenu:Remove()

  end

  /*---------------------------------------------------------------------------

                        Is the mayor alive/active

  ---------------------------------------------------------------------------*/
  local mayorActiveDisplay = R_GOVERNMENT_CL.electionMenu:Add("DPanel")

  mayorActiveDisplay:SetSize(menuw, menuh * .1)
  mayorActiveDisplay:Dock(TOP)

  function mayorActiveDisplay:Paint(w, h)
  
    surface.SetDrawColor(secondaryColor)
    surface.DrawRect(0, 0, w, h)

    if R_GOVERNMENT.mayorActive then

      draw.SimpleText("Mayor is currently alive, can't start election.", "HudSelectionText", w * .5, h * .5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    else

      draw.SimpleText("Join the election.", "HudSelectionText", w * .5, h * .5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      
    end
  
  end

  /*---------------------------------------------------------------------------

                        Current Candidates

  ---------------------------------------------------------------------------*/
  local mayorCandidatesContainer = R_GOVERNMENT_CL.electionMenu:Add("DPanel")

  mayorCandidatesContainer:Dock(TOP)
  mayorCandidatesContainer:DockMargin(0, 5, 0, 5)
  mayorCandidatesContainer:SetSize(menuw, menuh * .25)

  local mayorCandidates = mayorCandidatesContainer:Add("DGrid")

  local cols = 4
  local colsSpacing = 30
  local totalRowColSpacing = colsSpacing * cols
  local colWidth = (menuw / cols) - colsSpacing

  mayorCandidates:SetSize(menuw, menuh * .25)
  mayorCandidates:SetCols(cols)
  mayorCandidates:SetColWide(colWidth)
  mayorCandidates:SetPos((menuw / 2) - (menuw - totalRowColSpacing) / 2, 0)
  mayorCandidates:SetRowHeight(50)

  function mayorCandidates:RefreshCandidates()

    if #R_GOVERNMENT.candidates == 0 then

      local noPlayersPanel = vgui.Create("DPanel")

      noPlayersPanel:SetSize(colWidth, 50)

      function noPlayersPanel:Paint(w, h)

        draw.SimpleText("No Candidates", "HudSelectionText", w * .5, h * .5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

      end

      self:AddItem(noPlayersPanel)

    end
  
    for i, v in ipairs(R_GOVERNMENT.candidates) do
    
      local playerNamePanel = vgui.Create("DPanel")

      playerNamePanel:SetSize(colWidth, 50)

      function playerNamePanel:Paint(w, h)
      
        surface.SetDrawColor(candidateNameBgColor)
        surface.DrawRect(0, 0, w, h)

      end

      self:AddItem(playerNamePanel)

    end
    
  end
  mayorCandidates:RefreshCandidates()

  /*---------------------------------------------------------------------------

                        Join Election

  ---------------------------------------------------------------------------*/
  local joinElectionButton = R_GOVERNMENT_CL.electionMenu:Add("DButton")

  joinElectionButton:SetSize(menuw, menuh * .1)
  joinElectionButton:SetText("")
  joinElectionButton:Dock(BOTTOM)
  joinElectionButton:DockMargin(0, 10, 0, 10)

  function joinElectionButton:Paint(w, h)

    local bgColor = btnColor

    local joinElectionText = string.format("Join election for $%s", REBELLION.numberFormat(R_GOVERNMENT.Config.VotingSettings["entry_cost"]))

    if LocalPlayer():isCandidate() then

      bgColor = Color(50, 50, 50, 245)
      joinElectionText = "You are already in this election!"

    elseif #R_GOVERNMENT.candidates > R_GOVERNMENT.Config.VotingSettings["max_candidates"] then

      bgColor = Color(50, 50, 50, 245)
      joinElectionText = "The election list is full!"

    end

    surface.SetDrawColor(bgColor)
    surface.DrawRect(0, 0, w, h)

    draw.SimpleText(joinElectionText, "HudSelectionText", w * .5, h * .5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

  end

  if LocalPlayer():isCandidate() || #R_GOVERNMENT.candidates > R_GOVERNMENT.Config.VotingSettings["max_candidates"] then

    joinElectionButton:SetEnabled(false)

  end

  joinElectionButton.DoClick = function()

    RunConsoleCommand("", arguments)

  end

end

usermessage.Hook("SendMayorElectionMenu", R_GOVERNMENT_CL.OpenElectionMenu)
