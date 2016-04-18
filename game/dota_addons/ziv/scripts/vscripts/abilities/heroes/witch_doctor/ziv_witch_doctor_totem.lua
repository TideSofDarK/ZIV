function CreateTotem( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	-- StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.0})

	StartSoundEvent("Hero_WitchDoctor.Death_WardBuild",caster)

	local _duration = ability:GetLevelSpecialValueFor("totem_duration", ability:GetLevel())

	local totem = CreateUnitByName("npc_witch_doctor_totem", target, false, nil, caster:GetPlayerOwner(), caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(totem,totem,"modifier_witch_doctor_totem",{duration = _duration})
	InitAbilities(totem)

	Timers:CreateTimer(0.3, function (  )
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_ward_skull.vpcf",PATTACH_POINT,totem)
		ParticleManager:SetParticleControlEnt(particle, 0, totem, PATTACH_POINT_FOLLOW, "attach_attack1", totem:GetAbsOrigin(), false)

		AddChildParticle( totem, particle )
	end)

	keys.totem = totem
end

function RemoveTotem( keys )
	local caster = keys.caster

	if caster:GetUnitName() == "npc_witch_doctor_totem" then
		StopSoundEvent("Hero_WitchDoctor.Death_WardBuild",caster)
		caster:RemoveModifierByName("dummy_unit")
		caster:Kill(keys.ability, keys.caster)
	end
end

function SplitShot( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	Timers:CreateTimer(0.2, function ()
		if caster:IsNull() == false then
			caster:EmitSound("Hero_WitchDoctor_Ward.Attack")
			local units_in_burn_radius = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),  nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

			for k,v in pairs(units_in_burn_radius) do
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

    DealDamage( caster, target, caster:GetAverageTrueAttackDamage() * damage_amp, DAMAGE_TYPE_PHYSICAL )
end