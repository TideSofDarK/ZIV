require('libraries/ai_default_sfm')

if AI == nil then
    _G.AI = class({})
end

-- Get hero with max aggro
function AI:GetMaxAggro( caster )
  if GetTableLength(caster.ai.aggroTable) < 1 then
    return nil
  end
  
  table.sort(caster.ai.aggroTable)  
  for k,v in pairs(caster.ai.aggroTable) do
    if v == 0 then
      return nil
    end
    
    return EntIndexToHScript(k)
  end
end

function AI:IsInAbilityPhase( caster )
  	for i=0,16 do
      local ability = caster:GetAbilityByIndex(i)
      if ability then
        if ability:IsInAbilityPhase() then
          return true
        end
      end
    end
    
    return false
end

function AI:BossStart( keys, sfm )
	local caster = keys.caster
  -- AI fields
  caster.ai = {}

  -- Set default sfm if it doesn't exists
  if caster.ai.sfm == nil then
    caster.ai.sfm = SFM.sfm
  else
    caster.ai.sfm = sfm
  end
  
  caster.ai.state = caster.ai.sfm.initial_state
  caster.ai.spawnPoint = caster:GetAbsOrigin()
  caster.ai.aggroTable = {}

	caster:AddNewModifier(caster,nil,"modifier_boss_ai",{})

  Timers:CreateTimer(function ()
      if caster:IsNull() then
        return
      end
    
      AI:SFM( caster )
      AI:CheckAggroTable( caster )
    return 0.5
  end)
end

-- State finite machine
function AI:SFM( caster )
  local state = caster.ai.state
  print(state)
  
  if caster.ai.sfm.states[state] ~= nil then
    local funct = caster.ai.sfm.states[state].funct
    local transitions = caster.ai.sfm.states[state].transitions
    
    if funct ~= nil then
      funct(caster)
    end
    
    for k,v in pairs(transitions) do
      if v(caster) then
        caster.ai.state = k
        return
      end
    end
  end
end

function AI:CheckAggroTable( caster )
  for k,v in pairs(caster.ai.aggroTable) do
    if not EntIndexToHScript(k):IsAlive() then
      caster.ai.aggroTable[k] = 0
    end
  end
end