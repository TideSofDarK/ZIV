function Dash( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)

	local ability_level = ability:GetLevel() - 1

	StartAnimation(caster, {duration=0.55, activity=ACT_DOTA_RUN, rate=2.3})

	Timers:CreateTimer(0.55, function (  )
		StartAnimation(caster, {duration=1.2, activity=ACT_DOTA_CAST_ABILITY_1, rate=1.7})
	end)

	ability.direction = (target - caster:GetAbsOrigin()):Normalized()

	ability.distance = ability:GetCastRange()

	ability.speed = ability:GetLevelSpecialValueFor("dash_speed", ability_level)

	ability.traveled = 0

	caster:AddNewModifier( caster, nil, "modifier_disarmed", {duration=1.0} )

	ability.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

	Timers:CreateTimer(1.0, function (  )
		ParticleManager:DestroyParticle(ability.particle, false)
	end)
end

function DashHorizontal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.traveled < ability.distance then
		ability.speed = ability.speed + 2
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.direction * ability.speed)

		ability.traveled = ability.traveled + ability.speed
	else
		caster:InterruptMotionControllers(true)
	end
end

function Knockback( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:HasModifier("modifier_knockback") == true then return end

	local knockbackModifierTable =
    {
        should_stun = 1,
        knockback_duration = 1,
        duration = 1,
        knockback_distance = 250,
        knockback_height = 50,
        center_x = caster:GetAbsOrigin().x,
        center_y = caster:GetAbsOrigin().y,
        center_z = caster:GetAbsOrigin().z
    }
	target:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )

    local damageTable = {
        victim = target,
        attacker = caster,
        damage = caster:GetAverageTrueAttackDamage() + ability:GetLevelSpecialValueFor("bonus_damage", ability:GetLevel()-1),
        damage_type = DAMAGE_TYPE_PHYSICAL,
    }
    ApplyDamage(damageTable)
end