function RandomPointOnMap(offset)
  local offset = offset or 100

  local worldX = math.random(GetWorldMinX() + offset, GetWorldMaxX() - offset)
  local worldY = math.random(GetWorldMinY() + offset, GetWorldMaxY() - offset)

  return Vector(worldX,worldY,0)
end

function DistributeUnitsAlongPolygonPath(path, spawn, density)
  if not spawn or not path then return end

  local j = #path
  for i = 1, #path do
    local offset = (density or 128)

    local direction = (path[i] - path[j]):Normalized()
    local distance = (path[j] - path[i]):Length2D()

    for x=0,distance,offset do
      local pos = GetGroundPosition(path[j] + (direction * x),obstacle)

      if type(spawn) == "table" then
        if x == 0 then
          obstacle:SetForwardVector((pos - getMidPoint(path)):Normalized())
        else
          if arenas[current_arena].wallRandomDirection then
            obstacle:SetAngles(0, math.random(0, 360), 0)
          end
        end

        SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = pos + Vector(x * 32,y * 32,0), block_fow = true})
      elseif type(spawn) == "function" then
        spawn(pos, x == 0)
      elseif type(spawn) == "string" then
        local obstacle = SpawnEntityFromTableSynchronous("prop_dynamic", {model = model, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
        obstacle:SetAbsOrigin(pos)
      end
    end

      j = i
  end
end

function DistributeUnits( points, unit_name, count, team, on_kill )
  if #points == 0 then return end
  local random_points = Shuffle(points)

  local units = {}

  local i = 1
  for k,v in pairs(random_points) do
    if i > count then break end 
    local unit = CreateUnitByName(unit_name, v:GetAbsOrigin(), false, nil, nil,team)
    unit.on_kill = on_kill
    table.insert(units, unit)
    i = i + 1
  end

  return units
end