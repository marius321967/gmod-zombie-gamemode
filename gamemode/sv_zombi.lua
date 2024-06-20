AddCSLuaFile('sh_shopitems.lua')
AddCSLuaFile('cl_menus.lua')
AddCSLuaFile('sh_player.lua')
AddCSLuaFile('sh_commands.lua')
AddCSLuaFile('sh_playergroups.lua')

require("mysqloo")


include('sv_database.lua')
include('sv_dropitems.lua')
include('sh_player.lua')
include('sh_shopitems.lua')
include('sv_menus.lua')
include('sv_buyfunctions.lua')
include('sh_commands.lua')
include('sv_wavenpcs.lua')
include('sv_randomtips.lua')
include('sh_playergroups.lua')
-- include('sv_spectate.lua')
hook.Add('Initialize', 'zmb_CheckDatabase', function()
	if (ALLOW_DB == true) then
		db_connection = mysqloo.connect(DB_IP, DB_LOGIN, DB_PASSWORD, DB_NAME, DB_PORT)
		db_connection.onConnected = function(db)
			print('Successfully connected to database.')
			--[[
			local q = db:query('SELECT * FROM players WHERE 1')
			function q:onError(err, sql)
				print('Table not found: players')
				db_query('CREATE TABLE players (steamid VARCHAR(255), nick VARCHAR(255), joined INT, money INT, experience INT, player_group INT, is_admin INT)')
			end
			q:start()
			--]]
		end
		db_connection.onConnectionFailed = function(db, err)
			print('Failed to connect to database.')
		end
		db_connection:connect()
	end
end)

-- Put content from given folders up for clients to download.
CONTENT_FOLDERS = {
	'materials/spl/',
	'sound/zmb/',
	'sound/zmb/enemies/zombie/',
	'sound/zmb/weapons/p90/',
	'sound/zmb/weapons/famas/',
	'sound/zmb/weapons/glock/',
	'sound/zmb/weapons/awp/',
	'sound/zmb/weapons/deagle/',
	'sound/zmb/weapons/ak74/',
	'sound/zmb/weapons/m3/'
}
for k, v in ipairs(CONTENT_FOLDERS) do
	for k2, v2 in ipairs(file.Find('gamemodes/zombi/content/'..v..'*', 'MOD')) do
		resource.AddFile(v..v2)
	end
end
team.SetUp(1, 'Players', Color(0, 0, 0), true)


hook.Add('KeyPress', 'zmb_KeyPress', function(ply, key) 
	if (key == IN_USE) then
		if (GetGlobalBool('Playing') == false && ply:IsReady() == true && ply:Alive() == true) then
			local area = IsInsideTraderArea(ply)
			if (area != nil) then
				ply:ConCommand('zmb_menu_weapons')
			end
		end
	end
end)

hook.Add('PlayerConnect', 'zmb_PlayerConnect', function(name, ip)
	SendAllPlayersMessage(name..' is connecting.', 5)
end)
hook.Add('PlayerFootstep', 'zmb_PlayerFootstep', function(ply, pos, foot, sound, volume, rf )
	ply:EmitSound('npc/metropolice/gear'..math.random(1, 6)..'.wav', 25)
	return false -- Don't allow default footsteps
end)

hook.Add('PlayerInitialSpawn', 'zmb_PlayerInitialSpawn', function(ply)
	ply:ConCommand('zmb_addhudmessage "Welcome to Zombi! Enjoy your stay." 10')
	ply:ConCommand('zmb_menu_init')
end)

hook.Add('PlayerSpawn', 'zmb_PlayerSpawn', function(ply)
	ply:SetRunSpeed(player_groups[ply:GetPlayerGroup()]['walkspeed'])
	ply:SetWalkSpeed(player_groups[ply:GetPlayerGroup()]['walkspeed'])
	ply:SetJumpPower(0)
	ply:SetHealth(player_groups[ply:GetPlayerGroup()]['maxhealth'])
	ply:SetFOV(100, 0)
	ply:UnSpectate()
	ply:SetNoCollideWithTeammates(true)
	if (ply:IsReady() == true) then
		ply:SetModel('models/player/police.mdl')
		ply:Give('zmb_knife')
		ply:Give('zmb_medkit')
		ply:SetNWInt('MaxHealthCharge', 200)
		ply:SetNWInt('HealthCharge', tonumber(ply:GetNWInt('MaxHealthCharge')))
		ply:Give('zmb_glock')
		ply:SetAmmo(ply:GetWeapon('zmb_glock').MaxAmmo, 'Pistol')
		ply:GetWeapon('zmb_glock'):SetClip1(ply:GetWeapon('zmb_glock').Primary.ClipSize)
		ply:SelectWeapon('zmb_glock')
	end
end)

