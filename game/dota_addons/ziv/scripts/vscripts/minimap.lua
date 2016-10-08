Minimap = {}

CustomGameEventManager:RegisterListener( "set_minimap_event", Dynamic_Wrap(Minimap, 'SendEventFromPlayer'))

function Minimap:SendEvent( eventType, eventDuration, player, worldPos, entity )
    CustomGameEventManager:Send_ServerToAllClients("custom_minimap_event", 
      { type = eventType, duration = eventDuration, player = player, pos = worldPos, entity = entity })
end

function Minimap:SendEventFromPlayer( args )
  Minimap:SendEvent( args["type"], args["duration"], args["PlayerID"], args["pos"], args["entity"] )
end