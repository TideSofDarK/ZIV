function OnAttackLanded( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if caster._OnAttackLandedCallbacks then
		for k,v in pairs(caster._OnAttackLandedCallbacks) do
			v(target)
		end
	end
end

function InitAI( keys )
	local caster = keys.caster
	local ability = keys.ability

	AI:CreepStart( caster )
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

function CheckRange( keys )
	local caster = keys.caster
	local ability = keys.ability

	local target = caster:GetAttackTarget() or keys.target
	keys.target = target

	if not caster:IsRangedAttacker() then return end

	if GridNav:FindPathLength(target:GetAbsOrigin(), caster:GetAbsOrigin()) > caster:GetAttackRange() then
		caster:MoveToNPC(target)

		Timers:CreateTimer(0.25, function ()
			if target:IsAlive() then
				CheckRange( keys )
			end
		end)
	else
		caster:MoveToTargetToAttack(target)
	end
end