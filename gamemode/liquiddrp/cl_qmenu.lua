if LDRP_SH.DisableQMenu then return end

local LDRP = {}

function LDRP.QMenuHUD()
	if LDRP.QMenuStr then
		local Font = (string.len(LDRP.QMenuStr) > 28 and "Trebuchet24") or "HUDNumber"
		draw.SimpleTextOutlined(LDRP.QMenuStr, Font, ScrW()*.5, ScrH()*.03, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0) )
	end
end
hook.Add("HUDPaint","Shows that they added to favs",LDRP.QMenuHUD)

function LDRP.SetQMenuStr(text,time)
	LDRP.QMenuStr = text
	timer.Create("ResetStr0",time,1,function()
		LDRP.QMenuStr = nil
	end)
end

local function MC(a) return math.Clamp(a,0,255) end
local function LDRPColorMod(r,g,b,a)
	local Clrs = LDRP_Theme[LDRP_Theme.CurrentSkin].BGColor
	return Color(MC(Clrs.r+r),MC(Clrs.g+g),MC(Clrs.b+b),MC(Clrs.a+a))
end

local OldVGUICreate = vgui.Create
function vgui.Create(classnamE, parent, name, ...)
	local classname = classnamE
	if classname == "SpawnIconMenu" then
		classname = "SpawnIcon"
		local SpawnIcon = OldVGUICreate(classname, parent, name, ...)
		timer.Simple(0, function() -- The .OpenMenu function will be there the next frame
			if not SpawnIcon.OpenMenu or not SpawnIcon.Mdl then return end
			
			local model = string.match(SpawnIcon.Mdl, "(.*.mdl)")
			if not model then return end
			function SpawnIcon:OpenMenu()
				local menu = DermaMenu()
					menu:AddOption(((SpawnIcon.Section == "Favorites" and "Remove from favorites") or "Add to favorites"), function()
						if SpawnIcon.Section == "Favorites" then
							table.remove(LDRP.Props["Favorites"], table.KeyFromValue(LDRP.Props["Favorites"],model))
							SpawnIcon:Remove()
							SpawnIcon.RefreshList()
							LDRP.SetQMenuStr("Removed prop from favorites.",3)
						else
							if table.HasValue(LDRP.Props["Favorites"], model) then LDRP.SetQMenuStr("Prop already in favorites!",3) return end
							table.insert(LDRP.Props["Favorites"], model)
							LDRP.SetQMenuStr("Added prop to favorites.",3)
						end
						LocalPlayer():EmitSound("UI/buttonrollover.wav",60,120)
						LDRP_SH.SaveFavs()
					end)
					menu:AddOption("Copy to Clipboard", function() SetClipboardText(model) end)
					if LocalPlayer():IsAdmin() then menu:AddOption("Add/remove to prop blacklist", function() RunConsoleCommand("_protector","model",model) end) end
					
				menu:Open()
			end
		end)
		return SpawnIcon
	
	end
	return OldVGUICreate(classname, parent, name, ...)
end

LDRP.Tools = LDRP_SH.Tools --Moved down

--[[-----------------------------------------------
	AssociateToolData - Find all of the client's
	tools, and then filter them out based on the
	allowed tools present in LDRP.Tools. This has
	the advantage of only showing tools that are
	actually installed in the server, even if
	invalid tools are specified in LDRP.Tools.
	raw_tools = A table with the tool names as
	strings.
--------------------------------------------------]]
local function AssociateToolData(raw_tools)
	local newtable = {}
	for k, v in pairs(spawnmenu.GetTools()[1].Items) do --In the "Main" tools tab
		for a, b in ipairs(v) do --Navigate through the categories (Constraints, Construction, etc.)
			for c, d in ipairs(raw_tools or {}) do --Run through the allowed tools table, and associate any found info
				if string.lower(d) == b.ItemName then
					table.Add(newtable, {b})
					break
				end
			end
		end
	end
	return newtable
end

LDRP.Props = LDRP_SH.Props

LDRP.ContextType = "-"

hook.Add("InitPostEntity", "GiveAdminControls", function()
	if LocalPlayer():IsAdmin() then
		LDRP.AdminControls = LDRP_SH.AdminControls
	end
end)

--[[-------------------------------------------------------
	LDRP Spawn menu VGUI code
	Moved from the OnSpawnMenuOpen section
]]---------------------------------------------------------
local PANEL = {}

