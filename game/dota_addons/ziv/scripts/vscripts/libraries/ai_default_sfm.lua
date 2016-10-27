---------------------------------
-- Aggro handlers
---------------------------------
AggroMode = {
  Default = 0,
  Random = 1,
  Weakest = 2
}

function AggroTable()
  local aggro = {}
  aggro.table = {}
  aggro.unit = nil
  aggro.mode = AggroMode.Default
  aggro.time = 10  
  aggro.nextAggroTime = nil
  
  ---------------------------------
  -- Functions
  ---------------------------------
  function aggro:GetCurrentTime()
    local hours, minutes, seconds = string.match(GetSystemTime(), '(%d+)[:](%d+)[:](%d+)')
    return hours * 3600 + minutes * 60 + seconds
  end
  
  -- Set aggro mode
  function aggro:SetMode(mode, time)
    self.mode = mode
    self.time = time
    self.nextAggroTime = self:GetCurrentTime()
  end
  
  -- Get unit with max aggro in table
  function aggro:GetMaxAggroHero()
    if GetTableLength(self.table) < 1 then
      return nil
    end
    
    table.sort(self.table)  
    for k,v in pairs(self.table) do
      if v == 0 then
        return nil
      end
      
      return k
    end
  end  
  
  -- Get random hero in aggro table
  function aggro:GetRandomHero()
    local notNullAggro = {}
    
    for k,v in pairs(self.table) do
      if v ~= 0 then
        table.insert(notNullAggro, k)
      end
    end    
    
    if #notNullAggro > 0 then
      local index = RandomInt( 1, #notNullAggro )
      return notNullAggro[index]
    else
      return nil
    end
  end

  -- Get weakest hero in aggro table
  function aggro:GetWeakestHero()
    local minHP = nil
    local target = nil

    for heroID,_ in pairs(self.table) do
      if heroID ~= nil then
        local hero = EntIndexToHScript(heroID)
        local HP = hero:GetHealth()
        if hero:IsAlive() and (minHP == nil or HP < minHP) then
          minHP = HP
          target = heroID
        end
      end
    end

    return target
  end
  
  -- Get aggro unit by current aggro rules
  function aggro:GetAggroUnit()
    local hero
    
    if self.mode == AggroMode.Default then
      hero = self:GetMaxAggroHero()
      
    elseif self.mode == AggroMode.Random then
      if self:GetCurrentTime() >= self.nextAggroTime or self.unit == nil then
        hero = self:GetRandomHero()
        self.nextAggroTime = self:GetCurrentTime() + self.time
      else
        hero = self.unit
      end
      
    elseif self.mode == AggroMode.Weakest then
      hero = self:GetWeakestHero()
    end
    
    if hero ~= nil then
      self.unit = hero
      return EntIndexToHScript(hero)
    end
    
    return nil
  end
  
  -- Update aggro state for dead units
  function aggro:Update()
    for k,v in pairs(self.table) do
      if not EntIndexToHScript(k):IsAlive() then
        self.table[k] = 0
        if self.unit == k then
          self.unit = nil
        end
      end
    end
  end    
  
  -- Add aggro value
  function aggro:Add( attacker, damage )
    self.table[attacker] = (self.table[attacker] or 0) + damage
  end
  
  return aggro
end

---------------------------------
-- SFM handlers
---------------------------------
SFMStates = {
  Idle = 0,
  Casting = 1,
  Chasing = 2
}

function SFM( caster )
  local sfm = {}
  
  sfm.state = SFMStates.Idle
  sfm.isStateLocked = false
  sfm.caster = caster
  caster.sfm = sfm
  sfm.spawnPoint = caster:GetAbsOrigin()
  sfm.aggro = AggroTable()
  
  ---------------------------------
  -- Functions
  --------------------------------- 
  function sfm:SetState(state, isDebug)
    if not self.isStateLocked or isDebug then
      self.state = state
    end
  end
  
  function sfm:LockState(isStateLocked)
    sfm.isStateLocked = isStateLocked
  end
  
  function sfm:IsInAbilityPhase()
      for i=0,16 do
        local ability = self.caster:GetAbilityByIndex(i)
        if ability then
          if ability:IsInAbilityPhase() then
            return true
          end
        end
      end
      
      return false
  end  
  
  -----------------------------
  -- Idle handlers
  -----------------------------
  function sfm:Idle()
    sfm.caster:MoveToPosition(sfm.spawnPoint)
    --caster.aggroTable = {}
  end

  -----------------------------
  -- Chasing handlers
  -----------------------------
  function sfm:Chasing()
    local hero = sfm.aggro:GetAggroUnit()
    if hero ~= nil then
      sfm.caster:MoveToTargetToAttack(hero)
    end
  end

  -----------------------------
  -- Casting handlers
  -----------------------------
  function sfm:Casting()
    if sfm:IsInAbilityPhase() then
      return
    end
    
    local hero = sfm.aggro:GetAggroUnit()
    if hero == nil then
      return
    end
    
    local unit = sfm.caster

    local abilities = {}
    for i=0,16 do
      local ability = unit:GetAbilityByIndex(i)

      -- if ability and DOTA_ABILITY_BEHAVIOR_HIDDEN ~= bit.band( DOTA_ABILITY_BEHAVIOR_HIDDEN, ability:GetBehavior() ) and ability:IsCooldownReady() then abilities[ability] = ability:GetCastRange() end 
      if ability 
        and DOTA_ABILITY_BEHAVIOR_HIDDEN ~= bit.band( DOTA_ABILITY_BEHAVIOR_HIDDEN, ability:GetBehavior() ) 
        and ability:IsFullyCastable()
        and (not ability:GetKeyValue("HPThreshold") or (unit:GetHealth() / unit:GetMaxHealth()) < (ability:GetKeyValue("HPThreshold") / 100))
        and ability:IsInAbilityPhase() == false
        and (ability:GetCastRange() >= (hero:GetAbsOrigin() - unit:GetAbsOrigin()):Length2D() or DOTA_ABILITY_BEHAVIOR_NO_TARGET == bit.band( DOTA_ABILITY_BEHAVIOR_NO_TARGET, ability:GetBehavior() ))
        then table.insert(abilities, ability) end 
    end

    local next_ability = GetRandomElement(abilities)

    if next_ability then
      -- Timers:CreateTimer(math.random(0.0, 3.25), function (  )
        if DOTA_ABILITY_BEHAVIOR_NO_TARGET == bit.band( DOTA_ABILITY_BEHAVIOR_NO_TARGET, next_ability:GetBehavior() ) then
          unit:CastAbilityNoTarget(next_ability,-1)
        elseif DOTA_ABILITY_BEHAVIOR_UNIT_TARGET == bit.band( DOTA_ABILITY_BEHAVIOR_UNIT_TARGET, next_ability:GetBehavior() ) then
          unit:CastAbilityOnTarget(hero,next_ability,-1)
        elseif DOTA_ABILITY_BEHAVIOR_POINT == bit.band( DOTA_ABILITY_BEHAVIOR_POINT, next_ability:GetBehavior() ) then
          unit:CastAbilityOnPosition(hero:GetAbsOrigin() + Vector(math.random(-20.0, 20.0), math.random(-20.0, 20.0), 0.0),next_ability,-1)
        end
    end  
  end    

  function sfm:UpdateState()
    local hero = self.aggro:GetAggroUnit()
    if hero == nil then
        sfm:SetState(SFMStates.Idle)
        return    
    end
    
    local length = (hero:GetAbsOrigin() - self.caster:GetAbsOrigin()):Length2D()
    local spawnLength = (self.spawnPoint - self.caster:GetAbsOrigin()):Length2D()
    
    if self.state == SFMStates.Idle then
      if length > 500 and length < 1000 and spawnLength < 1000 then
        sfm:SetState(SFMStates.Chasing)
        return
      end
      
      if hero:IsAlive() and length < 700 then
        sfm:SetState(SFMStates.Casting)
        return
      end
    end
    
    if self.state == SFMStates.Chasing then
      if not hero:IsAlive() or length > 1000 then
        sfm:SetState(SFMStates.Idle)
        return
      end
      
      if length < 700 then
        sfm:SetState(SFMStates.Casting)
        return
      end
    end
    
    if self.state == SFMStates.Casting then
      if length > 700 and length < 1000 then
        sfm:SetState(SFMStates.Chasing)
        return
      end
      
      if not hero:IsAlive() or spawnLength > 1000 then
        sfm:SetState(SFMStates.Idle)
      end      
    end
  end    

  function sfm:Think()    
    Timers:CreateTimer(function ()
        if caster:IsNull() then
          return
        end
      
      --print('State: ', self.state)
      self:UpdateState()
      
      local funct = self.states[self.state]
      if funct ~= nil then
        funct()
      end
      
      self.aggro:Update()
    
      return 0.5
    end)
  end  
  
  ---------------------------------
  -- Bindings
  ---------------------------------  
  sfm.states = {}
  sfm.states[SFMStates.Idle] = sfm.Idle 
  sfm.states[SFMStates.Chasing] = sfm.Chasing
  sfm.states[SFMStates.Casting] = sfm.Casting
  
  return sfm
end