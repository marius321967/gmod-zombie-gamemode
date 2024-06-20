commands = {
	{title = 'Give 100 Dollars', func = function(ply) 
		local tr = ply:GetEyeTrace()
		if (tr.Entity:IsPlayer() == true) then
			if (tr.Entity:Alive() == true && tr.Entity:GetMoney() >= 100) then
				tr.Entity:AddMoney(100)
				ply:AddMoney(-100)
			end
		end
	end},
	{title = 'Drop Weapon', func = function(ply) 
		if (IsValid(ply:GetActiveWeapon()) == true) then
			if (ply:GetActiveWeapon().Primary.ClipSize > 0) then
				local weapon = ents.Create('zmb_pickupable_weapon')
				weapon:SetWeapon(ply:GetActiveWeapon():GetClass())
				weapon:SetViewModel(ply:GetActiveWeapon():GetModel())
				weapon:SetPos(ply:GetAttachment(ply:LookupAttachment('Chest')).Pos)
				weapon:Spawn()
				weapon.Clip = ply:GetActiveWeapon():Clip1()
				weapon:GetPhysicsObject():AddVelocity(ply:GetAimVector() * 200)
				ply:SetNWString('Slot'..ply:GetActiveWeapon().PreferredSlot, '')
				ply:StripWeapon(ply:GetActiveWeapon():GetClass())
			end
		end
	end}
}

--[[
hook.Add('PlayerSay', 'spl_ChatCommands', function(ply, message, public) 
	if (string.sub(message, 1, 1) == '!') then
		local command = ''
		local args = {}
		if (string.find(message, ' ') != nil) then
			command = string.sub(message, 2, string.find(message, ' ')-1)
			args = string.Explode(' ', string.sub(message, string.find(message, ' ')+1)) -- Find all substrings after that and split them into an array.
			for k, v in ipairs(args) do
				args[k] = string.lower(args[k])
			end
		else
			command = string.sub(message, 2)
		end
		if (commands[command] != nil) then
			commands[command](ply, args)
		else
			ply:PrintMessage(HUD_PRINTTALK, 'Unknown command')
		end
		return ''
	else
		return message
	end
	print(message)
end)
--]]