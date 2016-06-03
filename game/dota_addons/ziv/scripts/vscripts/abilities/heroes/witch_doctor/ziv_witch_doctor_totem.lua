function CreateTotem( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	-- StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.0})

	StartSoundEvent("Hero_WitchDoctor.Death_WardBuild",caster)

	local duration = ability:GetLevelSpecialValueFor("totem_duration", ability:GetLevel())

	local totem = CreateUnitByName("npc_witch_doctor_totem", target, false, nil, caster:GetPlayerOwner(), caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(totem,totem,"modifier_witch_doctor_totem",{duration = duration})
	InitAbilities(totem)

	Timers:CreateTimer(0.6, function (  )
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_skull.vpcf",PATTACH_POINT,totem)
		ParticleManager:SetParticleControlEnt(particle, 0, totem, PATTACH_POINT_FOLLOW, "attach_attack1", totem:GetAbsOrigin(), false)
		ParticleManager:SetParticleControlEnt(particle, 2, totem, PATTACH_POINT_FOLLOW, "attach_attack1", totem:GetAbsOrigin(), false)

		AddChildParticle( totem, particle )
	end)

	keys.totem = totem
end

function CreateTotem2( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local duration = ability:GetLevelSpecialValueFor("totem_duration", ability:GetLevel()) + GRMSC("ziv_witch_doctor_totem2_duration", caster)

	local totem = CreateUnitByName("npc_witch_doctor_totem2", target, false, nil, caster:GetPlayerOwner(), caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(totem,totem,"modifier_witch_doctor_totem2",{duration = duration})
	InitAbilities(totem)

	Timers:CreateTimer(0.3, function (  )
		local particle = ParticleManager:CreateParticle("particles/heroes/witch_doctor/witch_doctor_totem2_fx.vpcf",PATTACH_OVERHEAD_FOLLOW,totem)

		AddChildParticle( totem, particle )

		if totem:IsNull() ~= true and totem:IsAlive() ~= false then return 0.8 end
	end)

	keys.totem = totem
end

function RemoveTotem( keys )
	local caster = keys.caster

	if string.match(caster:GetUnitName(), "npc_witch_doctor_totem") then
		StopSoundEvent("Hero_WitchDoctor.Death_WardBuild",caster)
		caster:RemoveModifierByName("dummy_unit")
		caster:ForceKill(false)
	end
end

function SplitShot( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	Timers:CreateTimer(0.2, function ()
		if caster:IsNull() == false then
			caster:EmitSound("Hero_WitchDoctor_Ward.Attack")
			local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),  nil, 550 + GRMSC("ziv_witch_doctor_totem_radius", caster:GetOwnerEntity()), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

			local targets = ability:GetSpecialValueFor("totem_targets") + GRMSC("ziv_witch_doctor_totem_targets", caster)
			local i = 1
			for k,v in pairs(units) do
				if i >= targets then break end
				if v ~= target then 
					local projectile_info = 
				    {
				        EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_ward_attack.vpcf",
				        Ability = ability,
				        vSpawnOrigin = caster:GetAbsOrigin(),
				        Target = v,
				        Source = caster,
				        bHasFrontalCone = false,
				        iMoveSpeed = 800 + math.random(0, 500),
				        bReplaceExisting = false,
				        bProvidesVision = false
				    }
			    	ProjectileManager:CreateTrackingProjectile(projectile_info)
			    	i = i + 1
				end
			end
		end
	end)
end

function SplitShotImpact( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    local damage_amp = ability:GetSpecialValueFor("damage_amp")

    DealDamage( caster, target, caster:GetAverageTrueAttackDamage() * damage_amp, DAMAGE_TYPE_DARK )
end

function Pulling( keys )
	local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    if not target.pulling then
    	target.pulling = ParticleManager:CreateParticle("particles/heroes/witch_doctor/witch_doctor_totem2_lasso.vpcf", PATTACH_CUSTOMORIGIN, caster)

    	ParticleManager:SetParticleControlEnt(target.pulling, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin() + Vector(0,0,16), true)
    	ParticleManager:SetParticleControlEnt(target.pulling, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin() + Vector(0,0,16), true)
    
    	Timers:CreateTimer(0.3, function (  )
    		ParticleManager:DestroyParticle(target.pulling,false)
    		target.pulling = nil
    	end)
    end

    local caster_position = caster:GetAbsOrigin()
    local target_position = target:GetAbsOrigin()

    local angle =math.atan2(target_position.y - caster_position.y, target_position.x - caster_position.x)

	target_position.x = target_position.x - (math.cos(angle) * (64 + GRMSC("ziv_witch_doctor_totem2_force", caster)))
	target_position.y = target_position.y - (math.sin(angle) * (64 + GRMSC("ziv_witch_doctor_totem2_force", caster)))

	local speed = 2.5

	local time = 0
    Timers:CreateTimer(function ()
    	if time < 0.35 then
	    	-- if (caster_position - caster_position):Length() > 30 then return end

			FindClearSpaceForUnit(target, lerp_vector(target:GetAbsOrigin(), target_position, 0.03 * speed), false)
			time = time + 0.03
	    	return 0.03
    	end
    end)
end