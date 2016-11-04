ziv_elementalist_mastery = class({})

function ziv_elementalist_mastery:OnUpgrade()
	local caster = self:GetCaster()

	local crit_chance = GetSpecial(self, "crit_chance")
	local crit_damage = GetSpecial(self, "crit_damage")

	Damage:Modify(caster, Damage.CRIT_CHANCE, crit_chance)
	Damage:Modify(caster, Damage.CRIT_DAMAGE, crit_damage)

	caster:AddOnRuneModifierAppliedCallback(function ( modifier_name, value )
		if modifier_name == "ziv_elementalist_mastery_damage" then
			Damage:Modify(caster, Damage.CRIT_CHANCE, -crit_chance)
			Damage:Modify(caster, Damage.CRIT_DAMAGE, value)
		end
	end)
	caster:AddOnRuneModifierRemovedCallback(function ( modifier_name, value )
		if modifier_name == "ziv_elementalist_mastery_damage" then
			Damage:Modify(caster, Damage.CRIT_CHANCE, crit_chance)
			Damage:Modify(caster, Damage.CRIT_DAMAGE, -value)
		end
	end)
end