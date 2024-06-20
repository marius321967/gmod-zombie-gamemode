SWEP.Author = "Marius"
SWEP.PrintName = "Standard Issue Medkit"

SWEP.ViewModelFOV = 64
SWEP.ViewModel = "models/weapons/c_medkit.mdl"
SWEP.WorldModel = "models/weapons/w_medkit.mdl"
SWEP.AutoSwitchTo = false 
SWEP.AutoSwitchFrom = true
SWEP.Slot = 3
SWEP.SlotPos = 1 
SWEP.PreferredSlot = 5
SWEP.HoldType = "slam"
SWEP.FiresUnderwater = true 
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.UseHands = true
SWEP.CSMuzzleFlashes = true
 
SWEP.Primary.Sound = "items/smallmedkit1.wav"
SWEP.Primary.Damage = 10
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 1
SWEP.Base = "zmb_weapon_base"

function SWEP:PrimaryAttack()
	if (tonumber(self:GetNextPrimaryFire()) > CurTime() || tonumber(self.Owner:GetNWInt('HealthCharge')) <= 0) then return end
	if CLIENT then return end
	local tr = self.Owner:GetEyeTrace()
	if (tr.Entity.IsPlayer != nil) then
		if (tr.Entity:IsPlayer() == true) then
			if (tr.Entity:Alive() == true) then
				if (self.Owner:GetPos():Distance(tr.Entity:GetPos()) < 128) then
					local HealAmount = math.min(self.Primary.Damage, self.Owner:GetNWInt('HealthCharge'))
					tr.Entity:SetHealth(tr.Entity:Health() + HealAmount)
					self.Owner:SetNWInt('HealthCharge', self.Owner:GetNWInt('HealthCharge') - HealAmount)
					tr.Entity:EmitSound(Sound(self.Primary.Sound)) 
					self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
					self.Owner:AddMoney(math.floor(HealAmount/2))
				end
			end
		end
	else
		for k, v in ipairs(ents.FindInSphere(self.Owner:GetPos()), 128) do
			if (v.IsPlayer != nil) then
				if (v:IsPlayer() == true) then
					if (v:Alive() == true) then
						local HealAmount = math.min(self.Primary.Damage, self.Owner:GetNWInt('HealthCharge'))
						v:SetHealth(v:Health() + HealAmount)
						self.Owner:SetNWInt('HealthCharge', self.Owner:GetNWInt('HealthCharge') - HealAmount)
						v:EmitSound(Sound(self.Primary.Sound)) 
						self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
						self.Owner:AddMoney(math.floor(HealAmount/2))
					end
				end
			end
		end
	end
end

function SWEP:Reload() end

function SWEP:DrawHUD()
	draw.DrawText(self.Owner:GetNWInt('HealthCharge'), "Coolvetica32", ScrW() - 16, ScrH() - 64, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
	draw.DrawText(self.Owner:GetActiveWeapon().PrintName, 'Coolvetica32', ScrW() - 64, ScrH() - 48, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
end