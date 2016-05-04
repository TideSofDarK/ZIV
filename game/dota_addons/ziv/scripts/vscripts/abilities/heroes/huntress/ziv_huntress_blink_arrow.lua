function FireArrow( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local arrow = ParticleManager:CreateParticle("particles/ui_mouseactions/clicked_attackmove_unused.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(arrow, 0, target) 
end

function Blink( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	Timers:CreateTimer(0.48, function(  )
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(),"Hero_QueenOfPain.Blink_out",caster)
		ParticleManager:CreateParticle("particles/econ/events/ti5/blink_dagger_start_sparkles_ti5.vpcf", PATTACH_ABSORIGIN, caster)
	end)

	Timers:CreateTimer(0.49, function(  )
		caster:SetAbsOrigin(target)
		EmitSoundOnLocationWithCaster(target,"Hero_QueenOfPain.Blink_in",caster)

		local units = FindUnitsInRadius(caster:GetTeamNumber(), target,  nil, 75 + GRMSC("ziv_huntress_blink_arrow_radius", caster), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for k,v in pairs(units) do
			DealDamage(caster, v, caster:GetAverageTrueAttackDamage(), DAMAGE_TYPE_PHYSICAL)
		end
	end)

	Timers:CreateTimer(0.50, function(  )
		ParticleManager:CreateParticle("particles/econ/events/ti5/blink_dagger_end_lvl2_ti5.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_smoke.vpcf", PATTACH_ABSORIGIN, caster)
	end)
end
