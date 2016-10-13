function StartBarrage( keys )
	local keys = keys

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	keys.effect = "particles/heroes/huntress/huntress_focus_fire_projectile.vpcf"
	keys.impact_effect = "particles/units/heroes/hero_windrunner/windrunner_base_attack_explosion_magic.vpcf"
	keys.attachment = "bowstring"
	keys.translate = 'focusfire'
	keys.projectile_speed = 2100
	keys.duration = 0.1
	keys.rate = 2.35
	keys.bonus_attack_speed = GetSpecial(ability, "attack_speed") + GRMSC("ziv_huntress_focus_fire_as", caster)
	keys.attack_sound = "Hero_DrowRanger.Attack"
	keys.interruptable = false
	keys.standard_targeting = false
	keys.on_impact = (function ( caster )
		Timers:CreateTimer(0.2, function (  )
			if caster:HasModifier("modifier_focus_fire") == false then
				ParticleManager:DestroyParticle(ability.windrun_particle, false)
				ability.windrun_particle = nil
			end
		end)
	end)

	ability.windrun_particle = ability.windrun_particle or nil
	if not ability.windrun_particle then
		ability.windrun_particle = ParticleManager:CreateParticle("particles/heroes/huntress/huntress_focus_fire_fx.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	end

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_focus_fire",{duration = keys.duration})

	SimulateRangeAttack(keys)
end
