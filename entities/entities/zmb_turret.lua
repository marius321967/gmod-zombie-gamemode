AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true
ENT.Damage = 50
ENT.Spread = 0.5
ENT.ShotDelay = 0.3
ENT.ForwardSight = 2000
ENT.WideSight = 90

ENT.ShootSound = 'zmb/spl_turret/turret_shoot1.mp3'
ENT.SpotSound = 'zmb/spl_turret/turret_spotenemy.mp3'
ENT.LostSound = 'zmb/spl_turret/turret_loseenemy.mp3'
ENT.IdleSound = 'zmb/spl_turret/turret_idle1.wav'

function ENT:Initialize()
	self.loco:SetAcceleration(900)
	self.loco:SetDeceleration(900)
	self.loco:SetDesiredSpeed(20)
	self:SetModel('models/spl/turret.mdl')
	self:FindGoal()
	self:SetNextShoot(self.ShotDelay)
	timer.Create('TurretIdleTimer'..self:EntIndex(), 1.59, 0, function()
		if (self:IsValid() == true) then
			self:EmitSound(self.IdleSound)
		else
			timer.Destroy('TurretIdleTimer'..self:EntIndex())
		end
	end)
end

function ENT:FindGoal()
	for k, v in ipairs(ents.FindInCone(self:GetPos(), self:GetForward(), self.ForwardSight, self.WideSight)) do
		if (v.Base == 'zmb_enemy_base') then -- Target still in sight.
			self.Goal = v
			self:EmitSound(self.SpotSound)
		end
	end
end

function ENT:RunBehaviour()
	self:StartActivity(ACT_IDLE)
	while true do
		EnemyInCone = true
		if (self.Goal != nil) then
			if (self.Goal:IsValid()) then
				local trace = {}
				trace.start = self:GetPos()
				trace.endpos = self.Goal:GetPos()
				trace.filter = self
				local tr = util.TraceLine(trace)
				EnemyInCone = true
				local turn = math.AngleDifference(self:GetForward():Angle().y, tr.Normal:Angle().y)
				if (turn < -90 || turn > 90) then
					self:LoseGoal()
				elseif (turn < 0) then 
					self:SetPoseParameter('yaw_left', turn+1)
					self:SetPoseParameter('yaw_right', 0)
				else
					self:SetPoseParameter('yaw_left', 0)
					self:SetPoseParameter('yaw_right', turn+1)
				end
				if (self:CanShoot() == true) then
					self:Shoot(Vector(tr.Normal.x, tr.Normal.y, tr.Normal.z))
				end
			else
				self:LoseGoal()
			end
		else
			self:FindGoal()
		end
		coroutine.yield()
	end
end


function ENT:LoseGoal()
	self.Goal = nil
	self:EmitSound(self.LostSound)
	self:SetPoseParameter('yaw_left', 0)
	self:SetPoseParameter('yaw_right', 0)
end

function ENT:CanShoot()
	if (self.NextShoot <= CurTime()) then
		return true
	else
		return false
	end
end

function ENT:TargetInSight()
	local trace = {}
	trace.start = self:GetAttachment(self:LookupAttachment('muzzle')).Pos
	trace.endpos = self.Goal:GetAttachment(self.Goal:LookupAttachment('eyes')).Pos
	trace.filter = self
	local traceresult = util.TraceLine(trace)
	if (traceresult.Entity == self.Goal) then
		return true
	else
		return false
	end
end

function ENT:SetNextShoot(t)
	self.NextShoot = CurTime() + t
end

function ENT:Shoot(dir)
	self:StartActivity(ACT_RANGE_ATTACK1)
	timer.Simple(0.13, function()
		self:StartActivity(ACT_IDLE)
	end)
	self:EmitSound(self.ShootSound)
	local bullet = {}
	bullet.Num = 1
	bullet.Src = self:GetAttachment(self:LookupAttachment('muzzle')).Pos
	-- bullet.Dir = self:GetAttachment(self:LookupAttachment('muzzle')).Ang:Forward()
	bullet.Dir = dir
	bullet.Spread = Vector(self.Spread * 0.1, self.Spread * 0.1, 0)
	bullet.Tracer = 1	
	bullet.Force = 20
	bullet.Damage = self.Damage
	
	self:FireBullets(bullet) 
	self:SetNextShoot(self.ShotDelay)
end