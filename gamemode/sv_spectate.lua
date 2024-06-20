hook.Add('PlayerDeath', 'zmb_spec_PlayerDeath', function(ply)
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(GetAlivePlayers()[1])
end)

hook.Add('KeyPress', 'zmb_spec_KeyPress', function(ply, key)
	if (ply:Alive() == false) then
		if (key == IN_ATTACK) then
			for k, v in ipairs(GetAlivePlayers()) do
				if (v == ply:GetObserverTarget()) then
					if (GetAlivePlayers()[k+1] != nil) then
						ply:SpectateEntity(GetAlivePlayers()[k+1])
					else
						ply:SpectateEntity(GetAlivePlayers()[1])
					end
					break
				end
			end
		end
	end
end)

hook.Add('PlayerSpawn', 'zmb_PlayerSpawn', function(ply)
	print('sepec')
	ply:SpectateEntity(nil)
	ply:UnSpectate()
end)