Spawning NPCs
===========
##### Note: You must have admin permissions to use the command.
##### Note: Dual-Word NPC names must be surrounded by "" when entered into the console.

```
ldrp_npcpos "npc_name"
```

```
Typing only ldrp_npcpos will display the list of npcs you can spawn.
```

Adding a NPC (simple method)
=================
##### Note: The method of which the NPCs are saved, and loaded disallows the use of the same player model twice (being fixed).

###### Open the file gamemode/liquiddrp/sh_liquiddrp.lua
###### Find the function AddNPC, bellow this we will add our NPC.
```
LDRP.AddNPC("Health NPC", -- The NPC name
"models/Humans/Group03m/Female_01.mdl", -- The model we want to use
nil, -- the NPCs team (leave as nil if you don't understand what it's doing)
"Hello, would you like me to heal you?", -- The text we would like the npc to show the user
{ -- NPC buttons
	["Yes, please"] = function() 
    RunConsoleCommand("_buyheal") -- run the console command to heal the player
  end,
	["No thanks"] = function() end -- button to close the menu
})
```

Adding a NPC (advanced method)
============

##### This method works near identical to the above, although do default UI is show for you, so you can create your own window you would like to be opened when the player interacts with the NPC.
##### Open the file gamemode/liquiddrp/sh_liquiddrp.lua and find the function AddCustomNPC, bellow this we will add our custom NPC
```
LDRP.AddCustomNPC(
  "Mayor Elections", -- the name of the NPC
  "models/mossman.mdl", -- the model
  "SendMayorElectionMenu" -- the console command to run on player use
)
```
Adding a NPC Store
========

##### Again, this method is similar to the above, but makes it easier to add NPC whose purpose is to sell items to the player.
##### Open the file gamemode/liquiddrp/sh_liquiddrp.lua and find the function CreateStore, bellow this we will add our custom NPC
```
LDRP.CreateStore(
  "Miner", -- the NPC name
  "models/Humans/Group02/male_02.mdl", -- the npc model
  "I'm too lazy to mine rocks. Do it for me.", -- description/display text on menu
  {["Pickaxe"] = 120,["hammer"] = 200}, -- the item the NPC sells, and the cost
  {["Stone"] = 500,["Gold"] = 700,["Ruby"] = 900, ["Diamond"] = 1100} -- the item the npc buys with the cost
)
```