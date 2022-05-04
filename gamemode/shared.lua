
/*--------------------------------------------------------
Default teams. If you make a team above the citizen team, people will spawn with that team!
--------------------------------------------------------*/
TEAM_CITIZEN = AddExtraTeam("Citizen", {
	color = Color(20, 150, 20, 255),
	model = {
		"models/player/Group01/Female_01.mdl",
		"models/player/Group01/Female_02.mdl",
		"models/player/Group01/Female_03.mdl",
		"models/player/Group01/Female_04.mdl",
		"models/player/Group01/female_05.mdl",
		"models/player/Group01/Female_06.mdl",
		"models/player/group01/male_01.mdl",
		"models/player/Group01/Male_02.mdl",
		"models/player/Group01/male_03.mdl",
		"models/player/Group01/Male_04.mdl",
		"models/player/Group01/Male_05.mdl",
		"models/player/Group01/Male_06.mdl",
		"models/player/Group01/Male_07.mdl",
		"models/player/Group01/Male_08.mdl",
		"models/player/Group01/Male_09.mdl"
	},
	description = [[The Citizen is the most basic level of society you can hold
		besides being a hobo. 
		You have no specific role in city life.]],
	weapons = {},
	command = "citizen",
	max = 0,
	salary = 150,
  category = "Citizen",
	admin = 0,
	vote = false,
	hasLicense = false,
	candemote = false
})

TEAM_POLICE = AddExtraTeam("Civil Protection", {
	color = Color(25, 25, 170, 255),
	model = "models/player/police.mdl",
	description = [[The protector of every citizen that lives in the city. 
		You have the power to arrest criminals and protect innocents. 
		Hit them with your arrest baton to put them in jail
		Bash them with a stunstick and they might learn better than to disobey 
		the law.
		The Battering Ram can break down the door of a criminal with a warrant 
		for his/her arrest.
		The Battering Ram can also unfreeze frozen props(if enabled).
		Type /wanted <name> to alert the public to this criminal
		OR go to tab and warrant someone by clicking the warrant button]],
	weapons = {
		"arrest_stick",
		"unarrest_stick",
		"weapon_real_cs_glock18",
		"stunstick",
		"door_ram",
		"weaponchecker"
	},
	command = "cp",
	max = 4,
	salary = 230,
  category = "Law & Order",
	admin = 0,
	vote = true,
	hasLicense = true,
})

TEAM_GANG = AddExtraTeam("Gang Member", {
	color = Color(75, 75, 75, 255),
	model = {
		"models/player/group03/female_01.mdl",
		"models/player/group03/female_02.mdl",
		"models/player/group03/female_03.mdl",
		"models/player/group03/female_04.mdl",
		"models/player/group03/female_05.mdl",
		"models/player/group03/female_06.mdl",
		"models/player/group03/male_01.mdl",
		"models/player/group03/male_03.mdl",
		"models/player/group03/male_05.mdl",
		"models/player/group03/male_06.mdl",
		"models/player/group03/male_07.mdl",
		"models/player/group03/male_08.mdl",
		"models/player/group03/male_09.mdl"
	},
	description = [[The lowest person of crime. 
		A gang member generally works for the gang leader who runs the crime family. 
		The Mobboss sets your agenda and you follow it or you might be punished.]],
	weapons = {},
	command = "gangster",
	max = 3,
	salary = 130,
  category = "Criminal",
	admin = 0,
	vote = false,
	hasLicense = false
})

TEAM_MOB = AddExtraTeam("Gang Leader", {
	color = Color(25, 25, 25, 255),
	model = "models/player/gman_high.mdl",
	description = [[The gang leader is the boss of the criminals in the city. 
		With his power he coordinates the gangsters and forms an efficent crime
		organization. 
		He has the ability to break into houses by using a lockpick (and keypads)
		The Mobboss also can unarrest you.]],
	weapons = {
		"lockpick",
		"cracker",
		"unarrest_stick"
	},
	command = "mobboss",
	max = 1,
	salary = 170,
  category = "Criminal",
	admin = 0,
	vote = false,
	hasLicense = false,
})

