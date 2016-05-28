function AddStackableModifierWithDuration(caster, target, ability, modifierName, time, maxStacks)
  local modifier = target:FindModifierByName(modifierName)
  if modifier then
    local stackCount = target:GetModifierStackCount(modifierName, caster)

    target:RemoveModifierByName(modifierName)
    ability:ApplyDataDrivenModifier(caster, target, modifierName, {duration=time})

    if (stackCount + 1) <= maxStacks then
      target:SetModifierStackCount(modifierName, caster, stackCount + 1)
    else
      target:SetModifierStackCount(modifierName, caster, stackCount)
    end
  else
    ability:ApplyDataDrivenModifier(caster, target, modifierName, {duration=time})
    target:SetModifierStackCount(modifierName, caster, 1)
  end
end

function AddChildEntity( caster, entity )
  caster.child_entities = caster.child_entities or {}
  table.insert(caster.child_entities, entity) 
end

function SetHull( keys )
  local caster = keys.caster
  caster:SetHullRadius(tonumber(keys.size))
end

function UnitLookAtPoint( unit, point )
  local dir = (point - unit:GetAbsOrigin()):Normalized()
  dir.z = 0
  if dir == Vector(0,0,0) then return unit:GetForwardVector() end
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

  local kv = ZIV.HeroesKVs[caster:GetUnitName().."_ziv"]

  ability:EndCooldown()
  ability:StartCooldown( base_attack_time - duration)

  if keys.attack_particle then
    ParticleManager:CreateParticle(keys.attack_particle,PATTACH_ABSORIGIN,caster)
  end 

  StartAnimation(caster, {duration=base_attack_time, activity=activity, rate=rate})

  caster:SetForwardVector(UnitLookAtPoint( caster, target ))
  caster:Stop()

  if keys.pre_attack_sound then
    caster:EmitSound(keys.pre_attack_sound)
  elseif kv["SoundSet"] then
    caster:EmitSound(kv["SoundSet"]..".PreAttack")
  end

  Timers:CreateTimer(duration, function()
    if keys.attack_sound then
      caster:EmitSound(keys.attack_sound)
    elseif kv["SoundSet"] then
      caster:EmitSound(kv["SoundSet"]..".Attack")
    end

    if keys.on_impact then
      keys.on_impact(caster)
    else
      local units = FindUnitsInRadius(caster:GetTeamNumber(),target,nil,75,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false)

      for k,v in pairs(units) do
        if keys.impact_sound then
          caster:EmitSound(keys.impact_sound)
        elseif kv["SoundSet"] then
          caster:EmitSound(kv["SoundSet"]..".Attack.Impact")
        end

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

  local kv = ZIV.HeroesKVs[caster:GetUnitName().."_ziv"]

  ability:EndCooldown()
  ability:StartCooldown( base_attack_time)
  
  StartAnimation(caster, {duration=duration + base_attack_time, activity=ACT_DOTA_ATTACK, rate=rate})
  
  UnitLookAtPoint( caster, target )
  caster:Stop()

  caster:AddNewModifier(caster,ability,"modifier_custom_attack",{duration = 1.0 / caster:GetAttacksPerSecond()})

  local units = FindUnitsInRadius(caster:GetTeamNumber(),keys.target_points[1],nil,75,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false)

  if #units > 0 then
    keys.target_points[1] = units[1]:GetAbsOrigin() + Vector(0,0,64)
  end
  
  if keys.pre_attack_sound then
    caster:EmitSound(keys.pre_attack_sound)
  elseif kv["SoundSet"] then
    caster:EmitSound(kv["SoundSet"]..".PreAttack")
  end

  local projectile
  local projectileFX

  Timers:CreateTimer(duration, function()
    if caster:HasModifier("modifier_custom_attack") == false and keys.interruptable ~= false then
      return
    end

    if keys.attack_sound then
      caster:EmitSound(keys.attack_sound)
    elseif kv["SoundSet"] then
      caster:EmitSound(kv["SoundSet"]..".Attack")
    end

    local offset = 64
    local lock = true
    local distanceToTarget = caster:GetAttackRange() * 2.0
    local origin = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment(keys.attachment or "attach_attack1")) or (caster:GetAbsOrigin() + Vector(0,0,offset))
    local direction = (Vector(keys.target_points[1].x, keys.target_points[1].y, 0) 
      - Vector(origin.x, origin.y, 0)):Normalized()
    local point = caster:GetAbsOrigin() + ((keys.target_points[1] - origin):Normalized() * distanceToTarget)

    local time = (target - origin):Length2D()/speed

    if math.abs(origin.z - keys.target_points[1].z) < 128 then
      point.z = origin.z
      time = 8.0
      lock = false
    elseif keys.target_points[1].z - origin.z >= 128 then
      point.z = keys.target_points[1].z + (offset * 4) 
      time = 8.0
      lock = false
    end

    local unit_behavior = PROJECTILES_DESTROY
    local pierce_count = 0
    if keys.pierce then
      unit_behavior = PROJECTILES_NOTHING
    end

    projectile = {
      vSpawnOrigin = origin,
      fStartRadius = 64,
      fEndRadius = 48,
      Source = caster,
      fExpireTime = time,
      UnitBehavior = unit_behavior,
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
        -- if keys.impact_sound then
        --   caster:EmitSound(keys.impact_sound)
        -- elseif kv["SoundSet"] then
        --   caster:EmitSound(kv["SoundSet"]..".ProjectileImpact")
        -- end

        if keys.impact_effect then
          local endcap = TimedEffect(keys.impact_effect, target, 2.0, 3, PATTACH_POINT_FOLLOW)
          ParticleManager:SetParticleControlEnt(endcap,1,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetAbsOrigin(),false)
        end

        local new_keys = keys
        if keys.on_hit then
          new_keys.target = target
          keys.on_hit(new_keys)
        else
          DealDamage(caster, target, caster:GetAverageTrueAttackDamage() * damage_amp, DAMAGE_TYPE_PHYSICAL)
        end
        if keys.on_kill and (target:IsAlive() == false or target:GetHealth() <= 0) then
          new_keys.unit = target
          keys.on_kill(new_keys)
        end

        pierce_count = pierce_count + 1

        if pierce_count >= (keys.pierce or 1) or unit_behavior == PROJECTILES_DESTROY then
          projectile:Destroy()
          return false
        else
          if keys.pierce then
            if keys.impact_sound then
              caster:EmitSound(keys.impact_sound)
            elseif kv["SoundSet"] then
              caster:EmitSound(kv["SoundSet"]..".ProjectileImpact")
            end
          end
        end 
      end
    end)

    projectile.fDistance = (point - origin):Length2D()
    projectile.vVelocity = direction * speed * 1.1 

    projectileFX = ParticleManager:CreateParticle(keys.effect, PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(projectileFX, 0, origin)
    ParticleManager:SetParticleControl(projectileFX, 1, point)
    ParticleManager:SetParticleControl(projectileFX, 2, Vector(speed, 0, 0))
    ParticleManager:SetParticleControl(projectileFX, 3, point)

    projectile.OnFinish = (function(self, target)
      ParticleManager:DestroyParticle(projectileFX, false)

      if keys.impact_sound then
        caster:EmitSound(keys.impact_sound)
      elseif kv["SoundSet"] then
        caster:EmitSound(kv["SoundSet"]..".ProjectileImpact")
      end
    end)

    Projectiles:CreateProjectile(projectile)

    projectile.Destroy = function (  )
      ParticleManager:DestroyParticle(projectile.id, projectile.bDestroyImmediate)
      Projectiles:RemoveTimer(projectile.ProjectileTimerName)
      ParticleManager:DestroyParticle(projectileFX, true)
    end

    AddChildEntity(caster,projectile)
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