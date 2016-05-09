function Consume( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:SetChanneling(true)

	Timers:CreateTimer(0.1, function (  )
		if ability:IsChanneling() then
			ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN, caster)
			StartAnimation(caster, {duration=0.6, activity=ACT_DOTA_ATTACK, rate=1.5})

			EndAnimation(target)
			StartAnimation(target, {duration=-1, activity=ACT_DOTA_DISABLED, rate=1.5})

			ability:ApplyDataDrivenModifier(caster, target, "modifier_undying_consume", {duration = 0.5})
			DealDamage(caster, target, target:GetMaxHealth() * GetSpecial(ability, "hp_percent"), DAMAGE_TYPE_PHYSICAL)

			return 0.5
		else
			EndAnimation(target)
		end
	end)
end