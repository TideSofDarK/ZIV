function ColdBlastStart( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local quas_level = 1

	local knockback_duration = ability:GetLevelSpecialValueFor("knockback_duration", quas_level) + 0.1
	local travel_distance = ability:GetLevelSpecialValueFor("travel_distance", ability_level) 
	local travel_speed = ability:GetLevelSpecialValueFor("travel_speed", ability_level) 
	local radius_start = ability:GetLevelSpecialValueFor("radius_start", ability_level) + GRMSC("ziv_elementalist_cold_blast_radius", caster)
	local radius_end = ability:GetLevelSpecialValueFor("radius_end", ability_level) + GRMSC("ziv_elementalist_cold_blast_radius", caster)
	local dummy_ability_name = keys.dummy_ability_name
	local projectile_name = keys.projectile_name
	local direction = (target_point - caster_location):Normalized()

	local deafening_dummy = CreateUnitByName("npc_dummy_unit", caster_location, false, caster, caster, caster:GetTeamNumber())
	deafening_dummy:AddAbility(dummy_ability_name)

	local dummy_ability = deafening_dummy:FindAbilityByName(dummy_ability_name)
	dummy_ability:SetLevel(1)

	local distance_traveled = 0
	local dummy_speed = travel_speed * 1/30

	local projectile_table =
	{
		EffectName = projectile_name,
		Ability = dummy_ability,
		vSpawnOrigin = caster_location,
		vVelocity = direction * travel_speed,
		fDistance = travel_distance,
		fStartRadius = radius_start,
		fEndRadius = radius_end,
		Source = deafening_dummy,
		bHasFrontalCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = ability:GetAbilityTargetTeam(),
		iUnitTargetFlags = ability:GetAbilityTargetFlags(),
		iUnitTargetType = ability:GetAbilityTargetType()
	}
	ProjectileManager:CreateLinearProjectile( projectile_table )

	Timers:CreateTimer(function()
		if distance_traveled < travel_distance then
			local dummy_location = deafening_dummy:GetAbsOrigin() + direction * dummy_speed
			deafening_dummy:SetAbsOrigin(dummy_location)
			distance_traveled = distance_traveled + dummy_speed

			return 1/30
		else
			Timers:CreateTimer(knockback_duration,function()
				deafening_dummy:RemoveSelf()
			end)
		end
	end)
end

function ColdBlastHit( keys )
	local caster = keys.caster
	local caster_owner = caster:GetOwner()
	local target = keys.target
	local ability = keys.ability
	local owner_ability = caster_owner:FindAbilityByName("ziv_elementalist_cold_blast")

	local damage = owner_ability:GetLevelSpecialValueFor("damage_amp", 1) * caster_owner:GetAverageTrueAttackDamage()

	DealDamage(caster_owner, target, damage, DAMAGE_TYPE_COLD)

	if GetRuneChance("ziv_elementalist_cold_blast_knockback_chance",caster_owner) then
		local knockback_modifier_table =
	    {
	        should_stun = 1,
	        knockback_duration = 1,
	        duration = 1,
	        knockback_distance = 100,
	        knockback_height = 80,
	        center_x = caster_owner:GetAbsOrigin().x,
	        center_y = caster_owner:GetAbsOrigin().y,
	        center_z = caster_owner:GetAbsOrigin().z
	    }
		target:AddNewModifier( caster_owner, nil, "modifier_knockback", knockback_modifier_table )
	end
end