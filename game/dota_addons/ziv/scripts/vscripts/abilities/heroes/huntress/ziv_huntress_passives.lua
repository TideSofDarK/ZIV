function SplitShot( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	local units_in_burn_radius = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(),  nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	local projectile_info = 
    {
        EffectName = "particles/units/heroes/hero_windrunner/windrunner_base_attack.vpcf",
        Ability = ability,
        vSpawnOrigin = caster:GetAbsOrigin(),
        Target = nil,
        Source = target,
        bHasFrontalCone = false,
        iMoveSpeed = 3000,
        bReplaceExisting = false,
        bProvidesVision = false
    }

	for k,v in pairs(units_in_burn_radius) do
    	projectile_info.Target = v
    	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Sniper.Attack", target)
    	ProjectileManager:CreateTrackingProjectile(projectile_info)
	end
end

function SplitShotImpact( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    DealDamage( caster, target, caster:GetAverageTrueAttackDamage(), DAMAGE_TYPE_PHYSICAL )
end