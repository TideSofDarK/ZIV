function Flee( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local regen_duration = ability:GetSpecialValueFor("duration")
	local base_regen = ability:GetSpecialValueFor("base_regen")

	target:EmitSound("DOTA_Item.HealingSalve.Activate")

	ability:ApplyDataDrivenModifier(caster, target, "modifier_frenzy", {duration=regen_duration})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_frenzy_tooltip", {duration=regen_duration})

	Timers:CreateTimer(function ()
		if target:HasModifier("modifier_frenzy") then
			local stack_count = (1.0 - (target:GetHealth() / target:GetMaxHealth())) * base_regen

			target:SetModifierStackCount("modifier_frenzy", caster, stack_count)

			return 0.03
		end
	end)
end