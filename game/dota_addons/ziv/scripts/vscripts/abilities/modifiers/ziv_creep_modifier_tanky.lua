ziv_creep_modifier_tanky = class({})

function ziv_creep_modifier_tanky:GetIntrinsicModifierName(  )
  return "modifier_creep_tanky"
end
--------------------------------------------------------------------------------
modifier_creep_tanky = class({})
function modifier_creep_tanky:IsPassive()
  return true
end
function modifier_creep_tanky:IsPurgable()
  return false
end
function modifier_creep_tanky:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE
  }
  return funcs
end
function modifier_creep_tanky:GetModifierExtraHealthPercentage()
  return 0.8
end
--------------------------------------------------------------------------------
LinkLuaModifier("modifier_creep_tanky", "abilities/modifiers/ziv_creep_modifier_tanky.lua", LUA_MODIFIER_MOTION_NONE)