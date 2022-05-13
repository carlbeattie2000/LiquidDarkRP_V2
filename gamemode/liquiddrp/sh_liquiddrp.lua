-- Uncomment this to use fadmin
UseFadmin = true

UseFPP = true -- Use falco's prop protection?

LDRP_SH = {}

local LDRP = {}

LDRP_SH.UsePaycheckLady = false

LDRP_SH.ShowTutorial = false

LDRP_SH.ConfiscateCash = 200 -- How much cops get for confinscating PRINTERS

LDRP_SH.DisableQMenu = true -- Should the custom q menu be disabled?

LDRP_SH.ReplaceSkybox = false -- Should the gamemode replace the skybox with a much happier one?

LDRP_SH.SkyMat = "sky33" -- The skybox replacement mat, DO NOT EDIT IF YOU DON'T KNOW WHAT YOU ARE DOING

LDRP_SH.StackChecks = false -- If this is true, checks at the lady will stack.

LDRP_SH.NotifyNewVIPs = true -- Notify all players when a VIP is added

LDRP_SH.ChangeJobFuncs = {}

-- LDRP_SH.InterestCollectionDelay = 3600*24
LDRP_SH.InterestCollectionDelay = 60*5

-- TO ADD VIPS YOU MUST BE AN ADMIN AND TYPE ldrp_addvip targetsname

LDRP_SH.Printers = {}

LDRP_SH.PrOrder = {}

LDRP_SH.last = 0

function LDRP.AddNewPrinter(name, model, cost, prints, material, color)

	if !LDRP_SH.First then LDRP_SH.First = name end
	
	LDRP_SH.Printers[name] = {}

	LDRP_SH.Printers[name].mdl = model

	LDRP_SH.Printers[name].cost = cost

	LDRP_SH.Printers[name].mat = material

	LDRP_SH.Printers[name].clr = color

	LDRP_SH.Printers[name].prnt = prints
	
	LDRP_SH.last = LDRP_SH.last+1

	LDRP_SH.PrOrder[name] = LDRP_SH.last

end

LDRP.AddNewPrinter("Rusty Printer", "models/props_c17/consolebox01a.mdl", 0, 150, "models/props_pipes/GutterMetal01a", Color(255,255,255,255))

LDRP.AddNewPrinter("Aluminum Printer", "models/props_c17/consolebox03a.mdl", 1400, 200, "phoenix_storms/metal_plate", Color(255,255,255,255))

LDRP.AddNewPrinter("Steel Printer", "models/props_c17/consolebox03a.mdl", 1900, 250, "phoenix_storms/pack2/darkgrey", Color(255,255,255,255))

LDRP.AddNewPrinter("Ruby Printer", "models/props_c17/consolebox05a.mdl", 2600, 300, "models/shiny", Color(179,0,0,200))

LDRP.AddNewPrinter("Diamond Printer", "models/props_c17/consolebox05a.mdl", 3500, 350, "models/shiny", Color(200, 210, 247, 255))

--[[ Inventory and items ]]--

LDRP_SH.AllItems = {}

function LDRP.AddNewItem(Name, description, model, weight, clr, mat, realent, usefunc, usename, fakemdl)

	local name = string.lower(Name)

	LDRP_SH.AllItems[name] = {}

	LDRP_SH.AllItems[name].descr = description

	if string.sub(Name,1,6) == "weapon" then

		LDRP_SH.AllItems[name].iswep = true

	end

	LDRP_SH.AllItems[name].nicename = Name

	LDRP_SH.AllItems[name].mdl = model

	if CLIENT && model:EndsWith(".png") then

		LDRP_SH.AllItems[name].Material = Material(model, "noclamp smooth")

	end

	LDRP_SH.AllItems[name].clr = clr or Color(255,255,255,255)

	LDRP_SH.AllItems[name].mat = mat or ""

	LDRP_SH.AllItems[name].weight = weight or 1

	if usefunc then

		LDRP_SH.AllItems[name].use = usefunc

		LDRP_SH.AllItems[name].cuse = true

		if usename then LDRP_SH.AllItems[name].usename = usename end

	end

	if realent then

		LDRP_SH.AllItems[name].realent = realent

	end

	if fakemdl then

		LDRP_SH.AllItems[name].fakemdl = fakemdl

	end

end

LDRP.AddNewItem("Pot","Grow a flower inside of it.","models/nater/weedplant_pot_dirt.mdl",1,Color(255,255,255,255),"","pot")

