function CheckUnits( keys )
	local caster = keys.caster
	local trap = keys.trap
	local ability = keys.ability

	if trap then
		local units_in_radius = FindUnitsInRadius(caster:GetTeamNumber(), trap:GetAbsOrigin(),  nil, ability:GetSpecialValueFor("trap_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

		if #units_in_radius > 0 then
			RemoveTrapUnit( keys )
		end
	end
end

function TrapTimer( keys, check, remove, duration )
	local time = 0

	Timers:CreateTimer(function (  )
		if keys.trap and keys.trap:IsNull() == false and not keys.trap.worldPanel then
			if time < duration then
				if check then 
					check( keys )
				end
			else
				remove( keys )
			end
		end
		time = time + 0.2
		return 0.2
	end)
end