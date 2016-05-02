function StartAttack( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_ATTACK_EVENT, rate=2.2})

	local p_endx = 'particles/econ/items/juggernaut/jugg_sword_fireborn_odachi/jugg_crit_blur_fb_odachi.vpcf'
	local p1 = ParticleManager:CreateParticle(p_endx, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(p1, 0, caster:GetOrigin())

	caster:EmitSound("Hero_DragonKnight.PreAttack")

	Timers:CreateTimer(0.09, function()
		p1 = ParticleManager:CreateParticle('particles/heroes/samurai/samurai_execution_cleave.vpcf', PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(p1, 0, target:GetOrigin())

		p1 = ParticleManager:CreateParticle("particles/heroes/samurai/samurai_execution_cleave_dust.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(p1, 0, target:GetOrigin())

		local earth_particle_name = "particles/units/heroes/hero_ursa/ursa_earthshock_soil.vpcf"
		local damage_type = DAMAGE_TYPE_PHYSICAL
		if caster:HasModifier("modifier_cold_touch") then
			earth_particle_name = "particles/heroes/samurai/samurai_execution_frost_earth.vpcf"

			damage_type = DAMAGE_TYPE_COLD
		else
			local fire_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare_explosion_flameouts.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(fire_effect, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
			fire_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare_explosion_flash_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(fire_effect, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
		
			damage_type = DAMAGE_TYPE_FIRE
		end

		p1 = ParticleManager:CreateParticle(earth_particle_name, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(p1, 0, target:GetOrigin())

		local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

		caster:EmitSound("Hero_EarthShaker.Attack")

    	for k,v in pairs(units) do
		    DealDamage( caster, v, caster:GetAverageTrueAttackDamage(), damage_type )
    	end

		DealDamage( caster, target, caster:GetAverageTrueAttackDamage(), DAMAGE_TYPE_PHYSICAL )
	end)
end