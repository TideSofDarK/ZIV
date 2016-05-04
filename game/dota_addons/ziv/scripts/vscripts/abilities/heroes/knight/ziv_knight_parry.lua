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

	local knockbackModifierTable =
    {
        should_stun = 1,
        knockback_duration = 1,
        duration = 0.7,
        knockback_distance = 150 + GRMSC("ziv_knight_parry_force", caster),
        knockback_height = 50,
        center_x = caster:GetAbsOrigin().x,
        center_y = caster:GetAbsOrigin().y,
        center_z = caster:GetAbsOrigin().z
    }
	attacker:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )

    DealDamage(caster, attacker, caster:GetAverageTrueAttackDamage(), DAMAGE_TYPE_PHYSICAL)
end