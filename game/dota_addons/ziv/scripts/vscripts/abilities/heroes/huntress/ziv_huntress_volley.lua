function StartVolley( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- StartAnimation(caster, {duration=0.9, activity=ACT_DOTA_OVERRIDE_ABILITY_2, rate=1.0})

	caster:AddNewModifier(caster,ability,"modifier_command_restricted",{duration=ability:GetCastPoint()})
end

function Volley(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

	StartRuneCooldown(ability,"ziv_huntress_volley_cd",caster)

	if caster:HasModifier("modifier_volley") then
		local arrows = GetSpecial(ability, "arrows") + GRMSC("ziv_huntress_volley_arrows", caster)

		local angle = 40

		for i=angle/-2,angle/2,(angle / arrows) do
			if i <= 30 then
				local projectile = {
					EffectName = "particles/heroes/huntress/huntress_volley.vpcf",
					vSpawnOrigin = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),--{unit=hero, attach="attach_attack1", offset=Vector(0,0,0)},
					fDistance = 3000,
					fStartRadius = 48,
					fEndRadius = 48,
					Source = caster,
					fExpireTime = 8.0,
					vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * 2000,
					UnitBehavior = PROJECTILES_DESTROY,
					bMultipleHits = true,
					bIgnoreSource = true,
					TreeBehavior = PROJECTILES_NOTHING,
					bCutTrees = false,
					bTreeFullCollision = false,
					WallBehavior = PROJECTILES_DESTROY,
					GroundBehavior = PROJECTILES_DESTROY,
					fGroundOffset = 120,
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
					OnUnitHit = function(self, target) 
						Damage:Deal(caster, target, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "ziv_huntress_volley_damage"), DAMAGE_TYPE_PHYSICAL)

						ability:ApplyDataDrivenModifier(caster,target,"modifier_volley_slow",{})

						EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Mirana.ProjectileImpact", target)
					end,
					--OnTreeHit = function(self, tree) ... end,
					--OnWallHit = function(self, gnvPos) ... end,
					--OnGroundHit = function(self, groundPos) ... end,
					--OnFinish = function(self, pos) ... end,
				}

				Projectiles:CreateProjectile(projectile)
			end
		end

		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Mirana.Attack", caster)

		caster:RemoveModifierByName("modifier_volley")
	end
end

function VolleyHit(keys)
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
		
	Damage:Deal(caster, target, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "ziv_huntress_volley_damage"), DAMAGE_TYPE_PHYSICAL)

	ability:ApplyDataDrivenModifier(caster,target,"modifier_volley_slow",{})

	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Mirana.ProjectileImpact", target)
end