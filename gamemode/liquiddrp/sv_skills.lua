local LDRP = {}

function LDRP.UpgradeSkill(ply,cmd,args)
	if !args or !args[1] or args[2] then return end
	if ply.Character.Skills[args[1]] then
		local cur = ply.Character.Skills[args[1]]
		local tbl = LDRP_SH.AllSkills[args[1]]
		if cur.exp >= tbl.exptbl[cur.lvl] then
			local nextlvl = cur.lvl+1
			local cost = tbl.pricetbl[nextlvl]
			if !cost then
				ply:LiquidChat("SKILLS", Color(0,0,200), "You have the max level for this skill!")
				return
			end
			if ply:CanAfford(cost) then
				ply:LiquidChat("SKILLS", Color(0,0,200), "Bought level " .. nextlvl .. " " .. args[1] .. " for $" .. cost)
				ply:AddMoney(-cost)
				ply:GiveLevel(args[1],1)
			else
				ply:LiquidChat("SKILLS", Color(0,0,200), "You can't afford this, it costs $" .. cost)
			end
		end
	end
end
concommand.Add("_buysk",LDRP.UpgradeSkill)

util.AddNetworkString( "AddStaminaExp" )
net.Receive( "AddStaminaExp", function( length, ply )
	if not ply then return end
	local plyExp = net.ReadInt( 8 )
	ply:GiveEXP( "Stamina", plyExp, true )
end )