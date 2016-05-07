function Consume( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	Timers:CreateTimer(function (  )
		if ability:IsChanneling() then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_undying_consume", {duration = 0.5})
			DealDamage(caster, target, target:GetMaxHealth() * GetSpecial(ability, "hp_percent"), DAMAGE_TYPE_PHYSICAL)
			return 0.5
		end
	end)
end