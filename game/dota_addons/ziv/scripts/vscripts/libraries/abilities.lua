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
  local base_attack_time = keys.base_attack_time or (1 / caster:GetAttacksPerSecond())
  local duration = keys.duration or (caster:GetAttackAnimationPoint() / caster:GetAttackSpeed())
  local rate = keys.rate or caster:GetAttackSpeed()

  local damage_amp = GetSpecial(ability, "damage_amp") or 1.0
  local aoe = GetSpecial(ability, "aoe") or 0

  ability:EndCooldown()
  ability:StartCooldown( base_attack_time - duration)

  if keys.attack_particle then
    ParticleManager:CreateParticle(keys.attack_particle,PATTACH_ABSORIGIN,caster)
  end 

  if keys.attack_sound then
    caster:EmitSound(attack_sound)
  end 

  StartAnimation(caster, {duration=base_attack_time, activity=activity, rate=rate})

  -- caster:AddNewModifier(caster,ability,"modifier_custom_attack",{duration = duration})
  caster:SetForwardVector(UnitLookAtPoint( caster, target ))
  caster:Stop()

  Timers:CreateTimer(duration, function()
    -- if caster:HasModifier("modifier_custom_attack") == false then
    --   return
    -- end

    if keys.on_impact then
      keys.on_impact(caster)
    else
      local units = FindUnitsInRadius(caster:GetTeamNumber(),target,nil,75,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false)

      for k,v in pairs(units) do
        local new_keys = keys
        if keys.on_hit then
          new_keys.target = v
          keys.on_hit(new_keys)
        else
          DealDamage(caster, v, caster:GetAverageTrueAttackDamage() * damage_amp, DAMAGE_TYPE_PHYSICAL)
        end
        if keys.on_kill and v:IsAlive() == false then
          new_keys.unit = v
          keys.on_kill(new_keys)
        end

        if aoe == 0 then break end
      end
    end

    end)
end

