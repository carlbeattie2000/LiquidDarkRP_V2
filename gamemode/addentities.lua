AddCustomShipment("AK47", "models/weapons/w_rif_ak47.mdl", "weapon_real_cs_ak47", 2450, "Weapons", 10, false, nil, false, {TEAM_GUN}) 
AddCustomShipment("MP5", "models/weapons/w_smg_mp5.mdl", "weapon_real_cs_mp5a5", 2200, "Weapons", 10, false, nil, false, {TEAM_GUN}) 
AddCustomShipment("M4", "models/weapons/w_rif_m4a1.mdl", "weapon_real_cs_m4a1", 2450, "Weapons", 10, false, nil, false, {TEAM_GUN}) 
AddCustomShipment("Mac10", "models/weapons/w_smg_mac10.mdl", "weapon_real_cs_mac10", 2150, "Weapons", 10, false, nil, false, {TEAM_GUN}) 
AddCustomShipment("PumpShotgun", "models/weapons/w_shot_m3super90.mdl", "weapon_real_cs_pumpshotgun", 1750, "Weapons", 10, false, nil, false, {TEAM_GUN}) 
AddCustomShipment("SniperRifle", "models/weapons/w_snip_g3sg1.mdl", "ls_sniper", 3750, "Weapons", 10, false, nil, false, {TEAM_GUN}) 

AddEntity("Money printer", "money_printer", "models/props_c17/consolebox01a.mdl", nil, nil, 1500, "Other", 2, "/buymoneyprinter")
AddEntity("Money printer cooler", "cooler", "models/nukeftw/faggotbox.mdl", nil, nil, 300, "Other", 2, "/buycooler")
AddEntity("Pot", "pot", "models/nater/weedplant_pot_dirt.mdl", nil, nil, 100, "Other", 7, "/buypot")

/*
Add those lines under your custom shipments. At the bottom of this file or in data/CustomShipments.txt

HOW TO ADD CUSTOM SHIPMENTS:
AddCustomShipment("<Name of the shipment(no spaces)>"," <the model that the shipment spawns(should be the world model...)>", "<the classname of the weapon>", <the price of one shipment>, <how many guns there are in one shipment>, <OPTIONAL: true/false sold seperately>, <OPTIONAL: price when sold seperately>, < true/false OPTIONAL: /buy only = true> , OPTIONAL which classes can buy the shipment, OPTIONAL: the model of the shipment)

Notes:
MODEL: you can go to Q and then props tab at the top left then search for w_ and you can find all world models of the weapons!
CLASSNAME OF THE WEAPON
there are half-life 2 weapons you can add:
weapon_pistol
weapon_smg1
weapon_ar2
weapon_rpg
weapon_crowbar
weapon_physgun
weapon_357
weapon_crossbow
weapon_slam
weapon_bugbait
weapon_frag
weapon_physcannon
weapon_shotgun
gmod_tool

But you can also add the classnames of Lua weapons by going into the weapons/ folder and look at the name of the folder of the weapon you want.
Like the player possessor swep in addons/Player Possessor/lua/weapons You see a folder called weapon_posessor 
This means the classname is weapon_posessor

YOU CAN ADD ITEMS/ENTITIES TOO! but to actually make the entity you have to press E on the thing that the shipment spawned, BUT THAT'S OK!
YOU CAN MAKE GUNDEALERS ABLE TO SELL MEDKITS!

true/false: Can the weapon be sold seperately?(with /buy name) if you want yes then say true else say no

the price of sold seperate is the price it is when you do /buy name. Of course you only have to fill this in when sold seperate is true.


EXAMPLES OF CUSTOM SHIPMENTS(remove the // to activate it): */

--EXAMPLE OF AN ENTITY(in this case a medkit)
--AddCustomShipment("bball", "models/Combine_Helicopter/helicopter_bomb01.mdl", "sent_ball", 100, 10, false, 10, false, {TEAM_GUN}, "models/props_c17/oildrum001_explosive.mdl")
--EXAMPLE OF A BOUNCY BALL:   		NOTE THAT YOU HAVE TO PRESS E REALLY QUICKLY ON THE BOMB OR YOU'LL EAT THE BALL LOL
-- AddCustomShipment("bball", "models/Combine_Helicopter/helicopter_bomb01.mdl", "sent_ball", 100, 10, true, 10, true)
-- ADD CUSTOM SHIPMENTS HERE(next line):
