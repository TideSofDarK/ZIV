function Leap( keys )
	local target = keys.target_points[1]
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1	

	caster:SetForwardVector((target - caster:GetAbsOrigin()):Normalized())
	caster:Stop()

	ProjectileManager:ProjectileDodge(caster)

	ability.trail_particle = ParticleManager:CreateParticle("particles/heroes/beastmaster/beastmaster_leap_trail.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)

	StartAnimation(caster, {duration=2.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=0.8})

	ability.leap_direction = caster:GetForwardVector()
	ability.leap_distance = ability:GetLevelSpecialValueFor("leap_distance", ability_level)
	ability.leap_speed = ability:GetLevelSpecialValueFor("leap_speed", ability_level) * 1/30
	ability.leap_traveled = 0
	ability.leap_z = 0
end

function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		Timers:CreateTimer(0.06, function (  )
			ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_earthshock.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
			caster:EmitSound("Hero_EarthShaker.Fissure.Cast")

			ParticleManager:DestroyParticle(ability.trail_particle,false)

			local units_in_burn_radius = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),  nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for k,v in pairs(units_in_burn_radius) do
		    	local knockbackModifierTable =
			    {
			        should_stun = 1,
			        knockback_duration = 1.0,
			        duration = 1.0,
			        knockback_distance = 150,
			        knockback_height = 80,
			        center_x = caster:GetAbsOrigin().x,
			        center_y = caster:GetAbsOrigin().y,
			        center_z = caster:GetAbsOrigin().z
			    }
				v:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )

			    local damageTable = {
			        victim = v,
			        attacker = caster,
			        damage = caster:GetAverageTrueAttackDamage() / 2,
			        damage_type = DAMAGE_TYPE_MAGICAL,
			    }
			    ApplyDamage(damageTable)
			end
		end)
		
		caster:InterruptMotionControllers(true)
	end
end

function LeapVertical( keys )
	local caster = keys.target
	local ability = keys.ability

	-- For the first half of the distance the unit goes up and for the second half it goes down
	if ability.leap_traveled < ability.leap_distance/2 then
		-- Go up
		-- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
		ability.leap_z = ability.leap_z + ability.leap_speed/1.5
		-- Set the new location to the current ground location + the memorized z point
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	else
		-- Go down
		ability.leap_z = ability.leap_z - ability.leap_speed/1.5
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	end
end