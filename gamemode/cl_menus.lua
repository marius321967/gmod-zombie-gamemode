include('sh_shopitems.lua')
include('sh_commands.lua')


function zmb_showscoreboard()
	ScoreboardFrame = vgui.Create('DFrame')
	ScoreboardFrame:SetSize(0, 0)
	ScoreboardFrame:MakePopup()
	Scoreboard = vgui.Create('DPanel')
	Scoreboard:SetSize(560, table.Count(player.GetAll()) * 40 + 128)
	Scoreboard:SetPos(ScrW()/2-290, 256)
	Scoreboard.Paint = function() -- Paint function
		--Set our rect color below us; we do this so you can see items added to this panel
		surface.SetDrawColor(255, 150, 0, 255) 
		surface.DrawRect(0, 0, Scoreboard:GetWide(), Scoreboard:GetTall()) -- Draw the rect
		surface.SetDrawColor(0, 0, 0, 255) 
		surface.DrawRect(2, 2, Scoreboard:GetWide()-4, Scoreboard:GetTall()-4) -- Draw the rect
		surface.SetDrawColor(85, 85, 85, 255) 
		surface.DrawRect(10, 96, Scoreboard:GetWide()-24, 4) -- Draw line.
		draw.DrawText(GetHostName(), 'Coolvetica32', 16, 16, Color(255, 255, 255), TEXT_ALIGN_LEFT)
		draw.DrawText('Players: '..table.Count(player.GetAll()), 'Coolvetica20', 16, 64, Color(255, 255, 255), TEXT_ALIGN_LEFT)
		local UpTime = math.floor(CurTime())
		draw.DrawText(math.floor(UpTime/60)..':'..UpTime-math.floor(UpTime/60)*60, 'Coolvetica20', 128, 64, Color(255, 255, 255), TEXT_ALIGN_LEFT)
		for k, v in ipairs(player.GetAll()) do
			draw.DrawText(v:Nick(), 'Coolvetica32', 32, 112+40*(k-1), Color(255, 255, 255), TEXT_ALIGN_LEFT)
			draw.DrawText(v:GetKills(), 'Coolvetica32', 300, 112+40*(k-1), Color(255, 255, 255), TEXT_ALIGN_LEFT)
			draw.DrawText('$'..v:GetMoney(), 'Coolvetica32', 360, 112+40*(k-1), Color(255, 255, 255), TEXT_ALIGN_LEFT)
			draw.DrawText(v:Ping(), 'Coolvetica32', 548, 112+40*(k-1), Color(255, 255, 255), TEXT_ALIGN_RIGHT)
		end
	end
	
	Commandboard = vgui.Create('DPanel')
	Commandboard:SetSize(560, 64)
	Commandboard:SetPos(ScrW()/2-290, 184)
	Commandboard.Paint = function() end
	for k, v in pairs(commands) do
		local Button = vgui.Create('DButton', Commandboard)
		Button:SetPos((k-1) * 1/table.Count(commands)*Commandboard:GetWide()+2, 0)
		Button:SetSize(1/table.Count(commands)*Commandboard:GetWide()-4, 48)
		Button:SetText(v['title'])
		Button.Paint = function()
			surface.SetDrawColor(255, 150, 0, 255) 
			surface.DrawRect(0, 0, Button:GetWide(), Button:GetTall()) -- Draw the rect
			surface.SetDrawColor(0, 0, 0, 255) 
			surface.DrawRect(2, 2, Button:GetWide()-4, Button:GetTall()-4) -- Draw the rect
		end
		Button.DoClick = function()
			RunConsoleCommand('zmb_exec_command', k)
		end
	end
end
function zmb_hidescoreboard()
	Scoreboard:Hide()
	ScoreboardFrame:Hide()
	Commandboard:Hide()
end
function zmb_showhelp() 
	local Frame = vgui.Create('DFrame')
	Frame:SetSize(600, 800)
	Frame:Center()
	Frame:SetTitle('Info')
	Frame:SetVisible( true )
	Frame:SetDraggable( true )
	Frame:ShowCloseButton( true )
	Frame:MakePopup()
	
	local Label = vgui.Create('DLabel', Frame)
	Label:SetPos(10,30)
	Label:SetText('Help Menu') 
	Label:SizeToContents()
	
	local EnemiesButton = vgui.Create('DButton', Frame)
	EnemiesButton:SetSize(100, 50)
	EnemiesButton:SetPos(10, 60)
	EnemiesButton:SetText('Enemies')
	EnemiesButton.DoClick = function(button)
		RunConsoleCommand('zmb_info_enemies')
	end
