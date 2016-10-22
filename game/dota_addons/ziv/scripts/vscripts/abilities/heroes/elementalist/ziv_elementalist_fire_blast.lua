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

	local info =
	{
		EffectName = "particles/heroes/elementalist/elementalist_fire_blast.vpcf",
		Ability = ability,
		vSpawnOrigin = caster:GetAbsOrigin(), 
		fStartRadius = GetSpecial(ability, "start_radius") + GRMSC("ziv_elementalist_fire_blast_radius", caster),
		fEndRadius = GetSpecial(ability, "end_radius") + GRMSC("ziv_elementalist_fire_blast_radius", caster),
		vVelocity = 900 * caster:GetForwardVector(),
		fDistance = 400,
		Source = caster,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	} 

	ProjectileManager:CreateLinearProjectile( info )
end