function Form( keys )
	local caster = keys.caster
	local ability = keys.ability

	ability.original_model = caster:GetModelName()

	caster:SetModel("models/heroes/undying/undying_flesh_golem.vmdl")
	caster:SetOriginalModel("models/heroes/undying/undying_flesh_golem.vmdl")

	TimedEffect("particles/units/heroes/hero_undying/undying_fg_transform.vpcf", caster, 2.0)
end

function FormEnd( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:SetModel(ability.original_model)
	caster:SetOriginalModel(ability.original_model)

	TimedEffect("particles/units/heroes/hero_undying/undying_fg_transform.vpcf", caster, 2.0)
end