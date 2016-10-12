function SetScale( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:SetModelScale(caster:GetModelScale() * GetSpecial(ability, "size"))
end