function PANEL:Init()
	self.m_bHangOpen = false
	self.Opened = {} --Replaces LDRP.Opened = {}
	self.CurSpawnList = {}

	LDRP.Tools = AssociateToolData(LDRP.Tools)
	LDRP.VIPTools = AssociateToolData( LDRP_SH.VIPTools )
	table.sort(LDRP.Tools, function(a,b) return b.ItemName > a.ItemName end)
	table.sort(LDRP.VIPTools, function(a,b) return b.ItemName > a.ItemName end)
	
	if !LDRP.DontKnow then LDRP.DontKnow = true LDRP.SetQMenuStr("Right click on a prop for adding it to favorites.",6) end
	
	self:CreateBG("Props",ScrW()*.05,ScrH()*.05,ScrW()*.625,ScrH()*.9)
	self:CreateBG("Tools",ScrW()*.68,ScrH()*.05,ScrW()*.25,ScrH()*.9)

	self.PropList = vgui.Create("DPanelList", self.Opened["Props"])
	self.PropList:SetPos(12,ScrH()*.08)
	self.PropList:SetSize(ScrW()*.625-24,ScrH()*.82-12)
	self.PropList:SetSpacing(4)
	self.PropList:SetPadding(4)
	self.PropList:EnableHorizontal(true)
	self.PropList:EnableVerticalScrollbar(true)
	
	function self.PropList:RefreshList()
		timer.Simple(.01,function()
			if !self:IsValid() then return end
			self:PerformLayout()
			self.VBar:SetScroll( 1 )
		end)
	end
	
	self:SetPropList(LDRP.LastTab or "Construction")
	
	local Sections = 0
	LDRP.Props["Context Menu"] = {}

	if LocalPlayer():IsAdmin() or LocalPlayer():IsUserGroup("Moderator") then
		LDRP.Props["Mod Controls"] = {}
	end
	for k,v in pairs(LDRP.Props) do
		local SectionButton = vgui.Create("DButton", self.Opened["Props"])
		SectionButton:SetPos(12+Sections, ScrH()*.05)
		SectionButton:SetText(k)
		local width = string.len(k)*10
		SectionButton:SetSize(width, 22)
		Sections = Sections + width + 4
		
		SectionButton.DoClick = function(btn)
			if k == "Context Menu" then
				LDRP.ContextType = (LDRP.ContextType == "-" and "+") or "-"
				if LDRP.ContextType == "+" then LDRP.SetQMenuStr("Press this again to close it.",3) end
				RunConsoleCommand(LDRP.ContextType .. "menu_context")
				return
			elseif k == "Mod Controls" then
				for k,v in pairs(self.CurSpawnList) do
					if v:IsValid() then v:Remove() end
				end
				self.CurSpawnList = {}
				for k,v in pairs(LDRP.AdminControls) do
					local button = vgui.Create("DButton", self.PropList)
					button:SetText(k)
					button:SetSize(ScrW()*.625-32,ScrH()*.05)
					button:SetToolTip(v.descrpt)
					if v.sv then
						button.DoClick = function() RunConsoleCommand(v.sv) end
					else
						button.DoClick = v.func
					end
					
					self.PropList:AddItem(button)
					table.insert(self.CurSpawnList, button)
				end
				self.PropList:RefreshList()
				LDRP.LastTab = "Mod Controls"
				return
			end
			self:SetPropList(k)
			LocalPlayer():EmitSound("UI/buttonclick.wav",60,150)
		end
	end
	
	--Prep the tool menu
	self.ToolList = vgui.Create("DPropertySheet", self.Opened["Tools"])
	self.ToolList.ToolPanels = {}
	self.ToolList:SetPos(12,ScrH()*.06)
	self.ToolList:SetSize(ScrW()*.25-24, (ScrH()*.84-12) / 2)
	
	function self.ToolList:GetToolPanel( id )
		return self.ToolPanels[ id ]
	end
	
	local toolMenu = self.Opened["Tools"]
	local tools = vgui.Create( "DScrollPanel" )
	tools.List = tools
	
	local function GenerateToolButton( toolMode )
		local ToolButton = vgui.Create( "DButton" )
		ToolButton:SetText(toolMode.Text)
		
		ToolButton.DoClick = function(btn)
			if ( btn.Command ) then
                LocalPlayer():ConCommand( btn.Command )
            end
			
			local cp = controlpanel.Get( btn.Name )
            if ( !cp:GetInitialized() ) then
                cp:FillViaTable( btn )
            end
			
			spawnmenu.ActivateToolPanel( 1, cp)
			LocalPlayer():EmitSound("buttons/lightswitch2.wav")
		end
		
		ToolButton.Name = toolMode.ItemName
		ToolButton.ControlPanelBuildFunction = toolMode.CPanelFunction
		ToolButton.Command = toolMode.Command
		ToolButton.Controls = toolMode.Controls
		ToolButton.Text = toolMode.Text
		ToolButton:Dock( TOP )
		
		return ToolButton
	end
	
	for k, v in pairs( LDRP.VIPTools ) do
		local ToolButton = tools:Add( GenerateToolButton ( v ) )
		ToolButton:SetImage( "icon16/star.png" )
	end
	
	for k, v in pairs( LDRP.Tools ) do
		local ToolButton = tools:Add( GenerateToolButton( v ) )
	end
	
	self.ToolList.ToolPanels[ 1 ] = tools
	self.ToolList:AddSheet("Tools", tools, "icon16/wrench.png")
	
	tools.SetActive = function( self2, cp )
		self.ControlPanel:SetActive( cp )
	end
	
	self:LoadTools()
	
	self.ControlPanel = vgui.Create("DCategoryList", self.Opened["Tools"])
	self.ControlPanel:SetPos(12, ((ScrH()*.84) / 2) + 48)
	self.ControlPanel:SetSize(ScrW()*.25-24, (ScrH()*.84-12) / 2)
	
	self.ControlPanel.ClearControls = function( panel )
		panel:Clear()
	end
	
	function self.ControlPanel:SetActive( cp )
		local kids = self:GetCanvas():GetChildren()
		for k, v in pairs( kids ) do
			v:SetVisible( false )
		end
		
		self:AddItem( cp )
		cp:SetVisible( true )
		cp:Dock( TOP )
	end
