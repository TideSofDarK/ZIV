if GameSetup == nil then
    _G.GameSetup = class({})
end

GameSetup.INITIAL_TIME = 180
GameSetup.COUNTDOWN_TIME = 10

function GameSetup:Init() 
	PlayerTables:CreateTable("gamesetup", {status = GeneratePlayerArray("disconnected"), time = GameSetup.INITIAL_TIME}, true)

	CustomGameEventManager:RegisterListener("ziv_gamesetup_create_character", Dynamic_Wrap(Characters, 'CreateCharacter'))
	CustomGameEventManager:RegisterListener("ziv_gamesetup_update_status", Dynamic_Wrap(GameSetup, 'UpdatePlayerStatus'))

	ListenToGameEvent('game_rules_state_change', 
		function(keys)
			local state = GameRules:State_Get()

			if state == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
			elseif state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
				Timers:CreateTimer(1.0, function () 
					CustomGameEventManager:Send_ServerToAllClients("ziv_setup_character_selection",{}) 
				end)

				GameSetup:StartTimer(GameSetup.INITIAL_TIME, function () 

				end, function () 
					GameSetup:StartTimer(GameSetup.COUNTDOWN_TIME, function () 

					end, function () 

					end)
				end)
			end
		end, 
	nil)
end

function GameSetup:UpdatePlayerStatus(args)
	local pID = args.PlayerID

	PlayerTables:SetSubTableValue("gamesetup", "status", pID, args.status)

	if args.character then
		PlayerTables:SetSubTableValue("characters", "characters", pID, args.character)
	end

	GameSetup:FinishGameSetup()
end

function GameSetup:FinishGameSetup()
	local status = PlayerTables:GetTableValue("gamesetup", "status")

	for k,v in pairs(status) do
		if v ~= "ready" and not string.match(GetMapName(), "debug") and not IsInToolsMode() then
			return false
		end
	end

	for k,v in pairs(status) do
		if PlayerResource:GetPlayer(k) then
			Characters:SpawnCharacter(k, PlayerTables:GetTableValue("characters", "characters")[k])
		end
	end

	GameRules:LockCustomGameSetupTeamAssignment(true)
	GameRules:FinishCustomGameSetup()
end

function GameSetup:StartTimer(duration, tick, on_end)
	PlayerTables:SetTableValue("gamesetup", "time", {time = duration})
	Timers:CreateTimer(1.0, function ()
		local time = PlayerTables:GetTableValue( "gamesetup", "time").time
		if time ~= 0 then
			PlayerTables:SetTableValue("gamesetup", "time", {time = time - 1})
			tick()
			return 1.0
		else
			on_end()
		end
	end)
end