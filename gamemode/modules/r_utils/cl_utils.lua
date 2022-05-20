cUtils = cUtils || {}

cUtils.funcs = cUtils.funcs || {}

cUtils.config = cUtils.config || {}

function cUtils.funcs.ScreenScale(num, h)

	local devw = 2560 --Development height

	local devh = 1440 --Development width

	

	return num * (h and (ScrH() / devh) or (ScrW() / devw))

end

function cUtils.funcs.EditScrollBarStyle(scrollpanel, colour)

	local scrollbar = scrollpanel.VBar

	scrollbar.btnUp:SetVisible(false)

	scrollbar.btnDown:SetVisible(false)

	scrollbar:SetCursor("hand")

	scrollbar.btnGrip:SetCursor("hand")



	function scrollbar:PerformLayout()

		local wide = scrollbar:GetWide()

		local scroll = scrollbar:GetScroll() / scrollbar.CanvasSize

		local barSize = math.max(scrollbar:BarScale() * (scrollbar:GetTall() - (wide * 2)), cUtils.funcs.ScreenScale(10))

		local track = scrollbar:GetTall() - (wide * 2) - barSize

		track = track + 1



		scroll = scroll * track



		scrollbar.btnGrip:SetPos(0, (wide + scroll) - cUtils.funcs.ScreenScale(15, true))

		scrollbar.btnGrip:SetSize(wide, barSize + cUtils.funcs.ScreenScale(30))

	end

	local colour = colour or Color(10, 10, 10, 175)

	function scrollbar:Paint(w, h)

		cUtils.funcs.Rect(0, 0, scrollbar:GetWide() / 1.5, scrollbar:GetTall(), Color(colour.r, colour.g, colour.b, 100))

	end

	function scrollbar.btnGrip:Paint(w, h) 

		cUtils.funcs.Rect(0, 0, scrollbar.btnGrip:GetWide() / 1.5, scrollbar.btnGrip:GetTall(), colour or color_white)

	end

end

function cUtils.funcs.Rect(x, y, w, h, col)

	surface.SetDrawColor(col)

	surface.DrawRect(x, y, w, h)

end

-- Creates a nice looking combo box
-- Note: The dockMargin does not take a table, but a single value used for
-- all four sides.
-- The values takes a table, that is ipairs
function cUtils.funcs.PrettyComboBox(parent, x, y, w, h, defaultTxt, values, font, boxColor, boxFontColor, vBackColor, vFontColor, vBackHoverColor, vFontHoverColor, onSelect, dock, dockMargin)

  local comboBox = vgui.Create("DComboBox", parent || nil)

  comboBox:SetSize(w, h)
  comboBox:SetPos(x, y)
  comboBox:SetValue(defaultTxt)
  
  if dock then

    comboBox:Dock(dock)
    
    if dockMargin then

      comboBox:DockMargin(dockMargin, dockMargin, dockMargin, dockMargin)

    end

  end

  for i = 1, #values do

    comboBox:AddChoice(values[i])

  end

  comboBox.OnSelect = function(self, index, value)
  
    onSelect(value)
  
  end

  function comboBox:Paint(w, h)
  
    draw.RoundedBox(0, 0, 0, w, h, boxColor)

    draw.SimpleText(self:GetText(), font, cUtils.funcs.ScreenScale(10), h / 2, boxFontColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    return true
  
  end

  comboBox.OldOpen = comboBox.OldOpen || comboBox.OpenMenu

  function comboBox:OpenMenu(...)
  
    comboBox.OldOpen(self, ...)

    local tables = self.Menu:GetCanvas():GetChildren()

    for k, v in pairs(tables) do

      function v:Paint(w, h)

        local vFCol = vFontColor
        local vBColor = vBackColor

        if v.Hovered then

          vFCol = vFontHoverColor
          vBColor = vBackHoverColor

        end

        draw.RoundedBox(0, 0, 0, w, h, vBColor)

        draw.SimpleText(v:GetText(), font, cUtils.funcs.ScreenScale(10), h / 2, vFCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        return true
      
      end
    
    end
  
  end

  if parent == nil then return comboBox end

end

function cUtils.funcs.PrettyTextBox(parent, defaultTxt, x, y, w, h, font, bColor, fColor, onValueChange, dock, dockMargin)

  local textInput = vgui.Create("DTextEntry", parent or nil)

  textInput:SetSize(w, h)
  textInput:SetPos(x, y)
  textInput:SetFont(font)
  textInput:SetTextColor(fColor)
  textInput:SetPlaceholderColor(fColor)
  textInput:SetPlaceholderText(defaultTxt)

  if dock then

    textInput:Dock(TOP)

    if dockMargin then

      textInput:DockMargin(dockMargin, dockMargin, dockMargin, dockMargin)

    end
  
  end
  
  textInput.CurrentValue = defaultTxt

  function textInput.Paint(s, w, h)
  
    draw.RoundedBox(0, 0, 0, w, h, bColor)

    if (s:GetText() && (s:GetText() != "")) || s:HasFocus() then

      s:DrawTextEntryText(fColor, Color(0, 0, 255), Color(0, 0, 0, 255))

    else

      surface.SetTextColor(s:GetPlaceholderColor())
      surface.SetFont(font)
      
      local tw, th = surface.GetTextSize(tostring(defaultTxt))

      surface.SetTextPos(cUtils.funcs.ScreenScale(5, true), (h / 2) - (th / 2))

      surface.DrawText(tostring(defaultTxt))
    
    end
  
  end

  textInput:SetUpdateOnType(true)

  function textInput:OnValueChange(val)
  
    self.CurrentValue = val
    onValueChange(val)
  
  end

  function textInput:GetValue()
  
    return self.CurrentValue or defaultTxt
  
  end

  return textInput

end