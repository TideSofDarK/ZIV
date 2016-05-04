function Dash( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)

	local ability_level = ability:GetLevel() - 1

	StartAnimation(caster, {duration=0.44, activity=ACT_DOTA_RUN, rate=2.3})

	Timers:CreateTimer(0.44, function (  )
		StartAnimation(caster, {duration=1.2, activity=ACT_DOTA_CAST_ABILITY_1, rate=1.7})
	end)

	ability.direction = (target - caster:GetAbsOrigin()):Normalized()

	ability.distance = ability:GetCastRange()

	ability.speed = ability:GetLevelSpecialValueFor("dash_speed", ability_level)

	ability.traveled = 0

	caster:AddNewModifier( caster, nil, "modifier_disarmed", {duration=1.0} )

	ability.particle = ParticleManager:CreateParticle("particles/heroes/knight/knight_dash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

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
        knockback_distance = 200 + GRMSC("ziv_knight_dash_force", caster),
        knockback_height = 50,
        center_x = caster:GetAbsOrigin().x,
        center_y = caster:GetAbsOrigin().y,
        center_z = caster:GetAbsOrigin().z
    }
	target:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )

    DealDamage(caster, target, GetRuneDamage("ziv_knight_dash_damage",caster) + ability:GetLevelSpecialValueFor("damage_amp", ability:GetLevel()-1), DAMAGE_TYPE_FIRE)
end