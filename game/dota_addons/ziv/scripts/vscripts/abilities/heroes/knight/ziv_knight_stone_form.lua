function StoneForm( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:SetModelScale(1.25)
end

function RollbackModelScale( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:SetModelScale(1)
end