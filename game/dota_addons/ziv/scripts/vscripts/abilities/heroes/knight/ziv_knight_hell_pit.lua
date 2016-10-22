function HellPit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

	local radius = GetSpecial(ability, "radius")

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

			ability:ApplyDataDrivenModifier(caster,unit,"modifier_hell_pit_cage", { duration = GetSpecial(ability, "root_duration") })

			Damage:Deal( caster, unit, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), ""), DAMAGE_TYPE_FIRE)

			unit:EmitSound("Hero_Nevermore.Shadowraze")
		end)
		t = t + delay
	end )
end