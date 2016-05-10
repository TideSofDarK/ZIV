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
  local ability = keys.ability
  local speed = unit:GetProjectileSpeed()
  local duration = unit:GetAttackAnimationPoint()

  local damage_amp = GetSpecial(ability, "damage_amp") or 1.0

  ability:StartCooldown(unit:GetAttackAnimationPoint())

  StartAnimation(unit, {duration=duration + unit:GetBaseAttackTime(), activity=ACT_DOTA_ATTACK, rate=1.0})

  unit:AddNewModifier(unit,ability,"modifier_custom_attack",{duration = duration + unit:GetBaseAttackTime()})

  local units = FindUnitsInRadius(unit:GetTeamNumber(),keys.target_points[1],nil,200,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false)

  if #units > 0 then
    keys.target_points[1] = units[1]:GetAbsOrigin() + Vector(0,0,64)
  end

  Timers:CreateTimer(duration, function()
    if unit:HasModifier("modifier_custom_attack") == false then
      return
    end

    if keys.sound then
      unit:EmitSound(keys.sound)
    end

    local offset = 64
    local lock = true
    local distanceToTarget = unit:GetAttackRange() * 1.5
    local origin = unit:GetAbsOrigin() + Vector(0,0,64)
    local direction = (Vector(keys.target_points[1].x, keys.target_points[1].y, 0) 
      - Vector(origin.x, origin.y, 0)):Normalized()
    local point = unit:GetAbsOrigin() + ((keys.target_points[1] - origin):Normalized() * distanceToTarget)
    if math.abs(origin.z - keys.target_points[1].z) < 128 then --
      point.z = unit:GetAbsOrigin().z + offset 
      lock = false
    end
    local time = (point - origin):Length2D()/speed

    local projectile = {
      vSpawnOrigin = origin,
      fStartRadius = 64,
      fEndRadius = 64,
      Source = unit,
      fExpireTime = 8.0,
      UnitBehavior = PROJECTILES_NOTHING,
      bMultipleHits = false,
      bIgnoreSource = true,
      TreeBehavior = PROJECTILES_NOTHING,
      bCutTrees = false,
      bTreeFullCollision = false,
      WallBehavior = PROJECTILES_NOTHING,
      GroundBehavior = PROJECTILES_DESROY,
      fGroundOffset = offset,
      nChangeMax = 1,
      bRecreateOnChange = true,
      bZCheck = false,
      bGroundLock = lock,
      bProvidesVision = false,
      fVisionTickTime = .1,
      fVisionLingerDuration = 0.5,
      draw = true,
      UnitTest = function(self, target) return target:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= target:GetTeamNumber() end,
    }

    projectile.OnUnitHit = (function(self, target) 
      DealDamage(unit, target, unit:GetAverageTrueAttackDamage() * damage_amp, DAMAGE_TYPE_PHYSICAL)
    end)

    projectile.fDistance = (point - origin):Length2D()
    projectile.vVelocity = direction * speed * 1.1 

    Projectiles:CreateProjectile(projectile)

    local projectileFX = ParticleManager:CreateParticle(keys.effect, PATTACH_CUSTOMORIGIN, unit)
    ParticleManager:SetParticleControl(projectileFX, 0, origin)
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