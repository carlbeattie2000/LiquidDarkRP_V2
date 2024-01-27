local components = {}
function components.extraOptionsDefault()
    return {
        ["textOptions"] = {
            ["xAlign"] = TEXT_ALIGN_LEFT,
            ["nonParsed"] = false,
            ["multiline"] = false
        }
    }
end

local function centerXYToScreen(x, y, w, h, center_screen_x, center_screen_y)
    local center_x = IMGUI.CenterElement(0, ScrW(), w)
    local center_y = IMGUI.CenterElementY(0, ScrH(), h)
    if center_screen_x and center_screen_y then
        return {center_x, center_y}
    elseif center_screen_x then
        return {center_x, y}
    elseif center_screen_y then
        return {x, center_y}
    end
    return {x, y}
end

function components.DrawCenteredShrinkableProgressBar(x, y, w, h, center_screen_x, center_screen_y, barXDecrease, barYDecrease, percentage, text, borderRadiusOuter, borderRadiusInner, foreground, background, font, color)
    color = color or Color(255, 255, 255, 255)
    local updatedPos = centerXYToScreen(x, y, w, h, center_screen_x, center_screen_y)
    x = updatedPos[1]
    y = updatedPos[2]
    local barWidth = (w - barXDecrease) * percentage
    local barHeight = h - barYDecrease
    local barX = IMGUI.CenterElement(x, w, barWidth)
    local barY = IMGUI.CenterElementY(y, h, barHeight)
    local barTextWidth, barTextHeight = IMGUI.GetTextSize(text, font)
    draw.RoundedBox(borderRadiusOuter, x, y, w, h, background)
    draw.RoundedBox(borderRadiusInner, barX, barY, barWidth, barHeight, foreground)
    local textX = IMGUI.CenterElement(barX, barWidth, barTextWidth)
    local textY = IMGUI.CenterElementY(barY, barHeight, barTextHeight)
    draw.SimpleText(text, font, textX, textY, color)
end

function components.DrawTextBox(x, y, w, h, center_screen_x, center_screen_y, text, borderRadius, background, font, color, fitText, growLeft, extraOptions)
    color = color or Color(255, 255, 255, 255)
    fitText = fitText or false
    growLeft = growLeft or false
    nonParsed = nonParsed or false
    extraOptions = extraOptions or components.extraOptionsDefault()
    local textWidth, textHeight = IMGUI.GetMultiLineTextSize(text, font)
    if fitText and w < textWidth then w = textWidth end
    if fitText and h < textHeight then h = textHeight end
    if growLeft then x = x - w end
    local updatedPos = centerXYToScreen(x, y, w, h, center_screen_x, center_screen_y)
    x = updatedPos[1]
    y = updatedPos[2]
    local textX = IMGUI.CenterElement(x, w, textWidth)
    if extraOptions.textOptions.xAlign == TEXT_ALIGN_CENTER then textX = textX + textWidth / 2 end
    local textY = IMGUI.CenterElementY(y, h, textHeight)
    draw.RoundedBox(borderRadius, x, y, w, h, background)
    if extraOptions.textOptions.nonParsed then
        draw.DrawNonParsedText(text, font, textX, textY, color, extraOptions.textOptions.xAlign)
    elseif extraOptions.textOptions.multiline then
        draw.DrawText(text, font, textX, textY, color, extraOptions.textOptions.xAlign)
    else
        draw.SimpleText(text, font, textX, textY, color, extraOptions.textOptions.xAlign)
    end
end

-- Grid System
components.grids = {}

components.grids.CreateGrid = function (self, x, y, w, h, rows, columns,  gap, resize, col_w)
  if self and self.init then return end
  local grid_table = {}

  grid_table.init = true
  grid_table.x = x;
  grid_table.y = y;
  grid_table.w = w;
  grid_table.h = h;
  grid_table.rows = rows or 0;
  grid_table.columns = columns or 0;
  grid_table.gap = gap or 2;
  grid_table.resize = resize or false;
  grid_table.col_w = col_w or 0
  grid_table.grid_items = {};
  grid_table.items = 0;

  setmetatable(grid_table, {__index = components.grids})

  return grid_table
end

components.grids.addChild = function (self, w, h, row, column)
  row = row or false;
  column = column or false;

  if w > self.w and not self.resize then
    print("Warning! Your grid content will be wider than the grid.")
  end

  if h > self.h and not self.resize then
    print("Warning! Your grid content will be taller than the grid.")
  end
  if self.rows == 0 and self.columns == 0 then
    local row_item = self:addRow(w, h, row)
    return row_item;
  end
end

components.grids.addRow = function (self, w, h, row)
  row = row or false
  local lastY = 0
  if self.items == 0 then
    lastY = self.y + self.gap
  else
    for _, v in ipairs(self.grid_items) do
      lastY = v.y + v.h + self.gap;
    end
  end
  local row_item = {}
  row_item.x = self.x;
  row_item.y = lastY;
  row_item.w = w;
  row_item.h = h;
  table.insert(self.grid_items, row_item)
  self.items = self.items + 1;
  return row_item;
end


return components
