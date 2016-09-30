if GameSetup == nil then
    _G.GameSetup = class({})
end

GameSetup.INITIAL_TIME = 180
GameSetup.COUNTDOWN_TIME = 10

GameSetup.timer = nil

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

				GameSetup:StartPreparingPhase()
			end
		end, 
	nil)
end

function GameSetup:StartTimer(duration, tick, on_end)
	PlayerTables:SetTableValue("gamesetup", "time", {time = duration})
	return Timers:CreateTimer(1.0, function ()
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

function GameSetup:StartPreparingPhase()
	GameSetup.timer = GameSetup:StartTimer(GameSetup.INITIAL_TIME, function () 
		-- Tick
	end, function () 
		GameSetup:StartCountdownPhase()
	end)
end

function GameSetup:StartCountdownPhase()
	GameRules:LockCustomGameSetupTeamAssignment(true)

	CustomGameEventManager:Send_ServerToAllClients("ziv_gamesetup_lock", {})

	GameSetup.timer = GameSetup:StartTimer(GameSetup.COUNTDOWN_TIME, function () 
		-- Tick
	end, function () 
		GameRules:FinishCustomGameSetup()

		local status = PlayerTables:GetTableValue("gamesetup", "status")

		for k,v in pairs(status) do
			if PlayerResource:GetPlayer(k) then
				Characters:SpawnCharacter(k, PlayerTables:GetTableValue("characters", "characters")[k])
			end
		end
	end)
end

function GameSetup:UpdatePlayerStatus(args)
	local pID = args.PlayerID

	PlayerTables:SetSubTableValue("gamesetup", "status", pID, args.status)

	if args.character and args.character ~= -1 then
		PlayerTables:SetSubTableValue("characters", "characters", pID, args.character)
	end

	if args.status == "ready" then
		GameSetup:AttemptForceStart()
	end
end

function GameSetup:AttemptForceStart()
	local status = PlayerTables:GetTableValue("gamesetup", "status")
	
	for k,v in pairs(status) do
		if PlayerResource:GetPlayer(k) and v ~= "ready" and not string.match(GetMapName(), "debug") and not IsInToolsMode() then
			return false
		end
	end

	Timers:RemoveTimer(GameSetup.timer)

	GameSetup:StartCountdownPhase()
end