-- Code by Dockirby
-- https://www.reddit.com/r/Dota2Modding/comments/2e23z0/ashe_ability_examplemod/

ProjectileHolder = {} 

function Volly(args)
	local caster = args.caster
	local ability = args.ability
	local target = args.target_points[1]

	caster:SetForwardVector((target - caster:GetAbsOrigin()):Normalized() )
	caster:Stop()

	local info = 
	{
		Ability = args.ability,
        EffectName = args.EffectName,
        iMoveSpeed = args.MoveSpeed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = args.FixedDistance,
        fStartRadius = args.StartRadius,
        fEndRadius = args.EndRadius,
        Source = args.caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = 0.0,
	}

	local i = -30.5
	local z = 0.04

	Timers:CreateTimer(function (  )
		if i < 30.5 and caster:HasModifier("modifier_volly") then
			caster:SetForwardVector((target - caster:GetAbsOrigin()):Normalized() )
			caster:Stop()

			info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * args.MoveSpeed
			projectile = ProjectileManager:CreateLinearProjectile(info)

			i = i + (30.5/5)
			z = z + 0.006

			StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_ATTACK, rate=3.0, translate="focusfire"})

			caster:EmitSound("Hero_DrowRanger.Attack")

			return z
		else

		end
	end)
end


function VollyHit(args)
	local target = args.target
	local caster = args.caster
	local totalDamage = caster:GetAverageTrueAttackDamage() + args.BonusDamage 
	
	local damageTable = {
			victim = target,
			attacker = caster,
			damage = totalDamage,
			damage_type = DAMAGE_TYPE_PHYSICAL,}
	ApplyDamage(damageTable)	
end

function VollyThinker(target,runCount)
	target:SetContextNum("VollyHitCheck",0,0)
return nil
end