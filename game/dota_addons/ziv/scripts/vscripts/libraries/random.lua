function GetRandomNumberBasedOnLevel(min, max, level, coef, float)
	coef = coef or 0.2

	local a = level / MAX_LEVEL
	local b = (max - min)
	local c = clamp((b * a) + math.random(-b*coef,b*coef), min, max)

	if float then 
		return c 
	else 
		return round(c) 
	end
end