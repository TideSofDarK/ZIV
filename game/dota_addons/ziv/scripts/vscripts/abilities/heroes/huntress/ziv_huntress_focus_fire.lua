function StartBarrage( keys )
	local caster = keys.caster
	local target = keys.target:GetAbsOrigin()
	local ability = keys.ability

	local windrun_particle = ParticleManager:CreateParticle("particles/heroes/huntress/huntress_focus_fire_fx.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)

	local speed = 3000

	local projectiles = {}

	for i=1,10 do
		projectiles[i] = {
			vSpawnOrigin = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
			fDistance = 3000,
			fStartRadius = 64,
			fEndRadius = 64,
			Source = caster,
			fExpireTime = 8.0,
			UnitBehavior = PROJECTILES_DESTROY,
			bMultipleHits = false,
			bIgnoreSource = true,
			TreeBehavior = PROJECTILES_NOTHING,
			bCutTrees = false,
			bTreeFullCollision = false,
			WallBehavior = PROJECTILES_NOTHING,
			GroundBehavior = PROJECTILES_NOTHING,
			fGroundOffset = 80,
			nChangeMax = 1,
			bRecreateOnChange = true,
			bZCheck = false,
			bGroundLock = true,
			bProvidesVision = false,
			iVisionRadius = 350,
			iVisionTeamNumber = caster:GetTeam(),
			bFlyingVision = false,
			fVisionTickTime = .1,
			fVisionLingerDuration = 0.5,
			draw = false,
			UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
		}
	end

	local time = 0
	local tick = 0.05
	local _duration = 0.5

	local projectile_number = 1
	local projectile_count = 10

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_focus_fire",{duration = _duration})

	Timers:CreateTimer(function (  )
		if caster:HasModifier("modifier_focus_fire") and time < _duration and projectile_number <= projectile_count then
			local i = math.random(-3.0, 3.0)

			local targetPoint = RotatePosition(caster:GetAbsOrigin(), QAngle(0,i,0), target) + Vector(0,0,64)

			local distanceToTarget = (caster:GetAbsOrigin() - targetPoint):Length2D() + 100
		    local time = distanceToTarget/speed

			projectiles[projectile_number].fDistance = distanceToTarget
			projectiles[projectile_number].vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * speed * 1.1

			local projectileFX = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_base_attack.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(projectileFX, 0, caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")))
			ParticleManager:SetParticleControl(projectileFX, 1, targetPoint)
			ParticleManager:SetParticleControl(projectileFX, 2, Vector(speed, 0, 0))
			ParticleManager:SetParticleControl(projectileFX, 3, targetPoint)
			
		    Timers:CreateTimer(time, function()
		        ParticleManager:DestroyParticle(projectileFX, false)
		    end)

		    projectiles[projectile_number].OnUnitHit = (function(self, unit) 
				local bonusDamage = ability:GetLevelSpecialValueFor("bonus_damage", ability:GetLevel())

				DealDamage(caster, unit, (caster:GetAverageTrueAttackDamage() + bonusDamage) / 10, DAMAGE_TYPE_PHYSICAL)

				ParticleManager:SetParticleControl(projectileFX, 1, unit:GetAbsOrigin())
				ParticleManager:SetParticleControl(projectileFX, 2, Vector(0, 0, 0))
				ParticleManager:SetParticleControl(projectileFX, 3, unit:GetAbsOrigin())
				ParticleManager:DestroyParticle(projectileFX, false)
			end)

			Projectiles:CreateProjectile(projectiles[projectile_number])

		    caster:EmitSound("Hero_DrowRanger.Attack")
		    
		    StartAnimation(caster, {duration=0.1, activity=ACT_DOTA_ATTACK, rate=3.0, translate="focusfire"})

		    projectile_number = projectile_number + 1

		    time = time + tick
			return tick
		else
			ParticleManager:DestroyParticle(windrun_particle, false)
		end
	end)
end
