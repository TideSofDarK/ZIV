function Leap( keys )
	local target = keys.target_points[1]
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	StartRuneCooldown(ability,"ziv_beastmaster_leap_cd",caster)

	caster:SetForwardVector(UnitLookAtPoint( caster, target ))
	caster:Stop()

	ProjectileManager:ProjectileDodge(caster)

	ability.trail_particle = ParticleManager:CreateParticle("particles/heroes/beastmaster/beastmaster_leap_trail.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)

	StartAnimation(caster, {duration=1.6, activity=ACT_DOTA_CAST_ABILITY_1, rate=1.1})

	ability.leap_direction = caster:GetForwardVector()
	ability.leap_distance = ability:GetLevelSpecialValueFor("leap_distance", ability_level)
	ability.leap_speed = ability:GetLevelSpecialValueFor("leap_speed", ability_level) * 1/30
	ability.leap_traveled = 0
	ability.leap_z = 0

	ability.target = target
end

function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		Timers:CreateTimer(function (  )
			local point = caster:GetAbsOrigin() + (caster:GetForwardVector() * 64)

			local ground = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_earthshock.vpcf",PATTACH_ABSORIGIN,caster)
			ParticleManager:SetParticleControl(ground,0,point)
			caster:EmitSound("Hero_EarthShaker.Fissure.Cast")

			ParticleManager:DestroyParticle(ability.trail_particle,false)

			local units_in_burn_radius = FindUnitsInRadius(caster:GetTeamNumber(), point,  nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for k,v in pairs(units_in_burn_radius) do
		    	local knockbackModifierTable =
			    {
			        should_stun = 1,
			        knockback_duration = 1.0,
			        duration = 1.0,
			        knockback_distance = 75 + GRMSC("ziv_beastmaster_leap_force",caster),
			        knockback_height = 80,
			        center_x = point.x,
			        center_y = point.y,
			        center_z = point.z
			    }
				v:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )

			    DealDamage(caster, v, GetRuneDamage("ziv_beastmaster_leap_damage",caster), DAMAGE_TYPE_PHYSICAL)
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