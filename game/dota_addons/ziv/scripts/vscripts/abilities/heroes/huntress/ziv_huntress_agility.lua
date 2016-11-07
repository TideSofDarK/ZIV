function InitAgility(keys)
	local caster = keys.caster
	local ability = keys.ability

	-- local ratio = GetSpecial(ability, "armor_to_evasion_ratio") / 100

	caster:AddOnRuneModifierAppliedCallback(function ( modifier_name, value )
		if modifier_name == "ziv_huntress_agility_ratio" then
			local bonus_ratio = value / 100
			Damage:Modify(caster, Damage.EVASION, Damage:GetValue( caster, Damage.ARMOR ) * bonus_ratio)
		end
		if modifier_name == "ARMOR" then
			local ratio = (GetSpecial(ability, "armor_to_evasion_ratio") + GRMSC("ziv_huntress_agility_ratio", caster)) / 100
			Damage:Modify(caster, Damage.EVASION, value * ratio)
		end
	end)
	caster:AddOnRuneModifierRemovedCallback(function ( modifier_name, value )
		if modifier_name == "ziv_huntress_agility_ratio" then
			local bonus_ratio = -value / 100
			Damage:Modify(caster, Damage.EVASION, Damage:GetValue( caster, Damage.ARMOR ) * bonus_ratio)
		end
		if modifier_name == "ARMOR" then
			local ratio = (GetSpecial(ability, "armor_to_evasion_ratio") + GRMSC("ziv_huntress_agility_ratio", caster)) / 100
			Damage:Modify(caster, Damage.EVASION, -value * ratio)
		end
	end)
end