function SpawnBallista( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

	local _duration = ability:GetLevelSpecialValueFor("ballista_duration", ability:GetLevel())

	local ballista = CreateUnitByName("npc_huntress_ballista", target, false, nil, caster:GetPlayerOwner(), caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(ballista,ballista,"modifier_ballista",{})

	ballista:AddNewModifier(ballista, nil, "modifier_kill", {duration = _duration})
end

function BallistaDeath( keys )
	local caster = keys.caster
	local ability = keys.ability

	UTIL_Remove(caster)
end

function SplitShot( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	local units_in_burn_radius = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(),  nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	local projectile_info = 
    {
        EffectName = "particles/base_attacks/ranged_siege_good.vpcf",
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