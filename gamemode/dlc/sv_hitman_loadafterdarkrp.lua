local LDRP_Hitman = {}
LDRP_Hitman.Hits = {}

function LDRP_Hitman.PlaceHit(ply,arglong)
	local args = string.Explode(" ",arglong)
	
	if ply:Team() == TEAM_HITMAN then
		umsg.Start("SendHitMenu",ply)
		umsg.End()
	else
		if !arglong or !args or !args[1] or args[2] or args[1] == "" then ply:ChatPrint("Wrong format. Format: '/hit playersname'. This will cost $" .. LDRP_SH_Hitman.HitPrice) return "" end
		local playa = {}
		for k,v in pairs(player.GetAll()) do
			if string.find(string.lower(v:Name()),string.lower(args[1])) then
				table.insert(playa,v)
			end
		end
		
		if playa[2] then
			Notify(ply, 1, 3, "Multiple players found. Please type out the player's full name")
			return ""
		elseif !playa[1] then
			Notify(ply, 1, 3, "Player not found! Did you type it wrong?")
			return ""
		end
		
		local ply2 = playa[1]
		
		if LDRP_SH_Hitman.MultiHits then
			for k,v in pairs(LDRP_Hitman.Hits) do if v == ply2 then Notify(ply, 1, 3, "There is already a hit on this player.") return "" end end
		end
		
		if !ply:CanAfford(LDRP_SH_Hitman.HitPrice) then
			Notify(ply, 1, 3, "You can't afford a hit! Hits cost $" .. LDRP_SH_Hitman.HitPrice)
			return ""
		end
		local PlyName = ply2:Name()
		
		ply:AddMoney(-LDRP_SH_Hitman.HitPrice)
		Notify(ply, 0, 4, "You have placed a hit on " .. PlyName)
		table.insert(LDRP_Hitman.Hits,ply2)

		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_HITMAN then
				Notify(v, 5, 5, "A hit has been placed on " .. PlyName .. ", type /hit for more info.")
				umsg.Start("SendHitt",v)
					umsg.Entity(ply2)
				umsg.End()
			end
		end
	end
	return ""
end
AddChatCommand("/hit",LDRP_Hitman.PlaceHit)

LDRP_SH.ChangeJobFuncs["Hitman"] = function(ply)
	umsg.Start("ResetHits",ply)
		umsg.Entity(v)
	umsg.End()
	for k,v in pairs(LDRP_Hitman.Hits) do
		umsg.Start("SendHitt",ply)
			umsg.Entity(v)
		umsg.End()
	end
end

hook.Add("DoPlayerDeath","Removes hits, gives cash",function(victim,attk,dmginfo)
	if IsValid(attk) and type(attk) == "Player" and attk:Team() == TEAM_HITMAN and table.HasValue(LDRP_Hitman.Hits,victim) then
		umsg.Start("RemoveHitt")
			umsg.String(string.lower(victim:UniqueID()))
		umsg.End()
		attk:AddMoney(LDRP_SH_Hitman.HitPrice)
		Notify(attk, 5, 5, "You have completed the hit on " .. victim:Name() .. " and received $" .. LDRP_SH_Hitman.HitPrice)
		for k,v in pairs(LDRP_Hitman.Hits) do
			if v == victim then
				LDRP_Hitman.Hits[k] = nil
			end
		end
	end
end)

AddChatCommand("/buddies",function(ply) ply:ConCommand("protector_buddies") return "" end)