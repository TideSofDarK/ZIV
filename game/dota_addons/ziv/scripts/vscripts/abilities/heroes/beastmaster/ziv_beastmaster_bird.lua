function BirdHeal( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local level = ability:GetLevel()

	local hp_per_sec = ability:GetLevelSpecialValueFor("hp_per_sec", level-1)

	target:Heal(hp_per_sec, caster)
end

function Bird( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local level = ability:GetLevel()

	local bird_duration = ability:GetSpecialValueFor("duration")
	local hp_per_sec = ability:GetLevelSpecialValueFor("hp_per_sec", level-1)

	local bird = CreateUnitByName("npc_beastmaster_bird", target:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, bird, "modifier_bird", {})
	bird:AddNewModifier(bird, nil, "modifier_kill", {duration = bird_duration})

	local oldPos = target:GetAbsOrigin()
	oldPos.z = 100
	oldPos.x = oldPos.x + 200
	bird:SetAbsOrigin(oldPos)

	local particle

	Timers:CreateTimer(0.75, function (  )
		particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_life_drain_beam.vpcf", PATTACH_ABSORIGIN, bird)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_bird_heal", {})
	end)

    Timers:CreateTimer(function (  )
		if bird:IsAlive() == true and target:IsAlive() == true then
			local oldPos = target:GetAbsOrigin()
			oldPos.z = 100
			oldPos.x = oldPos.x + 200

			local newPos = lerp_vector(bird:GetAbsOrigin(), oldPos, 0.03 * 3)

			bird:SetAbsOrigin(newPos)

			bird:SetForwardVector((target:GetAbsOrigin() - bird:GetAbsOrigin()):Normalized())

			if particle then
				ParticleManager:SetParticleControl(particle, 0, newPos + Vector(0,0,250))
	    		ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin() + Vector(0,0,50))
			end

			return 0.03
		else
			target:RemoveModifierByName("modifier_bird_heal")
			ParticleManager:DestroyParticle(particle, false)
		end
    end)
end