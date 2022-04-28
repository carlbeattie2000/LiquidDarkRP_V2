if (SERVER) then
	AddCSLuaFile("shared.lua")
end

if (CLIENT) then
	SWEP.PrintName = "Keypad Cracker"
	SWEP.Slot = 4
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

-- Variables that are used on both client and server

SWEP.Author = "Jackool"
SWEP.Instructions = "Left click to crack a keypad"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/v_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.Sound = Sound("weapons/deagle/deagle-1.wav")

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

/*---------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()
	if (SERVER) then
		self:SetWeaponHoldType("normal")
	end
end

/*---------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------*/

local CrackTimes = LDRP_SH.CrackTimes
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + .4)
	if CLIENT then return end
	if self.IsCracking then return end
	local CrackTime = CrackTimes[self.Owner.Character.Skills["Hacking"].lvl or 1]
	local trace = self.Owner:GetEyeTrace()
	local e = trace.Entity
	if IsValid(e) and trace.HitPos:Distance(self.Owner:GetShootPos()) <= 300 and (e:GetClass() == "sent_keypad") then
		local ThieveryType
		local pl = self.Owner
		self.IsCracking = true
		self.StartCrack = CurTime()
		self.EndCrack	= CurTime() + CrackTime
		self:SetWeaponHoldType("pistol")
		timer.Create("KeyCrackSounds", 1, CrackTime, function()
			self:EmitSound("buttons/blip2.wav", 50, 50)
		end)
		umsg.Start("SendMeter",self.Owner)
			umsg.String("Cracking...")
			umsg.Float(CrackTime)
		umsg.End()
	end 
end

function SWEP:Holster()
	self.IsCracking = false
	timer.Destroy("KeyCrackSounds")
	return true
end

function SWEP:Succeed()
	self.IsCracking = false
	local trace = self.Owner:GetEyeTrace()
	if IsValid(trace.Entity) and trace.Entity:GetClass() == "sent_keypad" then
		local owner = trace.Entity:GetNWEntity("keypad_owner")
		if !owner:IsValid() then return end
		if owner != self.Owner then
			if SERVER then self.Owner:GiveEXP("Hacking",100,true) end
		else
			if CLIENT then notification.AddLegacy( "No hacking experience awarded for cracking your own keypad!", 1, 3 ) end
		end

		local key = trace.Entity:GetNWInt("keypad_keygroup1")
		local delay = trace.Entity:GetNWInt("keypad_length1")
		numpad.Activate( owner, key, false )
		timer.Simple( delay, function() numpad.Deactivate( owner, key, false ) end )
		trace.Entity:SetNWBool("keypad_access", true)
		trace.Entity:SetNWBool("keypad_showaccess", true)
		if (SERVER) then
			trace.Entity:EmitSound("buttons/button11.wav")
		end
		timer.Simple(2, function() trace.Entity:SetNWBool("keypad_showaccess", false) end)
	end
	timer.Destroy("KeyCrackSounds")
end

function SWEP:Fail()
	self.IsCracking	= false
	self:SetWeaponHoldType("normal")
	timer.Destroy("KeyCrackSounds")
	umsg.Start("CancelMeter",ply)
	umsg.End()
end

function SWEP:Think()
	if SERVER and self.IsCracking then
		local trace = self.Owner:GetEyeTrace()
		if not IsValid(trace.Entity) then 
			self:Fail()
		end
		if trace.HitPos:Distance(self.Owner:GetShootPos()) > 300 or (trace.Entity:GetClass() != "sent_keypad" and !trace.Entity.isFadingDoor) then
			self:Fail()
		end
		if self.EndCrack <= CurTime() then
			self:Succeed()
		end
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end