TEAM_GUN = AddExtraTeam("Gun Dealer", {
	color = Color(255, 140, 0, 255),
	model = "models/player/monk.mdl",
	description = [[A gun dealer is the only person who can sell guns to other 
		people. 
		However, make sure you aren't caught selling guns that are illegal to 
		the public.
		/Buyshipment <name> to Buy a  weapon shipment
		/Buygunlab to Buy a gunlab that spawns P228 pistols]],
	weapons = {},
	command = "gundealer",
	max = 2,
	salary = 160,
  category = "Shop Keepers",
	admin = 0,
	vote = false,
	hasLicense = false
})

TEAM_MEDIC = AddExtraTeam("Doctor", {
	color = Color(47, 79, 79, 255),
	model = "models/player/kleiner.mdl",
	description = [[With your medical knowledge, you heal players to proper 
		health. 
		Without a doctor, people can not be healed. 
		Left click with the Medical Kit to heal other players.
		Right click with the Medical Kit to heal yourself.]],
	weapons = {"med_kit"},
	command = "medic",
	max = 3,
	salary = 190,
  category = "Shop Keepers",
	admin = 0,
	vote = false,
	hasLicense = false
})

TEAM_CHIEF = AddExtraTeam("Civil Protection Chief", {
	color = Color(20, 20, 255, 255),
	model = "models/player/combine_soldier_prisonguard.mdl",
	description = [[The Chief is the leader of the Civil Protection unit. 
		Coordinate the police forces to bring law to the city
		Hit them with arrest baton to put them in jail
		Bash them with a stunstick and they might learn better than to 
		disobey the law.
		The Battering Ram can break down the door of a criminal with a 
		warrant for his/her arrest.
		Type /wanted <name> to alert the public to this criminal
		Type /jailpos to set the Jail Position]],
	weapons = {
		"arrest_stick",
		"unarrest_stick",
		"weapon_real_cs_desert_eagle",
		"stunstick",
		"door_ram",
		"weaponchecker"
	},
	command = "chief",
	max = 1,
	salary = 250,
  category = "Law & Order",
	admin = 0,
	vote = true,
	hasLicense = true,
	NeedToChangeFrom = TEAM_POLICE,
})

TEAM_POLICE = AddExtraTeam("S.W.A.T", {
	color = Color(20, 20, 255, 255),
	model = "models/player/swat.mdl",
	description = [[You are a member of the elite group swat. You must protect your city and it's citzens no matter the cost.
					Coordinate with the Chief of police, and the swat leader to bring law and order to the city. You are tasked
					with taking down some of the cities most dangerous criminals. Good luck!]],
	weapons = {
		"arrest_stick",
		"unarrest_stick",
		"weapon_real_cs_mp5a5",
		"weapon_real_cs_usp",
		"door_ram",
		"weaponchecker"
	},
	command = "swat",
	max = 5,
	salary = 200,
  category = "Law & Order",
	admin = 0,
	vote = true,
	hasLicense = true,
})

TEAM_POLICE = AddExtraTeam("S.W.A.T Sniper", {
	color = Color(20, 20, 255, 255),
	model = "models/player/gasmask.mdl",
	description = [[You are a member of the elite group swat, and speicalise in sniping. You must protect your city and it's citzens no matter the cost.
					Coordinate with the Chief of police, and the swat leader to bring law and order to the city. You are tasked
					with taking down some of the cities most dangerous criminals. Good luck!]],
	weapons = {
		"arrest_stick",
		"unarrest_stick",
		"weapon_real_cs_sg550",
		"weapon_real_cs_usp",
		"door_ram",
		"weaponchecker"
	},
	command = "swatsniper",
	max = 2,
	salary = 230,
  category = "Law & Order",
	admin = 0,
	vote = true,
	hasLicense = true,
})

