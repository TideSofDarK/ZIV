function SMGRush( keys )
    local caster = keys.caster
    local ability = keys.ability

    ability:ApplyDataDrivenModifier(caster,caster,"modifier_smg_rush_active",{duration = ability:GetSpecialValueFor("duration") + GRMSC("ziv_sniper_smg_rush_duration", caster)})
end

function DoubleAttack( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local base_attack_particle = keys.base_attack_particle

    local projectile_info = 
    {
        EffectName = base_attack_particle,
        Ability = ability,
        vSpawnOrigin = caster:GetAbsOrigin(),
        Target = target,
        Source = caster,
        bHasFrontalCone = false,
        iMoveSpeed = 3000,
        bReplaceExisting = false,
        bProvidesVision = false
    }

    Timers:CreateTimer(0.7, function (  )
    	StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_ATTACK, rate=2.5})

    	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Sniper.Attack", caster)
    	ProjectileManager:CreateTrackingProjectile(projectile_info)
    end)
end

function DoubleAttackDamage( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.victim = target
    damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
    damage_table.damage = caster:GetAverageTrueAttackDamage()

    ApplyDamage(damage_table)
end