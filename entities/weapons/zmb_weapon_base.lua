SWEP.base = "weapon_base"
SWEP.UseHands = true

SWEP.HoldType = "normal"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()
	util.PrecacheSound(self.Primary.Sound) 
	self:SetHoldType(self.HoldType)
end

function SWEP:SecondaryAttack() end 

function SWEP:Reload()
	if (self.ReloadingTime != nil && CurTime() <= self.ReloadingTime) then return end
	if (self:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
		self:DefaultReload(ACT_VM_RELOAD)
		local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
		self.ReloadingTime = CurTime() + AnimationTime
		self:SetNextPrimaryFire(CurTime() + AnimationTime)
	end
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + 0.4)
	return true
end

function SWEP:Holster(wep)
	if (self.ReloadingTime != nil) then
		if (CurTime() > self.ReloadingTime) then
			return true
		else
			return false
		end
	else 
		return true
	end
end

function SWEP:Equip(ply)
	ply:SetNWString('Slot'..self.PreferredSlot, self:GetClass())
end