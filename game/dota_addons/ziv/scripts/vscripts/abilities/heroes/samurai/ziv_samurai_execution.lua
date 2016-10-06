function StartAttack( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	StartRuneCooldown(ability,"ziv_samurai_execution_cd",caster)

	StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_ATTACK_EVENT, rate=2.2})

	local cold = caster:HasModifier("modifier_cold_touch") 

	local trail = "particles/heroes/samurai/samurai_execution_trail_fire.vpcf"
	local fx = "particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare_explosion_flash_c.vpcf"

	if cold then
		trail = "particles/heroes/samurai/samurai_execution_trail_ice.vpcf"
		fx = "particles/heroes/samurai/samurai_execution_frost_earth.vpcf"
	end

	local particle = ParticleManager:CreateParticle(trail, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetOrigin())

	caster:EmitSound("Hero_DragonKnight.PreAttack")

	Timers:CreateTimer(0.09, function()
		particle = ParticleManager:CreateParticle('particles/heroes/samurai/samurai_execution_cleave.vpcf', PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, target)

		particle = ParticleManager:CreateParticle("particles/heroes/samurai/samurai_execution_cleave_dust.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, target)

		local earth_particle_name = "particles/units/heroes/hero_ursa/ursa_earthshock_soil.vpcf"
		local damage_type = DAMAGE_TYPE_PHYSICAL
		if caster:HasModifier("modifier_cold_touch") then
			earth_particle_name = fx

			damage_type = DAMAGE_TYPE_COLD
		else
			local fire_effect = ParticleManager:CreateParticle(fx, PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(fire_effect, 3, target)
		
			damage_type = DAMAGE_TYPE_FIRE
		end

		particle = ParticleManager:CreateParticle(earth_particle_name, PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, target)

		local units = FindUnitsInRadius(caster:GetTeamNumber(), target, nil, ability:GetSpecialValueFor("radius") + GRMSC("ziv_samurai_execution_aoe", caster), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

		caster:EmitSound("Hero_EarthShaker.Attack")

    	for k,v in pairs(units) do
    		
    		if GetRuneChance("ziv_samurai_execution_knockback_chance",caster) then
    			local knockbackModifierTable =
			    {
			        should_stun = 0,
			        knockback_duration = 0.5,
			        duration = 0.5,
			        knockback_distance = 64,
			        knockback_height = 32,
			        center_x = target.x,
			        center_y = target.y,
			        center_z = target.z
			    }
				v:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )
			end
			
		    DealDamage( caster, v, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), ""), damage_type )
    	end
	end)
end