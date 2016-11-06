function InitAgility(keys)
	local caster = keys.caster
	local ability = keys.ability

	local ratio = GetSpecial(ability, "armor_to_evasion_ratio") / 100

	caster:AddOnRuneModifierAppliedCallback(function ( modifier_name, value )
		if modifier_name == "ARMOR" then
			Damage:Modify(caster, Damage.EVASION, value * ratio)
		end
	end)
	caster:AddOnRuneModifierRemovedCallback(function ( modifier_name, value )
		if modifier_name == "ARMOR" then
			Damage:Modify(caster, Damage.EVASION, -value * ratio)
		end
	end)
end