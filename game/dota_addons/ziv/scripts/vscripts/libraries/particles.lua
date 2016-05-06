function AddChildParticle( unit, particle )
  unit.particles = unit.particles or {}
  table.insert(unit.particles, particle)
end

function TimedEffect( effect, unit, duration, point )
	local particle = ParticleManager:CreateParticle(effect,PATTACH_ABSORIGIN,unit)
	if point then
		ParticleManager:SetParticleControl(particle,point,unit:GetAbsOrigin())
	end
	Timers:CreateTimer(duration, function(  )
		ParticleManager:DestroyParticle(particle,false)
	end)

	return particle
end