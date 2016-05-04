function FireBlastImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability =  keys.ability

	DealDamage(caster, target, caster:GetAverageTrueAttackDamage() * ability:GetSpecialValueFor("damage_amp"), DAMAGE_TYPE_FIRE)

	ability:ApplyDataDrivenModifier(caster,target,"modifier_fire_blast_effect",{})
end

function FireBlast( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability =  keys.ability

	local info =
	{
		EffectName = "particles/heroes/elementalist/elementalist_fire_blast.vpcf",
		Ability = ability,
		vSpawnOrigin = caster:GetAbsOrigin(), 
		fStartRadius = 75 + GRMSC("ziv_elementalist_fire_blast_radius", caster),
		fEndRadius = 125 + GRMSC("ziv_elementalist_fire_blast_radius", caster),
		vVelocity = 900 * caster:GetForwardVector(),
		fDistance = 400,
		Source = caster,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	} 

	ProjectileManager:CreateLinearProjectile( info )
end