hook.Add('PlayerShouldTakeDamage', 'zmb_PlayerShouldTakeDamage', function(ply, attacker)
	if (attacker:IsPlayer() == true) then
		return false
	else
		return true
	end
end)

function PlayRadio(url)
	for k, v in ipairs(player.GetAll()) do
		v:ConCommand('zmb_play_radio '..url)
	end
end

hook.Add('PlayerDeath', 'zmb_PlayerDeath', function(ply)
	ply:Spectate(OBS_MODE_ROAMING)
	ply:SpectateEntity(nil)
	ply:SetNWString('Slot1', '')
	ply:SetNWString('Slot2', '')
	ply:SetNWString('Slot3', '')
	ply:SetNWString('Slot4', '')
	ply:SetNWString('Slot5', '')
	ply:EmitSound('npc/metropolice/die1.wav', 50)
	SendAllPlayersMessage(ply:Nick()..' has died.', 5)
	if (GetGlobalBool('Playing') == true) then
		if (table.Count(GetAlivePlayers()) <= 1) then -- No more alive players.
			timer.Simple(3, function()
				GameOver()
			end)
		end
	end
	ply:SaveStats()
	--[[
	local wep = ply:GetActiveWeapon()
	local weapon = ents.Create('zmb_pickupable_weapon')
	weapon:SetWeapon(wep:GetClass())
	weapon:SetViewModel(wep:GetModel())
	weapon:SetPos(ply:GetAttachment(ply:LookupAttachment('Chest')).Pos)
	weapon:Spawn()
	weapon.Clip = wep:Clip1()
	weapon:GetPhysicsObject():AddVelocity(Vector(math.random(-200, 200), math.random(-200, 200), math.random(200, 400)))
	--]]
end)

hook.Add('PlayerDeathThink', 'zmb_PlayerDeathThink', function(ply)
	if (GetGlobalBool('Playing') == true) then
		return false
	elseif (ply:IsReady() == true) then
		ply:Spawn()
	else
		return false
	end
end)
hook.Add('PlayerAuthed', 'zmb_PlayerAuthed', function(ply, steamid, uniqueid)
	ply:SetNWBool('IsReady', false)
end)

function zmb_player_ready(ply, cmd, args)
	if (ply:IsReady() == false) then
		ply:SetNWBool('IsReady', true)
		SendAllPlayersMessage(ply:Nick()..' is ready.', 5)
		if (GetGlobalBool('GameStarted') == false && table.Count(GetReadyPlayers())/table.Count(player.GetAll()) >= 0.5) then
			EndWave(true) -- Start first wave preparations.
			SetGlobalBool('GameStarted', true)
			for k, v in ipairs(GetReadyPlayers()) do
				v:ConCommand('zmb_menu_init_close')
			end
		elseif (GetGlobalBool('GameStarted') == true) then
			ply:ConCommand('zmb_menu_init_close')
			if (GetGlobalBool('Playing') == true) then
				ply:ConCommand('zmb_addhudmessage "You will respawn when the wave is over." 10')
			end
		end
		if (ply:Alive() == true) then
			ply:KillSilent()
		end
	end
end
concommand.Add("zmb_player_ready", zmb_player_ready)

function zmb_switch_weapon(ply, cmd, args)
	if (ply:Alive() == true && ply:IsReady() == true) then
		if (args[1] != nil) then
			if (ply:HasWeapon(ply:GetNWString('Slot'..tonumber(args[1]))) == true) then
				ply:SelectWeapon(ply:GetNWString('Slot'..tonumber(args[1])))
			end
		end
	end
