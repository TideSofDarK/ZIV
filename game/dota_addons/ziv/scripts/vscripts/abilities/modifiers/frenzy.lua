function SetScale( keys )
	local caster = keys.caster
	caster:SetModelScale(keys.ability:GetLevelSpecialValueFor("bonus_size", 1))
end