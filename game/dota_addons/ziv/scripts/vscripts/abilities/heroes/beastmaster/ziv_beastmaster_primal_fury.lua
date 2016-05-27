function OnTakeDamage( keys )
	local caster = keys.caster
	local ability = keys.ability

	local duration = GetSpecial(ability, "duration")
	local max_stacks = GetSpecial(ability, "max_stacks")

	AddStackableModifierWithDuration(caster, caster, ability, "modifier_primal_fury_stacks", duration, max_stacks)
end