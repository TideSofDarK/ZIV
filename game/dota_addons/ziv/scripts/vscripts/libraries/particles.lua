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

function ReleaseChildParticles( caster )
  caster.particles = caster.particles or {}

  for k,v in pairs(caster.particles) do
    ParticleManager:DestroyParticle(v, false)
  end
end