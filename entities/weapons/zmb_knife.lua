SWEP.Author = "Marius"
SWEP.PrintName = "Knife"

SWEP.ViewModelFOV = 64
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
SWEP.Slot = 0
SWEP.SlotPos = 1 
SWEP.PreferredSlot = 1
SWEP.HoldType = "knife"
SWEP.FiresUnderwater = true 
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.CSMuzzleFlashes = true
 
SWEP.Primary.Sound = 'weapons/iceaxe/iceaxe_swing1.wav'
SWEP.Primary.Damage = 30
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.6
SWEP.Base = "zmb_weapon_base"

function SWEP:PrimaryAttack()
	if (self:GetNextPrimaryFire() > CurTime()) then return end
	self.Owner:LagCompensation(true)
	self:EmitSound(Sound(self.Primary.Sound)) 
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	
	--[[
	for k, ent in ipairs(ents.FindInCone(self:GetOwner():GetShootPos(),	self:GetOwner():GetAimVector(),	70, 45)) do
		if (string.find(ent:GetClass(), 'zmb_enemy_') != nil) then
			
		end
	end
	--]]
	
	local projectile = {}
	projectile.Num = self.Primary.NumberofShots
	projectile.Src = self.Owner:GetShootPos()
	projectile.Dir = self.Owner:GetAimVector()
	projectile.Spread = Vector(0, 0, 0)
	projectile.Tracer = 0
	projectile.Distance = 60
	projectile.Force = self.Primary.Force
	projectile.Damage = self.Primary.Damage
	projectile.AmmoType = self.Primary.Ammo
	self.Owner:FireBullets(projectile)
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Owner:LagCompensation(false)
end 
 
function SWEP:SecondaryAttack() 
	--[[
	if SERVER then
		local ent = ents.Create('crossbow_bolt')
		ent:SetPos(self.Owner:GetShootPos())
		ent:SetAngles(self.Owner:GetAimVector():Angle())
		ent.m_iDamage = self.Primary.Damage;
		ent:SetOwner(self.Owner)
		ent:Spawn()
		ent:SetVelocity(self.Owner:GetAimVector() * 5000)
	end
	--]]
end 

function SWEP:Reload() end

function SWEP:DrawHUD()
	draw.DrawText(self.Owner:GetActiveWeapon().PrintName, 'Coolvetica32', ScrW() - 64, ScrH() - 48, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
end

function SWEP:Holster(wep)
	self.Owner:SetWalkSpeed(160)
	self.Owner:SetRunSpeed(160)
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

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.Owner:SetWalkSpeed(160 * 1.2)
	self.Owner:SetRunSpeed(160 * 1.2)
	self:SetNextPrimaryFire(CurTime() + 0.4)
	return true
end