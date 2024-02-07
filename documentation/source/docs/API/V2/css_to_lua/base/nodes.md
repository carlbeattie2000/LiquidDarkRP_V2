---
id: nodes
title: Nodes
---

# Understanding Nodes in the Library
Elements are represented as nodes in a hierarchical tree structure. Each node serves as a building block for constructing complex layouts and designs. Although this library's main purpose is to allow styling and layout similar to CSS, it also incorporates some of the fundamentals of a structured document like HTML and includes methods commonly seen in JavaScript.

[Jump To Methods](#methods)

### Nodes and Hierarchy
- Root Node: The node with no parent is considered the root of the hierarchy. It serves as the starting point for organizing and structuring elements within the layout.
- Children Nodes: Each node can have zero or more children, which are subordinate nodes that are connected to the parent node. These children nodes enable the creation of nested layouts and designs.

### Elements as Nodes
- Elements Creation: Every element created using the library is represented as a node in the hierarchy. These nodes encapsulate the properties and behavior of the corresponding elements.
- Node Relationships: By defining parent-child relationships between nodes, you can establish the layout and structure of your design. Each node's position and appearance are influenced by its parent and children nodes.

### Flexible Design
- Versatility: The hierarchical nature of nodes allows for flexible and dynamic design compositions. Elements can be added, removed, or rearranged within the hierarchy to achieve desired layouts and visual arrangements.
- Scalability: The node-based approach provides scalability and adaptability to accommodate various design requirements and preferences.

### Methods
##### Creating our root node
I'll utilize these defined elements throughout the methods documentation to facilitate easy comprehension.
```lua
local CSSHUD = include('/path/to/library/export.lua')

local root = CSSHUD.Base:Create('therootnode') -- Optional: Pass a ID

local child_01 = CSSHUD.Base:Create('child_01')
local child_02 = CSSHUD.Base:Create('child_02')

root:AppendChild(child_01)
root:AppendChild(child_02)
```
##### [Append Child](https://developer.mozilla.org/en-US/docs/Web/API/Node/appendChild)
Appending a node to another involves attaching it as a child node to a parent node. If the node is already a child of another node, it is first removed from its current parent node, and then appended to the new parent node.
```lua
element:AppendChild(child)
```
##### [Insert Before](https://developer.mozilla.org/en-US/docs/Web/API/Node/insertBefore)
The `InsertBefore()` method of the Node interface inserts a node as a child of a specified parent node before a reference node. If the node already exists elsewhere, `insertBefore()` relocates it from its current position to the new one. This means it is automatically detached from its existing parent before being added to the specified new parent.
```lua
local child_03 = CSSHUD.Base:Create('child_03')
root:InsertBefore(child_03, child_02)
--[[
root {
    children {
        child_01 {

        },
        child_03 {

        },
        child_02 {

        }
    }
}
]]--
```
##### [Remove Child](https://developer.mozilla.org/en-US/docs/Web/API/Node/removeChild)
The `RemoveChild()` method searches for and removes the specified child node from its parent node.
```lua
root:RemoveChild(child)
```
Similar to JavaScript, you can also remove all children nodes of an node.
```lua
while root:FirstChild() do
    root:RemoveChild(root:FirstChild())
end
```

##### [Replace Child](https://developer.mozilla.org/en-US/docs/Web/API/Node/replaceChild)
The `ReplaceChild()` method substitutes the old node with the new one within its parent node.
```lua
root:ReplaceChild(new, old)
```

##### [Has Child Nodes](https://developer.mozilla.org/en-US/docs/Web/API/Node/hasChildNodes)
Returns true if the nodes children table is not empty
```lua
root:HasChildNodes()
```

##### [Get Root Node](https://developer.mozilla.org/en-US/docs/Web/API/Node/getRootNode)
To retrieve the root node, the method will search from the node it's called on up to the first parent node.
```lua
child_01:GetRootNode()
```
##### [Find By Id](https://developer.mozilla.org/en-US/docs/Web/API/Document/getElementById)
This will search downward through the tree and then upward to find the node with the given ID. Optionally, you can use the `FindByIdDown()` or `FindByIdUp()` methods if you know the path where the node with the ID is located.

**Please note that we're not checking for uniqueness, so it's important to be careful and avoid assigning the same ID to two nodes within the same tree, as this would cause issues.**
:::warning[  ]
If you really want to, you can get the node's unique ID with `__GetId()` and then use `SetId(id)` to set the node's user-facing ID to the internally used unique ID, so you won't run into issues and don't have to keep mental track if the ID is unique. However, I wouldn't recommend this approach.
:::
```lua
local child_03_found = root:FindById('child_03')
local root_found = child_03:FindById('therootnode')
```
##### GetId
Retrieve the ID of the node that was set either during creation or modified later.
```lua
root:GetId()
```

##### Get Parent
Returns the nodes parent or nil
```lua
root:GetParent() -- nil
child_01:GetParent() -- root
```

##### Set Parent
:::danger
The `SetParent()` method is primarily used internally. I would advise against directly setting a node's parent.
```lua
child_03:SetParent(child_01)
```
:::

##### Get Children
Returns a table containing the children nodes of the current node.
```lua
root:GetChildren()
```

##### Next Sibling
Returns the next sibling node of the current node, or nil if there isn't one.
```lua
root:NextSibling() -- nil
child_01:NextSibling() -- child_03
```

##### Previous Sibling
Returns the previous sibling node of the current node, or nil if there isn't one.
```lua
child_01:PreviousSibling() -- nil
child_03:PreviousSibling() -- child_01
```

##### First Child
Returns the first child node of the current node, or nil if there are no children.
```lua
root:FirstChild() -- child_01
child_01:FirstChild() -- nil
```

##### Last Child
Returns the last child node of the current node, or nil if there are no children.
```lua
root:LastChild() -- child_02
child_01:LastChild() -- nil
```
