function WDSpawn( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local duration = ability:GetSpecialValueFor("duration")
	local count = ability:GetSpecialValueFor("count")

	local creep_name = keys.creep or "npc_witch_doctor_skeleton"

	if not string.match(ability:GetName(), "2") then -- Skeletons
		StartRuneCooldown(ability,"ziv_witch_doctor_spawn_cd", caster)
		count = count + GRMSC("ziv_witch_doctor_spawn_count", caster)
	else -- Zombies
		StartRuneCooldown(ability,"ziv_witch_doctor_spawn2_cd", caster)
		count = count + GRMSC("ziv_witch_doctor_spawn2_count", caster)
	end

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target, nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	if #units > 0 then
		for i=1,clamp(#units, 1, count) do
			SpawnWDCreep(caster, units[i]:GetAbsOrigin(), duration, units[i], ability, keys.creep, keys.modifier)
		end
	end

	for i=1,(count - #units) do
		SpawnWDCreep(caster, target + RandomPointInsideCircle(0, 0, 300), duration, nil, ability, creep_name, keys.modifier)
	end
end

function SpawnWDCreep(caster, pos, duration, target, ability, creep_name, modifier_name)
	CreateUnitByNameAsync(creep_name,pos,true,caster,caster,caster:GetTeamNumber(),function (creep)
		local visuals = Director:GenerateVisuals( creep:GetUnitName() )
		if visuals.wearables_table then
			for k,v in pairs(visuals.wearables_table) do
				Wearables:AttachWearable(creep, v)
			end
		end

		ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_zombie_spawn_dirt02.vpcf", PATTACH_ABSORIGIN, creep)

		creep:AddNewModifier(caster,ability,"modifier_kill",{duration = duration})
		ability:ApplyDataDrivenModifier(caster,creep,modifier_name or "modifier_witch_doctor_skeleton",{})
		if target then
			creep:MoveToTargetToAttack(target)
		else
			creep:MoveToPositionAggressive(pos + RandomPointInsideCircle(0, 0, 200))
			Timers:CreateTimer(math.random(0.0, 4.0), function ()
				creep:MoveToPositionAggressive(pos + RandomPointInsideCircle(0, 0, 300))
			end)
		end
	end)
end

function ZombieHitImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local attacker = keys.attacker
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster,target,"modifier_witch_doctor_zombie_slow",{duration=GetSpecial(ability, "attack_slow_duration")})
	target:SetModifierStackCount("modifier_witch_doctor_zombie_slow",caster,GetSpecial(ability, "attack_slow"))
	Damage:Deal( caster, target, GetRuneDamage(caster, GetSpecial(ability, "zombie_damage_amp"), ""), DAMAGE_TYPE_PHYSICAL )
end

function SkeletonHitImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local attacker = keys.attacker
	local ability = keys.ability

	Damage:Deal( caster, target, GetRuneDamage(caster, GetSpecial(ability, "skeleton_damage_amp"), ""), DAMAGE_TYPE_PHYSICAL )
end