end
function zmb_showteam()
	local Frame = vgui.Create('DFrame')
	Frame:SetSize(200, 300)
	Frame:Center()
	Frame:SetTitle('Classes')
	Frame:SetVisible(true)
	Frame:SetDraggable(true)
	Frame:ShowCloseButton(false)
	Frame:MakePopup()
end
-- Zombi options.
function zmb_showspare1() end

-- F4
function zmb_showspare2() end

function zmb_menu_weapons(ply, cmd, args)
	local Selected = nil
	local WeaponsMenuFrame = vgui.Create('DFrame')
	WeaponsMenuFrame:SetSize(0, 0)
	WeaponsMenuFrame:MakePopup()
	
	local WeaponsMenu = vgui.Create('DPanel')
	WeaponsMenu:SetSize(560, math.ceil((table.Count(w))/5)*72+300)
	WeaponsMenu:SetPos(ScrW()/2-290, 200)
	WeaponsMenu.Paint = function() -- Paint function
		--Set our rect color below us; we do this so you can see items added to this panel
		surface.SetDrawColor(255, 150, 0) 
		surface.DrawRect(0, 0, WeaponsMenu:GetWide(), WeaponsMenu:GetTall()) -- Draw the rect
		surface.SetDrawColor(0, 0, 0) 
		surface.DrawRect(2, 2, WeaponsMenu:GetWide()-4, WeaponsMenu:GetTall()-4) -- Draw the rect
		draw.DrawText('Weapons', 'Coolvetica32', 16, 16, Color(255, 255, 255), TEXT_ALIGN_LEFT)
		surface.SetDrawColor(85, 85, 85, 255) 
		surface.DrawRect(10, 64, WeaponsMenu:GetWide()-24, 4) -- Draw line.
		surface.DrawRect(10, 256, WeaponsMenu:GetWide()-24, 4) -- Draw line.
		if (Selected != nil) then -- We have a selected weapon.
			draw.DrawText(w[Selected]['name'], 'Coolvetica20', 20, 80, Color(255, 255, 255), TEXT_ALIGN_LEFT)
			surface.SetTexture(surface.GetTextureID('spl/'..w[Selected]['entity']))
			surface.SetDrawColor(150, 150, 150)
			surface.DrawTexturedRect(20, 96, 128, 128)
			-- PWR
			surface.SetDrawColor(85, 85, 85)
			surface.DrawRect(164, 100, 204, 16)
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(166, 102, w[Selected]['power']*2, 12)
			draw.DrawText('PWR', 'Coolvetica16', 167, 101, Color(85, 85, 85), TEXT_ALIGN_LEFT)
			-- ACC
			surface.SetDrawColor(85, 85, 85)
			surface.DrawRect(164, 120, 204, 16)
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(166, 122, w[Selected]['accuracy'], 12)
			draw.DrawText('ACC', 'Coolvetica16', 167, 121, Color(85, 85, 85), TEXT_ALIGN_LEFT)
			-- SPD
			surface.SetDrawColor(85, 85, 85)
			surface.DrawRect(164, 140, 204, 16)
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(166, 142, w[Selected]['speed'], 12)
			draw.DrawText('SPD', 'Coolvetica16', 167, 141, Color(85, 85, 85), TEXT_ALIGN_LEFT)
			-- CLIP
			surface.SetDrawColor(85, 85, 85)
			surface.DrawRect(164, 160, 204, 16)
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(166, 162, w[Selected]['clipsize']*4, 12)
			draw.DrawText('CLIP', 'Coolvetica16', 167, 161, Color(85, 85, 85), TEXT_ALIGN_LEFT)
		end
	end
	local CloseButton = vgui.Create('DButton', WeaponsMenu)
	CloseButton:SetPos(WeaponsMenu:GetWide()-20, 0)
	CloseButton:SetSize(20, 20)
	CloseButton:SetText('X')
	CloseButton.Paint = function()
		surface.SetDrawColor(85, 85, 85)
		surface.DrawRect(0, 2, CloseButton:GetWide()-2, CloseButton:GetTall()-2) -- Draw the rect
		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(2, 2, CloseButton:GetWide()-4, CloseButton:GetTall()-4) -- Draw the rect
	end
	CloseButton.DoClick = function()
		WeaponsMenu:Hide()
		WeaponsMenuFrame:Hide()
	end
	local BuyButton = vgui.Create('DButton', WeaponsMenu)
	BuyButton:SetPos(WeaponsMenu:GetWide() - 148, 96)
	BuyButton:SetSize(128, 64)
	BuyButton:SetText('Buy')
	BuyButton.Paint = function()
		surface.SetDrawColor(85, 85, 85)
		surface.DrawRect(0, 0, BuyButton:GetWide(), BuyButton:GetTall()) -- Draw the rect
		surface.SetDrawColor(0, 0, 0) 
		surface.DrawRect(2, 2, BuyButton:GetWide()-4, BuyButton:GetTall()-4) -- Draw the rect
	end
	BuyButton.DoClick = function()
		if (Selected != nil) then
			RunConsoleCommand('zmb_buy_weapon', Selected)
		end
	end
	local AmmoButton = vgui.Create('DButton', WeaponsMenu)
	AmmoButton:SetPos(WeaponsMenu:GetWide() - 148, 168)
	AmmoButton:SetSize(128, 64)
	AmmoButton:SetText('Fill Ammo')
	AmmoButton.Paint = function()
		surface.SetDrawColor(85, 85, 85)
		surface.DrawRect(0, 0, AmmoButton:GetWide(), AmmoButton:GetTall()) -- Draw the rect
		surface.SetDrawColor(0, 0, 0) 
		surface.DrawRect(2, 2, AmmoButton:GetWide()-4, AmmoButton:GetTall()-4) -- Draw the rect
	end
	AmmoButton.DoClick = function()
		if (Selected != nil) then
			RunConsoleCommand('zmb_buy_ammo', Selected)
			timer.Simple(0.8, function()
				AmmoButton:SetText('Fill Ammo ($'..math.ceil((w[Selected]['maxammo'] - ply:GetAmmoCount(w[Selected]['ammotype'])) * w[Selected]['bulletprice'])..')')
			end)
		end
	end
	
	local FillMedkitButton = vgui.Create('DButton', WeaponsMenu)
	FillMedkitButton:SetPos(WeaponsMenu:GetWide() - 200, 20)
	FillMedkitButton:SetSize(128, 32)
	if (tonumber(ply:GetNWInt('MaxHealthCharge')) - tonumber(ply:GetNWInt('HealthCharge')) > 0) then
		FillMedkitButton:SetText('Fill Medkit ($'..math.ceil((tonumber(ply:GetNWInt('MaxHealthCharge')) - tonumber(ply:GetNWInt('HealthCharge'))) * tonumber(GetGlobalInt('MEDKIT_PRICE')))..')')
	else
		FillMedkitButton:SetText('Fill Medkit')
	end
	FillMedkitButton.Paint = function()
		surface.SetDrawColor(85, 85, 85)
		surface.DrawRect(0, 0, FillMedkitButton:GetWide(), FillMedkitButton:GetTall()) -- Draw the rect
		surface.SetDrawColor(0, 0, 0) 
		surface.DrawRect(2, 2, FillMedkitButton:GetWide()-4, FillMedkitButton:GetTall()-4) -- Draw the rect
	end
	FillMedkitButton.DoClick = function()
		RunConsoleCommand('zmb_fill_medkit')
		timer.Simple(0.8, function()
			if (tonumber(ply:GetNWInt('MaxHealthCharge')) - tonumber(ply:GetNWInt('HealthCharge')) > 0) then
				FillMedkitButton:SetText('Fill Medkit ($'..math.ceil((tonumber(ply:GetNWInt('MaxHealthCharge')) - tonumber(ply:GetNWInt('HealthCharge'))) * tonumber(GetGlobalInt('MEDKIT_PRICE')))..')')
			else
				FillMedkitButton:SetText('Fill Medkit')
			end
		end)
	end
	
	for k, value in pairs(w) do -- For each weapon.
		local Panel = vgui.Create('DButton', WeaponsMenu)
		Panel:SetSize(96, 64)
		Panel:SetPos(-math.floor((k-1)/5)*5*104 + (k-1)*104+20, math.floor((k-1)/5)*72+288)
		Panel.Paint = function()
			surface.SetDrawColor(85, 85, 85) 
			surface.DrawRect(0, 0, Panel:GetWide(), Panel:GetTall())
			surface.SetDrawColor(0, 0, 0) 
			surface.DrawRect(2, 2, Panel:GetWide()-4, Panel:GetTall()-4)
			surface.SetTexture(surface.GetTextureID('spl/'..value['entity']))
			surface.SetDrawColor(150, 150, 150)
			surface.DrawTexturedRect(16, 0, 64, 64)
		end
		Panel.DoClick = function()
			Selected = k
			BuyButton:SetText('Buy ($'..w[Selected]['price']..')')
			AmmoButton:SetText('Fill Ammo ($'..math.ceil((w[Selected]['maxammo'] - ply:GetAmmoCount(w[Selected]['ammotype'])) * w[Selected]['bulletprice'])..')')
		end
		Panel:SetText('')
	end
