function FireBlastImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability =  keys.ability

	DealDamage(caster, target, caster:GetAverageTrueAttackDamage() * ability:GetSpecialValueFor("damage_amp"), DAMAGE_TYPE_FIRE)

	ability:ApplyDataDrivenModifier(caster,target,"modifier_fire_blast_effect",{})
end