end

--[[	LoadTools
			Load all tool _menus_ given from spawnmenu.GetTools()
]]
function PANEL:LoadTools()
	local tools = spawnmenu.GetTools()

	for strName, pTable in pairs( tools ) do
		if pTable.Name ~= "AAAAAAA_Main" then
			local toolPanel = vgui.Create("ToolPanel")
			toolPanel.Content:Remove()
			toolPanel.Content = nil
			toolPanel.List:StretchToParent(nil, nil, 0, nil)
			toolPanel:SetTabID(strName)
			toolPanel:LoadToolsFromTable(pTable.Items)
			toolPanel.SetActive = function( self2, cp )
				self.ControlPanel:SetActive( cp )
			end
			
			self.ToolList:AddSheet(pTable.Label, toolPanel, pTable.Icon)
			self.ToolList.ToolPanels[ strName ] = toolPanel
		end
	end
end

function PANEL:GetToolMenu()
	return self.ToolList
end

function PANEL:CreateBG(name, x, y, w, h)
	local BackGroundWindow
	BackGroundWindow = vgui.Create("DFrame")
	self.Opened[name] = BackGroundWindow
	BackGroundWindow:SetPos(x,y)
	BackGroundWindow:SetSize(w,h)
	BackGroundWindow:MakePopup()
	BackGroundWindow:SetDraggable(false)
	BackGroundWindow:ShowCloseButton(false)
	BackGroundWindow:SetTitle("")
	BackGroundWindow:SetParent(self)
	BackGroundWindow.Paint = function()
		draw.RoundedBox( 8, 0, 0, w, h, LDRPColorMod(0,0,0,-40) )
		draw.RoundedBox( 8, 6, 6, w-12, h-12, LDRPColorMod(40,40,40,-40) )
		draw.SimpleTextOutlined(name, "HUDNumber", w*.5, h*.03, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0) )
	end
end

function PANEL:SetPropList(section)
	if self.QOpened == section then return end
	
	LDRP.LastTab = section
	self.QOpened = section
	
	for k,v in pairs(self.CurSpawnList) do
		if v:IsValid() then v:Remove() end
	end
	
	self.CurSpawnList = {}
	
	for k,v in pairs(LDRP.Props[section]) do
		local PropIcon = vgui.Create("SpawnIconMenu", self.PropList)
		PropIcon:SetModel(v)
		PropIcon:SetSize(81, 81)
		PropIcon.Mdl = v
		PropIcon.Section = section
		PropIcon:SetToolTip()
		
		PropIcon.RefreshList = function()
			self.PropList:RefreshList()
		end
		
		PropIcon.DoClick = function()
			RunConsoleCommand("gm_spawn",v)
			LocalPlayer():EmitSound("UI/buttonclickrelease.wav",60,150)
		end
		
		self.PropList:AddItem(PropIcon)
		table.insert(self.CurSpawnList, PropIcon)
	end
	
	self.PropList:RefreshList()
end

--We'll have this simply switch to the appropriate menu on the spawn menu.
function PANEL:OpenCreationMenuTab( name )
	local createTabs = spawnmenu.GetCreationTabs()
	
	for k,v in pairs(self.CurSpawnList) do
		if v:IsValid() then v:Remove() end
	end
	self.CurSpawnList = {}
	
	local pan = createTabs[ name ].Function()
	pan:SetParent( self.PropList )
	pan:Dock( FILL )
	table.insert( self.CurSpawnList, pan )
	
	self.PropList:RefreshList()
	LDRP.LastTab = name
	self.QOpened = name
