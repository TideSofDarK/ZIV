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
    caster:AddNoDraw()
	caster:ForceKill(false)
end

function SplitShot( keys )
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local pID = keys.caster:GetPlayerOwnerID()
    local hero = Characters:GetHero(pID)

    if caster:IsNull() or hero:HasModifier("ziv_huntress_ballista_chain") then
        return
    end

    Timers:CreateTimer(caster:GetAttackAnimationPoint(), function (  )
        if caster:IsNull() or caster:HasModifier("ziv_huntress_ballista_chain") then
            return
        end

        local arrows = GetSpecial(ability, "ballista_targets") + GRMSC("ziv_huntress_ballista_targets", caster) - 1

        keys.target_points = {} 
        keys.target_points[1] = caster:GetAbsOrigin() + (caster:GetForwardVector() * (caster:GetAttackRange() * 2))

        keys.effect = "particles/heroes/huntress/huntress_ballista_projectile.vpcf"
        keys.impact_effect = "particles/units/heroes/hero_windrunner/windrunner_base_attack_explosion_magic.vpcf"
        keys.attachment = "attach_attack1"
        keys.projectile_speed = caster:GetProjectileSpeed() 
        keys.ignore_z = true
        keys.spread = 300
        keys.spread_z = false
        keys.attack_sound = "Hero_Mirana.Attack"
        keys.interruptable = false
        keys.standard_targeting = false
        keys.force_destroy_tracking = true
        keys.duration = 0.0
        keys.rate = 0.0
        keys.base_attack_time = 0.0

        keys.on_hit = (function ( keys )
            SplitShotImpact( keys )
        end)

        for i=1,arrows do
            SimulateRangeAttack(keys)
        end
    end)

    -- local arrows = GetSpecial(ability, "ballista_targets") + GRMSC("ziv_huntress_ballista_targets", caster) - 1

    -- local angle = 40
    -- local start = angle/-2

    -- for i=start,angle/2,(angle / arrows) do
    --     if i <= 30 then
    --         local info = 
    --         {
    --             Ability = ability,
    --             EffectName = "particles/heroes/huntress/huntress_ballista_volley_projectile.vpcf",
    --             iMoveSpeed = 100,
    --             vSpawnOrigin = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
    --             fDistance = caster:GetAttackRange() * 2,
    --             fStartRadius = 48,
    --             fEndRadius = 48,
    --             Source = caster,
    --             bHasFrontalCone = false,
    --             bReplaceExisting = false,
    --             iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    --             iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    --             iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    --             fExpireTime = GameRules:GetGameTime() + 10.0,
    --             bDeleteOnHit = false,
    --             vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * caster:GetProjectileSpeed(),
    --         }
    --         local projectile = ProjectileManager:CreateLinearProjectile(info)
    --     end
    -- end

    -- EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Mirana.Attack", caster)
end

function Chain( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

    local pID = keys.caster:GetPlayerOwnerID()
    local hero = Characters:GetHero(pID)

    if caster:IsNull() or not hero:HasModifier("ziv_huntress_ballista_chain") then
        return
    end

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
    local pID = keys.caster:GetPlayerOwnerID()
    local caster = Characters:GetHero(pID)
    local target = keys.target
    local ability = keys.ability

    Damage:Deal( caster, target, GetRuneDamage(caster, GetSpecial(ability, "ballista_damage_amp"), ""), DAMAGE_TYPE_PHYSICAL )

    EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Mirana.ProjectileImpact", target)
end