function OnDealDamage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local damage = keys.Damage

	caster.OnDamageDealCallbacks = caster.OnDamageDealCallbacks or {}
	table.insert(caster.OnDamageDealCallbacks, function (target)
		local bonus_damage = math.ceil(damage/10)
		DealDamage( target, target, bonus_damage, DAMAGE_TYPE_MAGICAL )
		-- PopupColdDamage(target, bonus_damage)

		ParticleManager:CreateParticle("particles/creeps/ziv_creep_blood_frozen.vpcf", PATTACH_POINT_FOLLOW, target)

		ability:ApplyDataDrivenModifier(caster,target,"modifier_cold_touch_frozen", {})
	end)
end

function InitColdTouch( keys )
	local caster = keys.caster
	local ability = keys.ability

	ReleaseChildParticles( caster )

    if caster:HasModifier("modifier_reign_of_fire") then
    	caster:RemoveModifierByName("modifier_reign_of_fire")
    	SetToggleState( caster:FindAbilityByName("ziv_samurai_reign_of_fire"), false )
    end

    if ability:GetToggleState() == false then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_cold_touch",{})

		table.insert(caster.particles, ParticleManager:CreateParticle("particles/econ/courier/courier_roshan_frost/courier_roshan_frost_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster))
    elseif caster:HasModifier("modifier_cold_touch") == true then
		caster:RemoveModifierByName("modifier_cold_touch")
	end

	ability:ToggleAbility()
end