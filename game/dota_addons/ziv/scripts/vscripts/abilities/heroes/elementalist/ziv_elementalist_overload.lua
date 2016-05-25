function Overload( keys )
	local caster = keys.caster
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetAbsOrigin(),nil,ability:GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	local maximum_targets = ability:GetSpecialValueFor("max_targets") + GRMSC("ziv_elementalist_overload_targets", caster)

	local damage = 0
	local speed = 900

	if #units > 0 then
		caster:EmitSound("Hero_Crystal.CrystalNova")

		local particle
		TimedEffect("particles/econ/items/ancient_apparition/aa_blast_ti_5/ancient_apparition_ice_blast_explode_ti5.vpcf", caster, 2.0, 3)
		TimedEffect("particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf", caster, 2.0)

		damage = clamp(#units, 1, maximum_targets) * (caster:GetAverageTrueAttackDamage() * ability:GetSpecialValueFor("damage_amp"))
	end

	i = 1

	for k,v in pairs(units) do
		if i <= maximum_targets then
			local arc = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_POINT, v)
			ParticleManager:SetParticleControl(arc, 0, caster:GetAbsOrigin() + Vector(0,0,48))
			ParticleManager:SetParticleControl(arc, 1, v:GetAbsOrigin() + Vector(0,0,48))

			DealDamage(caster, v, GetRunePercentIncrease(damage/3,"ziv_elementalist_overload_lightning_damage",caster), DAMAGE_TYPE_LIGHTNING) 
			DealDamage(caster, v, GetRunePercentIncrease(damage/3,"ziv_elementalist_overload_cold_damage",caster), DAMAGE_TYPE_COLD)

			ability:ApplyDataDrivenModifier(caster,v,"modifier_overload_frozen",{})

			-- v:EmitSound("Hero_Zuus.GodsWrath.Target")
			

			Timers:CreateTimer(((caster:GetAbsOrigin() - v:GetAbsOrigin()):Length2D() / speed) + 0.2, function (  )
				local particle = ParticleManager:CreateParticle("particles/heroes/elementalist/elementalist_overload_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
				DealDamage(caster, v, GetRunePercentIncrease(damage/3,"ziv_elementalist_overload_fire_damage",caster), DAMAGE_TYPE_FIRE)

				ability:ApplyDataDrivenModifier(caster,v,"modifier_overload_burn",{})
				v:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
				-- v:EmitSound("Hero_SkeletonKing.Hellfire_BlastImpact")
			end)
			i = i + 1
		end
	end
end