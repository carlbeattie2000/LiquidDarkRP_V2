local ChatFont = CreateClientConVar("pchat_font", "ChatFont", true, false)
local ShouldCheck = CreateConVar("pchat_openurls", "1", FCVAR_ARCHIVE, "Parse URLs that are sent in chat?")
local OnlyPictures = CreateConVar("pchat_onlypictures", "0", FCVAR_ARCHIVE, "Only parse images?")
local UseSteam = CreateConVar("pchat_usesteambrowser", "0", FCVAR_ARCHIVE, "Use the steam browser to open URLS?")
local MaxMessages = CreateConVar("pchat_messagelimit", "250", FCVAR_ARCHIVE, "The amount of messages to keep in the chatbox.")

local Patterns = {"http://([%w%p]+)(....?)(%s*)", "http://([%w%p]+)%.(....?)(%s*)"}
local Pictures = {["png"] = true, ["jpg"] = true, ["bmp"] = true, ["gif"] = true}
local Fonts = {"DebugFixed", "DebugFixedSmall", "Default", "Marlett", "Trebuchet18", "Trebuchet24", "HudHintTextLarge", "HudHintTextSmall", "CenterPrintText", "HudSelectionText", "CloseCaption_Normal", "CloseCaption_Bold", "CloseCaption_BoldItalic", "ChatFont", "TargetID", "TargetIDSmall", "BudgetLabel", "DermaDefault", "DermaDefaultBold", "DermaLarge", "ScoreboardDefault", "ScoreboardDefaultTitle", "GModToolSubtitle", "GModToolHelp", "GModWorldtip"}

local ScreenScale = function(Num, IsX)
	local Num = Num*((IsX and ScrW() or ScrH()) / (IsX and 640 or 480))
	return Num
end
	