LDRP.AddNewItem("Cooler","Prevents a printer from exploding 4 times.","models/nukeftw/faggotbox.mdl",1,Color(255,255,255,255),"","cooler")

LDRP.AddNewItem("Weed Bag","A dub sac of bud. Let's get stoned.","models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl",.03,Color(255,255,255,255),"",nil,function(ply)
	
	ply:ChatPrint("You smoked some weed.")
	
	local am = 4
	
	ply:ConCommand("pp_sobel 1;pp_sobel_threshold 1")
	
	local UID = ply:UniqueID()
	
	timer.Create("WeedTrip_" .. UID,5,4,function()
		
		if !ply:IsValid() then timer.Remove("WeedTrip_" .. UID) end
		
		am = am-1
		
		ply:ConCommand("pp_sobel_threshold " .. (am/4+.01))
		
		if am == 0 then
			
			timer.Simple(3,function()
				
				if !ply:IsValid() then return end
				
				ply:ConCommand("pp_sobel 0")
			
			end)
		
		end
	
	end)

end, "Smoke")

LDRP.AddNewItem("Crack","Smoke this and things will go faster","models/props_debris/metal_panelshard01a.mdl",.1,Color(255,255,255,255),"",nil,function(ply) end,"Smoke")

LDRP.AddNewItem("Weed Seed","Grow some marijuana","models/katharsmodels/contraband/zak_wiet/zak_seed.mdl",.1,Color(255,255,255,255),"",nil)
LDRP.AddNewItem("Carrot","Eat it for 2 HP","models/props/carrot.mdl",.1,Color(255,255,255,255),"",nil,function(ply) ply:ChatPrint("Yum. A carrot.") ply:EmitSound("LiquidDRP/eating.wav") ply:SetHealth(math.Clamp(ply:Health()+2, 1, 100)) end,"Eat")
LDRP.AddNewItem("Carrot Seed","Grow some carrots! Level up growing.","models/katharsmodels/contraband/zak_wiet/zak_seed.mdl",.1,Color(255,255,255,255),"",nil)

LDRP.AddNewItem("Melon","Eat it for 10 HP","models/props_junk/watermelon01.mdl",.15,Color(255,255,255,255),"",nil,function(ply) ply:ChatPrint("MMMMM!! MELONS!!!!") ply:EmitSound("LiquidDRP/eating.wav") ply:SetHealth(math.Clamp(ply:Health()+14, 1, 100)) end,"Eat")
LDRP.AddNewItem("Melon Seed","With the right amount of care, it turns into tasty, juicy goodness.","models/katharsmodels/contraband/zak_wiet/zak_seed.mdl",.1,Color(255,255,255,255),"",nil)

LDRP.AddNewItem("Ruby","Ruby Ore","models/props_junk/rock001a.mdl",.5,Color(255,0,0,200),"models/debug/debugwhite")
LDRP.AddNewItem("Gold","Gold Ore","models/props_junk/rock001a.mdl",.5,Color(255,255,0,255),"")
LDRP.AddNewItem("Stone","Some rocks that were mined.","models/props_junk/rock001a.mdl",.4,Color(255,255,255,255),"")
LDRP.AddNewItem("Diamond","Diamond Ore","models/props_junk/rock001a.mdl",.5,Color(185,242,255,255),"models/debug/debugwhite")


LDRP.AddNewItem("Pistol Ammo","Some ammo for a pistol.","models/Items/357ammo.mdl",.5,Color(255,255,255,255),"",nil,function(ply) ply:GiveAmmo(50, "pistol") end,"Equip")
LDRP.AddNewItem("Rifle Ammo","Some ammo for a rifle.","models/Items/BoxSRounds.mdl",.5,Color(255,255,255,255),"",nil,function(ply) ply:GiveAmmo(80, "smg1") end,"Equip")
LDRP.AddNewItem("Shotgun Ammo","Some ammo for a shotgun.","models/Items/BoxBuckshot.mdl",.5,Color(255,255,255,255),"",nil,function(ply) ply:GiveAmmo(50, "buckshot") end,"Equip")

