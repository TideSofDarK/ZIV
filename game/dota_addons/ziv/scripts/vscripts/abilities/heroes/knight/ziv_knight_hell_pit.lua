function HellPit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

	StartRuneCooldown(ability,"ziv_knight_hell_pit_cd",caster)

	local radius = GetSpecial(ability, "radius") + GRMSC("ziv_knight_hell_pit_radius", caster)

	local ring = ParticleManager:CreateParticle("particles/heroes/knight/knight_hell_pit_ring.vpcf",PATTACH_CUSTOMORIGIN,nil)
	ParticleManager:SetParticleControl(ring,0,target)
	ParticleManager:SetParticleControl(ring,1,target)
	ParticleManager:SetParticleControl(ring,4,Vector(radius,0,0))
	ParticleManager:SetParticleControl(ring,5,Vector(radius,40,1))

	local delay = 0.05
	local t = 0.0

	DoToUnitsInRadius( caster, target, radius, target_team, target_type, target_flags, function ( unit )
		Timers:CreateTimer(t, function (  )
			TimedEffect("particles/heroes/knight/knight_hell_pit.vpcf", unit, 1.0)

			local duration = GetSpecial(ability, "root_duration") + (GRMSC("ziv_knight_hell_pit_duration", caster) / 100)

			ability:ApplyDataDrivenModifier(caster,unit,"modifier_hell_pit_cage", { duration = duration })

			Damage:Deal( caster, unit, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "ziv_knight_hell_pit_damage"), DAMAGE_TYPE_FIRE)

			unit:EmitSound("Hero_Nevermore.Shadowraze")
		end)
		t = t + delay
	end )
end