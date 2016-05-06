function Curse( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local particle = TimedEffect("particles/units/heroes/hero_undying/undying_decay.vpcf", caster, 2.0, 0)
	ParticleManager:SetParticleControl(particle,0,target)
end