LDRP.AddNewItem("Mushroom","Have a great trip!","models/props_swamp/shroom_ref_01.mdl",.05,Color(255,255,255,255),"",nil,function(ply)
	
	ply:EmitSound("LiquidDRP/eating.wav")
	
	ply:ChatPrint("Holy shit... This is awesome!")
	
	ply:ConCommand("pp_sharpen_distance 1")
	
	ply:ConCommand("pp_sharpen 1;pp_sharpen_contrast 2")
	
	local trip = 0
	local UID = ply:UniqueID()
	
	timer.Create("ShroomTrip_" .. UID,5,4,function()
		
		if !ply:IsValid() then timer.Remove("WeedTrip_" .. UID) end
		
		trip = trip+1
		
		ply:SetHealth(math.Clamp(ply:Health()+4, 1, 100))
		
		ply:ConCommand("pp_sharpen_contrast " .. (trip*2) .. ((trip == 3 and ";pp_sharpen_distance 2") or ""))
		
		if trip == 4 then
			
			timer.Simple(3,function()
				
				if !ply:IsValid() then return end
				
				ply:ConCommand("pp_sharpen 0")
			
			end)
		
		end
	
	end)

end,"Eat","models/props_junk/PopCan01a.mdl")

LDRP.AddNewItem("Mushroom Spore","Plant this to grow some mushrooms","models/props_swamp/shroom_ref_01.mdl",.1,Color(255,255,255,255),"",nil,nil,nil,"models/props_junk/PopCan01a.mdl")

LDRP_SH.AllCases = {}

local key = 1

function LDRP.AddNewCase(name, description, model, weight, clr, mat, realent, usename, fakemdl, id, bg, items )

  LDRP.AddNewItem(name, description, model, weight, clr, mat, realent, usefunc, usename, fakemdl)

  LDRP_SH.AllCases[name] = {
    ["nicename"] = name,
    ["icon"] = mat,
    ["prize_items"] = items,
    ["bg_clr"] = bg,
    ["id"] = id,
    ["key"] = ket
  }
  
  key = key + 1

end

LDRP.AddNewCase("Booster Case", "Open the case to claim your booster item!", "icon", .05, Color(213, 100, 100, 150), "models/shiny", nil, nil, "Open Case", nil, 1)

LDRP.AddNewCase("Money Case", "Open the case to claim your cash prize!", "icon", .05, Color(213, 100, 100, 150), "models/shiny", nil, nil, "Open Case", nil, 1)

LDRP.AddNewCase("Weapon Case", "Open the case to claim your weapon!", "icon", .05, Color(213, 100, 100, 150), "models/shiny", nil, nil, "Open Case", nil, 1)

LDRP_SH.NicerWepNames = {}

function LDRP.AddWeapon( class, nicename, description, model, weight, color, mat)

	LDRP.AddNewItem(class, description, model, weight, color || Color(255,255,255,255), mat, class,function(ply)

		local weapon = ents.Create(class)

		weapon:SetPos(ply:GetPos()+Vector(0,0,5))

		weapon.ammohacked = true

		weapon.IsUsing = ply

		weapon:Spawn()

		weapon:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)

	end,

	"Equip")

	LDRP_SH.NicerWepNames[class] = nicename

end

LDRP.AddWeapon("weapon_real_cs_ak47","AK47","An AK47","models/weapons/w_rif_ak47.mdl",.9)
LDRP.AddWeapon("weapon_real_cs_desert_eagle","Deagle","A deagle","models/weapons/w_pist_deagle.mdl",.5)
LDRP.AddWeapon("weapon_real_cs_five-seven","FiveSeven","A fiveseven","models/weapons/w_pist_fiveseven.mdl",.5)
LDRP.AddWeapon("weapon_real_cs_glock18","Glock","A glock","models/weapons/w_pist_glock18.mdl",.5)
LDRP.AddWeapon("weapon_real_cs_m4a1","M4","An M4","models/weapons/w_rif_m4a1.mdl",.9)
LDRP.AddWeapon("weapon_real_cs_mac10","Mac10","A Mac10","models/weapons/w_smg_mac10.mdl",.8)
LDRP.AddWeapon("weapon_real_cs_mp5a5","MP5","An MP5","models/weapons/w_smg_mp5.mdl",.8)
LDRP.AddWeapon("weapon_real_cs_p228","P228","A P228","models/weapons/w_pist_p228.mdl",.5)
LDRP.AddWeapon("weapon_real_cs_pumpshotgun","Shotgun","A shotgun","models/weapons/w_shot_m3super90.mdl",.8)
LDRP.AddWeapon("weapon_real_cs_usp","USP","A USP","models/weapons/w_pist_usp.mdl",.5)
LDRP.AddWeapon("weapon_real_cs_g3sg1","Rifle Upgrade","Automatic shooting, high damage.","models/weapons/w_snip_g3sg1.mdl",.8)
LDRP.AddWeapon("weapon_real_cs_xm1014","Shotgun Upgrade","Faster shoot rate.","models/weapons/w_shot_xm1014.mdl",.8)
LDRP.AddWeapon("weapon_real_cs_elites","Double Pistols","Hell yeah.","models/weapons/w_pist_elite.mdl",.6)
LDRP.AddWeapon("weapon_real_cs_galil","Galil","A galil.","models/weapons/w_rif_galil.mdl",.7)

