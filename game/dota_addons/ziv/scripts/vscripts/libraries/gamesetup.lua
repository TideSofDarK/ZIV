if GameSetup == nil then
    _G.GameSetup = class({})
end

GameSetup.TIMEOUT = 9999999 -- 5 minutes

function GameSetup:Init() 
	GameRules:SetCustomGameSetupTimeout( GameSetup.TIMEOUT )
	GameRules:EnableCustomGameSetupAutoLaunch( false )

	ListenToGameEvent('game_rules_state_change', 
		function(keys)
			local state = GameRules:State_Get()

			if state == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
			elseif state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
			end
		end, 
	nil)
end