end
concommand.Add("zmb_switch_weapon", zmb_switch_weapon)

hook.Add('PlayerDisconnected', 'zmb_PlayerDisconnected', function(ply) -- Player disconnected.
	SendAllPlayersMessage(ply:Nick()..' has disconnected.', 5)
	if (table.Count(player.GetAll()) <= 1) then
		game.LoadNextMap()
	elseif (GetGlobalBool('GameStarted') == false && table.Count(GetReadyPlayers())/table.Count(player.GetAll()) >= 0.5) then -- If we were at ready screen.
		EndWave(true) -- Start first wave preparations.
		for k, v in ipairs(player.GetAll()) do
			ply:ConCommand('zmb_menu_init_close')
		end
	elseif (table.Count(GetAlivePlayers()) <= 1) then -- If there was more than one player in server, but the disconnecting one was last last alive.
		GameOver()
	end
end)

hook.Add('Initialize', 'zmb_Initialize', function()
	-- Set some networked data that users will need.
	SetGlobalInt('Wave', 1)
	SetGlobalInt('MEDKIT_PRICE', MEDKIT_PRICE)
	SetGlobalBool('Playing', false) -- No waves in progress. Currently we're in a cooldown.	
	SetGlobalBool('GameStarted', false) -- No waves in progress. Currently we're in a cooldown.	
	
	timer.Create('SpawnTimer', SPAWN_INTENSITY, 0, function() Spawn() end)
	timer.Create('RandomTips', 120, 0, function() 
		for k, txt in ipairs(tips[math.random(1, table.Count(tips))]) do
			SendAllPlayersMessage(txt, 10)
		end
	end)
	timer.Stop('SpawnTimer')
end)

hook.Add('InitPostEntity', 'zmb_InitPostEntity', function()
	if (table.Count(ents.FindByClass('zmb_npc_spawner')) > 0) then
		Spawners = ents.FindByClass('zmb_npc_spawner')
	end
end)
hook.Add('PlayerHurt', 'zmb_DamageIndicator', function(ply, attacker)
	if (math.random(1, 2) == 1) then
		ply:EmitSound('npc/metropolice/pain'..math.random(1, 4)..'.wav', 50)
	end
	ply:ConCommand('zmb_damage_received')
end)


function GM:CanPlayerSuicide(ply) return true end
function GM:PlayerDeathSound() return true end
function GM:PlayerSwitchFlashlight(ply, on) return ENABLE_FLASHLIGHT end
function GM:PlayerNoClip(ply) return ENABLE_NOCLIP end

function SpawnNPC()
	if (tonumber(GetGlobalInt('NPCsLeftToSpawn')) > 0) then
		if (table.Count(ents.FindByClass('zmb_enemy_*')) < table.Count(player.GetAll()) * 40) then
			local j = math.random(1, 100)
			local LastMatch = nil
			for k, v in ipairs(npcs) do
				if (j > v['chance']) then 
					break
				else
					LastMatch = v
				end
			end
			local npc = ents.Create(LastMatch['entity'])
			npc:SetPos(ents.FindByClass('zmb_npc_spawner')[math.random(1, table.getn(ents.FindByClass('zmb_npc_spawner')))]:GetPos())
			npc:Spawn()
		end
	else
		StopSpawning()
	end
end

function StartWave()
	SendAllPlayersMessage('Wave '..GetGlobalInt('Wave')..' beginning. Be prepared.', 5)
	for k, v in ipairs(ents.FindByName('TraderDoor')) do
		v:Fire('Close', nil, 0)
	end
	SpawnItems()
	local Players = player.GetAll()
	for i = 1, table.Count(Players) do
		Players[i]:ConCommand('play zmb/startwave'..math.random(1, 4)..'.mp3')
	end
	SetGlobalInt('NPCsLeftToSpawn', math.min(DIFFICULTY * table.Count(GetAlivePlayers()), MAX_ENEMIES_WAVE) + tonumber(GetGlobalInt('NPCsLeftToSpawn')))
	if (table.Count(Spawners) > 0) then
		timer.Create('SpawnerTimer', SPAWN_INTENSITY, 0, function() 
			SpawnNPC()
		end)
	end
	SetGlobalBool('Playing', true)
