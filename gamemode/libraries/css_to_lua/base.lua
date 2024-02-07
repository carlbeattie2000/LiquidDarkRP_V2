local Base = {}

local __nodeIdManager = {}
__nodeIdManager.id = 0
function __nodeIdManager:GetId()
  local r_id = __nodeIdManager.id
  __nodeIdManager.id = __nodeIdManager.id + 1
  return r_id
end

Base.OutterBoxModels = {
  CONTENT_BOX = "0",
  BORDER_BOX = "1"
}

Base.DisplayTypes = {
  BLOCK = "0",
  GRID = "1"
}

function Base:Create(id)
  local base = {}

  local __id = __nodeIdManager:GetId() -- You may not assign it an ID, so we have to give it a generic one
  local parent = nil
  local children = {}
  id = id or nil

  local padding = {}
  padding.top = 0
  padding.right = 0
  padding.bottom = 0
  padding.left = 0

  function base:IsValid()
    return true
  end

  function base:SetPadding(top, right, bottom, left)
    top = top or 0
    right = right or 0
    bottom = bottom or 0
    left = left or 0

    Multi_Assert('Number', isnumber(top), isnumber(right), isnumber(bottom), isnumber(left))

    base:SetPaddingTop(top)
    base:SetPaddingRight(right)
    base:SetPaddingBottom(bottom)
    base:SetPaddingLeft(left)
  end

  function base:SetPaddingTop(top)
    top = top or 0

    Single_Assert('Number', isnumber(top))

    padding.top = top
  end

  function base:SetPaddingRight(right)
    right = right or 0

    Single_Assert('Number', isnumber(right))

    padding.right = right
  end

  function base:SetPaddingBottom(bottom)
    bottom = bottom or 0

    Single_Assert('Number', isnumber(bottom))

    padding.bottom = 0
  end

  function base:SetPaddingLeft(left)
    left = left or 0

    Single_Assert('Number', isnumber(left))

    padding.left = left
  end

  function base:GetPadding()
    local paddingCopy = {}

    paddingCopy.top = base:GetPaddingTop()
    paddingCopy.right = base:GetPaddingRight()
    paddingCopy.bottom = base:GetPaddingBottom()
    paddingCopy.left = base:GetPaddingLeft()

    return paddingCopy
  end

  function base:GetPaddingTop()
    return padding.top
  end

  function base:GetPaddingRight()
    return padding.right
  end

  function base:GetPaddingBottom()
    return padding.bottom
  end

  function base:GetPaddingLeft()
    return padding.left
  end

  local margin = {}
  margin.top = 0
  margin.right = 0
  margin.bottom = 0
  margin.left = 0

  function base:SetMargin(top, right, bottom, left)
    top = top or 0
    right = right or 0
    bottom = bottom or 0
    left = left or 0

    Multi_Assert('Number', isnumber(top), isnumber(right), isnumber(bottom), isnumber(left))

    base:SetMarginTop(top)
    base:SetMarginRight(right)
    base:SetMarginBottom(bottom)
    base:SetMarginLeft(left)
  end

  function base:SetMarginTop(top)
    top = top or 0

    Single_Assert('Number', isnumber(top))

    margin.top = top
  end

  function base:SetMarginRight(right)
    right = right or 0

    Single_Assert('Number', isnumber(right))

    margin.right = 0
  end

  function base:SetMarginBottom(bottom)
    bottom = bottom or 0

    Single_Assert('Number', isnumber(bottom))

    margin.bottom = bottom
  end

  function base:SetMarginLeft(left)
    left = left or 0

    Single_Assert('Number', isnumber(left))

    margin.left = left
  end

  function base:GetMargin()
    local marginCopy = {}

    marginCopy.top = base:GetMarginTop()
    marginCopy.right = base:GetMarginRight()
    marginCopy.bottom = base:GetMarginBottom()
    marginCopy.left = base:GetMarginLeft()

    return marginCopy
  end

  function base:GetMarginTop()
    return margin.top
  end

  function base:GetMarginRight()
    return margin.right
  end

  function base:GetMarginBottom()
    return margin.bottom
  end

  function base:GetMarginLeft()
    return margin.left
  end

  local box_model = {}

  base.outterTypes = Base.OutterBoxModels
  base.DisplayTypes = Base.DisplayTypes

  box_model.position = {}
  box_model.position.x = 0
  box_model.position.y = 0

  box_model.size = {}
  box_model.size.width = 0
  box_model.size.width = 0

  box_model.outter = self.OutterBoxModels.CONTENT_BOX
  box_model.inner = 'block'

  function base:SetBoxModel(model)
    Single_Assert('String', isstring(model))

    if model ~= base.OutterBoxModels.CONTENT_BOX and model ~= base.OutterBoxModels.BORDER_BOX then
      return false
    end

    box_model.outter = model
  end

  function base:SetDisplay(type)
    Single_Assert('String', isstring(type))

    if type ~= base.DisplayTypes.BLOCK and type ~= base.DisplayTypes.GRID then
      return false
    end

    box_model.inner = type
  end

  function base:GetBoxModel()
    local boxModelCopy = {}

    boxModelCopy.position = box_model.position
    boxModelCopy.size = box_model.size
    boxModelCopy.outter = box_model.outter
    boxModelCopy.inner = box_model.inner

    return boxModelCopy
  end

  local position = {}
  position.y = 0
  position.x = 0

  function base:SetPosition(x, y)
    x = x or 0
    y = y or 0

    Multi_Assert('Number', isnumber(x), isnumber(y))

    base:SetPositionX(x)
    base:SetPositionY(y)
  end

  function base:SetPositionX(x)
    x = x or 0

    Single_Assert('Number', isnumber(x))

    position.x = x
  end

  function base:SetPositionY(y)
    y = y or 0

    Single_Assert('Number', isnumber(y))

    position.y = y
  end

  function base:GetPosition()
    local positionCopy = {}

    positionCopy.x = base:GetPositionX()
    positionCopy.y = base:GetPositionY()

    return positionCopy
  end

  function base:GetPositionX()
    return position.x
  end

  function base:GetPositionY()
    return position.y
  end

  local size = {}
  size.width = 0
  size.height = 0

  function base:SetSize(width, height)
    width = width or 0
    height = height or 0

    Multi_Assert('Number', isnumber(width), isnumber(height))

    base:SetWidth(width)
    base:SetHeight(height)
  end

  function base:SetWidth(width)
    width = width or 0

    Single_Assert('Number')

    size.width = width
  end

  function base:SetHeight(height)
    height = height or 0

    Single_Assert('Number', isnumber(height))

    size.height = height
  end

  function base:GetSize()
    local sizeCopy = {}

    sizeCopy.width = base:GetWidth()
    sizeCopy.height = base:GetHeight()

    return sizeCopy
  end

  function base:GetWidth()
    return size.width
  end

  function base:GetHeight()
    return size.height
  end

  local border = {}
  border.thickness = 0
  border.color = Color(0, 0, 0, 255)
  border.radius = 0

  function base:SetBorder(thickness, color, radius)
    thickness = thickness or 0
    color = color or Color(0, 0, 0, 255)
    radius = radius or 0

    Multi_Assert('Number', isnumber(thickness), isnumber(radius))
    Single_Assert('Color', IsColor(color))

    base:SetBorderThickness(thickness)
    base:SetBorderColor(color)
    base:SetBorderRadius(radius)
  end

  function base:SetBorderThickness(thickness)
    thickness = thickness or 0

    Single_Assert('Number', isnumber(thickness))

    border.thickness = thickness
  end

  function base:SetBorderColor(color)
    color = color or Color(0, 0, 0, 255)

    Single_Assert('Color', IsColor(color))

    border.color = color
  end

  function base:SetBorderRadius(radius)
    radius = radius or 0

    Single_Assert('Number', isnumber(radius))

    border.radius = radius
  end

  function base:GetBorder()
    local borderCopy = {}

    borderCopy.thickness = base:GetBorderThickness()
    borderCopy.color = base:GetBorderColor()
    borderCopy.radius = base:GetBorderRadius()

    return borderCopy
  end

  function base:GetBorderThickness()
    return border.thickness
  end

  function base:GetBorderColor()
    return border.color
  end

  function base:GetBorderRadius()
    return border.radius
  end

  function base:SetProps(props)

    Single_Assert('Table', istable(props))

    if props.box_model then
      local box_model_prop = props.box_model

      if box_model_prop.model and IsValidEnum(base.outterTypes, box_model_prop.model) then
        box_model.outter = box_model_prop.model
      end

      if box_model_prop.display and IsValidEnum(base.DisplayTypes, box_model_prop.display) then
        box_model.inner = box_model_prop.display
      end
    end

    if props.margin then
      local margin_prop = props.margin

      if margin_prop.top then
        base:SetMarginTop(margin_prop.top)
      end

      if margin_prop.right then
        base:SetMarginRight(margin_prop.right)
      end

      if margin_prop.bottom then
        base:SetMarginBottom(margin_prop.bottom)
      end

      if margin_prop.left then
        base:SetMarginLeft(margin_prop.left)
      end
    end

    if props.padding then
      local padding_prop = props.padding

      if padding_prop.top then
        base:SetMarginTop(padding_prop.top)
      end

      if padding_prop.right then
        base:SetMarginRight(padding_prop.right)
      end

      if padding_prop.bottom then
        base:SetMarginBottom(padding_prop.bottom)
      end

      if padding_prop.left then
        base:SetMarginLeft(padding_prop.left)
      end
    end

    if props.position then
      local position_prop = props.position

      if position_prop.x then
        base:SetPositionX(position_prop.x)
      end

      if position_prop.y then
        base:SetPositionY(position_prop.y)
      end
    end

    if props.size then
      local size_prop = props.size

      if size_prop.width then
        base:SetWidth(size_prop.width)
      end

      if size_prop.height then
        base:SetHeight(size_prop.height)
      end
    end

    if props.border then
      local border_prop = props.border

      if border_prop.thickness then
        base:SetBorderThickness(border_prop.thickness)
      end

      if border_prop.color then
        base:SetBorderColor(border_prop.color)
      end

      if border_prop.radius then
        base:SetBorderRadius(border_prop.radius)
      end
    end
  end

  base.css_math = {}

  function base.css_math:CalculateBoxModel()
    if box_model.outter == Base.OutterBoxModels.CONTENT_BOX then
      base.css_math:CalculateContentBoxModel()
    end

    if box_model.outter == Base.OutterBoxModels.BORDER_BOX then
      base.css_math:CalculateBorderBoxModel()
    end
  end

  function base.css_math:CalculateContentBoxModel()
    local total_width = base:GetWidth() + base:GetPaddingLeft() + base:GetPaddingRight() + (base:GetBorderThickness() * 2)
    local total_height = base:GetHeight() + base:GetPaddingTop() + base:GetPaddingBottom() + (base:GetBorderThickness() * 2)

    box_model.size.width = total_width
    box_model.size.height = total_height
    box_model.position.x = base:GetPositionX()
    box_model.position.y = base:GetPositionY()
    -- How do I calculate the elements x,y when left and right padding has different values
  end

  function base.css_math:CalculateBorderBoxModel()

  end

  function base:AppendChild(element)
    if element:GetParent() ~= nil then
      -- Already has a position in the tree, lets remove it
      local elementParent = element:GetParent()
      elementParent:RemoveChild(element)
    end

    element:SetParent(base)
    table.insert(children, element)
  end

  function base:InsertBefore(element, referenceElement)
    Multi_Assert('Table', istable(element), istable(referenceElement))

    if not base:HasChildNodes() then
      return false
    end

    if element:GetParent() then
      -- Already has position in the tree, lets remove it
      local elementParent = element:GetParent()
      elementParent:RemoveChild(element)
    end

    for i, v in ipairs(children) do
      if v:__GetId() == referenceElement:__GetId() then
        table.insert(children, i, element)
        return true
      end
    end

    return false
  end

  function base:RemoveChild(child)
    if not base:HasChildNodes() then
      return nil
    end

    for i, v in ipairs(children) do
      if v:__GetId() == child:__GetId() then
        local old = children[i]
        table.remove(children, i)
        old:__RemoveParent()
        return old
      end
    end

    return nil
  end

  function base:ReplaceChild(new, old)
    Multi_Assert("Table", istable(new), istable(old))

    if not base:HasChildNodes() then
      return
    end

    for i, v in ipairs(children) do
      if v:__GetId() == old:__GetId() then
        children[i] = new
        break
      end
    end
  end

  function base:HasChildNodes()
    return children ~= nil and #children > 0
  end

  function base:GetRootNode()
    if parent == nil then
      return base
    end

    local node = base

    while node:GetParent() ~= nil  do
      node = node:GetParent()
    end

    return node
  end

  function base:FindById(find_id)
    Single_Assert("String", isstring(id))

    if base:GetId() == find_id then
      return base
    end

    local searchDown = base:FindByIdDown(find_id)

    if searchDown then
      return searchDown
    end

    return base:FindByIdUp(find_id)
  end

  function base:FindByIdDown(find_id)
    local found_element = nil

    for _, v in ipairs(base:GetChildren()) do
      if v:GetId() == find_id then
        return v
      end

      found_element = v:FindByIdDown(find_id)

      if found_element then
        return found_element
      end
    end

    return nil
  end

  function base:FindByIdUp(find_id)
    local node = base

    if node == nil or node:GetParent() == nil then
      return nil
    end

    while node:GetParent() ~= nil do
      node = node:GetParent()

      if node:GetId() == find_id then
        return node
      end

      for _, v in ipairs(node:GetChildren()) do
        if v:GetId() == find_id then
          return v
        end
      end
    end

    return nil
  end

  function base:SetId(new_id)
    Single_Assert("String", isstring(new_id))
    id = new_id
  end

  function base:GetId()
    return id
  end

  function base:__GetId()
    return __id
  end

  function base:GetParent()
    return parent
  end

  function base:SetParent(new_parent)
    Single_Assert("Table", new_parent)
    parent = new_parent
  end

  function base:__RemoveParent()
    parent = nil
  end

  function base:GetChildren()
    if not base:HasChildNodes() then
      return nil
    end

    return children
  end

  function base:NextSibling()
    if base:GetParent() == nil then
      return nil
    end

    for i, v in ipairs(base:GetParent():GetChildren()) do
      if v:__GetId() == base:__GetId() then
        return base:GetParent():GetChildren()[i + 1]
      end
    end

    return nil
  end

  function base:PreviousSibling()
    if base:GetParent() == nil then
      return nil
    end

    for i, v in ipairs(base:GetParent():GetChildren()) do
      if v:__GetId() == base:__GetId() then
        return base:GetParent():GetChildren()[i - 1]
      end
    end

    return nil
  end

  function base:FirstChild()
    if not base:HasChildNodes() then
      return nil
    end

    return base:GetChildren()[1]
  end

  function base:LastChild()
    if not base:HasChildNodes() then
      return nil
    end

    return base:GetChildren()[#base:GetChildren()]
  end

  if not IsValid(base) then return false end

  return base
end

return Base
