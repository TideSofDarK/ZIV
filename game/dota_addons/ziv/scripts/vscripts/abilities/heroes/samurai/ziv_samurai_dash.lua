function Dash( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	ProjectileManager:ProjectileDodge(caster)

	local ability_level = ability:GetLevel() - 1

	StartAnimation(caster, {duration=ability:GetSpecialValueFor("duration"), activity=ACT_DOTA_OVERRIDE_ABILITY_4, rate=5.4})

	ability.direction = UnitLookAtPoint( caster, target )

	ability.distance = 450

	ability.speed = ability:GetLevelSpecialValueFor("dash_speed", ability_level)

	ability.traveled = 0

	caster:AddNewModifier( caster, nil, "modifier_disarmed", {duration=0.25} )

	caster:SetForwardVector(UnitLookAtPoint( caster, target ))
	caster:Stop()

	if ability.particle or ability.particle2 then
		ParticleManager:DestroyParticle(ability.particle, false)
		ParticleManager:DestroyParticle(ability.particle2, false)

		ability.particle=nil
		ability.particle2=nil
	end

	local blade_trail_particle = "particles/heroes/samurai/samurai_blade_trail.vpcf"
	if caster:HasModifier("modifier_cold_touch") then
		blade_trail_particle = "particles/heroes/samurai/samurai_blade_trail_cold.vpcf"
	end

	ability.particle = ParticleManager:CreateParticle("particles/heroes/samurai/samurai_dash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ability.particle2 = ParticleManager:CreateParticle(blade_trail_particle, PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(ability.particle2, 0, caster, PATTACH_POINT_FOLLOW, "blade_attachment", caster:GetAbsOrigin(), false) 

	Timers:CreateTimer(0.27, function (  )
		ParticleManager:DestroyParticle(ability.particle, false)
		ParticleManager:DestroyParticle(ability.particle2, false)

		caster:SetForwardVector(ability.direction)
		caster:Stop()
	end)
end

function DashHorizontal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.traveled < ability.distance then
		ability.speed = ability.speed + 2
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.direction * ability.speed)

		ability.traveled = ability.traveled + ability.speed
	else
		caster:InterruptMotionControllers(true)
	end
end

function DealDashDamage( keys )
	local caster = keys.caster
	local target = keys.target
	if target:HasModifier("modifier_dash_hit") == false then
		local trailFxIndex = ParticleManager:CreateParticle( "particles/econ/items/juggernaut/bladekeeper_omnislash/_dc_juggernaut_omni_slash_trail.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( trailFxIndex, 0, target:GetAbsOrigin() )
		ParticleManager:SetParticleControl( trailFxIndex, 1, caster:GetAbsOrigin() )
		
		Timers:CreateTimer( 0.09, function()
				ParticleManager:DestroyParticle(trailFxIndex, true)
				ParticleManager:ReleaseParticleIndex(trailFxIndex)
			end
		)
		
		keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_dash_hit",{duration=1.0})

		DealDamage( caster, target, GetRuneDamage(caster, 0, "ziv_samurai_dash_damage"), DAMAGE_TYPE_PHYSICAL )
	end
end