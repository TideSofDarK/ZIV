function DragonComes( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	StartRuneCooldown(ability,"ziv_knight_dragon_cd",caster)

	local height = ability:GetSpecialValueFor("dragon_height")
	local radius = ability:GetSpecialValueFor("spawn_radius")

	local explosion_radius = ability:GetSpecialValueFor("explosion_radius") + GRMSC("ziv_knight_dragon_radius", caster)
	local explosion_damage = ability:GetSpecialValueFor("explosion_damage_amp") * caster:GetAverageTrueAttackDamage()

	local burn_duration = ability:GetSpecialValueFor("burn_duration")
	local burn_damage = ability:GetSpecialValueFor("burn_damage_amp") * caster:GetAverageTrueAttackDamage()

	local flee_seconds = 14

	target["3"] = target["3"] - 128

	local dragon = CreateUnitByName("npc_knight_ult_dragon", target, false, nil, caster:GetPlayerOwner(), caster:GetTeamNumber())
	dragon:RemoveModifierByName("dummy_unit")
	ability:ApplyDataDrivenModifier(caster, dragon, "modifier_dragon", {})

	local seed = math.random(0, 6.28)

	local x = (radius * math.cos(seed)) + target["1"]
	local y = (radius * math.sin(seed)) + target["2"]

	dragon:SetAbsOrigin(Vector(x, y, height))

	Timers:CreateTimer(function (  )

		local oldX = dragon:GetAbsOrigin()["1"]
		local oldY = dragon:GetAbsOrigin()["2"]
		local oldZ = dragon:GetAbsOrigin()["3"]

		local newX = lerp(oldX, target["1"], 0.03 * 1)
		local newY = lerp(oldY, target["2"], 0.03 * 1)
		local newZ = target["3"] + ((newX-target["1"])^2 + (newY-target["2"])^2) * (height - target["3"]) / (radius*radius)

		dragon:SetAbsOrigin(Vector(newX, newY, newZ))

		dragon:SetForwardVector((target - dragon:GetAbsOrigin()):Normalized())

		if dragon:GetAbsOrigin()["3"] - target["3"] < 10 then
			StartAnimation(dragon, {duration=2.0, activity=ACT_DOTA_CAST_ABILITY_2, rate=0.3})

			Timers:CreateTimer(0.6, function (  )
				local particle1 = ParticleManager:CreateParticle("particles/phoenix_supernova_reborn.vpcf", PATTACH_ABSORIGIN, dragon)
				ParticleManager:SetParticleControl(particle1, 0, target + Vector(0,0,30))
			    ParticleManager:SetParticleControl(particle1, 3, target + Vector(0,0,30))

			    local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf", PATTACH_ABSORIGIN, dragon)
				ParticleManager:SetParticleControl(particle2, 0, target + Vector(0,0,30))
			    ParticleManager:SetParticleControl(particle2, 1, target + Vector(0,0,30))
			    ParticleManager:SetParticleControl(particle2, 2, Vector(3, 0, 0))

			    dragon:EmitSound("Hero_Warlock.RainOfChaos")
			    dragon:EmitSound("Hero_DragonKnight.BreathFire")

			    local units = FindUnitsInRadius(caster:GetTeamNumber(), target,  nil, explosion_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			    local burn_timer = 0
			    Timers:CreateTimer(function (  )
			    	local units_in_burn_radius = FindUnitsInRadius(caster:GetTeamNumber(), target,  nil, explosion_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			    	for k,v in pairs(units_in_burn_radius) do
						DealDamage(caster, v, burn_damage, DAMAGE_TYPE_FIRE)
			    	end

			    	burn_timer = burn_timer + 1
			    	if burn_timer < burn_duration then return 1.0 end
			    end)

			    for k,v in pairs(units) do
			    	local knockbackModifierTable =
				    {
				        should_stun = 1,
				        knockback_duration = 1.1,
				        duration = 1.1,
				        knockback_distance = 55,
				        knockback_height = 140,
				        center_x = dragon:GetAbsOrigin().x,
				        center_y = dragon:GetAbsOrigin().y,
				        center_z = dragon:GetAbsOrigin().z
				    }
					v:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )

				    DealDamage(caster, v, explosion_damage, DAMAGE_TYPE_FIRE)
			    end
			end)

			local fixedDirection = dragon:GetForwardVector()
			fixedDirection["3"] = 0
			local newTarget = (fixedDirection * radius * 3.9) + Vector(0, 0, height) + dragon:GetAbsOrigin()

			local t = 0

			Timers:CreateTimer(1.85, function (  )
				local oldX = dragon:GetAbsOrigin()["1"]
				local oldY = dragon:GetAbsOrigin()["2"]
				local oldZ = dragon:GetAbsOrigin()["3"]

				local newX = lerp(oldX, newTarget["1"], smoothstep(0.0, 1.0, t))
				local newY = lerp(oldY, newTarget["2"], smoothstep(0.0, 1.0, t))
				local newZ = lerp(oldZ, newTarget["3"], 0.03 * 0.2)

				t = t + (0.03 / flee_seconds)

				dragon:SetAbsOrigin(Vector(newX, newY, newZ))
				if newTarget["3"] - dragon:GetAbsOrigin()["3"] > 600 then
					return 0.03
				else
					UTIL_Remove(dragon)
				end
			end)
		else
			return 0.03
		end	
	end)
end