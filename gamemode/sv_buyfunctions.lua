include('sh_shopitems.lua')

function zmb_buy_weapon(ply, cmd, args)
	if (GetGlobalBool('Playing') == false) then
		if (IsInsideTraderArea(ply)) then
			args[1] = tonumber(args[1])
			if (w[args[1]] != nil) then
				if (ply:GetNWString('Slot'..w[args[1]]['preferredslot']) == '') then
					if (ply:GetMoney() >= w[args[1]]['price']) then
						ply:Give(w[args[1]]['entity'])
						ply:GetWeapon(w[args[1]]['entity']).MaxAmmo = w[args[1]]['maxammo']
						ply:AddMoney(-w[args[1]]['price'])
						ply:EmitSound('zmb/buyitem.mp3')
					else
						ply:ConCommand('zmb_addhudmessage "Not enough money." 5')
					end
				else
					ply:ConCommand('zmb_addhudmessage "This slot is already taken." 5')
				end
			else
				print('Bad arguments for buy command!')
			end
		end
	end
end
concommand.Add("zmb_buy_weapon", zmb_buy_weapon)

function zmb_buy_ammo(ply, cmd, args)
	if (GetGlobalBool('Playing') == false) then
		if (IsInsideTraderArea(ply)) then
			args[1] = tonumber(args[1])
			if (w[args[1]] != nil) then
				local BulletsNeeded = w[args[1]]['maxammo'] - ply:GetAmmoCount(w[args[1]]['ammotype'])
				if (BulletsNeeded != 0) then
					if (math.ceil(BulletsNeeded * w[args[1]]['bulletprice']) <= ply:GetMoney() && ply:HasWeapon(w[args[1]]['entity']) == true) then
						ply:SetAmmo(w[args[1]]['maxammo'], w[args[1]]['ammotype'])
						ply:AddMoney(-math.ceil(BulletsNeeded * w[args[1]]['bulletprice']))
						ply:EmitSound('zmb/buyitem.mp3')
					else
						ply:ConCommand('zmb_addhudmessage "Not enough money." 5')
					end
				end
			else
				print('Bad arguments for buy command!')
			end
		end
	end
end
concommand.Add("zmb_buy_ammo", zmb_buy_ammo)

function zmb_fill_medkit(ply, cmd, args)
	if (GetGlobalBool('Playing') == false) then
		if (IsInsideTraderArea(ply)) then
			local FillNeeded = tonumber(ply:GetNWInt('MaxHealthCharge')) - tonumber(ply:GetNWInt('HealthCharge'))
			if (FillNeeded > 0) then
				if (math.ceil(FillNeeded * MEDKIT_PRICE) <= ply:GetMoney()) then
					ply:SetNWInt('HealthCharge', tonumber(ply:GetNWInt('MaxHealthCharge')))
					ply:AddMoney(-math.ceil(FillNeeded * MEDKIT_PRICE))
					ply:EmitSound('zmb/buyitem.mp3')
				else
					ply:ConCommand('zmb_addhudmessage "Not enough money." 5')
				end
			end
		end
	end
end
concommand.Add("zmb_fill_medkit", zmb_fill_medkit)