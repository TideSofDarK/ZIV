function Form( keys )
	local caster = keys.caster
	local ability = keys.ability

	ability.original_model = caster:GetModelName()

	caster:SetModel("models/heroes/undying/undying_flesh_golem.vmdl")
	caster:SetOriginalModel("models/heroes/undying/undying_flesh_golem.vmdl")
end

function FormEnd( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:SetModel(ability.original_model)
	caster:SetOriginalModel(ability.original_model)
end