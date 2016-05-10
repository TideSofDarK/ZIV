Minimap = {}

CustomGameEventManager:RegisterListener( "world_bounds_request", Dynamic_Wrap(Minimap, 'GetWorldSize'))

function Minimap:GetWorldSize( args )
  local worldMin = { x = GetWorldMinX(), y = GetWorldMinY() }
  local worldMax = { x = GetWorldMaxX(), y = GetWorldMaxY() }
  
  local playerID = args.PlayerID
  local player = PlayerResource:GetPlayer(playerID)
  
  CustomGameEventManager:Send_ServerToPlayer(player, "world_bounds", { min = worldMin, max = worldMax, map = GetMapName() })
end