local DoShit = function()
	local ChatBox = vgui.Create("EditablePanel")
	ChatBox:SetPos(ScreenScale(10, true), ScreenScale(290, false))
	ChatBox:SetSize(ScreenScale(200, true), ScreenScale(100, false))
	ChatBox:SetAlpha(0)
	ChatBox.Team = false
	ChatBox.Paint = function(self)
		surface.SetDrawColor(95, 178, 255, 100)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	end
	ChatBox.Visible = false
	ChatBox:SetVisible(false)
	ChatBox:SetAlpha(0)
	
	ChatBox.SettingsMenu = vgui.Create("EditablePanel")
	ChatBox.SettingsMenu:SetPos(ScreenScale(210, true) + 1, ScreenScale(290, false) + 4)
	ChatBox.SettingsMenu:SetSize(ScreenScale(15, false), ScreenScale(100, false) - 8)
	ChatBox.SettingsMenu.Expanded = false
	ChatBox.SettingsMenu.Expanding = false
	ChatBox.SettingsMenu:SetVisible(false)
	--Moving DSysButton over to GWEN implementation
	ChatBox.SettingsMenu.ExpandButton = vgui.Create("DButton", ChatBox.SettingsMenu)
	ChatBox.SettingsMenu.ExpandButton:SetSize(ScreenScale(15, false), ScreenScale(15, false))
	ChatBox.SettingsMenu.ExpandButton:SetText("")
	ChatBox.SettingsMenu.ExpandButton.DoClick = function(self)
		if not(self:IsVisible()) then return end
		if(ChatBox.SettingsMenu.Expanding) then return end
		if not(ChatBox.SettingsMenu.Expanded) then
			ChatBox.SettingsMenu:SizeTo(ScreenScale(100, true), ChatBox.SettingsMenu:GetTall(), 0.6, 0, 1)
			ChatBox.SettingsMenu.Expanded = true
			ChatBox.SettingsMenu.Expanding = true
			timer.Simple(0.6, function()
				ChatBox.SettingsMenu.Expanding = false
			end)
		else
			ChatBox.SettingsMenu:SizeTo(ScreenScale(15, false), ChatBox.SettingsMenu:GetTall(), 0.6, 0, 1)
			ChatBox.SettingsMenu.Expanded = false
			ChatBox.SettingsMenu.Expanding = true
			timer.Simple(0.6, function()
				ChatBox.SettingsMenu.Expanding = false
			end)
		end
	end
	ChatBox.SettingsMenu.ExpandButton.Paint = function(self)
		self:AlignRight(0)
		
		if ChatBox.SettingsMenu.Expanded then
			SKIN:PaintButtonLeft(self, self:GetWide(), self:GetTall())
		else
			SKIN:PaintButtonRight(self, self:GetWide(), self:GetTall())
		end
	end
	
	ChatBox.SettingsMenu.Panel = vgui.Create("EditablePanel", ChatBox.SettingsMenu)
	ChatBox.SettingsMenu.Panel:SetTall(ChatBox.SettingsMenu:GetTall())
	ChatBox.SettingsMenu.Panel.Paint = function(self)
		self:SetWide(ChatBox.SettingsMenu:GetWide() - ChatBox.SettingsMenu.ExpandButton:GetWide() + 1)
		if(self:GetWide() < 2) then return end
		surface.SetDrawColor(10, 10, 10, 100)
		surface.DrawRect(0, 0, self:GetWide() - 1, self:GetTall())
	end
	ChatBox.SettingsMenu.Settings = vgui.Create("DListLayout", ChatBox.SettingsMenu.Panel)
	ChatBox.SettingsMenu.Settings:SetPos(4, 4)
	ChatBox.SettingsMenu.Settings.Paint = function()
		local W, H = ChatBox.SettingsMenu.Panel:GetSize()
		ChatBox.SettingsMenu.Settings:SetSize(math.max(1, W - 8), math.max(1, H - 8))
	end
	
	ChatBox.SettingsMenu.Settings.Font = vgui.Create("DComboBox")
	ChatBox.SettingsMenu.Settings.Font:StretchToParent(4, nil, 4, nil)
	for I = 1, #Fonts do
		local select = false
		--[[Instead of having to remember to update several lines of code if I change the default
		chat box font, I'll only have to change it at the top of this file.]]
		if Fonts[I] == GetConVarString("pchat_font") then select = true end
		ChatBox.SettingsMenu.Settings.Font:AddChoice(Fonts[I], Fonts[I], select)
	end

	--Because DComboBox only supports binding numeric convars.
	ChatBox.SettingsMenu.Settings.Font.OnSelect = function(self, index, value, data)
		RunConsoleCommand( "pchat_font", value )
	end
	ChatBox.SettingsMenu.Settings:Add(ChatBox.SettingsMenu.Settings.Font)
	
	ChatBox.SettingsMenu.Settings.MessageLimit = vgui.Create("DNumSlider", ChatBox.SettingsMenu.Settings)
	ChatBox.SettingsMenu.Settings.MessageLimit:StretchToParent(4, nil, 4, nil)
	ChatBox.SettingsMenu.Settings.MessageLimit:SetText("Max Messages")
	ChatBox.SettingsMenu.Settings.MessageLimit:SetMinMax(1, 2100)
	ChatBox.SettingsMenu.Settings.MessageLimit:SetDecimals(0)
	ChatBox.SettingsMenu.Settings.MessageLimit:SetConVar("pchat_messagelimit")
	ChatBox.SettingsMenu.Settings:Add(ChatBox.SettingsMenu.Settings.MessageLimit)
	
	ChatBox.SettingsMenu.Settings.OpenURLs = vgui.Create("DCheckBoxLabel", ChatBox.SettingsMenu.Settings)
	ChatBox.SettingsMenu.Settings.OpenURLs:StretchToParent(4, nil, 4, nil)
	ChatBox.SettingsMenu.Settings.OpenURLs:SetText("Clickable URLs?")
	ChatBox.SettingsMenu.Settings.OpenURLs:SetConVar("pchat_openurls")
	ChatBox.SettingsMenu.Settings:Add(ChatBox.SettingsMenu.Settings.OpenURLs)
	
	ChatBox.SettingsMenu.Settings.URLSettings = vgui.Create("DPanelList", ChatBox.SettingsMenu.Settings)
	ChatBox.SettingsMenu.Settings.URLSettings:SetSpacing(4)
	ChatBox.SettingsMenu.Settings.URLSettings:SetPadding(2)
	ChatBox.SettingsMenu.Settings.URLSettings.Expanded = ChatBox.SettingsMenu.Settings.OpenURLs:GetChecked()
	ChatBox.SettingsMenu.Settings.URLSettings.Expanding = false
	ChatBox.SettingsMenu.Settings.URLSettings.Think = function(self)
		if not(ChatBox.SettingsMenu.Settings.URLSettings.Expanded == ChatBox.SettingsMenu.Settings.OpenURLs:GetChecked()) and not(ChatBox.SettingsMenu.Settings.URLSettings.Expanding) then
			if(ChatBox.SettingsMenu.Settings.OpenURLs:GetChecked()) then
				ChatBox.SettingsMenu.Settings.URLSettings:SizeTo(ChatBox.SettingsMenu.Settings.URLSettings:GetWide(), ScreenScale(32, false), 0.2, 0, 1)
				ChatBox.SettingsMenu.Settings.URLSettings.Expanded = true
			else
				ChatBox.SettingsMenu.Settings.URLSettings:SizeTo(ChatBox.SettingsMenu.Settings.URLSettings:GetWide(), 1, 0.2, 0, 1)
				ChatBox.SettingsMenu.Settings.URLSettings.Expanded = false
			end
			ChatBox.SettingsMenu.Settings.URLSettings.Expanding = true
			timer.Simple(0.2, function()
				ChatBox.SettingsMenu.Settings.URLSettings.Expanding = false
			end)
		end
	end
	
	ChatBox.SettingsMenu.Settings.URLSettings.Paint = function(self)
		if self.Expanding or self.Expanded then
			surface.SetDrawColor(75, 158, 180, 125)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		end
	end
	ChatBox.SettingsMenu.Settings:Add(ChatBox.SettingsMenu.Settings.URLSettings)
	
	ChatBox.SettingsMenu.Settings.URLSettings.UseSteam = vgui.Create("DCheckBoxLabel", ChatBox.SettingsMenu.Settings.URLSettings)
	ChatBox.SettingsMenu.Settings.URLSettings.UseSteam:StretchToParent()
	ChatBox.SettingsMenu.Settings.URLSettings.UseSteam:SetText("Use Steam browser?")
	ChatBox.SettingsMenu.Settings.URLSettings.UseSteam:SetConVar("pchat_usesteambrowser")
	--Disable because we can't launch the steam browser from garrys mod
	ChatBox.SettingsMenu.Settings.URLSettings.UseSteam:SetTooltip("Opening the steam browser from garry's mod has been disabled.")
	ChatBox.SettingsMenu.Settings.URLSettings.UseSteam.Button:SetDisabled(true)
	ChatBox.SettingsMenu.Settings.URLSettings.UseSteam.Label:SetMouseInputEnabled(false)
	ChatBox.SettingsMenu.Settings.URLSettings:AddItem(ChatBox.SettingsMenu.Settings.URLSettings.UseSteam)
	
	ChatBox.SettingsMenu.Settings.URLSettings.Pictures = vgui.Create("DCheckBoxLabel", ChatBox.SettingsMenu.Settings.URLSettings)
	ChatBox.SettingsMenu.Settings.URLSettings.Pictures:StretchToParent()
	ChatBox.SettingsMenu.Settings.URLSettings.Pictures:SetText("Only open images?")
	ChatBox.SettingsMenu.Settings.URLSettings.Pictures:SetConVar("pchat_onlypictures")
	ChatBox.SettingsMenu.Settings.URLSettings:AddItem(ChatBox.SettingsMenu.Settings.URLSettings.Pictures)
	
	ChatBox.SendButton = vgui.Create("DButton", ChatBox)
	ChatBox.SendButton:SetTall(ScreenScale(15, false))
	ChatBox.SendButton:AlignBottom(4)
	ChatBox.SendButton:SetText("")
	ChatBox.SendButton.DoClick = function() ChatBox:SendMessage() end
	ChatBox.SendButton.Paint = function(self)
		local C1, C2, C3, C4
		if (self:IsDown()) then
			C1 = Color(60, 60, 60)
			C2 = Color(80, 80, 80)
			C3 = Color(10, 10, 10, 100)
			C4 = Color(200, 200, 200)
		else
			C1 = Color(80, 80, 80)
			C2 = Color(60, 60, 60)
			C3 = Color(50, 50, 50, 100)
			C4 = Color(255, 255, 255)
		end
		surface.SetDrawColor(C1.r, C1.g, C1.b)
		surface.DrawLine(0, 0, 0, self:GetTall() - 1)
		surface.DrawLine(0, 0, self:GetWide() - 1, 0)
		surface.DrawLine(1, 1, 1, self:GetTall() - 2)
		surface.DrawLine(1, 1, self:GetWide() - 2, 1)
		surface.SetDrawColor(C2.r, C2.g, C2.b)
		surface.DrawLine(0, self:GetTall() - 1, self:GetWide() - 1, self:GetTall() - 1)
		surface.DrawLine(self:GetWide() - 1, self:GetTall() - 1, self:GetWide() - 1, 0)
		surface.DrawLine(1, self:GetTall() - 2, self:GetWide() - 2, self:GetTall() - 2)
		surface.DrawLine(self:GetWide() - 2, self:GetTall() - 1, self:GetWide() - 2, 2)
		surface.SetDrawColor(C3.r, C3.g, C3.b, C3.a)
		surface.DrawRect(2, 2, self:GetWide() - 4, self:GetTall() - 4)
		surface.SetTextColor(C4.r, C4.g, C4.b)
		surface.SetFont("Trebuchet18")
		local String = ChatBox.Team and "Team:" or "Say:"
		local W,H = surface.GetTextSize(String)
		surface.SetTextPos(self:GetWide()/2 - W/2, self:GetTall()/2 - H/2)
		surface.DrawText(String)
	end

	--MessagePanel is purely for looks - it just creates a darker colored background for the actual messages.
	ChatBox.MessagePanel = vgui.Create("EditablePanel", ChatBox)
	ChatBox.MessagePanel:SetName("MessagePanel")
	ChatBox.MessagePanel:StretchToParent(4, 4, 4, ScreenScale(20, false))
	ChatBox.MessagePanel:NoClipping(true)
	ChatBox.MessagePanel.Paint = function(self)
		surface.SetDrawColor(60, 60, 60, 255)
		surface.SetDrawColor(60, 60, 60, 255)
		surface.DrawLine(0, 0, 0, self:GetTall() - 1)
		surface.DrawLine(0, 0, self:GetWide() - 1, 0)
		surface.DrawLine(1, 1, 1, self:GetTall() - 2)
		surface.DrawLine(1, 1, self:GetWide() - 2, 1)
		surface.SetDrawColor(80, 80, 80, 255)
		surface.DrawLine(0, self:GetTall() - 1, self:GetWide() - 1, self:GetTall() - 1)
		surface.DrawLine(self:GetWide() - 1, self:GetTall() - 1, self:GetWide() - 1, 0)
		surface.DrawLine(1, self:GetTall() - 2, self:GetWide() - 2, self:GetTall() - 2)
		surface.DrawLine(self:GetWide() - 2, self:GetTall() - 1, self:GetWide() - 2, 2)
		surface.SetDrawColor(10, 10, 10, 100)
		surface.DrawRect(2, 2, self:GetWide() - 4, self:GetTall() - 4)
	end

	ChatBox.Messages = vgui.Create("DScrollPanel")
	ChatBox.Messages:SetName("Messages")
	ChatBox.Messages.FuncBackup = {} --Create a table to backup the VBar paint functions before we remove them
		ChatBox.Messages.FuncBackup.Paint = ChatBox.Messages:GetVBar().Paint
		ChatBox.Messages.FuncBackup.btnGrip = ChatBox.Messages:GetVBar().btnGrip.Paint
		ChatBox.Messages.FuncBackup.btnUp = ChatBox.Messages:GetVBar().btnUp.Paint
		ChatBox.Messages.FuncBackup.btnDown = ChatBox.Messages:GetVBar().btnDown.Paint
		
	ChatBox.Messages.RestoreVBar = function(self)
		local vbar = self:GetVBar()
		vbar.Paint = self.FuncBackup.Paint
		vbar.btnGrip.Paint = self.FuncBackup.btnGrip
		vbar.btnUp.Paint = self.FuncBackup.btnUp
		vbar.btnDown.Paint = self.FuncBackup.btnDown
	end
	ChatBox.Messages.HideVBar = function(self)
		self:GetVBar().Paint = function() end
		self:GetVBar().btnGrip.Paint = function() end
		self:GetVBar().btnUp.Paint = function() end
		self:GetVBar().btnDown.Paint = function() end
	end
	ChatBox.Messages:HideVBar()
	--Structure the child panels into a vertical list formation
	--The below code is mostly a copy pasta from DPanelList's Rebuild function
	ChatBox.Messages.Rebuild = function(self)
		local Offset = 0
		self.Items = self:GetCanvas():GetChildren()
		for k, panel in pairs( self.Items ) do
            if ( panel:IsVisible() ) then
				panel:SetSize( self:GetCanvas():GetWide() - self.Padding * 2, panel:GetTall() )
				panel:SetPos( self.Padding, self.Padding + Offset )
                
                -- Changing the width might ultimately change the height
                -- So give the panel a chance to change its height now,
                -- so when we call GetTall below the height will be correct.
                -- True means layout now.
                panel:InvalidateLayout( true )
                
                Offset = Offset + panel:GetTall()
            end
        end
        
        Offset = Offset + self.Padding
		self:GetCanvas():SetTall( Offset + self.Padding)
	end
	
	--Called when the Messages GUI is placed in the chat box.
	ChatBox.Messages.Parent = function(self)
		self:SetParent(ChatBox)
		self:StretchToParent(8, 8, 8, ScreenScale(20, false) + 4)
	end
	
	--The chat box is closing, move the messages GUI out so it can still show up.
	local CBX, CBY, CBW, CBH = ChatBox:GetBounds()
	ChatBox.Messages.Unparent = function(self)
		self:SetParent()
		self:SetPos(CBX + 8, CBY + 8)
		self:SetSize(CBW - 16, CBH - 8 - (ScreenScale(20, false) + 4))
	end
	ChatBox.Messages:Unparent()
	
	ChatBox.Messages:SetPadding(0)
	ChatBox.Messages.Paint = function() end
	
	ChatBox.TextEntry = vgui.Create("DTextEntry", ChatBox)
	ChatBox.TextEntry:StretchToParent(ScreenScale(28, true), 4, ScreenScale(12, true), nil)
	ChatBox.TextEntry:SetTall(ScreenScale(15, false))
	ChatBox.TextEntry:AlignBottom(4)
	ChatBox.TextEntry:SetTextInset(2, 0)
	ChatBox.TextEntry:SetAllowNonAsciiCharacters(true)
	ChatBox.TextEntry.Paint = function(self)
		surface.SetDrawColor(60, 60, 60, 255)
		surface.DrawLine(0, 0, 0, self:GetTall() - 1)
		surface.DrawLine(0, 0, self:GetWide() - 1, 0)
		surface.DrawLine(1, 1, 1, self:GetTall() - 2)
		surface.DrawLine(1, 1, self:GetWide() - 2, 1)
		surface.SetDrawColor(80, 80, 80, 255)
		surface.DrawLine(0, self:GetTall() - 1, self:GetWide() - 1, self:GetTall() - 1)
		surface.DrawLine(self:GetWide() - 1, self:GetTall() - 1, self:GetWide() - 1, 0)
		surface.DrawLine(1, self:GetTall() - 2, self:GetWide() - 2, self:GetTall() - 2)
		surface.DrawLine(self:GetWide() - 2, self:GetTall() - 1, self:GetWide() - 2, 2)
		surface.SetDrawColor(10, 10, 10, 100)
		surface.DrawRect(2, 2, self:GetWide() - 4, self:GetTall() - 4)
		self:DrawTextEntryText(Color(200, 200, 200), Color(30, 130, 255), Color(200, 200, 200))
	end
	ChatBox.TextEntry.OnEnter = function() 
		ChatBox:SendMessage()
	end

	ChatBox.TextEntry.OnKeyCodeTyped = function(self, Key)
		if(Key == KEY_ESCAPE) then
			ChatBox:GoAway()
			--[[self:SetText("")
			timer.Simple(0, function()
				RunConsoleCommand("cancelselect")
			end)]]
		elseif(Key == KEY_ENTER) then
			self.OnEnter()
		elseif(Key == KEY_UP) then
			if(ChatBox.PrevMessage) then
				ChatBox.PrevMessage:DoClick()
			end
		elseif(Key == KEY_DOWN) then
			ChatBox.NextMessage:DoClick()
		end
	end

	SentMessages = {""}
	ChatBox.CurMessage = 1
	
	ChatBox.PrevMessage = vgui.Create("DButton", ChatBox)
	ChatBox.PrevMessage:SetSize(ScreenScale(8, true), ScreenScale(6, false))
	ChatBox.PrevMessage:AlignRight(ScreenScale(6, true) - ScreenScale(8, true)/2)
	ChatBox.PrevMessage:AlignBottom(ScreenScale(10, false))
	ChatBox.PrevMessage:SetText("")
	--Override this button to paint like a GWEN skinned button for a different control.
	ChatBox.PrevMessage.Paint = function(self, w, h)
		SKIN:PaintNumberUp(ChatBox.PrevMessage, w, h)
	end
	ChatBox.PrevMessage.DoClick = function(self)
		if not(self:IsVisible()) then return end
		if not(ChatBox.NextMessage:IsVisible()) then
			ChatBox.NextMessage:SetVisible(true)
		end
		if(ChatBox.CurMessage < 2) then
			SentMessages[1] = ChatBox.TextEntry:GetText()
		end
		ChatBox.CurMessage = math.min(#SentMessages, ChatBox.CurMessage + 1)
		ChatBox.TextEntry:SetText(SentMessages[ChatBox.CurMessage])
		if(ChatBox.CurMessage == #SentMessages) then
			self:SetVisible(false)
		end
	end
	ChatBox.NextMessage = vgui.Create("DButton", ChatBox)
	ChatBox.NextMessage:SetSize(ScreenScale(8, true), ScreenScale(6, false))
	ChatBox.NextMessage:AlignRight(ScreenScale(6, true) - ScreenScale(8, true)/2)
	ChatBox.NextMessage:AlignBottom(ScreenScale(10, false) - ScreenScale(6, false))
	ChatBox.NextMessage:SetText("")
	ChatBox.NextMessage.Paint = function(self, w, h)
		SKIN:PaintNumberDown(self, w, h)
	end
	ChatBox.NextMessage.DoClick = function(self)
		if not(self:IsVisible()) then return end
		if not(ChatBox.PrevMessage:IsVisible()) then
			ChatBox.PrevMessage:SetVisible(true)
		end
		ChatBox.CurMessage = math.max(1, ChatBox.CurMessage - 1)
		ChatBox.TextEntry:SetText(SentMessages[ChatBox.CurMessage])
		if(ChatBox.CurMessage == 1) then
			SentMessages[1] = ""
			self:SetVisible(false)
		end
	end
	
	ChatBox.PrevMessage:SetVisible(false)
	ChatBox.NextMessage:SetVisible(false)

	ChatBox.SendMessage = function(self)
		self:GoAway()
		if(self.TextEntry:GetText():Trim():len() > 0) then
			table.insert(SentMessages, 2, self.TextEntry:GetText():Trim())
			RunConsoleCommand(self.Team and "Say_team" or "Say", self.TextEntry:GetText():Trim())
		end
		self.TextEntry:SetText("")
	end 

	local DrawChat = function()
		if(ChatBox.Visible) and not(ChatBox:GetAlpha() >= 255) then
			ChatBox:SetAlpha(ChatBox:GetAlpha() + RealFrameTime()*900)
			ChatBox.TextEntry:SetAlpha(ChatBox:GetAlpha())
		end
	end
	hook.Add("HUDPaint", "PChat.HUDPaint", DrawChat)
	
	local HTMLFrame = vgui.Create("DFrame")
	HTMLFrame:SetSize(ScrW()*3/4, ScrH()*3/4)
	HTMLFrame:Center()
	HTMLFrame:SetVisible(false)
	HTMLFrame:SetDraggable(true)
	HTMLFrame.Paint = function(self)	
		surface.SetDrawColor(100, 100, 100, 100)
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
		surface.SetTextColor(255, 255, 255)
	end
	HTMLFrame.btnClose.DoClick = function()
		gui.EnableScreenClicker(false)
		HTMLFrame:SetVisible(false)
	end
	
	local HTMLPanel = vgui.Create("DHTML", HTMLFrame)
	HTMLPanel:StretchToParent(4, ScreenScale(34), 2, 2)
	HTMLPanel:NoClipping(true)
	HTMLPanel.FinishedURL = function(self)
		HTMLFrame:SetTitle(self.PageTitle)
	end
	
	local HTMLControls = vgui.Create("DHTMLControls", HTMLPanel)
	HTMLControls:SetHTML(HTMLPanel)
	HTMLControls:StretchToParent(0, nil, 0, nil)
	HTMLControls:AlignTop(HTMLControls:GetTall()*-1 + 4)

	local _,FontHeight
	local FontCallback = function(cvar, Old, New)
		surface.SetFont(ChatFont:GetString() or "ChatFont")
		_, FontHeight = surface.GetTextSize("0")
	end
	cvars.AddChangeCallback("pchat_font", FontCallback)
	FontCallback()

	local ChatBoxWidth = ChatBox:GetWide() - 8 - ScreenScale(15, true)
	local ShouldPrint = true
	local PrintColor = chat.AddText
	function chat.AddText(...)
		local CurColor = Color(161, 255, 255)
		local X, Y = 2, 2
		local RawString = ""
		TempPanel = vgui.Create("EditablePanel")
		local URLButton
		TempPanel:StretchToParent(4, 4, 4, nil)
		TempPanel:SetTall(FontHeight*1.25)
		TempPanel.FakeAlpha = 255*6
		TempPanel.Materials = {}
		TempPanel.HasFaded = false
		TempPanel.ToPaint = {}
		for _,v in pairs({...}) do
			if(type(v) == "IMaterial") then
				if((surface.GetTextSize(RawString) + 16) > ChatBoxWidth) then
					X = 2
					Y = Y + FontHeight
				end
				TempPanel.Materials[#TempPanel.Materials + 1] = {v, X, Y}
				X = X + 18
			end 
			if(type(v) == "table") then
				CurColor = v
			end 
			if(type(v) == "Angle") then
				v = "Angle("..v.p..", "..v.y..", "..v.r..")"
			end
			if(type(v) == "Vector") then
				v = "Vector("..v.x..", "..v.y..", "..v.z..")"
			end
			if(type(v) == "boolean") then
				v = v and "true" or "false"
			end
			if(type(v) == "Entity") then
				v = "["..v:EntIndex().."]"..v:GetClass()
			end
			if(type(v) == "Player") then
				CurColor = Color(255, 204, 161)
				v = v:Nick()
			end
			if((type(v) == "string") or (type(v) == "number")) then
				local URL = string.match(v, "%b\r\r")
				if not(URL == nil) then
					v = string.gsub(v, "\r", "")
					URLButton = vgui.Create("DButton", TempPanel)
					URLButton:SetSize(ChatBoxWidth, FontHeight)
					URLButton.URL = URL
					URLButton:SetCursor("hand")
					URLButton:SetText("")
					URLButton.Paint = function(self)
						surface.SetDrawColor(34, 148, 233)
						surface.DrawLine(0, self:GetTall() - 1, self:GetWide() - 2, self:GetTall() - 1)
					end
					URLButton.DoClick = function(self)
						if(UseSteam:GetBool()) then
							gui.OpenURL(self.URL)
						else
							HTMLPanel:OpenURL(self.URL)
							--HTMLPanel:SetMouseInputEnabled(true)
							--HTMLPanel:SetKeyboardInputEnabled(true)
							HTMLFrame:SetTitle("Loading..")
							HTMLFrame:SetVisible(true)
							HTMLControls.AddressBar:SetVisible(false)
							HTMLControls.HomeURL = self.URL
							gui.EnableScreenClicker(true)
						end
					end
				end
				surface.SetFont(ChatFont:GetString())
				local CurLine = ""
				for _,String  in pairs(string.Explode(" ", v)) do
					if(surface.GetTextSize(RawString.." "..String) > ChatBoxWidth) then
						TempPanel.ToPaint[#TempPanel.ToPaint + 1] = {CurLine, ChatFont:GetString(), X, Y, CurColor}
						X = 2
						Y = Y + FontHeight
						v = string.sub(v, CurLine:len() + 1)
						TempPanel:SetTall(TempPanel:GetTall() + FontHeight)
						CurLine = String.." "
						RawString = String.." "
						if(surface.GetTextSize(RawString) > ChatBoxWidth) then
							local CurWord = ""
							for _,Char  in pairs(string.Explode("", RawString)) do
								if(surface.GetTextSize(CurWord..Char) > ChatBoxWidth) then
									if not(URL == nil) then
										CurWord = string.sub(CurWord, 1, -3).."..."
										CurLine = CurWord.." "
										RawString = CurWord.." "
										URLButton:SetWide(surface.GetTextSize(CurWord))
										break
									else
										TempPanel.ToPaint[#TempPanel.ToPaint + 1] = {CurWord, ChatFont:GetString(), X, Y, CurColor}
										X = 2
										Y = Y + FontHeight
										TempPanel:SetTall(TempPanel:GetTall() + FontHeight)
										CurWord = Char
									end
								else
									CurWord = CurWord..Char
								end
								CurLine = CurWord.." "
								RawString = CurWord.." "
							end
						else
							CurLine = String.." "
							RawString = String.." "
						end
						TempPanel.ToPaint[#TempPanel.ToPaint + 1] = {CurLine, ChatFont:GetString(), X, Y, CurColor}
						if not(URL == nil) then
							URLButton:SetPos(X - 1, Y)
							URLButton:SetWide(surface.GetTextSize(CurLine))
						end
					else
						RawString = RawString..String.." "
						CurLine = CurLine..String.." "
						if not(URL == nil) then
							URLButton:SetPos(X - 1, 2)
							URLButton:SetWide(surface.GetTextSize(URL:Trim()) + 2)
						end
					end
				end
				TempPanel.ToPaint[#TempPanel.ToPaint + 1] = {CurLine, ChatFont:GetString(), X, Y, CurColor}
				for k, v in pairs(TempPanel.ToPaint) do
					line, font, x, y, color = unpack(v)
				end
				
				local W, H = surface.GetTextSize(v)
				X = X + W
			end
		end
		
		TempPanel.Paint = function(self)
			for k,v in pairs(self.ToPaint) do
				draw.DrawText(unpack(v))
			end
			for k,v in pairs(self.Materials) do
				surface.SetMaterial(v[1])
				surface.SetDrawColor(255, 255, 255)
				surface.DrawTexturedRect(v[2], v[3], 16, 16)
			end
			if not(self.HasFaded) then
				self.FakeAlpha = self.FakeAlpha - RealFrameTime()*300
				self.HasFaded = self.FakeAlpha <= 0
			end
			if(ChatBox:IsVisible()) then
				self:SetAlpha(255)
			else
				if not(self.HasFaded) then
					self:SetAlpha(math.min(self.FakeAlpha, 255))
				else
					self:SetAlpha(0)
				end
			end
		end
		
		ChatBox.Messages:AddItem(TempPanel)
		local Items = ChatBox.Messages:GetCanvas():GetChildren()
		local Max = math.Clamp(MaxMessages:GetInt(), 1, 2100) - 1
		while (#Items > Max) do
			Items[1]:Remove()
			table.remove(Items, 1)
			ChatBox.Messages:PerformLayout()
		end
		
		ChatBox.Messages:Rebuild()
		ChatBox.Messages:ScrollToChild(Items[#Items])

		if(ShouldPrint) then
			PrintColor(...)
		end
	end

	FindMetaTable("Player").ChatPrint = function (self, Str)
		chat.AddText(Str)
	end

	local ChatText = function(PlayerIndex, PlayerName, Text, MessageType)
		if(PlayerName == Text) then return true end
		ShouldPrint = false
		if((MessageType == "none") or (MessageType == "chat")) then
			chat.AddText(Text)
		elseif(MessageType == "joinleave") then
			chat.AddText(Color(161, 255, 161), Text)
		else
			chat.AddText(Color(255, 161, 161), "Unknown message type - "..MessageType..":")
			chat.AddText(Text)
		end

		ShouldPrint = true
		return true
	end
	hook.Add("ChatText", "PChat.ChatText", ChatText)

	local CheckForLinks = function(Player, Text, Team, Dead)
		local Pattern
		if(ShouldCheck:GetBool()) then
			if(OnlyPictures:GetBool()) then
				Pattern = Patterns[2]
			else
				Pattern = Patterns[1]
			end
		end
		if !Text or !Pattern then return end
		local _, Extension = string.match(Text, Pattern)
		local S, E = string.find(Text, Pattern) 
		local URL, Object
		if(ShouldCheck:GetBool()) then
			if(not(S == nil) and not(E == nil)) then
				URL = string.TrimRight(string.sub(Text, S, E + 3))
				Object = "URL"
			else
				return false
			end
		end
		if not(Extension == nil) then
			if(Extension:len() > 0) then
				if(Pictures[Extension]) then
					URL = string.TrimRight(string.sub(Text, S, E + 3))
					Object = "picture"
				end
			end
		end
		if(OnlyPictures:GetBool()) and (Object == "URL") then return end
		chat.AddText(Player, Color(255, 255, 255), " has sent the "..Object..": ", Color(34, 148, 233), "\r"..URL.."\r")
		return true
	end
	hook.Add("OnPlayerChat", "PChat.OnPlayerChat", CheckForLinks)
	
	ChatBox.ComeBack = function(self)
		gui.EnableScreenClicker( true ) --Enable mouse
		self.Messages:RestoreVBar()
		self.Visible = true
		self:SetVisible(true)
		self.SettingsMenu:SetVisible(true)
		self:MakePopup()
		self.TextEntry:RequestFocus()
		self.Messages:Parent()
		self.CurMessage = 1
		if(#SentMessages > 1) then
			self.PrevMessage:SetVisible(true)
		end
		for k,v in pairs(ChatBox.Messages:GetCanvas():GetChildren()) do
			v:SetCursor("beam")
		end
		local String = self.Team and "Team:" or "Say:"
		surface.SetFont("Trebuchet18")
		local W,H = surface.GetTextSize(String)
		self.SendButton:SetWide(W + 12)
		local X,Y = self.SendButton:GetPos()
		self.SendButton:SetPos(ScreenScale(14, true) - self.SendButton:GetWide()/2 - 1, Y) --The minus one is because it's one pixel off when it's team chat and fuck my OCD and asjdhaksjdhas
		hook.Call( "StartChat" )
	end

	local OpenChat = function(Player, Bind, Pressed)
		if ChatBox.Visible then --Chatbox is open
			if (Bind == "cancelselect") then ChatBox.GoAway() return true end --Close chat on Esc
			if (Bind ~= "toggleconsole") then return true end --Don't do anything
		elseif(Pressed and string.find(Bind, "messagemode")) then
			ChatBox.Team = string.find(Bind, "messagemode2")
			ChatBox:ComeBack()
			return true 
		end
	end
	hook.Add("PlayerBindPress", "PChat.PlayerBindPress", OpenChat)
	
	ChatBox.GoAway = function()
		gui.EnableScreenClicker( false ) --Disable mouse
		local self = ChatBox
		self.Messages:Unparent()
		self.Messages:HideVBar()
		self.Messages:GetVBar():AddScroll(self.Messages:GetTall() + 2)
		self.Visible = false
		self:SetVisible(false)
		self.SettingsMenu:SetVisible(false)
		self:SetAlpha(0)
		self.TextEntry:SetAlpha(0)
		timer.Simple(0, function()
			self.Team = false
		end)
		for k,v in pairs(ChatBox.Messages:GetCanvas():GetChildren()) do
			v:SetCursor("arrow")
		end
		
		hook.Call( "FinishChat" )
	end
end

DoShit()

--ply *should* be valid almost every time 
local function AddToChat(msg)
	local col1 = Color(msg:ReadShort(), msg:ReadShort(), msg:ReadShort())

	local name = msg:ReadString()
	local ply = msg:ReadEntity()
	local col2 = Color(msg:ReadShort(), msg:ReadShort(), msg:ReadShort())

	local text = msg:ReadString()
	if text and text ~= "" then
		if IsValid(ply) then
			--Remember, OnPlayerChat wants to know if the player is *dead*, or _not_ alive.
			if not hook.Call("OnPlayerChat", nil, ply, text, false, not ply:Alive()) then
				--By definition, OnPlayerChat will return true if standard messages are to be surpressed.
				--If OnPlayerChat didn't have anything fancy to do, then do a standard AddText.
				chat.AddText(col1, name, col2, ": "..text)
			end
		end
	else
		chat.AddText(col1, name)
	end
	chat.PlaySound()
end
usermessage.Hook("DarkRP_Chat", AddToChat)

hook.Add( "HUDShouldDraw", "Disable old CB", function( hud )
	if hud == "CHudChat" then
		return false
	end
end )