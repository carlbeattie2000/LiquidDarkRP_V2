--[[ 	sv_persistprops.lua
		Liquid DarkRP functionality that saves props and their locations so
		that they can be loaded when the server loads up a particular map
		again.
]]

local LDRP = {}

LDRP.SavedProps = {}
LDRP.SavedRemove = {}

if file.Exists("liquiddrp/savedprops.txt", "DATA") then
	LDRP.SavedProps = von.deserialize(file.Read("liquiddrp/savedprops.txt", "DATA"))
	LDRP.SavedRemove = von.deserialize(file.Read("liquiddrp/savedremove.txt", "DATA"))
end
LDRP.SavedInMap = {}

function LDRP.SaveProps()
	file.Write("liquiddrp/savedprops.txt", von.serialize(LDRP.SavedProps))
	file.Write("liquiddrp/savedremove.txt", von.serialize(LDRP.SavedRemove))
	GAMEMODE:WriteOut( "Persistent prop information has been saved!", Severity.Info )
end

function LDRP.CreateSaveProp(model,position,angle,color,material,class)
	local Prop
	if class then
		Prop = ents.Create(class)
	else
		Prop = ents.Create("prop_untouchable")
		Prop:SetModel(model)
	end
	
	Prop:SetPos(position)
	Prop:SetAngles(angle)
	Prop:SetColor(color)
	Prop:SetMaterial(material)
	Prop:Spawn()
	
	local Phys = Prop:GetPhysicsObject()
	Phys:Wake()
	Phys:EnableMotion(false)
	
	return Prop
end

function LDRP.MapSetupCMD(ply,cmd,args)
	if !ply:IsSuperAdmin() then return end
	
	local ent = ply:GetEyeTrace().Entity
	if !ent or !ent:IsValid() or ent:GetClass() == "shop_base" or ent:IsWorld() or ent:IsPlayer() then return end
	
	if args[1] == "addprop" then
		if LDRP.SavedInMap[ent] then
			LDRP.SavedProps[LDRP.SavedInMap[ent]] = nil
			LDRP.SavedInMap[ent] = nil
			ent:Remove()
			ply:PrintMessage( HUD_PRINTCONSOLE, "Removed saved prop." )
		else
			local N = table.Count(LDRP.SavedProps)+1
			LDRP.SavedProps[N] = {}
			if ent:GetClass() != "prop_physics" then
				LDRP.SavedProps[N].class = ent:GetClass()
			end
			LDRP.SavedProps[N].mat = ent:GetMaterial()
			LDRP.SavedProps[N].pos = ent:GetPos()
			LDRP.SavedProps[N].angs = ent:GetAngles()
			LDRP.SavedProps[N].mdl = ent:GetModel()
			local v = LDRP.SavedProps[N]
			local Prop = LDRP.CreateSaveProp(v.mdl,v.pos,v.angs,Color(255,255,255,255),v.mat)
			LDRP.SavedInMap[Prop] = N
			ent:Remove()
			ply:PrintMessage( HUD_PRINTCONSOLE, "Saved prop." )
		end
		LDRP.SaveProps()
	elseif args[1] == "addremove" then
		ply:ChatPrint("Saved auto remove entity.")
		table.insert(LDRP.SavedRemove,ent:GetPos())
		ent:Remove()
		LDRP.SaveProps()
	else
		ply:PrintMessage( HUD_PRINTCONSOLE,
			"Usage: ldrp_map _command_ \nModify the game world. Syntax:" )
		ply:PrintMessage( HUD_PRINTCONSOLE,
			"ldrp_map addprop \n\tAdds or removes the current prop you are"..
				" looking at so that it will be loaded if the server is"..
				" restarted.")
		ply:PrintMessage( HUD_PRINTCONSOLE,
			"ldrp_map addremove \n\tAdds the current prop you are looking"..
				" at to the remove list so it is removed from the map"..
				" whenever the map is loaded.")
	end
end
concommand.Add("ldrp_map", LDRP.MapSetupCMD)

hook.Add( "InitPostEntity", "LDRP.ProcessSavedProps", function()
	timer.Simple(1.5, function()
		for k,v in pairs(ents.GetAll()) do
			if v:IsValid() and !v:IsWorld() and table.HasValue(LDRP.SavedRemove,v:GetPos()) then
				v:Remove()
			end
		end
		
		for k,v in pairs(LDRP.SavedProps) do
			local Prop = LDRP.CreateSaveProp(v.mdl,v.pos,v.angs,Color(255,255,255,255),v.mat,v.class)
			LDRP.SavedInMap[Prop] = k
		end
	end)
end )