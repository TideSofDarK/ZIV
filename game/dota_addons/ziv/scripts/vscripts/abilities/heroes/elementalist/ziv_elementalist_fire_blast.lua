function FireBlastCast( keys )
	local caster = keys.caster
	local target = keys.target
	local ability =  keys.ability
	
	StartAnimation(caster, {duration=ability:GetCastPoint(), activity=ACT_DOTA_CAST_SUN_STRIKE, rate=1.0, translate="divine_sorrow_sunstrike"})
	caster:EmitSound("Hero_AbyssalUnderlord.Firestorm.Cast")

	caster:AddNewModifier(caster,ability,"modifier_command_restricted",{duration=ability:GetCastPoint()})
end

function FireBlast( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability =  keys.ability

	StartRuneCooldown(ability,"ziv_elementalist_fire_blast_cd",caster)

	if GetRuneChance("ziv_elementalist_fire_blast_double_chance",caster) then
		ability:EndCooldown()
	end

	local radius = GetSpecial(ability, "radius")

	local waves = GetSpecial(ability, "waves")
	local wave_delay = GetSpecial(ability, "wave_delay")
	local wave_radius = GetSpecial(ability, "wave_radius")

	local points = RandomPointsInsideCircleUniform( target, radius, waves, wave_radius )

	for i=0,waves-1 do
		Timers:CreateTimer(i * wave_delay, function (  )
			local wave = ParticleManager:CreateParticle("particles/heroes/elementalist/elementalist_fire_blast_wave.vpcf",PATTACH_CUSTOMORIGIN,nil)
			ParticleManager:SetParticleControl(wave, 0, points[i+1])

			Timers:CreateTimer(0.15, function ()
				EmitSoundOnLocationWithCaster(points[i+1],"Hero_AbyssalUnderlord.Firestorm",caster)
				DoToUnitsInRadius(caster, points[i+1], wave_radius, target_team, target_type, target_flags, function ( v )
					Damage:Deal(caster, v, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "ziv_elementalist_fire_blast_damage"), DAMAGE_TYPE_FIRE)
					EmitSoundOnLocationWithCaster(v:GetAbsOrigin(),"Hero_AbyssalUnderlord.Firestorm.Target",caster)
				end)
			end)
		end)
	end
end