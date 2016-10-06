function ShotgunSpecial(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

	local cast_range = Distance(caster, target)

	keys.effect = "particles/heroes/sniper/sniper_shotgun_special_projectile.vpcf"
	keys.projectile_speed = 2700
	keys.duration = 0.1
	keys.rate = 3.0
	keys.base_attack_time = 0.1
	keys.cooldown_modifier = GetRunePercentDecrease(1.0,"ziv_sniper_shotgun_special_speed",caster)
	keys.ignore_z = true
	keys.spread = 125 - GRMSC("ziv_sniper_shotgun_special_spread", caster)
	keys.spread_z = true
	keys.interruptable = false
	keys.standard_targeting = false
	keys.attack_sound = "null"
	keys.on_hit = (function ( keys )
		DealDamage(caster, keys.target, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "ziv_sniper_shotgun_special_damage"), DAMAGE_TYPE_PHYSICAL)
		if GetChance(GetSpecial(ability, "knockback_chance")) then
			local duration = GetRunePercentIncrease(0.3,"ziv_sniper_shotgun_special_force",caster)
			local knockbackModifierTable =
		    {
		        should_stun = 1,
		        knockback_duration = duration,
		        duration = duration,
		        knockback_distance = 75,
		        knockback_height = 30,
		        center_x = caster:GetAbsOrigin().x,
		        center_y = caster:GetAbsOrigin().y,
		        center_z = caster:GetAbsOrigin().z
		    }
			keys.target:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )
		end
	end)

	for i=1,5 do
		SimulateRangeAttack(keys)
	end

	Timers:CreateTimer(keys.duration, function (  )
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Sniper.ShotgunSpecial", caster)
	end)
end