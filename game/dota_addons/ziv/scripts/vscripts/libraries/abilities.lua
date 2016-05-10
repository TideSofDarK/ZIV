function SetHull( keys )
  local caster = keys.caster
  caster:SetHullRadius(tonumber(keys.size))
end

function SetToggleState( ability, state )
  if ability:GetToggleState() ~= state then
    ability:ToggleAbility()
  end
end

function SimulateRangeAttack( keys  )
  local unit = keys.caster
  local point = keys.target_points[1]
  local ability = keys.ability
  local speed = unit:GetProjectileSpeed()
  local duration = unit:GetAttackAnimationPoint()

  local damage_amp = GetSpecial(ability, "damage_amp")

  point.z = unit:GetAbsOrigin().z

  ability:StartCooldown(unit:GetAttackAnimationPoint())

  StartAnimation(unit, {duration=duration + unit:GetBaseAttackTime(), activity=ACT_DOTA_ATTACK, rate=1.0})

  unit:AddNewModifier(unit,ability,"modifier_custom_attack",{duration = duration + unit:GetBaseAttackTime()})

  Timers:CreateTimer(duration, function()
    if unit:HasModifier("modifier_custom_attack") == false then
      return
    end

    if keys.sound then
      unit:EmitSound(keys.sound)
    end

    local distanceToTarget = (unit:GetAbsOrigin() - point):Length2D() + 100
    local time = distanceToTarget/speed

    local projectile = {
      vSpawnOrigin = unit:GetAttachmentOrigin(unit:ScriptLookupAttachment("attach_attack1")),
      fStartRadius = 64,
      fEndRadius = 64,
      Source = unit,
      fExpireTime = 8.0,
      UnitBehavior = PROJECTILES_DESTROY,
      bMultipleHits = false,
      bIgnoreSource = true,
      TreeBehavior = PROJECTILES_NOTHING,
      bCutTrees = false,
      bTreeFullCollision = false,
      WallBehavior = PROJECTILES_NOTHING,
      GroundBehavior = PROJECTILES_NOTHING,
      fGroundOffset = 64,
      nChangeMax = 1,
      bRecreateOnChange = true,
      bZCheck = false,
      bGroundLock = false,
      bProvidesVision = false,
      fVisionTickTime = .1,
      fVisionLingerDuration = 0.5,
      draw = true,
      UnitTest = function(self, target) return target:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= target:GetTeamNumber() end,
    }

    projectile.OnUnitHit = (function(self, target) 
      DealDamage(unit, target, unit:GetAverageTrueAttackDamage() * damage_amp, DAMAGE_TYPE_PHYSICAL)
    end)

    projectile.fDistance = distanceToTarget
    projectile.vVelocity = (unit:GetAttachmentOrigin(unit:ScriptLookupAttachment("attach_attack1")) - point):Normalized() * speed * -1.1 

    Projectiles:CreateProjectile(projectile)

    local projectileFX = ParticleManager:CreateParticle(keys.effect, PATTACH_CUSTOMORIGIN, unit)
    ParticleManager:SetParticleControl(projectileFX, 0, unit:GetAttachmentOrigin(unit:ScriptLookupAttachment("attach_attack1")))
    ParticleManager:SetParticleControl(projectileFX, 1, point)
    ParticleManager:SetParticleControl(projectileFX, 2, Vector(speed, 0, 0))
    ParticleManager:SetParticleControl(projectileFX, 3, point)

    Timers:CreateTimer(time, function()
      ParticleManager:DestroyParticle(projectileFX, false)
    end)
  end)
end

function GetSpecial( ability, name )
  return ability:GetLevelSpecialValueFor(name,ability:GetLevel()-1)
end

function InitAbilities( hero )
  for i=0, hero:GetAbilityCount()-1 do
    local abil = hero:GetAbilityByIndex(i)
    if abil ~= nil then
      if hero:IsHero() and hero:GetAbilityPoints() > 0 then
        hero:UpgradeAbility(abil)
      else
        abil:SetLevel(1)
      end
    end
  end
end

function AddAbilityAndUpgrade( unit, ability )
  unit:AddAbility(ability)
  unit:FindAbilityByName(ability):UpgradeAbility(false)
end