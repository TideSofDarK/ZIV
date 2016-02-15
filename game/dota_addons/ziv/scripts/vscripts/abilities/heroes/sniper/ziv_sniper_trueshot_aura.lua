ziv_sniper_trueshot_aura = class({})
LinkLuaModifier("modifier_trueshot_aura", "abilities/heroes/sniper/modifier_trueshot_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_trueshot_aura_effect", "abilities/heroes/sniper/modifier_trueshot_aura_effect.lua", LUA_MODIFIER_MOTION_NONE)

function ziv_sniper_trueshot_aura:GetIntrinsicModifierName(  )
	return "modifier_trueshot_aura"
end