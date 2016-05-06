function Attack( keys )
	local caster = keys.caster
	local ability = keys.ability

	StartAnimation(caster, {duration=1.7, activity=ACT_DOTA_ATTACK, rate=0.6})
end

function AttackParticle( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local particle = TimedEffect("particles/units/heroes/hero_visage/visage_stoneform_blast.vpcf", caster, 2.0)
	ParticleManager:SetParticleControl(particle,0,target)
end

function AttackImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	
end