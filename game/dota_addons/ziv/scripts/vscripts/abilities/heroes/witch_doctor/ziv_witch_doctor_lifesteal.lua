function Lifesteal( keys )
	local caster = keys.caster
	local ability = keys.ability

	local lifesteal_percent = ability:GetSpecialValueFor("lifesteal_percent")

	caster:Heal(tonumber(keys.Damage) * lifesteal_percent, caster)
end