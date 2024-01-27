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
return components
