function OnDamageTick( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local damage = GetRuneDamage(caster, GetSpecial(ability, "burn_damage_amp"), "ziv_samurai_reign_of_fire_damage")

	-- PopupCriticalDamage(target, damage)
	Damage:Deal(caster, target, damage, DAMAGE_TYPE_FIRE)
end

function OnDamage:Deal( keys )
	local caster = keys.caster
	local ability = keys.ability
	local damage = keys.Damage

	caster.OnDamageDealCallbacks = caster.OnDamageDealCallbacks or {}
	table.insert(caster.OnDamageDealCallbacks, function (caster, target, damage)
		if target:HasModifier("modifier_reign_of_fire_burn") == false then
			target:EmitSound("Hero_Huskar.Burning_Spear")
			ability:ApplyDataDrivenModifier(caster,target,"modifier_reign_of_fire_burn", {})
		end

		local leech = GetSpecial(ability, "hp_leech") + GRMSC("ziv_samurai_reign_of_fire_leech", caster)

		caster:Heal(damage * (leech / 100.0), caster:FindAbilityByName("ziv_samurai_reign_of_fire")) 
	end)
end

function InitReignOfFire( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:EmitSound("Hero_Phoenix.FireSpirits.Launch")

	ReleaseChildParticles( caster )

    if caster:HasModifier("modifier_cold_touch") then
    	caster:RemoveModifierByName("modifier_cold_touch")
    	SetToggleState( caster:FindAbilityByName("ziv_samurai_cold_touch"), false )
    end

	if ability:GetToggleState() == false then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_reign_of_fire",{})

	    local fire = ParticleManager:CreateParticle("particles/winter_fx/healing_campfire_flame_a.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(fire, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true) 
		table.insert(caster.particles, fire)
		table.insert(caster.particles, ParticleManager:CreateParticle("particles/heroes/samurai/samurai_fire_steps.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster))
		table.insert(caster.particles, ParticleManager:CreateParticle("particles/econ/courier/courier_wyvern_hatchling/courier_wyvern_hatchling_fire_f.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster))
	elseif caster:HasModifier("modifier_reign_of_fire") == true then
		caster:RemoveModifierByName("modifier_cold_touch")
	end

	ability:ToggleAbility()
end
