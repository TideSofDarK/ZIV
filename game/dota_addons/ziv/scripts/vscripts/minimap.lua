Minimap = {}

CustomGameEventManager:RegisterListener( "world_bounds_request", Dynamic_Wrap(Minimap, 'GetWorldSize'))
CustomGameEventManager:RegisterListener( "set_minimap_event", Dynamic_Wrap(Minimap, 'SendEventFromPlayer'))

function Minimap:GetWorldSize( args )
  local worldMin = { x = GetWorldMinX(), y = GetWorldMinY() }
  local worldMax = { x = GetWorldMaxX(), y = GetWorldMaxY() }
  
  local playerID = args.PlayerID
  local player = PlayerResource:GetPlayer(playerID)
  
  CustomGameEventManager:Send_ServerToPlayer(player, "world_bounds", { min = worldMin, max = worldMax, map = GetMapName() })
end

function Minimap:SendEvent( eventType, eventDuration, player, worldPos, entity )
    CustomGameEventManager:Send_ServerToAllClients("custom_minimap_event", 
      { type = eventType, duration = eventDuration, player = player, pos = worldPos, entity = entity })
end

function Minimap:SendEventFromPlayer( args )
  Minimap:SendEvent( args["type"], args["duration"], args["PlayerID"], args["pos"], args["entity"] )
end