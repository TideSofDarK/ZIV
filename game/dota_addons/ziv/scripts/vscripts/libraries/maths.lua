function RandomPointInsideCircle(radius)
    local angle = math.random(0,math.pi * 2)
    local x = radius * math.cos(angle)
    local y = radius * math.sin(angle)
    return Vector(x,y,0) 
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

function lerp_vector(a, b, t)
  local newVector = Vector(0,0,0)
  for i=1,3 do
    local cs = tostring(i)
    newVector[cs] = a[cs] + (b[cs] - a[cs]) * t
  end
  return newVector
end

function lerp(a, b, t)
  return a + (b - a) * t
end

function clamp(val, lower, upper)
    return math.max(lower, math.min(upper, val))
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