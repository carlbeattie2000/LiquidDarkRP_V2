
local LDRP,STL = {},string.lower

LDRP_Protector = {}
LDRP_Protector.NoPhysgun = (file.Exists("protector/nophys.txt", "DATA") and von.deserialize(file.Read("protector/nophys.txt", "DATA"))) or {"func_door","func_door_rotating","money_printer","player","shop_base","crafting_table","plants","pot","prop_untouchable","rock_base","cooler","func_breakable","func_breakable_surf","prop_door_rotating"}
LDRP_Protector.AllPhysgun = (file.Exists("protector/allphys.txt", "DATA") and von.deserialize(file.Read("protector/allphys.txt", "DATA"))) or {}
LDRP_Protector.UseProtect = (file.Exists("protector/useprotect.txt", "DATA") and (file.Read("protector/useprotect.txt", "DATA") == "true")) or false
LDRP_Protector.DiscoTime = 120 -- How many seconds before their shit disapears

LDRP_Protector.Restrict = (file.Exists("protector/restricted.txt", "DATA") and von.deserialize(file.Read("protector/restricted.txt", "DATA"))) or {}
LDRP_Protector.Restrict.Models = LDRP_Protector.Restrict.Models or {}
LDRP_Protector.Restrict.Tools = LDRP_Protector.Restrict.Tools or {}

function LDRP.ProtectSaveInfo(ply)
	if !ply:IsValid() or !ply.Protect then return end
	file.Write("protector/info_" .. ply:UniqueID() .. ".txt", von.serialize(ply.Protect))
end

function LDRP.SetEntOwner(ply,ent)
	ent.Owner = ply
end

function LDRP.CanTouch(ply,ent)
	local Valid = (type(ent.Owner) == "Player" and ent.Owner:IsValid() and ent.Owner)
	if ent != nil and ent:IsValid() and table.HasValue(LDRP_Protector.NoPhysgun,STL(ent:GetClass())) then return false end
	
	return (!Valid) or (Valid and Valid == ply) or (Valid and Valid.Protect and Valid.Protect.Friends[ply:UniqueID()]) or (!ent.dt)
end

hook.Add("PlayerDisconnect","LDRP Prop protect",function(ply)
	LDRP.ProtectSaveInfo(ply)
	timer.Create("RemoveProps_" .. ply:UniqueID(), (LDRP_Protector.DiscoTime or 120), 1, function()
		for k,v in pairs(ents.GetAll()) do
			if v:IsValid() and v.Owner then
				v:Remove()
			end
		end
	end)
end)

hook.Add("PhysgunPickup","LDRP Prop protect",function(ply,ent)
	if ent and ent:IsValid() and table.HasValue(LDRP_Protector.AllPhysgun,ent:GetClass()) then return true end
	if ent and ent:IsValid() and table.HasValue(LDRP_Protector.NoPhysgun,ent:GetClass()) then return false end
	local CanTouch = LDRP.CanTouch(ply,ent)
	if !CanTouch then
		if !ply.LastNotify or CurTime()-ply.LastNotify > 3 then ply.LastNotify = CurTime() Notify(ply, 1, 5, "This is not your prop!") end
		return false
	end
end)

hook.Add("PhysgunDrop","LDRP Prop protect",function(ply,ent)
	if ent:IsValid() and ent:IsPlayer() then
		if ply:IsAdmin() or ply:IsSuperAdmin() then
			ent:Freeze(false)
			return true
		else
			return false
		end
	end
	
	if !LDRP.CanTouch(ply,ent) then
		if !ply.LastNotify or CurTime()-ply.LastNotify > 3 then ply.LastNotify = CurTime() Notify(ply, 1, 5, "This is not your prop!") end
		Notify(ply, 1, 5, "This is not your prop!")
		return false
	end
end)

hook.Add("CanTool","LDRP Prop protect",function(ply, tr, mode)
	local Ent = (tr and tr.Entity)
	if Ent and Ent:IsValid() and table.HasValue(LDRP_Protector.NoPhysgun,STL(Ent:GetClass())) then return false end
	
	if table.HasValue(LDRP_Protector.Restrict.Tools,STL(mode)) then Notify(ply, 1, 5, "This tool is restricted!") return false end
end)

hook.Add("PlayerUse","LDRP Prop protect",function(ply,ent)
	if (LDRP_Protector.UseProtect and ent:GetClass() != "shop_base" and !LDRP.CanTouch(ply,ent)) then return false end
end)

