if GameSetup == nil then
    _G.GameSetup = class({})
end

GameSetup.player_array = {}

function GameSetup:Init() 
	CustomNetTables:SetTableValue( "gamesetup", "status", {})

	CustomGameEventManager:RegisterListener("ziv_gamesetup_lockin", Dynamic_Wrap(GameSetup, 'OnPlayerLockIn'))
	CustomGameEventManager:RegisterListener("ziv_gamesetup_cancel_lockin", Dynamic_Wrap(GameSetup, 'OnPlayerCancelLockIn'))

	ListenToGameEvent('game_rules_state_change', 
		function(keys)
			local state = GameRules:State_Get()

			if state == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
			elseif state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
				DoToAllPlayers(function (player) 
					GameSetup.player_array[player:GetPlayerID()] = false
				end)
			end
		end, 
	nil)
end

function GameSetup:OnPlayerLockIn(args)

end

function GameSetup:OnPlayerCancelLockIn(args)
	
end