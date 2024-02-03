---
id: box_model
title: Box Model
---

Drawing inspiration from the [CSS Box Model](https://developer.mozilla.org/en-US/docs/Learn/CSS/Building_blocks/The_box_model), I've implemented a system that mirrors its principles. When creating a HUD element and adjusting its padding, margin, size, and other attributes, the same rules are applied.

This ensures consistency and familiarity in managing the layout and appearance of your HUD elements, just like working with CSS.

Every element within this library is constructed based on the box model principle.

### Fundamental Properties of HUD Elements:

#### Box Model Outter Types
##### [Standard](https://developer.mozilla.org/en-US/docs/Learn/CSS/Building_blocks/The_box_model#the_standard_css_box_model)
In the standard box model, setting inline-size and block-size (or width and height) properties defines the content box dimensions. Padding and borders are then added to these dimensions to determine the total size occupied by the box.
View the full list of box models [here](#box-models)
```lua title="Setting the box model to standard"
element:SetBoxModel(element.outterTypes.STANDARD)
```
##### [Border Box](https://developer.mozilla.org/en-US/docs/Learn/CSS/Building_blocks/The_box_model#the_alternative_css_box_model)
In the border box model, the width of the box corresponds directly to its visible width on the page. The content area width is calculated by subtracting the combined width of the padding and border from the total width of the box. There's no need to sum the border and padding to determine the actual size of the box.
View the full list of display types [here](#display-types)
```lua title="Setting the box model to border box"
element:SetBoxModel(element.outterTypes.BORDER_BOX)
```

#### Box Model Inner (Display) Types
The block property is used to render an element as a block-level element, meaning it takes up the full width available and starts on a new line. Block-level elements naturally stack on top of each other vertically.
##### [Block](https://developer.mozilla.org/en-US/docs/Glossary/Block/CSS)
```lua title="Setting the box model display type to block"
element:SetDisplay(element.DisplayTypes.BLOCK)
```

#### Getting the elements box model base properties
You can retreieve the base properties which include the position and size of the box-model
```lua title="Get the box model properties"
element:GetBoxModel()
--[[
{
    position = {
        x = number,
        y = number
    },
    size = {
        width = number,
        height = number
    },
    outter = enum,
    inner = enum
}
]]--
```

#### [Padding](https://developer.mozilla.org/en-US/docs/Web/CSS/padding)
This is the space between the content of an element and its border. It provides visual breathing room and helps to separate the content from the border of the element.
```lua title="Adjusting Element Padding"
element:SetPadding(top: number, right: number, bottom: number, left: number)

element:SetPaddingTop(top: number)
element:SetPaddingRight(right: number)
element:SetPaddingBottom(bottom: number)
element:SetPaddingLeft(left: number)
```
```lua title="Getting Element Padding"
element:GetPadding()
-- {
--    top = number
--    right = number
--    bottom = number
--    left = number
-- }

element:GetPaddingTop()
element:GetPaddingRight()
element:GetPaddingBottom()
element:GetPaddingLeft()
```

#### [Margin](https://developer.mozilla.org/en-US/docs/Web/CSS/margin)
This refers to the space between an element's border and adjacent elements. It creates separation between elements, influencing their positioning and overall layout on the page.
```lua title="Adjusting Element Padding"
element:SetMargin(top: number, right: number, bottom: number, left: number)

element:SetMarginTop(top: number)
element:SetMarginRight(right: number)
element:SetMarginBottom(bottom: number)
element:SetMarginLeft(left: number)
```
```lua title="Getting Element Padding"
element:GetMargin()
-- {
--    top = number
--    right = number
--    bottom = number
--    left = number
-- }

element:GetMarginTop()
element:GetMarginRight()
element:GetMarginBottom()
element:GetMarginLeft()
```

#### Elements Position
```lua title="Set the position of a element"
element:SetPosition(x: number, y: number)

element:SetPositionX(x: number)
element:SetPositionY(y: number)
```
```lua title="Get the position of a element"
element:GetPosition()
--[[
{
    x = number,
    y = number
}
]]--
element:GetPositionX() -- number
element:GetPositionY() -- number
```

#### Elements Size
```lua title="Set the size of a element"
element:SetSize(width: number, height: number)

element:SetWidth(width: number)
element:SetHeight(height: number)
```
```lua title="Get the size of a element"
element:GetSize()
--[[
{
    width = number,
    height = number
}
]]--

element:GetWidth() -- number
element:GetHeight() -- number
```
#### [Border](https://developer.mozilla.org/en-US/docs/Web/CSS/border)
Not all the CSS borders features will be implemented, but I hope most are eventually.
Features Included
- thickness
- color
- radius
```lua title="Setting the elements border"
element:SetBorder(thickness: number, color: Color, radius: number)

element:SetBorderThickness(thickness: number)
element:SetBorderColor(color: Color)
element:SetBorderRadius(radius: number)
```
```lua title="Getting the elements border"
element:GetBorder()
--[[
{
    thickness = number,
    color = Color,
    radius = number
}
]]--

element:GetBorderThickness() -- number
element:GetBorderColor() -- color
element:GetBorderRadius() -- number
```

#### Props
You can pass a table of properties where each element has its own defined properties, but all elements will inherit the base properties. Only the properties specified in the table will be applied or updated for each element.
```lua title="Setting the base elements props"
element:SetProps({
    box_model = {
        model = enum,
        display = enum
    },
    margin = {
        top = number,
        right = number,
        bottom = number,
        left = number
    },
    padding = {
        top = number,
        right = number,
        bottom = number,
        left = number
    },
    position = {
        x = number,
        y = number
    },
    size = {
        width = number,
        height = number
    },
    border = {
        thickness = number,
        color = Color,
        radius = number
    }
})
```

#### Specical Types
##### Enums
###### Box Models
```lua
element.outterTypes = {
    STANDARD = "0" -- The standard box model,
    BORDER_BOX = "1" -- The alternative box model
}
```
###### Display Types
```lua
element.DisplayTypes = {
    BLOCK = "0",
    GRID = "1"
}
```
