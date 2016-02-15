function ShotgunShot(args)
    local caster = args.caster
    local ability = args.ability
    local target = args.target

    if not ability then return end

    local bullet_count = ability:GetLevelSpecialValueFor("bullet_count", ability:GetLevel())

    local bullet = 1

    Timers:CreateTimer(caster:GetAttackAnimationPoint(), function (  )
        for bullet=1,bullet_count do
            local randomX = math.random(75, 30) * GetRandomSign()
            local randomY = math.random(75, 30) * GetRandomSign()

            local targetPoint = target:GetAbsOrigin() + Vector(randomX, randomY, 0)

            local distanceToTarget = (caster:GetAbsOrigin() - targetPoint):Length2D()
            local time = distanceToTarget/args.MoveSpeed

            local projectile = {
                vSpawnOrigin = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
                fStartRadius = 32,
                fEndRadius = 32,
                Source = caster,
                fExpireTime = 8.0,
                UnitBehavior = PROJECTILES_NOTHING,
                bMultipleHits = false,
                bIgnoreSource = true,
                TreeBehavior = PROJECTILES_NOTHING,
                bCutTrees = false,
                bTreeFullCollision = false,
                WallBehavior = PROJECTILES_NOTHING,
                GroundBehavior = PROJECTILES_NOTHING,
                fGroundOffset = 80,
                nChangeMax = 1,
                bRecreateOnChange = true,
                bZCheck = false,
                bGroundLock = true,
                bProvidesVision = true,
                iVisionRadius = 350,
                iVisionTeamNumber = caster:GetTeam(),
                bFlyingVision = false,
                fVisionTickTime = .1,
                fVisionLingerDuration = 1,
                draw = false,
                UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
                OnUnitHit = function(self, unit) 
                    local damageTable = {
                        victim = unit,
                        attacker = caster,
                        damage = caster:GetAverageTrueAttackDamage(),
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                    }
                    ApplyDamage(damageTable)
                end,
            }

            projectile.fDistance = distanceToTarget
            projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,0,0), (targetPoint - caster:GetAbsOrigin()):Normalized() ) * args.MoveSpeed

            Projectiles:CreateProjectile(projectile)

            local projectileFX = ParticleManager:CreateParticle(args.EffectName, PATTACH_CUSTOMORIGIN, caster)
            ParticleManager:SetParticleControl(projectileFX, 0, caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")))
            ParticleManager:SetParticleControl(projectileFX, 1, targetPoint)
            ParticleManager:SetParticleControl(projectileFX, 2, Vector(args.MoveSpeed, 0, 0))
            ParticleManager:SetParticleControl(projectileFX, 3, targetPoint)
            
            Timers:CreateTimer(time, function()
                ParticleManager:DestroyParticle(projectileFX, false)
            end)
        end
    end)
end