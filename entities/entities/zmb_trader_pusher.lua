AddCSLuaFile()

ENT.Type 				= 'point'
ENT.Base 				= 'base_point'

function ENT:KeyValue(key, value)
	if (string.lower(key) == 'tradername') then
		self.TraderName = value
	end
end