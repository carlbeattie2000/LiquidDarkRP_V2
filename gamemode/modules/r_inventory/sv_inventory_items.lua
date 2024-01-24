local meta = FindMetaTable("Player");
--[[---------------------------------------------------------------------------

Special Items

---------------------------------------------------------------------------]]
R_INVENTORY_SPECIAL_ITEMS = {};

R_INVENTORY_SPECIAL_ITEMS.cash = {
  ['ID'] = 1
}

-- Players Wallet

function meta:AddInventoryMoney(amount, multiplier)
  multiplier = multiplier or 0;

  if amount == 0 or amount < 0 then
    PrintConsoleTaggedMessage(' Error adding inventory money, amount was invalid!');
    return;
  end

  local newTotal = self:GetInventoryMoney();

  if multiplier > 0 then
    newTotal = newTotal + amount * multiplier;
  else
    newTotal = newTotal + amount;
  end

  self:SetInventoryItem(R_INVENTORY_SPECIAL_ITEMS.cash['ID'], newTotal);
end

function meta:SetInventoryMoney(amount)
  if amount == 0 or amount < 0 then
    PrintConsoleTaggedMessage(' Error adding inventory money, amount was invalid!');
    return;
  end

  self:AddInventoryItem(R_INVENTORY_SPECIAL_ITEMS.cash['ID'], amount, 0);
end

function meta:GetInventoryMoney()
  local query = 'SELECT quantity FROM inventory_stored_items WHERE player_id = ' .. MySQLite.SQLStr(self:SteamID()) .. ';';
  local queryRecieved = MySQLite.query(query);
   
  return MySQLite.query(query)[1]['quantity'];
end

-- Networked

util.AddNetworkString("R_PLAYER_WALLET_REQUEST");
util.AddNetworkString("R_PLAYER_WALLET_RECEIVED");

local function sendClientWallet(len, ply)
  if ( not sUtils.playerIsValid(ply) ) then
    return;
  end

  net.Start("R_PLAYER_WALLET_RECEIVED");
  net.WriteInt(ply:GetInventoryMoney(), 32);
  net.Send(ply);
end

net.Receive("R_PLAYER_WALLET_REQUEST", sendClientWallet);

concommand.Add("R_INV_WALLET", function(ply)
  sendClientWallet(0, ply);
end)

-- Players wallet end

--[[---------------------------------------------------------------------------

Inventory Core

---------------------------------------------------------------------------]]
-- Networked 
util.AddNetworkString(R_INVENTORY.config.NetMessages.getUpdatedInventory);
util.AddNetworkString(R_INVENTORY.config.NetMessages.recievedUpdatedInventory);

function sendClientInventory(len, ply)
  if (not sUtils.playerIsValid(ply)) then
    return
  end

  local inventoryQuery = "SELECT * FROM inventory_stored_items WHERE player_id = " .. MySQLite.SQLStr(string.upper(ply:SteamID())) .. "and inventory_id = " .. MySQLite.SQLStr(net.ReadInt(8));
  local queriedInventoryData = MySQLite.query(inventoryQuery);

  net.Start(R_INVENTORY.config.NetMessages.recievedUpdatedInventory);
  net.WriteTable(queriedInventoryData);
  net.Send(ply);
end

net.Receive(R_INVENTORY.config.NetMessages.getUpdatedInventory, sendClientInventory);


-- Player Server Functions
function meta:GetInventoryItem(id)

end

function meta:AddInventoryItem(id, quantity, weight)
  local query = 'INSERT INTO inventory_stored_items(item_id, player_id, inventory_id, weight, quantity) VALUES(' .. MySQLite.SQLStr(id) .. ',' .. MySQLite.SQLStr(string.upper(self:SteamID())) .. ',' .. MySQLite.SQLStr(R_INVENTORY.config.inventories.player['ID']) .. ',' .. MySQLite.SQLStr(weight) .. ',' .. MySQLite.SQLStr(quantity) .. ');';

  MySQLite.query(query);
end

function meta:SetInventoryItem(id, quantity)

end

-- Hooks
hook.Add('PlayerInitialSpawn', 'createDbTablesForNewPlayers', function(ply)
  sendClientInventory(0, ply);
end);