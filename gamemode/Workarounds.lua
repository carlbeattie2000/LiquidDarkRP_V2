
if CLIENT then
	/*---------------------------------------------------------------------------
	Vehicle fix for datastream from Tobba
	---------------------------------------------------------------------------*/
	--Commenting out fix - not using glon (so not necessary?)
	/*
	function debug.getupvalues(f)
		local t, i, k, v = {}, 1, debug.getupvalue(f, 1)
		while k do
			t[k] = v
			i = i+1
			k,v = debug.getupvalue(f, i)
		end
		return t
	end

	glon.encode_types = debug.getupvalues(glon.Write).encode_types
	glon.encode_types["Vehicle"] = glon.encode_types["Vehicle"] or {10, function(o)
			return (IsValid(o) and o:EntIndex() or -1).."\1"
		end}
	*/
	/*---------------------------------------------------------------------------
	Fix the gmod cleanup
	---------------------------------------------------------------------------*/
	concommand.Add( "gmod_admin_cleanup", function( pl, command, args )
		if not pl:IsAdmin() then return end
		for k,v in pairs(ents.GetAll()) do
			if v.Owner and not v:IsWeapon() then -- DarkRP entities have the Owner part of their table as nil.
				v:Remove()
			end
		end
		if NotifyAll then NotifyAll(0, 4, pl:Nick() .. " cleaned up everything.") end
	end)

	/*---------------------------------------------------------------------------
	Generic InitPostEntity workarounds
	---------------------------------------------------------------------------*/
	hook.Add("InitPostEntity", "DarkRP_Workarounds", function()
		if hook.GetTable().HUDPaint then hook.Remove("HUDPaint","drawHudVital") end -- Removes the white flashes when the server lags and the server has flashbang. Workaround because it's been there for fucking years
	end)

	return
end

/*---------------------------------------------------------------------------
Assmod makes previously banned people able to noclip. I say fuck you.
---------------------------------------------------------------------------*/
hook.Add("PlayerNoClip", "DarkRP_FuckAss", function(ply)
	if LevelToString and string.lower(LevelToString(ply:GetNWInt("ASS_isAdmin"))) == "banned" then -- Assmod's bullshit
		for k, v in pairs(player.GetAll()) do
			if v:IsAdmin() then
				GAMEMODE:TalkToPerson(v, Color(255,0,0,255), "WARNING", Color(0,0,255,255), "If DarkRP didn't intervene, assmod would have given a banned user noclip access.\nGet rid of assmod, it's a piece of shit.", ply)
			end
		end
		return false
	end
end)

/*---------------------------------------------------------------------------
Generic InitPostEntity workarounds
---------------------------------------------------------------------------*/
-- 3/10/2013 tgp1994 No idea what below coder is going on about, but durgz_witty_sayings isn't a cvar. Maybe they removed it.
--[[hook.Add("InitPostEntity", "DarkRP_Workarounds", function()
	game.ConsoleCommand("durgz_witty_sayings 0\n") -- Deals with the cigarettes exploit. I'm fucking tired of them. I hate having to fix other people's mods, but this mod maker is retarded and refuses to update his mod.
end)]]
