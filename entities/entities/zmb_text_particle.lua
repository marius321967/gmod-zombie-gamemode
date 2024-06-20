AddCSLuaFile()

ENT.Base 			= "base_anim"

function ENT:Initialize()
	self:SetModel('models/props_junk/garbage_metalcan002a.mdl')
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:PhysWake()
	self:GetPhysicsObject():SetMass(1)
	self:Launch()
end

function ENT:Draw()
	local color = self:GetNWVector('Color')
	cam.Start3D2D(self:GetPos(), Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.1)
	draw.SimpleTextOutlined(self:GetNWString('Text'), "Stitch200", 0, 0, Color(color.x, color.y, color.z), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0))
	cam.End3D2D()
end

function ENT:SetText(t)
	self:SetNWString('Text', t)
end

function ENT:SetDrawColor(t)
	self:SetNWVector('Color', t)
end

function ENT:Launch()
	self:GetPhysicsObject():SetVelocity(Vector(math.random(-100, 100), math.random(-100, 100), math.random(200, 300)))
end