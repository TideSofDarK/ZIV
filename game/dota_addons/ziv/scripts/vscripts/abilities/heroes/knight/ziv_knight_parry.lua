function Parry( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability

	StartAnimation(caster, {duration=1.3, activity=ACT_DOTA_CAST_ABILITY_2, rate=1.4})

	local timer = 0
	
	Timers:CreateTimer(function (  )

		caster:SetForwardVector((attacker:GetAbsOrigin() - caster:GetAbsOrigin()))
		timer = timer + 0.03
		if timer < 0.2 then return 0.03 end
	end)

	local knockbackModifierTable =
    {
        should_stun = 1,
        knockback_duration = 1,
        duration = 1,
        knockback_distance = 180,
        knockback_height = 50,
        center_x = caster:GetAbsOrigin().x,
        center_y = caster:GetAbsOrigin().y,
        center_z = caster:GetAbsOrigin().z
    }
	attacker:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )

    local damageTable = {
        victim = attacker,
        attacker = caster,
        damage = caster:GetAverageTrueAttackDamage(),
        damage_type = DAMAGE_TYPE_PHYSICAL,
    }
    ApplyDamage(damageTable)
end