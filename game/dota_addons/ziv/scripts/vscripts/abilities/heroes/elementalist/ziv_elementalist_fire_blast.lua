function FireBlastImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability =  keys.ability
	
	local damage = GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "")
	if GetRuneChance("ziv_elementalist_fire_blast_crit_chance",caster) then
		damage = damage * GetSpecial(ability, "crit_damage")
	end

	Damage:Deal(caster, target, damage, DAMAGE_TYPE_FIRE)

	ability:ApplyDataDrivenModifier(caster,target,"modifier_fire_blast_effect",{})
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

			Timers:CreateTimer(0.2, function ()
				DoToUnitsInRadius(caster, points[i+1], wave_radius, target_team, target_type, target_flags, function ( v )
					Damage:Deal(caster, v, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "ziv_elementalist_fire_blast_damage"), DAMAGE_TYPE_FIRE)
				end)
			end)
		end)
	end
end