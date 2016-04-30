function Overload( keys )
	local caster = keys.caster
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetAbsOrigin(),nil,ability:GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	local maximum_targets = ability:GetSpecialValueFor("max_targets")

	local damage = 0
	local speed = 900

	if #units > 0 then
		caster:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")

		local particle

		Timers:CreateTimer(0.06, function (  )
			particle = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_plasmafield.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			-- ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin() + Vector(0,0,48))
			ParticleManager:SetParticleControl(particle, 1, Vector(speed,1000,1))	
		end)

		Timers:CreateTimer(0.5, function (  )
			ParticleManager:DestroyParticle(particle,false)
			ParticleManager:SetParticleControl(particle, 1, Vector(99999,1,1))	
		end)

		damage = clamp(#units, 1, maximum_targets) * (caster:GetAverageTrueAttackDamage() * ability:GetSpecialValueFor("damage_amp"))
	end

	i = 1

	for k,v in pairs(units) do
		if i <= maximum_targets then
			local arc = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_POINT, v)
			ParticleManager:SetParticleControl(arc, 0, caster:GetAbsOrigin() + Vector(0,0,48))
			ParticleManager:SetParticleControl(arc, 1, v:GetAbsOrigin() + Vector(0,0,48))

			Timers:CreateTimer((caster:GetAbsOrigin() - v:GetAbsOrigin()):Length2D() / speed, function (  )
				local particle = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_static_field.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
				DealDamage(caster, v, damage, DAMAGE_TYPE_LIGHTNING)
				v:EmitSound("Hero_Zuus.GodsWrath.Target")
			end)
			i = i + 1
		end
	end
end