function ArcLightning( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

	local radius = GetSpecial(ability, "radius")
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

	if #units > 0 then
		caster:EmitSound("Hero_Zuus.ArcLightning.Cast")

		ArcLightningChain( caster, caster, units[1], ability )

		local particle = ParticleManager:CreateParticle("particles/heroes/elementalist/elementalist_arc_lightning.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 1, units[1], PATTACH_POINT_FOLLOW, "attach_hitloc", units[1]:GetAbsOrigin(), true)

		-- Damage:Deal(caster, units[1], GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), ""), DAMAGE_TYPE_LIGHTNING)

		local last_target = units[1]

		units[1] = nil
		local shuffled_units = Shuffle(units)

		for i=1,GetSpecial(ability, "max_targets") do
			if shuffled_units[i] then
				ArcLightningChain( caster, last_target, shuffled_units[i], ability )

				last_target = shuffled_units[i]
			end
		end
	end
end

function ArcLightningChain( caster, first_target, second_target, ability )
	local particle = ParticleManager:CreateParticle("particles/heroes/elementalist/elementalist_arc_lightning.vpcf",PATTACH_CUSTOMORIGIN, first_target)
	ParticleManager:SetParticleControlEnt(particle, 0, first_target, PATTACH_POINT_FOLLOW, "attach_hitloc", first_target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, second_target, PATTACH_POINT_FOLLOW, "attach_hitloc", second_target:GetAbsOrigin(), true)

	Damage:Deal(caster, second_target, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), ""), DAMAGE_TYPE_LIGHTNING)
end