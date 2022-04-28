if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Crafting Hammer"
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 55
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 0
	SWEP.SlotPos		= 2
end

SWEP.Author		= "Jackool"
SWEP.Contact		= ""
SWEP.Purpose		= "Used for crafting"
SWEP.Instructions	= "Primary fire while looking at a crafting table."


SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.ViewModel		= "models/weapons/v_sledgehammer/v_sledgehammer.mdl"
SWEP.WorldModel  	= "models/weapons/w_sledgehammer.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()
end

function SWEP:Reload()
end

/*---------------------------------------------------------
	PrimaryAttack
	Line 553: 			 self.Owner:EmitSound(Sound("physics/glass/glass_bottle_impact_hard"..tostring(math.random(1,3))..".wav"))
	Line 553: 			 self.Owner:EmitSound(Sound("physics/glass/glass_bottle_impact_hard"..tostring(math.random(1,3))..".wav"))
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	if self.Weapon:GetNextPrimaryFire() >= CurTime() then return end

	self.Weapon:SetNextPrimaryFire(CurTime()+2)
	if self.Owner:Team() != TEAM_CRAFTER then if SERVER then self.Owner:LiquidChat("Mining", Color(100,100,100), "You need to be the crafter job to use this. (remember to holster the hammer first)") end return end
	
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

	if !CLIENT then return end
	
	local LP = LocalPlayer()
	if LP:GetEyeTrace().Entity and LP:GetEyeTrace().Entity:IsValid() and LP:GetEyeTrace().Entity:GetClass() == "crafting_table" then
		LDRP_SH.OpenCraftingMenu()
	end
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
end