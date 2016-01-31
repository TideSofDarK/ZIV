ProjectileHolder = {} 

function Volley(args)
	local caster = args.caster
	local ability = args.ability
	local target = args.target_points[1]

	local projectile = {
		-- EffectName = args.EffectName,
		vSpawnOrigin = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
		fDistance = 3000,
		fStartRadius = 16,
		fEndRadius = 16,
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
		bProvidesVision = true,
		iVisionRadius = 350,
		iVisionTeamNumber = caster:GetTeam(),
		bFlyingVision = false,
		fVisionTickTime = .1,
		fVisionLingerDuration = 1,
		draw = false,
		UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
		OnUnitHit = function(self, unit) 
			local bonusDamage = ability:GetLevelSpecialValueFor("bonus_damage", ability:GetLevel())
			local damageTable = {
			    victim = unit,
			    attacker = caster,
			    damage = caster:GetAverageTrueAttackDamage() + bonusDamage,
			    damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage(damageTable)
		end,
	}

	Timers:CreateTimer(function (  )
		if ability:IsChanneling() == true then
			local i = math.random(-20, 20)

			local targetPoint = RotatePosition(caster:GetAbsOrigin(), QAngle(0,i,0), target)

			local distanceToTarget = (caster:GetAbsOrigin() - targetPoint):Length2D()
		    local time = distanceToTarget/args.MoveSpeed

			projectile.fDistance = distanceToTarget
			projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * args.MoveSpeed

			Projectiles:CreateProjectile(projectile)

			local projectileFX = ParticleManager:CreateParticle(args.EffectName, PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(projectileFX, 0, caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")))
			ParticleManager:SetParticleControl(projectileFX, 1, targetPoint)
			ParticleManager:SetParticleControl(projectileFX, 2, Vector(args.MoveSpeed, 0, 0))
			ParticleManager:SetParticleControl(projectileFX, 3, targetPoint)
			
		    Timers:CreateTimer(time, function()
		        ParticleManager:DestroyParticle(projectileFX, false)
		    end)
		    EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Gyrocopter.Attack", caster)
		    

			return 0.07
		else

		end
	end)
end