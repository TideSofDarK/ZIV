SU.NETWORK_TEST = true
SU.STEAMIDS     = {}

ListenToGameEvent('game_rules_state_change', 
  function(keys)
    local state = GameRules:State_Get()

    if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
      SU:Init()
    end
  end, nil)

function SU:BuildSteamIDArray()
  local players = {}
  for pID = 0, DOTA_MAX_PLAYERS-1 do
    if PlayerResource:IsValidPlayerID(pID) then
      if not PlayerResource:IsBroadcaster(pID) then
        players[pID] = PlayerResource:GetSteamAccountID(pID) or 0
      end
    end
  end

  return players
end

function SU:Init()
  SU.STEAMIDS = SU:BuildSteamIDArray()
  
  if SU.STAT_SETTINGS ~= nil then
    if SU.NETWORK_TEST or (not GameRules:IsCheatMode()) then
      SU:SendAuthInfo()
    else
      print("Bad stat recording conditions.")
    end    
  else
    print("StatUploader settings file not found.")
  end
end

function SU:RecordCharacter( args )
  local pID = args.PlayerID
  local steamID = PlayerResource:GetSteamAccountID(pID)

  local request_params = {
    Command = "RecordCharacter",
    Data = {
      SteamID = steamID,
      CharacterName = args.character_name,
      HeroName = args.hero_name,
      Abilities = args.abilities,
      Equipment = args.equipment
    }
  }
  
  SU:SendRequest( request_params, function(obj)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pID), "ziv_setup_character_selection",{})
  end)
end

function SU:LoadPlayerData( args )
  local pID = args.PlayerID
  local steamID = PlayerResource:GetSteamAccountID(pID)

  local request_params = {
    Command = "LoadPlayerData",
    SteamID = steamID
  }
  
  SU:SendRequest( request_params, function(obj)
    CustomGameEventManager:Send_ServerToAllClients("ziv_setup_character_selection",{})
  end)
end

function SU:SavePlayerData( args )
  local pID = args.PlayerID
  local steamID = PlayerResource:GetSteamAccountID(pID)

  local request_params = {
    Command = "SavePlayerData",
    Data = {
      SteamID = steamID,
      Exp = args.exp,
      Settings = args.settings
    }
  }
  
  SU:SendRequest( request_params, function(obj)
    -- CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pID), "ziv_setup_character_selection",{})
  end)
end