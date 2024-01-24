local GM = GM or GAMEMODE;

local function PrintConsoleTaggedMessage(msg)
  MsgC(R_INVENTORY.config.chatTagColor, '[' .. R_INVENTORY.config.chatTag .. ']');
  MsgN(msg);
end

--[[---------------------------------------------------------------------------

R_INVENTORY Init

---------------------------------------------------------------------------]]
local function rInventoriesinitDatabase()
  PrintConsoleTaggedMessage('Starting Database Initialize');

  MySQLite.begin();

  local isMysql = MySQLite.isMySQL();
  local AUTOINCREMENT = isMysql and 'AUTO_INCREMENT' or 'AUTOINCREMENT';
  local ENGINE_INNODB = isMysql and 'ENGINE=InnoDB' or '';

  MySQLite.queueQuery([[
    CREATE TABLE IF NOT EXISTS inventories (
      id INTEGER NOT NULL PRIMARY KEY,
      name VARCHAR(50) NOT NULL,
      player_id INTEGER NOT NULL,
      max_slots INTEGER NOT NULL,
      max_weight INTEGER NOT NULL
    ) ]] .. ENGINE_INNODB .. [[;
  ]])

  MySQLite.queueQuery([[
    CREATE TABLE IF NOT EXISTS inventory_stored_items (
      id INTEGER NOT NULL PRIMARY KEY ]] .. AUTOINCREMENT .. [[,
      item_id INTEGER NOT NULL,
      player_id INTEGER NOT NULL,
      inventory_id INTEGER NOT NULL,
      weight INTEGER NOT NULL,
      quantity INTEGER NOT NULL
    )
  ]])

  MySQLite.commit(function ()
    hook.Call('rInventoryDBInitialized');
  end)
end

local function InitFinished(status)
  PrintConsoleTaggedMessage(status and 'Loaded' or 'Failed Loading')
end

local function rInventoryDbInitFinished(status)
  InitFinished(status);
end

local function rInventoryInit()
  rInventoriesinitDatabase();
end

hook.Add('Initialize', 'rInventoryInit', rInventoryInit);
hook.Add('rInventoryDBInitialized', 'rInventoryDbInit', function ()
    rInventoryDbInitFinished(true);
end)

