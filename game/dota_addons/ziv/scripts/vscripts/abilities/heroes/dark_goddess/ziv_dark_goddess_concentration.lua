function ToggleConcentration( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability:GetToggleState() == true then
		caster:RemoveModifierByName("modifier_concentration")
	else
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_concentration",{})
	end

	ability:ToggleAbility()
end