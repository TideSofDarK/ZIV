function BirdHeal( keys )
	local caster = keys.caster
	local ability = keys.ability

	local hp_per_sec = GetSpecial(ability, "hp_per_sec") / 3
	local sp_per_second = GetRunePercentDecrease((GetSpecial(ability, "sp_per_second") / 3),"ziv_beastmaster_bird_manacost",caster)

	if caster:GetMana() >= sp_per_second then
		caster:Heal(hp_per_sec, caster)
		caster:SpendMana(sp_per_second,ability)
	else
		KillBird( keys )
		if ability:GetToggleState() == true then
			ability:ToggleAbility()
		end
	end
end

function BirdDamage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	Damage:Deal(caster, target, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "ziv_beastmaster_bird_damage"), DAMAGE_TYPE_PHYSICAL)
	
	if GetRuneChance("ziv_beastmaster_bird_blind_chance",caster) then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_bird_blindness",{})
		target:EmitSound("Hero_Antimage.ManaBreak")
	end
end

function BirdAttack( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability.bird and ability.bird:IsNull() == false and ability.bird:IsAlive() then
		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, GetSpecial(ability, "bird_radius") * 2, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

		local seed = math.random(1, #units)

		if #units > 0 then 
			local projectile_info = 
		    {
		        EffectName = "particles/heroes/beastmaster/beastmaster_bird_attack.vpcf",
		        Ability = ability,
		        Target =  units[seed],
		        Source = ability.bird,
		        bHasFrontalCone = false,
		        iMoveSpeed = 1300,
		        bReplaceExisting = false,
		        bProvidesVision = false,
		        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
		    }

		    ability.bird:EmitSound("Hero_ShadowShaman.Attack")

			ProjectileManager:CreateTrackingProjectile(projectile_info)
		end
	end
end

function KillBird( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability.bird and ability.bird:IsNull() == false and ability.bird:IsAlive() then
		ability.bird:ForceKill(false)

		caster:EmitSound("Hero_Beastmaster_Bird.Death")

		ability:ToggleAbility()
	end
end

function Bird( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability:GetToggleState() == true then
		KillBird( keys )
	else
		local bird = CreateUnitByName("npc_beastmaster_bird", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
		ability.bird = bird
		ability:ApplyDataDrivenModifier(caster, bird, "modifier_bird", {})

		caster:EmitSound("Hero_Beastmaster.Call.Hawk")

		local oldPos = caster:GetAbsOrigin()
		oldPos.z = 100
		oldPos.x = oldPos.x + 200
		bird:SetAbsOrigin(oldPos)

		local particle

		Timers:CreateTimer(0.75, function (  )
			-- particle = ParticleManager:CreateParticle("particles/heroes/beastmaster/beastmaster_bird_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, bird)
			-- AddChildParticle( bird, particle )

			ability:ApplyDataDrivenModifier(caster, caster, "modifier_bird_heal", {})
		end)

		local t = 0

	    Timers:CreateTimer(function (  )
	    	

			if bird:IsAlive() == true and caster:IsAlive() == true then
				local new_pos = caster:GetAbsOrigin() + PointOnCircle(GetSpecial(ability, "bird_radius"), t)
				bird:SetForwardVector(lerp_vector(bird:GetForwardVector(), UnitLookAtPoint( bird, new_pos + Vector(0,0,100) ), 0.03 * 10)) 
				bird:SetAbsOrigin(new_pos + Vector(0,0,100))

				if particle then
					ParticleManager:SetParticleControlEnt(particle, 0, bird, PATTACH_POINT_FOLLOW, "attach_hitloc", bird:GetAbsOrigin(), true)
		    		ParticleManager:SetParticleControl(particle, 1, caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_hitloc")))
				end

				t = t + 3.0
				if t > 360 then t = 360 - t end
				return 0.03
			end
	    end)

	    ability:ToggleAbility()
	end
end