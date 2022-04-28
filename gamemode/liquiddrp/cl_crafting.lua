local LDRP = {}

LDRP.NiceNames = LDRP_SH.NicerWepNames
function LDRP_SH.OpenCraftingMenu()
	local C = {}
	
	local W,H = 800,450
	
	C.BG = vgui.Create("DFrame")
	C.BG:SetPos(ScrW()*.5-(W*.5),ScrH()*.5-(H*.5))
	C.BG:MakePopup()
	C.BG:SetSize(W,H)
	C.BG:SetTitle("Crafting")
	
	C.Crafting = vgui.Create("DPanelList",C.BG)
	C.Crafting:SetPos(4,22)
	C.Crafting:SetSize(W-8,H-66)
	C.Crafting:EnableVerticalScrollbar(true)
	C.Crafting:SetPadding(4)
	C.Crafting:SetSpacing(4)
	
	local IcoSize = H*.15-8
	local RW,RH = W-16,H*.15
	local Selected
	for k,v in pairs(LDRP_SH.CraftItems) do
		local Recipe = vgui.Create("DPanel")
		Recipe:SetSize(RW,RH)
		
		local Str
		local num = 0
		for c,b in pairs(v.recipe) do

			num = num+1
			if Str then
				Str = Str .. ", " .. b .. " " .. (LDRP.NiceNames[c] or c)
			else
				Str = b .. " " .. (LDRP.NiceNames[c] or c)
			end	
		end
		
		Recipe.Paint = function()
			draw.RoundedBox( 8, 0, 0, RW, RH, (Selected == k and Color(255,255,255,180)) or Color(180,180,180,180) )
			draw.SimpleTextOutlined( k .. " (lvl " .. v.lvl .. ")", "Trebuchet24", 10+(IcoSize), RH*.5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
			draw.SimpleTextOutlined( "Resources needed: " .. Str, "Trebuchet22", 263+(IcoSize), RH*.5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
		end
		local Icon = vgui.Create("SpawnIcon",Recipe)
		Icon:SetPos(4,4)
		Icon:SetSize(IcoSize, IcoSize)
		Icon:SetModel(v.icon)
		Icon.OnCursorEntered = function() return false end
		Icon:SetToolTip()
		Icon.OnMousePressed = function() return false end
		
		local InvisButton = vgui.Create("DButton",Recipe)
		InvisButton:SetSize(RW,RH)
		InvisButton:SetDrawBackground(false)
		InvisButton.DoClick = function()
			Selected = k
			if C.CraftButton.Opened then
				C.CraftButton:SetDisabled(false)
				C.CraftButton:SetText("Craft")
				C.CraftButton.Opened = nil
			end
		end
		InvisButton:SetText("")
		C.Crafting:AddItem(Recipe)
	end
	
	C.CraftButton = vgui.Create("DButton",C.BG)
	C.CraftButton:SetDisabled(true)
	C.CraftButton:SetPos(4,H-40)
	C.CraftButton:SetSize(W-8,34)
	C.CraftButton:SetText("Click and item above to craft it.")
	C.CraftButton.Opened = true
	C.CraftButton.DoClick = function()
		RunConsoleCommand("__crft",Selected)
		C.BG:Close()
	end
end

