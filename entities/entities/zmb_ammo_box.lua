AddCSLuaFile()

ENT.Type = 'anim'
ENT.Base = 'base_anim'

ENT.Editable			= true
ENT.Spawnable			= true
ENT.AdminOnly			= false

ENT.Model = 'models/items/item_item_crate.mdl'

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:PhysWake()
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:Use(activator, caller)
	if (activator:IsPlayer()) then
		if (activator:Alive() == true) then
			if (activator:GetActiveWeapon() != nil) then
				if (activator:GetActiveWeapon().Primary.ClipSize > 0) then -- Make sure we don't fill a melee weapon with ammo.
					local AmmoNeeded = math.min(activator:GetActiveWeapon().Primary.ClipSize*2, activator:GetActiveWeapon().MaxAmmo - activator:GetAmmoCount(activator:GetActiveWeapon().Primary.Ammo))
					if (AmmoNeeded > 0) then
						self:Remove()
						activator:GiveAmmo(AmmoNeeded, activator:GetActiveWeapon().Primary.Ammo)
					else
						activator:ConCommand('zmb_addhudmessage "You can\'t carry more ammo." 5')
					end
				end
			end
		end
	end
end