end

function EndWave(FirstWave)
	for k, v in ipairs(ents.FindByName('TraderDoor')) do
		v:Fire('Open', nil, 0)
	end
	if (FirstWave == false) then
		for k, ply in ipairs(player.GetAll()) do
			ply:ConCommand('play npc/overwatch/radiovoice/leadersreportratios.wav')
		end
		SendAllPlayersMessage('Wave finished! Get to the nearest', 20)
		SendAllPlayersMessage('trader spot (yellow doors) and press E.', 20)
	else
		for k, ply in ipairs(player.GetAll()) do
			ply:ConCommand('play npc/overwatch/radiovoice/restrictedincursioninprogress.wav')
		end
	end
	timer.Simple(2, function() 
		if (FirstWave == false) then
			DIFFICULTY = math.ceil(DIFFICULTY * 1.2)
			SetGlobalInt('Wave', tonumber(GetGlobalInt('Wave')) + 1)
		end
		timer.Stop('SpawnerTimer')
		SetGlobalBool('Playing', false)
		
		local CooldownTimer = ents.Create('zmb_timer')
		CooldownTimer:SetName('CooldownTImer')
		if (FirstWave == true) then
			CooldownTimer.Timeleft = 5
		else
			CooldownTimer.Timeleft = COOLDOWN_LENGTH
		end
		function CooldownTimer:OnTimeChange()
			SetGlobalInt('CooldownTime', CooldownTimer.Timeleft)
		end
		function CooldownTimer:OnComplete()
			StartWave()
		end
		CooldownTimer:Spawn()
		CooldownTimer:Start()
	end)
end


function GameOver()
	SendAllPlayersMessage('All players have died. Game over.', 10)
	for k, v in ipairs(player.GetAll()) do
		v:ConCommand('play npc/overwatch/radiovoice/failuretotreatoutbreak.wav')
	end
	timer.Simple(5, function() -- Wait 5 seconds, then lock player movement and change map
		for k, v in ipairs(player.GetAll()) do
			v:Lock()
			v:ConCommand('zmb_showscoreboard')
		end
		timer.Simple(15, game.LoadNextMap)
	end)
	for k, v in ipairs(ents.FindByClass('zmb_enemy_*')) do
		v.IsFrozen = true
	end
end

function SpawnItems() -- That is an unnecessarily long function.
	-- Find all available item spawn locations.
	local AvailableItemSpawners = ents.FindByClass('zmb_item_spawner')
	local UnavailableItemSpawners = {}
	for k, v in ipairs(ents.FindByClass('zmb_item_spawner')) do
		for k2, v2 in ipairs(ents.FindInSphere(v:GetPos(), 100)) do
			if (v2.GetClass != nil) then
				if (v2:GetClass() == 'zmb_pickupable_weapon' || v2:GetClass() == 'zmb_ammo_box') then
					UnavailableItemSpawners[table.getn(UnavailableItemSpawners)+1] = k
					break
				end
			end
		end
	end
	table.sort(UnavailableItemSpawners, function (a, b)
      return (a > b)
    end)
	for k, v in ipairs(UnavailableItemSpawners) do
		table.remove(AvailableItemSpawners, v)
	end
	-- Now we know which item spawners are not occupied with previously spawned items.
	if (table.getn(AvailableItemSpawners) > 0) then
		local k = math.min(table.getn(AvailableItemSpawners), ITEM_SPAWN * table.Count(GetAlivePlayers()))
		for i=1, k, 1 do
			if (table.getn(AvailableItemSpawners) < 1) then return end
			-- Right here we know fosho that we're going to spawn an item.
			-- Find out which location to spawn at.
			local index = 1
			if (table.Count(AvailableItemSpawners) > 1) then
				index = math.random(1, table.Count(AvailableItemSpawners))
			end
			-- Here we know exactly where we're going to spawn it.
			if (math.random(1, 5) == 0) then -- 20% chance to spawn a weapon.
				local j = math.random(1, 100)
				local LastMatch = nil
				for k, v in ipairs(d_w) do
					if (j > v['chance']) then 
						break
					else
						LastMatch = v
					end
				end
				local weapon = ents.Create('zmb_pickupable_weapon')
				weapon:SetWeapon(LastMatch['entity'])
				weapon:SetViewModel(LastMatch['model'])
				weapon:SetPos(AvailableItemSpawners[index]:GetPos())
				weapon:Spawn()
			else -- Otherwise spawn ammo.
				local ammo = ents.Create('zmb_ammo_box')
				ammo:SetPos(AvailableItemSpawners[index]:GetPos())
				ammo:Spawn()
			end
			table.remove(AvailableItemSpawners, index)
		end
	end
