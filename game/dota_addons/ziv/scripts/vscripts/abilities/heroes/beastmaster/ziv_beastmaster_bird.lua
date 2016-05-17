function BirdHeal( keys )
	local caster = keys.caster
	local ability = keys.ability

	local hp_per_sec = GetSpecial(ability, "hp_per_sec") / 3
	local sp_per_second = GetSpecial(ability, "sp_per_second") / 3

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

function KillBird( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability.bird and ability.bird:IsNull() == false and ability.bird:IsAlive() then
		ability.bird:ForceKill(false)
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

		local oldPos = caster:GetAbsOrigin()
		oldPos.z = 100
		oldPos.x = oldPos.x + 200
		bird:SetAbsOrigin(oldPos)

		local particle

		Timers:CreateTimer(0.75, function (  )
			particle = ParticleManager:CreateParticle("particles/heroes/beastmaster/beastmaster_bird_beam.vpcf", PATTACH_ABSORIGIN, bird)
			AddChildParticle( bird, particle )

			ability:ApplyDataDrivenModifier(caster, caster, "modifier_bird_heal", {})
		end)

		local t = 0

	    Timers:CreateTimer(function (  )
	    	

			if bird:IsAlive() == true and caster:IsAlive() == true then
				local new_pos = caster:GetAbsOrigin() + PointOnCircle(250, t)
				bird:SetForwardVector(UnitLookAtPoint( bird, new_pos ))
				bird:SetAbsOrigin(new_pos)

				local z_delta = lerp(bird:GetModifierStackCount("modifier_bird",caster), 100, 0.03 * 3)
				bird:SetModifierStackCount("modifier_bird",caster,z_delta)

				if particle then
					ParticleManager:SetParticleControl(particle, 0, bird:GetAttachmentOrigin(bird:ScriptLookupAttachment("attach_hitloc")) + Vector(0,0,z_delta))
		    		ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin() + Vector(0,0,50))
				end

				t = t + 2.75
				if t > 360 then t = 360 - t end
				return 0.03
			end
	    end)
	end

	ability:ToggleAbility()
end