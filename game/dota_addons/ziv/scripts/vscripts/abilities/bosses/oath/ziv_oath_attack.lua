function Attack( keys )
	local caster = keys.caster
	local ability = keys.ability

	local activity

	if math.random(0,1) == 0 then
		activity = ACT_DOTA_RAZE_1
	else
		if math.random(0,1) == 0 then
			activity = ACT_DOTA_RAZE_2
		else
			activity = ACT_DOTA_RAZE_3
		end
	end

	StartAnimation(caster, {duration=3.1, activity=activity, rate=0.8})
end

function AttackParticle( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local particle = TimedEffect("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", caster, 2.0)
	ParticleManager:SetParticleControl(particle,0,target)
end

function AttackImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local damage = GetSpecial(ability, "damage_percent") * target:GetMaxHealth()

	local fire_damage = DealDamage(caster, target, damage/2, DAMAGE_TYPE_FIRE, true)
	local physical_damage = DealDamage(caster, target, damage/2, DAMAGE_TYPE_PHYSICAL, true)
	PopupDamage(target:GetPlayerOwner(), target, fire_damage + physical_damage, 0.5)
end