include('shared.lua')
include('sh_player.lua')
include('cl_menus.lua')
include('sh_playergroups.lua')

DrawableHUDs = {
	['CAchievementNotificationPanel'] = true,
	['CHudHealth'] = false,
	['CHudSuitPower'] = false,
	['CHudBattery'] = false,
	['CHudCrosshair'] = true,
	['CHudAmmo'] = false,
	['CHudSecondaryAmmo'] = true,
	['CHudChat'] = true,
	['CHudCloseCaption'] = true,
	['CHudCredits'] = true,
	['CHudDeathNotice'] = true,
	['CHudTrain'] = true,
	['CHudMessage'] = true,
	['CHudMenu'] = true,
	['CHudWeapon'] = true,
	['CHudWeaponSelection'] = false,
	['CHudGMod'] = true,
	['CHudDamageIndicator'] = true,
	['CHudHintDisplay'] = true,
	['CHudVehicle'] = true,
	['CHudVoiceStatus'] = true,
	['CHudVoiceSelfStatus'] = true,
	['CHudSquadStatus'] = true,
	['CHudZoom'] = true,
	['CHudCommentary'] = true,
	['CHudGeiger'] = true,
	['CHudHistoryResource'] = true,
	['CHudAnimationInfo'] = true,
	['CHUDAutoAim'] = true,
	['CHudFilmDemo'] = true,
	['CHudHDRDemo'] = true,
	['CHudPoisonDamageIndicator'] = true,
	['CPDumpPanel'] = true
}

local LastTimeMoneyEarned = 0
local LastTimeDamageReceived = 0
local LastMoneyEarned = 0

-- Make some fonts.
surface.CreateFont("Coolvetica16", {font = "coolvetica", size = 16, weight = 400, antialias = true, shadow = false})
surface.CreateFont("Coolvetica20", {font = "coolvetica", size = 20, weight = 400, antialias = true, shadow = false})
surface.CreateFont("Coolvetica26", {font = "coolvetica", size = 26, weight = 400, antialias = true, shadow = false})
surface.CreateFont("Coolvetica32", {font = "coolvetica", size = 32, weight = 400, antialias = true, shadow = false})
surface.CreateFont("Coolvetica64", {font = "coolvetica", size = 64, weight = 400, antialias = true, shadow = false})
surface.CreateFont("Coolvetica200", {font = "coolvetica", size = 200, weight = 400, antialias = true, shadow = false})
local HudMessages = {}

function GM:HUDShouldDraw(name)
	if (DrawableHUDs[name] != nil) then
		return DrawableHUDs[name]
	else 
		return true
	end
end

function GM:ScoreboardShow()
	RunConsoleCommand('zmb_showscoreboard')
end
function GM:ScoreboardHide()
	RunConsoleCommand('zmb_hidescoreboard')
end

function GM:RenderScreenspaceEffects()
	-- DrawMaterialOverlay( "spl/damagedoverlay", -0.5)
	local tab = {}
	tab[ "$pp_colour_addr" ] = 0
	tab[ "$pp_colour_addg" ] = 0
	tab[ "$pp_colour_addb" ] = 0.1
	tab[ "$pp_colour_brightness" ] = -0.17
	tab[ "$pp_colour_contrast" ] = 2
	tab[ "$pp_colour_colour" ] = 0.3
	tab[ "$pp_colour_mulr" ] = 0
	tab[ "$pp_colour_mulg" ] = 0
	tab[ "$pp_colour_mulb" ] = 0.3
	DrawColorModify( tab )
	-- DrawBloom(0.6, 0.75, 3, 3, 2, 3, 0, 0, 0 )
	-- DrawSharpen(20, 0.05)
end

