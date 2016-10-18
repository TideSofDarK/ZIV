function Toggle( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability:GetToggleState() then
		caster:RemoveModifierByName("modifier_soul_sacrifice")
	else
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_soul_sacrifice",{})
	end

	ability:ToggleAbility()
end

function Sacrifice( keys )
	local caster = keys.caster
	local ability = keys.ability

	local ratio = GetSpecial(ability, "hp_to_ep_ratio") - (GRMSC("ziv_witch_doctor_soul_sacrifice_ratio", caster) / 100)
	local hp = GetSpecial(ability, "hp_to_ep_per_second")
	local tick = GetSpecial(ability, "tick")

	local damage = hp * tick
	local ep = damage / ratio

	caster:SetHealth(math.max(1, caster:GetHealth() - damage))
	caster:GiveMana(ep)
end