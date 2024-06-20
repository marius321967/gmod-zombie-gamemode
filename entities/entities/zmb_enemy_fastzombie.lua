AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Model = 'models/zombie/fast.mdl'
ENT.Goal = nil -- Don't mind this, we're going to set it up later.
ENT.Speed = 200
ENT.KillReward = 20
ENT.MaxHealth = 70
ENT.Experience = 30
ENT.AttackDamage = 3
ENT.MoveAction = ACT_RUN
ENT.HeadBone = 'ValveBiped.HC_BodyCube'
ENT.JumpSound = 'npc/fast_zombie/fz_scream1.wav'


ENT.IdleSounds = {
	'npc/zombie_poison/pz_idle2.wav',
	'npc/zombie_poison/pz_idle3.wav',
	'npc/zombie_poison/pz_idle4.wav'
}

function ENT:Initialize()
	self.Entity:SetCollisionBounds(Vector(-4, -4, 0), Vector(4, 4, 64)) 
	self.loco:SetAcceleration(900)
	self.loco:SetDeceleration(900)
	self.loco:SetJumpHeight(72)
	self:SetModel(self.Model)
	self:SetHealth(self.MaxHealth)
	self.loco:SetDesiredSpeed(self.Speed)
	self.IsFrozen = false
	self.IsAttacking = false
	self.IsStunned = false
	self.IsJumping = false
	self.Dead = false
	self.HoldingPlayer = nil
	
	IncrementAliveNPCs()
	DecrementNPCsLeftToSpawn()
	self:Init()
	--[[
	if SERVER then
		timer.Create('zmb_enemy_idle_timer_'..self:EntIndex(), 2, 0, function()
			if (IsValid(self) && self.Dead == false) then
				if (math.random(1, 1) == 1) then
					self:EmitSound(self.IdleSounds[math.random(1, table.Count(self.IdleSounds))])
				end
			else
				timer.Remove('zmb_enemy_idle_timer_'..self:EntIndex())
			end
		end)
	end
	--]]
end

function ENT:Init() end


function ENT:BehaveUpdate( fInterval )
	if ( !self.BehaveThread ) then return end
	if ( self.IsFrozen ) then return end
	for k, v in ipairs(ents.FindInSphere(Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z+36), 50) ) do
		if (IsValid(v)) then
			if (v:IsPlayer() == true) then
				if (v:Alive() == true && v:IsReady() == true) then
					self:Attack(v)
					self.Goal = v
				end
			elseif (v:GetClass() == 'func_breakable_surf') then
				v:Fire('Shatter', '0 0 0', 0)
			end
		end
	end
	local ok, message = coroutine.resume( self.BehaveThread )
	if ( ok == false ) then
		self.BehaveThread = nil
		Msg( self, "error: ", message, "\n" );
	end
end

function ENT:FindGoal()
	if ( self.IsFrozen ) then return end
	if (table.Count(GetAlivePlayers()) > 0) then
		self:SetGoal(GetClosest(self, GetAlivePlayers()))
	else
		self.IsFrozen = true
	end
end

function ENT:RunBehaviour()
	while true do
		self:FindGoal()
		self:StartActivity(self.MoveAction)
		self:SetPlaybackRate(2)
		if (self:MoveToPos(self.Goal) == 'stuck') then
			DecrementAliveNPCs()
			self:Remove()
		end
		coroutine.yield()
	end
end

function ENT:OnKilled(damageinfo)
	if (damageinfo:GetAttacker().IsPlayer != nil) then
		if (damageinfo:GetAttacker():IsPlayer()) then
			damageinfo:GetAttacker():AddKills(1)
			damageinfo:GetAttacker():AddMoney(self.KillReward)
		end
	end
	DecrementAliveNPCs() -- Get rid of this from the networked variables.
	self:BecomeRagdoll(damageinfo)
	self.Dead = true
	self:EmitSound('npc/zombie/zombie_die'..math.random(1, 3)..'.wav')
end

