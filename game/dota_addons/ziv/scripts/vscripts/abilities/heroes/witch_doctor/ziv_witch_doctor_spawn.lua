function randomPointInCircle(x, y, radius)
	local randX, randY
	repeat
		randX, randY = math.random(-radius, radius), math.random(-radius, radius)
	until (((-randX) ^ 2) + ((-randY) ^ 2)) ^ 0.5 <= radius
	return Vector(x + randX, y + randY, 0)
end

function WDSpawn( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local count = ability:GetSpecialValueFor("count")
	local duration = ability:GetSpecialValueFor("duration")

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target, nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	if #units > 0 then
		for i=1,clamp(#units, 1, count) do
			SpawnWDCreep(caster, units[i]:GetAbsOrigin(), duration, units[i], ability, keys.creep, keys.modifier)
		end
	end

	for i=1,(count - #units) do
		SpawnWDCreep(caster, target + randomPointInCircle(0, 0, 300), duration, nil, ability, keys.creep, keys.modifier)
	end
end

function SpawnWDCreep(caster, pos, _duration, target, ability, creep_name, modifier_name)
	local creep = CreateUnitByName(creep_name or "npc_witch_doctor_skeleton",pos,true,caster,caster,caster:GetTeamNumber())

	ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_zombie_spawn_dirt02.vpcf", PATTACH_ABSORIGIN, creep)

	creep:AddNewModifier(caster,ability,"modifier_kill",{duration = _duration})
	ability:ApplyDataDrivenModifier(caster,creep,modifier_name or "modifier_witch_doctor_skeleton",{})
	if target then
		creep:MoveToTargetToAttack(target)
	else
		Timers:CreateTimer(math.random(0.0, 4.0), function ()
			creep:MoveToPositionAggressive(pos + randomPointInCircle(0, 0, 300))
		end)
	end
end