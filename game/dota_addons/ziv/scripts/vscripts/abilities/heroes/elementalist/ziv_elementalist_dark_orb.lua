function DarkOrb( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:EmitSound("Hero_Warlock.ShadowWordCastBad")

	local lifetime = GetSpecial(ability, "lifetime") + (GRMSC("ziv_elementalist_dark_orb_duration", caster) / 100)
	local speed = GetSpecial(ability, "speed") + (GRMSC("ziv_elementalist_dark_orb_speed", caster) / 100)
	local radius = math.random(GetSpecial(ability, "radius") * 0.9, GetSpecial(ability, "radius"))
	local z_offset = math.random(-64,86)
	local start = Vector(0,0,z_offset) + RandomPointOnCircle(radius)

    local hitloc = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_hitloc"))

    local stack = CreateUnitByName('npc_dummy_unit', hitloc + start, true, caster, caster, caster:GetTeamNumber())
    stack:SetModel("models/units/dark_orb/dark_orb.vmdl")
    stack:SetOriginalModel("models/units/dark_orb/dark_orb.vmdl")
    Physics:Unit(stack)

    stack.ignore_sphere_z = true

	stack:RemoveCollider()
    collider = stack:AddColliderFromProfile("blocker")
    collider.radius = 100 + GRMSC("ziv_elementalist_dark_orb_radius", caster)
    collider.linear = false
  	collider.skipFrames = 1
    collider.test = function(self, collider, collided)
    	return IsValidEntity(collided) and collided:GetTeamNumber() ~= caster:GetTeamNumber() and collided.FindModifierByNameAndCaster and not collided:FindModifierByNameAndCaster("modifier_dark_orb_hit", stack) and collided:IsAlive() == true and (collided:IsControllableByAnyPlayer() or collided:GetTeamNumber() == DOTA_TEAM_NEUTRALS) and collided.GetUnitName and collided:GetUnitName() ~= "npc_dummy_unit"
    end
    collider.action = function ( self, collider, collided )
    	ability:ApplyDataDrivenModifier(stack,collided,"modifier_dark_orb_hit",{duration=180 / (speed * 30)})

    	EmitSoundOnLocationWithCaster(collided:GetAbsOrigin(),"Hero_Terrorblade.Attack",caster)

    	local particle = ParticleManager:CreateParticle("particles/heroes/elementalist/elementalist_dark_orb_explosion.vpcf",PATTACH_ABSORIGIN,collided)
    	Damage:Deal(caster, collided, GetRuneDamage(caster, GetSpecial(ability, "damage_amp"), "ziv_elementalist_dark_orb_damage"), DAMAGE_TYPE_DARK)
    end

	local angle = 0

	stack:SetPhysicsAcceleration(Vector(1,1,1))

	stack:OnPhysicsFrame(function(unit)
		if stack:IsNull() then return nil end
		local hitloc = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_hitloc"))

		local next_pos = RotatePosition(hitloc, QAngle(0,angle,0), hitloc + start)
		stack:SetForwardVector((caster:GetAbsOrigin() - next_pos):Normalized())
		stack:SetAbsOrigin(next_pos) 
		angle = angle + speed

		return 0.03
	end)

    local particle = ParticleManager:CreateParticle("particles/heroes/elementalist/elementalist_dark_orb.vpcf",PATTACH_CUSTOMORIGIN,nil)
    ParticleManager:SetParticleControlEnt(particle,0,stack,PATTACH_ABSORIGIN_FOLLOW,"attach_origin",stack:GetAbsOrigin(),false)

    Timers:CreateTimer(lifetime, function (  )
    	stack:RemoveSelf()
    	ParticleManager:DestroyParticle(particle, false)
    end)
end