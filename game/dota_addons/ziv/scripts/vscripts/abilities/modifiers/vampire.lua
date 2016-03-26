function Lifesteal(keys)
	if keys.target.GetInvulnCount == nil then
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_creep_lifesteal_effect", {duration = 0.03})
	end
end