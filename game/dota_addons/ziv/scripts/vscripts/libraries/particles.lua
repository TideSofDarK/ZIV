function AddChildParticle( unit, particle )
  unit.particles = unit.particles or {}
  table.insert(unit.particles, particle)
end

function TimedEffect( effect, unit, duration, point, method )
	local particle = ParticleManager:CreateParticle(effect,method or PATTACH_ABSORIGIN,unit)
	if point then
		ParticleManager:SetParticleControl(particle,point,unit:GetAbsOrigin())
		if method then
			ParticleManager:SetParticleControlEnt(particle,point,unit,method,"attach_hitloc",unit:GetAbsOrigin(),false)
		end
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

function AttachParticleKV( keys )
	local caster = keys.caster
	local particle_name = keys.particle

	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())

    AddChildParticle( caster, particle )
end