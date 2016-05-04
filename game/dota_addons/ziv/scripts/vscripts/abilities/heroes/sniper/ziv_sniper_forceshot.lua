ProjectileHolder = {} 

function Forceshot(args)
	local caster = args.caster
	local ability = args.ability
	local target = args.target_points[1]

	local castRange = ability:GetCastRange()

	Timers:CreateTimer(0.27, function (  )
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Ability.Assassinate", caster)

		for i=-27.5,27.5,(27.5/3) do
			local projectile = {
				-- EffectName = args.EffectName,
				vSpawnOrigin = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
				fDistance = castRange,
				fStartRadius = 40,
				fEndRadius = 40,
				Source = caster,
				vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * args.MoveSpeed,
				UnitBehavior = PROJECTILES_NOTHING,
				bMultipleHits = false,
				bIgnoreSource = true,
				TreeBehavior = PROJECTILES_NOTHING,
				bCutTrees = false,
				bTreeFullCollision = false,
				WallBehavior = PROJECTILES_NOTHING,
				GroundBehavior = PROJECTILES_NOTHING,
				fGroundOffset = 80,
				nChangeMax = 1,
				bRecreateOnChange = false,
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
					PassiveKnockback( { caster = caster, target = unit } )
					DealDamage(caster, unit, caster:GetAverageTrueAttackDamage() * ability:GetSpecialValueFor("damage_amp"), DAMAGE_TYPE_PHYSICAL)
				end,
			}

			local createdProjectile = Projectiles:CreateProjectile(projectile)

			local targetPoint = RotatePosition(caster:GetAbsOrigin(), QAngle(0,i,0), caster:GetAbsOrigin() + ((target - caster:GetAbsOrigin()):Normalized() * castRange) )

			local projectileFX = ParticleManager:CreateParticle(args.EffectName, PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(projectileFX, 0, caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")))
			ParticleManager:SetParticleControl(projectileFX, 1, targetPoint)
			ParticleManager:SetParticleControl(projectileFX, 2, Vector(args.MoveSpeed, 0, 0))
			ParticleManager:SetParticleControl(projectileFX, 3, targetPoint)

			local distanceToTarget = (caster:GetAbsOrigin() - targetPoint):Length2D()
		    local time = distanceToTarget/args.MoveSpeed

		    Timers:CreateTimer(time, function()
		    	createdProjectile:Destroy()
		        ParticleManager:DestroyParticle(projectileFX, false)
		    end)
		end
	end)
end

function PassiveKnockback( keys )
	local caster = keys.caster
	local target = keys.target

	local knockbackModifierTable =
    {
        should_stun = 1,
        knockback_duration = 1,
        duration = 1,
        knockback_distance = 100 + (GRMSC("ziv_sniper_shotgun_special_force", caster)),
        knockback_height = 100,
        center_x = caster:GetAbsOrigin().x,
        center_y = caster:GetAbsOrigin().y,
        center_z = caster:GetAbsOrigin().z
    }
	target:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )
end