end


function zmb_exec_command(ply, cmd, args)
	if (args[1] != nil) then
		if (tonumber(args[1]) != nil) then
			commands[tonumber(args[1])]['func'](ply)
		end
	end
end
concommand.Add("zmb_exec_command", zmb_exec_command)

-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
-- Less typing.
function StartSpawning()
	timer.Start('SpawnTimer')
end
function StopSpawning()
	timer.Stop('SpawnTimer')
end
function DecrementAliveNPCs()
	SetGlobalInt('AliveNPCs', GetGlobalInt('AliveNPCs') - 1)
	local AlivePlayer = false
	for k, ply in ipairs(player.GetAll()) do
		if (ply:Alive() == true) then
			AlivePlayer = true
			break
		end
	end
	if (tonumber(GetGlobalInt('AliveNPCs')) + tonumber(GetGlobalInt('NPCsLeftToSpawn')) == 0 && table.Count(GetAlivePlayers()) > 0 && GetGlobalBool('Playing') == true) then
		EndWave(false)
	end
end
function IncrementAliveNPCs()
	SetGlobalInt('AliveNPCs', tonumber(GetGlobalInt('AliveNPCs')) + 1)
end
function DecrementNPCsLeftToSpawn()
	if (tonumber(GetGlobalInt('NPCsLeftToSpawn')) > 0) then
		SetGlobalInt('NPCsLeftToSpawn', tonumber(GetGlobalInt('NPCsLeftToSpawn')) - 1)
	end
end
function SetNPCsLeftToSpawn(i)
	SetGlobalInt('NPCsLeftToSpawn', i)
end
function IsInsideTraderArea(ply)
	for k2, area in ipairs(ents.FindByClass('zmb_trader_area')) do
		local a_min, a_max = area:GetCollisionBounds()
		if (ply:GetPos().x > a_min.x && ply:GetPos().y > a_min.y && ply:GetPos().z > a_min.z && ply:GetPos().x < a_max.x && ply:GetPos().y < a_max.y && ply:GetPos().z < a_max.z) then
			return area
		end
	end
	return nil
end
function IsEnemy(ent) if (string.find(ent:GetClass(), 'zmb_enemy_') != nil) then return true else return false end end
function GetAlivePlayers()
	local alive = {}
	for k, ply in ipairs(player.GetAll()) do
		if (ply:Alive() == true && ply:GetNWBool('IsReady') == true) then
			alive[table.Count(alive) + 1] = ply
		end
	end
	return alive
end
function GetDeadPlayers()
	local dead = {}
	for k, ply in ipairs(player.GetAll()) do
		if (ply:Alive() == false) then
			dead[table.Count(dead) + 1] = ply
		end
	end
	return dead
end
function GetReadyPlayers()
	local ready = {}
	for k, ply in ipairs(player.GetAll()) do
		if (ply:IsReady() == true) then
			ready[table.Count(ready) + 1] = ply
		end
	end
	return ready
end
function GetClosest(ent, arr)
	local Closest = nil
	for k, v in ipairs(arr) do
		if (v != ent) then
			if (Closest == nil) then
				Closest = v
			elseif (ent:GetPos():Distance(Closest:GetPos()) > ent:GetPos():Distance(v:GetPos())) then
				Closest = v
			end
		else
			return nil
		end
	end
	return Closest
end
function SendAllPlayersMessage(m, l)
	for k, ply in ipairs(player.GetAll()) do
		ply:ConCommand('zmb_addhudmessage "'..m..'" '..l..'')
	end
end