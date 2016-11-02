ziv_elementalist_mastery = class({})

function ziv_elementalist_mastery:OnUpgrade()
	local caster = self:GetCaster()

	local crit_chance = GetSpecial(self, "crit_chance")
	local crit_damage = GetSpecial(self, "crit_damage")

	Damage:Modify(caster, Damage.CRIT_CHANCE, crit_chance)
	Damage:Modify(caster, Damage.CRIT_DAMAGE, crit_damage)
end