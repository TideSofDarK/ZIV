function CreateTrapUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

	local _duration = ability:GetLevelSpecialValueFor("trap_duration", ability:GetLevel())

	local trap = CreateUnitByName("npc_explosive_trap", target, false, nil, caster:GetPlayerOwner(), caster:GetTeamNumber())

	InitAbilities(trap)

	Timers:CreateTimer(0.35, function (  )
		if trap and trap:IsNull() == false and trap:HasModifier("dummy_unit") then
			local sparks = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, trap)
			ParticleManager:SetParticleControl(sparks, 0, trap:GetAbsOrigin() + Vector(0,0,32))

			AddChildParticle( trap, sparks )

			return 0.3
		end
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
		      data = { delay = 1.0 },
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

		if #units_in_radius > 0 then
			for k,v in pairs(units_in_radius) do
				ability:ApplyDataDrivenModifier(caster, v, "modifier_explosive_trap_effect", {})
				DealDamage( caster, v, caster:GetAverageTrueAttackDamage() * ability:GetSpecialValueFor("damage_amp"), DAMAGE_TYPE_PURE )
			end
		end

		local explosion = ParticleManager:CreateParticle("particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", PATTACH_CUSTOMORIGIN, trap)
		ParticleManager:SetParticleControl(explosion, 3, trap:GetAbsOrigin() + Vector(0,0,128))
		explosion = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_flamebreak_explosion.vpcf", PATTACH_CUSTOMORIGIN, trap)
		ParticleManager:SetParticleControl(explosion, 3, trap:GetAbsOrigin() + Vector(0,0,128))
		explosion = ParticleManager:CreateParticle("particles/generic_gameplay/dust_impact_large.vpcf", PATTACH_ABSORIGIN_FOLLOW, trap)
		explosion = ParticleManager:CreateParticle("particles/neutral_fx/roshan_slam_debris_small.vpcf", PATTACH_ABSORIGIN_FOLLOW, trap)
		trap:EmitSound("Hero_Techies.LandMine.Detonate")

		trap:RemoveModifierByName("dummy_unit")
		trap:SetRenderMode(10)

		Timers:CreateTimer(0.6, function (  )
			DestroyEntityBasedOnHealth(trap, trap)
		end)
	end
end