function Barrier( event )
	local caster = event.caster
	local ability = event.ability
	local damage_per_mana = GetSpecial(ability, "damage_per_ep")
	local damage_absorption = GetSpecial(ability, "damage_absorption")
	local damage = event.Damage * damage_absorption
	local not_reduced_damage = event.Damage - damage

	local caster_mana = caster:GetMana()
	local mana_needed = damage / damage_per_mana

	local old_health = (caster.old_health or 0) - not_reduced_damage

	if old_health >= 1 then
		if mana_needed <= caster_mana then
			caster:SpendMana(mana_needed, ability)
			caster:SetHealth(old_health)

			local particle_name = "particles/heroes/elementalist/elementalist_barrier_impact.vpcf"
			local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, caster)

			ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(mana_needed,0,0))
		else
			local new_health = old_health - damage
			caster:SpendMana(mana_needed, ability)
			caster:SetHealth(new_health)
		end
	end	
end

function BarrierHealth( event )
	local caster = event.caster

	caster.old_health = caster:GetHealth()
end