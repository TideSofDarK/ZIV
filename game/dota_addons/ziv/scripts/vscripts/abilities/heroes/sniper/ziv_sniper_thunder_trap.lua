function CreateTrapUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

	local _duration = ability:GetLevelSpecialValueFor("trap_duration", ability:GetLevel())

	local trap = CreateUnitByName("npc_thunder_trap", target, false, caster, caster, caster:GetTeamNumber())

	InitAbilities(trap)

	Timers:CreateTimer(0.35, function (  )
		local sparks = ParticleManager:CreateParticle("particles/heroes/sniper/sniper_thunder_trap_sparks.vpcf", PATTACH_CUSTOMORIGIN, trap)
		ParticleManager:SetParticleControl(sparks, 1, trap:GetAbsOrigin() + Vector(0,0,32))

		AddChildParticle( trap, sparks )
	end)

	keys.trap = trap

	TrapTimer( keys, CheckUnits, RemoveTrapUnit, _duration )
end

function RemoveTrapUnit( keys )
	local caster = keys.caster
	local trap = keys.trap
	local ability = keys.ability

	if trap then
		trap:EmitSound("Tutorial.Notice.Speech")

		Timers:CreateTimer(1.0, function (  )
			Explode( keys )
		end)

		trap.worldPanel = WorldPanels:CreateWorldPanelForAll(
		    {layout = "file://{resources}/layout/custom_game/worldpanels/trap_countdown.xml",
		      entity = trap:GetEntityIndex(),
		      data = { delay = 1.0, boom = "ZAP!" },
		      entityHeight = 170,
		    })
	end
end

function Explode( keys )
	local caster = keys.caster
	local trap = keys.trap
	local ability = keys.ability

	if trap then
		local units_in_radius = FindUnitsInRadius(caster:GetTeamNumber(), trap:GetAbsOrigin(),  nil, ability:GetSpecialValueFor("trap_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

		local current_unit

		if #units_in_radius > 0 then
			for k,v in pairs(units_in_radius) do
				if not current_unit then
					current_unit = v
				else
					local arc = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_POINT, v)
					ParticleManager:SetParticleControl(arc, 0, current_unit:GetAbsOrigin() + Vector(0,0,48))
					ParticleManager:SetParticleControl(arc, 1, v:GetAbsOrigin() + Vector(0,0,48))	
				end

				ability:ApplyDataDrivenModifier(caster, v, "modifier_thunder_trap_effect", {})
				DealDamage( caster, v, caster:GetAverageTrueAttackDamage() * ability:GetSpecialValueFor("damage_amp"), DAMAGE_TYPE_LIGHTNING )
			end
		end

		local explosion = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start_bolt_parent.vpcf", PATTACH_CUSTOMORIGIN, trap)
		ParticleManager:SetParticleControl(explosion, 0, trap:GetAbsOrigin() + Vector(0,0,32))
		ParticleManager:SetParticleControl(explosion, 1, trap:GetAbsOrigin() + Vector(0,0,32))

		ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_earthshock_dust.vpcf", PATTACH_ABSORIGIN, trap)
		ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_dust_hit.vpcf", PATTACH_ABSORIGIN, trap)
		ParticleManager:CreateParticle("particles/econ/items/doom/doom_f2p_death_effect/doom_bringer_f2p_death_ground_smoke.vpcf", PATTACH_ABSORIGIN, trap)

		trap:EmitSound("Hero_Zuus.LightningBolt")

		Timers:CreateTimer(0.6, function (  )
			trap:RemoveModifierByName("dummy_unit")
			DestroyEntityBasedOnHealth(trap, trap)
			trap:SetRenderMode(10)
		end)
	end
end