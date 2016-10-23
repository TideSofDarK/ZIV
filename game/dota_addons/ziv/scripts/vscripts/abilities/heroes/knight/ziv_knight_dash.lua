function Dash( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)

	local ability_level = ability:GetLevel() - 1

	StartAnimation(caster, {duration=-1, activity=ACT_DOTA_RUN, rate=2.0})

	ability.direction = (target - caster:GetAbsOrigin()):Normalized()

	ability.distance = math.max(GetSpecial(ability, "minimum_distance"), math.min(GetSpecial(ability, "maximum_distance"), (caster:GetAbsOrigin() - target):Length2D()))

	ability.speed = GetSpecial(ability, "dash_speed")
	ability.move_tick = GetSpecial(ability, "dash_speed") / 30
	ability.duration = ability.distance/ability.speed

	ability.traveled = 0

	caster:AddNewModifier( caster, nil, "modifier_disarmed", {duration=ability.duration} )
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_dash_running",{duration=ability.duration})

	ability.particle = ParticleManager:CreateParticle("particles/heroes/knight/knight_dash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

	Timers:CreateTimer(ability.duration, function (  )
		ParticleManager:DestroyParticle(ability.particle, false)
	end)

	Timers:CreateTimer(ability.duration / 1.5, function (  )
		Timers:CreateTimer(0.15, function (  )
			StartAnimation(caster, {duration=0.8, activity=ACT_DOTA_CAST_ABILITY_5, rate=2.5})
		end)
		Timers:CreateTimer(0.3, function (  )
			caster:EmitSound("Hero_EarthShaker.IdleSlam")
		end)
		Timers:CreateTimer(0.4, function (  )
			local ground = TimedEffect( "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle_ground_rocks.vpcf", caster, 1.0, 5 )
			local rocks = TimedEffect( "particles/units/heroes/hero_visage/visage_stone_form.vpcf", caster, 0.5 )

			local hit_position = caster:GetAbsOrigin() + (caster:GetForwardVector() * 140)

			ParticleManager:SetParticleControl(ground,5,hit_position)
			ParticleManager:SetParticleControl(rocks,0,hit_position)

			DoToUnitsInRadius( caster, hit_position, 128, target_team, target_type, target_flags, function ( v )
				Damage:Deal(caster, v, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "ziv_knight_dash_damage"), DAMAGE_TYPE_PHYSICAL)

				local force = GRMSC("ziv_knight_dash_force", caster)
				if force > 0 then
					local knockbackModifierTable =
				    {
				        should_stun = 1,
				        knockback_duration = 0.4,
				        duration = 0.4,
				        knockback_distance = force,
				        knockback_height = 75,
				        center_x = caster:GetAbsOrigin().x,
				        center_y = caster:GetAbsOrigin().y,
				        center_z = caster:GetAbsOrigin().z
				    }
					v:AddNewModifier( caster, ability, "modifier_knockback", knockbackModifierTable )
				end
			end )
		end)
		-- Timers:CreateTimer(0.4, function (  )
		-- 	FreezeAnimation(caster, 0.15)
		-- end)
	end)
end

function DashHorizontal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.traveled < ability.distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.direction * ability.move_tick)
		caster:EmitSound("Hero_WarlockGolem.Footsteps")

		ability.traveled = ability.traveled + ability.move_tick
	else
		caster:InterruptMotionControllers(true)
	end
end