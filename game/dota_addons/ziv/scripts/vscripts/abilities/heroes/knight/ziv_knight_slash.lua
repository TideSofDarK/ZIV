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

		local damage = GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "ziv_knight_slash_damage")

		local FireProjectile = function (restrict)
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
					Damage:Deal(caster, unit, damage / 2, DAMAGE_TYPE_FIRE)
					unit:EmitSound("Hero_Batrider.ProjectileImpact")
				end,
			}

			Projectiles:CreateProjectile(projectile)
			caster:EmitSound("Hero_Huskar.PreAttack")
		end

		FireProjectile()
		if GetRuneChance("ziv_knight_slash_projectile_chance", caster) then
			Timers:CreateTimer(0.25, function ()
				FireProjectile(true)
			end)
		end

		if GetRuneChance("ziv_knight_slash_stun_chance",caster) then
			target:AddNewModifier(caster,ability,"modifier_stunned",{duration = 0.2})
		end

		Damage:Deal(caster, target, damage, DAMAGE_TYPE_PHYSICAL)

		TimedEffect("particles/heroes/knight/knight_slash_ring.vpcf", target, 1.0)
		DoToUnitsInRadius( caster, caster:GetAbsOrigin(), GetSpecial(ability, "radius"), target_team, target_type, target_flags, function ( v )
			if target ~= v then
				TimedEffect("particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire_explosion_c.vpcf", v, 1.0, 3, PATTACH_POINT_FOLLOW)
				Damage:Deal(caster, v, damage * (GetSpecial(ability, "secondary_damage") / 100), DAMAGE_TYPE_PHYSICAL)
			end
		end )
	end)

	keys.on_impact = function (  )
		local swipe = ParticleManager:CreateParticle("particles/heroes/knight/knight_slash_swipe.vpcf",PATTACH_CUSTOMORIGIN,nil)
		ParticleManager:SetParticleControl(swipe,0,caster:GetAbsOrigin() + (caster:GetForwardVector() * 45))
		ParticleManager:SetParticleControlOrientation(swipe,2,caster:GetForwardVector(),caster:GetRightVector(), caster:GetUpVector())
	end

	SimulateMeleeAttack( keys )
end