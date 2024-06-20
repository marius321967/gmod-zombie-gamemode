AddCSLuaFile()

ENT.Type = 'brush'
ENT.Base = 'base_brush'

function ENT:Touch(ent)
	if (ent.IsPlayer != nil) then
		if (ent:IsPlayer() == true) then
			if (ent:Alive() == true) then
				if (GetGlobalBool('Playing') == true) then
					for k, v in ipairs(ents.FindByClass('zmb_trader_pusher')) do
						if (v.TraderName == self:GetName()) then
							ent:SetPos(v:GetPos())
						end
					end
				end
			end
		end
	end
end