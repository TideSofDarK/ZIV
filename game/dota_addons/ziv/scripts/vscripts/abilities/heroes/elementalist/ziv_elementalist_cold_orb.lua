function ColdOrbImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(),target:GetAbsOrigin(),nil,ability:GetSpecialValueFor("Radius"),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false)

	for k,v in pairs(units) do
		if IsValidEntity(v) then
			DealDamage(caster, v, caster:GetAverageTrueAttackDamage() * ability:GetSpecialValueFor("damage_amp"), DAMAGE_TYPE_MAGICAL)
			ability:ApplyDataDrivenModifier(caster,v,"modifier_cold_orb_effect",{})
		end
	end
end