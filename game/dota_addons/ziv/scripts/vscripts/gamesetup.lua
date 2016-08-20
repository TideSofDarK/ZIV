if GameSetup == nil then
    _G.GameSetup = class({})
end

GameSetup.INITIAL_TIME = 120
GameSetup.COUNTDOWN_TIME = 10

GameSetup.player_array = {}

function GameSetup:Init() 
	PlayerTables:CreateTable("characters", {}, true)
	PlayerTables:CreateTable("gamesetup", {status={(function() local players = {} for i=0,DOTA_MAX_PLAYERS-1 do players[i] = "connected" end return players end)()}}, true)

	CustomGameEventManager:RegisterListener("ziv_gamesetup_create_character", Dynamic_Wrap(GameSetup, 'OnPlayerCreateCharacter'))
	CustomGameEventManager:RegisterListener("ziv_gamesetup_delete_character", Dynamic_Wrap(GameSetup, 'OnPlayerDeleteCharacter'))
	CustomGameEventManager:RegisterListener("ziv_gamesetup_lockin", Dynamic_Wrap(GameSetup, 'OnPlayerLockIn'))
	CustomGameEventManager:RegisterListener("ziv_gamesetup_cancel_lockin", Dynamic_Wrap(GameSetup, 'OnPlayerCancelLockIn'))

	ListenToGameEvent('game_rules_state_change', 
		function(keys)
			local state = GameRules:State_Get()

			if state == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
			elseif state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
				for i=0,DOTA_MAX_PLAYERS-1 do
					PlayerTables:SetTableValue("characters", tostring(i), {})
				end

				PlayerTables:SetTableValue("gamesetup", "time", {initial = GameSetup.INITIAL_TIME})

				Timers:CreateTimer(function ()
					PlayerTables:SetTableValue("gamesetup", "time", {initial = PlayerTables:GetTableValue( "gamesetup", "time").initial - 1})

					return 1.0
				end)
			end
		end, 
	nil)
end

function GameSetup:OnPlayerLockIn(args)
	local pID = args.PlayerID

	player_array[pID] = args.character_name
end

function GameSetup:OnPlayerCancelLockIn(args)
	local pID = args.PlayerID

	player_array[pID] = nil
end

function GameSetup:OnPlayerCreateCharacter(args)
	local pID = args.PlayerID

	local characters = PlayerTables:GetTableValue("characters", tostring(pID))

    characters = characters or {}
	table.insert(characters, Characters:CreateCharacter( args ))

	PlayerTables:SetTableValue("characters", tostring(pID), characters)
end

function GameSetup:OnPlayerDeleteCharacter(args)
	local pID = args.PlayerID

	local characters = PlayerTables:GetTableValue("characters", tostring(pID))
	for k,v in pairs(characters) do
		if args.character_name == v.character_name then
			characters[k] = nil
			break
		end
	end

	PlayerTables:SetTableValue("characters", tostring(pID), characters)
end