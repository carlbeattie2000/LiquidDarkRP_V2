R_INVENTORY = R_INVENTORY or {}
R_INVENTORY.Inventories = {}

function R_INVENTORY.getWallet()
  net.Start(R_INVENTORY.config.NetMessages.getWallet);
  net.SendToServer();
end

net.Receive(R_INVENTORY.config.NetMessages.recievedWallet, function()
  print(net.ReadInt());
end);

net.Receive(R_INVENTORY.config.NetMessages.recievedUpdatedInventory, function()
  local inventory = net.ReadTable();
  
  R_INVENTORY.Inventories[inventory[1]["inventory_id"]] = inventory;

  for k, v in pairs(R_INVENTORY.Inventories) do
    print(k);
  end
end)