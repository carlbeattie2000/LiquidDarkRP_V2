local LDRP = {}

local tostring = tostring

function LDRP.UpgradePrinter(ply,fargs)
	local args = string.Explode(" ", fargs)
	local ent = ply:GetEyeTrace().Entity
	
	if ent and ent:IsValid() and ent:GetClass() == "money_printer" then
		local tb = LDRP_SH.Printers
		local order = LDRP_SH.PrOrder[ent:GetNWString("Upgrade")]
		
		if order >= LDRP_SH.last then
			ply:LiquidChat("GAME", Color(0,200,200), "This printer already has it's maximum upgrade!")
		else
			local nex = order+1
			local nexn = table.KeyFromValue(LDRP_SH.PrOrder, nex)
			if ply:CanAfford(tb[nexn].cost) then
				local b = tb[nexn]
				ply:AddMoney(-b.cost)
				ply:LiquidChat("GAME", Color(0,200,200), "You have upgraded this printer to " .. nexn .. " for $" .. b.cost)
				ent:SetNWString("Upgrade",nexn)
				ent:SetPos(ent:GetPos()+Vector(0,0,10))
				if ent:GetModel() != b.mdl then ent:SetModel(b.mdl) end
				if ent:GetMaterial() != b.mat then ent:SetMaterial(b.mat) end
				if ent:GetColor() != b.clr then ent:SetColor(b.clr) end
				if ent:GetPhysicsObject() then ent:GetPhysicsObject():Wake() end
			else
				ply:LiquidChat("GAME", Color(0,200,200), "You can't afford '" .. nexn .. "'! It costs $" .. tb[nexn].cost)
			end
		end
	else
		ply:LiquidChat("GAME", Color(0,200,200), "You must be looking at an item to upgrade it!")
	end
	return ""
end
AddChatCommand("/upgrade",LDRP.UpgradePrinter)


