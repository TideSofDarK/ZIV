function SpawnBallista( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

    StartRuneCooldown(ability,"ziv_huntress_ballista_cd",caster)

	local _duration = ability:GetLevelSpecialValueFor("ballista_duration", ability:GetLevel())

	local ballista = CreateUnitByName("npc_huntress_ballista", target, false, caster, caster, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(ballista,ballista,"modifier_ballista",{})

    ability:ApplyDataDrivenModifier(ballista,ballista,"modifier_ballista_as",{})
    ballista:SetModifierStackCount("modifier_ballista_as",ballista,GRMSC("ziv_huntress_ballista_as", caster))

	ballista:AddNewModifier(ballista, nil, "modifier_kill", {duration = _duration})

    ballista.bottom = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/units/ballista/ballista_bottom.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    ballista.bottom:SetAbsOrigin(target)
    ballista.bottom:SetModelScale(ballista:GetModelScale())
end

function BallistaDeath( keys )
	local caster = keys.caster
	local ability = keys.ability

    UTIL_Remove(caster.bottom)
	caster:RemoveSelf()
end

function SplitShot( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(),  nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

    local targets = GetSpecial(ability, "ballista_targets") + GRMSC("ziv_huntress_ballista_targets", caster)

    EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Mirana.Attack", target)

    local i = 1

	for k,v in pairs(units) do
        if v:entindex() ~= target:entindex() then
            if i > targets then
                break
            end
            local projectile_info = 
            {
                EffectName = "particles/heroes/huntress/huntress_ballista_projectile.vpcf",
                Ability = ability,
                Target = v,
                Source = target,
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                bHasFrontalCone = false,
                iMoveSpeed = caster:GetProjectileSpeed(),
                bReplaceExisting = false,
                bProvidesVision = false
            }

            ProjectileManager:CreateTrackingProjectile(projectile_info)

            i = i + 1
        end
	end
end

function SplitShotImpact( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    Damage:Deal( caster, target, GetRuneDamage(caster, GetSpecial(ability, "ballista_damage_amp"), ""), DAMAGE_TYPE_PHYSICAL )

    EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Mirana.ProjectileImpact", target)
end