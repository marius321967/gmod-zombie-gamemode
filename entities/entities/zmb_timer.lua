AddCSLuaFile()

ENT.Type 				= 'point'
ENT.Base 				= 'base_point'


function ENT:Initialize()
	if SERVER then
		self.TimerID = 'Timer'..self:EntIndex()
		timer.Create(self.TimerID, 1, 0, function() self:Tick() end)
		self:Stop()
	end
end

function ENT:Decrement(t)
	if SERVER then
		self.Timeleft = self.Timeleft - 1
		self:OnTimeChange()
	end
end

function ENT:Stop()
	if SERVER then
		timer.Stop(self.TimerID)
	end
end

function ENT:Start()
	if SERVER then
		self:TriggerOutput('OnStart', nil)
		timer.Start(self.TimerID)
		self:OnTimeChange()
	end
end

function ENT:Tick()
	if SERVER then
		if (self.Timeleft <= 0) then
			self:Stop()
			self:OnComplete()
			self:Destroy()
		else 
			self:Decrement()
		end
	end
end
--[[
function ENT:OnTimeChange()
	
end
--]]

function ENT:Destroy()
	if SERVER then
		timer.Destroy(self.TimerID)
		self:Remove()
	end
end

function ENT:AcceptInput(name, activator, caller, data)
	if (name == 'Start') then
		self:Start()
	end
end