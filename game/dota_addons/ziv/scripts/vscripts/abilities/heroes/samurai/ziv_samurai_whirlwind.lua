function StartWhirlwind( keys )
	local caster = keys.caster
	local ability = keys.ability

	local _duration = ability:GetSpecialValueFor("duration")

	ability:StartCooldown(_duration - 0.1)

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_whirlwind",{})

	if caster:HasModifier("modifier_animation") == false then
		StartAnimation(caster, {duration=-1, activity=ACT_DOTA_OVERRIDE_ABILITY_1, rate=1.25})
		caster:EmitSound("Greevil.BladeFuryStart")
	end

	if not caster.whirlwind_particle then
		local whirlwind_particle_name = "particles/econ/items/juggernaut/highplains_sword_longfang/juggernaut_blade_fury_longfang.vpcf"
		if caster:HasModifier("modifier_cold_touch") then
			whirlwind_particle_name = "particles/heroes/samurai/samurai_whirlwind_cold.vpcf"
		end

		caster.whirlwind_particle = ParticleManager:CreateParticle(
			whirlwind_particle_name, 
			PATTACH_ABSORIGIN_FOLLOW, 
			caster)
		ParticleManager:SetParticleControl(caster.whirlwind_particle, 0, Vector(0,0,20))
		ParticleManager:SetParticleControl(caster.whirlwind_particle, 5, Vector(285,1,1))

		Timers:CreateTimer(_duration + 0.03, function ()
			if caster:HasModifier("modifier_whirlwind") == false then
				ParticleManager:DestroyParticle(caster.whirlwind_particle, false)
				caster.whirlwind_particle = nil
				EndAnimation(caster)
				-- StopSoundEvent(, caster)
				StopSoundOn("Greevil.BladeFuryStart", caster)
				caster:EmitSound("Hero_Juggernaut.BladeFuryStop")
			else
				return 0.3
			end
		end)
	else

	end
end

function DamageTick( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local particle = ParticleManager:CreateParticle(
			"particles/creeps/ziv_creep_blood_a.vpcf", 
			PATTACH_ABSORIGIN_FOLLOW, 
			target)

	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 

	DealDamage( caster, target, caster:GetAverageTrueAttackDamage() / 3, DAMAGE_TYPE_PURE )
end

function InitParticles( keys )
	local caster = keys.caster
	local ability = keys.ability

end