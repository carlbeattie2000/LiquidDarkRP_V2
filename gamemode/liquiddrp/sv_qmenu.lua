if LDRP_SH.DisableQMenu then return end
local LDRP = {}

function LDRP.SpawnedProp(ply,mdl,ent)
	local Allowed
	for k,v in pairs(LDRP_SH.Props) do
		if table.HasValue(v,mdl) then Allowed = true break end
	end
	if !Allowed then return false end
end
hook.Add("PlayerSpawnProp","Blocks unused props",LDRP.SpawnedProp)

local CacheTools,CacheVIPTools = {},{}
for k,v in ipairs(LDRP_SH.Tools) do CacheTools[k] = string.lower(v) end
for k,v in ipairs(LDRP_SH.VIPTools) do CacheVIPTools[k] = string.lower(v) end


LDRP.ButtonMDLs = {"models/dav0r/buttons/button.mdl","models/dav0r/buttons/switch.mdl","models/props_c17/clock01.mdl","models/props_junk/garbage_coffeemug001a.mdl","models/props_junk/garbage_newspaper001a.mdl","models/props_lab/huladoll.mdl","models/props_c17/playgroundTick-tack-toe_block01a.mdl","models/props_c17/computer01_keyboard.mdl","models/props_c17/cashregister01a.mdl","models/props_lab/powerbox02d.mdl","models/props_lab/reciever01d.mdl"}

local function CheckBasedOnWildCard( tbl, toolmode )
	local found = false
	for _, v in pairs( tbl ) do
		local asterisk = string.find( v, "*", 1, true )
		if asterisk and string.find( toolmode, string.sub( v, 1, asterisk - 1 ) ) then
			return true
		end
	end
	
	return false
end

function LDRP.CanUseTool(ply,tr,toolmode)
	--[[
	local mdl = ply:GetActiveWeapon():GetToolObject():GetClientInfo("model")
	local CanUse = (table.HasValue(CacheTools,toolmode) or (ply:IsVIP() and table.HasValue(CacheVIPTools, toolmode))
	if CanUse and mdl then
		if table.HasValue(LDRP_SH.ExtraPropFilter,mdl) then return false end
		
		local Allowed
		for k,v in pairs(LDRP_SH.Props) do
			if table.HasValue(v,mdl) then Allowed = true break end
		end
		if !Allowed then return false end
	end
	]]--
	local VIP = table.HasValue(CacheVIPTools, toolmode)
	local Regular = table.HasValue(CacheTools,toolmode)
	if VIP and !ply:IsVIP() then Notify(ply, 1, 3, "This tool is VIP-only!") return false end
	if not ( VIP or Regular ) then
		--Make sure there isn't a wildcard in here
		if CheckBasedOnWildCard( CacheTools, toolmode ) then return true end
		Notify( ply, 1, 3, "This tool is not enabled on the server!" ) end
	return VIP or Regular or false
end
hook.Add("CanTool","Disable unused tools",LDRP.CanUseTool)