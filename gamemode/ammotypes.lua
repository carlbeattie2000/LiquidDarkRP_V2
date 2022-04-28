/*---------------------------------------------------------------------------
-- Custom ammo types

-- Add your custom ammo types in this file. Here's the syntax:

-- GM:AddAmmoType(ammoType, name, model, price, amountGiven, customCheck)

-- ammoType: The name of the ammo that Garry's mod recognizes
-- 	If you open your SWEP's shared.lua, you can find the ammo name next to
-- 	SWEP.Primary.Ammo = "AMMO NAME HERE"
-- 	or
-- 	SWEP.Secondary.Ammo = "AMMO NAME HERE"

-- name: The name you want to give to the ammo. This can be anything.

-- model: The model you want the ammo to have in the F4 menu

-- price: the price of your ammo in dollars

-- amountGiven: How much bullets of this ammo is given every time the player buys it

-- customCheck: (Optional! Advanced!) a Lua function that describes who can buy the ammo.
-- 	Similar to the custom check function for jobs and shipments
-- 	Parameters:
-- 		ply: the player who is trying to buy the ammo

-- Examples are below!
---------------------------------------------------------------------------*/

local permissions = {
	[ "pistol" ] = { TEAM_GUN, TEAM_POLICE, TEAM_CHIEF },
	[ "buckshot" ] = { TEAM_GUN },
	[ "smg1" ] = { TEAM_GUN }
}

local function PermCheck( ply, ammo )
	local good = false
	table.foreachi( permissions[ ammo ], function( _, v )
		if ply:Team() == v then
			good = true
		end
	end )

	return good
end

-- Pistol ammo type. Used by p228, desert eagle and all other pistols
GM:AddAmmoType("pistol", "Pistol ammo", "models/Items/BoxSRounds.mdl", 30, 24,
	function( ply ) return PermCheck( ply, "pistol" ) end )

-- Buckshot ammo, used by the shotguns
GM:AddAmmoType("buckshot", "Shotgun ammo", "models/Items/BoxBuckshot.mdl", 50, 8,
	function( ply ) return PermCheck( ply, "buckshot" ) end)

-- Rifle ammo, usually used by assault rifles
GM:AddAmmoType("smg1", "Rifle ammo", "models/Items/BoxMRounds.mdl", 80, 30,
	function( ply ) return PermCheck( ply, "smg1" ) end)