function Lifesteal( keys )
	local caster = keys.caster
	local ability = keys.ability

	local lifesteal_percent = ability:GetSpecialValueFor("lifesteal_percent")

	caster:Heal(tonumber(keys.Damage) * lifesteal_percent, caster)

	local mana = GRMSC("ziv_witch_doctor_lifesteal_mana", caster) / 100
	caster:GiveMana(tonumber(keys.Damage) * mana)
	if mana > 0 then
		-- TODO Mana particles
	end
end