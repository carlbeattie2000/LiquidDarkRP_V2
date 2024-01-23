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
