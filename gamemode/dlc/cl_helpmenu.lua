--[[		"MENU "API""
	TabName:	String displayed next to the icon of the tab inserted into the options menu.
	TabIcon:	File relative to the materials directory that will be placed in the tab. 16x26 pixels.
	Panel:		The master panel that will be inserted into the tab.
]]

MENU = MENU or {}
MENU["Help"] = {}
MENU["Help"].TabName = "Help"
MENU["Help"].TabIcon = "icon16/book_open.png"

local containerw

function HelpTab(_containerw)
	containerw = _containerw
	MENU["Help"].Panel = vgui.Create("DScrollPanel")
	MENU["Help"].Panel:SetName("DScrollPanel")
	MENU["Help"].Panel:StretchToParent(0, 0, 0, 0)
	vgui.Create("HelpVGUI", MENU["Help"].Panel)
	return MENU["Help"]
end

local HelpPanel = {}

function HelpPanel:Init()
	self:SetName("HelpPanel")
	self.StartHelpX = -containerw
	self.HelpX = self.StartHelpX

	self.title = vgui.Create("DLabel", self)
	self.title:SetText(GAMEMODE.Name)
	self.title:SetFont("HUDNumber")
	self.title:SetPos(5, 0)
	self.title:SetTextColor(Color(75, 150, 225))
	self.title:SizeToContents()

	self.HelpInfo = vgui.Create("DPanel", self)
	self.HelpInfo:SetName("HelpInfo")

	self.vguiHelpCategories = {}
	self.vguiHelpLabels = {}
	self.Scroll = 0
	
	self:FillHelpInfo()
	self:InvalidateLayout()
end

function HelpPanel:FillHelpInfo()
	local LabelIndex = 0
	local yoffset = 0

	self.HelpInfo:Clear()
	for k, v in pairs(GAMEMODE:GetHelpCategories()) do
		self.vguiHelpCategories[k] = vgui.Create("DLabel", self.HelpInfo)
		self.vguiHelpCategories[k]:SetText(v.name)
		self.vguiHelpCategories[k].OrigY = yoffset
		self.vguiHelpCategories[k]:SetPos(5, yoffset)
		self.vguiHelpCategories[k]:SetFont("GModToolSubtitle")
		self.vguiHelpCategories[k]:SetColor(Color(140, 0, 0, 200))
		self.vguiHelpCategories[k]:SetExpensiveShadow(2, Color(0,0,0,255))
		self.vguiHelpCategories[k]:SizeToContents()

		surface.SetFont("ChatFont")

		local index = 0
		local labelCount = table.Count(v.labels)
		local labelw, labelh
		for i, label in pairs(v.labels) do
			labelw, labelh = surface.GetTextSize(label)
			LabelIndex = LabelIndex + 1

			self.vguiHelpLabels[LabelIndex] = vgui.Create("DLabel", self.HelpInfo)
			self.vguiHelpLabels[LabelIndex]:SetFont("ChatFont")
			self.vguiHelpLabels[LabelIndex]:SetText(label)
			self.vguiHelpLabels[LabelIndex]:SetWidth(labelw)
			self.vguiHelpLabels[LabelIndex].OrigY = yoffset + 25 + index * labelh
			self.vguiHelpLabels[LabelIndex]:SetPos(5, yoffset + 25 + index * labelh)
			self.vguiHelpLabels[LabelIndex]:SetColor(Color(255, 255, 255, 200))

			index = index + 1
		end
		
		surface.SetFont("GModToolSubtitle")
		local __w, cath = surface.GetTextSize("A")

		yoffset = yoffset + (cath + 15) + labelCount * labelh
	end

	self.ScrollSize = yoffset
end

function HelpPanel:PerformLayout()
	self.HelpInfo:SizeToChildren(0, 0)
	self.HelpInfo:SetPos(0, self.title:GetTall() + 5)
	self:SizeToChildren(0, 0)

	for k, v in pairs(self.vguiHelpCategories) do
		if not ValidPanel(v) then self.vguiHelpCategories[k] = nil continue end

		v:SetPos(5, v.OrigY - self.Scroll)
		v:SizeToContents()
	end

	for k, v in pairs(self.vguiHelpLabels) do
		if not ValidPanel(v) then self.vguiHelpLabels[k] = nil continue end

		v:SetPos(5, v.OrigY - self.Scroll)
		v:SizeToContents()
	end
end

function HelpPanel:Paint()
	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 150))
end

function HelpPanel:Think()
	if self.HelpX < 0 then
		self.HelpX = self.HelpX + 600 * FrameTime()
	end

	if self.HelpX > 0 then
		self.HelpX = 0
	end

	self:SetPos(self.HelpX, 20)
end

vgui.Register("HelpVGUI", HelpPanel, "DPanel")