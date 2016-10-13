function CreateTrap( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	local duration = ability:GetLevelSpecialValueFor("snare_unit_duration", ability:GetLevel())

	local trap = CreateUnitByName("npc_dummy_unit", target, false, nil, caster:GetPlayerOwner(), caster:GetTeamNumber())
	caster.last_trap = trap

	InitAbilities(trap)

	local projTable = {
            EffectName = "particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",
            Ability = ability,
            Target = trap,
            Source = caster,
            bDodgeable = false,
            bProvidesVision = false,
            vSpawnOrigin = caster:GetAbsOrigin(),
            iMoveSpeed = 900,
            iVisionRadius = 0,
            iVisionTeamNumber = caster:GetTeamNumber(),
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
        }
    ProjectileManager:CreateTrackingProjectile(projTable)

    Timers:CreateTimer(duration, function (  )
    	UTIL_Remove(trap)
    end)
end

function CreateTrapUnit( keys )
	local caster = keys.caster
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster.last_trap, caster.last_trap, "modifier_trap_unit", {})
end

function RemoveTrapUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:RemoveModifierByName("modifier_trap_unit")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_trap_delay", {})
end

function SnareImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster,target,"modifier_ensnared",{duration = ability:GetSpecialValueFor("snare_duration") + GRMSC("ziv_huntress_trap_duration", caster)})
end