local function PrintConsoleTaggedMessage(msg)
  MsgC(R_INVENTORY.config.chatTagColor, "[" .. R_INVENTORY.config.chatTag .. "]");
  MsgN(msg);
end

concommand.Add('r_inventory_test', function (ply, _, _)
  ply:LiquidChat(R_INVENTORY.config.chatTag, R_INVENTORY.config.chatTagColor, R_INVENTORY.config.defaultMaxWeight);
end)

--[[---------------------------------------------------------------------------

R_INVENTORY Init

---------------------------------------------------------------------------]]
local function InitFinished(status)
  PrintConsoleTaggedMessage(status and "Loaded" or "Failed Loading")
end

local function rInventoryInit()
  local status = true;
  InitFinished(status);
end

hook.Add("Initialize", "rInventoryInit", rInventoryInit);
