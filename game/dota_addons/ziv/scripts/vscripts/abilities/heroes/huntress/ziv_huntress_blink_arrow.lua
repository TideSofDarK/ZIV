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
	end)

	Timers:CreateTimer(0.50, function(  )
		ParticleManager:CreateParticle("particles/econ/events/ti5/blink_dagger_end_lvl2_ti5.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_smoke.vpcf", PATTACH_ABSORIGIN, caster)
	end)
end
