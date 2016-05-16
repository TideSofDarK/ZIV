function SetHull( keys )
  local caster = keys.caster
  caster:SetHullRadius(tonumber(keys.size))
end

function UnitLookAtPoint( unit, point )
  local dir = (point - unit:GetAbsOrigin()):Normalized()
  dir.z = 0
  return dir
end

function SetToggleState( ability, state )
  if ability:GetToggleState() ~= state then
    ability:ToggleAbility()
  end
end

function SimulateMeleeAttack( keys )
  local caster = keys.caster
  local target = keys.target_points[1]
  local ability = keys.ability

  local activity = keys.activity or ACT_DOTA_ATTACK
  local duration = keys.duration or 0.5
  local rate = keys.rate or 2.2

  local damage_amp = GetSpecial(ability, "damage_amp") or 1.0
  local aoe = GetSpecial(ability, "aoe") or 0

  if keys.attack_particle then
    ParticleManager:CreateParticle(keys.attack_particle,PATTACH_ABSORIGIN,caster)
  end 

  if keys.attack_sound then
    caster:EmitSound(attack_sound)
  end 

  StartAnimation(caster, {duration=duration, activity=activity, rate=rate})

  -- caster:AddNewModifier(caster,ability,"modifier_custom_attack",{duration = duration})
  UnitLookAtPoint( caster, target )
  caster:Stop()

  Timers:CreateTimer(duration, function()
    -- if caster:HasModifier("modifier_custom_attack") == false then
    --   return
    -- end

    if keys.attack_impact then
      keys.attack_impact(caster)
    else
      local units = FindUnitsInRadius(caster:GetTeamNumber(),target,nil,100,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false)

      Timers:CreateTimer(duration, function()
        if aoe ~= 0 then
          for k,v in pairs(units) do
            DealDamage(caster, v, caster:GetAverageTrueAttackDamage() * damage_amp, DAMAGE_TYPE_PHYSICAL)
          end
        else
          DealDamage(caster, units[1], caster:GetAverageTrueAttackDamage() * damage_amp, DAMAGE_TYPE_PHYSICAL)
        end
        end)
    end
    end)
end

function SimulateRangeAttack( keys )
  local caster = keys.caster
  local ability = keys.ability
  local speed = caster:GetProjectileSpeed()
  local duration = caster:GetAttackAnimationPoint() / caster:GetAttackSpeed()
  local base_attack_time = caster:GetBaseAttackTime() / caster:GetAttackSpeed()

  local damage_amp = GetSpecial(ability, "damage_amp") or 1.0

  ability:StartCooldown(caster:GetAttackAnimationPoint())

  StartAnimation(caster, {duration=duration + base_attack_time, activity=ACT_DOTA_ATTACK, rate=1.0 * caster:GetAttackSpeed()})

  caster:AddNewModifier(caster,ability,"modifier_custom_attack",{duration = duration + base_attack_time})

  local units = FindUnitsInRadius(caster:GetTeamNumber(),keys.target_points[1],nil,200,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false)

  if #units > 0 then
    keys.target_points[1] = units[1]:GetAbsOrigin() + Vector(0,0,64)
  end

  Timers:CreateTimer(duration, function()
    if caster:HasModifier("modifier_custom_attack") == false then
      return
    end

    if keys.sound then
      caster:EmitSound(keys.sound)
    end

    local offset = 64
    local lock = true
    local distanceToTarget = caster:GetAttackRange() * 1.5
    local origin = caster:GetAbsOrigin() + Vector(0,0,64)
    local direction = (Vector(keys.target_points[1].x, keys.target_points[1].y, 0) 
      - Vector(origin.x, origin.y, 0)):Normalized()
    local point = caster:GetAbsOrigin() + ((keys.target_points[1] - origin):Normalized() * distanceToTarget)
    if math.abs(origin.z - keys.target_points[1].z) < 128 then --
      point.z = caster:GetAbsOrigin().z + offset 
      lock = false
    end
    local time = (point - origin):Length2D()/speed

    local projectile = {
      vSpawnOrigin = origin,
      fStartRadius = 96,
      fEndRadius = 96,
      Source = caster,
      fExpireTime = 8.0,
      UnitBehavior = PROJECTILES_NOTHING,
      bMultipleHits = false,
      bIgnoreSource = true,
      TreeBehavior = PROJECTILES_NOTHING,
      bCutTrees = false,
      bTreeFullCollision = false,
      WallBehavior = PROJECTILES_NOTHING,
      GroundBehavior = PROJECTILES_DESTROY,
      fGroundOffset = offset,
      nChangeMax = 1,
      bRecreateOnChange = true,
      bZCheck = false,
      bGroundLock = lock,
      bProvidesVision = false,
      fVisionTickTime = .1,
      fVisionLingerDuration = 0.5,
      draw = true,
      UnitTest = function(self, target) return target:GetUnitName() ~= "npc_dummy_unit" and caster:GetTeamNumber() ~= target:GetTeamNumber() end,
    }

    projectile.OnUnitHit = (function(self, target)
      if target then
        DealDamage(caster, target, caster:GetAverageTrueAttackDamage() * damage_amp, DAMAGE_TYPE_PHYSICAL)
        local new_keys = keys
        if keys.on_hit then
          new_keys.target = target
          keys.on_hit(new_keys)
        end
        if keys.on_kill then
          new_keys.unit = target
          keys.on_hit(new_keys)
        end
      end
    end)

    projectile.fDistance = (point - origin):Length2D()
    projectile.vVelocity = direction * speed * 1.1 

    Projectiles:CreateProjectile(projectile)

    local projectileFX = ParticleManager:CreateParticle(keys.effect, PATTACH_CUSTOMORIGIN, caster)
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

function CreepAgression( keys )
  local caster = keys.caster

  local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),nil,800,DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

  if #heroes > 0 then
    for k,v in pairs(heroes) do
      local path = GridNav:FindPathLength(v:GetAbsOrigin(), caster:GetAbsOrigin())
      if path <= 800 and path > 0 then 
        caster:RemoveModifierByName("ziv_creep_normal_hpbar_behavior_aggro")
        
        local creeps = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),nil,800,DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for k2,v2 in pairs(creeps) do
          local path = GridNav:FindPathLength(v:GetAbsOrigin(), caster:GetAbsOrigin())
          if path <= 800 and path > 0 then 
            v:RemoveModifierByName("ziv_creep_normal_hpbar_behavior_aggro")
          end
        end
        break
      end
    end
  end
end