end

function zmb_info_enemies()
	local Frame = vgui.Create('DFrame')
	Frame:SetSize(1000, 800) -- Size Frame
	Frame:Center()
	Frame:SetTitle('Info - Enemies') -- Frame set name
	Frame:SetVisible(true) -- Frame rendered ( true or false )
	Frame:SetDraggable(true) -- Frame draggable
	Frame:ShowCloseButton(true) -- Show buttons panel
	Frame:MakePopup()
	
	local Title = vgui.Create('DLabel', Frame)
	Title:SetPos(30,50)
	Title:SetText('The Enemies')
	Title:SetFont('Coolvetica64')
	Title:SizeToContents()
end

function zmb_menu_init()
	InitFrame = vgui.Create('DFrame')
	InitFrame:SetSize(0, 0)
	InitFrame:SetVisible(true)
	InitFrame:MakePopup()
	
	InitPanel = vgui.Create('DPanel')
	InitPanel:SetSize(560, 700)
	InitPanel:SetPos(ScrW()/2-290, 256)
	InitPanel.Paint = function()
		surface.SetDrawColor(255, 150, 0, 255) 
		surface.DrawRect(0, 0, InitPanel:GetWide(), InitPanel:GetTall())
		surface.SetDrawColor(0, 0, 0, 255) 
		surface.DrawRect(2, 2, InitPanel:GetWide()-4, InitPanel:GetTall()-4)
		for k, v in ipairs(player.GetAll()) do
			if (v:GetNWBool('IsReady') == true) then
				draw.DrawText(v:Nick(), 'Coolvetica32', 16, 128+34*(k-1), Color(0, 150, 0), TEXT_ALIGN_LEFT)
			else
				draw.DrawText(v:Nick(), 'Coolvetica32', 16, 128+34*(k-1), Color(255, 0, 0), TEXT_ALIGN_LEFT)
			end
		end
	end
	local StartButton = vgui.Create('DButton', InitPanel)
	StartButton:SetSize(InitPanel:GetWide()-20, 64)
	StartButton:SetPos(10, 10)
	StartButton:SetText('I\'m ready')
	StartButton.Paint = function()
		surface.SetDrawColor(255, 150, 0) 
		surface.DrawRect(0, 0, StartButton:GetWide(), StartButton:GetTall())
		surface.SetDrawColor(255, 255, 255) 
		surface.DrawRect(2, 2, StartButton:GetWide()-4, StartButton:GetTall()-4)
	end
	StartButton.DoClick = function(button)
		RunConsoleCommand('zmb_player_ready')
	end
end

function zmb_menu_init_close()
	if (InitFrame != nil) then
		InitFrame:Hide()
	end
	if (InitPanel != nil) then
		InitPanel:Hide()
	end
end

concommand.Add('zmb_showscoreboard', zmb_showscoreboard)
concommand.Add('zmb_hidescoreboard', zmb_hidescoreboard)
concommand.Add('zmb_showhelp', zmb_showhelp)
concommand.Add('zmb_showteam', zmb_showteam)
concommand.Add('zmb_showspare1', zmb_showspare1)
concommand.Add('zmb_showspare2', zmb_showspare2)
concommand.Add('zmb_info_classes', zmb_info_classes)
concommand.Add('zmb_info_enemies', zmb_info_enemies)
concommand.Add('zmb_menu_weapons', zmb_menu_weapons)
concommand.Add('zmb_menu_init', zmb_menu_init)
concommand.Add('zmb_menu_init_close', zmb_menu_init_close)