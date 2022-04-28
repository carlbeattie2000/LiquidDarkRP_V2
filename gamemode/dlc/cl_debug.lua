concommand.Add( "ldrp_dbg_printcolors", function()
	print("SKIN table:")
	PrintTable(SKIN)
end )

concommand.Add( "ldrp_dbg_colorpalette", function()
	local function GenColorPanel( text, color, y, parent )
		local db = vgui.Create("DPanel", parent)
		db.Text = text
		db.Color = color
		db:SetPos(5, y + 5)
		db:SetSize(parent:GetWide() - 25, 20)
		db.Paint = function( panel )
			draw.RoundedBox( 0, 0, 0, panel:GetWide(), panel:GetTall(), Color(255, 255, 255, 255) )
			draw.RoundedBox( 2, 2, 2, panel:GetWide() - 4, panel:GetTall() - 4, panel.Color )
			draw.SimpleTextOutlined( panel.Text, "Trebuchet18", 5, 0, Color(255, 255, 255, 255), 0, 0, 1, Color(0, 0, 0, 255) )
			surface.SetFont("Trebuchet18")
			local wide = surface.GetTextSize( panel.Text)
			draw.SimpleTextOutlined( panel.Color.r..", "..panel.Color.g..", "..panel.Color.b..", "..panel.Color.a,
				"DermaDefault", wide + 10, 2, Color(200, 200, 200, 255), 0, 0, 1, Color(25, 25, 25, 255) )
		end
		
		return db
	end
	
	local dpanel = vgui.Create("DFrame")
	dpanel:SetTitle("Derma/Custom Skin Colors")
	dpanel:SetSize(350, 500)
	dpanel:SetPos(100, 100)
	dpanel:SetBGColor(0, 0, 0, 255)
	local spanel = vgui.Create("DScrollPanel", dpanel)
	spanel:StretchToParent( 0, 20, 5, 0 )
	local height = 0
	
	--Put in current theme colors first.
	local dl = vgui.Create( "DLabel", spanel )
	dl:SetText("Unmodified colors for the current skin:")
	dl:SizeToContents()
	dl:SetPos(5, 0)
	height = height + 13
	local dl2 = vgui.Create( "DLabel", spanel )
	dl2:SetText(LDRP_Theme.CurrentSkin)
	dl2:SetPos(5, height)
	dl2:SetFont("HudHintTextLarge")
	dl2:SizeToContents()
	height = height + 20
	
	for k, v in pairs(LDRP_Theme[LDRP_Theme.CurrentSkin]) do
		if type(v) == "table" then
			GenColorPanel(k, v, height, spanel)
			height = height + 25
		end
	end
	
	height = height + 20
	local dl3 = vgui.Create( "DLabel", spanel )
	dl3:SetText( "SKIN colors:" )
	dl3:SetPos(5, height)
	dl3:SizeToContents()
	height = height + 13
	--Now get the modified SKIN colors.
	for k, v in pairs(SKIN) do
		if type(v) == "table" and v.r ~= nil then
			GenColorPanel( k, v, height, spanel )
			height = height + 25
		end
	end
end )