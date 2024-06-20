SWEP.Author = "Marius"
SWEP.PrintName = "Benelli M3"

SWEP.ViewModelFOV = 64
SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.AutoSwitchTo = false 
SWEP.AutoSwitchFrom = true
SWEP.Slot = 1
SWEP.SlotPos = 1 
SWEP.PreferredSlot = 3
SWEP.HoldType = "shotgun"
SWEP.FiresUnderwater = true 
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.CSMuzzleFlashes = true
SWEP.MaxAmmo = 64
 
SWEP.Primary.Sound = "zmb/weapons/m3/m3_shoot1.wav"
SWEP.Primary.Damage = 10
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 8
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Spread = 1
SWEP.Primary.NumberofShots = 12
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Delay = 0.9
SWEP.Base = "zmb_weapon_base"

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	if (self:GetNWBool('Reloading') == true) then 
		self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
		self:SetNWBool('Reloading', false)
		self:SetNextPrimaryFire(CurTime() + 1)
		timer.Destroy('ReloadTimer'..self:EntIndex())
		return
	end
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
	if SERVER then
		projectile.Callback = function(ply, tr, damageinfo)
			if (string.find(tr.Entity:GetClass(), 'zmb_enemy_') != nil) then
				tr.Entity:Ignite(5, 0)
			end
		end
	end
	self.Owner:FireBullets(projectile)
	
	self:ShootEffects()
 
	self.Owner:ViewPunch(Angle(-self.Primary.Recoil, self.Primary.Recoil * math.random(-1, 1), 0)) 
	self:TakePrimaryAmmo(self.Primary.TakeAmmo) 
 
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
end

function SWEP:Reload()
	if (self.ReloadingTime != nil && CurTime() <= self.ReloadingTime) then return end
	if (self:GetNWBool('Reloading') == true) then return end
	if (self:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
		self:SetNWBool('Reloading', true)
		self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
		timer.Simple(0.3, function()
			if (IsValid(self) == true) then
				if (self.Owner != nil) then
					if (self.Owner:Alive() == true && self.Owner:IsValid() == true && self.Owner:GetActiveWeapon() == self) then
						self:SendWeaponAnim(ACT_VM_RELOAD)
						self:SetClip1(self:Clip1() + 1)
						self.Owner:SetAmmo(self.Owner:GetAmmoCount(self.Primary.Ammo) - 1, self.Primary.Ammo)
						self:SetNextPrimaryFire(CurTime() + 0.5)
						timer.Create('ReloadTimer'..self:EntIndex(), 0.5, 0, function()
							if (IsValid(self) == true) then
								if (self.Owner != nil) then
									if (self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 && self.Owner:Alive() == true && self.Owner:IsValid() == true && self.Owner:GetActiveWeapon() == self) then
										if (self:Clip1() < self.Primary.ClipSize) then -- Still reloading.
											self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
											self:SetClip1(self:Clip1() + 1)
											self.Owner:SetAmmo(self.Owner:GetAmmoCount(self.Primary.Ammo) - 1, self.Primary.Ammo)
											timer.Simple(0.03, function()
												self:SendWeaponAnim(ACT_VM_RELOAD)
											end)
										else -- We finished reloading
											self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
											self:SetNWBool('Reloading', false)
											self:SetNextPrimaryFire(CurTime() + 1)
											timer.Destroy('ReloadTimer'..self:EntIndex())
										end
									end
								end
							end
						end)
					end -- Oh my god.
				end
			end
		end)
	end
end

function SWEP:DrawHUD()
	draw.DrawText(self.Owner:GetActiveWeapon():Clip1(), "Coolvetica32", ScrW() - 16, ScrH() - 64, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
	draw.DrawText(self.Owner:GetAmmoCount(self.Owner:GetActiveWeapon():GetPrimaryAmmoType()), "Coolvetica32", ScrW() - 16, ScrH() - 32, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
	draw.DrawText(self.Owner:GetActiveWeapon().PrintName, 'Coolvetica32', ScrW() - 64, ScrH() - 48, Color(255, 255, 255), TEXT_ALIGN_RIGHT)		-- draw.SimpleTextOutlined(, "Coolvetica32", ScrW()-64, ScrH()-64, Color(0, 175, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 0, Color(0, 0, 0))
end