hook.Add("PlayerSpawnedProp","LDRP Prop protect",function(ply,mdl,ent)
	local EntMdl = ent:GetModel()
	if table.HasValue(LDRP_Protector.Restrict.Models,STL(EntMdl)) then ent:Remove() Notify(ply, 1, 5, "This model is restricted!") return false end
	LDRP.SetEntOwner(ply,ent)
end)

hook.Add("PlayerSpawnedEffect","LDRP Prop protect",function(ply,mdl,ent)
	local EntMdl = ent:GetModel()
	if table.HasValue(LDRP_Protector.Restrict.Models,STL(EntMdl)) then ent:Remove() Notify(ply, 1, 5, "This model is restricted!") return false end
	LDRP.SetEntOwner(ply,ent)
end)

hook.Add("PlayerSpawnedVehicle","LDRP Prop protect",function(ply,ent)
	local EntMdl = ent:GetModel()
	if table.HasValue(LDRP_Protector.Restrict.Models,STL(EntMdl)) then ent:Remove() Notify(ply, 1, 5, "This model is restricted!") return false end
	LDRP.SetEntOwner(ply,ent)
end)

hook.Add("PlayerSpawnedNPC","LDRP Prop protect",function(ply,ent)
	local EntMdl = ent:GetModel()
	if table.HasValue(LDRP_Protector.Restrict.Models,STL(EntMdl)) then ent:Remove() Notify(ply, 1, 5, "This model is restricted!") return false end
	LDRP.SetEntOwner(ply,ent)
end)

hook.Add("PlayerSpawnedSENT","LDRP Prop protect",function(ply,ent)
	local EntMdl = ent:GetModel()
	if table.HasValue(LDRP_Protector.Restrict.Models,STL(EntMdl)) then ent:Remove() Notify(ply, 1, 5, "This model is restricted!") return false end
	LDRP.SetEntOwner(ply,ent)
end)

hook.Add("PlayerSpawnedRagdoll","LDRP Prop protect",function(ply,mdl,ent)
	local EntMdl = ent:GetModel()
	if table.HasValue(LDRP_Protector.Restrict.Models,STL(EntMdl)) then ent:Remove() Notify(ply, 1, 5, "This model is restricted!") return false end
	LDRP.SetEntOwner(ply,ent)
end)

hook.Add("PlayerInitialSpawn","LDRP Prop protect",function(ply)
	local UID = ply:UniqueID()
	if timer.Exists("RemoveProps_" .. UID) then
		timer.Remove("RemoveProps_" .. UID)
	end
	
	if !file.Exists("protector/info_" .. UID .. ".txt", "DATA") then
		ply.Protect = {}
		ply.Protect.Friends = {}
		LDRP.ProtectSaveInfo(ply)
	else
		ply.Protect = von.deserialize(file.Read("protector/info_" .. UID .. ".txt", "DATA"))
	end
end)

