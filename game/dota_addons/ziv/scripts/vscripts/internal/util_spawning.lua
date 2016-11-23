function RandomPointOnMap(offset)
  local offset = offset or 100

  local worldX = math.random(GetWorldMinX() + offset, GetWorldMaxX() - offset)
  local worldY = math.random(GetWorldMinY() + offset, GetWorldMaxY() - offset)

  return Vector(worldX,worldY,0)
end

function GetArea( point )
  local t = {}
  for k,v in pairs(Entities:FindAllByName(point)) do
    t[tonumber(string.match(v:GetName(),"%d+"))] = v:GetAbsOrigin()
  end
  return t
end

function DistributeUnitsAlongPolygonPath(path, spawn, density)
  if not spawn or not path then return end

  local entities = {}

  local j = #path
  for i = 1, #path do
    local offset = (density or 128)

    local direction = (path[i] - path[j]):Normalized()
    local distance = (path[j] - path[i]):Length2D()

    for x=0,distance,offset do
      local ent
      if type(spawn) == "table" then
        -- TO DO
      elseif type(spawn) == "function" then
        ent = spawn(path[j] + (direction * x), x == 0)
      elseif type(spawn) == "string" then
        ent = SpawnEntityFromTableSynchronous("prop_dynamic", {model = model, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})

        local pos = GetGroundPosition(path[j] + (direction * x),ent)
        ent:SetAbsOrigin(pos)
      end

      if ent then
        table.insert(entities, ent)
      end
    end

      j = i
  end

  return entities
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