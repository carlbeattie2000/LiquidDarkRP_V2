local GM = GM or GAMEMODE;

-- First time spawn init
local function createDefaultInventoriesQueries(ply)
  local inventoryQueries = {}

  for inventory, inventoryConfig in pairs(R_INVENTORY.config.inventories) do
    local query = [[
      INSERT INTO inventories(id, name, player_id, max_slots, max_weight) VALUES (
        ]] .. MySQLite.SQLStr(inventoryConfig.ID) .. [[,]] ..
        MySQLite.SQLStr(inventory) .. [[,]] ..
        MySQLite.SQLStr(string.upper(ply:SteamID())) .. [[,]] ..
        MySQLite.SQLStr(inventoryConfig.enableSlotSystem and inventoryConfig.defaultMaxSlots or R_INVENTORY.config.defaultMaxSlots or 0) .. [[,]] ..
        MySQLite.SQLStr(inventoryConfig.enableWeightSystem and inventoryConfig.defaultMaxWeight or R_INVENTORY.config.defaultMaxWeight or 0) .. [[
      )
    ]]

    table.insert(inventoryQueries, query:format(
      inventoryConfig.ID,
      inventory,
      string.upper(ply:SteamID()),
      inventoryConfig.enableSlotSystem and inventoryConfig.defaultMaxSlots or R_INVENTORY.config.defaultMaxSlots or 0,
      inventoryConfig.enableWeightSystem and inventoryConfig.defaultMaxWeight or R_INVENTORY.config.defaultMaxWeight or 0
    ));
  end

  return inventoryQueries;
end

local function rInvetoriesNewPlayerInitDatabase(ply)
  local getPlayerQuery = 'SELECT player_id FROM inventories WHERE player_id = ' .. MySQLite.SQLStr(ply:SteamID()) .. ';';

  MySQLite.query(
    getPlayerQuery,
    function (data, ...)
      if !data then
        local inventoryQueries = createDefaultInventoriesQueries(ply);

        MySQLite.begin();

        for _, inventoryQuery in ipairs(inventoryQueries)  do
          MySQLite.queueQuery(inventoryQuery);
        end

        MySQLite.commit(function ()
          ply:SetInventoryMoney(GM.Config.startingmoney);
        end);
      end
    end
  )
end

hook.Add('PlayerInitialSpawn', 'createDbTablesForNewPlayers', function(ply)
  rInvetoriesNewPlayerInitDatabase(ply);
end);

