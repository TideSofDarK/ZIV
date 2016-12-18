-- Polygons

function IsPointInsidePolygon(point, polygon)
  local odd_nodes = false
  local j = #polygon
  for i = 1, #polygon do
      if (polygon[i].y < point.y and polygon[j].y >= point.y or polygon[j].y < point.y and polygon[i].y >= point.y) then
          if (polygon[i].x + ( point.y - polygon[i].y ) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x) then
              odd_nodes = not odd_nodes
          end
      end
      j = i
  end
  return odd_nodes
end

function RandomPointInPolygon( polygon )
  local minX = polygon[1].x
  local maxX = polygon[1].x
  local minY = polygon[1].y
  local maxY = polygon[1].y

  for k,v in pairs(polygon) do
        minX = math.min( v.x, minX );
        maxX = math.max( v.x, maxX );
        minY = math.min( v.y, minY );
        maxY = math.max( v.y, maxY );
  end

  local point
  repeat
    point = Vector(RandomFloat(minX,maxX), RandomFloat(minY,maxY), 0)
  until IsPointInsidePolygon(point, polygon)

  return point
end

function GetPathLength( path )
  local length = 0
  for i=1,#path do
    if not path[i+1] then
      return length
    else
      length = length + (path[i] - path[i+1]):Length2D()
    end
  end
end

function FindUnitsInCone(position, coneDirection, coneLength, coneWidth, teamNumber, teamFilter, typeFilter, flagFilter, order)
  local units = FindUnitsInRadius(teamNumber, position, nil, coneLength, teamFilter, typeFilter, flagFilter, order, false)

  coneDirection = coneDirection:Normalized()

  local output = {}
  for _, unit in pairs(units) do
    local direction = (unit:GetAbsOrigin() - position):Normalized()
    if direction:Dot(coneDirection) >= math.cos(coneWidth/2) then
      table.insert(output, unit)
    end
  end

  return output
end

function IsInFront(a,b,direction)
  local product = (a.x - b.x) * direction.x + (a.y - b.y) * direction.y + (a.z - b.z) * direction.z
  return product < 0.0
end

function RandomPointInsideCircle(x, y, radius, min_length)
  local dist = math.random((min_length or 0), radius)
  local angle = math.random(0, math.pi * 2)
  
  local xOffset = dist * math.cos(angle)
  local yOffset = dist * math.sin(angle)
  
  return Vector(x + xOffset, y + yOffset, 0)
end

function RandomPointsInsideCircleUniform( pos, radius, count, uniform )
  local points = {}

  check_point = function ( v )
    for i=1,#points do
      if (points[i] - v):Length2D() < uniform then return false end
    end
    return true
  end

  for i=1,count do
    local point
    repeat 
      point = RandomPointInsideCircle(pos.x, pos.y, radius)
    until check_point(point)

    point.z = pos.z

    table.insert(points, point)
  end

  return points
end

function RandomPointOnCircle(radius)
    local angle = math.random(0,math.pi * 2)
    local x = radius * math.cos(angle)
    local y = radius * math.sin(angle)
    return Vector(x,y,0) 
end

function PointOnCircle(radius, angle)
    local x = radius * math.cos(angle * math.pi / 180)
    local y = radius * math.sin(angle * math.pi / 180)
    return Vector(x,y,0) 
end

function Distance(a, b)
  if not a.x then
    a = a:GetAbsOrigin()
  end
  if not b.x then
    b = b:GetAbsOrigin()
  end
  return (a - b):Length()
end

function MoveTowards(unit, dest, speed, callback, look)
  local tick = (1.0/30.0)
  local t = tick
  local speed = speed/30.0

  Timers:CreateTimer(function (  )
    local delta = 25

    local diff

    if dest.GetAbsOrigin then
      diff = (dest:GetAbsOrigin() - unit:GetAbsOrigin()):Normalized()
    else
      diff = (dest - unit:GetAbsOrigin()):Normalized()
    end

    local distance = Distance(unit, dest)
    
    if distance <= delta or distance == 0 then
      callback()
    else
      local new_pos = unit:GetAbsOrigin() + (diff * math.min(speed, distance))

      if look then
        unit:SetForwardVector(UnitLookAtPoint(unit, new_pos))
      end

      unit:SetAbsOrigin(new_pos)

      t = t + tick
      return tick
    end
  end)
end

function angleOfPoint( pt )
   local x, y = pt.x, pt.y
   local radian = math.atan2(y,x)
   local angle = radian*180/math.pi
   if angle < 0 then angle = 360 + angle end
   return angle
end

function angleBetweenPoints( a, b )
   local x, y = b.x - a.x, b.y - a.y
   return angleOfPoint( { x=x, y=y } )
end

function smallestAngleDiff( target, source )
   local a = target - source
   
   if (a > 180) then
      a = a - 360
   elseif (a < -180) then
      a = a + 360
   end
   
   return a
end

function dotProduct(a, b)
  return a.x*b.x + a.y*b.y + (a.z or 0)*(b.z or 0)
end

function randomf(lower, greater)
  return lower + math.random()  * (greater - lower);
end

function lerp(a,b,t) return (1-t)*a + t*b end

function lerp2(a,b,t) return a+(b-a)*t end

function lerp_vector(a, b, t)
  local newVector = Vector(0,0,0)
  for i=1,3 do
    local cs = tostring(i)

    newVector[cs] = ((1-t)*a[cs]) + (t*b[cs])
  end
  return newVector
end

function clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
end

function math._repeat(val, upper)
  return val - math.floor(val / upper) * upper
end

function round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

function smoothstep(edge0, edge1, x)
    x = clamp((x - edge0)/(edge1 - edge0), 0.0, 1.0)
    return x*x*(3 - 2*x)
end

function GetRandomSign()
  local seed = math.random(0, 1)
  if seed > 0 then return 1
  elseif seed < 1 then return -1 end
end
