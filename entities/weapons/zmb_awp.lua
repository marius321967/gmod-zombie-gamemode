SWEP.Author = "Marius"
SWEP.PrintName = "Arctic Warfare Police"

SWEP.ViewModelFOV = 64
SWEP.ViewModel = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"
SWEP.AutoSwitchTo = false 
SWEP.AutoSwitchFrom = true
SWEP.Slot = 2
SWEP.SlotPos = 1 
SWEP.PreferredSlot = 4
SWEP.HoldType = "ar2"
SWEP.FiresUnderwater = true 
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.CSMuzzleFlashes = true
SWEP.MaxAmmo = 40
 
SWEP.Primary.Sound = "zmb/weapons/awp/awp_shoot1.wav"
SWEP.Primary.Damage = 120
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 10
SWEP.Primary.Ammo = "XBowBolt"
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Spread = 0
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 10
SWEP.Primary.Delay = 1.5
SWEP.Base = "zmb_weapon_base"

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	self.Owner:LagCompensation(true)
	self:EmitSound(Sound(self.Primary.Sound)) 
 
	local projectile = {}
	projectile.Num = self.Primary.NumberofShots
	projectile.Src = self.Owner:GetShootPos()
	projectile.Dir = self.Owner:GetAimVector()
	projectile.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
	projectile.Tracer = 1
	projectile.Force = self.Primary.Force 
	projectile.Damage = self.Primary.Damage 
	projectile.AmmoType = self.Primary.Ammo 
	
	self:ShootEffects()
 
	self.Owner:FireBullets(projectile) 
	self.Owner:ViewPunch(Angle(-self.Primary.Recoil, self.Primary.Recoil * math.random(-1, 1), 0)) 
	self:TakePrimaryAmmo(self.Primary.TakeAmmo) 
 
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Owner:LagCompensation(false)
end 
 
function SWEP:SecondaryAttack()
	if (self.Owner:GetFOV() > 45) then
		self.Owner:SetFOV(45, 0.2)
	else
		self.Owner:SetFOV(0, 0.2)
	end
end

function SWEP:DrawHUD()
	draw.DrawText(self.Owner:GetActiveWeapon():Clip1(), "Coolvetica32", ScrW() - 16, ScrH() - 64, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
	draw.DrawText(self.Owner:GetAmmoCount(self.Owner:GetActiveWeapon():GetPrimaryAmmoType()), "Coolvetica32", ScrW() - 16, ScrH() - 32, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
	draw.DrawText(self.Owner:GetActiveWeapon().PrintName, 'Coolvetica32', ScrW() - 64, ScrH() - 48, Color(255, 255, 255), TEXT_ALIGN_RIGHT)		-- draw.SimpleTextOutlined(, "Coolvetica32", ScrW()-64, ScrH()-64, Color(0, 175, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 0, Color(0, 0, 0))
end