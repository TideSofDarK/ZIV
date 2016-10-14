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
		if Distance(v, caster) < GetSpecial(ability, "aggro_radius") then
			caster:MoveToTargetToAttack(v)
			caster:RemoveModifierByName("ziv_creep_normal_behavior_logic")
			return
		end
	end
end