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
				for i=0,DOTA_MAX_PLAYERS do
					CustomNetTables:SetTableValue( "characters", tostring(i), {})
				end
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

	local characters = CustomNetTables:GetTableValue("characters", tostring(pID))

    characters = characters or {}
	table.insert(characters, Characters:CreateCharacter( args ))

	CustomNetTables:SetTableValue("characters", tostring(pID), characters)
end

function GameSetup:OnPlayerDeleteCharacter(args)
	-- TODO
	-- Server-related stuff

	local pID = args.PlayerID

	local characters = CustomNetTables:GetTableValue("characters", tostring(pID))
	table.remove(characters, args.characterID)

	CustomNetTables:SetTableValue("characters", tostring(pID), characters)
end