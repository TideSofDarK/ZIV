ziv_creep_lord_tanky = class({})

function ziv_creep_lord_tanky:GetIntrinsicModifierName(  )
  return "modifier_creep_lord_tanky"
end
--------------------------------------------------------------------------------
modifier_creep_lord_tanky = class({})
function modifier_creep_lord_tanky:IsPassive()
  return true
end
function modifier_creep_lord_tanky:IsPurgable()
  return false
end
function modifier_creep_lord_tanky:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE
  }
  return funcs
end
function modifier_creep_lord_tanky:GetModifierExtraHealthPercentage()
  return 1.5
end
--------------------------------------------------------------------------------
LinkLuaModifier("modifier_creep_lord_tanky", "abilities/modifiers/ziv_creep_lord_tanky.lua", LUA_MODIFIER_MOTION_NONE)