function GM:HUDPaint()
	-- Draw black hud stripe.
	draw.RoundedBox(0, 0, ScrH()-80, ScrW(), 80, Color(0, 0, 0, 150))
	--- Draw dosh.
	draw.DrawText('$'..LocalPlayer():GetMoney(), 'Coolvetica32', 256, ScrH() - 64, Color(255, 255, 255), TEXT_ALIGN_LEFT)
	if (LastTimeMoneyEarned + 3 > CurTime()) then
		if (LastMoneyEarned >= 0) then
			draw.DrawText('+'..LastMoneyEarned, 'Coolvetica32', 256, ScrH() - 32, Color(255, 255, 255, (LastTimeMoneyEarned + 3 - CurTime()) / 3 * 255), TEXT_ALIGN_LEFT)
		else
			draw.DrawText(LastMoneyEarned, 'Coolvetica32', 256, ScrH() - 32, Color(255, 255, 255, (LastTimeMoneyEarned + 3 - CurTime()) / 3 * 255), TEXT_ALIGN_LEFT)
		end	
	end
	-- Draw health and armor.
	if (LocalPlayer():Armor() > 0) then
		draw.DrawText('HP '..LocalPlayer():Health(), 'Coolvetica32', 96, ScrH() - 64, Color(255, 255, 255), TEXT_ALIGN_LEFT)
		draw.DrawText('AR '..LocalPlayer():Armor(), 'Coolvetica32', 96, ScrH() - 32, Color(255, 255, 255), TEXT_ALIGN_LEFT)
	else
		draw.DrawText('HP '..LocalPlayer():Health(), 'Coolvetica64', 96, ScrH() - 64, Color(255, 255, 255), TEXT_ALIGN_LEFT)
	end
	
	draw.DrawText(tonumber(GetGlobalInt('Wave'))..' wave', 'Coolvetica32', 416, ScrH() - 64, Color(255, 255, 255), TEXT_ALIGN_LEFT)
	-- Draw hud messages if any.
	local cnt = table.Count(HudMessages)
	if (cnt > 0) then
		draw.RoundedBox(5, 32, 32, 400, cnt*30 + 16, Color(0, 0, 0, 128))
		for k, v in ipairs(HudMessages) do
			draw.DrawText(v['message'], "Coolvetica26", 40, 40 + (k-1)*30, Color(255, 255, 255), TEXT_ALIGN_LEFT)
			if (v['endtime'] < CurTime()) then
				table.remove(HudMessages, k)
			end
		end
	end
	
	local explosive = {
		x = 16,
		y = ScrH()-72,
		w = 64,
		h = 64
	}
	-- Draw cooldown time or enemy count.
	if (GetGlobalBool('Playing') == false) then -- Cooldown.
		draw.DrawText(tonumber(GetGlobalInt('CooldownTime')), "Coolvetica64", ScrW()/2, ScrH()-64, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		explosive['texture'] = surface.GetTextureID("spl/hazardyellow")
	else -- Wave.
		draw.DrawText(tonumber(GetGlobalInt('AliveNPCs')) + tonumber(GetGlobalInt('NPCsLeftToSpawn')), "Coolvetica64", ScrW()/2, ScrH()-64, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		explosive['texture'] = surface.GetTextureID("spl/hazardred")
	end
	draw.TexturedQuad(explosive)
	-- Draw other player.
	local tr = LocalPlayer():GetEyeTrace()
	if (tr.Entity:IsPlayer() == true) then
		if (tr.Entity:Alive() == true) then
			if (LocalPlayer():GetPos():Distance(tr.Entity:GetPos()) < 256) then
				draw.DrawText(tr.Entity:Nick(), 'Coolvetica32', ScrW()/2, ScrH()/2, Color(255, 255, 255), TEXT_ALIGN_CENTER)
				draw.DrawText('+'..tr.Entity:Health(), 'Coolvetica32', ScrW()/2, ScrH()/2 + 32, Color(255, 255, 255), TEXT_ALIGN_CENTER)
			end
		end
	end
	if (IsValid(LocalPlayer():GetActiveWeapon()) == true) then -- Check if player isn't empty handed, aka not ready.
		for i = 1, 5 do
			surface.SetTexture(surface.GetTextureID('spl/wep_triangle'))
			if (LocalPlayer():GetActiveWeapon():GetClass() == LocalPlayer():GetNWString('Slot'..i)) then
				surface.SetDrawColor(255, 255, 255, 100)
			else
				surface.SetDrawColor(255, 255, 255, 50)
			end
			surface.DrawTexturedRect(0, ScrH()-128-(i)*128, 96, 96)
			if (LocalPlayer():GetNWString('Slot'..i) != '') then
				surface.SetTexture(surface.GetTextureID('spl/'..LocalPlayer():GetNWString('Slot'..i)))
				surface.DrawTexturedRect(0, ScrH()-112-(i)*128, 64, 64)
			end
		end
	end
	if (LastTimeDamageReceived + 3 > CurTime()) then
		draw.TexturedQuad({x = 0, y = 0, w = ScrW(), h = ScrH(), texture = surface.GetTextureID("spl/damagedoverlay"), color = Color(255, 255, 255, (LastTimeDamageReceived + 3 - CurTime()) / 3 * 150)})
	end
end

function zmb_addhudmessage(ply, cmd, args)
	if (args[1] != nil && args[2] != nil) then
		HudMessages[table.Count(HudMessages)+1] = {['message'] = args[1], ['endtime'] = CurTime() + tonumber(args[2])}
	end
end
concommand.Add('zmb_addhudmessage', zmb_addhudmessage)

function zmb_money_given(ply, cmd, args)
	if (args[1] != nil) then
		LastTimeMoneyEarned = CurTime()
		LastMoneyEarned = tonumber(args[1])
	end
end
concommand.Add('zmb_money_given', zmb_money_given)

function zmb_damage_received(ply, cmd)
	LastTimeDamageReceived = CurTime()
end
concommand.Add('zmb_damage_received', zmb_damage_received)

function zmb_play_radio(ply, cmd, args)
	if (args[1] != nil) then
		sound.PlayURL(args[1], 'mono', function(station, err, errstr)
			print(errstr)
			if ( IsValid( station ) ) then
				print('ready to play')
				station:Play()
			else
				LocalPlayer():ChatPrint( "Invalid URL!" )
			end
		end)
	end
end
concommand.Add('zmb_play_radio', zmb_play_radio)

hook.Add('Think', 'zmb_ListenInput', function()
	if (IsValid(LocalPlayer():GetActiveWeapon()) == true) then
		if (input.IsKeyDown(KEY_1)) then
			if (LocalPlayer():GetActiveWeapon():GetClass() != LocalPlayer():GetNWString('Slot'..1)) then
				RunConsoleCommand('zmb_switch_weapon', 1)
			end
		elseif (input.IsKeyDown(KEY_2)) then
			if (LocalPlayer():GetActiveWeapon():GetClass() != LocalPlayer():GetNWString('Slot'..2)) then
				RunConsoleCommand('zmb_switch_weapon', 2)
			end
		elseif (input.IsKeyDown(KEY_3)) then
			if (LocalPlayer():GetActiveWeapon():GetClass() != LocalPlayer():GetNWString('Slot'..3)) then
				RunConsoleCommand('zmb_switch_weapon', 3)
			end
		elseif (input.IsKeyDown(KEY_4)) then
			if (LocalPlayer():GetActiveWeapon():GetClass() != LocalPlayer():GetNWString('Slot'..4)) then
				RunConsoleCommand('zmb_switch_weapon', 4)
			end
		elseif (input.IsKeyDown(KEY_5)) then
			if (LocalPlayer():GetActiveWeapon():GetClass() != LocalPlayer():GetNWString('Slot'..5)) then
				RunConsoleCommand('zmb_switch_weapon', 5)
			end
		end
	end
end)
hook.Add("PlayerBindPress", "zmb_DisableJump", function(ply, bind)
	if (string.find(bind, "+jump")) then return true end
end)