LDRP.AddWeapon("weapon_real_cs_grenade","Explosive Grenade","BOOM!","models/weapons/w_eq_fraggrenade.mdl",.4)
LDRP.AddWeapon("weapon_real_cs_flash","Flash Grenade","I'm blind!!","models/weapons/w_eq_flashbang.mdl",.4)
LDRP.AddWeapon("weapon_real_cs_smoke","Smoke Grenade","Let's smoke this place.","models/weapons/w_eq_smokegrenade.mdl",.4)

LDRP.AddWeapon("weapon_real_cs_knife","Knife","I'LL CUT YOU UP!","models/weapons/w_knife_t.mdl",.3)


LDRP.AddWeapon("ls_sniper","Sniper","A sniper","models/weapons/w_snip_g3sg1.mdl",1)

LDRP.AddWeapon("pickaxe","Pickaxe","Pickaxe. Mine rocks.","models/weapons/w_stone_pickaxe.mdl",.65)
LDRP.AddWeapon("pickaxe1","Pickaxe upgrade 1","Pickaxe with better success.","models/weapons/w_stone_pickaxe.mdl",.75)
LDRP.AddWeapon("pickaxevip","Pickaxe upgrade 2","Pickaxe with much better success. (and it weighs less!)","models/weapons/w_stone_pickaxe.mdl",.65)
LDRP.AddWeapon("pickaxediamond","Diamond Pickaxe","Pickaxe with much better success. (and it's strong!)","models/weapons/w_stone_pickaxe.mdl",1, Color(102, 255, 224), "models/shiny")
LDRP.AddWeapon("pickaxenuclear","Nuclear Pickaxe","Strongest Pickaxe Created.","models/weapons/w_stone_pickaxe.mdl",2.5, Color(0, 204, 0), "models/shiny")
LDRP.AddWeapon("hammer","Crafting Hammer","Craft stuff with this.","models/weapons/w_sledgehammer.mdl",.7)

LDRP.AddWeapon("lockpick", "Lockpick", "Break into bases with this Basic lockpick", "models/weapons/w_crowbar.mdl", 1)
LDRP.AddWeapon("lockpickdiamond", "Diamond Lockpick", "Break into bases with this Diamond lockpick", "models/weapons/w_crowbar.mdl", 1, Color(102, 255, 224), "models/shiny")

--[[
LDRP.AddNewItem("Meth Stove","","models/props_junk/garbage_glassbottle001a.mdl",1,Color(255,255,255,255),"",nil)
LDRP.AddNewItem("Uncooked Meth","","models/props_junk/garbage_glassbottle001a.mdl",.1,Color(255,255,255,255),"",nil)
LDRP.AddNewItem("Meth","","models/props_junk/garbage_glassbottle002a.mdl",.2,Color(255,255,255,255),"",nil)
]]--

function LDRP_SH.ItemTable(name)

	return LDRP_SH.AllItems[name]

end

--[[ Growable Plants ]]--
LDRP_SH.AllGrowableItems = {}

LDRP_SH.PlantIDs = {}

