function StartVolley( keys )
	local caster = keys.caster
	local ability = keys.ability

	StartAnimation(caster, {duration=1.1, activity=ACT_DOTA_ATTACK, rate=1.8})
end

function Volley(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]

	if caster:HasModifier("modifier_volley") then
		local arrows = GetSpecial(ability, "arrows") + GRMSC("ziv_huntress_volley_arrows", caster)

		local angle = 40

		for i=angle/-2,angle/2,(angle / arrows) do
			if i <= 30 then
				local info = 
				{
					Ability = ability,
			        EffectName = "particles/heroes/huntress/huntress_volley.vpcf",
			        iMoveSpeed = 100,
			        vSpawnOrigin = caster:GetAbsOrigin(),
			        fDistance = keys.FixedDistance,
			        fStartRadius = keys.StartRadius,
			        fEndRadius = keys.EndRadius,
			        Source = keys.caster,
			        bHasFrontalCone = false,
			        bReplaceExisting = false,
			        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			        fExpireTime = GameRules:GetGameTime() + 10.0,
					bDeleteOnHit = false,
					vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * keys.MoveSpeed,
				}
				projectile = ProjectileManager:CreateLinearProjectile(info)
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