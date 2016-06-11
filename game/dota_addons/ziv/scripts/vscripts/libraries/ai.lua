if AI == nil then
    _G.AI = class({})
end

function AI:BossStart( keys, sfm )
	local caster = keys.caster

	caster:AddNewModifier(caster,nil,"modifier_boss_ai",{})
  
  caster.state = sfm.initial_state
  caster.sfm = sfm
  caster.aggroTable = {}

  if sfm ~= nill then
    Timers:CreateTimer(function ()        
        AI:SFM( caster )
        AI:CheckAggroTable( caster )
      return 0.5
    end)
  end
end

-- State finite machine
function AI:SFM( caster )
  local state = caster.state
  print(state)
  
  if caster.sfm.states[state] ~= nil then
    local funct = caster.sfm.states[state].funct
    local transitions = caster.sfm.states[state].transitions
    
    if funct ~= nil then
      funct(caster)
    end
    
    for k,v in pairs(transitions) do
      if v(caster) then
        caster.state = k
        return
      end
    end
  end
end

function AI:CheckAggroTable( caster )
  for k,v in pairs(caster.aggroTable) do
    if not EntIndexToHScript(k):IsAlive() then
      caster.aggroTable[k] = 0
    end
  end
end