function LDRP.AddGrowItem(Class, name, crop, cropam, time, plantmdl, plantpos, seedchance, reqlvl, exp, max, illegal, confiscated, reqteams)

	local class = string.lower(Class)

	LDRP_SH.PlantIDs[#LDRP_SH.PlantIDs+1] = class

	LDRP_SH.AllGrowableItems[class] = {}

	LDRP_SH.AllGrowableItems[class]["name"] = name
	LDRP_SH.AllGrowableItems[class]["crop"] = crop
	LDRP_SH.AllGrowableItems[class]["cropam"] = cropam
	LDRP_SH.AllGrowableItems[class]["time"] = time
	LDRP_SH.AllGrowableItems[class]["plantmdl"] = plantmdl
	LDRP_SH.AllGrowableItems[class]["plantpos"] = plantpos
	LDRP_SH.AllGrowableItems[class]["reqlvl"] = reqlvl
	LDRP_SH.AllGrowableItems[class]["exp"] = exp
	LDRP_SH.AllGrowableItems[class]["illegal"] = illegal or false
	LDRP_SH.AllGrowableItems[class]["confiscated"] = confiscated
	LDRP_SH.AllGrowableItems[class]["reqteams"] = reqteams
	LDRP_SH.AllGrowableItems[class]["max"] = max
	LDRP_SH.AllGrowableItems[class]["seedchance"] = seedchance

end

LDRP.AddGrowItem("Weed Seed","Marijuana Plant","weed bag",4,10,"models/FAG/delicious_penis.mdl",Vector(0,0,15),6,2,80,2,{TEAM_POLICE,TEAM_CHIEF,TEAM_DOCTOR},100,{TEAM_DRUGDEALER})

LDRP.AddGrowItem("Mushroom Spore","Mushroom","mushroom",7,10,"models/props_swamp/shroom_ref_01_cluster.mdl",Vector(0,0,10.5),5,3,130,3,{TEAM_POLICE,TEAM_CHIEF,TEAM_DOCTOR},50,{TEAM_DRUGDEALER})

LDRP.AddGrowItem("Carrot Seed","Carrot Plant","carrot",3,8,"models/nukeftw/faggotplant.mdl",Vector(0,0,10.5),4,1,110,5)

LDRP.AddGrowItem("Melon Seed","Melon Plant","melon",2,8,"models/nukeftw/faggotplant.mdl",Vector(0,0,10.5),6,2,125,3)

-- LDRP.AddGrowItem("Seed Name","Plant Name","crop name",crop amount,mins it takes,plant model,chance of seed 4 = 40% etc.,requiredlevel,exp,maximum plants,{table_of_illegal_teams},money for confiscating if illegal,{table_of_required_teams})

LDRP_SH.Rocks = {}

LDRP_SH.PickTime = 4

function LDRP.AddMiningRock(name,model,mat,color,spawnchance,levelneeded,expgive,minechance,maxpicks,maxinmap,itemgive,itemgiveamount,requireswep)

	LDRP_SH.Rocks[name] = {}

	LDRP_SH.Rocks[name].spawnchance = spawnchance
	LDRP_SH.Rocks[name].lvl = levelneeded
	LDRP_SH.Rocks[name].clr = color
	LDRP_SH.Rocks[name].exp = expgive
	LDRP_SH.Rocks[name].picks = maxpicks
	LDRP_SH.Rocks[name].picked = itemgive
	LDRP_SH.Rocks[name].pickedam = itemgiveamount
	LDRP_SH.Rocks[name].max = maxinmap
	LDRP_SH.Rocks[name].mat = mat
	LDRP_SH.Rocks[name].mdl = model
	LDRP_SH.Rocks[name].minechance = minechance
	LDRP_SH.Rocks[name].requireswep = requireswep

end

LDRP.AddMiningRock("Stone","models/props_wasteland/rockcliff01J.mdl","",Color(255,255,255,255),2,1,40,2,5000,5,"stone",1)
LDRP.AddMiningRock("Gold","models/props_wasteland/rockcliff01J.mdl","",Color(255,255,0,255),4,2,30,3,5000,5,"gold",1)
LDRP.AddMiningRock("Ruby","models/props_wasteland/rockcliff01J.mdl","models/shiny",Color(255,0,0,200),6,2,50,4,5000,5,"ruby",1)
LDRP.AddMiningRock("Diamond","models/props_wasteland/rockcliff01J.mdl","models/shiny",Color(185,242,255,255),6,3,50,4,5000,5,"diamond",1)

--[[ Player Skills ]]--

LDRP_SH.AllSkills = {}

function LDRP.AddSkill(name,description,mdl,exptable,costtbl,lvlfunc)

	LDRP_SH.AllSkills[name] = {}

	LDRP_SH.AllSkills[name].descrpt = description
	LDRP_SH.AllSkills[name].mdl = mdl
	LDRP_SH.AllSkills[name].exptbl = exptable
	LDRP_SH.AllSkills[name].pricetbl = costtbl

	local func = lvlfunc or nil

	LDRP_SH.AllSkills[name].OnLevelUp = func

	if type(func) == "function" then

		LDRP_SH.AllSkills[name].LvlFunction = true

	end

end

LDRP.AddSkill("Growing","Allows you to grow more types of plants.","models/nater/weedplant_pot_dirt.mdl",
	{[1] = 2000,[2] = 6000,[3] = 10000,[4] = 12000,[5] = 16000},
	{[1] = 2000,[2] = 1800,[3] = 2500,[4] = 4500,[5] = 5300}
)

LDRP.AddSkill("Mining","Allows you to mine different rocks.","models/weapons/w_stone_pickaxe.mdl",
	{[1] = 2000,[2] = 6000,[3] = 8000,[4] = 10000,[5] = 12000},
	{[1] = 2000,[2] = 1800,[3] = 4000,[4] = 5000,[5] = 6000}
)

LDRP.AddSkill("Crafting","Allows you to craft different items.","models/weapons/w_sledgehammer.mdl",
	{[1] = 2000,[2] = 6000,[3] = 10000,[4] = 12000,[5] = 16000},
	{[1] = 2000,[2] = 1800,[3] = 4000,[4] = 5000,[5] = 6000}
)

LDRP.AddSkill("Locksmith","Allows you to lockpick faster.","models/weapons/w_crowbar.mdl",
	{[1] = 2000,[2] = 3000,[3] = 5000,[4] = 7000,[5] = 8000},
	{[1] = 2000,[2] = 3500,[3] = 4000,[4] = 5000,[5] = 6000}
)
LDRP_SH.LockpickTimes = {[1] = 40,[2] = 35,[3] = 30,[4] = 25,[5] = 20}

LDRP.AddSkill("Hacking","Allows you to keypad crack faster.","models/props_lab/keypad.mdl",
	{[1] = 2000,[2] = 3000,[3] = 5000,[4] = 7000,[5] = 8000},
	{[1] = 2000,[2] = 3500,[3] = 4000,[4] = 5000,[5] = 6000}
)
LDRP_SH.CrackTimes = {[1] = 40,[2] = 35,[3] = 30,[4] = 25,[5] = 20}

LDRP.AddSkill("Stamina","Each level allows more inventory weight","models/props_junk/Shoe001a.mdl",
	{[1] = 4000,[2] = 8000,[3] = 12000,[4] = 16000,[5] = 20000}, -- EXP needed
	{[1] = 2000,[2] = 3000,[3] = 4000,[4] = 5000,[5] = 6000}, -- EXP cost
	

	function(ply) -- On level up

		local NewWeight = ply.Character.InvWeight.allowed+3
		
		ply.Character.InvWeight.allowed = NewWeight
		
		ply:SavePlayer("Inventory")
		
		umsg.Start("SendWeight",ply)
		
			umsg.Float(NewWeight)
		
		umsg.End()
	
	end

)



--[[ NPCs ]]--
local LeaveMessages = {"Oh, sorry.","Oh okay.","Sorry, didn't know","Fine then...","I just wanted to talk."}

LDRP_SH.AllNPCs = {}

LDRP_SH.ModelToName = {}

function LDRP.AddNPC(name, mdl, Team, descrpt, buttons)

	LDRP_SH.AllNPCs[name] = {}

	LDRP_SH.AllNPCs[name].mdl = mdl
	LDRP_SH.ModelToName[string.lower(mdl)] = name
	LDRP_SH.AllNPCs[name].descrpt = descrpt
	LDRP_SH.AllNPCs[name].buttons = button
	LDRP_SH.AllNPCs[name].NeedTeam = Team

	local usermsg = string.Replace(name, " ", "")

	LDRP_SH.AllNPCs[name].uname = usermsg
	
	if CLIENT then

		local function NPCUMSG(um)

			local z = um:ReadFloat()

			if z == (nil or 0) then

				LDRP_SH.OpenNPCWindow(name,mdl,descrpt,buttons)

			else	

				LDRP_SH.OpenNPCWindow(name,mdl,("I only talk to " .. team.GetName(z) .. "s."),{[LeaveMessages[math.random(1,#LeaveMessages)]] = function() end})
			
			end
		
		end
		
		usermessage.Hook(usermsg,NPCUMSG)
	
	end

end

LDRP.AddNPC("Paycheck Lady","models/humans/group01/female_01.mdl",nil,"Hello, I hand out paychecks to people.",
{
	["Can I pick my paycheck up?"] = function() RunConsoleCommand("_pcg") end,
	["I have to go, sorry."] = function() end
})

LDRP_SH.WeedBagWorth = 60
LDRP_SH.SeedWorth = 100
LDRP_SH.SporeWorth = 40
LDRP_SH.ShroomWorth = 20

LDRP.AddNPC("Drug Dealer","models/gman.mdl",{TEAM_DRUGDEALER},"Yo man, need some drugs?",
{
	["I need weed seeds. (NEEDS LVL 2 GROWING)"] = {
		["Can I get 1 seed bag. ($" .. LDRP_SH.SeedWorth .. ")"] = function() RunConsoleCommand("_dd","buy","weed") end,
		["Can I get 5 seed bags. ($" .. LDRP_SH.SeedWorth*5 .. ")"] = function() RunConsoleCommand("_dd","buy","weed","5") end
	},
	["I'd like to sell my weed. ($" .. LDRP_SH.WeedBagWorth .. " per bag)"] = function() RunConsoleCommand("_dd","sell","weed") end,
	["I need mushroom spores. (NEEDS LVL 3 GROWING]"] = {
		["Can I get 1 spore. ($" .. LDRP_SH.SporeWorth .. ")"] = function() RunConsoleCommand("_dd","buy","shrooms") end,
		["Can I get 5 spores. ($" .. LDRP_SH.SporeWorth*5 .. ")"] = function() RunConsoleCommand("_dd","buy","shrooms","5") end
	},
	["I'd like to sell my shrooms. ($" .. LDRP_SH.ShroomWorth .. " per bag)"] = function() RunConsoleCommand("_dd","sell","shrooms") end
})

LDRP.AddNPC("Bail NPC","models/police.mdl",nil,"Hello. I can bail you out of jail for $500",
{
	["Fuck yeah man!"] = function() RunConsoleCommand("_bmo") end,
	["No thanks, I like jail"] = function() LocalPlayer():ChatPrint("Fuck that dipshit. What a shitty cop") end
})

LDRP_SH.CarrotBuyPrice = 28

LDRP_SH.CarrotSeedPrice = 50

function LDRP.AddCustomNPC(name, mdl, usermsg)

	LDRP_SH.AllNPCs[name] = {}

	LDRP_SH.AllNPCs[name].mdl = mdl
	LDRP_SH.ModelToName[mdl] = name
	LDRP_SH.AllNPCs[name].uname = usermsg

end

LDRP.AddCustomNPC("Banker","models/humans/group01/male_05.mdl","SendBankMenu")

LDRP_SH.AllStores = {}

LDRP_SH.AllStores.Sells = {}

LDRP_SH.AllStores.Buys = {}

function LDRP.CreateStore(name, model, Saying, Sells, Buys)
	
	for b,v in pairs(Sells) do

		local k = string.lower(b)

		LDRP_SH.AllStores.Sells[k] = {}

		LDRP_SH.AllStores.Sells[k].Cost = v

		LDRP_SH.AllStores.Sells[k].NPC = name

	end

	for b,v in pairs(Buys) do

		local k = string.lower(b)

		LDRP_SH.AllStores.Buys[k] = {}

		LDRP_SH.AllStores.Buys[k].Cost = v

		LDRP_SH.AllStores.Buys[k].NPC = name

	end

	LDRP_SH.AllNPCs[name] = {}

	LDRP_SH.AllNPCs[name].mdl = model
	
	LDRP_SH.ModelToName[string.lower(model)] = name
	
	local usermsg = string.Replace(name, " ", "")

	LDRP_SH.AllNPCs[name].uname = usermsg
	
	if CLIENT then

		local function NPCUMSG(um)

			LDRP_SH.OpenStoreMenu(name,model,Saying,Sells,Buys)

		end

		usermessage.Hook(usermsg,NPCUMSG)

	end

end

LDRP.CreateStore("General Store","models/humans/group01/male_09.mdl","Welcome to the General Store!",{["Carrot Seed"] = LDRP_SH.CarrotSeedPrice,["Melon Seed"] = 75,["Pistol Ammo"] = 100,["Rifle Ammo"] = 140,["Shotgun Ammo"] = 140},{["Carrot"] = LDRP_SH.CarrotBuyPrice,["Melon"] = 50})
LDRP.CreateStore("Miner","models/Humans/Group02/male_02.mdl","I'm too lazy to mine rocks. Do it for me.",{["Pickaxe"] = 120,["hammer"] = 200},{["Stone"] = 500,["Gold"] = 700,["Ruby"] = 900, ["Diamond"] = 1100})

LDRP_SH.CraftItems = {}

function LDRP.CreateCraftItem( Name, Icon, CraftTime, LevelNeeded, ExpGive, Recipe, Results, VIPOnly)

	LDRP_SH.CraftItems[Name] = {}

	LDRP_SH.CraftItems[Name].recipe = Recipe
	LDRP_SH.CraftItems[Name].results = Results
	LDRP_SH.CraftItems[Name].lvl = LevelNeeded
	LDRP_SH.CraftItems[Name].crafttime = CraftTime
	LDRP_SH.CraftItems[Name].exp = ExpGive
	LDRP_SH.CraftItems[Name].icon = Icon
	LDRP_SH.CraftItems[Name].vip = VIPOnly

end

LDRP.CreateCraftItem("Pickaxe Upgrade #1","models/weapons/w_stone_pickaxe.mdl",8,1,100,{["gold"] = 5,["stone"] = 5,["pickaxe"] = 1},{["pickaxe1"] = 1})
LDRP.CreateCraftItem("Pickaxe Diamond","models/weapons/w_stone_pickaxe.mdl",8,1,100,{["diamond"] = 20, ["pickaxe1"] = 2},{["pickaxediamond"] = 1})
LDRP.CreateCraftItem("Pickaxe Upgrade VIP","models/weapons/w_stone_pickaxe.mdl",12,1,130,{["ruby"] = 4,["stone"] = 4,["pickaxe1"] = 1},{["pickaxevip"] = 1},true)

-- Outfits

function LDRP.CreateOutfit(name, description, model, weight, clr, mat, realent, usefunc)

  LDRP.AddNewItem(
    name, 
    description,
    model, 
    weight, 
    clr, 
    mat, 
    realent, 
    usefunc || function(ply) 

      ply:SetModel( model )
      ply:SetHealth(400)

    end, "Wear/takeoff outfit", nil)

end

LDRP.CreateOutfit("drug man", "drug man outfit", "models/bloocobalt/splinter cell/chemsuit_cod.mdl", 2, nil, nil, nil)


-- Moderator controls

LDRP_SH.AdminControls = {}

function AddAdminControl(name, description, func,sv)

	LDRP_SH.AdminControls[name] = {}

	LDRP_SH.AdminControls[name].descrpt = description

	if sv then

		local function AdminFunc(ply,cmd,args)

			if !ply:IsUserGroup("Moderator") and !ply:IsAdmin() then return end

			func(ply,cmd,args)

		end

		local name = "_" .. string.Replace(string.lower(name)," ","")

		concommand.Add(name,AdminFunc)

		LDRP_SH.AdminControls[name].sv = name

	else

		LDRP_SH.AdminControls[name].func = func

	end

end

AddAdminControl("Cleanup Disconnected Players' Props","Cleans up the props of people who are disconnected",function() RunConsoleCommand("fpp_cleanup","disconnected") end) 

LDRP.AllVIPs = {}

if SERVER then

	--require("von") --Updating all references from GLon to vON (could be messy)
	LDRP.AllVIPs = (file.Exists("ldrp_vips.txt", "DATA") and von.deserialize(file.Read("ldrp_vips.txt", "DATA"))) or {}
	
	concommand.Add("ldrp_addvip",function(ply,cmd,args)

		if !ply:IsAdmin() then return end

		if !args[1] then ply:ChatPrint("Command format: ldrp_addvip 'name'") return end
		
		local Target = {}

		for k,v in pairs(player.GetAll()) do if string.find(string.lower(v:GetName()),string.lower(args[1])) then table.insert(Target,v) end end

		if table.Count(Target) > 1 then

			ply:ChatPrint("More than 1 target found! Be more specific on the name.")

		else

			if !Target[1]:IsValid() then ply:ChatPrint("Player isn't valid.") return end

			table.insert(LDRP.AllVIPs,Target[1]:SteamID())

			file.Write("ldrp_vips.txt", von.serialize(LDRP.AllVIPs))

			if Target[1] == ply then

				ply:ChatPrint("You have added yourself to the VIP list.")

			else

				ply:ChatPrint(Target[1]:Name() .. " has been added to the VIP list.")

				Target[1]:ChatPrint("You have been given VIP! Congrats.")

			end
			
			if LDRP_SH.NotifyNewVIPs then

				for k,v in pairs(player.GetAll()) do

					if v:IsValid() and v != ply and v != Target[1] then v:ChatPrint(Target[1]:Name() .. " is a new VIP! Congratulate them.") end

				end

			end

		end

	end)

end

local meta=FindMetaTable("Player")

function meta:IsVIP() -- VIP system is small only for release. Edit as you desire

	return (table.HasValue(LDRP.AllVIPs,self:SteamID())) or self:IsAdmin()
	
end