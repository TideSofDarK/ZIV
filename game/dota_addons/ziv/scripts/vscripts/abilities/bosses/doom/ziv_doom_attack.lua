function Attack( keys )
	local caster = keys.caster
	local ability = keys.ability

	local particle = TimedEffect("particles/units/heroes/hero_doom_bringer/doom_infernal_blade.vpcf", caster, 2.0)

	StartAnimation(unit, {duration=2.0, activity=ACT_DOTA_ATTACK, rate=1.0, translate="infernal_blade"})
end

function AttackParticle( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local particle = TimedEffect("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf", caster, 2.0)
	ParticleManager:SetParticleControl(particle,0,target)
end

function AttackImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	
end