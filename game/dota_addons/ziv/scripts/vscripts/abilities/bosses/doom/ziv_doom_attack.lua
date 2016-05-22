function Attack( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	StartAnimation(caster, {duration=3.0, activity=ACT_DOTA_ATTACK_EVENT, rate=1.0})

	Timers:CreateTimer(caster:GetAttackAnimationPoint() / caster:GetAttackSpeed(), function (  )
		TimedEffect("particles/units/heroes/hero_doom_bringer/doom_infernal_blade.vpcf", caster, 2.0)

		local particle = TimedEffect("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf", caster, 2.0)
		ParticleManager:SetParticleControl(particle,0,target)
	end)
end

function AttackImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	DealDamage(caster, target, GetSpecial(ability, "damage_percent") * target:GetMaxHealth() / 2, DAMAGE_TYPE_PHYSICAL)
	DealDamage(caster, target, GetSpecial(ability, "damage_percent") * target:GetMaxHealth() / 2, DAMAGE_TYPE_FIRE)
end