ziv_stats_bonus_fix = class({})

LinkLuaModifier("modifier_stats_bonus_fix", "abilities/modifier_stats_bonus_fix.lua",LUA_MODIFIER_MOTION_NONE)

function ziv_stats_bonus_fix:GetIntrinsicModifierName() 
	return "modifier_stats_bonus_fix"
end

function ziv_stats_bonus_fix:OnHeroCalculateStatBonus(params) 
	if not self.CalcStat then
		self:GetCaster():AddNewModifier(caster, self, "modifier_stats_bonus_fix", nil)
	end
end