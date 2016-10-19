function ProjectileImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	TimedEffect("particles/units/heroes/hero_nevermore/nevermore_base_attack_impact.vpcf", target, 1.0, 1, PATTACH_POINT_FOLLOW)
end

function Slash( keys )
	local keys = keys

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	keys.on_hit = (function ( keys )
		local target = keys.target
		local sparks = TimedEffect("particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire_explosion_c.vpcf", caster, 1.0, 3)
		ParticleManager:SetParticleControlEnt(sparks, 3, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)

		TimedEffect("particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire_explosion_c.vpcf", target, 1.0, 3, PATTACH_POINT_FOLLOW)

		local damage = GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "ziv_knight_slash_damage")

		local fire_projectile = function (restrict)
			local projectile = {
				EffectName = "particles/heroes/knight/knight_slash_projectile.vpcf",
				vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,80),
				fDistance = 1500,
				fStartRadius = 100,
				fEndRadius = 100,
				Source = caster,
				fExpireTime = 8.0,
				vVelocity = caster:GetForwardVector() * 1200,
				UnitBehavior = PROJECTILES_NOTHING,
				bMultipleHits = false,
				bIgnoreSource = true,
				TreeBehavior = PROJECTILES_NOTHING,
				bCutTrees = true,
				bTreeFullCollision = false,
				WallBehavior = PROJECTILES_DESTROY,
				GroundBehavior = PROJECTILES_NOTHING,
				fGroundOffset = 80,
				nChangeMax = 1,
				bRecreateOnChange = true,
				bZCheck = false,
				bGroundLock = true,
				bProvidesVision = false,
				draw = false,
				UnitTest = function(self, unit) return (unit:entindex() ~= target:entindex() or restrict) and unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
				OnUnitHit = function(self, unit) 
					TimedEffect("particles/heroes/knight/knight_slash_projectile_impact.vpcf", unit, 1.0, 1, PATTACH_POINT_FOLLOW)
					DealDamage(caster, unit, damage / 2, DAMAGE_TYPE_FIRE)
					unit:EmitSound("Hero_Batrider.ProjectileImpact")
				end,
			}

			Projectiles:CreateProjectile(projectile)
			caster:EmitSound("Creep_Good_Range.Attack")
		end

		fire_projectile()
		if GetRuneChance("ziv_knight_slash_projectile_chance", caster) then
			Timers:CreateTimer(0.25, function ()
				fire_projectile(true)
			end)
		end

		if GetRuneChance("ziv_knight_slash_aoe_chance",caster) then
			TimedEffect("particles/heroes/knight/knight_slash_ring.vpcf", target, 1.0)
			DoToUnitsInRadius( caster, target:GetAbsOrigin(), 300, target_team, target_type, target_flags, function ( v )
				DealDamage(caster, v, damage, DAMAGE_TYPE_PHYSICAL)
			end )
		else
			DealDamage(caster, target, damage, DAMAGE_TYPE_PHYSICAL)
			if GetRuneChance("ziv_knight_slash_stun_chance",caster) then
				target:AddNewModifier(caster,ability,"modifier_stunned",{duration = 0.2})
			end
		end
	end)

	SimulateMeleeAttack( keys )

	local sword_trail = ParticleManager:CreateParticle("particles/heroes/knight/knight_slash_trail.vpcf",PATTACH_POINT_FOLLOW,caster)
	ParticleManager:SetParticleControlEnt(sword_trail, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	Timers:CreateTimer(caster:GetAttackAnimationPoint(), function (  )
		ParticleManager:DestroyParticle(sword_trail,false)
	end)
end