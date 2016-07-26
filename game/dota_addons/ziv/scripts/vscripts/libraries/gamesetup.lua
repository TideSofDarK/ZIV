if GameSetup == nil then
    _G.GameSetup = class({})
end

GameSetup.player_array = {}

function GameSetup:Init() 
	CustomNetTables:SetTableValue( "gamesetup", "status", {})

	CustomGameEventManager:RegisterListener("ziv_gamesetup_create_character", Dynamic_Wrap(GameSetup, 'OnPlayerCreateCharacter'))
	CustomGameEventManager:RegisterListener("ziv_gamesetup_delete_character", Dynamic_Wrap(GameSetup, 'OnPlayerDeleteCharacter'))
	CustomGameEventManager:RegisterListener("ziv_gamesetup_lockin", Dynamic_Wrap(GameSetup, 'OnPlayerLockIn'))
	CustomGameEventManager:RegisterListener("ziv_gamesetup_cancel_lockin", Dynamic_Wrap(GameSetup, 'OnPlayerCancelLockIn'))

	ListenToGameEvent('game_rules_state_change', 
		function(keys)
			local state = GameRules:State_Get()

			if state == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
			elseif state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
				local characters = {}

				for i=0,DOTA_MAX_PLAYERS do
					characters[i] = {}
				end

				CustomNetTables:SetTableValue( "gamesetup", "characters", characters)
			end
		end, 
	nil)
end

function GameSetup:OnPlayerLockIn(args)

end

function GameSetup:OnPlayerCancelLockIn(args)
	
end

function GameSetup:OnPlayerCreateCharacter(args)
	-- TODO
	-- Server-related stuff

	local pID = args.PlayerID

	local characters = CustomNetTables:GetTableValue("gamesetup", "characters")

    characters[pID] = characters[pID] or {}
	table.insert(characters[pID], Characters:CreateCharacter( args ))

	CustomNetTables:SetTableValue("gamesetup", "characters", characters)
end

function GameSetup:OnPlayerDeleteCharacter(args)
	-- TODO
	-- Server-related stuff

	local pID = args.PlayerID

	local characters = CustomNetTables:GetTableValue("gamesetup", "characters")
	table.remove(characters[pID], args.characterID)

	CustomNetTables:SetTableValue("gamesetup", "characters", characters)
end