function SimulateRangeAttack( keys )
  local caster = keys.caster
  local ability = keys.ability
  local target = keys.target_points[1]

  local speed = tonumber(keys.projectile_speed) or caster:GetProjectileSpeed()
  local duration = keys.duration or (caster:GetAttackAnimationPoint() / caster:GetAttackSpeed())
  local base_attack_time = keys.base_attack_time or (1 / caster:GetAttacksPerSecond())
  local rate = keys.rate or caster:GetAttackSpeed()

  local damage_amp = GetSpecial(ability, "damage_amp") or 1.0

  ability:EndCooldown()
  ability:StartCooldown( base_attack_time)
  
  StartAnimation(caster, {duration=duration + base_attack_time, activity=ACT_DOTA_ATTACK, rate=rate})
  UnitLookAtPoint( caster, target )
  caster:Stop()

  caster:AddNewModifier(caster,ability,"modifier_custom_attack",{duration = 1.0 / caster:GetAttacksPerSecond()})

  local units = FindUnitsInRadius(caster:GetTeamNumber(),keys.target_points[1],nil,200,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false)

  if #units > 0 then
    keys.target_points[1] = units[1]:GetAbsOrigin() + Vector(0,0,64)
  end

  Timers:CreateTimer(duration, function()
    if caster:HasModifier("modifier_custom_attack") == false and keys.interruptable ~= false then
      return
    end

    if keys.attack_sound then
      caster:EmitSound(keys.attack_sound)
    end

    local offset = 64
    local lock = true
    local distanceToTarget = caster:GetAttackRange() * 2.0
    local origin = caster:GetAbsOrigin() + Vector(0,0,offset)
    local direction = (Vector(keys.target_points[1].x, keys.target_points[1].y, 0) 
      - Vector(origin.x, origin.y, 0)):Normalized()
    local point = caster:GetAbsOrigin() + ((keys.target_points[1] - origin):Normalized() * distanceToTarget)
    local time = (target - origin):Length2D()/speed

    if math.abs(origin.z - keys.target_points[1].z) < 128 then
      point.z = caster:GetAbsOrigin().z + offset 
      time = 8.0
      lock = false
    elseif keys.target_points[1].z - origin.z >= 128 then
      point.z = keys.target_points[1].z + (offset * 4) 
      time = 8.0
      lock = false
    end

    local projectile = {
      vSpawnOrigin = origin,
      fStartRadius = 64,
      fEndRadius = 64,
      Source = caster,
      fExpireTime = time,
      UnitBehavior = PROJECTILES_NOTHING,
      bMultipleHits = false,
      bIgnoreSource = true,
      TreeBehavior = PROJECTILES_NOTHING,
      bCutTrees = false,
      bTreeFullCollision = false,
      WallBehavior = PROJECTILES_NOTHING,
      GroundBehavior = PROJECTILES_NOTHING,
      fGroundOffset = offset,
      nChangeMax = 1,
      bRecreateOnChange = true,
      bZCheck = false,
      bGroundLock = lock,
      bProvidesVision = false,
      fVisionTickTime = .1,
      fVisionLingerDuration = 0.5,
      draw = false,
      UnitTest = function(self, target) return target:GetUnitName() ~= "npc_dummy_unit" and caster:GetTeamNumber() ~= target:GetTeamNumber() end,
    }

    if keys.on_impact then
      keys.on_impact(caster)
    end

    projectile.OnUnitHit = (function(self, target)
      if IsValidEntity(target) then
        local new_keys = keys
        if keys.on_hit then
          new_keys.target = target
          keys.on_hit(new_keys)
        else
          DealDamage(caster, target, caster:GetAverageTrueAttackDamage() * damage_amp, DAMAGE_TYPE_PHYSICAL)
        end
        if keys.on_kill and target:IsAlive() == false then
          new_keys.unit = target
          keys.on_kill(new_keys)
        end
      end
    end)

    projectile.fDistance = (point - origin):Length2D()
    projectile.vVelocity = direction * speed * 1.1 

    local projectileFX = ParticleManager:CreateParticle(keys.effect, PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(projectileFX, 0, origin)
    ParticleManager:SetParticleControl(projectileFX, 1, point)
    ParticleManager:SetParticleControl(projectileFX, 2, Vector(speed, 0, 0))
    ParticleManager:SetParticleControl(projectileFX, 3, point)

    projectile.OnFinish = (function(self, target)
      ParticleManager:DestroyParticle(projectileFX, false)
    end)

    Projectiles:CreateProjectile(projectile)
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
  local ability = keys.ability

  if caster:GetAggroTarget() ~= nil and math.abs(caster:GetAggroTarget():GetAbsOrigin().z - caster:GetAbsOrigin().z) > 128 then
    caster:Stop()
    caster:RemoveModifierByName("ziv_creep_normal_behavior_aggro")
    ability:ApplyDataDrivenModifier(caster,caster,"ziv_creep_normal_behavior_disable_autoattack",{duration = 0.5})
    Timers:CreateTimer(0.5, function (  )
      ability:ApplyDataDrivenModifier(caster,caster,"ziv_creep_normal_behavior_aggro",{})
      caster:RemoveModifierByName("ziv_creep_normal_behavior_disable_autoattack")
    end)
  end

  -- local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),nil,800,DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

  -- if #heroes > 0 then
  --   for k,v in pairs(heroes) do
  --     local path = GridNav:FindPathLength(v:GetAbsOrigin(), caster:GetAbsOrigin())
  --     if path <= 800 and path > 0 then 
  --       caster:RemoveModifierByName("ziv_creep_normal_behavior_aggro")
        
  --       local creeps = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),nil,800,DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
  --       for k2,v2 in pairs(creeps) do
  --         local path = GridNav:FindPathLength(v:GetAbsOrigin(), caster:GetAbsOrigin())
  --         if path <= 800 and path > 0 then 
  --           v:RemoveModifierByName("ziv_creep_normal_behavior_aggro")
  --         end
  --       end
  --       break
  --     end
  --   end
  -- end
end