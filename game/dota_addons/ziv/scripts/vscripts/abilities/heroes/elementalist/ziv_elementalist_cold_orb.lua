function FireOrb( keys )
	keys.on_hit = ColdOrbOnHit
	keys.standard_targeting = true
	keys.impact_sound = "Hero_Ancient_Apparition.ProjectileImpact"
	SimulateRangeAttack(keys)
end

function ColdOrbOnHit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(),target:GetAbsOrigin(),nil,ability:GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false)

	for k,v in pairs(units) do
		if IsValidEntity(v) then
			DealDamage(caster, v, GetRuneDamage("ziv_elementalist_cold_orb_damage",caster) * GetSpecial(ability,"damage_amp"), DAMAGE_TYPE_COLD)
			ability:ApplyDataDrivenModifier(caster,v,"modifier_cold_orb_effect",{})
		end
	end
end 