concommand.Add("_protector",function(ply,cmd,args)
	local Type = args[1]
	
	if Type == "friend" then
		local Ply
		
		if ply.Protect.Friends[args[2]] then
			Notify(ply, 4, 4, "You have removed " .. ply.Protect.Friends[args[2]] .. " from your protection list.")
			ply.Protect.Friends[args[2]] = nil
		else
			for k,v in pairs(player.GetAll()) do if string.lower(v:UniqueID()) == string.lower(args[2]) then Ply = v end end
			if !Ply or !Ply:IsValid() then Notify(ply, 5, 5, "That is not a valid player.") return end
			
			Notify(ply, 4, 4, "You have added " .. Ply:Name() .. " to your protection list.")
			ply.Protect.Friends[args[2]] = Ply:GetName()
		end
		LDRP.ProtectSaveInfo(ply)
	elseif Type == "useprotect" then
		if !ply:IsAdmin() or ply:IsSuperAdmin() and !ply:IsSuperAdmin() then return end
		LDRP_Protector.UseProtect = !LDRP_Protector.UseProtect
		file.Write("protector/useprotect.txt",((LDRP_Protector.UseProtect and "true") or "false"))
		Notify(ply, 5, 5, "Use protection is now " .. ((LDRP_Protector.UseProtect and "on") or "off"))
	elseif Type == "nophys" then
		if !ply:IsAdmin() or ply:IsSuperAdmin() and !ply:IsSuperAdmin() then return end
		local Removal
		
		for k,v in pairs(LDRP_Protector.NoPhysgun) do
			if STL(v) == STL(args[2]) then
				Removal = v
				LDRP_Protector.NoPhysgun[k] = nil
			end
		end
		
		if !Removal then
			Notify(ply, 5, 5, "You have added '" .. args[2] .. "' to the no physgun list.")
			table.insert(LDRP_Protector.NoPhysgun,STL(args[2]))
		else
			Notify(ply, 5, 5, "You have removed '" .. Removal .. "' from the no physgun list.")
		end
		file.Write("protector/nophys.txt",glon.encode(LDRP_Protector.NoPhysgun))
	elseif Type == "allphys" then
		if !ply:IsAdmin() or ply:IsSuperAdmin() and !ply:IsSuperAdmin() then return end
		local Removal
		
		for k,v in pairs(LDRP_Protector.AllPhysgun) do
			if STL(v) == STL(args[2]) then
				Removal = v
				LDRP_Protector.AllPhysgun[k] = nil
			end
		end
		
		if !Removal then
			Notify(ply, 5, 5, "You have added '" .. args[2] .. "' to the all physgun list.")
			table.insert(LDRP_Protector.AllPhysgun,STL(args[2]))
		else
			Notify(ply, 5, 5, "You have removed '" .. Removal .. "' from the all physgun list.")
		end
		file.Write("protector/allphys.txt",glon.encode(LDRP_Protector.AllPhysgun))
	elseif Type == "model" then
		if !ply:IsAdmin() or ply:IsSuperAdmin() and !ply:IsSuperAdmin() then return end
		local Removal
		
		for k,v in pairs(LDRP_Protector.Restrict.Models) do
			if STL(v) == STL(args[2]) then
				Removal = v
				LDRP_Protector.Restrict.Models[k] = nil
			end
		end
		
		if !Removal then
			Notify(ply, 5, 5.5, "You have added '" .. args[2] .. "' to the prop blacklist.")
			
			table.insert(LDRP_Protector.Restrict.Models,STL(args[2]))
		else
			Notify(ply, 5, 5.5, "You have removed '" .. Removal .. "' from the prop blacklist.")
		end
		file.Write("protector/restricted.txt",glon.encode(LDRP_Protector.Restrict))
	elseif Type == "tool" then
		if !ply:IsAdmin() or ply:IsSuperAdmin() and !ply:IsSuperAdmin() then return end
		local Removal
		
		for k,v in pairs(LDRP_Protector.Restrict.Tools) do
			if STL(v) == STL(args[2]) then
				Removal = v
				LDRP_Protector.Restrict.Tools[k] = nil
			end
		end
		
		if !Removal then
			Notify(ply, 5, 5.5, "You have added '" .. args[2] .. "' to the tool restriction list.")
			
			table.insert(LDRP_Protector.Restrict.Tools,STL(args[2]))
		else
			Notify(ply, 5, 5.5, "You have removed '" .. Removal .. "' from the tool restriction list.")
		end
		file.Write("protector/restricted.txt",glon.encode(LDRP_Protector.Restrict))
	elseif Type == "getvar" then
		if !ply:IsAdmin() or ply:IsSuperAdmin() and !ply:IsSuperAdmin() then return end
		if args[2] == "useprotect" then
			umsg.Start("SendOptionValue",ply)
				umsg.String(args[2])
				umsg.Float((LDRP_Protector.UseProtect and 1) or 0)
			umsg.End()
		else
			umsg.Start("SendOptionValue",ply)
				umsg.String(args[2])
				local WhichTable = (args[2] == "tool" and LDRP_Protector.Restrict.Tools) or (args[2] == "model" and LDRP_Protector.Restrict.Models) or (args[2] == "nophys" and LDRP_Protector.NoPhysgun) or (args[2] == "allphys" and LDRP_Protector.AllPhysgun) or (args[2] == "tool" and LDRP_Protector.Restrict.Tools)
				umsg.Float(table.Count(WhichTable))
				for k,v in pairs(WhichTable) do
					umsg.String(k)
					umsg.String(v)
				end
			umsg.End()
		end
	end
end)

concommand.Add("protector_buddies",function(ply,cmd,args)
	for k,v in pairs(ply.Protect.Friends) do
		umsg.Start("SendPPBuddy",ply)
			umsg.String(k)
			umsg.String(v)
		umsg.End()
	end
	
	umsg.Start("SendBuddyMenu",ply)
	umsg.End()
end)