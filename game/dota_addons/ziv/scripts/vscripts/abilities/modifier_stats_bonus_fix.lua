modifier_stats_bonus_fix = class({})

function modifier_stats_bonus_fix:IsHidden()
	return true 
end

function modifier_stats_bonus_fix:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
end

function modifier_stats_bonus_fix:DeclareFunctions()
	local funcs = {
		--MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	}
 
	return funcs
end

--function modifier_stats_bonus_fix:GetModifierMoveSpeedBonus_Percentage(params)
--	return self.moveSpeedBonus
--end


function modifier_stats_bonus_fix:GetModifierBaseAttack_BonusDamage(params)
	return self.attackBonus
end

function modifier_stats_bonus_fix:GetModifierHealthBonus(params)
	return self.healthBonus
end

function modifier_stats_bonus_fix:GetModifierConstantHealthRegen(params)
	return self.healtRegenBonus
end

function modifier_stats_bonus_fix:GetModifierAttackSpeedBonus_Constant(params)
	return self.attackSpeedBonus
end

function modifier_stats_bonus_fix:GetModifierManaBonus(params)
	return	self.manaBonus
end

function modifier_stats_bonus_fix:GetModifierConstantManaRegen(params)
	return self.manaRegenBonus
end

function modifier_stats_bonus_fix:CalculateStatsBonus(kv) 
	local hero = self:GetParent()

	if not hero:IsHero() then
		return
	end

	local primaryStat = hero:GetPrimaryStatValue()
	local strength = hero:GetStrength() - (kv.strFix or 0)
	local agility = hero:GetAgility()
	local intellect = hero:GetIntellect()

	self.attackBonus = 0

	self.healthBonus = (19 * -strength)
	self.healtRegenBonus = 0
	
	hero.baseArmorValue = hero.baseArmorValue or hero:GetPhysicalArmorBaseValue()
	
	self.armorBonus = 0
	hero:SetPhysicalArmorBaseValue(self.armorBonus+hero.baseArmorValue) 
	
	self.attackSpeedBonus = -agility
	self.moveSpeedBonus = 0

	self.manaBonus = intellect * -13
	self.manaRegenBonus = intellect * -0.04

	self:GetAbility().CalcStat = 1
	hero:CalculateStatBonus()
	self:GetAbility().CalcStat = nil
end

function modifier_stats_bonus_fix:OnCreated(kv)
	if IsServer() then
		self:CalculateStatsBonus(kv) 
		self:StartIntervalThink(0.1)
	end
end


function modifier_stats_bonus_fix:OnRefresh(kv)
	if IsServer() then
		self:CalculateStatsBonus(kv) 
	end
end

function modifier_stats_bonus_fix:OnIntervalThink()
	self:CalculateStatsBonus({})
end