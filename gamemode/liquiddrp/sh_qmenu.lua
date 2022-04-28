if LDRP_SH.DisableQMenu then return end

local LDRP = {}

LDRP_SH.Props = {}
LDRP_SH.Props["Construction"] = {}
LDRP_SH.Props["Random"] = {}
LDRP_SH.Props["Roleplay"] = {}
for k,v in pairs(file.Find("models/props_phx/construct/*.mdl", "MOD")) do
	table.insert(LDRP_SH.Props["Construction"],"models/props_phx/construct/" .. v)
end

function LDRP.AddPropList(name,section)
	for k,v in pairs(util.KeyValuesToTable(file.Read("settings/spawnlist_default/"..name..".txt", "MOD")).contents) do
		table.insert(LDRP_SH.Props[section],v.model)
	end
end
LDRP.AddPropList("002-comic props","Roleplay")
LDRP.AddPropList("001-construction props","Random")
local SavedFavs = file.Exists("ldrp_favprops.txt", "DATA")

LDRP_SH.Props["Favorites"] = (SavedFavs and von.deserialize(file.Read("ldrp_favprops.txt", "DATA"))) or {}

function LDRP_SH.SaveFavs()
	file.Write("ldrp_favprops.txt",von.serialize(LDRP_SH.Props["Favorites"]))
end

LDRP_SH.Tools = {
	"adv_duplicator",
	"Axis",
	"Ballsocket",
	"Button",
	"colmat",
	"Door",
	"Elastic",
	"Eyeposer",
	"Faceposer",
	"Finger",
	"Hydraulic",
	"Keypad",
	"Light",
	"Motor",
	"Muscle",
	"Nocollide",
	"Pulley",
	"Rope",
	"Slider",
	"Thruster",
	"Remover",
	"Weld",
	"weld_ez2",
	"Wheel",
	"Winch",
	"wire*",
	"rtcamera",
	"shareprops",
	"fadingdoor",
	--SCars
	"carfuel",
	"carhealth",
	"carhydraulic",
	"carneonlights",
	"carsound",
	"carspawner",
	"carsuspension",
	"cartuning",
	"paintjobswitcher",
	"wheelchanger"}
LDRP_SH.VIPTools = {
	"Balloon",
	"Camera",
	"Colour",
	"Duplicator",
	"Emitter",
	"Hoverball",
	"Inflator",
	"Keypad_adv",
	"Lamp",
	"Leafblower",
	"Material",
	"Paint",
	"Trails"
}

LDRP_SH.MaxSigns = 2

LDRP_SH.ExtraPropFilter = {}