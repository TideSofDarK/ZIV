function AttachParticle( keys )
	local caster = keys.caster
	local particle_name = keys.particle

	caster.particles = caster.particles or {}

	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())

    table.insert(caster.particles, particle)
end