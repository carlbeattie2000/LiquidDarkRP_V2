if SERVER then AddCSLuaFile("shared.lua") end

if CLIENT then

	SWEP.ViewModelFOV = 55

	SWEP.ViewModelFlip = false

	SWEP.Slot = 5

	SWEP.SlotPos = 1

	SWEP.DrawAmmo = false

	SWEP.DrawCrosshair = false

end

-- Variables that are used on both client and server

SWEP.Author = "Jackool"

SWEP.Instructions = "Left click to pick a lock"

SWEP.Contact = ""

SWEP.Purpose = "Used for unlocking doors"

SWEP.Spawnable = true

SWEP.AdminSpawnable = true

SWEP.ViewModel = Model("models/weapons/v_crowbar.mdl")

SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

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
	self:SetWeaponHoldType("normal")
end

/*---------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------*/

local LockpickTimes = LDRP_SH.LockpickTimes

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 2)

	if CLIENT then return end

	if self.IsLockPicking then return end
	
	local trace = self.Owner:GetEyeTrace()

	local e = trace.Entity

	if IsValid(e) and trace.HitPos:Distance(self.Owner:GetShootPos()) <= 100 and (e:IsDoor() or e:IsVehicle() or string.find(string.lower(e:GetClass()), "vehicle")) then
		
		self.IsLockPicking = true
		
		self.StartPick = CurTime()
		
		local Lockpicktime = LockpickTimes[self.Owner.Character.Skills["Locksmith"].lvl]

		if self.LookPickTimeReduce then 

			Lockpicktime = Lockpicktime - self.LookPickTimeReduce

		end
		
		self.EndPick = CurTime() + Lockpicktime
		
		self:SetWeaponHoldType("pistol")
		
		local snd = {1,3,4}
		
		timer.Create("LockPickSounds", 1, Lockpicktime, function(wep)
		
			if not IsValid(wep) then return end
		
			wep:EmitSound("weapons/357/357_reload".. tostring(snd[math.random(1, #snd)]) ..".wav", 50, 50)
		
		end, self)
		
		umsg.Start("SendMeter",self.Owner)
		
			umsg.String("Lockpicking...")
		
			umsg.Float(Lockpicktime)
		
		umsg.End()
	
	end

end

function SWEP:Holster()
	self.IsLockPicking = false

	if SERVER then timer.Destroy("LockPickSounds") end

	if self.CustomClr then

		if SERVER then

			self:SetColor(Color(255, 255, 255, 255))

			self:SetMaterial("")

		elseif CLIENT && IsValid(self.Owner) && IsValid(self.Owner:GetViewModel()) then

			self.Owner:GetViewModel():SetColor(Color(255, 255, 255, 255))

			self.Owner:GetViewModel():SetMaterial("")

		end

	end

	return true
end

function SWEP:Succeed()

	self.IsLockPicking = false

	local trace = self.Owner:GetEyeTrace()

	local e = trace.Entity

	if IsValid(e) and e.Fire then

		e.JustPicked = true

		timer.Simple(5,function()

			if !e:IsValid() then return end

			e.JustPicked = false

		end)

		e:Fire("unlock", "", .5)

		e:Fire("open", "", .6)

		e:Fire("setanimation","open",.6)

		if e.DoorData.Owner and e.DoorData.Owner:IsPlayer() and !e:OwnedBy(self.Owner) then self.Owner:GiveEXP("Locksmith",100,true) end
	end

	timer.Destroy("LockPickSounds")

end

function SWEP:Fail()

	self.IsLockPicking = false

	self:SetWeaponHoldType("normal")

	timer.Destroy("LockPickSounds")

	umsg.Start("CancelMeter",ply)

	umsg.End()

end

function SWEP:Think()

	if SERVER and self.IsLockPicking then

		local trace = self.Owner:GetEyeTrace()

		if not IsValid(trace.Entity) then 

			self:Fail()

		end

		if trace.HitPos:Distance(self.Owner:GetShootPos()) > 100 or (not trace.Entity:IsDoor() and not trace.Entity:IsVehicle() and not string.find(string.lower(trace.Entity:GetClass()), "vehicle")) then
			
			self:Fail()
		
		end
		
		if self.EndPick <= CurTime() then
			
			self:Succeed()
		
		end
	
	end

end

function SWEP:SecondaryAttack()

	self:PrimaryAttack()

end

function SWEP:Deploy()

	if self.CustomClr then

		if SERVER then

			timer.Simple(0.1, function() if IsValid(self) then self:CallOnClient("Deploy", "") end end)

			self:SetMaterial(self.CustomMat)

			self:SetColor(self.CustomClr)

		else

			self.Owner:GetViewModel():SetMaterial(self.CustomMat)

			self.Owner:GetViewModel():SetColor(self.CustomClr)

		end

	end

end

function SWEP:OnRemove()

	if self.CustomClr then

		if SERVER then

			self:SetMaterial("")

			self:SetColor(Color(255, 255, 255, 255))

		elseif CLIENT && IsValid(self.Owner) && IsValid(self.Owner:GetViewModel()) then

			self.Owner:GetViewModel():SetColor(Color(255, 255, 255, 255))

			self.Owner:GetViewModel():SetMaterial("")

		end

	end

end