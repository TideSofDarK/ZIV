function OnDamageTick( keys )
	local caster = keys.caster
	local target = keys.target

	local ability = keys.ability

	local damage = math.ceil((caster:GetAverageTrueAttackDamage() / 100) * ability:GetSpecialValueFor("burn_damage_percent"))

	PopupCriticalDamage(target, damage)
	DealDamage(target, target, damage, DAMAGE_TYPE_MAGICAL)
end

function OnDealDamage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local damage = keys.Damage

	caster.OnDamageDealCallbacks = caster.OnDamageDealCallbacks or {}
	table.insert(caster.OnDamageDealCallbacks, function (target)
		ability:ApplyDataDrivenModifier(caster,target,"modifier_reign_of_fire_burn", {})
	end)
end

function InitReignOfFire( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster.particles = caster.particles or {}

	for k,v in pairs(caster.particles) do
      ParticleManager:DestroyParticle(v, false)
    end

	if ability:GetToggleState() == false then
		caster:RemoveModifierByName("modifier_cold_touch")
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

function Toggle( keys )
	local ability = keys.ability
	ability:ToggleAbility()
end