TEAM_POLICE = AddExtraTeam("S.W.A.T Leader", {
	color = Color(20, 20, 255, 255),
	model = {
		"models/player/urban.mdl", 
		"models/player/riot.mdl"
	},
	description = [[You are a member of the elite group swat. You must protect your city and it's citzens no matter the cost.
					Coordinate with the Chief of police an your S.W.A.T Officers to bring law and order to the city. You are tasked
					with taking down some of the cities most dangerous criminals. Good luck!]],
	weapons = {
		"arrest_stick",
		"unarrest_stick",
		"weapon_real_cs_m4a1",
		"weapon_real_cs_usp",
		"door_ram",
		"weaponchecker"
	},
	command = "swatleader",
	max = 1,
	salary = 240,
  category = "Law & Order",
	admin = 0,
	vote = true,
	hasLicense = true,
	NeedToChangeFrom = TEAM_POLICE,
})

TEAM_MAYOR = AddExtraTeam("Mayor", {
	color = Color(150, 20, 20, 255),
	model = "models/player/breen.mdl",
	description = [[The Mayor of the city creates laws to serve the greater good 
		of the people.
		If you are the mayor you may create and accept warrants.
		Type /wanted <name>  to warrant a player
		Type /jailpos to set the Jail Position
		Type /lockdown initiate a lockdown of the city. 
		Everyone must be inside during a lockdown. 
		The cops patrol the area
		/unlockdown to end a lockdown]],
	weapons = {},
	command = "mayor",
	max = 1,
	salary = 220,
  category = "Law & Order",
	admin = 0,
	vote = true,
	hasLicense = false,
})

