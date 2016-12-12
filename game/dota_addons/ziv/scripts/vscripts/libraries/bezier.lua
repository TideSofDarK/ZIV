BezierCurve = class({})

function BezierCurve:init()
    self:generate_new_bezier()
end

function BezierCurve:Draw(curve, offset)
    for i=1,(#curve)-1 do
        DebugDrawLine(offset + curve[i], offset + curve[i+1], 255, 0, 255, false, 5.0)
    end
end

function BezierCurve:PointOnCubicBezier(cp, t )
    local ax, bx, cx
    local ay, by, cy
    local tSquared, tCubed
    local result = Vector(0,0,0)
 
  --  /* calculation of the polinomial coeficients */
 
    cx = 3.0 * (cp[2].x - cp[1].x)
    bx = 3.0 * (cp[1].x - cp[2].x) - cx
    ax = cp[4].x - cp[1].x - cx - bx
 
    cy = 3.0 * (cp[2].y - cp[1].y)
    by = 3.0 * (cp[3].y - cp[2].y) - cy
    ay = cp[4].y - cp[1].y - cy - by
 
  --  /* calculate the curve point at parameter value t */
 
    tSquared = t * t
    tCubed = tSquared * t
 
    result.x = (ax * tCubed) + (bx * tSquared) + (cx * t) + cp[1].x
    result.y = (ay * tCubed) + (by * tSquared) + (cy * t) + cp[1].y
 
    return result
end
 

-- ComputeBezier fills an array of Point2D structs with the curve   
-- points generated from the control points cp. Caller must 
-- allocate sufficient memory for the result, which is 
-- <sizeof(Point2D) numberOfPoints>
 
function BezierCurve:ComputeBezier( cp, numberOfPoints ) 
    local dt
    local i
    local curve = {}
 
    dt = 1.0 / ( numberOfPoints - 1 )
 
    for i = 1, numberOfPoints do
        curve[i] = self:PointOnCubicBezier( cp, i*dt )
        i = i + 1
    end

    return curve
end