end

function PANEL:HangOpen( bHang )
    self.m_bHangOpen = bHang
end

function PANEL:HangingOpen()
    return self.m_bHangOpen
end

function PANEL:Open()

    RestoreCursorPosition()

    self.m_bHangOpen = false
    
    -- If the context menu is open, try to close it..
    if ( g_ContextMenu:IsVisible() ) then
        g_ContextMenu:Close( true )
    end
    
    if ( self:IsVisible() ) then return end
    
    CloseDermaMenus()
    
    self:MakePopup()
    self:SetVisible( true )
    self:SetKeyboardInputEnabled( false )
    self:SetMouseInputEnabled( true )
    self:SetAlpha( 255 )

    achievements.SpawnMenuOpen()
end

function PANEL:Close( bSkipAnim )

    if ( self.m_bHangOpen ) then
        self.m_bHangOpen = false
        return
    end
    
    RememberCursorPosition()
    
    CloseDermaMenus()

    self:SetKeyboardInputEnabled( false )
    self:SetMouseInputEnabled( false )
    self:SetVisible( false )
end

--[[---------------------------------------------------------
   Name: StartKeyFocus
-----------------------------------------------------------]]
function PANEL:StartKeyFocus( pPanel )

    self.m_pKeyFocus = pPanel
    self:SetKeyboardInputEnabled( true )
    self:HangOpen( true )
    
    g_ContextMenu:StartKeyFocus( pPanel )
    
end

--[[---------------------------------------------------------
   Name: EndKeyFocus
-----------------------------------------------------------]]
function PANEL:EndKeyFocus( pPanel )

    if ( self.m_pKeyFocus != pPanel ) then return end
    self:SetKeyboardInputEnabled( false )
    
    g_ContextMenu:EndKeyFocus( pPanel )

end

vgui.Register( "LDRPSpawnMenu", PANEL, "EditablePanel" )

--[[function GM:OnSpawnMenuClose()
	if LDRP.Opened then
		for k,v in pairs(LDRP.Opened) do
			if v:IsValid() then v:Close() end
		end
		LDRP.Opened = nil
	end
end]]

--[[Creates the LDRP spawn menu GUI.
	This function wasn't in the original LDRP code,
	but I figure making this act more like the default
	spawnmenu will fix some compatibility issues
	*cough*Tool panels*cough*
]]
local function CreateSpawnMenu()
	-- If we have an old spawn menu remove it.
    if ( g_SpawnMenu ) then
    
        g_SpawnMenu:Remove()
        g_SpawnMenu = nil
    
    end
	
	-- Start Fresh
    spawnmenu.ClearToolMenus()
	
	-- Add defaults for the gamemode. In sandbox these defaults
    -- are the Main/Postprocessing/Options tabs.
    -- They're added first in sandbox so they're always first
    hook.Run( "AddGamemodeToolMenuTabs" )
    
    -- Use this hook to add your custom tools
    -- This ensures that the default tabs are always
    -- first.
    hook.Run( "AddToolMenuTabs" )
    
    -- Use this hook to add your custom tools
    -- We add the gamemode tool menu categories first
    -- to ensure they're always at the top.
    hook.Run( "AddGamemodeToolMenuCategories" )
    hook.Run( "AddToolMenuCategories" )
    
    -- Add the tabs to the tool menu before trying
    -- to populate them with tools.
    hook.Run( "PopulateToolMenu" )
	
	g_SpawnMenu = vgui.Create( "LDRPSpawnMenu" )

	g_SpawnMenu:SetVisible( false )
    
    CreateContextMenu()

    hook.Run( "PostReloadToolsMenu" )
end

function GM:OnSpawnMenuOpen()
    -- Let the gamemode decide whether we should open or not..
    if ( !hook.Call( "SpawnMenuOpen", GAMEMODE ) ) then return end

    if ( g_SpawnMenu ) then
    
        g_SpawnMenu:Open()

    end
    
end

function GM:OnSpawnMenuClose()
    if ( g_SpawnMenu ) then g_SpawnMenu:Close() end

    -- We're dragging from the spawnmenu but the spawnmenu is closed
    -- so keep the dragging going using the screen clicker
    if ( dragndrop.IsDragging() ) then
        gui.EnableScreenClicker( true )
    end
end

-- Hook to create the spawnmenu at the appropriate time (when all sents and sweps are loaded)
-- This is different from the default spawnmenu hook because LocalPlayer is called.
hook.Add( "InitPostEntity", "CreateSpawnMenu", CreateSpawnMenu )