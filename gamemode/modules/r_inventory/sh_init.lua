R_INVENTORY = R_INVENTORY or {};

R_INVENTORY.config = {};
R_INVENTORY.config.enableWeightSystem = true;
R_INVENTORY.config.enableSlotSysytem = true;
R_INVENTORY.config.defaultMaxWeight = 30;
R_INVENTORY.config.defaultMaxSlots = 18;
R_INVENTORY.config.blackListedItems = {};
R_INVENTORY.config.chatTag = 'R_INVENTORY';
R_INVENTORY.config.chatTagColor = Color(213, 100, 100);
R_INVENTORY.config.moduleName = 'r_inventory';

-- Static Inventories
-- Eg. The players main inventory, or a bank
-- You can set each inventory to have its own config, or they will use the one
-- above, but each must have it's own unique ID
R_INVENTORY.config.inventories = {}

R_INVENTORY.config.inventories.player = {
  ['ID'] = 1
}
R_INVENTORY.config.inventories.bank = {
  ['ID'] = 2,
  ['enableWeightSystem'] = false,
  ['enableSlotSysytem'] = true,
  ['defaultMaxSlots'] = 24,
}

R_INVENTORY.config.NetMessages = {};

R_INVENTORY.config.NetMessages.getWallet = "R_PLAYER_WALLET_REQUEST";
R_INVENTORY.config.NetMessages.recievedWallet = "R_PLAYER_WALLET_RECIEVED";
R_INVENTORY.config.NetMessages.getUpdatedInventory = "R_INV_UPDATE_REQUEST";
R_INVENTORY.config.NetMessages.recievedUpdatedInventory = "R_INV_UPDATE_RECIEVED";
