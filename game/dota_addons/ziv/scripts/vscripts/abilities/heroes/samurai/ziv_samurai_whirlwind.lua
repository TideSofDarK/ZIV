function StartWhirlwind( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

	local target_unit = FindUnitsInRadius(caster:GetTeamNumber(), target, nil, 98, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)[1]
	if target_unit then
		target = target_unit:GetAbsOrigin()
	end

	-- caster:MoveToPosition(target)

	local _duration = ability:GetSpecialValueFor("duration")

	ability:StartCooldown(_duration - 0.1)

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_whirlwind",{})

	if caster:HasModifier("modifier_animation") == false then
		StartAnimation(caster, {duration=-1, activity=ACT_DOTA_OVERRIDE_ABILITY_1, rate=1.25})

		ability.sound = ability.sound or false
		if ability.sound == false then
			StartSoundEvent("Greevil.BladeFuryStart", caster)
			ability.sound = true
		end
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

				if ability.sound == true then
					StopSoundEvent("Greevil.BladeFuryStart", caster)
					ability.sound = false
				end

				caster:EmitSound("Hero_Juggernaut.BladeFuryStop")
			else
				return 0.3
			end
		end)
	else

	end

	caster:MoveToPosition(target)
end

function DamageTick( keys )
	local caster = keys.caster
	local ability = keys.ability

	local units_in_radius = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),  nil, ability:GetSpecialValueFor("radius") + GRMSC("ziv_samurai_whirlwind_aoe", caster), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	if #units_in_radius > 0 then
		caster:EmitSound("Hero_Abaddon.Attack")
	end

	for k,v in pairs(units_in_radius) do
		local target = v

		local particle = ParticleManager:CreateParticle(
				"particles/creeps/ziv_creep_blood_a.vpcf", 
				PATTACH_ABSORIGIN_FOLLOW, 
				target)

		ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 

		local damage_type = DAMAGE_TYPE_FIRE
		if caster:HasModifier("modifier_cold_touch") then
			damage_type = DAMAGE_TYPE_COLD
		end

		DealDamage( caster, target, GetRuneDamage("ziv_samurai_whirlwind_damage",caster) / 1.5, damage_type )
	end
end