function ENT:Attack(ent)
	if (self.IsAttacking == false && self.IsJumping == false && self.IsStunned == false) then
		self.IsAttacking = true
		self.HoldingPlayer = ent
		ent:SetRunSpeed(1)
		ent:SetWalkSpeed(1)
		self.loco:FaceTowards(ent:GetPos())
		self.loco:SetDesiredSpeed(0)
		self:StartActivity(ACT_MELEE_ATTACK1)
		self:SetPlaybackRate(1)
		timer.Create('FZAttackTimer'..self:EntIndex(), 0.2, 0, function()
			if (IsValid(self) && self.Dead != true && self.IsStunned == false && self.HoldingPlayer:Alive() == true) then
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(self.AttackDamage + math.random(-1, 1))
				dmginfo:SetDamageType(DMG_SLASH)
				dmginfo:SetAttacker(self)
				ent:TakeDamageInfo(dmginfo)
				self:EmitSound('npc/zombie/claw_strike'..math.random(1, 3)..'.wav')
			else
				self.HoldingPlayer:SetRunSpeed(128)
				self.HoldingPlayer:SetWalkSpeed(128)
				self.HoldingPlayer = nil
				self:StartActivity(self.MoveAction)
				self.IsAttacking = false
				self.loco:SetDesiredSpeed(self.Speed)
				timer.Remove('FZAttackTimer'..self:EntIndex())
			end
		end)
		--[[
		for i = 1, 4 do
			timer.Simple(0.2 * i, function()
				if (IsValid(self) && self.Dead != true && self.IsStunned == false) then
					if (ent:GetPos():Distance(self:GetPos()) < 70) then
						local dmginfo = DamageInfo()
						dmginfo:SetDamage(self.AttackDamage)
						dmginfo:SetDamageType(DMG_SLASH)
						dmginfo:SetAttacker(self)
						ent:TakeDamageInfo(dmginfo)
						self:EmitSound('npc/zombie/claw_strike'..math.random(1, 3)..'.wav')
					else
						self:EmitSound('npc/zombie/claw_miss'..math.random(1, 2)..'.wav')
					end
				end
			end)
		end
		timer.Simple(0.95, function()
			if (IsValid(self) && self.Dead != true && self.IsStunned == false) then
				self:StartActivity(self.MoveAction)
				self.IsAttacking = false
				self.loco:SetDesiredSpeed(self.Speed)
			end
		end)
		--]]
	end
end

function ENT:Stun()
	if (self.IsStunned == false && self.Dead != true) then
		self.IsStunned = true
		self.loco:SetDesiredSpeed(0)
		self:StartActivity(ACT_IDLE_ANGRY)
		self:SetPlaybackRate(1)
		timer.Simple(2, function()
			if (IsValid(self) && self.Dead != true) then
				self:StartActivity(self.MoveAction * 1.3)
				self.IsStunned = false
				self.loco:SetDesiredSpeed(self.Speed)
			end
		end)
	end
end

function ENT:OnLandOnGround()
	self.IsJumping = false
	self:StartActivity(self.MoveAction)
end
function ENT:OnLeaveGround()
	self.IsJumping = true
	self:StartActivity(ACT_JUMP)
end

function ENT:OnInjured(damageinfo) -- Other damage.
	damageinfo:SetDamage(damageinfo:GetDamage() + math.random(-2, 2))
	if (self:LookupBone(self.HeadBone) != nil) then
		if (damageinfo:GetDamagePosition():Distance(self:GetBonePosition(self:LookupBone(self.HeadBone))) < 10) then
			damageinfo:ScaleDamage(3)
		end
	end
	if (damageinfo:GetDamage() > 50) then
		self:Stun()
	end
end

function ENT:SetGoal(ent)
	if IsValid(ent) then
		self.Goal = ent
	end
end

-- Updated this function a little bit. First arguent is not a position, it's an entity.
-- The actual position is calculated inside the function. Kinda inefficient.
function ENT:MoveToPos( ent, options )
	if (IsValid(ent) == false ) then return "failed" end
	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, ent:GetPos() )
	if ( !path:IsValid() ) then return "failed" end
	while (path:IsValid() && IsValid(ent) == true && ent == self.Goal) do
		if (ent:IsPlayer() == true) then
			if (ent:Alive() == false) then
				return "ok"
			end
		end
		path:Compute( self, ent:GetPos() )
		path:Update( self )
		if ( options.draw ) then
			path:Draw()
		end
		if ( self.loco:IsStuck() ) then
			self:HandleStuck();
			return "stuck"
		end
		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end
		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then path:Compute( self, ent:GetPos() ) end
		end
		coroutine.yield()
	end
	return "ok"
end
