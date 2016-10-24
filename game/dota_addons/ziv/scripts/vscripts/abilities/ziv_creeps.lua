AI_FLAGS_FLEE_ON_LOW_HP 		= 0
AI_FLAGS_MOVE_DURING_FIGHT 		= 1
AI_FLAGS_TRY_TO_KEEP_DISTANCE 	= 2

function InitAI( keys )
	local caster = keys.caster
	local ability = keys.ability

	local flags_string = ZIV.UnitKVs[caster:GetUnitName()]["AIFlags"]
	if flags_string then
		local flags = KeyValues:Split(flags_string, " | ")
		PrintTable(falgs)
		for k,v in pairs(flags) do
			print(caster:GetUnitName(), v)
			if _G[v] then
				print(caster:GetUnitName(), v)
			end
		end
	end
end

function AggroNearbyCreeps(keys)
	local caster = keys.caster
	local ability = keys.ability

	DoToUnitsInRadius(caster, caster:GetAbsOrigin(), GetSpecial(ability, "aggro_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, nil, nil, function (v)
		v:MoveToPositionAggressive(caster:GetAbsOrigin())
	end)
end

function CheckForHeroes(keys)
	local caster = keys.caster
	local ability = keys.ability

	for k,v in pairs(Characters.current_session_characters) do
		if GridNav:FindPathLength(v:GetAbsOrigin(),caster:GetAbsOrigin()) < GetSpecial(ability, "aggro_radius") then
			caster:MoveToTargetToAttack(v)
			caster:RemoveModifierByName("ziv_creep_normal_behavior_logic")
			return
		end
	end
end