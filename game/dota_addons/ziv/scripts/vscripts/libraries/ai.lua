require('libraries/ai_default_sfm')

if AI == nil then
    _G.AI = class({})
end

-- Init AI
function AI:BossStart( keys, sfm )
  caster = keys.caster
	caster:AddNewModifier(caster,nil,"modifier_boss_ai",{})

  sfm:Think()
end

