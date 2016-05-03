GLAIVE_STATE_ATTACK = 0
GLAIVE_STATE_DECAY = 1
GLAIVE_STATE_SUSTAIN = 2
GLAIVE_STATE_RELEASE = 3

function SpawnGlaive( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	if GetRuneChance("ziv_dark_goddess_glaive_count",caster) == true then
		Timers:CreateTimer(0.3, function (  )
			SpawnGlaive( keys )
		end)
	end

	local glaive = CreateUnitByName("npc_dummy_unit",caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_mom_r")),false,caster,caster,caster:GetTeamNumber())
	InitAbilities(glaive)

	ability:ApplyDataDrivenModifier(caster,	glaive,	"modifier_glaive_unit",{})
	glaive:AddNewModifier(glaive,nil,"modifier_phased",{})

	local particle = ParticleManager:CreateParticle("particles/heroes/dark_goddess/dark_goddess_glaive_alt.vpcf",PATTACH_ABSORIGIN_FOLLOW,glaive)

	local projectile_speed = 4540

	Physics:Unit(glaive)

    glaive:SetPhysicsVelocityMax(5000)
    glaive:SetPhysicsFriction (0.15)
    glaive:Slide(true)
	glaive:PreventDI()

	local state = GLAIVE_STATE_ATTACK
	
	local midpoint = Vector((glaive:GetAbsOrigin()[1] + target[1]) / 2, (glaive:GetAbsOrigin()[2] + target[2]) / 2, 0)

	local point1 = RotatePosition(midpoint, QAngle(0,50,0), target)
	local point2 = target
	local point3 = RotatePosition(midpoint, QAngle(0,-50,0), target)

	local distance = point1 - glaive:GetAbsOrigin()
	local direction = distance:Normalized()
	glaive:SetPhysicsAcceleration(direction * projectile_speed)

	glaive:OnPhysicsFrame(function(unit)
		if state == GLAIVE_STATE_ATTACK then
			distance = point1 - glaive:GetAbsOrigin()
			direction = distance:Normalized()
			glaive:SetPhysicsAcceleration(direction * projectile_speed)
			
			if distance:Length() < 50 then
				state = GLAIVE_STATE_DECAY
			end
		elseif state == GLAIVE_STATE_DECAY then
			distance = point2 - glaive:GetAbsOrigin()
			direction = distance:Normalized()
			glaive:SetPhysicsAcceleration(direction * projectile_speed)

			if distance:Length() < 50 then
				state = GLAIVE_STATE_SUSTAIN
			end
		elseif state == GLAIVE_STATE_SUSTAIN then
			distance = point3 - glaive:GetAbsOrigin()
			direction = distance:Normalized()
			glaive:SetPhysicsAcceleration(direction * projectile_speed)

			if distance:Length() < 25 then
				state = GLAIVE_STATE_RELEASE
			end
		else
			distance = caster:GetAbsOrigin() - glaive:GetAbsOrigin()
			direction = distance:Normalized()
			glaive:SetPhysicsAcceleration(direction * projectile_speed)

			if distance:Length() < 100 then
			    caster:EmitSound("Hero_Luna.MoonGlaive.Impact")
			end

			if distance:Length() < 75 then
			    glaive:SetPhysicsAcceleration(Vector(0,0,0))
			    glaive:SetPhysicsVelocity(Vector(0,0,0))
			    glaive:OnPhysicsFrame(nil)

			    UTIL_Remove(glaive)
				ParticleManager:DestroyParticle(particle,false)
			end
		end
	end)
end

function BleedDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:HasModifier("modifier_glaive_bleeding") then
		DealDamage( caster, target, GetRuneDamageIncrease("ziv_dark_goddess_glaive_bleed_damage",caster) * ability:GetSpecialValueFor("bleeding_damage_amp"), DAMAGE_TYPE_PHYSICAL )
		caster:EmitSound("Hero_Pudge.Dismember")
	else
		DealDamage( caster, target, caster:GetAverageTrueAttackDamage() * ability:GetSpecialValueFor("damage_amp"), DAMAGE_TYPE_PHYSICAL )
		caster:EmitSound("Hero_Silencer.GlaivesOfWisdom.Damage")
	end
end