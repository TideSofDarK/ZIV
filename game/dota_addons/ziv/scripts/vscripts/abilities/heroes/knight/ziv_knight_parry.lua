function UnequipShield( keys )
	local caster = keys.caster
	local ability = keys.ability

	Wearables:Remove(caster)
end

function EquipShield( keys )
	local caster = keys.caster
	local ability = keys.ability

	Wearables:AttachWearable(caster, "models/items/sven/arms_of_the_rogue/arms_of_the_rogue.vmdl")
end

function Parry( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability

	if caster:IsCommandRestricted() == true or not IsInFront(caster:GetAbsOrigin(),attacker:GetAbsOrigin(),caster:GetForwardVector()) then 
		ability:EndCooldown()
		return 
	end

	StartRuneCooldown(ability,"ziv_knight_parry_cd",caster)

	caster:EmitSound("Hero_DragonKnight.DragonTail.Target")

	StartAnimation(caster, {duration=1.3, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.4})

	local timer = 0
	
	Timers:CreateTimer(function (  )
		local vector = (attacker:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
		vector.z = 0
		caster:SetForwardVector(vector)
		
		timer = timer + 0.03
		if timer < 0.2 then return 0.03 end
		EndAnimation(caster)
	end)

    if not attacker:IsRangedAttacker() then
	   	local knockbackModifierTable =
	    {
	        should_stun = 1,
	        knockback_duration = 1,
	        duration = 0.4,
	        knockback_distance = 100 + GRMSC("ziv_knight_parry_force", caster),
	        knockback_height = 25,
	        center_x = caster:GetAbsOrigin().x,
	        center_y = caster:GetAbsOrigin().y,
	        center_z = caster:GetAbsOrigin().z
	    }
		attacker:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )

	    Damage:Deal(caster, attacker, GetRuneDamage(caster, GetSpecial(ability, "parry_damage_amp"), ""), DAMAGE_TYPE_PHYSICAL)

        projectileFX = ParticleManager:CreateParticle("particles/heroes/knight/knight_parry.vpcf", PATTACH_CUSTOMORIGIN, caster)
    	ParticleManager:SetParticleControl(projectileFX, 0, caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_hitloc")))
    	ParticleManager:SetParticleControl(projectileFX, 1, (attacker:GetAbsOrigin() +(attacker:GetForwardVector() * -500)))
    	ParticleManager:SetParticleControl(projectileFX, 2, Vector(900, 0, 0))
    	ParticleManager:SetParticleControl(projectileFX, 3, (attacker:GetAbsOrigin() +(attacker:GetForwardVector() * -500)))


    end
end