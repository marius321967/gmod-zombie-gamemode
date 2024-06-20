AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')


STARTING_MONEY = 250 -- Starting money for each new player.
COOLDOWN_LENGTH = 60 -- Time between waves in seconds.
MAX_ENEMIES_WAVE = 300 -- Maximum amount of zombies in wave.
ITEM_SPAWN = 2 -- How many items to spawn for each player at the beginning of each wave.
NUM_WAVES = 10 -- How many waves we will have to survive to win the game.
DIFFICULTY = 12 -- Difficulty variable. Will increase with each wave. Used to calculate toughness of enemies.
DIFFICULTY_RATIO = 1.3 -- How much game's difficulty will increase with each wave.
SPAWN_INTENSITY = 1 -- How often we'll spawn new enemies.
MEDKIT_PRICE = 1 -- How much one HP costs on medkit.
ENABLE_FLASHLIGHT = true
ENABLE_NOCLIP = false
ALLOW_DB = true -- Allow saving and loading stats from database. Otherwise players will start anew every time they connect or map changes.

DB_IP = '46.105.46.43'
DB_LOGIN = 'InesaD_393'
DB_PASSWORD = 'Dras1967'
DB_NAME = 'inesad_393'
DB_PORT = 3306

include('sv_zombi.lua')
include('shared.lua')