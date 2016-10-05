function ColdBlastStart( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	if GetRuneChance("ziv_elementalist_cold_blast_double_chance",caster) then
		ability:EndCooldown()
	end

	local duration = GetRunePercentIncrease(GetSpecial(ability,"duration"),"ziv_elementalist_cold_blast_duration",caster)

	local thinker = ability:ApplyDataDrivenThinker(caster, target, "modifier_cold_blast", {duration = duration})

	local particle = ParticleManager:CreateParticle("particles/heroes/elementalist/elementalist_cold_blast.vpcf",PATTACH_POINT,thinker)

	thinker:EmitSound("Hero_Ancient_Apparition.IceVortexCast")
	StartSoundEvent("Hero_Invoker.ColdBlast",thinker)

	-- StartSoundEventFromPosition("Hero_Ancient_Apparition.IceVortex", target)

	Timers:CreateTimer(duration - 0.03, function () 
		ParticleManager:DestroyParticle(particle, false)
		StopSoundEvent("Hero_Invoker.ColdBlast",thinker)
	end)
end

function ColdBlastTick( keys )
	local caster = keys.caster
	local thinker = keys.target
	local ability = keys.ability

	DoToUnitsInRadius( caster, thinker:GetAbsOrigin(), GetSpecial(ability, "radius") + GRMSC("ziv_elementalist_cold_blast_radius", caster), nil, nil, nil, function ( v )
		ability:ApplyDataDrivenModifier(caster,v,"modifier_cold_blast_slow",{})
		v:SetModifierStackCount("modifier_cold_blast_slow",caster,math.abs(GetSpecial(ability,"slow")) + GRMSC("ziv_elementalist_cold_blast_slow", caster))

		local damage = GetSpecial(ability, "damage_amp") * GetSpecial(ability, "tick") * caster:GetAverageTrueAttackDamage()

		DealDamage(caster, v, damage, DAMAGE_TYPE_COLD)

		v:EmitSound("Hero_Invoker.IceWall.Slow")
	end)

	-- EmitSoundOn("Hero_Ancient_Apparition.IceBlastRelease.Tick", target)
	-- caster_owner:EmitSound("Hero_Invoker.ColdBlast.Impact")

	-- if GetRuneChance("ziv_elementalist_cold_blast_knockback_chance",caster_owner) then
	-- 	local knockback_modifier_table =
	--     {
	--         should_stun = 1,
	--         knockback_duration = 1,
	--         duration = 1,
	--         knockback_distance = 100,
	--         knockback_height = 80,
	--         center_x = caster_owner:GetAbsOrigin().x,
	--         center_y = caster_owner:GetAbsOrigin().y,
	--         center_z = caster_owner:GetAbsOrigin().z
	--     }
	-- 	target:AddNewModifier( caster_owner, nil, "modifier_knockback", knockback_modifier_table )
	-- end
end