TEAM_HOBO = AddExtraTeam("Hobo", {
	color = Color(80, 45, 0, 255),
	model = "models/player/corpse1.mdl",
	description = [[The lowest member of society. All people who see you laugh.
		You have no home.
		Beg for your food and money
		Sing for everyone who passes to get money
		Make your own wooden home somewhere in a corner or 
		outside someone else's door]],
	weapons = {"weapon_bugbait"},
	command = "hobo",
	max = 5,
	salary = 0,
  category = "Citizen",
	admin = 0,
	vote = false,
	hasLicense = false
})

--[[ LIQUID DARKRP JOBS ]]--

TEAM_DRUGDEALER = AddExtraTeam("Drug Dealer", {
	color = Color(120, 120, 120, 255),
	model = "models/player/Group01/Male_08.mdl",
	description = [[The drug dealer can buy weed seeds from
		the main dealer in the map and grow marijuana for
		him and sell it back to him for cash.]],
	weapons = {},
	command = "drugdealer",
	max = 5,
	salary = 70,
  category = "Criminal",
	admin = 0,
	vote = false,
	hasLicense = false
})

TEAM_THIEF = AddExtraTeam("Thief", {
	color = Color(70, 70, 70, 255),
	model = "models/player/Group03/Male_02.mdl",
	description = [[Lockpick doors, hack keypads, and steal other player's
		items for profit.
		Keep in mind that the cops don't like this!]],
	weapons = {
		"lockpick",
		"cracker"
	},
	command = "thief",
	max = 4,
	salary = 90,
  category = "Criminal",
	admin = 0,
	vote = false,
	hasLicense = false
})

TEAM_MINER = AddExtraTeam("Miner", {
	color = Color(120, 120, 120, 255),
	model = "models/player/Group03/Male_04.mdl",
	description = [[The miner can gain skills in the mining area, allowing
		them to mine more valuable rocks. The rocks can be sold or used
		for crafting.
		To get a pickaxe, go to the Miner NPC.]],
	weapons = {},
	command = "miner",
	max = 5,
	salary = 80,
  category = "Citizen",
	admin = 0,
	vote = false,
	hasLicense = false
})

TEAM_CRAFTER = AddExtraTeam("Crafter", {
	color = Color(235, 105, 105, 255),
	model = "models/player/Group03/Male_06.mdl",
	description = [[The crafter can create items from various resources
		by purchasing a hammer from the miner and then hitting the
		crafting table.
		Crafted items can then be sold or used.]],
	weapons = {},
	command = "crafter",
	max = 2,
	salary = 90,
  category = "Citizen",
	admin = 0,
	vote = false,
	hasLicense = false
})

TEAM_HEAVYWEP = AddExtraTeam("Heavy Weapons Guy", {
	color = Color(60,60,60),
	model = "models/player/arctic.mdl",
	description = [[You sell heavier weapons that the gundealer does not have
		that can do lots of damage and maybe even cause explosions.]],
	weapons = {},
	command = "heavydealer",
	max = 2,
	salary = 110,
  category = "Shop Keepers",
	admin = 0,
	vote = false,
	hasLicense = false
})

-- Assassin/hitman class is found in dlc/sh_hitman_loadafterdarkrp.lua

--------------------------------------------

/*
--------------------------------------------------------
HOW TO MAKE A DOOR GROUP
--------------------------------------------------------
AddDoorGroup("NAME OF THE GROUP HERE, you see this when looking at a door", Team1, Team2, team3, team4, etc.)

WARNING: THE DOOR GROUPS HAVE TO BE UNDER THE TEAMS IN SHARED.LUA. IF THEY ARE NOT, IT MIGHT MUCK UP!


The default door groups, can also be used as examples:
*/
AddDoorGroup("cops and mayor only", TEAM_CHIEF, TEAM_POLICE, TEAM_MAYOR)
AddDoorGroup("gundealer only", TEAM_GUN)


/*
--------------------------------------------------------
HOW TO MAKE An agenda
--------------------------------------------------------
AddAgenda(Title of the agenda, Manager (who edits it), Listeners (the ones who just see and follow the agenda))

WARNING: THE AGENDAS HAVE TO BE UNDER THE TEAMS IN SHARED.LUA. IF THEY ARE NOT, IT MIGHT MUCK UP!

The default agenda's, can also be used as examples:
*/
AddAgenda("Gangster's agenda", TEAM_MOB, {TEAM_GANG})
AddAgenda("Police agenda", TEAM_MAYOR, {TEAM_CHIEF, TEAM_POLICE})

/*
---------------------------------------------------------------------------
HOW TO MAKE A GROUP CHAT
---------------------------------------------------------------------------
Pick one!
GAMEMODE:AddGroupChat(List of team variables separated by comma)

or

GAMEMODE:AddGroupChat(a function with ply as argument that returns whether a random player is in one chat group)
This one is for people who know how to script Lua.

*/
GM:AddGroupChat(function(ply) return ply:IsCP() end)
GM:AddGroupChat(TEAM_MOB, TEAM_GANG)

/*---------------------------------------------------------------------------
Define which teams belong to civil protection
Civil protection can set warrants, make people wanted and do some other police related things
---------------------------------------------------------------------------*/
GM.CivilProtection = {
	[TEAM_POLICE] = true,
	[TEAM_CHIEF] = true,
	[TEAM_MAYOR] = true,
}

-- Don't edit below unless you don't want DLCs or know what you are doing.
-- DLCs automatically load from the dlc/ folder. Ones begining with "sv_" load serverside, beginning with "cl_" load clientside, and "sh_" runs shared.
------------------------------------- LIQUID DARKRP DLCS -------------------------------------
if SERVER then
	LDRP_DLC = {}
	LDRP_DLC.Find = file.Find(GM.FolderName .. "/gamemode/dlc/*.lua", "LUA")
	LDRP_DLC.CL = {}
	LDRP_DLC.SV = {}

	for k,v in pairs(LDRP_DLC.Find) do
		local Ext = string.sub(v,1,3)
		local LoadAfter = (string.find(string.lower(v,"_loadafterdarkrp"),"_loadafterdarkrp") and "after") or "before"
		if Ext == "sh_" then
			LDRP_DLC.CL["dlc/" .. v] = LoadAfter
			LDRP_DLC.SV["dlc/" .. v] = LoadAfter
		elseif Ext == "cl_" then
			LDRP_DLC.CL["dlc/" .. v] = LoadAfter
		elseif Ext == "sv_" then
			LDRP_DLC.SV["dlc/" .. v] = LoadAfter
		else
			MsgN("One of your DLCs is using an invalid format! -----------------------------------------")
			MsgN("DLCs must start with either cl_ sv_ or sh_")
		end
	end

	for k,v in pairs(LDRP_DLC.SV) do
		if v == "after" then continue end
		include(k)
	end
	
	for k,v in pairs(LDRP_DLC.CL) do
		AddCSLuaFile(k)
	end
end

------------------------------------- LIQUID DARKRP DLCS END -------------------------------------
