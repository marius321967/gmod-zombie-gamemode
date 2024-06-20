AddCSLuaFile()

ENT.Type = 'anim'
ENT.Base = 'base_anim'

function ENT:Initialize()
	if SERVER then
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self.Clip = 0
		self.PreferredSlot = 2
		self:PhysWake()
	end
end

function ENT:Use( activator, caller )
	if (activator:IsPlayer()) then
		if (!activator:HasWeapon(self.Weapon) ) then
			for i = 1, 5 do
				if (activator:GetNWString('Slot'..i) == self.Weapon) then
					activator:ConCommand('zmb_addhudmessage "You already have this weapon." 7')
					break
				end
			end
			self:Remove()
			activator:Give(self.Weapon)
			activator:GetWeapon(self.Weapon):SetClip1(self.Clip)
		end
	end
end
--[[
function ENT:Draw()
	self:DrawModel()
	if (math.random(1, 3) != 1) then
		local EntPos = self:GetPos()
		EntPos.z = EntPos.z + 20
		cam.Start3D2D(EntPos, Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.1 )
		draw.DrawText('Ar-2', "Stitch64", 0, -50, Color(0, 170, 255), TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end

--]]
function ENT:SetWeapon(ent)
	self.Weapon = ent
end
function ENT:SetViewModel(path)
	self.Model = path
end