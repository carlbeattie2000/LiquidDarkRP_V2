if SERVER then

	AddCSLuaFile( "shared.lua" )

	resource.AddSingleFile("models/weapons/v_fists_t.dx80.vtx")
	resource.AddSingleFile("models/weapons/v_fists_t.dx90.vtx")
	resource.AddSingleFile("models/weapons/v_fists_t.mdl")
	resource.AddSingleFile("models/weapons/v_fists_t.sw.vtx")
	resource.AddSingleFile("models/weapons/v_fists_t.vvd")
	resource.AddSingleFile("models/weapons/v_fists_tt.dx90.vtx")

else

	SWEP.DrawCrosshair 	= false
	SWEP.DrawAmmo 		= false

end

SWEP.Spawnable				= true;
SWEP.AdminSpawnable			= true;

SWEP.ViewModel			= "models/weapons/v_fists_t.mdl"

SWEP.Author = "Jackool"
SWEP.Instructions = "Left Click: Punch"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.WorldModel = Model("")

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false


SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.HoldType = "fist"


function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )
	
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:DrawViewModel(true)
		self.Owner:DrawWorldModel(false)
	end
end

local HitSounds = {"npc/vort/foot_hit.wav","npc/zombie/zombie_hit.wav"}

function SWEP:PrimaryAttack()
	local ply = self.Owner
	
	if CLIENT then
		self.Weapon:EmitSound("npc/zombie/claw_miss" .. math.random( 1, 2 ) .. ".wav");
	end
	
	ply:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST)
	ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST)
	
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)

	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	
	local EyeTrace = ply:GetEyeTrace();
	
	if ply:EyePos():Distance(EyeTrace.HitPos) > 75 then return false; end

    local final = HitSounds[math.random(1,#HitSounds)]

	if EyeTrace.MatType == MAT_GLASS then
		if CLIENT then
			self.Weapon:EmitSound("physics/glass/glass_cup_break" .. math.random(1, 2) .. ".wav");
		end
		return false
	end
	
	if EyeTrace.HitWorld then
		if CLIENT then
			self.Weapon:EmitSound( final );
		end
		return false;
	end

	if CLIENT and EyeTrace.Entity and EyeTrace.Entity:IsValid() then self.Weapon:EmitSound( final ) end

	if EyeTrace.MatType == MAT_FLESH then
		if CLIENT then
			// probably another person or NPC
			self.Weapon:EmitSound( final )
			
			local OurEffect = EffectData();
			OurEffect:SetOrigin(EyeTrace.HitPos);
			util.Effect("BloodImpact", OurEffect);
		end
		
		if SERVER then
			if EyeTrace.Entity and EyeTrace.Entity:IsValid() and EyeTrace.Entity:IsPlayer() then
				EyeTrace.Entity:TakeDamage(ply.Character.Skills["Stamina"].lvl*3, ply, self.Weapon)
			end
		end
		
		return false;
	else
		// something else?
		if CLIENT then
			self.Weapon:EmitSound( final )
		end
	end
end

function SWEP:SecondaryAttack()
	return false
end
