local isTest = true
local steamIDs

ListenToGameEvent('game_rules_state_change', 
  function(keys)
    local state = GameRules:State_Get()

    if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
      Timers:CreateTimer(function ()
        SU:Init()
      end)
    end
  end, nil)

function SU:BuildSteamIDArray()
    local players = {}
    for playerID = 0, DOTA_MAX_PLAYERS-1 do
      if PlayerResource:IsValidPlayerID(playerID) then
        if not PlayerResource:IsBroadcaster(playerID) then
          table.insert(players, PlayerResource:GetSteamAccountID(playerID) or 0)
        end
      end
    end

    return players
end

function SU:Init()
  steamIDs = SU:BuildSteamIDArray()
  DeepPrintTable(steamIDs)
  
  if SU.StatSettings ~= nil then
    if isTest or (not GameRules:IsCheatMode()) then
      ListenToGameEvent('game_rules_state_change', 
        function(keys)
          local state = GameRules:State_Get()

          if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
            SU:SendAuthInfo()
          end
        end, nil)
    else
      print("Bad stat recording conditions.")
    end    
  else
    print("StatUploader settings file not found.")
  end
end

function SU:RecordCharacter( args )
  local playerID = args.PlayerID
  local steamID = PlayerResource:GetSteamAccountID(playerID)

  local requestParams = {
    Command = "RecordCharacter",
    Data = {
      SteamID = steamID,
      CharacterName = args.character_name,
      HeroName = args.hero_name,
      Abilities = StringifyTable(args.abilities),
      Equipment = StringifyTable(args.equipment)
    }
  }
  
  SU:SendRequest( requestParams, function(obj)
  end)
end