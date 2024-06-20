local Player = FindMetaTable("Player") -- Get player metatable.
 
-- Set functions.
function Player:SetMoney(amount) if (tonumber(amount) != nil) then self:SetNWInt('Money', tonumber(amount)) end end
function Player:SetExperience(amount) if (tonumber(amount) != nil) then self:SetNWInt('Experience', amount) end end
function Player:SetKills(amount) if (tonumber(amount) != nil) then self:SetNWInt('Kills', amount) end end
function Player:SetPlayerGroup(amount) if (tonumber(amount) != nil) then self:SetNWInt('PlayerGroup', amount) end end

-- Get functions.
function Player:GetMoney() return tonumber(self:GetNWInt('Money', -1)) end
function Player:GetExperience()	return tonumber(self:GetNWInt('Experience', -1)) end
function Player:GetKills() return tonumber(self:GetNWInt('Kills', -1)) end
function Player:GetAdmin() return self:GetNWBool('IsAdmin', false) end
function Player:GetPlayerGroup() return tonumber(self:GetNWInt('PlayerGroup', 0)) end

-- Add functions.
function Player:AddMoney(amount) self:ConCommand('zmb_money_given '..amount) self:SetNWInt('Money', self:GetMoney() + amount) end
function Player:AddExperience(amount) self:SetNWInt('Experience', self:GetExperience() + amount) end
function Player:AddKills(amount) self:SetNWInt('Kills', self:GetKills() + amount) end


-- Save and load from db funcs.
if SERVER then
	function Player:SaveStats()
		if (ALLOW_DB == true) then
			if (self:GetMoney() > -1 && self:GetExperience() > -1) then
				print('Saving stats: '..tonumber(self:GetNWInt('money')))
				local c = mysqloo.connect(DB_IP, DB_LOGIN, DB_PASSWORD, DB_NAME, DB_PORT)
				c.onConnected = function(db)
					local q = db:query('UPDATE players SET nick = "'..self:Nick()..'", money = '..self:GetMoney()..', experience = '..self:GetExperience()..', player_group = '..self:GetPlayerGroup()..', is_admin = '..(self:GetAdmin() and 1 or 0)..' WHERE steamid = "'..self:SteamID()..'"')
					q:start()
				end
				function c:onConnectionFailed(err)
					print('Failed to connect to database.')
				end
				c:connect()
			end
		end
	end
end

function Player:IsReady() return self:GetNWBool('IsReady') end

-- Table: players
-- Columns: steamid VARCHAR(255), money INT, experience INT
hook.Add('Initialize', 'zmb_ply_Initialize', function()
	if SERVER then
		timer.Create('MoneySaveTimer', 30, 0, function()
			for k, ply in ipairs(player.GetAll()) do ply:SaveStats() end
		end)
	end
end)

hook.Add('PlayerAuthed', 'zmb_ply_PlayerAuthed', function(ply, steamID, uniqueID)
	if SERVER then
		ply:SetKills(0)
		ply:LoadStatsFromDatabase()
	end
end)


function Player:LoadStatsFromDatabase()
	if (ALLOW_DB == true) then
		local c = mysqloo.connect(DB_IP, DB_LOGIN, DB_PASSWORD, DB_NAME, DB_PORT)
		c.onConnected = function(db)
			local q = db:query('SELECT * FROM players WHERE steamid = "'..self:SteamID()..'"')
			q.onSuccess = function(query)
				if (q:getData()[1] != nil) then
					print('Existsing player connected: '..self:SteamID())
					print('Getting money: '..q:getData()[1]['money'])
					self:SetMoney(q:getData()[1]['money'])
					self:SetExperience(q:getData()[1]['experience'])
					self:SetPlayerGroup(q:getData()[1]['player_group'])
					self:SetNWBool('IsAdmin', q:getData()[1]['is_admin'] == 1)
				else
					print('New player connected: '..self:SteamID())
					local insert = db:query('INSERT INTO players VALUES ("'..self:SteamID()..'", "'..self:Nick()..'", "'..os.time()..'",'..STARTING_MONEY..', 0, 0, 0)')
					insert:start()
					self:SetMoney(STARTING_MONEY)
					self:SetExperience(0)
					self:SetPlayerGroup(0)
					self:SetNWBool('IsAdmin', false)
					
				end
			end
			function q:onError(err, sql)
				self:SetMoney(STARTING_MONEY)
				self:SetExperience(0)
				self:SetPlayerGroup(0)
					self:SetNWBool('IsAdmin', false)
			end
			q:start()
		end
		function c:onConnectionFailed(err)
			print('Failed to connect to database.')
		end
		c:connect()
	else
		self:SetMoney(STARTING_MONEY)
		self:SetExperience(0)
		self:SetPlayerGroup(0)
		self:SetNWBool('IsAdmin', false)
	end
end


if SERVER then
	function zmb_make_player_admin(ply, cmd, args)
		if (IsValid(ply) == true) then
			if (args[1] != nil && ply:GetAdmin() == true) then
				for k, v in ipairs(player.GetAll()) do
					if (player:SteamID() == args[1]) then
						v:SetNWBool('IsAdmin', true)
						v:SaveStats()
						break
					end
				end
			end
		end
	end
	concommand.Add("zmb_make_player_admin", zmb_make_player_admin)
end

--[[
hook.Add('PlayerDisconnected', 'zmb_ply_SaveStatsDisconnect', function(ply) if SERVER then ply:SaveStats() end end)
hook.Add('ShutDown', 'zmb_ply_SaveStatsShutDown', function()	for k, ply in ipairs(player.GetAll()) do if SERVER then ply:SaveStats() end end end)
--]]
hook.Add('ShutDown', 'zmb_ply_SaveStatsShutDown', function() timer.Remove('MoneySaveTimer') end)